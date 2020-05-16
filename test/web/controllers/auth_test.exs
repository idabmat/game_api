defmodule Web.Controllers.Authtest do
  use Web.ConnCase

  setup do
    {:ok, auth: %Ueberauth.Auth{}}
  end

  describe "google provider" do
    test "request phase", %{conn: conn} do
      conn = get(conn, "/auth/google")
      assert String.match?(response(conn, 302), ~r/accounts\.google\.com/)
    end

    test "successful callback", %{conn: conn, auth: auth} do
      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get("/auth/google/callback")

      assert json_response(conn, 200) == %{"status" => "Signed in"}
    end

    test "failed callback", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_failure, :failed)
        |> get("/auth/google/callback")

      assert json_response(conn, 400) == %{"status" => "Failed to authenticate"}
    end
  end

  describe "unknown provider" do
    test "request phase", %{conn: conn} do
      conn = get(conn, "/auth/foobar")
      assert json_response(conn, 200) == %{}
    end
  end
end
