# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

module DaisyUI
  module ClassMerge
    module Validators
      class << self
        def arbitrary_value?(class_part, test_label, test_value)
          match = ARBITRARY_VALUE_REGEX.match(class_part)
          return false unless match

          return test_label.call(match[1]) unless match[1].nil?

          test_value.call(match[2])
        end

        def arbitrary_variable?(class_part, test_label, should_match_no_label: false)
          match = ARBITRARY_VARIABLE_REGEX.match(class_part)
          return false unless match

          return test_label.call(match[1]) unless match[1].nil?

          should_match_no_label
        end

        def numeric?(value)
          Float(value, exception: false).is_a?(Numeric)
        end

        def integer?(value)
          Integer(value, exception: false).is_a?(Integer)
        end
      end

      ARBITRARY_VALUE_REGEX = /^\[(?:(\w[\w-]*):)?(.+)\]$/i
      ARBITRARY_VARIABLE_REGEX = /^\((?:(\w[\w-]*):)?(.+)\)$/i
      FRACTION_REGEX = %r{^\d+(?:\.\d+)?/\d+(?:\.\d+)?$}
      TSHIRT_UNIT_REGEX = /^(\d+(\.\d+)?)?(xs|sm|md|lg|xl)$/
      LENGTH_UNIT_REGEX = /\d+(%|px|r?em|[sdl]?v([hwib]|min|max)|pt|pc|in|cm|mm|cap|ch|ex|r?lh|cq(w|h|i|b|min|max))|\b(calc|min|max|clamp)\(.+\)|^0$/
      COLOR_FUNCTION_REGEX = /^(rgba?|hsla?|hwb|(ok)?(lab|lch)|color-mix|color|light-dark)\(.+\)$/

      # Shadow always begins with x and y offset separated by underscore optionally prepended by inset
      SHADOW_REGEX = /^(inset_)?-?((\d+)?\.?(\d+)[a-z]+|0)_-?((\d+)?\.?(\d+)[a-z]+|0)/
      IMAGE_REGEX = /^(url|image|image-set|cross-fade|element|(repeating-)?(linear|radial|conic)-gradient)\(.+\)$/

      IS_FRACTION = lambda { |value|
        FRACTION_REGEX.match?(value)
      }

      IS_NUMBER = lambda { |value|
        numeric?(value)
      }

      IS_INTEGER = lambda { |value|
        integer?(value)
      }

      IS_PERCENT = lambda { |value|
        value.end_with?("%") && IS_NUMBER.call(value[0..-2])
      }

      IS_TSHIRT_SIZE = lambda { |value|
        TSHIRT_UNIT_REGEX.match?(value)
      }

      IS_ANY = ->(_ = nil) { true }

      IS_LENGTH_ONLY = lambda { |value|
        # `colorFunctionRegex` check is necessary because color functions can have percentages in them which which would be incorrectly classified as lengths.
        # For example, `hsl(0 0% 0%)` would be classified as a length without this check.
        # I could also use lookbehind assertion in `lengthUnitRegex` but that isn't supported widely enough.
        LENGTH_UNIT_REGEX.match?(value) && !COLOR_FUNCTION_REGEX.match?(value)
      }

      IS_NEVER = ->(_) { false }

      IS_SHADOW = lambda { |value|
        SHADOW_REGEX.match?(value)
      }

      IS_IMAGE = lambda { |value|
        IMAGE_REGEX.match?(value)
      }

      IS_ANY_NON_ARBITRARY = lambda { |value|
        !IS_ARBITRARY_VALUE.call(value) && !IS_ARBITRARY_VARIABLE.call(value)
      }

      NAMED_CONTAINER_QUERY_REGEX = %r{\A@container(?:-size|-normal)?/.+\z}

      IS_NAMED_CONTAINER_QUERY = lambda { |value|
        NAMED_CONTAINER_QUERY_REGEX.match?(value)
      }

      IS_ARBITRARY_SIZE = lambda { |value|
        arbitrary_value?(value, IS_LABEL_SIZE, IS_NEVER)
      }

      IS_ARBITRARY_VALUE = lambda { |value|
        ARBITRARY_VALUE_REGEX.match?(value)
      }

      IS_ARBITRARY_LENGTH = lambda { |value|
        arbitrary_value?(value, IS_LABEL_LENGTH, IS_LENGTH_ONLY)
      }

      IS_ARBITRARY_NUMBER = lambda { |value|
        arbitrary_value?(value, IS_LABEL_NUMBER, IS_NUMBER)
      }

      IS_ARBITRARY_WEIGHT = lambda { |value|
        arbitrary_value?(value, IS_LABEL_WEIGHT, IS_ANY)
      }

      IS_ARBITRARY_FAMILY_NAME = lambda { |value|
        arbitrary_value?(value, IS_LABEL_FAMILY_NAME, IS_NEVER)
      }

      IS_ARBITRARY_POSITION = lambda { |value|
        arbitrary_value?(value, IS_LABEL_POSITION, IS_NEVER)
      }

      IS_ARBITRARY_IMAGE = lambda { |value|
        arbitrary_value?(value, IS_LABEL_IMAGE, IS_IMAGE)
      }

      IS_ARBITRARY_SHADOW = lambda { |value|
        arbitrary_value?(value, IS_LABEL_SHADOW, IS_SHADOW)
      }

      IS_ARBITRARY_VARIABLE = lambda { |value|
        ARBITRARY_VARIABLE_REGEX.match?(value)
      }

      IS_ARBITRARY_VARIABLE_LENGTH = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_LENGTH)
      }

      IS_ARBITRARY_VARIABLE_FAMILY_NAME = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_FAMILY_NAME)
      }

      IS_ARBITRARY_VARIABLE_POSITION = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_POSITION)
      }

      IS_ARBITRARY_VARIABLE_SIZE = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_SIZE)
      }

      IS_ARBITRARY_VARIABLE_IMAGE = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_IMAGE)
      }

      IS_ARBITRARY_VARIABLE_SHADOW = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_SHADOW, should_match_no_label: true)
      }

      IS_ARBITRARY_VARIABLE_WEIGHT = lambda { |value|
        arbitrary_variable?(value, IS_LABEL_WEIGHT, should_match_no_label: true)
      }

      ############
      # Labels
      ############

      IS_LABEL_POSITION = lambda { |label|
        %w[position percentage].include?(label)
      }

      IS_LABEL_IMAGE = lambda { |label|
        %w[image url].include?(label)
      }

      IS_LABEL_SIZE = lambda { |label|
        %w[length size bg-size].include?(label)
      }

      IS_LABEL_LENGTH = lambda { |label|
        label == "length"
      }

      IS_LABEL_NUMBER = lambda { |label|
        label == "number"
      }

      IS_LABEL_FAMILY_NAME = lambda { |label|
        label == "family-name"
      }

      IS_LABEL_WEIGHT = lambda { |label|
        %w[number weight].include?(label)
      }

      IS_LABEL_SHADOW = lambda { |label|
        label == "shadow"
      }
    end
  end
end
