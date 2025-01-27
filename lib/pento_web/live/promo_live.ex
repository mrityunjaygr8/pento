defmodule PentoWeb.PromoLive do
  use PentoWeb, :live_view

  alias Pento.Promo
  alias Pento.Promo.Recipient

  def mount(_params, _session, socket) do
    socket = socket |> assign_recipient() |> assign_changeset()
    # IO.puts(socket.assigns)
    {:ok, socket}
  end

  def assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{})
  end

  def assign_changeset(%{assigns: %{recipient: recipient}} = socket) do
    socket
    |> assign(:changeset, to_form(Promo.change_recipient(recipient)))
  end

  def handle_event(
        "validate",
        %{"recipient" => recipient_params},
        %{assigns: %{recipient: recipient}} = socket
      ) do
    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, to_form(changeset))}
  end

  def handle_event("save", %{"recipient" => _recipient_params}, _socket) do
    :timer.sleep(2000)
  end
end
