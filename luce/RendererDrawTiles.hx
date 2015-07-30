package luce;

import openfl.display.Graphics;
import openfl.display.Tilesheet;

class RendererDrawTiles implements Batch.BatchRenderer {
	static inline public var RENDER_FLAGS = #if batch_minimal 0 #else Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA #end;
	public var graphics(default,null): Graphics;
	public var smooth: Bool = true;

	public function new( graphics: Graphics ) {
		this.graphics = graphics;
	}

	public inline function clear() {
		graphics.clear();
	}

	public inline function render( batch: Batch ) {
		batch.atlas.tilesheet.drawTiles( graphics, batch.renderList, smooth, RENDER_FLAGS );
	}	
}
