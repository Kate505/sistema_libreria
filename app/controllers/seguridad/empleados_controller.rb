class Seguridad::EmpleadosController < ApplicationController
  before_action :set_empleado, only: %i[edit update destroy]

  def index
    @empleado = Empleado.new
    @empleados = Empleado.all.order(:primer_apellido)
  end

  def edit
    @empleado = Empleado.find_by(id: params[:id])
    render partial: "form", locals: { empleado: @empleado }
  end

  def create
    @empleado = Empleado.new(empleado_params)
    if @empleado.save
      @empleados = Empleado.all.order(:primer_apellido)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),

            turbo_stream.replace("empleado_form", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new })
          ]
        end
        format.html { redirect_to seguridad_empleados_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("empleado_form", partial: "seguridad/empleados/form", locals: { empleado: @empleado }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @empleado.update(empleado_params)
      @empleados = Empleado.all.order(:primer_apellido)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),
            turbo_stream.replace("empleado_form", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new })
          ]
        end
        format.html { redirect_to seguridad_empleados_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("empleado_form", partial: "seguridad/empleados/form", locals: { empleado: @empleado }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @empleado.destroy
    @empleados = Empleado.all.order(:primer_apellido)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),
          turbo_stream.replace("empleado_form", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new })
        ]
      end
      format.html { redirect_to seguridad_empleados_path, notice: "Eliminado" }
    end
  end

  private

  def set_empleado
    @empleado = Empleado.find(params[:id])
  end

  def empleado_params
    params.require(:empleado).permit(:primer_nombre, :segundo_nombre, :primer_apellido, :segundo_apellido,
                                     :cargo, :salario_base, :viatico_transporte, :fecha_contratacion, :pasivo)
  end
end
