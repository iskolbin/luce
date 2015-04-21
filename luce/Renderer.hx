package luce;

import openfl.display.Graphics;
import openfl.display.Tilesheet;

class Renderer {
	static inline public var RENDER_FLAGS = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA;
	public static var smooth: Bool = true;

	public inline static function render( graphics: Graphics,	scene: Scene ) {
#if !renderer_no_clear 
		graphics.clear(); 
#end
		scene.atlas.tilesheet.drawTiles( graphics, scene.renderList, smooth #if !batch_minimal ,RENDER_FLAGS #end );
	}	
}
