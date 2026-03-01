namespace :finanzas do
  resources :gastos_operativos do
    member do
      post :importar_nomina
    end
    resources :detalle_pagos_empleados, only: %i[edit create update destroy]
  end

  resources :nomina_empleados, only: [ :index ]
end
