defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def demo(conn, _params) do
    render(conn, "demo.html")
  end

  def stopwatch(conn, _params) do
    render(conn, "stopwatch.html")
  end

  def playground(conn, _params) do
    render(conn, "playground.html")
  end
end
