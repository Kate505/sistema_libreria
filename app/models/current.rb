class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :configuracion_negocio
  delegate :user, to: :session, allow_nil: true
end
