import Config

config :sns,
  scheme: "https",
  host: "amazonaws.com",
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  region: {:system, "AWS_REGION"}

config :ex_aws, json_codec: Jason
