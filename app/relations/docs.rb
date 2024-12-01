module Site
  module Relations
    class Docs < Hanami::DB::Relation
      schema :docs do
        attribute :org, Types::Nominal::String
        attribute :slug, Types::Nominal::String
        attribute :version, Types::Nominal::String
      end
    end
  end
end
