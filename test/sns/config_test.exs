defmodule SNS.ConfigTest do
  use ExUnit.Case

  alias SNS.Config

  describe "config/3" do
    setup do
      Application.put_env(:sns, :foo, "bar")
      Application.put_env(:sns, :bar, baz: "qux")
      Application.put_env(:sns, :with_env, {:system, "HOME"})
      Application.put_env(:sns, :with_mfa, {Kernel, :+, [1, 1]})

      on_exit(fn ->
        Application.delete_env(:sns, :foo)
        Application.delete_env(:sns, :bar)
        Application.delete_env(:sns, :with_env)
        Application.delete_env(:sns, :with_mfa)
      end)
    end

    test "returns the correct config values" do
      assert Config.config(:foo) == "bar"
      assert Config.config(:bar, :baz) == "qux"
    end

    test "if the config isn't set returns the default" do
      assert Config.config(:not_set, nil, "default") == "default"
      assert Config.config(:not_set, :bar, "default") == "default"
    end

    test "correctly parses env var values" do
      assert Config.config(:with_env) == System.get_env("HOME")
    end

    test "correctly parses {m, f, a} tuples" do
      assert Config.config(:with_mfa) == 2
    end
  end

  describe "config!/2" do
    setup do
      Application.put_env(:sns, :foo, "bar")
      Application.put_env(:sns, :bar, baz: "qux")
      Application.put_env(:sns, :with_env, {:system, "HOME"})
      Application.put_env(:sns, :with_env_failure, {:system, "NO_VARIABLE_SET"})
      Application.put_env(:sns, :with_mfa, {Kernel, :+, [1, 1]})

      on_exit(fn ->
        Application.delete_env(:sns, :foo)
        Application.delete_env(:sns, :bar)
        Application.delete_env(:sns, :with_env)
        Application.delete_env(:sns, :with_mfa)
      end)
    end

    test "returns the correct config values" do
      assert Config.config!(:foo) == "bar"
      assert Config.config!(:bar, :baz) == "qux"
    end

    test "correctly parses env var values" do
      assert Config.config!(:with_env) == System.get_env("HOME")
    end

    test "correctly parses {m, f, a} tuples" do
      assert Config.config!(:with_mfa) == 2
    end

    test "if the config isn't set, raises an error" do
      assert_raise(RuntimeError, fn ->
        Config.config!(:not_set)
      end)
    end

    test "if a configured env var isn't set, raises an error" do
      assert_raise(RuntimeError, fn ->
        Config.config!(:with_env_failure)
      end)
    end
  end
end
