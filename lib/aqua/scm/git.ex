defmodule Aqua.SCM.Git do
  @moduledoc false
  def clone(git_repo_url, path) when is_binary(git_repo_url) and is_binary(path) do
    git_run(["clone", git_repo_url, path])
  end

  def clone_repo(url, fs) do
    case git_run(["clone", url, fs]) do
      {message, 0} -> {:ok, message}
      error -> decorate_error(error)
    end
  end

  def pull_repo(fs) do
    branch_name = branch_name(fs)

    case git_run(["-C", fs, "fetch", "origin", branch_name]) do
      {_message, 0} ->
        case git_run(["-C", fs, "reset", "--hard", "origin/#{branch_name}"]) do
          {message, 0} -> {:ok, message}
          error -> decorate_error(error)
        end

      error ->
        decorate_error(error)
    end
  end

  defp branch_name(fs) do
    case git_run(["-C", fs, "rev-parse", "--abbrev-ref", "HEAD"]) do
      {branch_name, 0} -> String.trim(branch_name)
      _ -> "master"
    end
  end

  defp git_run(args) do
    System.cmd("git", args, stderr_to_stdout: true)
  end

  @spec decorate_error(error :: {any(), integer()}) :: {:error, any()}
  defp decorate_error({reason, _error_code}) do
    {:error,
     String.split(reason, ["ERROR: ", "fatal: "])
     |> Enum.reverse()
     |> Enum.at(0)}
  end
end
