defmodule Elixir4photosWeb.CameraLiveTest do
  use Elixir4photosWeb.ConnCase

  import Phoenix.LiveViewTest

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

  test "mounts and renders the camera page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#camera-box")
    assert has_element?(view, "#camera-shoot")
  end

  test "save_photo event stores the photo and streams it to the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#photos img")

    render_hook(view, "save_photo", %{"data_url" => @data_url})

    assert has_element?(view, "#photos img")
    assert length(Photos.list_photos()) == 1
  end
end
