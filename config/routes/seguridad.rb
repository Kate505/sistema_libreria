namespace :seguridad do
  get "modulos/index", to: "modulos#index", as: :modulos_index
  get "menus/index", to: "menus#index", as: :menus_index
end
