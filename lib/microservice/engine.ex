defmodule Microservice.Engine do
  use Engine.Application, otp_app: :microservice
end

defmodule OpenFn.RunDispatcher.GenericHandler do
  use OpenFn.Run.Handler
  require Logger

  def on_log_line(line, _context) do
    Logger.debug("#{inspect(line)}")
  end
end
