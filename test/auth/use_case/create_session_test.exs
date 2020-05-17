defmodule Auth.UseCase.CreateSessionTest do
  use ExUnit.Case, async: true

  alias Auth.UseCase.CreateSession

  defp invalid_google_auth(_context) do
    auth_data = %Ueberauth.Failure{
      errors: [%Ueberauth.Failure.Error{message: "No code received", message_key: "missing_code"}],
      provider: :google,
      strategy: Ueberauth.Strategy.Google
    }

    {:ok, %{auth_data: auth_data}}
  end

  defp valid_google_auth(_context) do
    auth_data = %Ueberauth.Auth{
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

    {:ok, %{auth_data: auth_data}}
  end

  defp invalid_unknown_auth(_context) do
    auth_data = %Ueberauth.Failure{
      errors: [%Ueberauth.Failure.Error{message: "No code received", message_key: "missing_code"}],
      provider: :foobar
    }

    {:ok, %{auth_data: auth_data}}
  end

  defp valid_unknown_auth(_context) do
    auth_data = %Ueberauth.Auth{
      info: %Ueberauth.Auth.Info{
        email: "me@acme.com",
        image: "https://lh6.googleusercontent.com/photo.jpg"
      },
      provider: :foobar,
      uid: "123"
    }

    {:ok, %{auth_data: auth_data}}
  end

  describe "without data" do
    test "returns an error" do
      assert {:error, ["Bad request"]} = CreateSession.execute(%{})
    end
  end

  describe "with a invalid google auth" do
    setup [:invalid_google_auth]

    test "returns the error", %{auth_data: auth_data} do
      assert {:error, ["No code received"]} = CreateSession.execute(auth_data)
    end
  end

  describe "with a valid google auth" do
    setup [:valid_google_auth]

    test "returns the error", %{auth_data: auth_data} do
      assert {:ok, user_info} = CreateSession.execute(auth_data)
      assert user_info.email == "me@acme.com"
      assert user_info.image == "https://lh6.googleusercontent.com/photo.jpg"
      assert user_info.uid == "123"
    end
  end

  describe "with an invalid and unknown provider" do
    setup [:invalid_unknown_auth]

    test "returns an error", %{auth_data: auth_data} do
      assert {:error, ["Bad request"]} = CreateSession.execute(auth_data)
    end
  end

  describe "with an valid but unknown provider" do
    setup [:valid_unknown_auth]

    test "returns an error", %{auth_data: auth_data} do
      assert {:error, ["Bad request"]} = CreateSession.execute(auth_data)
    end
  end
end
