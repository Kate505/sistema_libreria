namespace :facturacion do

  resources :ventas do
    collection do
      get :buscar_cliente
      get :buscar_producto
    end
    resources :detalle_ventas, only: %i[create destroy]
  end

end
