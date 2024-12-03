# auto_register: false
# frozen_string_literal: true

module Site
  module Content
    class File < Site::Struct
      attribute :front_matter, Types::Strict::Hash.constructor(-> hsh { hsh.transform_keys(&:to_sym) })
      attribute :content, Types::Strict::String
    end
  end
end
