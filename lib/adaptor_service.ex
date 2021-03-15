defmodule AdaptorService do
  require Logger

  def adaptors_from_yaml(path_to_yaml) do
    Logger.info("adaptors_from_yaml/1 called with #{inspect(path_to_yaml)}")

    jobs =
      YamlElixir.read_from_file!(path_to_yaml)
      |> Map.get("jobs")

    Map.keys(jobs)
    |> Enum.map(fn key -> jobs[key]["adaptor"] end)
    |> Enum.uniq()
  end

  # def install_adaptors(adaptors) when is_list(adaptors) do
  #   Logger.warn("install_adaptors/1 called with #{inspect(adaptors)}")
  #   Enum.each(adaptors, &ensure_installed/1)
  # end

  # def ensure_installed(adaptor) do
  #   Logger.warn("ensure_installed/1 called with #{inspect(adaptor)}")
  #   unless is_installed?(adaptor), do: install_adaptor(adaptor)
  # end

  def install_adaptors(adaptors, dir) when is_list(adaptors) do
    Logger.info("install_adaptor/1 called with #{inspect(adaptors)} and #{inspect(dir)}")

    adaptor_list =
      ["@openfn/core@github:openfn/core#allow_npm_style" | adaptors]
      |> Enum.join(" ")

    System.cmd(
      "/usr/bin/env",
      [
        "sh",
        "-c",
        "npm install --no-save --no-package-lock --global-style #{adaptor_list} --prefix #{dir}"
      ],
      stderr_to_stdout: true,
      into: IO.stream(:stdio, :line)
    )
  end

  # def is_installed?(adaptor) do
  #   Logger.warn("is_installed?/1 called with #{adaptor}")
  #   true
  # end
end
