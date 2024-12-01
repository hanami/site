# frozen_string_literal: true

require "hanami"

module Site
  class App < Hanami::App
    class << self
      def prepare
        super
        load_content
        self
      end

      private

      def load_content
        # Start the db provider, which will auto-migrate the tables (see config/providers/db.rb)
        start :db

        # Load content into the database
        self["content.load_guides"].call
      end
    end
  end
end
