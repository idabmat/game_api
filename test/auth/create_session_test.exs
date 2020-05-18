defmodule Auth.CreateSessionTest do
  use ExUnit.Case, async: true

  alias Auth.Account
  alias Auth.Account.InMemory
  alias Auth.CreateSession

  defp invalid_google_auth do
    %Ueberauth.Failure{
      errors: [%Ueberauth.Failure.Error{message: "No code received", message_key: "missing_code"}],
      provider: :google,
      strategy: Ueberauth.Strategy.Google
    }
  end

  defp valid_google_auth do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{},
      extra: %Ueberauth.Auth.Extra{},
      info: %Ueberauth.Auth.Info{
        email: "me@acme.com",
        image: "https://lh6.googleusercontent.com/photo.jpg"
      },
      provider: :google,
      strategy: Ueberauth.Strategy.Google,
      uid: "123"
    }
  end

  defp invalid_unknown_auth do
    %Ueberauth.Failure{
      errors: [%Ueberauth.Failure.Error{message: "No code received", message_key: "missing_code"}],
      provider: :foobar
    }
  end

  defp valid_unknown_auth do
    %Ueberauth.Auth{
      info: %Ueberauth.Auth.Info{
        email: "me@acme.com",
        image: "https://lh6.googleusercontent.com/photo.jpg"
      },
      provider: :foobar,
      uid: "123"
    }
  end

  setup do
    start_supervised!(InMemory)
    :ok
  end

  describe "without data" do
    setup do
      result = CreateSession.execute(%{}, account_gateway: InMemory)
      {:ok, %{result: result}}
    end

    test "returns an error", %{result: result} do
      assert result == {:error, ["Bad request"]}
    end

    test "does not create an account" do
      assert InMemory.size() == 0
    end
  end

  describe "with a invalid google auth" do
    setup do
      auth_data = invalid_google_auth()
      result = CreateSession.execute(auth_data, account_gateway: InMemory)
      {:ok, %{result: result}}
    end

    test "returns the error", %{result: result} do
      assert result == {:error, ["No code received"]}
    end

    test "does not create an account" do
      assert InMemory.size() == 0
    end
  end

  describe "with a valid google auth and no previous account" do
    setup do
      auth_data = valid_google_auth()
      result = CreateSession.execute(auth_data, account_gateway: InMemory)
      {:ok, %{result: result}}
    end

    test "returns the profile", %{result: result} do
      assert {:ok, profile} = result
      assert profile.email == "me@acme.com"
      assert profile.image == "https://lh6.googleusercontent.com/photo.jpg"
      assert profile.uid == "123"
    end

    test "creates an account", %{result: result} do
      assert {:ok, profile} = result
      assert InMemory.get({:google, "123"}) == profile
      assert InMemory.size() == 1
    end
  end

  describe "with a valid google auth and a previous account" do
    setup do
      previous_account = %Account{provider: :google, uid: "123", email: "old@email.com"}
      InMemory.set(previous_account)
      auth_data = valid_google_auth()
      result = CreateSession.execute(auth_data, account_gateway: InMemory)
      {:ok, %{result: result}}
    end

    test "returns the updated profile", %{result: result} do
      assert {:ok, profile} = result
      assert profile.email == "me@acme.com"
      assert profile.image == "https://lh6.googleusercontent.com/photo.jpg"
      assert profile.uid == "123"
    end

    test "updates the existing account", %{result: result} do
      assert {:ok, profile} = result
      assert InMemory.get({:google, "123"}) == profile
      assert InMemory.size() == 1
    end
  end

  describe "with an invalid and unknown provider" do
    setup do
      auth_data = invalid_unknown_auth()
      result = CreateSession.execute(auth_data, account_gateway: InMemory)
      {:ok, %{result: result}}
    end

    test "returns an error", %{result: result} do
      assert result == {:error, ["Bad request"]}
    end

    test "does not create an account" do
      assert InMemory.size() == 0
    end
  end

  describe "with an valid but unknown provider" do
    setup do
      auth_data = valid_unknown_auth()
      result = CreateSession.execute(auth_data, account_data: InMemory)
      {:ok, %{result: result}}
    end

    test "returns an error", %{result: result} do
      assert result == {:error, ["Bad request"]}
    end

    test "does not create an account" do
      assert InMemory.size() == 0
    end
  end
end
