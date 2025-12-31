class Seguridad::MenusController < ApplicationController
  before_action :set_menu, only: %i[edit update destroy]

  def index
    @menu = Menu.new
    @menus = Menu.all.order(:nombre)
  end

  def edit
    @menu = Menu.find_by(id: params[:id])
    render partial: "form", locals: { menu: @menu }
  end

  def create
    @menu = Menu.new(menu_params)
    if @menu.save
      @menus = Menu.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("menus_table", partial: "seguridad/menus/table", locals: { menus: @menus }),

            turbo_stream.replace("menu_form", partial: "seguridad/menus/form", locals: { menu: Menu.new })
          ]
        end
        format.html { redirect_to seguridad_menus_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("menu_form", partial: "seguridad/menus/form", locals: { menu: @menu }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @menu.update(menu_params)
      @menus = Menu.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("menus_table", partial: "seguridad/menus/table", locals: { menus: @menus }),
            turbo_stream.replace("menu_form", partial: "seguridad/menus/form", locals: { menu: Menu.new })
          ]
        end
        format.html { redirect_to seguridad_menus_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("menu_form", partial: "seguridad/menus/form", locals: { menu: @menu }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @menu.destroy
    @menus = Menu.all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("menus_table", partial: "seguridad/menus/table", locals: { menus: @menus }),
          turbo_stream.replace("menu_form", partial: "seguridad/menus/form", locals: { menu: Menu.new })
        ]
      end
      format.html { redirect_to seguridad_menus_path, notice: "Eliminado" }
    end
  end

  def por_modulo
    modulo_id = params[:modulo_id]
    target = "menu_padre_select"

    @menus_filtrados = if modulo_id.present?
                         Menu.where(modulo_id: modulo_id)
                             .where.not(nombre: "Inicio")
                             .order(:nombre)
    else
                         []
                       end

    render turbo_stream: turbo_stream.replace(
      target,
      partial: "seguridad/menus/select_menu_padre",
      locals: { menus: @menus_filtrados, selected: nil }
    )
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:nombre, :codigo, :modulo_id, :menu_id, :link_to, :pasivo)
  end
end
