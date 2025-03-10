# frozen_string_literal: true

module Site
  module Relations
    class Docs < Hanami::DB::Relation
      schema :docs do
        attribute :org, Types::Nominal::String
        attribute :slug, Types::Nominal::String
        attribute :version, Types::Nominal::String
        attribute :hidden, Types::Nominal::Bool
      end

      def visible
        where(hidden: false)
      end
    end
  end
end
