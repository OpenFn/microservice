defmodule Microservice.Engine do
  use Engine.Application, otp_app: :microservice
end

defmodule OpenFn.RunDispatcher.GenericHandler do
  use Engine.Run.Handler
  require Logger

  def on_log_emit(str, _context) do
    Logger.debug("#{inspect(str)}")
  end
end
