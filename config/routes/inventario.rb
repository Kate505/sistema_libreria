namespace :inventario do
  resources :ordenes_de_compra do
    collection do
      get :buscar_proveedor
      get :buscar_producto
      post :crear_proveedor
    end
    member do
      patch :finalizar
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
