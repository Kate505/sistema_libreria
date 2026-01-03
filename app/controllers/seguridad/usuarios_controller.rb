class Seguridad::UsuariosController < ApplicationController
  before_action :set_usuario, only: %i[edit update destroy add_rol remove_rol]

  def index
    @usuario = User.new
    @usuarios = User.all.order(:primer_apellido)
    @roles_usuario = []
    @lista_agregar_roles = []
  end

  def edit
    @usuario = User.find_by(id: params[:id])
    @usuarios = User.all.order(:primer_apellido)

    refresh_lists_for_view

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("usuario_form",
                                                  partial: "seguridad/usuarios/form",
                                                  locals: { usuario: @usuario, roles_usuario: @roles_usuario, lista_agregar_roles: @lista_agregar_roles }
        )
      end
    end
  end

  def create
    @usuario = User.new(usuario_params)
    password_temporal = "Temporal123"

    @usuario.password = password_temporal
    @usuario.password_confirmation = password_temporal

    refresh_lists_for_view

    if @usuario.save
      @usuarios = User.all.order(:primer_apellido)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),

            turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario })
          ]
        end
        format.html { redirect_to seguridad_usuarios_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @usuario.update(usuario_params)
      @usuarios = User.all.order(:primer_apellido)
      refresh_lists_for_view

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),
            turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario })
          ]
        end
        format.html { redirect_to seguridad_usuarios_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @usuario.destroy
    @usuarios = User.all.order(:primer_apellido)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),
          turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: [] })
        ]
      end
      format.html { redirect_to seguridad_usuarios_path, notice: "Eliminado" }
    end
  end

  def por_modulo
    modulo_id = params[:modulo_id]
    target = "usuario_padre_select"

    @usuarios_filtrados = if modulo_id.present?
                            User.where(modulo_id: modulo_id)
                                .where.not(nombre: "Inicio")
                                .order(:nombre)
                          else
                            []
                          end

    render turbo_stream: turbo_stream.replace(
      target,
      partial: "seguridad/usuarios/select_usuario_padre",
      locals: { usuarios: @usuarios_filtrados, selected: nil }
    )
  end

  def add_rol
    rol = Rol.find(params[:rol_id])
    RolesUser.find_or_create_by(user: @usuario, rol: rol)

    refresh_lists_for_view
    update_modal_stream
  end

  def remove_rol
    rol_user = RolesUser.find_by(user: @usuario, rol_id: params[:rol_id])
    rol_user&.destroy

    refresh_lists_for_view
    update_modal_stream
  end

  private

  def set_usuario
    @usuario = User.find(params[:id])
  end

  def usuario_params
    params.require(:user).permit(:email_address, :pasivo)
  end

  def refresh_lists_for_view
    @roles_usuario = @usuario&.roles || []

    if @usuario&.persisted?
      ids_excluir = @roles_usuario.pluck(:id)
      @lista_agregar_roles = Rol.where.not(id: ids_excluir)
    else
      @lista_agregar_roles = []
    end
  end

  def update_modal_stream
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("tbody_roles_asignados",
                              partial: "seguridad/usuarios/lista_roles_asignados",
                              locals: { roles_usuario: @roles_usuario, usuario: @usuario }),

          turbo_stream.update("tbody_roles_disponibles",
                              partial: "seguridad/usuarios/lista_roles_disponibles",
                              locals: { lista_agregar_roles: @lista_agregar_roles, usuario: @usuario })
        ]
      end
    end
  end
end
