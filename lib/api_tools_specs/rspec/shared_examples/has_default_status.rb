shared_examples 'has_default_status' do
  let(:active) { Status.new }
  before do
    Status.stub(:active) { active }
  end

  describe "before_validation" do
    it 'sets the status to "Active" if it is not set' do
      subject.valid?
      subject.status.should == active
    end

    it 'does nothing if the status is set' do
      status = Status.new
      subject.status = status
      subject.valid?
      subject.status.should == status
    end
  end

  describe "#status_name" do
    it 'returns the status.name' do
      subject.status = Status.new(name: 'Holy')
      subject.status_name.should == 'Holy'
    end

    it 'returns nil if there is no status' do
      subject.status_name.should == nil
    end
  end

  describe "#status_name=" do
    it 'sets the status based on the name' do
      status = Status.new
      Status.stub(:where).with(name: 'statusy') { double first: status }
      subject.status_name = 'statusy'
      subject.status.should == status
    end

    it 'returns nil if no status has the name' do
      Status.stub(:where) { double first: nil }
      subject.status_name = anything
      subject.status.should == nil
    end
  end

  describe "#active?" do
    it "returns true if the status is active" do
      subject.status = active
      subject.active?.should == true
    end

    it 'returns false if the status is not active' do
      subject.status = Status.new
      subject.active?.should == false
    end
  end
end
