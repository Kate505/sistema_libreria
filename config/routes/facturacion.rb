namespace :facturacion do
  resources :ventas do
    collection do
      get :buscar_cliente
      get :buscar_producto
      get :historial
    end
    member do
      patch :finalizar
    end
    resources :detalle_ventas, only: %i[create destroy]
  end
end
