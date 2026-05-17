class FreightCalculationService
  def self.call(orden_de_compra)
    new(orden_de_compra).call
  end

  def initialize(orden_de_compra)
    @orden = orden_de_compra
  end

  def call
    # Recargar la relación para asegurar que tenemos los datos más recientes
    detalles = @orden.detalle_ordenes_de_compra.reload.to_a
    return true if detalles.empty?

    flete_total = @orden.costo_total_flete.to_d

    if flete_total <= 0
      # Restaurar costos al precio unitario original
      detalles.each do |detalle|
        detalle.update_column(:costo_unitario_compra_calculado, detalle.precio_unitario_compra)
      end
      return true
    end

    valor_total = detalles.sum { |d| d.precio_unitario_compra.to_d * d.cantidad.to_i }

    if valor_total <= 0
      # Si por alguna razón el valor total es 0 (ej. productos gratis), 
      # se distribuye equitativamente con redondeo a 2 decimales (restricción de BD).
      flete_equitativo = (flete_total / detalles.size).round(2)
      detalles.each do |detalle|
        flete_unitario = (flete_equitativo / detalle.cantidad.to_i).round(2)
        nuevo_costo = (detalle.precio_unitario_compra.to_d + flete_unitario).round(2)
        detalle.update_column(:costo_unitario_compra_calculado, nuevo_costo)
      end
      return true
    end

    # Prorrateo proporcional con método del Mayor Resto (Largest Remainder) a 2 decimales
    # para asegurar que la suma de fletes asignados sea igual al flete total
    fletes_asignados = detalles.map do |detalle|
      valor_linea = detalle.precio_unitario_compra.to_d * detalle.cantidad.to_i
      # Flete matemático exacto
      flete_exacto = (valor_linea / valor_total) * flete_total
      # Flete redondeado a 2 decimales para la asignación
      flete_redondeado = flete_exacto.round(2)
      
      { 
        detalle: detalle, 
        flete: flete_redondeado, 
        exacto: flete_exacto,
        valor_linea: valor_linea
      }
    end

    suma_fletes_redondeados = fletes_asignados.sum { |f| f[:flete] }
    diferencia = (flete_total - suma_fletes_redondeados).round(2)

    if diferencia != 0
      # Ordenar por la mayor fracción decimal perdida
      fletes_asignados.sort_by! { |f| f[:exacto] - f[:flete] }.reverse!
      # Asignamos la diferencia (los centavos faltantes/sobrantes) al de mayor fracción
      fletes_asignados.first[:flete] = (fletes_asignados.first[:flete] + diferencia).round(2)
    end

    # Persistir en la base de datos limitándonos a 2 decimales
    fletes_asignados.each do |f_info|
      detalle = f_info[:detalle]
      flete_asignado = f_info[:flete]
      
      # El costo unitario se trunca a 2 decimales, aceptando la limitación de la Opción B
      flete_unitario = (flete_asignado / detalle.cantidad.to_i).round(2)
      nuevo_costo = (detalle.precio_unitario_compra.to_d + flete_unitario).round(2)
      
      detalle.update_column(:costo_unitario_compra_calculado, nuevo_costo)
    end

    true
  end
end
