# frozen_string_literal: true

module DaisyUI
  # @component html class="carousel"
  class Carousel < Base
    self.component_class = :carousel

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def item(**options, &)
      div(class: component_classes("carousel-item", options:), **options, &)
    end

    register_modifiers(
      snap: {
        # "sm:carousel-start"
        # "@sm:carousel-start"
        # "md:carousel-start"
        # "@md:carousel-start"
        # "lg:carousel-start"
        # "@lg:carousel-start"
        start: "carousel-start",
        # "sm:carousel-center"
        # "@sm:carousel-center"
        # "md:carousel-center"
        # "@md:carousel-center"
        # "lg:carousel-center"
        # "@lg:carousel-center"
        center: "carousel-center",
        # "sm:carousel-end"
        # "@sm:carousel-end"
        # "md:carousel-end"
        # "@md:carousel-end"
        # "lg:carousel-end"
        # "@lg:carousel-end"
        end: "carousel-end"
      },
      direction: {
        # "sm:carousel-vertical"
        # "@sm:carousel-vertical"
        # "md:carousel-vertical"
        # "@md:carousel-vertical"
        # "lg:carousel-vertical"
        # "@lg:carousel-vertical"
        vertical: "carousel-vertical",
        # "sm:carousel-horizontal" "@sm:carousel-horizontal"
        # "md:carousel-horizontal" "@md:carousel-horizontal"
        # "lg:carousel-horizontal" "@lg:carousel-horizontal"
        horizontal: "carousel-horizontal"
      }
    )
  end
end
