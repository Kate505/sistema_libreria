module ApplicationHelper

  def show_snack_bar?
    !%w[home sesions].include?(controller_name)
  end

  def menu_list_from_module(modulo)
    menus = Current.user.accessible_menus_by_user_and_module(modulo.id)

    content_tag(:ul, class: "p-0 m-0") do
      menus.map { |menu| render_menu_item(menu) }.join.html_safe
    end
  end

  def render_menu_item(menu)
    if menu.children.loaded? && menu.children.any?
      render_menu_padre(menu)
    else
      content_tag(:li) do
        link_to(menu.link_to || "#", data: { turbo_frame: "main_content",
                                             "helpers--components--arbol-navegacion-target": "module",
                                             action: "helpers--components--arbol-navegacion#open" }) do
          content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                      fill: "none", viewBox: "0 0 24 24",
                      stroke_width: "1.5", stroke: "currentColor",
                      class: "h-4 w-4") + menu.nombre
        end
      end
    end
  end

  def render_menu_padre(menu)
    content_tag(:li) do
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

  def breadcrumbs
    return if %w[home sessions].include?(controller_name)

    parts = controller_path.split("/")

    content_tag(:div, class: "breadcrumbs text-md mx-auto gap-9 px-10 pt-2 md:gap-20 md:pt-4 backdrop-blur-lg") do
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

  def inline_svg(name, class_name: nil)
    path = Rails.root.join("app/assets/images", name)
    svg = File.read(path)
    svg.sub!("<svg", "<svg class='#{class_name}'") if class_name.present?
    svg.html_safe
  end

  def menu_for_drawer
    modulos = Current.user.accessible_modulos.to_a
    items = []

    # --------------------
    # HOME
    # --------------------

    items << content_tag(:li, class: "py-4") do

      # -------- versión compacta --------
      concat(
        link_to(
          root_path,
          class: "is-drawer-close:tooltip is-drawer-close:tooltip-right
                is-drawer-close:flex is-drawer-open:hidden
                items-center justify-center w-full",
          data: { tip: "Home",
                  turbo_frame: "main_content" }
        ) do
          inline_svg("home.svg", class_name: "w-6 h-6 inline-block")
        end
      )

      # -------- versión expandida --------
      concat(
        link_to(
          root_path,
          data: { turbo_frame: "main_content" },
          class: "is-drawer-open:flex is-drawer-close:hidden
                items-center gap-2 w-full"
        ) do
          concat(
            inline_svg("home.svg", class_name: "w-6 h-6 inline-block")
          )

          concat content_tag(:span, "Home")
        end
      )
    end

    items.concat(
      modulos.map do |modulo|
        unique_details_id = "details-modulo-#{modulo.id}"
        content_tag(:li, class: "py-4") do

          # --------------------
          # VERSION COMPACTA
          # --------------------
          concat(
            content_tag(:button,
                        class: "is-drawer-close:tooltip is-drawer-close:tooltip-right
                    is-drawer-close:flex is-drawer-open:hidden
                    items-center justify-center w-full",
                        data: { tip: modulo.nombre,
                                action: "click->sidebar#expandAndOpen",
                                target_id: unique_details_id }
            ) do
              inline_svg(modulo.icono, class_name: "w-6 h-6 inline-block")
            end
          )

          # --------------------
          # VERSION EXPANDIBLE
          # --------------------
          concat(
            content_tag(:details,
                        id: unique_details_id,
                        class: "is-drawer-open:block is-drawer-close:hidden",
                        open: false
            ) do

              concat(
                content_tag(:summary,
                            class: "flex items-center gap-2 group cursor-pointer"
                ) do

                  concat(
                    inline_svg(modulo.icono, class_name: "w-6 h-6 inline-block")
                  )

                  concat content_tag(:span, modulo.nombre)

                  concat(
                    content_tag(:svg, "",
                                xmlns: "http://www.w3.org/2000/svg",
                                viewBox: "0 0 20 20",
                                fill: "currentColor",
                                class: "w-4 h-4 ml-auto transition-transform duration-300 group-open:rotate-90"
                    )
                  )
                end
              )

              # submenu
              concat(menu_list_from_module(modulo))
            end
          )
        end
      end
    )

    safe_join(items)
  end

end
