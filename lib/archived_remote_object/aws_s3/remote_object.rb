require "archived_remote_object/aws_s3/client"

module ArchivedRemoteObject
  module AwsS3
    class RemoteObject
      attr_accessor :key, :remote_client

      def initialize(
        key:,
        remote_client: AwsS3::Client.new
      )
        self.key = key
        self.remote_client = remote_client
      end

      def attributes
        return @attributes if @attributes

        fetch_attributes
      end

      def restore(**args)
        remote_client.restore(**args)
      end

      def assign_tag(key:, value:)
        remote_client.assign_tag(key: self.key, set: [key, value])
      end

      def storage_class=(storage_class)
        # accepts STANDARD, STANDARD_IA, ONEZONE_IA, GLACIER, INTELLIGENT_TIERING, DEEP_ARCHIVE
        remote_client.assign_storage_class(key: key, storage_class: storage_class)
      end

      def delete
        remote_client.delete(key: key)
      end

      def sync
        tap { fetch_attributes }
      end

      def debug_state
        {
          restore: attributes.restore,
          storage_class: attributes.storage_class
        }
      end

      private

      def fetch_attributes
        @attributes = remote_client.fetch_object_data(key: key)
      end
    end
  end
end
