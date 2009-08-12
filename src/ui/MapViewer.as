package ui
{
	import com.afcomponents.umap.core.UMap;
	import com.afcomponents.umap.gui.MapTypeControl;
	import com.afcomponents.umap.gui.ZoomControl;
	import com.afcomponents.umap.providers.MapType;
	
	import map.WMSTileLayer;
	import map.WMSTileProvider;
	
	import mx.core.UIComponent;
	
	public class MapViewer extends UIComponent
	{
		[Bindable]
		private var map:UMap;
		
		override protected function createChildren():void {
			super.createChildren();
			if (!map) {				
				map = new UMap();	
				
				map.setSize(this.width, this.height);	
				
				/*var provider:WMSTileProvider = new WMSTileProvider();
						
				var mapType:MapType = new MapType("test", 0x0, 0xFF0000, "OS", "uhoh");						
						
				mapType.addLayer(new WMSTileLayer("http://localhost:8080/geoserver/wms", "bcip_raster", "", "", ""));
				mapType.addLayer(new WMSTileLayer("http://localhost:8080/geoserver/wms", "bcip_vector", "", "", ""));									

				provider.addMapType(mapType);

				map.setProvider(provider);																		
						
				map.setMapType("test");		
				
				map.addControl(new MapTypeControl());
				map.addControl(new ZoomControl());*/
				
				addChild(map);
			}
		}

	}
}