describe ArchivedRemoteObject::Archive::ArchivedObject do
  subject(:archived_object) do
    described_class.new(key: key)
  end

  let(:key) { "file_name" }
  let(:source_klass) { ArchivedRemoteObject::AwsS3::ArchivedObject }
  let(:source) { instance_double(source_klass) }

  before do
    expect(source_klass).to receive(:new).once.with(key: key).and_return(source)
  end

  describe "#archived?" do
    context 'when source "archived"' do
      it "returns true with ask source" do
        expect(source).to receive(:archived?).once.and_return(true)
        expect(archived_object.archived?).to eq(true)
      end
    end

    context 'when source "not archived"' do
      it "returns false with ask source" do
        expect(source).to receive(:archived?).once.and_return(false)
        expect(archived_object.archived?).to eq(false)
      end
    end
  end

  describe "#restore_in_progress?" do
    context 'when source "not archived"' do
      it "returns false with no ask source" do
        expect(source).to receive(:archived?).once.and_return(false)
        expect(source).not_to receive(:restore_in_progress?)
        expect(archived_object.restore_in_progress?).to eq(false)
      end
    end

    context 'when source "archived"' do
      context 'when source "restore_in_progress"' do
        it "returns false with ask source" do
          expect(source).to receive(:archived?).once.and_return(true)
          expect(source).to receive(:restore_in_progress?).once.and_return(true)
          expect(archived_object.restore_in_progress?).to eq(true)
        end
      end

      context 'when source "not restore_in_progress"' do
        it "returns false with ask source" do
          expect(source).to receive(:archived?).once.and_return(true)
          expect(source).to receive(:restore_in_progress?).once.and_return(false)
          expect(archived_object.restore_in_progress?).to eq(false)
        end
      end
    end
  end

  describe "#restored?" do
    context 'when source "not archived"' do
      it "returns false with no ask source" do
        expect(source).to receive(:archived?).once.and_return(false)
        expect(source).not_to receive(:restored?)
        expect(archived_object.restored?).to eq(false)
      end
    end

    context 'when source "archived"' do
      context 'when source "restored"' do
        it "returns false with ask source" do
          expect(source).to receive(:archived?).once.and_return(true)
          expect(source).to receive(:restored?).once.and_return(true)
          expect(archived_object.restored?).to eq(true)
        end
      end

      context 'when source "not restored"' do
        it "returns false with ask source" do
          expect(source).to receive(:archived?).once.and_return(true)
          expect(source).to receive(:restored?).once.and_return(false)
          expect(archived_object.restored?).to eq(false)
        end
      end
    end
  end

  describe "#restore" do
    context 'when "available"' do
      it "raises error" do
        expect(archived_object).to receive(:available?).once.and_return(true)
        expect(archived_object).not_to receive(:restore_in_progress?)
        expect(source).not_to receive(:restore)
        expect { archived_object.restore }.to raise_exception(described_class::CantBeRestoredError)
      end
    end

    context 'when "not available"' do
      context 'when "restore_in_progress"' do
        it "raises error" do
          expect(archived_object).to receive(:available?).once.and_return(false)
          expect(archived_object).to receive(:restore_in_progress?).once.and_return(true)
          expect(source).not_to receive(:restore)
          expect { archived_object.restore }.to raise_exception(described_class::CantBeRestoredError)
        end
      end

      context 'when "restore_in_progress"' do
        it "fires restore on source" do
          expect(archived_object).to receive(:available?).once.and_return(false)
          expect(archived_object).to receive(:restore_in_progress?).once.and_return(false)
          expect(source).to receive(:restore).once.with(no_args)
          archived_object.restore
        end
      end
    end
  end

  describe "#available?" do
    context 'when "not archived"' do
      it "returns true" do
        expect(archived_object).to receive(:archived?).once.and_return(false)
        expect(archived_object).not_to receive(:restored?)
        expect(archived_object.available?).to eq(true)
      end
    end

    context "when archived" do
      before do
        expect(archived_object).to receive(:archived?).once.and_return(true)
      end

      context 'when "not archived" and "restored"' do
        it "returns true" do
          expect(archived_object).to receive(:restored?).once.and_return(true)
          expect(archived_object.available?).to eq(true)
        end
      end

      context 'when "not archived" and "not restored"' do
        it "returns false" do
          expect(archived_object).to receive(:restored?).once.and_return(false)
          expect(archived_object.available?).to eq(false)
        end
      end
    end
  end

  describe "#stop_archiving_on_duration" do
    context 'when "not restored"' do
      it "raises error" do
        expect(archived_object).to receive(:restored?).once.and_return(false)
        expect(archived_object).not_to receive(:restore_in_progress?)
        expect(source).not_to receive(:stop_archiving_on_duration)
        expect { archived_object.stop_archiving_on_duration }
          .to raise_exception(described_class::CantStopArchivingOnDurationError)
      end
    end

    context 'when "restored"' do
      context 'when "restore_in_progress"' do
        it "raises error" do
          expect(archived_object).to receive(:restored?).once.and_return(true)
          expect(archived_object).to receive(:restore_in_progress?).once.and_return(true)
          expect(source).not_to receive(:stop_archiving_on_duration)
          expect { archived_object.stop_archiving_on_duration }
            .to raise_exception(described_class::CantStopArchivingOnDurationError)
        end
      end

      context 'when "restore_in_progress"' do
        it "fires stop_archiving_on_duration on source" do
          expect(archived_object).to receive(:restored?).once.and_return(true)
          expect(archived_object).to receive(:restore_in_progress?).once.and_return(false)
          expect(source).to receive(:stop_archiving_on_duration).once.with(no_args)
          archived_object.stop_archiving_on_duration
        end
      end
    end
  end

  describe "#sync" do
    it "fires sync on source" do
      expect(source).to receive(:sync)
      expect(archived_object.sync).to eq(archived_object)
    end
  end

  describe "#debug_state" do
    it "returns hash with current state of object" do
      expect(archived_object).to receive(:restore_in_progress?).once.and_return(false)
      expect(archived_object).to receive(:restored?).once.and_return(true)
      expect(source).to receive(:debug_state).once.and_return(source_debug: true)
      expect(archived_object.debug_state)
        .to eq(
          restore_in_progress: false,
          restored: true,
          source_debug: true
        )
    end
  end
end
