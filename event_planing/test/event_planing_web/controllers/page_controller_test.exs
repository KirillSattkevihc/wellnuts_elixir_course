defmodule EventPlaningWeb.PageControllerTest do
  use EventPlaningWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "1234"
  end
end
