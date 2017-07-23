require 'rake'

describe 'meter_cat rake tasks' do

  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    load 'lib/tasks/meter_cat.rake'
  end

  #############################################################################
  # meter_cat:mail

  describe 'meter_cat:mail' do

    it 'calls sends the report email' do
      MeterCat.should_receive(:mail)
      @rake['meter_cat:mail'].invoke
    end
  end

  #############################################################################
  # meter_cat:random[name,min,max,start,stop]

  describe 'meter_cat:random[name,min,max,days]' do

    before(:each) do
      @name = 'test'
      @min = '1'
      @max = '10'
      @days = '365'
    end

    it 'calls Meter::random with the args' do
      MeterCat::Meter.should_receive(:random) do |args|
        args[:name].should eql(@name)
        args[:min].should eql(@min)
        args[:max].should eql(@max)
        args[:days].should eql(@days)
      end
      @rake['meter_cat:random'].invoke(@name, @min, @max, @days)
    end
  end
end
