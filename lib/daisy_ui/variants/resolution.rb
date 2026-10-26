# frozen_string_literal: true

module DaisyUI
  class Variants
    # Which members, compounds and `on` rules hold for one instance, worked
    # out explicitly rather than left to ClassMerge, so a default or a set
    # member never renders beside the member the caller gave, with class
    # merging on or off:
    #
    # 1. the caller's members (the last one per group, as ClassMerge keeps)
    # 2. defaults, for groups the caller left empty
    # 3. compounds in declaration order; each one's `set` fills or replaces a
    #    member the caller did not name, and later compounds see it
    # 4. `on` rules, against the final selection
    #
    # @api private
    class Resolution
      attr_reader :compounds, :rules

      def initialize(klass, given)
        definitions = klass.variant_definitions
        @given = given
        @selection = klass.modifier_groups.to_h { |group, members| [group, given.reverse.find { |m| members.include?(m) }] }
        @named = @selection.compact.keys
        definitions[:defaults].each { |group, member| @selection[group] ||= member }
        @compounds = matching_compounds(definitions[:compounds])
        @rules = definitions[:rules].select { |rule| holds?(rule[:match]) }
      end

      # Members a default or a compound selected, not the caller.
      def implied_members
        @selection.filter_map { |group, member| member unless @named.include?(group) }
      end

      # Every member and flag in effect, for the slots' per-member classes.
      def active = (@given | implied_members)

      private

      # One at a time: a compound's `set` is seen by the compounds after it.
      def matching_compounds(compounds)
        compounds.each_with_object([]) do |compound, matched|
          next unless holds?(compound[:match])

          matched << compound
          compound[:set].each { |group, member| @selection[group] = member unless @named.include?(group) }
        end
      end

      def holds?(match) = Match.holds?(match, @selection, @given)
    end
  end
end
