require "archived_remote_object/aws_s3/archived_object"

module ArchivedRemoteObject
  module Archive
    class ArchivedObject
      CantBeRestoredError = Class.new(StandardError)
      CantStopArchivingOnDurationError = Class.new(StandardError)

      def initialize(
        key:,
        remote_object: AwsS3::ArchivedObject.new(key: key)
      )
        self.remote_object = remote_object
      end

      def archived?
        remote_object.archived?
      end

      def restore_in_progress?
        return false unless archived?

        remote_object.restore_in_progress?
      end

      def restored?
        return false unless archived?

        remote_object.restored?
      end

      def restore
        raise CantBeRestoredError if available? || restore_in_progress?

        remote_object.restore
      end

      def stop_archiving_on_duration
        raise CantStopArchivingOnDurationError if !restored? || restore_in_progress?

        remote_object.stop_archiving_on_duration
      end

      def available?
        !archived? || restored?
      end

      def sync
        tap { remote_object.sync }
      end

      def debug_state
        {
          restore_in_progress: restore_in_progress?,
          restored: restored?,
          **remote_object.debug_state
        }
      end

      private

      attr_accessor :remote_object
    end
  end
end
