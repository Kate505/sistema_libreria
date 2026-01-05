namespace :catalogos do
  
  resources :categorias, except: [:show]
  resources :proveedores, except: [:show]
  resources :clientes, except: [:show]

end
