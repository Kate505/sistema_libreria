class Seguridad::UsuariosController < ApplicationController
  before_action :set_usuario, only: %i[edit update destroy add_rol remove_rol]

  def index
    @usuario = User.new
    @usuarios = User.all.order(:email_address)
    @roles_usuario = []
    @lista_agregar_roles = []
  end

  def edit
    @usuario = User.find_by(id: params[:id])
    @usuarios = User.all.order(:email_address)

    refresh_lists_for_view

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        frame_id = request.headers["Turbo-Frame"].presence || "usuario_form_desktop"
        suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
        render turbo_stream: turbo_stream.replace(frame_id,
                                                  partial: "seguridad/usuarios/form",
                                                  locals: { usuario: @usuario, roles_usuario: @roles_usuario, lista_agregar_roles: @lista_agregar_roles, suffix: suffix }
        )
      end
    end
  end

  def buscar_empleado
    @empleados = Empleado.empleados_sin_usuario
                         .empleados_activos
                         .por_nombre_completo(params[:q])
                         .limit(5)

    render json: @empleados.map { |e| { id: e.id, text: e.nombre_completo } }
  end

  def create
    @usuario = User.new(usuario_params.except(:password, :password_confirmation))

    # Usar la contraseña ingresada por el admin, o "Temporal123" como fallback
    nueva_password = params.dig(:user, :password).presence || "Temporal123"
    confirmacion   = params.dig(:user, :password_confirmation).presence || nueva_password

    if nueva_password != confirmacion
      @usuario.errors.add(:password, "y su confirmación no coinciden")
      refresh_lists_for_view
      return respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, lista_agregar_roles: @lista_agregar_roles }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end

    @usuario.password = nueva_password
    @usuario.password_confirmation = confirmacion
    @usuario.requires_password_change = true

    refresh_lists_for_view

    if @usuario.save
      @usuarios = User.all.order(:email_address)
      flash.now[:notice] = "Usuario creado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),
            turbo_stream.replace("usuario_form_desktop", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario, suffix: "desktop" }),
            turbo_stream.replace("usuario_form_mobile", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to seguridad_usuarios_path, notice: "Usuario creado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear el usuario."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("usuario_form_desktop", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, suffix: "desktop", lista_agregar_roles: @lista_agregar_roles }),
            turbo_stream.replace("usuario_form_mobile", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, suffix: "mobile", lista_agregar_roles: @lista_agregar_roles }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end


  def update
    params_limpios = usuario_params
    nueva_password = params_limpios.delete(:password).presence
    params_limpios.delete(:password_confirmation)

    # Si el admin activó la contraseña temporal, asignar nueva clave o usar Temporal123 como fallback
    if params_limpios[:requires_password_change] == "1"
      # Usar la contraseña ingresada o "Temporal123" como fallback
      nueva_password = nueva_password.presence || "Temporal123"
      password_confirmation = params.dig(:user, :password_confirmation).presence || nueva_password

      if nueva_password != password_confirmation
        @usuario.errors.add(:password, "y su confirmación no coinciden")
        refresh_lists_for_view
        return respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("usuario_form", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, lista_agregar_roles: @lista_agregar_roles }) }
          format.html { render :index, status: :unprocessable_entity }
        end
      end

      @usuario.password = nueva_password
      @usuario.password_confirmation = password_confirmation
    end

    if @usuario.update(params_limpios)
      @usuarios = User.all.order(:email_address)
      refresh_lists_for_view
      flash.now[:notice] = "Usuario actualizado exitosamente."

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),
            turbo_stream.replace("usuario_form_desktop", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario, suffix: "desktop" }),
            turbo_stream.replace("usuario_form_mobile", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: @roles_usuario, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to seguridad_usuarios_path, notice: "Usuario actualizado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar el usuario."
      refresh_lists_for_view
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("usuario_form_desktop", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, suffix: "desktop", lista_agregar_roles: @lista_agregar_roles }),
            turbo_stream.replace("usuario_form_mobile", partial: "seguridad/usuarios/form", locals: { usuario: @usuario, roles_usuario: @roles_usuario, suffix: "mobile", lista_agregar_roles: @lista_agregar_roles }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @usuario.destroy
    @usuarios = User.all.order(:email_address)
    flash.now[:notice] = "Usuario eliminado exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("usuarios_table", partial: "seguridad/usuarios/table", locals: { usuarios: @usuarios }),
          turbo_stream.replace("usuario_form_desktop", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: [], suffix: "desktop" }),
          turbo_stream.replace("usuario_form_mobile", partial: "seguridad/usuarios/form", locals: { usuario: User.new, roles_usuario: [], suffix: "mobile" }),
          turbo_stream.update("flash-messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to seguridad_usuarios_path, notice: "Usuario eliminado exitosamente." }
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
    params.require(:user).permit(:email_address, :empleado_id, :pasivo, :requires_password_change, :password, :password_confirmation)
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
