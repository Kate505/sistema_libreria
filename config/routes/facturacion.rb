namespace :facturacion do
  resources :ventas do
    collection do
      get :buscar_cliente
      post :crear_cliente
      get :buscar_producto
      get :historial
      get :volver_a_lista
    end
    member do
      patch :finalizar
    end
    resources :detalle_ventas, only: %i[create destroy]
  end
end
