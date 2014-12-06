shared_examples 'belongs_to_with' do |attribute, association|
  let(:association_attribute) { :"#{association}_#{attribute}" }
  let(:association_id) { :"#{association}_id" }

  it 'creates an attr_writer for attribute named <assocation_name>_<attribute_name>' do
    expect(subject.respond_to?(:"#{association}_#{attribute}=")).to eq true
  end

  it 'creates a method named <assocation_name>_<attribute_name> that returns <association>.<attribute>' do
    baz = create_valid_model(association)
    subject.attributes = {association => baz}
    expect(subject.send(association_attribute)).to eq baz.send(attribute)
  end

  it 'searches the associated class by <attribute_name>' do
    baz = create_valid_model(association)
    subject.attributes = {association_attribute => baz.send(attribute)}
    expect(subject.send(association_attribute)).to eq baz.send(attribute)
  end

  it 'gives precendence to *_<attribute_name> over *_id' do
    baz1 = create_valid_model(association)
    baz2 = create_valid_model(association)
    subject.attributes = {association => baz1, association_attribute => baz2.send(attribute)}
    expect(subject.send(association)).to eq baz2
  end

  describe 'before_validation' do
    it 'sets (or overwrites) *_id from *_<attribute_name>' do
      baz1 = create_valid_model(association)
      baz2 = create_valid_model(association)
      subject.attributes = {association => baz1, association_attribute => baz2.send(attribute)}
      expect(subject.send(association_id)).to eq baz1.id
      subject.valid?
      expect(subject.send(association_id)).to eq baz2.id
    end

    it 'does not clear *_id if *_<attribute_name> is nil' do
      subject.attributes = {association_id => 5, association_attribute => nil}
      expect(subject.send(association_id)).to eq 5
      subject.valid?
      expect(subject.send(association_id)).to eq 5
    end
  end
end

shared_examples 'polymorphic_belongs_to_with' do |attribute, association|
  it_behaves_like 'belongs_to_with', attribute, association

  it "searches the associated class by #{attribute}" do
    baz = create_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute), "#{association}_type" => baz.class.to_s}
    expect(subject.send(association)).to eq baz
  end
end

shared_examples 'belongs_to_with!' do |attribute, association|
  it_behaves_like 'belongs_to_with', attribute, association

  it "raises if it cannot find the #{association}" do
    baz = build_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute)}
    expect { subject.valid? }.to raise_exception APITools::RecordNotFound
  end

  it 'sets the class and attribute => value on the error' do
    baz = build_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute)}
    begin
      subject.valid?
    rescue APITools::RecordNotFound => e
      expect(e.klass).to eq baz.class
      expect(e.attribute).to eq attribute.to_sym
      expect(e.value).to eq baz.send(attribute)
    end
  end
end
