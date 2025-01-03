defmodule Aqua.Bitbucket do
  def generate_clone_url(org, repo) do
    "git@bitbucket.org:#{org}/#{repo}.git"
  end
end
