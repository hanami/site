# frozen_string_literal: true

module Site
  module Structs
    class Guide < Site::DB::Struct
      def path
        Content::GUIDES_PATH.join(org, version, slug)
      end
    end
  end
end
