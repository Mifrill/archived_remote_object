require "aws-sdk-s3"

module ArchivedRemoteObject
  module AwsS3
    class Client
      attr_accessor :s3_client

      def initialize
        self.s3_client = Aws::S3::Client.new(
          stub_responses: stubbed?,
          region: ArchivedRemoteObject.configuration.aws_region,
          credentials: Aws::Credentials.new(
            ArchivedRemoteObject.configuration.aws_access_key_id,
            ArchivedRemoteObject.configuration.aws_secret_access_key
          )
        )
      end

      def fetch_object_data(key:, stubbed_response: {})
        if stubbed?
          response = {
            storage_class: "DEEP_ARCHIVE",
            restore: nil,
            **stubbed_response
          }
          s3_client.stub_responses(:head_object, response)
        end
        s3_client.head_object(bucket: bucket, key: key)
      end

      def restore(key:, duration:)
        s3_client.stub_responses(:restore_object) if stubbed?
        s3_client.restore_object(bucket: bucket, key: key, restore_request: { days: duration })
      end

      def assign_tag(key:, set:)
        s3_client.stub_responses(:put_object_tagging) if stubbed?
        s3_client.put_object_tagging(bucket: bucket, key: key, tagging: { tag_set: [{ key: set[0], value: set[1] }] })
      end

      def assign_storage_class(key:, storage_class:)
        s3_client.stub_responses(:copy_object) if stubbed?
        s3_client.copy_object(bucket: bucket, key: key, copy_source: "#{bucket}/#{key}", storage_class: storage_class)
      end

      def delete(key:)
        s3_client.stub_responses(:delete_object) if stubbed?
        s3_client.delete_object(bucket: bucket, key: key)
      end

      private

      def bucket
        ArchivedRemoteObject.configuration.aws_bucket
      end

      def stubbed?
        ArchivedRemoteObject.configuration.stub_client_requests
      end
    end
  end
end
