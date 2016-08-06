require "test/unit"
require "nztm2000"

class TestNztm2000 < Test::Unit::TestCase
  def test_sanity
    nztm2000 = NZTM2000.new
    [[1576041.150, 6188574.240, -34.444065991,	172.739193967], 
     [1576542.010, 5515331.050, -40.512408980,	172.723105968],
     [1307103.220, 4826464.860, -46.651295012,	169.172062008]
    ].each do |easting,northing, latitude, longitude|
       latitude_r, longitude_r = nztm2000.geod(easting, northing)
       easting_r, northing_r = nztm2000.nztm(latitude_r, longitude_r)
       assert_in_delta(latitude_r, latitude, 0.00005)
       assert_in_delta(longitude_r, longitude, 0.00005)
       assert_in_delta(easting_r, easting, 0.0005)
       assert_in_delta(northing_r, northing, 0.0005)
    end
  end
end
