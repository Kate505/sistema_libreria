module ApplicationHelper

  def show_sidebar?
    controller_name == "home" && action_name == "index"
  end

  def show_snack_bar?
    !%w[home sesions].include?(controller_name)
  end

  def snack_bar

    modulos = Current.user.accessible_modulos.to_a

    safe_join(
      modulos.map do |modulo|
        content_tag(:li, class: "dropdown dropdown-hover") do
          concat(
            content_tag(:summary, class: "px-8 text-md text-blue-50 dark:text-blue-50") do
              concat(modulo.nombre)
              concat(content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                                 viewBox: "0 0 20 20", fill: "currentColor",
                                 class: "w-4 h-4 ml-auto transition-transform duration-300 group-open:rotate-90") do

                tag.path(d: "M8.25 4.5l7.5 7.5-7.5 7.5")
              end
              )
            end
          )
          concat(menu_list_from_module(modulo))
        end
      end
    )
  end

  def arbol_navegacion
    items = []

    modulos = Current.user.accessible_modulos.to_a

    items << content_tag(:li) do
      link_to(root_path, data: {
        "helpers--components--arbol-navegacion-target": "module",
        action: "helpers--components--arbol-navegacion#open"
      }) do
        content_tag(:div, class: "avatar") do
          content_tag(:div, image_tag("home.png", class: "rounded-xl", alt: "Logo"), class: "w-8 rounded")
        end + "Home"
      end
    end

    items.concat(
      modulos.map do |modulo|
        content_tag(:li) do
          content_tag(:details, open: false) do
            concat(
              content_tag(:summary, class: "flex items-center gap-2 group") do
                avatar = content_tag(:div, class: "avatar") do
                  content_tag(:div, image_tag(modulo.icono, class: "rounded-xl", alt: "Logo"), class: "w-8 rounded")
                end
                concat(avatar)
                concat(modulo.nombre)
                concat(content_tag(:svg, "", xmlns: "http://www.w3.org/2000/svg",
                                   viewBox: "0 0 20 20", fill: "currentColor",
                                   class: "w-4 h-4 ml-auto transition-transform duration-300 group-open:rotate-90")
                )
              end
            )
            concat(menu_list_from_module(modulo))
          end
        end
      end
    )

    content_tag(:aside, class: "flex flex-col shrink h-full min-h-0 w-1/4 bg-base-200 shadow-sm",
                id: "arbol-navegacion",
                data: { turbo_permanent: true }) do
      concat(
        content_tag(:div, class: "border-t border-base-300 shrink-0 join join-horizontal justify-center") do
          concat(
            content_tag(:div, class: "flex h-16 shrink-0 items-center py-0 px-4") do
              content_tag(:h1, "Librería Pequeños Detalles", class: "text-lg font-bold")
            end
          )
        end
      )
      concat(
        content_tag(:div, class: "flex-1 overflow-y-auto min-h-0 py-4") do
          content_tag(:div, class: "join join-vertical w-full") do
            concat(
              content_tag(:div, class: "flex h-16 shrink-0 items-center px-6") do
                content_tag(:ul,
                            class: "menu menu-md bg-base-200 rounded-box flex-1 space-y-1 p-0",
                            data: { controller: "helpers--components--menu-list" }
                ) do
                  safe_join(items)
                end
              end
            )
          end
        end)
      concat(
        content_tag(:div, class: "pt-3 border-t border-base-300 shrink-0 join join-horizontal justify-center") do
          concat(link_to(root_path, class: "btn join-item flex items-center gap-2 p-3 rounded-lg hover:bg-base-300 transition-colors") do
            content_tag(:div, class: "avatar") do
              content_tag(:div, image_tag("settings.png", class: "rounded-xl", alt: "Settings"), class: "w-8 rounded")
            end
          end)
          concat(link_to(session_path,
                         class: "btn join-item flex items-center gap-2 p-3 rounded-lg hover:bg-base-300 transition-colors",
                         method: :delete,
                         data: { turbo_method: :delete, turbo_confirm: "¿Estás seguro?" }) do
            content_tag(:div, class: "avatar") do
              content_tag(:div, image_tag("logout.png", class: "rounded-xl", alt: "Logout"), class: "w-8 rounded")
            end
          end)
          concat(
            theme_toggle(padding: "pe-2", size: "6")
          )
        end
      )
    end
  end

  def menu_list_from_module(modulo)
    menus = modulo.menus.select { |menu| menu.menu_id.nil? }

    content_tag(:ul, class: "dropdown-content menu menu-lg bg-base-200 w-full rounded-box z-1") do
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

    content_tag(:div, class: "breadcrumbs text-md mx-auto max-w-6xl gap-9 px-10 pt-2 md:gap-20 md:pt-4 backdrop-blur-lg") do
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
