defmodule Discuss.Repo do
  use Ecto.Repo,
    otp_app: :Discuss,
    adapter: Ecto.Adapters.Postgres
end
