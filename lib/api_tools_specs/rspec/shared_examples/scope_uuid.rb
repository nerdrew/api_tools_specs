shared_examples "scope_uuid" do |association, options = {}|
  let(:scope_name) { :"with_#{association}_uuid" }

  describe '.scope_uuid' do
    it 'adds a scope named "with_<association>_uuid" to the class' do
      expect(described_class.respond_to?(scope_name)).to eq true
    end
  end

  describe '.with_<association>_uuid' do
    it 'scopes the query by: JOIN <association> ... WHERE <association>.uuid = <uuid>' do
      associated_model = create_valid_model(association)
      model1 = create_valid_model association => associated_model
      create_valid_model
      expect(described_class.send(scope_name, associated_model.uuid).to_a).to eq [model1]
    end

    context 'with an invalid uuid' do
      it 'does not raise an exception' do
        expect(->{described_class.send(scope_name, 'a').to_a }).to_not raise_exception
      end

      it 'returns nothing' do
        create_valid_model association
        create_valid_model
        expect(described_class.send(scope_name, 'a').to_a).to eq []
      end
    end
  end
end
