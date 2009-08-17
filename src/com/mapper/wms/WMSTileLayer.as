/**
 * -----------------------------------------------------------------------
 * WMS Tile Layer for UMap
 * -----------------------------------------------------------------------
 * Original is loosely based on WMS Example posted by (jatorre) on UMap forums.
 * -----------------------------------------------------------------------
 */ 
package com.mapper.wms
{
   import com.afcomponents.umap.providers.TileLayer;
   import osgb.OSGBLLHelper;
   
   import flash.geom.Point;
   
    /**
     * Custom Tile provider - WMS Tile layer
     * 
     */
    public class WMSTileLayer extends TileLayer
    {
        //Needed for transformations
        private var offset:Number = 16777216;
        private var radius:Number = offset / Math.PI;
        
        /**
        * WMS Custom tile layer constructor.
        * 
        * @param baseServerUrl
        * @param layers
        * @param format
        * @param styles
        * @param filters
        */
        public function WMSTileLayer(baseServerUrl:String, layers:String, format:String, styles:String, 
                                                             filter:String, service:String = "WMS", 
                                                             request:String = "getMap", version:String = "1.1.1", 
                                                             width:String="256", height:String = "256")
        {
            // http://localhost:8080/geoserver/wms?styles=&Format=application/openlayers&request=GetMap&version=1.1.1&layers=mottmac:RoadClass2-E2&width=800&height=375&srs=EPSG:4326
            //construct the base URL
            var urlBase:String = baseServerUrl + "?" +
                "WMS=WorldMap" + "&" +
                "LAYERS="+ layers + "&" +
                "FORMAT="+format + "&" +
                "STYLES=" + styles + "&" +
                "SERVICE=" + service + "&" +
                "REQUEST=" + request + "&" +
                "VERSION=" + version + "&" +
                "FILTER="+ filter + "&" +
                "WIDTH="+ width + "&" +
                "HEIGHT=" + height + "&";
            
            super("[server]", 0, 17, true, "");
            
            this.addServer(urlBase);
            this.addServer(urlBase);
            this.addServer(urlBase);
            this.addServer(urlBase);
            
            trace("urlBase: "+ urlBase);
        }
        
        /**
        * Return target Tile URL for specified point and zoom level.
        * 
        * @param The tile position.
        * @param The zoom level for target tile.
        * 
        */
        override public function getTileURL(tile:Point, zoom:uint):String
        {
            //Adjust the zoom level from the new to the old, as the server side tiles depend on the old one.
            var zoomLevel:Number = 17 - zoom;
            
            // LowerLeft Corner
            var tileIndexLL:Point = new Point(256*tile.x, 256*(tile.y+1));

            // UpperRight Corner
            var tileIndexUR:Point = new Point(256*(tile.x+1), 256*(tile.y));
            
            var lngLL:Number = XToL(zoomLevel,tileIndexLL.x);
            var latLL:Number = YToL(zoomLevel,tileIndexLL.y);
            
            var lngUR:Number = XToL(zoomLevel,tileIndexUR.x);
            var latUR:Number = YToL(zoomLevel,tileIndexUR.y);

            // trace(lngLL, latLL, lngUR, latUR);
            
            var SRS:String = "EPSG:4326";
            
            var url:String = "[server]SRS="+SRS+"&BBOX=" + 
                             lngLL + "," + 
                             latLL + "," + 
                             lngUR + "," + 
                             latUR;
            
            trace(url);
            
            return url; 
        }
        
        //TRANSFORMATION EQUATIONS FROM PIXEL TO LATLON
        private function LToX(z:Number,x:Number):Number
        {
            return (offset+radius*x*Math.PI/180)>>z;
        }
        
        private function LToY(z:Number,y:Number):Number
        {
            return (offset-radius*Math.log((1+Math.sin(y*Math.PI/180))/(1-Math.sin(y*Math.PI/180)))/2)>>z;
        }
        
        private function XToL(z:Number,x:Number):Number
        {
            return (((x<<z)-offset)/radius)*180/Math.PI;
        }
        
        private function YToL(z:Number,y:Number):Number
        {
            return (Math.PI/2-2*Math.atan(Math.exp(((y<<z)-offset)/radius)))*180/Math.PI;
        }
        
    }

} 