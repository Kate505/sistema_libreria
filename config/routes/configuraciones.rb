namespace :configuraciones do
  resource :negocio, controller: :negocio, only: %i[edit update]
end
