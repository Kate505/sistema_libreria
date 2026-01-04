namespace :catalogos do
  
  resources :categorias, except: [:show]
  resources :proveedores, except: [:show]

end
