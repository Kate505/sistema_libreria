class Seguridad::MenusController < ApplicationController
  def index
    @menus = Menu.all
  end

  def lista
    @menus = Menu.all
  end

end
