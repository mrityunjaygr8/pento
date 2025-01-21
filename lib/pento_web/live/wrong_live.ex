defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view
  alias Pento.Accounts

  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       score: 0,
       message: "Make a guess:",
       correct: generate_correct(),
       session_id: session["live_socket_id"]
     )}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Your score: {@score}</h1>
    <h2>{@message}</h2>
    <h2>{@correct}</h2>
    <h2>{@session_id}</h2>
    <h2>{@current_user.email}</h2>
    <h2>
      <%= for n <- 1..10 do %>
        <.link href="#" phx-click="guess" phx-value-number={n}>
          {n}
        </.link>
      <% end %>
    </h2>
    """
  end

  def generate_correct do
    Enum.random(1..10)
  end

  @spec check_guess(integer(), integer(), integer()) :: %{
          message: String.t(),
          score: integer(),
          new_correct: integer()
        }
  def check_guess(guess, correct, score) do
    if guess == correct do
      %{message: "You guessed correctly. WOW!", score: score + 1, new_correct: generate_correct()}
    else
      %{
        message: "You guessed incorrectly. Try again",
        score: score - 1,
        new_correct: correct
      }
    end
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    %{message: message, score: score, new_correct: new_correct} =
      check_guess(String.to_integer(guess), socket.assigns.correct, socket.assigns.score)

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        correct: new_correct
      )
    }
  end
end
