namespace :inventario do

  resources :productos do
    collection do
      get :buscar_categoria
      get :consulta_precios
    end
  end

end
