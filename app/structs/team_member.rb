# frozen_string_literal: true

module Site
  module Structs
    class TeamMember < Site::DB::Struct
      def active?
        !active_since.nil?
      end

      def status
        active? ? "Active since #{active_since}" : "Former member"
      end
    end
  end
end