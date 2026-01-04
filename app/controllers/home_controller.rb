class HomeController < ApplicationController
  def index
    @modulos = Current.user.accessible_modulos
    @user = Current.user
  end
end
