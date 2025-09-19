class Seguridad::ModulosController < ApplicationController
  def index
    @modulos = Current.user.accessible_modulos
  end

end
