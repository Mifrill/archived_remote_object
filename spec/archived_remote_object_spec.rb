describe ArchivedRemoteObject do
  it "has a version number" do
    expect(ArchivedRemoteObject::VERSION).not_to be nil
  end

  describe ".get_object" do
    it "returns object with proper data" do
      object = described_class.get_object("remote-file-key")
      expect(object.status).to eq(:restoration_initiated)
      debug_state = {
        restore_in_progress: false,
        restored: false,
        restore: nil,
        storage_class: "DEEP_ARCHIVE"
      }
      expect(object.debug_state).to eq(debug_state)
    end
  end
end
