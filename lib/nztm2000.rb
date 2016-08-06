class NZTM2000
  VERSION = '1.0.0'

  #Define the parameters for the International Ellipsoid
  #used for the NZGD2000 datum (and hence for NZTM)
  NZTM_A    = 6378137.0
  NZTM_RF_GRS80   = 298.257222101 #GRS80 Inverse flattening between equatorial and polar.
  NZTM_RF_WGS84 = 298.257223563 #Inverse flattening.
  NZTM_RF = NZTM_RF_GRS80
  NZTM_CM   = 173
  NZTM_OLAT = 0.0 
  NZTM_SF   = 0.9996 
  NZTM_FE   = 1600000.0 
  NZTM_FN   = 10000000.0
  
  attr_accessor :meridian #Central meridian
  attr_accessor :scalef   #Scale factor
  attr_accessor :orglat   #Origin latitude
  attr_accessor :falsee   #False easting
  attr_accessor :falsen   #False northing
  attr_accessor :utomk    #Unit to metre conversion
  attr_accessor :a, :rf, :f, :e2, :ep2 #Ellipsoid parameters
  
  attr_accessor :latitude    #Latitude (decimal degrees)
  attr_accessor :latitude_r  #Latitude (radians)
  attr_accessor :longitude   #Longitude (Decimal degrees)
  attr_accessor :longitude_r #Longitude (radians)
  attr_accessor :northing    #NZTM 2000 northing (meters)
  attr_accessor :easting     #NZTM 2000 easting (meters)
  
  def initialize
    tm_initialize(NZTM_A, NZTM_RF, NZTM_CM/(180/Math::PI), NZTM_SF, NZTM_OLAT/(180/Math::PI), NZTM_FE, NZTM_FN, 1.0)
  end
  
  #Initialize the TM projection parameters
  def tm_initialize( a, rf, cm, sf, lto, fe, fn, utom )
     @meridian = cm
     @scalef = sf
     @orglat = lto
     @falsee = fe
     @falsen = fn
     @utom = utom
     f = rf != 0.0 ? 1.0/rf : 0.0
     @a = a
     @rf = rf
     @f = f
     @e2 = 2.0*f - f*f
     @ep2 = @e2/( 1.0 - @e2 )

     @om = meridian_arc( lto )
  end
  
  #*************************************************************************
  #  Method based on Redfearn's formulation as expressed in GDA technical   
  #  manual at http://www.icsm.gov.au/gda/tech.html               
  #                                                                         
  #  @param latitude [Numeric] radians                                                 
  #  @return [Numeric] the length of meridional arc in meters (Helmert formula)                 
  #                                                                         
  #*************************************************************************
  private def meridian_arc( lt )
      e4 = @e2*@e2
      e6 = e4*@e2

      a0 = 1 - (@e2/4.0) - (3.0*e4/64.0) - (5.0*e6/256.0)
      a2 = (3.0/8.0) * (@e2+e4/4.0+15.0*e6/128.0)
      a4 = (15.0/256.0) * (e4 + 3.0*e6/4.0)
      a6 = 35.0*e6/3072.0

      return  @a*(a0*lt-a2*Math.sin(2*lt)+a4*Math.sin(4*lt)-a6*Math.sin(6*lt))
  end
  
  #***********************************************************************
  #   Calculates the foot point latitude from the meridional arc          
  #   Method based on Redfearn's formulation as expressed in GDA technical
  #   manual at http://www.icsm.gov.au/gda/tech.html            
  #                                                                       
  #   @param m [Numeric] meridional arc (metres)                                          
  #                                                              
  #   @returns [Numeric] the foot point latitude (radians)                            #                                                                       
  #***********************************************************************

  private def foot_point_lat( m )
      n  = @f/(2.0-@f)
      n2 = n*n
      n3 = n2*n
      n4 = n2*n2

      g = @a*(1.0-n)*(1.0-n2)*(1+9.0*n2/4.0+225.0*n4/64.0)
      sig = m/g

      return sig + (3.0*n/2.0 - 27.0*n3/32.0)*Math.sin(2.0*sig) +
                      (21.0*n2/16.0 - 55.0*n4/32.0)*Math.sin(4.0*sig) +
                      (151.0*n3/96.0) * Math.sin(6.0*sig) +
                      (1097.0*n4/512.0) * Math.sin(8.0*sig)
  end
  
  #*************************************************************************
  #   Routine to convert from Tranverse Mercator to latitude and longitude. 
  #   Method based on Redfearn's formulation as expressed in GDA technical  
  #   manual at http://www.icsm.gov.au/gda/tech.html      
  #   Sets @latitude, @longitude (degrees) and @latitude_r, @longitude_r (Radians)    
  #                                                                         
  #   @param ce [Numeric] input northing (metres)
  #   @return [Numeric, Numeric]    @latitude, @longitude (decimal degrees)                                       
  #                                                                         
  #*************************************************************************

  private def tm_geod
      cn1  =  (@northing - @falsen)*@utom/@scalef + @om
      fphi = foot_point_lat(cn1)
      slt = Math.sin(fphi)
      clt = Math.cos(fphi)

      eslt = (1.0-@e2*slt*slt)
      eta = @a/Math.sqrt(eslt)
      rho = eta * (1.0 - @e2) / eslt
      psi = eta/rho

      e = (@easting-@falsee)*@utom
      x = e/(eta*@scalef)
      x2 = x*x

      t = slt/clt
      t2 = t*t
      t4 = t2*t2

      trm1 = 1.0/2.0

      trm2 = ((-4.0*psi + 9.0*(1-t2))*psi + 12.0*t2)/24.0

      trm3 = ((((8.0*(11.0-24.0*t2)*psi - 
                    12.0*(21.0-71.0*t2))*psi + 
                    15.0*((15.0*t2-98.0)*t2+15))*psi +
                    180.0*((-3.0*t2+5.0)*t2))*psi + 360.0*t4)/720.0

      trm4 = (((1575.0*t2+4095.0)*t2+3633.0)*t2+1385.0)/40320.0

      @latitude_r = fphi+(t*x*e/(@scalef*rho))*(((trm4*x2-trm3)*x2+trm2)*x2-trm1)
      @latitude = @latitude_r * 180.0 / Math::PI

      trm1 = 1.0

      trm2 = (psi+2.0*t2)/6.0

      trm3 = (((-4.0*(1.0-6.0*t2)*psi +
                 (9.0-68.0*t2))*psi +
                 72.0*t2)*psi +
                 24.0*t4)/120.0

      trm4 = (((720.0*t2+1320.0)*t2+662.0)*t2+61.0)/5040.0

      @longitude_r = @meridian - (x/clt)*(((trm4*x2-trm3)*x2+trm2)*x2-trm1)
      @longitude = @longitude_r * 180.0 / Math::PI
      
      return @latitude, @longitude
  end

  #*************************************************************************
  #                                                                         
  #   geodtm                                                                
  #                                                                         
  #   Routine to convert from latitude and longitude to Transverse Mercator.
  #   Method based on Redfearn's formulation as expressed in GDA technical  
  #   manual at http://www.icsm.gov.au/gda/tech.html              
  #   Loosely based on FORTRAN source code by J.Hannah and A.Broadhurst.    
  #                                                                         
  #   Sets @easting  (metres)                                               
  #   Sets @northing (metres)                                               
  #   @return [Numeric,Numeric] @easting, @northing (meters)
  #*************************************************************************
  private def geod_tm
      dlon  =  @longitude_r - @meridian
      while ( dlon > Math::PI ) do dlon -= (2 * Math::PI) end
      while ( dlon < -Math::PI ) do dlon += ( 2 * Math::PI) end

      m = meridian_arc(@latitude_r)

      slt = Math.sin(@latitude_r)

      eslt = (1.0-@e2*slt*slt)
      eta = @a/Math.sqrt(eslt)
      rho = eta * (1.0-@e2) / eslt
      psi = eta/rho

      clt = Math.cos(@latitude_r)
      w = dlon

      wc = clt*w
      wc2 = wc*wc

      t = slt/clt
      t2 = t*t
      t4 = t2*t2
      t6 = t2*t4

      trm1 = (psi-t2)/6.0

      trm2 = (((4.0*(1.0-6.0*t2)*psi + (1.0+8.0*t2))*psi - 2.0*t2)*psi+t4)/120.0;

      trm3 = (61 - 479.0*t2 + 179.0*t4 - t6)/5040.0

      gce = (@scalef*eta*dlon*clt)*(((trm3*wc2+trm2)*wc2+trm1)*wc2+1.0)
      @easting = gce/@utom+@falsee

      trm1 = 1.0/2.0

      trm2 = ((4.0*psi+1)*psi-t2)/24.0

      trm3 = ((((8.0*(11.0-24.0*t2)*psi - 28.0*(1.0-6.0*t2))*psi + (1.0-32.0*t2))*psi - 2.0*t2)*psi + t4)/720.0

      trm4 = (1385.0-3111.0*t2+543.0*t4-t6)/40320.0

      gcn = (eta*t)*((((trm4*wc2+trm3)*wc2+trm2)*wc2+trm1)*wc2)
      @northing = (gcn+m-@om)*@scalef/@utom+@falsen
      
      return @easting, @northing
  end

  # Functions implementation the TM projection specifically for the
  #   NZTM coordinate system
  #  @return [Numeric,Numeric] latitude and longitude (decimal degrees)
  def geod( easting, northing )
    @easting = easting
    @northing = northing
    return tm_geod
  end

  # Functions implementation the TM projection specifically for the
  #   NZTM coordinate system
  #  @return [Numeric,Numeric] northing and easting (meters)
  def nztm( latitude, longitude )
    @latitude = latitude
    @latitude_r = latitude/(180/Math::PI)
    @longitude = longitude
    @longitude_r = longitude/(180/Math::PI)
    return geod_tm
  end

  def self.test
    nztm2000 = self.new
    [[1576041.150, 6188574.240], 
     [1576542.010, 5515331.050],
     [1307103.220, 4826464.860]].each do |easting,northing|
       latitude, longitude = nztm2000.geod(easting, northing)
       r_easting, r_northing = nztm2000.nztm(latitude, longitude)
     
       puts "Input  NZTM easting, northing: #{"%12.3f"%easting}, #{"%12.3f"%northing}"
       puts "Output     Latitude Longitude: #{"%12.9f"%latitude}, #{"%12.9f"%longitude}"
       puts "Output NZTM easting, northing: #{"%12.3f"%r_easting}, #{"%12.3f"%r_northing}"
       puts "Difference:                    #{"%12.3f"%(easting - r_easting)}, #{"%12.3f"%(northing - r_northing)}"
       puts
     end
  end
end


