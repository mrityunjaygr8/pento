defmodule Pento.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.Catalog` context.
  """

  @doc """
  Generate a unique product sku.
  """
  def unique_product_sku() do
    Stream.iterate(1_000_000, &(&1 + 1))
    |> Stream.take_while(&(&1 <= 9_999_999))
    |> Stream.reject(&MapSet.member?(MapSet.new(), &1))
    |> Enum.random()
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        sku: unique_product_sku(),
        unit_price: 120.5
      })
      |> Pento.Catalog.create_product()

    product
  end
end
