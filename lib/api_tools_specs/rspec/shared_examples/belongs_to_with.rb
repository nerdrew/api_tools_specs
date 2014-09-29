shared_examples 'belongs_to_with' do |attribute, association|
  let(:association_attribute) { :"#{association}_#{attribute}" }
  let(:association_id) { :"#{association}_id" }

  it 'creates an attr_writer for attribute named <assocation_name>_<attribute_name>' do
    subject.respond_to?(:"#{association}_#{attribute}=").should == true
  end

  it 'creates a method named <assocation_name>_<attribute_name> that returns <association>.<attribute>' do
    baz = create_valid_model(association)
    subject.attributes = {association => baz}
    subject.send(association_attribute).should == baz.send(attribute)
  end

  it 'searches the associated class by <attribute_name>' do
    baz = create_valid_model(association)
    subject.attributes = {association_attribute => baz.send(attribute)}
    subject.send(association_attribute).should == baz.send(attribute)
  end

  it 'gives precendence to *_<attribute_name> over *_id' do
    baz1 = create_valid_model(association)
    baz2 = create_valid_model(association)
    subject.attributes = {association => baz1, association_attribute => baz2.send(attribute)}
    subject.send(association).should == baz2
  end

  describe 'before_validation' do
    it 'sets (or overwrites) *_id from *_<attribute_name>' do
      baz1 = create_valid_model(association)
      baz2 = create_valid_model(association)
      subject.attributes = {association => baz1, association_attribute => baz2.send(attribute)}
      subject.send(association_id).should == baz1.id
      subject.valid?
      subject.send(association_id).should == baz2.id
    end

    it 'does not clear *_id if *_<attribute_name> is nil' do
      subject.attributes = {association_id => 5, association_attribute => nil}
      subject.send(association_id).should == 5
      subject.valid?
      subject.send(association_id).should == 5
    end
  end
end

shared_examples 'polymorphic_belongs_to_with' do |attribute, association|
  it_behaves_like 'belongs_to_with', attribute, association

  it "searches the associated class by #{attribute}" do
    baz = create_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute), "#{association}_type" => baz.class.to_s}
    subject.send(association).should == baz
  end
end

shared_examples 'belongs_to_with!' do |attribute, association|
  it_behaves_like 'belongs_to_with', attribute, association

  it "raises if it cannot find the #{association}" do
    baz = build_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute)}
    lambda { subject.valid? }.should raise_exception APITools::RecordNotFound
  end

  it 'sets the class and attribute => value on the error' do
    baz = build_valid_model(association)
    subject.attributes = {"#{association}_#{attribute}" => baz.send(attribute)}
    begin
      subject.valid?
    rescue APITools::RecordNotFound => e
      e.klass.should == baz.class
      e.attribute.should == attribute.to_sym
      e.value.should == baz.send(attribute)
    end
  end
end
