# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    class Scope < Hanami::View::Scope
      def initialize(**)
        super
        @slots = {}

        # Evaluate the block given to `#render_scope` so that we can fill our slots.
        _locals[:render_scope_block]&.call(self)
      end

      def render_with_slots(partial_name, &block)
        # `#scope` inside templates does not do anything with its given block at the moment. Save
        # the block into a special local name that we then call inside the custom scope class'
        # `#initialize`.
        scope(render_scope_block: block).render(partial_name)
      end

      def slot(name, content = nil)
        @slots[name] = (content || yield).html_safe
      end

      def slot?(name)
        @slots.key?(name)
      end

      def render_slot(name)
        @slots[name]
      end
    end
  end
end
