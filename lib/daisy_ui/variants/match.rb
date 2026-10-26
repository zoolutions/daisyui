# frozen_string_literal: true

module DaisyUI
  class Variants
    # What a `compound` or `on` match means, and the checks that make a typo
    # fail where it is declared (at boot) rather than never match:
    #
    # | value            | matches when                                        |
    # |------------------|-----------------------------------------------------|
    # | `:member`        | that member is selected (given, defaulted or set)   |
    # | `[:a, :b]`       | any of them is; a `nil` in the list means "or none" |
    # | `nil` / `false`  | no member of that group is                          |
    # | `true`           | any member of that group is                         |
    # | `true` / `false` | a flag is on / off                                  |
    #
    # @api private
    class Match
      def initialize(klass)
        @klass = klass
      end

      # `selection` is { group => member or nil }, `on` the flags given.
      def self.holds?(match, selection, on)
        match.all? do |key, value|
          if selection.key?(key)
            member = selection[key]
            case value
            when true then !member.nil?
            when false, nil then member.nil?
            when Array then value.include?(member)
            else member == value
            end
          else
            on.include?(key) == value
          end
        end
      end

      def match!(match)
        match.each do |key, value|
          if groups.key?(key)
            value_members(value).each { |member| member!(key, member) }
          elsif flags.include?(key)
            raise ArgumentError, "#{owner}: flag #{key.inspect} matches true or false, got #{value.inspect}" unless BOOLS.include?(value)
          else
            raise ArgumentError, "#{owner} has no variant or flag #{key.inspect}"
          end
        end
      end

      def member!(group, member)
        raise ArgumentError, "#{owner} has no variant #{group.inspect}" unless groups.key?(group)
        return if groups[group].include?(member)

        raise ArgumentError, "#{owner}: #{group.inspect} has no member #{member.inspect}; #{group}: #{groups[group].join(', ')}"
      end

      def state!(name)
        return if @klass.variant_definitions[:states].key?(name)

        raise ArgumentError, "#{owner} has no state #{name.inspect}: declare it with `state #{name.inspect}, \"<variant>\"` first"
      end

      def slot!(name)
        return if name == :root || @klass.variant_definitions[:slots].key?(name)

        raise ArgumentError, "#{owner} has no slot #{name.inspect}: declare it with `slot #{name.inspect}` first"
      end

      private

      BOOLS = [true, false].freeze
      private_constant :BOOLS

      def value_members(value)
        return [] if value.nil? || value == true || value == false

        Array(value).compact
      end

      def groups = @klass.modifier_groups

      # Ungrouped modifiers and registered flags.
      def flags = Schema.flags(@klass)

      def owner = @klass.name || @klass.inspect
    end
  end
end
