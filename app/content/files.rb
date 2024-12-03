# frozen_string_literal: true

require "dry/monads"
require "front_matter_parser"

module Site
  module Content
    class Files
      include Dry::Monads[:result]

      def find(path, as: File)
        path = CONTENT_PATH.join(path)

        begin
          parsed_file = FrontMatterParser::Parser.parse_file(path)
        rescue Errno::ENOENT
          return Failure[:not_found, path]
        end

        file = as.new(
          front_matter: parsed_file.front_matter,
          content: parsed_file.content
        )

        Success(file)
      end
    end
  end
end
