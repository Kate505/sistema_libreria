namespace :configuraciones do
  resource :negocio, controller: :negocio, only: %i[edit update] do
    post :sugerir_valores, on: :collection
  end
end
