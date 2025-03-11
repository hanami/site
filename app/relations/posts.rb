# frozen_string_literal: true

module Site
  module Relations
    class Posts < Hanami::DB::Relation
      schema :posts do
        attribute :permalink, Types::Nominal::String
        attribute :title, Types::Nominal::String
        attribute :published_at, Types::Nominal::Time.optional
        attribute :author, Types::Nominal::String
        attribute :body, Types::Nominal::String

        indexes do
          index :permalink, name: :unique_permalink, unique: true
        end
      end
    end
  end
end
