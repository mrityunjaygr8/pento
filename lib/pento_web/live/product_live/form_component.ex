defmodule PentoWeb.ProductLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        multipart
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />
        <div phx-drop-target={@uploads.image.ref} >
          <.label>Image</.label>
          <.live_file_input upload={@uploads.image} />
        </div>

        <%= for image <- @uploads.image.entries do %>
          <div class="mt-4">
            <.live_img_preview entry={image} width="60" />
            <button phx-click="cancel-upload" phx-value-ref={image.ref} phx-target={@myself}>cancel</button>
          </div>
          <%= for err <- upload_errors(@uploads.image, image) do %>
            <.error>{err}</.error>
          <% end %>

          <progress value={image.progress} max="100" />
        <% end %>
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(Catalog.change_product(product))
      end)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1, max_file_size: 9_000_000, auto_upload: true)
     }
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset = Catalog.change_product(socket.assigns.product, product_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref, "value" => _value}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
    
  end

  def parans_with_image(socket, params) do
    path = 
      socket 
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first

    Map.put(params, "image_upload", path)
  end

  defp upload_static_file(%{path: path}, _entry) do
    filename = Path.basename(path)
    dest = Path.join("priv/static/images", filename)
    File.cp!(path, dest)
    {:ok, ~p"/images/#{filename}"}
  end

  defp save_product(socket, :edit, product_params) do
    product_params = parans_with_image(socket, product_params)
    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_product(socket, :new, product_params) do
    product_params = parans_with_image(socket, product_params)
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
