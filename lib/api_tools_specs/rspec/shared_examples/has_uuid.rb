shared_examples "has_uuid" do
  describe 'validations' do
    describe 'uniqueness' do
      it 'allows a unique uuid' do
        build_valid_model.save!
        model2 = build_valid_model
        model2.uuid = nil
        model2.valid?
        model2.errors[:uuid].should be_empty
        model2.uuid.should_not be_nil
      end

      it 'does not allow a duplicate uuid' do
        model1 = build_valid_model
        model1.save!
        model2 = build_valid_model
        model2.uuid = model1.uuid
        model2.valid?
        model2.errors[:uuid].should == ['has already been taken']
      end
    end

    describe 'format' do
      it 'allows properly formatted uuids' do
        subject.uuid = '01234567-890a-bcde-f012-3456789abcde'
        subject.valid?
        subject.errors[:uuid].should be_empty
      end
    end
  end

  it "should assign the model a uuid before it is validated" do
    SecureRandom.stub(:uuid).and_return("random-uuid")
    subject.valid?
    subject.uuid.should == "random-uuid"
  end

  it "should not modify the uuid if it was created with one" do
    subject.uuid = "My-Great-UUID"
    subject.valid?
    subject.uuid.should == "My-Great-UUID"
  end

  it "should not allow people to update the uuid after creation" do
    subject.stub(:new_record?) { false }
    lambda {
      subject.uuid = "foo"
    }.should raise_error(ArgumentError, "Can't set the uuid after the object has been created (on #{described_class.to_s} with id: #{subject.id})")
  end

  describe '.find_uuid' do
    it 'returns the record with the given uuid' do
      model = build_valid_model
      model.save!
      described_class.find_uuid(model.uuid).should == model
    end
  end

  describe '.find_uuids' do
    it 'returns the records matching the uuids' do
      model1 = build_valid_model
      model1.save!
      model2 = build_valid_model
      model2.save!
      described_class.find_uuids(model1.uuid, model2.uuid).should =~ [model1, model2]
    end
  end

  describe '.find_uuid!' do
    it 'calls .find_uuid' do
      collection = double
      described_class.should_receive(:find_uuid).with('MY-UUID') { collection }
      described_class.find_uuid!('MY-UUID').should == collection
    end

    it 'raises RecordNotFound if it cannot find the uuid' do
      lambda do
        described_class.find_uuid!('01234567-890a-bcde-f012-3456789abcde')
      end.should raise_exception APITools::RecordNotFound
    end

    it 'raises RecordNotFound if the uuid is invalid' do
      lambda do
        described_class.find_uuid!('A')
      end.should raise_exception APITools::RecordNotFound
    end

    it 'set the class and uuid as attributes on the error' do
      begin
        described_class.find_uuid!('A')
      rescue APITools::RecordNotFound => e
        e.klass.should == described_class
        e.attribute.should == :uuid
        e.value.should == 'A'
      end
    end
  end
end
