class Geokit::Geocoders::NominatimGeocoder < Geokit::Geocoders::Geocoder

  PLACE_KEYS = %W{city state postcode country country_code house_number house
                  hamlet}
  PROVIDER = 'nominatim'

  class << self
    attr_accessor :server
  end

  def self.do_geocode(address, options = {})
    # get server address
    server = options[:server] || self.server
    raise "server required" unless server
    server = "http://#{server}" unless server.match(/^http:/)

    # construct response
    res = Geokit::GeoLoc.new
    res.provider = PROVIDER

    # create query string
    address_str = address.is_a?(Geokit::GeoLoc) ? address.to_geocodeable_s : address
    opts = options.merge(:q => address_str, :limit => 1,
                         :format => :xml, :addressdetails => 1)
    opts.delete(:server)
    params = opts.collect { |k,v| "#{k}=#{URI.escape(v.to_s)}" }.join("&")

    # send query
    url = "#{server}?#{params}"
    server_res = self.call_geocoder_service(url)
    return res if !server_res.is_a?(Net::HTTPSuccess)

    # parse response
    xml = server_res.body
    xml = xml.force_encoding('utf-8') if xml.respond_to?(:force_encoding)
    logger.debug "nominatim geocoding. Address: #{address}. Result: #{xml}"
    self.parse_response(xml, res)
    res
  end

  private

  def self.parse_response(xml, res)
    doc = REXML::Document.new(xml)

    place = doc.elements['//searchresults/place']
    attrs = place.attributes
    res.lat = attrs['lat']
    res.lng = attrs['lon']

    elements = {}
    PLACE_KEYS.each do |key|
      elements[key] = place.elements[key] ? place.elements[key].text : nil
    end

    res.full_address = attrs['display_name']
    res.street_address = elements['road']
    res.zip = elements['postcode']
    res.country = elements['country']
    res.city = elements['city'] || elements['hamlet']
    res.state = elements['state']
    res.street_number = elements['house_number'] || elements['house']
    res.success = true
  end

  def self.escape(string)
    Geokit::Inflector::url_escape(string.to_s)
  end

end
