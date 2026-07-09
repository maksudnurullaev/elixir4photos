defmodule Elixir4photos.Photos do
  @moduledoc """
  Context for capturing and persisting photos taken from the browser camera.
  """

  import Ecto.Query, warn: false
  alias Elixir4photos.Repo
  alias Elixir4photos.Photos.Photo

  def list_photos do
    Photo
    |> order_by([p], desc: p.inserted_at, desc: p.id)
    |> Repo.all()
    |> Enum.map(&with_url/1)
  end

  def save_photo(data_url) when is_binary(data_url) do
    with [_header, base64] <- String.split(data_url, ",", parts: 2),
         {:ok, binary} <- Base.decode64(base64) do
      filename = Ecto.UUID.generate() <> ".jpeg"

      File.mkdir_p!(photos_dir())
      File.write!(Path.join(photos_dir(), filename), binary)

      %Photo{}
      |> Photo.changeset(%{filename: filename})
      |> Repo.insert()
      |> case do
        {:ok, photo} -> {:ok, with_url(photo)}
        error -> error
      end
    else
      _ -> {:error, :invalid_data_url}
    end
  end

  def photos_dir do
    Application.get_env(
      :elixir4photos,
      :photos_dir,
      Path.join([:code.priv_dir(:elixir4photos), "static", "photos"])
    )
  end

  def photo_url(%Photo{filename: filename}), do: "/photos/#{filename}"

  defp with_url(%Photo{} = photo), do: %{photo | url: photo_url(photo)}
end
