require 'prawn'
require 'prawn/table'

module Pdf
  class EstadisticasPeriodo < Prawn::Document
    def initialize(data)
      super(page_size: 'LETTER', margin: [40, 40, 40, 40])
      @data = data
      generar_documento
    end

    def generar_documento
      encabezado
      move_down 20
      kpis
      move_down 20
      grafico_top_productos
      pie_de_pagina
    end

    private

    def encabezado
      text "Librería Pequeños Detalles", size: 20, style: :bold, align: :center
      text "Reporte de Estadísticas por Período", size: 16, style: :bold, align: :center
      text "Período: #{@data[:fecha_desde].strftime('%d/%m/%Y')} - #{@data[:fecha_hasta].strftime('%d/%m/%Y')}", align: :center
      move_down 10
      stroke_horizontal_rule
    end

    def kpis
      move_down 10
      text "Resumen Financiero", size: 14, style: :bold
      move_down 10

      tabla_datos = [
        ["Concepto", "Monto"],
        ["Ingresos Brutos", "C$ #{format_money(@data[:ingresos_brutos])}"],
        ["Costo de Ventas (COGS)", "C$ #{format_money(@data[:cogs])}"],
        ["Utilidad Bruta", "C$ #{format_money(@data[:utilidad_bruta])}"],
        ["Margen Bruto", "#{@data[:margen_bruto_pct]}%"],
        ["Gastos Operativos", "C$ #{format_money(@data[:gastos_operativos_total])}"],
        ["Utilidad Neta", "C$ #{format_money(@data[:utilidad_neta])}"],
        ["Margen Neto", "#{@data[:margen_neto_pct]}%"]
      ]

      table(tabla_datos, width: bounds.width / 2) do
        row(0).font_style = :bold
        row(0).background_color = "f0f0f0"
        cells.padding = 6
        cells.size = 10
        columns(1).align = :right
      end

      move_down 20
      text "Resumen de Operaciones", size: 14, style: :bold
      move_down 10

      tabla_ops = [
        ["Total de Ventas Realizadas", @data[:total_ventas_count].to_s],
        ["Total de Artículos Vendidos", @data[:total_articulos_vendidos].to_s]
      ]

      table(tabla_ops, width: bounds.width / 2) do
        cells.padding = 6
        cells.size = 10
        columns(1).align = :right
      end
    end

    def grafico_top_productos
      return if @data[:top_ingresos_labels].empty?

      move_down 20
      text "Top 10 Productos por Ingreso", size: 14, style: :bold
      move_down 10

      tabla_prod = [["Producto", "Ingresos Generados"]]
      
      @data[:top_ingresos_labels].each_with_index do |label, i|
        tabla_prod << [label, "C$ #{format_money(@data[:top_ingresos_data][i])}"]
      end

      table(tabla_prod, width: bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "f0f0f0"
        cells.padding = 6
        cells.size = 10
        columns(1).align = :right
      end
    end

    def pie_de_pagina
      number_pages "Página <page> de <total>", {
        start_count_at: 1,
        page_filter: :all,
        at: [bounds.left, 0],
        align: :center,
        size: 9
      }
    end

    def format_money(amount)
      ActionController::Base.helpers.number_with_precision(amount, precision: 2, delimiter: ',')
    end
  end
end
