# frozen_string_literal: true

module DaisyUI
  class Avatar < Base
    self.component_class = :avatar

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      presence: {
        # "sm:avatar-online"
        # "@sm:avatar-online"
        # "md:avatar-online"
        # "@md:avatar-online"
        # "lg:avatar-online"
        # "@lg:avatar-online"
        online: "avatar-online",
        # "sm:avatar-offline"
        # "@sm:avatar-offline"
        # "md:avatar-offline"
        # "@md:avatar-offline"
        # "lg:avatar-offline"
        # "@lg:avatar-offline"
        offline: "avatar-offline"
      },
      # "sm:avatar-placeholder"
      # "@sm:avatar-placeholder"
      # "md:avatar-placeholder"
      # "@md:avatar-placeholder"
      # "lg:avatar-placeholder"
      # "@lg:avatar-placeholder"
      placeholder: "avatar-placeholder"
    )
  end
end
