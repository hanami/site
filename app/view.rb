# auto_register: false
# frozen_string_literal: true

require "hanami/view"

# For .xml.builder templates
require "builder"

module Site
  class View < Hanami::View
    include Deps["settings"]

    # Used in the app layout
    expose :settings, decorate: false
  end
end
