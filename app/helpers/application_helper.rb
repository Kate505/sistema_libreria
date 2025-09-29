module ApplicationHelper

  def show?
    !(controller_name == "home" && action_name == "index")
  end

  def arbol_navegacion
    items = []

    items << content_tag(:li) do
      link_to(root_path, data: {
        "helpers--components--arbol-navegacion-target": "module",
        action: "helpers--components--arbol-navegacion#open"
      }) do
        content_tag(:svg, "",
                    xmlns: "http://www.w3.org/2000/svg",
                    fill: "none",
                    viewBox: "0 0 24 24",
                    stroke_width: "1.5",
                    stroke: "currentColor",
                    class: "h-4 w-4") + "Home"
      end
    end

    items.concat(
      Current.user.accessible_modulos.map do |modulo|
        content_tag(:li) do
          content_tag(:details, open: false) do
            concat(
              content_tag(:summary) do
                avatar = content_tag(:div, class: "avatar") do
                  content_tag(:div, image_tag(modulo.icono, class: "rounded-xl", alt: "Logo"), class: "w-8 rounded")
                end
                avatar + modulo.nombre
              end
            )
            concat(menu_list(modulo.id))
          end
        end
      end
    )

    content_tag(:ul,
                class: "menu menu-md bg-base-200 rounded-box max-w-xs w-full",
                data: { controller: "helpers--components--arbol-navegacion" }
    ) do
      safe_join(items)
    end
  end


  def menu_list(modulo_id)
    menus = Current.user.accessible_menus_by_user_and_module(modulo_id) || []
    content_tag(:ul, class: "menu menu-lg w-full") do
      menus.select { |menu| menu.menu_id.nil? }.map do |menu|
        render_menu_item(menu)
      end.join.html_safe
    end
  end

  def render_menu_item(menu)
    return render_menu_padre(menu) if menu.children.any?
    content_tag(:li) do
      link = link_to(menu.link_to || "#", data: { turbo_frame: "main_content",
                                                  "helpers--components--arbol-navegacion-target": "module",
                                                  action: "helpers--components--arbol-navegacion#open" }) do
        content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                    fill: "none",
                    viewBox: "0 0 24 24",
                    stroke_width: "1.5",
                    stroke: "currentColor",
                    class: "h-4 w-4") +
          menu.nombre
      end
      link
    end
  end

  def render_menu_padre(menu)
    content_tag(:li) do
      content_tag(:details, open: false) do
        concat(
          content_tag(:summary) do
            avatar = content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                                 fill: "none",
                                 viewBox: "0 0 24 24",
                                 stroke_width: "1.5",
                                 stroke: "currentColor",
                                 class: "h-4 w-4") do
              tag.path(d: "M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75m-8.69-6.44l-2.12-2.12a1.5 1.5 0 00-1.061-.44H4.5A2.25 2.25 0 002.25 6v12a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18V9a2.25 2.25 0 00-2.25-2.25h-5.379a1.5 1.5 0 01-1.06-.44z")
            end
            avatar + menu.nombre
          end
        )
        concat(
          content_tag(:ul) do
            menu.children.map { |child| render_menu_item(child) }.join.html_safe
          end
        )
      end
    end
  end

  def breadcrumbs
    parts = controller_path.split("/")

    content_tag(:div, class: "breadcrumbs text-md mx-auto max-w-6xl gap-9 px-10 pt-2 md:gap-20 md:pt-4 bg-base-100/70 backdrop-blur-lg") do
      content_tag(:ul) do
        concat(content_tag(:li, "Home"))
        parts.each_with_index do |part, i|
          name = part.titleize
          path = "/" + parts[0..i].join("/")
          concat(content_tag(:li, name))
        end

        content_tag(:li)
      end
    end
  end
end
