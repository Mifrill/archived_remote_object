require "timecop"

describe ArchivedRemoteObject::AwsS3::ArchivedObject do
  subject(:archived_object) do
    described_class.new(key: key, remote_object: remote_object)
  end

  let(:remote_object_klass) { ArchivedRemoteObject::AwsS3::RemoteObject }
  let(:remote_object) { instance_double(remote_object_klass) }
  let(:key) { "uploads/submission_attachment/file/1/document.pdf" }
  let(:archive_data) { OpenStruct.new(storage_class: storage_class, restore: restore) }
  let(:storage_class) { "DEEP_ARCHIVE" }
  let(:restore) { nil }

  shared_context "remote_object" do
    before do
      expect(remote_object).to receive(:attributes).at_least(:once).and_return(archive_data)
    end
  end

  describe "#archived?" do
    include_context "remote_object"

    context 'when data with "archived" storage class' do
      let(:storage_class) { "DEEP_ARCHIVE" }

      it { expect(archived_object.archived?).to eq(true) }
    end

    context 'when data with "not archived" storage class' do
      let(:storage_class) { "STANDARD" }

      it { expect(archived_object.archived?).to eq(false) }
    end

    context "when data with no storage class" do
      let(:storage_class) { nil }

      it { expect(archived_object.archived?).to eq(false) }
    end
  end

  describe "#restore_in_progress?" do
    include_context "remote_object"

    context 'when data with "not archived" storage class' do
      let(:storage_class) { "STANDARD" }

      it { expect(archived_object.restore_in_progress?).to eq(false) }

      context "when data with no storage class" do
        let(:storage_class) { nil }

        it { expect(archived_object.restore_in_progress?).to eq(false) }
      end
    end

    context "when object never was restored" do
      let(:restore) { nil }

      it { expect(archived_object.restore_in_progress?).to eq(false) }
    end

    context 'when Restoration status: "In-progress"' do
      let(:restore) { 'ongoing-request="true"' }

      it { expect(archived_object.restore_in_progress?).to eq(true) }
    end

    context 'when Restoration status: "Completed"' do
      let(:restore) { 'ongoing-request="false", expiry-date="Mon, 22 Feb 2021 00:00:00 GMT"' }

      it { expect(archived_object.restore_in_progress?).to eq(false) }
    end

    context 'when response for "restore" changed | [case in theory]' do
      let(:restore) { "response in Aws API is changed" }

      it "raises RestoreResponseChangedError error" do
        expect { archived_object.restore_in_progress? }.to raise_exception(described_class::RestoreResponseChangedError)
      end
    end
  end

  describe "#restored?" do
    include_context "remote_object"

    context 'when data with "not archived" storage class' do
      let(:storage_class) { "STANDARD" }

      it { expect(archived_object.restored?).to eq(false) }

      context "when data with no storage class" do
        let(:storage_class) { nil }

        it { expect(archived_object.restored?).to eq(false) }
      end
    end

    context "when object never was restored" do
      let(:restore) { nil }

      it { expect(archived_object.restored?).to eq(false) }
    end

    context 'when Restoration status: "In-progress"' do
      let(:restore) { 'ongoing-request="true"' }

      it { expect(archived_object.restored?).to eq(false) }
    end

    context 'when Restoration status: "Completed"' do
      let(:restore) { 'ongoing-request="false", expiry-date="Mon, 22 Feb 2021 00:00:00 GMT"' }
      let(:expiry_date) { "Mon, 22 Feb 2021 00:00:00 GMT" }

      around { |example| Timecop.travel(current_time, &example) }

      context "when Restoration expiry date/time: before current time" do
        let(:current_time) { "Mon, 21 Feb 2021 23:59:59 GMT" }

        it { expect(archived_object.restored?).to eq(true) }
        it { expect(Time.parse(archived_object.send(:expiry_date))).to be > Time.parse(current_time) }
      end

      context "when Restoration expiry date/time: equal to current time" do
        let(:current_time) { "Mon, 22 Feb 2021 00:00:00 GMT" }

        it { expect(archived_object.restored?).to eq(false) }
        it { expect(Time.parse(archived_object.send(:expiry_date))).to eq(Time.parse(current_time)) }
      end

      context "when Restoration expiry date/time: after current time" do
        let(:current_time) { "Mon, 22 Feb 2021 00:00:01 GMT" }

        it { expect(archived_object.restored?).to eq(false) }
        it { expect(Time.parse(archived_object.send(:expiry_date))).to be < Time.parse(current_time) }
      end
    end

    context 'when response for "restore" changed | [case in theory]' do
      let(:restore) { "response in Aws API is changed" }

      it { expect { archived_object.restored? }.to raise_exception(described_class::RestoreResponseChangedError) }
    end
  end

  describe "#restore" do
    it "fires restore request on remote_object" do
      expect(remote_object).to receive(:restore).once.with(key: key, duration: "1")
      archived_object.restore
    end
  end

  describe "#stop_archiving_on_duration" do
    it 'fires storage_class setter request with "STANDARD" storage class on remote_object' do
      expect(remote_object).to receive(:storage_class=).once.with("STANDARD")
      archived_object.stop_archiving_on_duration
    end
  end

  describe "#sync" do
    it "fires sync on remote object" do
      expect(remote_object).to receive(:sync).with(no_args).and_return(remote_object)
      archived_object.sync
    end
  end

  describe "#debug_state" do
    it "returns hash with current state of object" do
      expect(remote_object).to receive(:debug_state).and_return(debug: true)
      expect(archived_object.debug_state).to eq(debug: true)
    end
  end
end
