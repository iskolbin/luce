package luce;

import openfl.display.Graphics;
import openfl.display.Tilesheet;

class RendererDrawTiles implements Batch.BatchRenderer {
#if batch_minimal
	static inline public var RENDER_FLAGS = 0;
#else
	static inline public var RENDER_FLAGS = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA;
#end
	public var graphics(default,null): Graphics;
	public var smooth: Bool = true;

	public function new( graphics: Graphics ) {
		this.graphics = graphics;
	}

	public inline function render( batch: Batch ) {
#if !renderer_no_clear 
		graphics.clear(); 
#end
		batch.atlas.tilesheet.drawTiles( graphics, batch.renderList, smooth, RENDER_FLAGS );
	}	
}
