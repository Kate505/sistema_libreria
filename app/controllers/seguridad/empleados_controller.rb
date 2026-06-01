class Seguridad::EmpleadosController < ApplicationController
  before_action :set_empleado, only: %i[edit update destroy]

  def index
    @empleado = Empleado.new
    @empleados = Empleado.all.order(:primer_apellido)

    if params[:q].present?
      q = "%#{params[:q]}%"
      @empleados = @empleados.where(
        "primer_nombre ILIKE :q OR segundo_nombre ILIKE :q OR primer_apellido ILIKE :q OR segundo_apellido ILIKE :q OR cedula ILIKE :q OR telefono ILIKE :q",
        q: q
      )
    end

    @empleados = @empleados.page(params[:page]).per(10)
  end

  def edit
    frame_id = request.headers["Turbo-Frame"].presence || "empleado_form_desktop"
    suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
    render partial: "form", locals: { empleado: @empleado, suffix: suffix }
  end

  def create
    @empleado = Empleado.new(empleado_params)
    if @empleado.save
      @empleados = Empleado.all.order(:primer_apellido).page(1).per(10)
      flash.now[:notice] = "Empleado creado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),
            turbo_stream.replace("empleado_form_desktop", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "desktop" }),
            turbo_stream.replace("empleado_form_mobile", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to seguridad_empleados_path, notice: "Empleado creado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear el empleado."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("empleado_form_desktop", partial: "seguridad/empleados/form", locals: { empleado: @empleado, suffix: "desktop" }),
            turbo_stream.replace("empleado_form_mobile", partial: "seguridad/empleados/form", locals: { empleado: @empleado, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @empleado.update(empleado_params)
      @empleados = Empleado.all.order(:primer_apellido).page(1).per(10)
      flash.now[:notice] = "Empleado actualizado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),
            turbo_stream.replace("empleado_form_desktop", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "desktop" }),
            turbo_stream.replace("empleado_form_mobile", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to seguridad_empleados_path, notice: "Empleado actualizado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar el empleado."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("empleado_form_desktop", partial: "seguridad/empleados/form", locals: { empleado: @empleado, suffix: "desktop" }),
            turbo_stream.replace("empleado_form_mobile", partial: "seguridad/empleados/form", locals: { empleado: @empleado, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @empleado.destroy
    @empleados = Empleado.all.order(:primer_apellido).page(1).per(10)
    flash.now[:notice] = "Empleado eliminado exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("empleados_table", partial: "seguridad/empleados/table", locals: { empleados: @empleados }),
          turbo_stream.replace("empleado_form_desktop", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "desktop" }),
          turbo_stream.replace("empleado_form_mobile", partial: "seguridad/empleados/form", locals: { empleado: Empleado.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to seguridad_empleados_path, notice: "Empleado eliminado exitosamente." }
    end
  end

  private

  def set_empleado
    @empleado = Empleado.find(params[:id])
  end

  def empleado_params
    params.require(:empleado).permit(:primer_nombre, :segundo_nombre, :primer_apellido, :segundo_apellido,
                                     :cargo, :fecha_contratacion, :pasivo, :cedula, :telefono)
  end
end
