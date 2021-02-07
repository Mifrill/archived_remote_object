require "archived_remote_object/aws_s3/remote_object"

module ArchivedRemoteObject
  module AwsS3
    class ArchivedObject
      RestoreResponseChangedError = Class.new(StandardError)

      def initialize(
        key:,
        remote_object: AwsS3::RemoteObject.new(key: key)
      )
        self.key = key
        self.remote_object = remote_object
      end

      def archived?
        remote_object.attributes.storage_class == "DEEP_ARCHIVE"
      end

      def restore_in_progress?
        restore_in_progress = parse_restore_status[0]
        return false unless restore_in_progress

        restore_in_progress.to_s.downcase == "true"
      end

      def restored?
        return false unless expiry_date

        Time.parse(expiry_date) > Time.now
      end

      def restore
        remote_object.restore(key: key, duration: restore_duration_days)
      end

      def sync
        tap { remote_object.sync }
      end

      def debug_state
        remote_object.debug_state
      end

      private

      attr_accessor :key, :remote_object

      def restore_duration_days
        ArchivedRemoteObject.configuration.archive_restore_duration_days
      end

      def expiry_date
        parse_restore_status[1]
      end

      def parse_restore_status
        remote_object.attributes.restore =~ /ongoing-request="(.+?)"(, expiry-date="(.+?)")?/
        last_match = Regexp.last_match
        raise RestoreResponseChangedError if !remote_object.attributes.restore.nil? && !last_match

        last_match&.captures || []
      end
    end
  end
end
