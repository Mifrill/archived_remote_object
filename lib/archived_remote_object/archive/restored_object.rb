require "ostruct"
require "archived_remote_object/archive/archived_object"

module ArchivedRemoteObject
  module Archive
    class RestoredObject
      def initialize(
        key:,
        archived_object: Archive::ArchivedObject.new(key: key)
      )
        self.archived_object = archived_object
      end

      def call
        assign_attributes

        if attributes.status == :archived
          archived_object.restore
          attributes.status = :restoration_initiated
        end

        attributes
      end

      private

      def attributes
        @attributes ||= OpenStruct.new
      end

      def assign_attributes # rubocop:disable Metrics/AbcSize
        if archived_object.available?
          attributes.status = :available
        elsif archived_object.restore_in_progress?
          attributes.status = :in_progress
          attributes.debug_state = archived_object.debug_state
        else
          attributes.status = :archived
          attributes.debug_state = archived_object.debug_state
        end
      end

      attr_accessor :archived_object
    end
  end
end
