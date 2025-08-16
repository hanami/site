# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    module Scopes
      class Card < Hanami::View::Scope
        def initialize(**)
          super
          @slots = {}

          # Evaluate the block given to `#render_scope` so that we can fill our slots.
          _locals[:render_scope_blk]&.call(self)
        end

        def render(partial = "partials/card", **opts)
          super
        end

        def slot(name, content = nil)
          @slots[name] = (content || yield).html_safe
        end

        def render_slot(name)
          @slots[name]
        end
      end
    end
  end
end
