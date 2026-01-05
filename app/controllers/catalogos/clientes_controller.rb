class Catalogos::ClientesController < ApplicationController
  before_action :set_cliente, only: %i[edit update destroy]

  def index
    @cliente = Cliente.new
    @clientes = Cliente.all.order(:primer_apellido)
  end

  def edit
    @cliente = Cliente.find_by(id: params[:id])
    render partial: "form", locals: { cliente: @cliente }
  end

  def create
    @cliente = Cliente.new(cliente_params)
    if @cliente.save
      @clientes = Cliente.all.order(:primer_apellido)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),

            turbo_stream.replace("cliente_form", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new })
          ]
        end
        format.html { redirect_to catalogos_clientes_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cliente_form", partial: "catalogos/clientes/form", locals: { cliente: @cliente }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @cliente.update(cliente_params)
      @clientes = Cliente.all.order(:primer_apellido)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),
            turbo_stream.replace("cliente_form", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new })
          ]
        end
        format.html { redirect_to catalogos_clientes_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("cliente_form", partial: "catalogos/clientes/form", locals: { cliente: @cliente }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cliente.destroy
    @clientes = Cliente.all.order(:primer_apellido)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("clientes_table", partial: "catalogos/clientes/table", locals: { clientes: @clientes }),
          turbo_stream.replace("cliente_form", partial: "catalogos/clientes/form", locals: { cliente: Cliente.new })
        ]
      end
      format.html { redirect_to catalogos_clientes_path, notice: "Eliminado" }
    end
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:primer_nombre, :segundo_nombre, :primer_apellido, :segundo_apellido, :email)
  end
end
