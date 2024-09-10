defmodule InventoryManager do
  defstruct products: [], cart: []

  # Agregar un nuevo producto al inventario
  def add_product(%InventoryManager{products: products} = inventory, name, price, stock) do
    id = length(products) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    %InventoryManager{inventory | products: products ++ [product]}
  end

  # Listar todos los productos
  def list_products(%InventoryManager{products: products}) do
    Enum.each(products, fn product ->
      IO.puts("#{product.id}. #{product.name} - Precio: $#{product.price}, Stock: #{product.stock}")
    end)
  end

  # Aumentar el stock de un producto
  def increase_stock(%InventoryManager{products: products} = inventory, id, quantity) do
    updated_products = Enum.map(products, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)
    %InventoryManager{inventory | products: updated_products}
  end

  # Vender un producto
  def sell_product(%InventoryManager{products: products, cart: cart} = inventory, id, quantity) do
    case Enum.find(products, fn product -> product.id == id end) do
      nil ->
        IO.puts("Producto no encontrado.")
        inventory

      %{} = product when product.stock >= quantity ->
        updated_product = %{product | stock: product.stock - quantity}
        updated_cart = add_to_cart(cart, id, quantity)
        %InventoryManager{
          inventory |
          products: Enum.map(products, fn p -> if p.id == id, do: updated_product, else: p end),
          cart: updated_cart
        }

      %{} ->
        IO.puts("Stock insuficiente.")
        inventory
    end
  end

  # Agregar al carrito
  defp add_to_cart(cart, id, quantity) do
    case Enum.find(cart, fn {product_id, _} -> product_id == id end) do
      nil -> cart ++ [{id, quantity}]
      {^id, existing_quantity} -> Enum.map(cart, fn
        {product_id, qty} when product_id == id -> {product_id, qty + quantity}
        item -> item
      end)
    end
  end

  # Ver el carrito de compras
  def view_cart(%InventoryManager{cart: cart}) do
    Enum.each(cart, fn {id, quantity} ->
      IO.puts("Producto ID: #{id}, Cantidad: #{quantity}")
    end)
  end

  # Realizar el checkout y vaciar el carrito
  def checkout(%InventoryManager{products: products} = inventory, cart) do
    total_cost = Enum.reduce(cart, 0, fn {id, quantity}, acc ->
      case Enum.find(products, fn p -> p.id == id end) do
        %{price: price} -> acc + (price * quantity)
        nil -> IO.puts("Producto con ID #{id} no encontrado."); acc
      end
    end)
    IO.puts("Total a pagar: $#{total_cost}")
    %InventoryManager{inventory | cart: []}
  end

  # Ejecutar el gestor de inventario
  def run do
    inventory = %InventoryManager{}
    loop(inventory)
  end

  # Bucle principal
  defp loop(inventory) do
    IO.puts("""
    Gestor de Inventario
    1. Agregar Producto
    2. Listar Productos
    3. Aumentar Stock
    4. Vender Producto
    5. Ver Carrito
    6. Checkout
    7. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el nombre del producto: ")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el precio del producto: ")
        price = IO.gets("") |> String.trim() |> String.to_float()
        IO.write("Ingrese la cantidad en stock: ")
        stock = IO.gets("") |> String.trim() |> String.to_integer()
        inventory = add_product(inventory, name, price, stock)
        loop(inventory)

      2 ->
        list_products(inventory)
        loop(inventory)

      3 ->
        IO.write("Ingrese el ID del producto: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad a aumentar: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory = increase_stock(inventory, id, quantity)
        loop(inventory)

      4 ->
        IO.write("Ingrese el ID del producto a vender: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        IO.write("Ingrese la cantidad a vender: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory = sell_product(inventory, id, quantity)
        loop(inventory)

      5 ->
        view_cart(inventory)
        loop(inventory)

      6 ->
        inventory = checkout(inventory, inventory.cart)
        loop(inventory)

      7 ->
        IO.puts("¡Adiós!")

      _ ->
        IO.puts("Opción no válida.")
        loop(inventory)
    end
  end
end

# Ejecutar el gestor de inventario
InventoryManager.run()
