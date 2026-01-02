class Seguridad::RolesController < ApplicationController
  before_action :set_rol, only: %i[edit update destroy add_menu remove_menu]

  def index
    @rol = Rol.new
    @roles = Rol.all.order(:nombre)
    @roles_menus = []
    @lista_agregar_menus = []
    @rol_usuarios = []
  end

  def edit
    @rol = Rol.find_by(id: params[:id])
    @roles = Rol.all.order(:nombre)

    refresh_lists_for_view

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: @rol }),

          turbo_stream.update("tabs_container", partial: "seguridad/roles/tabs", locals: { rol: @rol, roles_menus: @roles_menus, lista_agregar_menus: @lista_agregar_menus, rol_usuarios: @rol_usuarios })
        ]
      end
    end
  end

  def create
    @rol = Rol.new(rol_params)
    if @rol.save
      @roles = Rol.all.order(:nombre)

      refresh_lists_for_view

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("roles_table", partial: "seguridad/roles/table_rol", locals: { roles: @roles }),
            turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: @rol }),

            # Aquí también cambia a update
            turbo_stream.update("tabs_container", partial: "seguridad/roles/tabs", locals: { rol: @rol, roles_menus: @roles_menus, lista_agregar_menus: @lista_agregar_menus, rol_usuarios: @rol_usuarios })
          ]
        end
        format.html { redirect_to seguridad_roles_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: @rol }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @rol.update(rol_params)
      @roles = Rol.all.order(:nombre)

      refresh_lists_for_view

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("roles_table", partial: "seguridad/roles/table_rol", locals: { roles: @roles }),
            turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: @rol }),

            turbo_stream.update("tabs_container", partial: "seguridad/roles/tabs", locals: { rol: @rol, roles_menus: @roles_menus, lista_agregar_menus: @lista_agregar_menus, rol_usuarios: @rol_usuarios })
          ]
        end
        format.html { redirect_to seguridad_roles_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: @rol }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @rol.destroy
    @roles = Rol.all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("roles_table", partial: "seguridad/roles/table_rol", locals: { roles: @roles }),
          turbo_stream.replace("rol_form", partial: "seguridad/roles/form", locals: { rol: Rol.new }),
          turbo_stream.replace("tabs_container", partial: "seguridad/roles/tabs", locals: { rol: Rol.new, roles_menus: [], rol_usuarios: [] })
        ]
      end
      format.html { redirect_to seguridad_roles_path, notice: "Eliminado" }
    end
  end

  def add_menu
    menu = Menu.find(params[:menu_id])

    RolesMenu.find_or_create_by(rol: @rol, menu: menu)

    refresh_lists_for_view

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("tabs_container",
                                                 partial: "seguridad/roles/tabs",
                                                 locals: { rol: @rol, roles_menus: @roles_menus, lista_agregar_menus: @lista_agregar_menus, rol_usuarios: @rol_usuarios }
        )
      end
    end
  end

  def remove_menu
    roles_menu = RolesMenu.find_by(id: params[:rol_menu_id])
    roles_menu&.destroy

    refresh_lists_for_view

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("tabs_container",
                                                 partial: "seguridad/roles/tabs",
                                                 locals: { rol: @rol, roles_menus: @roles_menus, lista_agregar_menus: @lista_agregar_menus, rol_usuarios: @rol_usuarios }
        )
      end
    end
  end

  private

  def set_rol
    @rol = Rol.find(params[:id])
  end

  def rol_params
    params.require(:rol).permit(:nombre, :pasivo)
  end

  def refresh_lists_for_view
    @roles_menus = @rol&.roles_menus.includes(:menu, menu: :modulo)
    @rol_usuarios = @rol&.roles_users.includes(:user)
    @lista_agregar_menus = Menu.where.not(id: @roles_menus.map(&:menu_id)).includes(:modulo)
  end
end
