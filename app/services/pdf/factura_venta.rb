require 'prawn'
require 'prawn/table'

module Pdf
  class FacturaVenta < Prawn::Document
    def initialize(venta)
      # Configuramos el PDF (A4 tipo Carta)
      super(page_size: 'LETTER', margin: [40, 40, 40, 40])
      @venta = venta
      @detalles = @venta.detalle_ventas.includes(:producto).order(:created_at)

      generar_documento
    end

    def generar_documento
      encabezado
      move_down 20
      datos_venta
      move_down 20
      tabla_detalles
      move_down 20
      totales
      pie_de_pagina
    end

    private

    def encabezado
      text "Sistema Librería", size: 24, style: :bold, align: :center
      text "Dirección de la Tienda Principal", align: :center
      text "Teléfono: (505) 0000-0000", align: :center
      text "RUC: 123456789", align: :center
    end

    def datos_venta
      bounding_box([0, cursor], width: bounds.width) do
        stroke_bounds if false # debug
        
        # Columna Izquierda
        bounding_box([0, bounds.height], width: bounds.width / 2) do
          fecha = @venta.fecha_venta ? @venta.fecha_venta.strftime("%d/%m/%Y %H:%M") : Time.current.strftime("%d/%m/%Y %H:%M")
          text "<b>Fecha:</b> #{fecha}", inline_format: true
          
          metodo = if @venta.metodo_pago.present?
                     Venta::METODOS_PAGO[@venta.metodo_pago] || @venta.metodo_pago
                   else
                     "N/A"
                   end
          text "<b>Método de Pago:</b> #{metodo}", inline_format: true
          
          estado = @venta.finalizada? ? "Finalizada" : "Pendiente"
          text "<b>Estado:</b> #{estado}", inline_format: true
        end

        # Columna Derecha
        bounding_box([bounds.width / 2, bounds.height], width: bounds.width / 2) do
          text "<b>Factura Nº:</b> #{@venta.id.to_s.rjust(6, '0')}", align: :right, inline_format: true
          
          cliente = @venta.cliente ? "#{@venta.cliente.primer_nombre} #{@venta.cliente.primer_apellido}" : "Consumidor Final"
          text "<b>Cliente:</b> #{cliente}", align: :right, inline_format: true
        end
      end
    end

    def tabla_detalles
      tabla_datos = [["Cantidad", "Producto", "P. Unitario (C$)", "Subtotal (C$)"]]
      
      @detalles.each do |detalle|
        tabla_datos << [
          detalle.cantidad.to_s,
          detalle.producto.nombre,
          ActionController::Base.helpers.number_with_precision(detalle.precio_unitario_venta, precision: 2, delimiter: ','),
          ActionController::Base.helpers.number_with_precision(detalle.subtotal, precision: 2, delimiter: ',')
        ]
      end

      table(tabla_datos, width: bounds.width, header: true) do
        row(0).font_style = :bold
        row(0).background_color = "f0f0f0"
        row(0).align = :center
        
        columns(0).align = :center
        columns(2).align = :right
        columns(3).align = :right
        
        cells.padding = 8
        cells.borders = [:bottom]
        cells.border_width = 0.5
        cells.border_color = "cccccc"
      end
    end

    def totales
      move_down 10
      total = ActionController::Base.helpers.number_with_precision(@venta.cantidad_total, precision: 2, delimiter: ',')
      
      bounding_box([bounds.width - 200, cursor], width: 200) do
        text "<b>Total: C$ #{total}</b>", align: :right, inline_format: true, size: 14
      end
    end

    def pie_de_pagina
      move_down 50
      text "¡Gracias por su compra!", align: :center, style: :italic
      text "Este documento no es un comprobante fiscal válido a menos que se indique lo contrario", align: :center, size: 8, color: "777777"
      
      number_pages "Página <page> de <total>", {
        start_count_at: 1,
        page_filter: :all,
        at: [bounds.left, 0],
        align: :center,
        size: 9
      }
    end
  end
end
