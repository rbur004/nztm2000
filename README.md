# nztm2000

* http://rbur004.github.io/nztm2000/
* Source https://github.com/rbur004/nztm2000
* Gem https://rubygems.org/gems/nztm2000

## DESCRIPTION:

###New Zealand Transverse Mercator (NZTM) projection routines

Converts coordinates  between the New Zealand Transverse Merctator 2000 and GRS80 latitude and longitude on the New Zealand Geodetic Datum 2000.  
                  
## FEATURES/PROBLEMS:


## SYNOPSIS:

The NZTM200 provides two public methods 

geod( easting, northing )
Converts easting and northing (meters) to a latitude and longitude (Decimal degrees and radian results available)

nztm( latitude, longitude )
Converts latitude and longitude (Decimal degrees) to easting and northing (meters) 

```
require 'nztm2000'
  #Self test from nztm.c.
  nztm2000 = NZTM2000.new
  [[1576041.150, 6188574.240], 
   [1576542.010, 5515331.050],
   [1307103.220, 4826464.860]].each do |easting,northing|
     r_latitude, r_longitude = nztm2000.geod(easting, northing)
     r_easting, r_northing = nztm2000.nztm(r_latitude, r_longitude)
 
     printf "Input  NZTM easting, northing: %12.3f %12.3f\n", easting, northing
     printf "Output     Latitude Longitude: %12.6f %12.6f\n", r_latitude, r_longitude
     printf "Output NZTM easting, northing: %12.3f %12.3f\n", r_easting, r_northing
     printf "Difference:                    %12.3f %12.3f\n", easting - r_easting, northing - r_northing
     puts
  end
```

## REQUIREMENTS:

* 

## INSTALL:

* sudo gem install nztm2000

## LICENSE:

Derived from
  http://www.linz.govt.nz/geodetic/software-downloads#nztm2000

LINZ listed no specific license, but the site states:

Download and use of these software applications is taken to be acceptance of the following conditions:
```
Land Information New Zealand (LINZ) does not offer any support for this software.
The software is provided "as is" and without warranty of any kind. In no event shall LINZ be liable for loss of any kind whatsoever with respect to the download, installation and use of the software.
The software is designed to work with MS Windows. However, LINZ makes no warranty regarding the performance or non-performance of the software on any particular system or system configuration.
 
Last Updated: 24 November 2014
```

The LINZ site also carries a CC-by license
      http://www.linz.govt.nz/linz-copyright

 
