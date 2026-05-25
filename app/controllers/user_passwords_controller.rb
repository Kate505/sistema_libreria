class UserPasswordsController < ApplicationController
  # No saltamos la autenticación aquí, porque el usuario debe estar logueado para cambiar su contraseña obligatoria.
  # Pero sí debemos omitir la validación de 'requires_password_change' para que no haya un loop infinito.
  skip_before_action :check_password_change_required, only: [:edit, :update]
  skip_before_action :authorize_menu_access_globally, only: [:edit, :update]

  def edit
    redirect_to root_path if !Current.user.requires_password_change?
  end

  def update
    if Current.user.update(password_params.merge(requires_password_change: false))
      redirect_to root_path, notice: "Contraseña actualizada exitosamente.", status: :see_other
    else
      flash.now[:alert] = "La confirmación no coincide con la contraseña o la contraseña es inválida."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
