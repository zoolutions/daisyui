# frozen_string_literal: true

module DaisyUI
  class Aura < Base
    self.component_class = :aura

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      # "sm:aura-dual"
      # "@sm:aura-dual"
      # "md:aura-dual"
      # "@md:aura-dual"
      # "lg:aura-dual"
      # "@lg:aura-dual"
      dual: "aura-dual",
      # "sm:aura-rainbow"
      # "@sm:aura-rainbow"
      # "md:aura-rainbow"
      # "@md:aura-rainbow"
      # "lg:aura-rainbow"
      # "@lg:aura-rainbow"
      rainbow: "aura-rainbow",
      # "sm:aura-holo"
      # "@sm:aura-holo"
      # "md:aura-holo"
      # "@md:aura-holo"
      # "lg:aura-holo"
      # "@lg:aura-holo"
      holo: "aura-holo",
      # "sm:aura-gold"
      # "@sm:aura-gold"
      # "md:aura-gold"
      # "@md:aura-gold"
      # "lg:aura-gold"
      # "@lg:aura-gold"
      gold: "aura-gold",
      # "sm:aura-silver"
      # "@sm:aura-silver"
      # "md:aura-silver"
      # "@md:aura-silver"
      # "lg:aura-silver"
      # "@lg:aura-silver"
      silver: "aura-silver",
      # "sm:aura-glow"
      # "@sm:aura-glow"
      # "md:aura-glow"
      # "@md:aura-glow"
      # "lg:aura-glow"
      # "@lg:aura-glow"
      glow: "aura-glow",
      size: {
        # "sm:aura-xs"
        # "@sm:aura-xs"
        # "md:aura-xs"
        # "@md:aura-xs"
        # "lg:aura-xs"
        # "@lg:aura-xs"
        xs: "aura-xs",
        # "sm:aura-sm"
        # "@sm:aura-sm"
        # "md:aura-sm"
        # "@md:aura-sm"
        # "lg:aura-sm"
        # "@lg:aura-sm"
        sm: "aura-sm",
        # "sm:aura-md"
        # "@sm:aura-md"
        # "md:aura-md"
        # "@md:aura-md"
        # "lg:aura-md"
        # "@lg:aura-md"
        md: "aura-md",
        # "sm:aura-lg"
        # "@sm:aura-lg"
        # "md:aura-lg"
        # "@md:aura-lg"
        # "lg:aura-lg"
        # "@lg:aura-lg"
        lg: "aura-lg",
        # "sm:aura-xl"
        # "@sm:aura-xl"
        # "md:aura-xl"
        # "@md:aura-xl"
        # "lg:aura-xl"
        # "@lg:aura-xl"
        xl: "aura-xl"
      }
    )
  end
end
