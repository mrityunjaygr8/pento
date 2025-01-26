defmodule Pento.Search do
  alias Pento.Search.SearchTerm

  def change_search_term(%SearchTerm{} = searchTerm, attrs \\ %{}) do
    SearchTerm.changeset(searchTerm, attrs)
  end

  def search(_searchTerm, _attrs) do
    {:ok, %SearchTerm{}}
  end
end
