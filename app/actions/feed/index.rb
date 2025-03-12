# frozen_string_literal: true

module Site
  module Actions
    module Feed
      class Index < Site::Action
        def handle(request, response)
          response.format = :atom
        end
      end
    end
  end
end
