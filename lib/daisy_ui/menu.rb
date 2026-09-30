# frozen_string_literal: true

module DaisyUI
  class Menu < Base
    self.component_class = :menu

    def view_template(&)
      ul(class: classes, **attributes, &)
    end

    def title(*, as: :li, **options, &)
      public_send(as, class: component_classes("menu-title", options:), **options, &)
    end

    def item(...)
      render MenuItem.new(...)
    end

    def submenu(*modifiers, **, &)
      if modifiers.include?(:collapsible)
        li do
          render CollapsibleSubMenu.new(*modifiers, **, &)
        end
      else
        li do
          render SubMenu.new(*modifiers, **, &)
        end
      end
    end

    register_modifiers(
      size: {
        # "sm:menu-xs"
        # "@sm:menu-xs"
        # "md:menu-xs"
        # "@md:menu-xs"
        # "lg:menu-xs"
        # "@lg:menu-xs"
        xs: "menu-xs",
        # "sm:menu-sm"
        # "@sm:menu-sm"
        # "md:menu-sm"
        # "@md:menu-sm"
        # "lg:menu-sm"
        # "@lg:menu-sm"
        sm: "menu-sm",
        # "sm:menu-md"
        # "@sm:menu-md"
        # "md:menu-md"
        # "@md:menu-md"
        # "lg:menu-md"
        # "@lg:menu-md"
        md: "menu-md",
        # "sm:menu-lg"
        # "@sm:menu-lg"
        # "md:menu-lg"
        # "@md:menu-lg"
        # "lg:menu-lg"
        # "@lg:menu-lg"
        # "xl:menu-lg"
        # "@xl:menu-lg"
        lg: "menu-lg",
        # "sm:menu-xl"
        # "@sm:menu-xl"
        # "md:menu-xl"
        # "@md:menu-xl"
        # "lg:menu-xl"
        # "@lg:menu-xl"
        # "xl:menu-xl"
        # "@xl:menu-xl"
        xl: "menu-xl"
      },
      direction: {
        # "sm:menu-vertical"
        # "@sm:menu-vertical"
        # "md:menu-vertical"
        # "@md:menu-vertical"
        # "lg:menu-vertical"
        # "@lg:menu-vertical"
        vertical: "menu-vertical",
        # "sm:menu-horizontal"
        # "@sm:menu-horizontal"
        # "md:menu-horizontal"
        # "@md:menu-horizontal"
        # "lg:menu-horizontal"
        # "@lg:menu-horizontal"
        horizontal: "menu-horizontal"
      }
    )
  end
end
