defmodule Elixir4photosWeb.CameraLive do
  use Elixir4photosWeb, :live_view

  alias Elixir4photos.Photos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :photos, Photos.list_photos())}
  end

  @impl true
  def handle_event("save_photo", %{"data_url" => data_url}, socket) do
    case Photos.save_photo(data_url) do
      {:ok, photo} ->
        {:noreply, stream_insert(socket, :photos, photo, at: 0)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Could not save photo: #{inspect(reason)}")}
    end
  end
end
