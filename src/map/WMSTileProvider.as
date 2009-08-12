/**
 * -----------------------------------------------------------------------
 * WMS Custom Tile Provider for UMap
 * -----------------------------------------------------------------------
 */
package map
{
    import com.afcomponents.umap.providers.DefaultProvider;
    
    /**
     * WMSTileProvider custom class.
     * 
     */
    public class WMSTileProvider extends DefaultProvider
    {
        private var copyright:String = "unknown";
        
        public function WMSTileProvider(copyright:String=null)
        {
            this.copyright = copyright;
        }
        
        override public function getDefaultCopyright():String
        {
            return copyright;
        }
    }
}