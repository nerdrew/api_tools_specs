shared_examples 'has_default_status' do
  let(:active) { Status.new }
  before do
    allow(Status).to receive(:active) { active }
  end

  describe "before_validation" do
    it 'sets the status to "Active" if it is not set' do
      subject.valid?
      expect(subject.status).to eq active
    end

    it 'does nothing if the status is set' do
      status = Status.new
      subject.status = status
      subject.valid?
      expect(subject.status).to eq status
    end
  end

  describe "#status_name" do
    it 'returns the status.name' do
      subject.status = Status.new(name: 'Holy')
      expect(subject.status_name).to eq 'Holy'
    end

    it 'returns nil if there is no status' do
      expect(subject.status_name).to eq nil
    end
  end

  describe "#status_name=" do
    it 'sets the status based on the name' do
      status = Status.new
      allow(Status).to receive(:where).with(name: 'statusy') { double first: status }
      subject.status_name = 'statusy'
      expect(subject.status).to eq status
    end

    it 'returns nil if no status has the name' do
      allow(Status).to receive(:where) { double first: nil }
      subject.status_name = anything
      expect(subject.status).to eq nil
    end
  end

  describe "#active?" do
    it "returns true if the status is active" do
      subject.status = active
      expect(subject.active?).to eq true
    end

    it 'returns false if the status is not active' do
      subject.status = Status.new
      expect(subject.active?).to eq false
    end
  end
end
