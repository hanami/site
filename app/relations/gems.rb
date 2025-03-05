# frozen_string_literal: true

module Site
  module Relations
    class Gems < Hanami::DB::Relation
      schema :gems do
        attribute :org, Types::Nominal::String
        attribute :slug, Types::Nominal::String
        attribute :hidden, Types::Nominal::Bool
      end
    end
  end
end
