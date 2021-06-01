describe ArchivedRemoteObject::AwsS3::RemoteObject do
  subject(:remote_object) do
    described_class.new(key: key, remote_client: remote_client)
  end

  let(:remote_client_klass) { ArchivedRemoteObject::AwsS3::Client }
  let(:remote_client) { instance_double(remote_client_klass) }
  let(:key) { "uploads/submission_attachment/file/1/document.pdf" }
  let(:archive_data) { OpenStruct.new(storage_class: storage_class, restore: restore) }
  let(:storage_class) { "DEEP_ARCHIVE" }
  let(:restore) { nil }

  describe "#attributes" do
    it "fires remote request and memoize attributes" do
      expect(remote_client).to receive(:fetch_object_data).once.with(key: key).and_return(archive_data)
      2.times { remote_object.attributes }
    end
  end

  describe "#restore" do
    it "delegates call to remote_client with same arguments" do
      expect(remote_client).to receive(:restore).once.with(key: key, duration: "2")
      remote_object.restore(key: key, duration: "2")
    end
  end

  describe "#assign_tag" do
    it "delegates call to remote_client with proper arguments" do
      expect(remote_client).to receive(:assign_tag).once.with(key: key, set: %w[tag_key tag_value])
      remote_object.assign_tag(key: "tag_key", value: "tag_value")
    end
  end

  describe "#storage_class=" do
    it "fires assign_storage_class on remote_client with proper arguments" do
      expect(remote_client).to receive(:assign_storage_class).once.with(key: key, storage_class: "STANDARD")
      remote_object.storage_class = "STANDARD"
    end
  end

  describe "#delete" do
    it "fires delete on remote_client" do
      expect(remote_client).to receive(:delete).once.with(key: key)
      remote_object.delete
    end
  end

  describe "#exists?" do
    it "fires exists? on remote_client" do
      expect(remote_client).to receive(:exists?).once.with(key: key)
      remote_object.exists?
    end
  end

  describe "#sync" do
    it "fires fetch_object_data request to reload archive_data" do
      expect(remote_client).to receive(:fetch_object_data).with(key: key).and_return(archive_data)
      expect(remote_object.attributes.storage_class).to eq("DEEP_ARCHIVE")
      expect(remote_client)
        .to receive(:fetch_object_data).with(key: key)
                                       .and_return(OpenStruct.new(storage_class: "STANDARD"))
      expect(remote_object.attributes.storage_class).to eq("DEEP_ARCHIVE")
      remote_object.sync
      expect(remote_object.attributes.storage_class).to eq("STANDARD")
    end
  end

  describe "#debug_state" do
    it "returns hash with current state of object" do
      expect(remote_client).to receive(:fetch_object_data).with(key: key).and_return(archive_data)
      expect(remote_object.debug_state)
        .to eq(
          restore: nil,
          storage_class: "DEEP_ARCHIVE"
        )
    end
  end
end
