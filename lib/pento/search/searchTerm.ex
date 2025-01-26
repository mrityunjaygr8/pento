defmodule Pento.Search.SearchTerm do
  defstruct [:term]
  @types %{term: :integer}

  import Ecto.Changeset

  def changeset(%__MODULE__{} = searchTerm, attrs) do
    {searchTerm, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:term])
    |> validate_number(:term, greater_than_or_equal_to: 1_000_000, less_than_or_equal_to: 9_999_999)
  end
end
