shared_examples "has_uuid" do
  describe 'validations' do
    describe 'uniqueness' do
      it 'allows a unique uuid' do
        build_valid_model.save!
        model2 = build_valid_model
        model2.uuid = nil
        model2.valid?
        expect(model2.errors[:uuid]).to be_empty
        expect(model2.uuid).to_not be_nil
      end

      it 'does not allow a duplicate uuid' do
        model1 = build_valid_model
        model1.save!
        model2 = build_valid_model
        model2.uuid = model1.uuid
        model2.valid?
        expect(model2.errors[:uuid]).to eq ['has already been taken']
      end
    end

    describe 'format' do
      it 'allows properly formatted uuids' do
        subject.uuid = '01234567-890a-bcde-f012-3456789abcde'
        subject.valid?
        expect(subject.errors[:uuid]).to be_empty
      end
    end
  end

  it "assigns the model a uuid before it is validated" do
    allow(SecureRandom).to receive(:uuid).and_return("random-uuid")
    subject.valid?
    expect(subject.uuid).to eq "random-uuid"
  end

  it "does not modify the uuid if it was created with one" do
    subject.uuid = "My-Great-UUID"
    subject.valid?
    expect(subject.uuid).to eq "My-Great-UUID"
  end

  it "does not allow people to update the uuid after creation" do
    allow(subject).to receive(:new_record?).and_return(false)
    expect {
      subject.uuid = "foo"
    }.to raise_error(ArgumentError, "Can't set the uuid after the object has been created (on #{described_class.to_s} with id: #{subject.id})")
  end

  describe '.find_uuid' do
    it 'returns the record with the given uuid' do
      model = build_valid_model
      model.save!
      expect(described_class.find_uuid(model.uuid)).to eq model
    end
  end

  describe '.find_uuids' do
    it 'returns the records matching the uuids' do
      model1 = build_valid_model
      model1.save!
      model2 = build_valid_model
      model2.save!
      expect(described_class.find_uuids(model1.uuid, model2.uuid)).to match [model1, model2]
    end
  end

  describe '.find_uuid!' do
    it 'calls .find_uuid' do
      collection = double
      expect(described_class).to receive(:find_uuid).with('MY-UUID') { collection }
      expect(described_class.find_uuid!('MY-UUID')).to eq collection
    end

    it 'raises RecordNotFound if it cannot find the uuid' do
      expect do
        described_class.find_uuid!('01234567-890a-bcde-f012-3456789abcde')
      end.to raise_exception APITools::RecordNotFound
    end

    it 'raises RecordNotFound if the uuid is invalid' do
      expect do
        described_class.find_uuid!('A')
      end.to raise_exception APITools::RecordNotFound
    end

    it 'set the class and uuid as attributes on the error' do
      begin
        described_class.find_uuid!('A')
      rescue APITools::RecordNotFound => e
        expect(e.klass).to eq described_class
        expect(e.attribute).to eq :uuid
        expect(e.value).to eq 'A'
      end
    end
  end
end
