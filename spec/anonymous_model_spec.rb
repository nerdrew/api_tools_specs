require 'spec_helper'

describe APIToolsSpecs::AnonymousModel do
  before :all do
    @events = []
    ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  describe '.build_model' do
    build_model :bam do
      string :goat
    end

    it 'creates a new database connection to an in-memory sqlite db and create a new table' do
      @events.map {|event| event.payload[:sql] }.join("\n") =~ /CREATE TABLE "bams"/
      @events.map {|event| event.payload[:sql] }.join("\n") =~ /ALTER TABLE "bams" ADD "goat" varchar\(255\)/
    end

    it 'creates a model that we can use' do
      lambda { Bam.create goat: 'can' }.should change(Bam, :count).by(1)
      Bam.last.goat.should == 'can'
    end
  end

  describe 'class reuse' do
    shared_examples 'cleanup old classes' do
      build_model :bam do
        string :cat
      end

      build_model :boom do
        integer :bam_id
        belongs_to :bam
      end

      it 'has the correct class' do
        Boom.new.association(:bam).klass.should == Bam
      end
    end

    it_behaves_like 'cleanup old classes'
    it_behaves_like 'cleanup old classes'

    it 'removes the class after running' do
      lambda { Bam }.should raise_exception NameError
    end

    it 'removes old tables' do
      APIToolsSpecs::AnonymousModel::ConnectionHolder.connection.tables.should == []
    end
  end
end
