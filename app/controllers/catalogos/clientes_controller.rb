class Catalogos::ClientesController < ApplicationController
  before_action :set_cliente, only: %i[edit update destroy]

  def index
    @cliente = Cliente.new
    @clientes = Cliente.all.order(:primer_apellido)

    if params[:q].present?
      q = "%#{params[:q]}%"
      @clientes = @clientes.where(
        "primer_nombre ILIKE :q OR segundo_nombre ILIKE :q OR primer_apellido ILIKE :q OR segundo_apellido ILIKE :q OR cedula ILIKE :q OR telefono ILIKE :q",
        q: q
      )
    end

    @clientes = @clientes.page(params[:page]).per(10)
  end

  def edit
    frame_id = request.headers["Turbo-Frame"].presence || "cliente_form_desktop"
    suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
    render partial: "form", locals: { cliente: @cliente, suffix: suffix }
  end

  def create
    @cliente = Cliente.new(cliente_params)
    if @cliente.save
      @clientes = Cliente.all.order(:primer_apellido).page(1).per(10)
      flash.now[:notice] = "Cliente creado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),
            turbo_stream.replace("cliente_form_desktop", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "desktop" }),
            turbo_stream.replace("cliente_form_mobile", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_clientes_path, notice: "Cliente creado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear el cliente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cliente_form_desktop", partial: "catalogos/clientes/form", locals: { cliente: @cliente, suffix: "desktop" }),
            turbo_stream.replace("cliente_form_mobile", partial: "catalogos/clientes/form", locals: { cliente: @cliente, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @cliente.update(cliente_params)
      @clientes = Cliente.all.order(:primer_apellido).page(1).per(10)
      flash.now[:notice] = "Cliente actualizado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),
            turbo_stream.replace("cliente_form_desktop", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "desktop" }),
            turbo_stream.replace("cliente_form_mobile", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_clientes_path, notice: "Cliente actualizado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar el cliente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cliente_form_desktop", partial: "catalogos/clientes/form", locals: { cliente: @cliente, suffix: "desktop" }),
            turbo_stream.replace("cliente_form_mobile", partial: "catalogos/clientes/form", locals: { cliente: @cliente, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cliente.destroy
    @clientes = Cliente.all.order(:primer_apellido).page(1).per(10)
    flash.now[:notice] = "Cliente eliminado exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),
          turbo_stream.replace("cliente_form_desktop", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "desktop" }),
          turbo_stream.replace("cliente_form_mobile", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to catalogos_clientes_path, notice: "Cliente eliminado exitosamente." }
    end
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:primer_nombre, :segundo_nombre, :primer_apellido, :segundo_apellido, :email, :cedula, :telefono)
  end
end
