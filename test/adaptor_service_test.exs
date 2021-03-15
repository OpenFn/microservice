defmodule AdaptorServiceTest do
  use ExUnit.Case, async: false

  import AdaptorService

  test "adaptors_from_yaml/1 returns a list of adaptors" do
    result = adaptors_from_yaml("./test/fixtures/project.yaml")
    assert result == ["@openfn/language-common"]
  end

  # test "install_adaptors/2 installs adaptors" do
  #   result = install_adaptors("@openfn/language-http", "./sample-project")
  #   assert result == :ok
  # end
end
