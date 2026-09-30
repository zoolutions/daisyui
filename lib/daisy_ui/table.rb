# frozen_string_literal: true

module DaisyUI
  class Table < Base
    self.component_class = :table

    def view_template(&)
      table(class: classes, **attributes, &)
    end

    def header(...)
      thead(...)
    end

    def row(...)
      render TableRow.new(...)
    end

    def body(...)
      tbody(...)
    end

    def footer(...)
      tfoot(...)
    end

    register_modifiers(
      # "sm:table-zebra"
      # "@sm:table-zebra"
      # "md:table-zebra"
      # "@md:table-zebra"
      # "lg:table-zebra"
      # "@lg:table-zebra"
      zebra: "table-zebra",
      # "sm:table-pin-rows"
      # "@sm:table-pin-rows"
      # "md:table-pin-rows"
      # "@md:table-pin-rows"
      # "lg:table-pin-rows"
      # "@lg:table-pin-rows"
      pin_rows: "table-pin-rows",
      # "sm:table-pin-cols"
      # "@sm:table-pin-cols"
      # "md:table-pin-cols"
      # "@md:table-pin-cols"
      # "lg:table-pin-cols"
      # "@lg:table-pin-cols"
      pin_cols: "table-pin-cols",
      size: {
        # "sm:table-xs"
        # "@sm:table-xs"
        # "md:table-xs"
        # "@md:table-xs"
        # "lg:table-xs"
        # "@lg:table-xs"
        xs: "table-xs",
        # "sm:table-sm"
        # "@sm:table-sm"
        # "md:table-sm"
        # "@md:table-sm"
        # "lg:table-sm"
        # "@lg:table-sm"
        sm: "table-sm",
        # "sm:table-md"
        # "@sm:table-md"
        # "md:table-md"
        # "@md:table-md"
        # "lg:table-md"
        # "@lg:table-md"
        md: "table-md",
        # "sm:table-lg"
        # "@sm:table-lg"
        # "md:table-lg"
        # "@md:table-lg"
        # "lg:table-lg"
        # "@lg:table-lg"
        # "xl:table-lg"
        # "@xl:table-lg"
        lg: "table-lg",
        # "sm:table-xl"
        # "@sm:table-xl"
        # "md:table-xl"
        # "@md:table-xl"
        # "lg:table-xl"
        # "@lg:table-xl"
        # "xl:table-xl"
        # "@xl:table-xl"
        xl: "table-xl"
      }
    )
  end
end
