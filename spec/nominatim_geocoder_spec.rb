require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class NominatimTests

  def self.geocode_tests
    [ ["Adelaide", {
         :lat => -34.927, :lng => 138.600,
         :zip => "5000", :country => "Australia", :city => "Adelaide",
         :state => "South Australia"
       }],
      ["359 Columbus Avenue, New York", {
         :lat => 40.717, :lng => -73.338,
         :zip => '11704', :street_number => '359',
         :country => "United States of America", :city => "West Babylon",
         :state => "New York"
       }]
    ]
  end

end

describe Geokit::Geocoders::NominatimGeocoder do

  before(:all) do
    @klass = Geokit::Geocoders::NominatimGeocoder
    @server = ENV['NOMINATIM_SERVER']
  end

  it "should respond to do_geocode()" do
    @klass.should respond_to(:do_geocode)
  end

  it "should be usable from MultiGeocoder" do
    @klass.should_receive(:geocode).and_return(Geokit::GeoLoc.new)

    Geokit::Geocoders::provider_order = [:nominatim]
    Geokit::Geocoders::MultiGeocoder.geocode('test address')
  end

  NominatimTests.geocode_tests.each do |addr, expected|
    it "should geocode #{addr}" do
      @klass.server = @server
      res = @klass.geocode(addr)
      res.should_not be_nil
      res.success.should be_true
      res.lat.should be_within(0.1).of(expected[:lat])
      res.lng.should be_within(0.1).of(expected[:lng])

      expected.each do |k,v|
        next if [:lat, :lng].include?(k)
        res.send(k).should == v
      end
    end
  end

end

