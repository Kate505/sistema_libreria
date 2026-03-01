namespace :estadisticas do
  resources :estadisticas_periodo, only: [ :index ]
end
