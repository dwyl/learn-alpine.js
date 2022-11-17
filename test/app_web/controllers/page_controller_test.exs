defmodule AppWeb.PageControllerTest do
  use AppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200)
  end

  test "GET /demo", %{conn: conn} do
    conn = get(conn, "/demo")
    assert html_response(conn, 200)
  end

  test "GET /stopwatch", %{conn: conn} do
    conn = get(conn, "/stopwatch")
    assert html_response(conn, 200)
  end

  test "GET /playground", %{conn: conn} do
    conn = get(conn, "/playground")
    assert html_response(conn, 200)
  end

  test "GET /select-input", %{conn: conn} do
    conn = get(conn, "/select-input")
    assert html_response(conn, 200)
  end
end
