describe ArchivedRemoteObject::Archive::RestoredObject do
  subject(:restored_object) do
    described_class.new(key: key)
  end

  let(:archive_object_klass) { ArchivedRemoteObject::Archive::ArchivedObject }
  let(:archive_object) { instance_double(archive_object_klass) }
  let(:key) { "key" }
  let(:archive_object_expects) do
    lambda do
      expect(archive_object_klass)
        .to receive(:new).once.with(key: "key").and_return(archive_object)
      expect(archive_object)
        .to receive(:available?).once.and_return(available?)
    end
  end

  describe "#call" do
    context "when attachment not archived" do
      let(:available?) { true }

      it 'return data with "available" status' do
        archive_object_expects.call
        expect(archive_object).not_to receive(:restore_in_progress?)
        expect(archive_object).not_to receive(:restore)
        expect(restored_object.call.status).to eq(:available)
      end
    end

    context "when archived" do
      let(:available?) { false }

      it 'initiates restore and returns proper data with "restoration_initiated" status' do
        archive_object_expects.call
        expect(archive_object).to receive(:restore_in_progress?).once.and_return(false)
        expect(archive_object).to receive(:restore).once
        expect(archive_object).to receive(:debug_state).once.and_return(debug: true)
        expect(restored_object.call.to_h).to eq(status: :restoration_initiated, debug_state: { debug: true })
      end

      context "when restore in progress" do
        it 'returns proper data with "in_progress" status' do
          archive_object_expects.call
          expect(archive_object).to receive(:restore_in_progress?).once.and_return(true)
          expect(archive_object).not_to receive(:restore)
          expect(archive_object).to receive(:debug_state).once.and_return(debug: true)
          expect(restored_object.call.to_h).to eq(status: :in_progress, debug_state: { debug: true })
        end
      end
    end
  end
end
