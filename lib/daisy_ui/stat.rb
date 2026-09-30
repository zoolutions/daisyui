# frozen_string_literal: true

module DaisyUI
  # @component html class="stats"
  class Stat < Base
    self.component_class = "stats"

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def item(**options, &)
      div(class: component_classes("stat", options:), **options, &)
    end

    def title(**options, &)
      div(class: component_classes("stat-title", options:), **options, &)
    end

    def value(**options, &)
      div(class: component_classes("stat-value", options:), **options, &)
    end

    def desc(**options, &)
      div(class: component_classes("stat-desc", options:), **options, &)
    end

    def figure(**options, &)
      div(class: component_classes("stat-figure", options:), **options, &)
    end

    def actions(**options, &)
      div(class: component_classes("stat-actions", options:), **options, &)
    end

    register_modifiers(
      direction: {
        # "sm:stats-horizontal"
        # "@sm:stats-horizontal"
        # "md:stats-horizontal"
        # "@md:stats-horizontal"
        # "lg:stats-horizontal"
        # "@lg:stats-horizontal"
        horizontal: "stats-horizontal",
        # "sm:stats-vertical"
        # "@sm:stats-vertical"
        # "md:stats-vertical"
        # "@md:stats-vertical"
        # "lg:stats-vertical"
        # "@lg:stats-vertical"
        vertical: "stats-vertical"
      }
    )
  end
end
