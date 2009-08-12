/**
 * -----------------------------------------------------------------------
 * OSGBLLHelper - Alistair Rutherford, www.netthreads.co.uk, Nov 2007.
 * Glasgow, Scotland, UK.
 * 
 * Actionscript3 version of OSGB Latitude/Longitude conversions.
 * 
 * -----------------------------------------------------------------------
 * This is based on the original C-code version from Chuck Ganz. Here:
 * 
 * http://www.bangor.ac.uk/is/iss025/ganzc.zip
 * 
 * -----------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * -----------------------------------------------------------------------
 */
package osgb
{
    public class OSGBLLHelper
    {
        private static var _instance:OSGBLLHelper = null;
        
        // ------------------------------------------------------------------------
        // Math Constants
        // ------------------------------------------------------------------------
        private static var PI:Number = 3.14159265;
        private static var FOURTHPI:Number = PI / 4;
        private static var DEG2RAD:Number = PI / 180;
        private static var rad2deg:Number = 180.0 / PI;
        
        // ------------------------------------------------------------------------
        // Results
        // ------------------------------------------------------------------------
        public var latitude:Number = 0.0
        public var longitude:Number = 0.0
        public var easting:Number  = 0.0
        public var northing:Number  = 0.0
        public var osgbEasting:Number  = 0.0
        public var osgbNorthing:Number  = 0.0
        public var osgbGridSquare:String = "";

        // ------------------------------------------------------------------------
        // Working vars
        // ------------------------------------------------------------------------
        private var refEasting:Number  = 0.0;        
        private var refNorthing:Number  = 0.0;        

        /**
         * Singleton access to helper
         * 
         */
        public static function getInstance():OSGBLLHelper
        {
            if (_instance==null)
            {
                _instance = new OSGBLLHelper()
            }
            
            return _instance;
        } 
        
         /**
          * This function creates refEasting and refNorthing used in 
          * conversion function.
          * 
          * @param osgbGridSquare String OSGB grid reference characters
          * 
          */
        private function osgbSquareToRefCoords(osgbGridSquare:String):void
        {
            var pos:Number = 0;
            var x_multiplier:Number = 0;
            var y_multiplier:Number = 0;
    
            var gridSquare:String = "VWXYZQRSTULMNOPFGHJKABCDE";
            
            // find 500km offset
            var ch:String = osgbGridSquare.charAt(0);
            
            if (ch== 'S')
            {
                x_multiplier = 0;
                y_multiplier = 0;
            }
            else if (ch == 'T')
            {
                x_multiplier = 1;
                y_multiplier = 0;
            }
            else if (ch == 'N')
            { 
                x_multiplier = 0;
                y_multiplier = 1;
            }
            else if (ch == 'O')
            { 
                x_multiplier = 1;
                y_multiplier = 1;
            }
            else if (ch == 'H')
            { 
                x_multiplier = 0;
                y_multiplier = 2;
            }
            else if (ch == 'J')
            { 
                x_multiplier = 1;
                y_multiplier = 2;
            }
            
            refEasting = x_multiplier * 500000;
            refNorthing = y_multiplier * 500000;
            
            // find 100km offset and add to 500km offset to get coordinate of 
            // square point is in
            var index:Number = gridSquare.indexOf(osgbGridSquare.charAt(1));
            
            refEasting += ((index % 5) * 100000);
            refNorthing += ((index / 5) * 100000);
            
        }
                
        /**
        *  osgbToLL - Convert the OSGR36 grid ref value to WGS84-like lat and long
        */ 
        public function osgbToLL(osgbZone:String, osbgEasting:Number, osgbNorthing:Number):void
        {
            // Converts OSGB coords to lat/long.  Equations from USGS Bulletin 1532 
            // East Longitudes are positive, West longitudes are negative. 
            // North latitudes are positive, South latitudes are negative
            // Lat and Long are in decimal degrees. 
    
            var k0:Number = 0.9996012717
            var a:Number = 0.0
            var eccPrimeSquared:Number = 0.0
            var N1:Number = 0.0
            var T1:Number = 0.0
            var C1:Number = 0.0
            var R1:Number = 0.0
            var D:Number = 0.0
            var M:Number = 0.0
            var LongOrigin:Number = -2.0
            var LatOrigin:Number = 49.0
            
            var LatOriginRad:Number = LatOrigin * DEG2RAD
            
            var mu:Number = 0.0
            var phi1:Number = 0.0
            var phi1Rad:Number = 0.0
            var x:Number = 0.0
            var y:Number = 0.0
            
            var majoraxis:Number = a = 6377563.396 //  Airy
            var minoraxis:Number = 6356256.91 // Airy
            
            var eccSquared:Number = (majoraxis * majoraxis - minoraxis * minoraxis) / (majoraxis * majoraxis);
            var e1:Number = (1-Math.sqrt(1-eccSquared))/(1+Math.sqrt(1-eccSquared));
    
            // Only calculate M0 once since it is based on the origin of the OSGB projection, which is fixed
            var M0:Number = a*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64 - 5*eccSquared*eccSquared*eccSquared/256)*LatOriginRad 
                    - (3*eccSquared/8 + 3*eccSquared*eccSquared/32 + 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(2*LatOriginRad) 
                    + (15*eccSquared*eccSquared/256 + 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(4*LatOriginRad) 
                    - (35*eccSquared*eccSquared*eccSquared/3072)*Math.sin(6*LatOriginRad));
    
            // Calculate refEasting and refNorthing
            osgbSquareToRefCoords(osgbZone);
            
            x = osbgEasting - 400000.0 + refEasting; //  remove 400,000 meter false easing for longitude
            y = osgbNorthing + 100000.0 + refNorthing; // remove 100,000 meter false easing for longitude
            
            eccPrimeSquared = (eccSquared)/(1-eccSquared);
            
            M = M0 + y / k0;
            mu = M/(a*(1-eccSquared/4-3*eccSquared*eccSquared/64-5*eccSquared*eccSquared*eccSquared/256));
            
            phi1Rad = mu    + (3*e1/2-27*e1*e1*e1/32)*Math.sin(2*mu) 
                    + (21*e1*e1/16-55*e1*e1*e1*e1/32)*Math.sin(4*mu) 
                    +(151*e1*e1*e1/96)*Math.sin(6*mu); 
                    
            phi1 = phi1Rad*rad2deg;
            
            N1 = a/Math.sqrt(1-eccSquared*Math.sin(phi1Rad)*Math.sin(phi1Rad));
            T1 = Math.tan(phi1Rad)*Math.tan(phi1Rad);
            C1 = eccPrimeSquared*Math.cos(phi1Rad)*Math.cos(phi1Rad);
            R1 = a*(1-eccSquared)/Math.pow(1-eccSquared*Math.sin(phi1Rad)*Math.sin(phi1Rad), 1.5);
            D = x/(N1*k0);
            
            latitude = phi1Rad - (N1*Math.tan(phi1Rad)/R1)*(D*D/2-(5+3*T1+10*C1-4*C1*C1-9*eccPrimeSquared)*D*D*D*D/24 
                    +(61+90*T1+298*C1+45*T1*T1-252*eccPrimeSquared-3*C1*C1)*D*D*D*D*D*D/720);
            latitude = latitude * rad2deg;
            
            longitude = (D-(1+2*T1+C1)*D*D*D/6+(5-2*C1+28*T1-3*C1*C1+8*eccPrimeSquared+24*T1*T1) 
                    *D*D*D*D*D/120)/Math.cos(phi1Rad);
            longitude = LongOrigin + longitude * rad2deg;
            
        }

        /**
         * llToOSGB - convert WGS84 to OSGB
         *
         */
        public function llToOSGB(lat:Number, lng:Number):void
        {
            // Converts lat/long to OSGB coords.  Equations from USGS Bulletin 1532 
            // East Longitudes are positive, West longitudes are negative. 
            // North latitudes are positive, South latitudes are negative
            // Lat and Long are in decimal degrees
            // Written by Chuck Gantz- chuck.gantz@globalstar.com
            
            var a:Number;
            var eccSquared:Number;
            var k0:Number = 0.9996012717;
            
            var LongOrigin:Number = -2;
            var LongOriginRad:Number = LongOrigin * DEG2RAD;
            var LatOrigin:Number = 49;
            var LatOriginRad:Number = LatOrigin * DEG2RAD;
            var eccPrimeSquared:Number;
            var N:Number;
            var T:Number;
            var C:Number;
            var A:Number;
            var M:Number;
            
            var LatRad:Number =lat*DEG2RAD;
            var LongRad:Number = lng*DEG2RAD;
            
            var majoraxis:Number = a = 6377563.396;//Airy
            var minoraxis:Number = 6356256.91;//Airy
            
            eccSquared = (majoraxis * majoraxis - minoraxis * minoraxis) / (majoraxis * majoraxis);
            
            // only calculate M0 once since it is based on the origin 
            // of the OSGB projection, which is fixed
            var M0:Number = a*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64 - 5*eccSquared*eccSquared*eccSquared/256)*LatOriginRad - (3*eccSquared/8+ 3*eccSquared*eccSquared/32+ 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(2*LatOriginRad) + (15*eccSquared*eccSquared/256 + 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(4*LatOriginRad) - (35*eccSquared*eccSquared*eccSquared/3072)*Math.sin(6*LatOriginRad));
            
            eccPrimeSquared = (eccSquared)/(1-eccSquared);
            
            N = a/Math.sqrt(1-eccSquared*Math.sin(LatRad)*Math.sin(LatRad));
            T = Math.tan(LatRad)*Math.tan(LatRad);
            C = eccPrimeSquared*Math.cos(LatRad)*Math.cos(LatRad);
            A = Math.cos(LatRad)*(LongRad-LongOriginRad);
            
            M = a*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64 - 5*eccSquared*eccSquared*eccSquared/256)*LatRad - (3*eccSquared/8 + 3*eccSquared*eccSquared/32 + 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(2*LatRad) + (15*eccSquared*eccSquared/256 + 45*eccSquared*eccSquared*eccSquared/1024)*Math.sin(4*LatRad) - (35*eccSquared*eccSquared*eccSquared/3072)*Math.sin(6*LatRad));
            
            easting = (k0*N*(A+(1-T+C)*A*A*A/6 + (5-18*T+T*T+72*C-58*eccPrimeSquared)*A*A*A*A*A/120));
            easting += 400000.0; //false easting
            
            northing = (k0*(M-M0+N*Math.tan(LatRad)*(A*A/2+(5-T+9*C+4*C*C)*A*A*A*A/24 + (61-58*T+T*T+600*C-330*eccPrimeSquared)*A*A*A*A*A*A/720)));
            northing -= 100000.0;//false northing
            
            this.coordsToOSGBSquare(easting, northing);
        }
        
        public function coordsToOSGBSquare(easting:Number, northing:Number):void
        {
            var GridSquare:String = "VWXYZQRSTULMNOPFGHJKABCDE";
            var posx:Number; //positions in grid
            var posy:Number; 
            
            this.osgbEasting = (easting + 0.5); //round to nearest int
            this.osgbNorthing = (northing + 0.5); //round to nearest int
            
            //find correct 500km square
            posx = this.osgbEasting / 500000;
            posy = this.osgbNorthing / 500000;
            
            this.osgbGridSquare += GridSquare.charAt(trunc(posx) + trunc(posy) * 5 + 7);
            
            //find correct 100km square
            posx = this.osgbEasting % 500000; //remove 500 km square
            posy = this.osgbNorthing % 500000; //remove 500 km square
            posx = posx / 100000; //find 100 km square
            posy = posy / 100000; //find 100 km square
            this.osgbGridSquare += GridSquare.charAt(trunc(posx) + trunc(posy) * 5);
            
            //remainder is northing and easting
            this.osgbNorthing = this.osgbNorthing % 500000; 
            this.osgbNorthing = trunc(this.osgbNorthing % 100000);
            
            this.osgbEasting = this.osgbEasting % 500000;
            this.osgbEasting = trunc(this.osgbEasting % 100000);
        }
         
        private function trunc(val:Number):Number
        {
            if (val < 0)
                return -(Math.floor(Math.abs(val)));
            else
                return Math.floor(Math.abs(val));
        } 
        
    }
}