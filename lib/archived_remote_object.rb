require "archived_remote_object/version"
require "archived_remote_object/configuration"
require "archived_remote_object/archive/archived_object"
require "archived_remote_object/archive/restored_object"
require "archived_remote_object/aws_s3/archived_object"
require "archived_remote_object/aws_s3/remote_object"
require "archived_remote_object/aws_s3/client"

module ArchivedRemoteObject
  def self.get_object(key) # rubocop:disable Metrics/MethodLength
    Archive::RestoredObject.new(
      key: key,
      archived_object: Archive::ArchivedObject.new(
        key: key,
        remote_object: AwsS3::ArchivedObject.new(
          key: key,
          remote_object: AwsS3::RemoteObject.new(
            key: key,
            remote_client: AwsS3::Client.new
          )
        )
      )
    ).call
  end
end
