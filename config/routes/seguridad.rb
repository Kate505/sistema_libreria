namespace :seguridad do
  resources :modulos, except: [:show]

  resources :menus, except: [:show] do
    collection do
      get :por_modulo
    end
  end

  resources :usuarios, except: [:show] do
    member do
      post :add_rol
      delete :remove_rol
    end
    collection do
      get :buscar_empleado
    end
  end

  resources :roles, except: [:show] do
    member do
      post :add_menu
      delete :remove_menu
    end
  end

  resources :empleados, except: [:show]

end
