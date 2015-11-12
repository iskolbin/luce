package luce;

import openfl.display.Graphics;

class RendererDrawTiles implements Batch.BatchRenderer {
	public var graphics(default,null): Graphics;
	public var smooth: Bool = true;

	public function new( graphics: Graphics ) {
		this.graphics = graphics;
	}

	public inline function clear() {
		graphics.clear();
	}

	public inline function render( batch: Batch ) {
		batch.atlas.tilesheet.drawTiles( graphics, batch.renderList, smooth, 0 );	
	}	
}
