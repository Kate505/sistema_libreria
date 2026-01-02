module Components::PasivoHelper
  def status_badge(pasivo:)
    style_class = pasivo ? "badge-neutral badge-outline" : "badge-success badge-outline"
    label       = pasivo ? "Pasivo" : "Activo"

    content_tag(:span, label, class: "badge #{style_class}")
  end
end
