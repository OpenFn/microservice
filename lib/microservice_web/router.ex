defmodule MicroserviceWeb.Router do
  use MicroserviceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # TODO: Replace MicroserviceWeb.OpenFnInbox with hex OpenFnInbox application.
  # scope "/inbox", OpenFnInbox do
  #   pipe_through(:api)

  #   post("/", OpenFnInbox, :receive)
  # end

  scope "/inbox", MicroserviceWeb do
    pipe_through(:api)

    post("/", OpenFnInbox, :receive)
  end
end
