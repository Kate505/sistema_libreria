module FormActionsHelper
  # Botón de guardar estándar para formularios.
  def save_button(form_builder, style_class: "btn btn-primary")
    form_builder.button(class: style_class) do
      safe_join([
        tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "size-4 mr-1") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "m4.5 12.75 6 6 9-13.5")
        end,
        "Guardar"
      ])
    end
  end

  def cancel_button(cancel_path, frame_id:, style_class: "btn btn-soft btn-error")
    link_to(
      "Cancelar",
      cancel_path,
      class: style_class,
      data: {
        turbo_frame: frame_id,
        turbo_action: "advance"
      }
    )
  end

  def form_action_buttons(form_builder, cancel_path:, frame_id:, save_class: nil, cancel_class: "btn btn-soft btn-error")
    safe_join(
      [
        save_button(form_builder, style_class: save_class),
        cancel_button(cancel_path, frame_id: frame_id, style_class: cancel_class)
      ],
      "\n"
    )
  end
end

