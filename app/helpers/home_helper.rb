module HomeHelper
  def launcher_menu_list(modulo_id)
    menus = Current.user.accessible_menus_by_user_and_module(modulo_id) || []

    content_tag(:div, class: "flex items-start flex-wrap w-full") do
      menus.select { |menu| menu.menu_id.nil? }.map do |menu|
        content_tag(:div, class: "p-4 basis-full md:basis-1/2 lg:basis-1/2") do
          render_launcher_menu_item(menu)
        end
      end.join.html_safe
    end
  end

  private

  def render_launcher_menu_item(menu)
    return render_launcher_menu_with_children_item(menu) if menu.children.any?
    content_tag(:div, class: "flex card card border border-base-300 bg-base-100 shadow-md hover:shadow-xl transition p-4") do
      content_tag(:div, class: "flex items-center justify-between") do
        safe_join([
                    content_tag(:h3, class: "font-semibold flex items-center gap-2") do
                      safe_join([
                                  content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                                              fill: "none",
                                              viewBox: "0 0 24 24",
                                              stroke_width: "1.5",
                                              stroke: "currentColor",
                                              class: "h-5 w-5") do
                                    tag.path(d: "M4 6h16M4 12h16M4 18h16")
                                  end,
                                  menu.nombre
                                ])
                    end,
                    link_to("Abrir", menu.link_to || "#", class: "btn btn-sm btn-primary")
                  ])
      end
    end
  end

  def render_launcher_menu_with_children_item(menu)
    content_tag(:div, class: "flex card border border-base-300 bg-base-100 shadow-md hover:shadow-xl transition") do
      content_tag(:div, class: "collapse collapse-arrow") do
        concat(
          content_tag(:input, nil, type: "checkbox") # controla apertura
        )
        concat(
          content_tag(:div, class: "collapse-title font-semibold flex items-center gap-2") do
            safe_join([
                        content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                                    fill: "none",
                                    viewBox: "0 0 24 24",
                                    stroke_width: "1.5",
                                    stroke: "currentColor",
                                    class: "h-5 w-5") do
                          tag.path(d: "M4 6h16M4 12h16M4 18h16")
                        end,
                        menu.nombre
                      ])
          end
        )
        concat(
          content_tag(:div, class: "collapse-content") do
            content_tag(:ul, class: "menu menu-md w-full") do
              menu.children.map { |child| render_menu_item(child) }.join.html_safe
            end
          end
        )
      end
    end
  end

end
