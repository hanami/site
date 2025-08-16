# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    class Scope < Hanami::View::Scope
      def render_scope(scope_name, &block)
        # `#scope` inside templates does not do anything with its given block at the moment. For the
        # purposes of this gemo, save the block into a special local name that we then call inside
        # the custom scope class' `#initialize`.
        scope(scope_name, render_scope_blk: block).render
      end
    end
  end
end
