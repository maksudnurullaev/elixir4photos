defmodule Elixir4photos.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :filename, :string, null: false

      timestamps()
    end
  end
end
