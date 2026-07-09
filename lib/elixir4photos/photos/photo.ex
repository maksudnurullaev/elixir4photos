defmodule Elixir4photos.Photos.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :filename, :string
    field :url, :string, virtual: true

    timestamps()
  end

  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
  end
end
