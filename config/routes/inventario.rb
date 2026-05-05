namespace :inventario do
  resources :ordenes_de_compra do
    collection do
      get :buscar_proveedor
      get :buscar_producto
    end
    resources :detalle_ordenes_de_compra, only: %i[create destroy]
  end

  resources :productos do
    collection do
      get :buscar_categoria
      get :buscar_marca
      get :consulta_precios
    end
  end
end
