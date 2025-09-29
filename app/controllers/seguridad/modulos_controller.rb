class Seguridad::ModulosController < ApplicationController
  def index
    @modulos = Current.user.accessible_modulos
  end

  def lista
    @modulos = Modulo.all
  end

end
