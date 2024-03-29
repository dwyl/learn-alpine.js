defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AppWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AppWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/demo", PageController, :demo
    get "/stopwatch", PageController, :stopwatch
    get "/playground", PageController, :playground

    live "/items", ItemLive.Index, :index
    live "/items/new", ItemLive.Index, :new

    live "/counter", CounterLive.Index, :index
    live "/select-input", SelectInputLive.Index, :index
  end
end
