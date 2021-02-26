ExUnit.start()

Application.put_env(
  :microservice,
  :node_js_sys_path,
  "./assets/node_modules/.bin" <> ":" <> System.get_env("PATH")
)

Application.put_env(
  :microservice,
  :adaptor_path,
  "./assets/node_modules/language-http/lib/Adaptor"
)

# Ecto.Adapters.SQL.Sandbox.mode(Microservice.Repo, :manual)
