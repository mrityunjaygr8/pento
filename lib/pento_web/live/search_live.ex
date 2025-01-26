defmodule PentoWeb.SearchLive do
  use PentoWeb, :live_view
  
  alias Pento.Search
  alias Pento.Search.SearchTerm

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_search_term |> assign_search_term_form}
  end

  defp assign_search_term(socket) do
    socket |> assign(:search_term, %SearchTerm{})
  end

  defp assign_search_term_form(%{assigns: %{search_term: search_term}}=socket) do
    socket |> assign(:form, to_form(Search.change_search_term(search_term)))
  end

  def handle_event("validate", %{"search_term"=> search_term_params}, %{assigns: %{search_term: search_term}} = socket) do
    changeset = search_term
      |> Search.change_search_term(search_term_params)
      |> Map.put(:action, :validate)
    
    {:noreply,
      socket
      |> assign(:form, to_form(changeset))
    }
  end

end
