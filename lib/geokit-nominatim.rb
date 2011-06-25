
path = File.expand_path(File.dirname(__FILE__))
$:.unshift path unless $:.include?(path)

require 'geokit'
require 'geokit/geocoders/nominatim_geocoder'
