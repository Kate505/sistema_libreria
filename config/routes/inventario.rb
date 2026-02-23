namespace :inventario do

  resources :productos do
    collection do
      get :buscar_categoria
    end
  end

end
