namespace :seguridad do
  resources :modulos, except: [:show]
  resources :menus
end
