defmodule Elixir4photos.PhotosTest do
  use Elixir4photos.DataCase

  alias Elixir4photos.Photos

  @tiny_jpeg_base64 "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkYEwogJC4sMDAeGRwoEiEoMCEYHBwc/8kACwgAAQABAQERAP/MAAYAEQEF/9oACAEBAAA/ANLPIP/Z"
  @data_url "data:image/jpeg;base64," <> @tiny_jpeg_base64

  setup do
    on_exit(fn ->
      case File.ls(Photos.photos_dir()) do
        {:ok, files} ->
          Enum.each(files, &File.rm(Path.join(Photos.photos_dir(), &1)))

        _ ->
          :ok
      end
    end)
  end

  test "save_photo/1 writes the file to disk and inserts a DB row" do
    assert {:ok, photo} = Photos.save_photo(@data_url)
    assert photo.filename =~ ~r/\.jpeg$/
    assert photo.url == "/photos/#{photo.filename}"

    path = Path.join(Photos.photos_dir(), photo.filename)
    assert File.exists?(path)
    assert File.read!(path) == Base.decode64!(@tiny_jpeg_base64)
  end

  test "save_photo/1 returns an error for an invalid data url" do
    assert {:error, :invalid_data_url} = Photos.save_photo("not-a-data-url")
  end

  test "list_photos/0 returns saved photos newest first" do
    {:ok, first} = Photos.save_photo(@data_url)
    {:ok, second} = Photos.save_photo(@data_url)

    assert [%{id: second_id}, %{id: first_id}] = Photos.list_photos()
    assert second_id == second.id
    assert first_id == first.id
  end
end
