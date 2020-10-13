ExUnit.start()

Application.put_env(:microservice, :expression_path, "./test/config/expression.js")
Application.put_env(:microservice, :credential_path, "./test/config/credential.json")
Application.put_env(:microservice, :final_state_path, nil)

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
