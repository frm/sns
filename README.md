# SNS

**⚠️ WARNING: This library is missing automatic tests and is not yet deemed
production ready. Proceed at your own peril ⚠️**

SNS is the internal wrapper for AWS SNS used in some of my projects.

A few goodies:

- Automatically subscribes to SNS via HTTP/HTTPS protocol on startup;
- Abstracts away the nasty HTTP callback flow;
- Allows configuring a local pub sub that mocks the AWS API so you can develop
  locally and test with confidence without AWS configs or testing hacks;
- Allows you to set up multiple different subscriptions in the same app, perfect
  for umbrella apps.

**Table of Contents**

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Development](#development)
- [About](#about)

## Installation

Add `:sns` as a dependency in your `mix.exs`. Until this package is production
ready, please use the latest tag from GitHub.

```elixir
def deps do
  [{:sns, git: "git@github.com:frm/sns.git", tag: "0.4.0"}]
end
```

## Quick Start

tl;dr:

1. configure `:sns`;
2. (optional) start the local server and the automatic subscription;
3. define a handler;
4. add the callback plug.

```elixir
# config/config.exs
config :sns,
  scheme: {:system, "AWS_SNS_SCHEME"},
  host: {:system, "AWS_SNS_HOST"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  # requires you to have this environment variable set up,
  # even if you don't use the AWS API
  region: {:system, "AWS_REGION"},
  # if running locally instead of using AWS, use SNS.API.Mock instead
  adapter: SNS.API.AWS

config :my_app, MyApp.SNS.Subscription,
  endpoint: {:system, "SNS_ENDPOINT"},
  topic: {:system, "SNS_TOPIC"},
  protocol: "http" # you'll want "https" in production


# (optional) lib/application.ex
def MyApp.Application do
  # ...

  @impl true
  def start(_type, _args) do
    children = [
      # optional, automatically subscribes on startup,
      # remove it if you want to subscribe to a topic manually
      {MyApp.SNS.Subscription,
        Application.fetch_env!(:my_app, MyApp.SNS.Subscription},
      # only add this if you're running locally, instead of using AWS,
      # for development purposes only.
      SNS.Local.PubSub
    ]

    # ...
  end
end

# (optional) lib/sns/subscription.ex
defmodule MyApp.SNS.Subscription do
  # optional, only do this if you want to automatically subscribe to the given
  # topic on startup
  use SNS.Subscription
end


# lib/my_app/sns/handler.ex
defmodule MyApp.SNS.Handler do
  # handle new messages here
  def handle(message) do
    IO.puts("just received #{inspect(message)}"
  end
end


# lib/my_app_web/router.ex
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ...

  forward "/sns/callback", SNS.Router, handler: MyApp.SNS.Handler

  # ...
end
```

If you want a detailed explanation on what all of this is, see below.

## Usage

SNS was built to have two distinct modes that act similarly

- when in development or test, you should be able to make use of everything that AWS
  provides you without actually having to configure it.
- when in production, you should hit AWS but allow `:sns` to handle subscription
  confirmation and all those things developers don't want to handle.

There is a base set of config params that are shared across both modes, which
you'll always need:

```elixir
# config/config.exs
config :sns,
  scheme: {:system, "AWS_SNS_SCHEME"},
  host: {:system, "AWS_SNS_HOST"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  # requires you to have this environment variable set up,
  # even if you don't use the AWS API
  region: {:system, "AWS_REGION"}
```

The way `:sns` works is by defining a plug that receives HTTP subscription
events from AWS SNS. In your `router.ex`
file:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ...

  forward "/sns/callback", SNS.Router, handler: MyApp.SNS.Handler

  # ...
end
```

To start handling events, you just need to define your own handler. It should
implement a `handle/1` function that receives a binary string.

```elixir
defmodule MyApp.SNS.Handler do
  def handle(message) do
    IO.puts("just received #{inspect(message)}"
  end
end
```

The one final thing that remains is actually subscribing to a topic. You can
either call `SNS.API.subscribe/4` or you can make use of the
`SNS.Subscription` module. This is a utility task that you can add to your
`application.ex` so that it automatically subscribes to the configured topics.

As an example:

```elixir
# lib/application.ex
def MyApp.Application do
  # ...

  @impl true
  def start(_type, _args) do
    children = [
      # automatically subscribes on startup
      {MyApp.SNS.Subscription,
        Application.fetch_env!(:my_app, MyApp.SNS.Subscription},
    ]

    # ...
  end
end

# config/config.exs
# you can hardcode these values or use them as env variables
config :my_app, MyApp.SNS.Subscription,
  endpoint: {:system, "SNS_ENDPOINT"},
  topic: {:system, "SNS_TOPIC"},
  protocol: "http" # make sure you use "https" in prod

# lib/my_app/sns/subscription.ex
defmodule MyApp.SNS.Subscription do
  use SNS.Subscription
end
```

Depending on what you want to do, the next stages differ.

### I want to use it in development

Perfect, so you'll have to do two things:

1. add `SNS.Local.PubSub` to your `application.ex` file, just like in the
   `SNS.Subscription` example above. This is a pub sub server that mimics
   AWS behaviour;
2. configure `:sns` to use the mock API adapter by adding `adapter:
SNS.API.Mock` to the `config/config.exs` file as per the example in
   [Quick Start](#quick-start).

### I want to use it in production

Scrumptious, so to do that, you'll just have make sure you have the right environment
variables set and now just configure `:sns` to use the AWS API adapter by
adding `adapter: SNS.API.AWS` to the `config/config.exs` file, as per the
example in [Quick Start](#quick-start).

### Umbrella apps

`:sns` was written to work well with umbrella apps. You can define a handler for
each separate router:

```elixir
#
# Configuring AppOne
#

# apps/app_one/lib/app_one/sns/handler.ex
defmodule AppOne.SNS.Handler do
  def handle(message) do
    # handle things in any way you like
  end
end

# apps/app_one/lib/app_one_web/router.ex
defmodule AppOneWeb.Router do
  use MyAppWeb, :router

  # ...

  forward "/sns/callback", SNS.Router, handler: MyApp.SNS.Handler

  # ...
end

# (optional) apps/app_one/lib/app_one/application.ex
def AppOne.Application do
  # ...

  @impl true
  def start(_type, _args) do
    children = [
      # optional, automatically subscribes on startup,
      # remove it if you want to subscribe to a topic manually
      {
        AppOne.SNS.Subscription,
        Application.fetch_env!(:app_one, AppOne.SNS.Subscription)
      },
      # only add this if you're running locally, instead of using AWS,
      # for development purposes only.
      SNS.Local.PubSub
    ]

    # ...
  end
end

# (optional) apps/app_one/lib/app_one/sns/subscription.ex
defmodule AppOne.SNS.Subscription do
  # optional, only do this if you want to automatically subscribe to the given
  # topic on startup
  use SNS.Subscription
end

#
# Configuring AppTwo
#

# apps/app_two/lib/app_two/sns/handler.ex
defmodule AppTwo.SNS.Handler do
  def handle(message) do
    # handle things in any way you like
  end
end

# apps/app_two/lib/app_two_web/router.ex
defmodule AppTwoWeb.Router do
  use MyAppWeb, :router

  # ...

  forward "/sns/callback", SNS.Router, handler: MyApp.SNS.Handler

  # ...
end

# (optional) apps/app_two/lib/app_two/application.ex
def AppTwo.Application do
  # ...

  @impl true
  def start(_type, _args) do
    children = [
      # optional, automatically subscribes on startup,
      # remove it if you want to subscribe to a topic manually
      {
        AppTwo.SNS.Subscription,
        Application.fetch_env!(:app_two, AppTwo.SNS.Subscription)
      },
      # only add this if you're running locally, instead of using AWS,
      # for development purposes only.
      SNS.Local.PubSub
    ]

    # ...
  end
end

# (optional) apps/app_two/lib/app_two/sns/subscription.ex
defmodule AppTwo.SNS.Subscription do
  # optional, only do this if you want to automatically subscribe to the given
  # topic on startup
  use SNS.Subscription
end
```

In the example above, we configure two umbrella apps. In this case, each of them
would have a dedicated endpoint to handle SNS callbacks and they could even each
have a different subscription topic.

### Production security concerns

Since this library relies on adding a publicly accessible endpoint to confirm
subscriptions and receive events, we need to protect against an outside party
jamming it. To do that, you can use route obfuscation.

As an example:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  # ...

  post "/sns/:api_key/callback",
    SNS.Router,
    handler: MyApp.SNS.Handler,
    verify_with: {"api_key", {:system, "INTERNAL_SNS_API_KEY"}}

  # ...
end
```

Using a route param with the `:verify_with` option will cause the plug to
validate the path is the same as your internal API Key to prevent malicious
third-parties. While not a complete solution, this helps easily obfuscate the
endpoint being used.

The `:verify_with` receives a tuple with the first element being the route
param to check against and the second element either the value of the API key or
a `{:system, env_var_name}` tuple. This will check the environment in runtime to
avoid compile-time env var issues.

## Development

If you want to help develop, please feel free to open issues, pull requests, the
works. All contributions welcome but they **must** follow the [Code of Conduct][coc].

There's a development utility included, that runs a [`cowboy`][cowboy] server to
handle the callbacks:

```elixir
SNS.Local.Server.start() # starts the server
```

## About

&copy; 2022 Fernando Mendes

It is open-source, made available for free, and is subject to the terms in its
[license].

[license]: ./LICENSE
[coc]: ./CODE_OF_CONDUCT.md
[cowboy]: https://github.com/ninenines/cowboy
