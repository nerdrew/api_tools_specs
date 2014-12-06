shared_examples 'is_soft_deletable' do
  describe "validations" do
    # TODO this does not work with shoulda right now
    # it { should ensure_inclusion_of(:deleted).in_array([true, false]) }
  end

  describe ".active" do
    it "returns all records which 'deleted' column is set to false" do
      active = build_valid_model
      active.deleted = false
      active.save!

      inactive = build_valid_model
      inactive.deleted = true
      inactive.save!

      expect(described_class.active).to eq [active]
    end
  end

  describe ".soft_delete" do
    it "sets the 'deleted' attribute to true for all of the models" do
      model1 = build_valid_model
      model1.deleted = false
      model1.save!

      model2 = build_valid_model
      model2.deleted = false
      model2.save!

      expect(described_class.active).to eq [model1, model2]

      described_class.active.soft_delete

      expect(described_class.active).to be_empty
    end
  end

  describe 'callbacks' do
    it "has a before_soft_delete callback" do
      model = create_valid_model

      model.class.module_eval do
        attr_accessor :foo
        before_soft_delete ->(mod){ mod.foo = 'bam' }
      end

      model.foo = 'boom'
      model.soft_delete
      expect(model.foo).to eq 'bam'
    end

    it "has an after_soft_delete callback" do
      model = create_valid_model

      model.class.module_eval do
        attr_accessor :foo
        after_soft_delete ->(mod){ mod.foo = 'bam' }
      end

      model.foo = 'boom'
      model.soft_delete
      expect(model.foo).to eq 'bam'
    end

    it "has an around_soft_delete callback" do
      model = create_valid_model

      model.class.module_eval do
        attr_accessor :foo
        around_soft_delete :test_around_callback

        def test_around_callback
          self.foo = 'bam'
          yield
        end
      end

      model.foo = 'boom'
      model.soft_delete
      expect(model.foo).to eq 'bam'
      expect(model).to be_deleted
    end
  end

  describe "#soft_delete" do
    it "sets the 'deleted' attribute to true" do
      model = build_valid_model
      model.save!
      model.soft_delete
      expect(model).to be_deleted
    end

    it "sets assigns a time to 'deleted_at'" do
      model = build_valid_model
      model.save!
      model.soft_delete
      expect(model.deleted_at).to_not be_nil
    end

    it "doesn't delete the record from the database" do
      model = build_valid_model
      model.save!
      model.soft_delete
      expect(model).to be_persisted
    end
  end
end
