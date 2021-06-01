require "aws-sdk-s3"

describe ArchivedRemoteObject::AwsS3::Client do
  subject(:client) { described_class.new }

  let(:s3_client) { client.s3_client }

  it "initialized S3 client with proper configuration" do
    expect(ArchivedRemoteObject.configuration).to receive(:aws_region).once.and_return("eu-west")
    expect(ArchivedRemoteObject.configuration).to receive(:aws_access_key_id).once.and_return("test access key")
    expect(ArchivedRemoteObject.configuration).to receive(:aws_secret_access_key).once.and_return("test secret")
    expect(s3_client).to be_kind_of(Aws::S3::Client)
    expect(s3_client.config.region).to eq("eu-west")
    expect(s3_client.config.credentials.access_key_id).to eq("test access key")
    expect(s3_client.config.credentials.secret_access_key).to eq("test secret")
  end

  describe "#fetch_object_data" do
    it "fires head_object request with proper key" do
      expect(s3_client).to receive(:head_object).once.with(bucket: "bucket", key: "test-object-key")
      client.fetch_object_data(key: "test-object-key")
    end

    context "with API request" do
      it "fires external head_object request and returns head_object_output response" do
        stub_response_restore = 'ongoing-request="false", expiry-date="Mon, 08 Feb 2021 00:00:00 GMT"'
        object_data = client.fetch_object_data(
          key: "remote-file-key",
          stubbed_response: { restore: stub_response_restore }
        )
        expect(object_data.data).to be_kind_of(Aws::S3::Types::HeadObjectOutput)
        expect(object_data.context.operation_name).to eq(:head_object)
        expect(object_data.storage_class).to eq("DEEP_ARCHIVE")
        expect(object_data.restore).to eq(stub_response_restore)
      end
    end
  end

  describe "#restore" do
    it "fires restore request with proper key and duration" do
      expect(s3_client)
        .to receive(:restore_object).once.with(
          bucket: "bucket", key: "test-restore-object-key", restore_request: { days: 1 }
        )
      client.restore(key: "test-restore-object-key", duration: 1)
    end

    context "with API request" do
      it "fires external restore_object request and returns restore_output response" do
        restore_object_data = client.restore(key: "remote-file-key", duration: 30)
        expect(restore_object_data.data).to be_kind_of(Aws::S3::Types::RestoreObjectOutput)
        expect(restore_object_data.context.operation_name).to eq(:restore_object)
        expect(restore_object_data.context.params)
          .to eq(
            bucket: "bucket",
            key: "remote-file-key",
            restore_request: { days: 30 }
          )
      end
    end
  end

  describe "#assign_tag" do
    it "fires put_object_tagging request with proper key and set of tag key:value" do
      expect(s3_client)
        .to receive(:put_object_tagging).once.with(
          bucket: "bucket", key: "test-object-key", tagging: { tag_set: [{ key: "tag-key", value: "tag-value" }] }
        )
      client.assign_tag(key: "test-object-key", set: %w[tag-key tag-value])
    end

    context "with API request" do
      it "fires external put_object_tagging request and returns put_object_tagging_output response" do
        restore_object_data = client.assign_tag(key: "test-object-key", set: %w[attachable_type SubmissionVersion])
        expect(restore_object_data.data).to be_kind_of(Aws::S3::Types::PutObjectTaggingOutput)
        expect(restore_object_data.context.operation_name).to eq(:put_object_tagging)
        expect(restore_object_data.context.params)
          .to eq(
            bucket: "bucket",
            key: "test-object-key",
            tagging: { tag_set: [{ key: "attachable_type", value: "SubmissionVersion" }] }
          )
      end
    end
  end

  describe "#assign_storage_class" do
    it "fires copy_object request with proper key/copy_source/storage_class" do
      expect(s3_client)
        .to receive(:copy_object).once.with(
          bucket: "bucket",
          key: "test-object-key",
          copy_source: "bucket/test-object-key",
          storage_class: "STANDARD"
        )
      client.assign_storage_class(key: "test-object-key", storage_class: "STANDARD")
    end

    context "with API request" do
      it "fires external copy_object request and returns copy_object_output response" do
        restore_object_data = client.assign_storage_class(key: "test-object-key", storage_class: "STANDARD")
        expect(restore_object_data.data).to be_kind_of(Aws::S3::Types::CopyObjectOutput)
        expect(restore_object_data.context.operation_name).to eq(:copy_object)
        expect(restore_object_data.context.params)
          .to eq(
            bucket: "bucket",
            key: "test-object-key",
            storage_class: "STANDARD",
            copy_source: "bucket/test-object-key"
          )
      end
    end
  end

  describe "#delete" do
    it "fires delete_object request with proper key" do
      expect(s3_client)
        .to receive(:delete_object).once.with(
          bucket: "bucket",
          key: "test-object-key"
        )
      client.delete(key: "test-object-key")
    end

    context "with API request" do
      it "fires external delete_object request and returns delete_object_output response" do
        restore_object_data = client.delete(key: "test-object-key")
        expect(restore_object_data.data).to be_kind_of(Aws::S3::Types::DeleteObjectOutput)
        expect(restore_object_data.context.operation_name).to eq(:delete_object)
        expect(restore_object_data.context.params)
          .to eq(
            bucket: "bucket",
            key: "test-object-key"
          )
      end
    end
  end
end
