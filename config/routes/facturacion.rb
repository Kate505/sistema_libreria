namespace :facturacion do
  resources :ventas do
    member do
      patch :finalizar
    end
    collection do
      get :historial
      get :buscar_cliente
      get :buscar_producto
    end
    resources :detalle_ventas, only: %i[create destroy]
  end
end
