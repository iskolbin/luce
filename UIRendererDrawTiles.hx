import openfl.display.Graphics;
import openfl.display.Tilesheet;

class UIRendererDrawTiles implements UIBatch.BatchRenderer {
	static inline public var RENDER_FLAGS = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA;
	public var graphics(default,null): Graphics;
	public var smooth: Bool = true;

	public function new( graphics: Graphics ) {
		this.graphics = graphics;
	}

	public inline function render( batch: UIBatch ) {
		graphics.clear();
		batch.atlas.tilesheet.drawTiles( graphics, batch.renderList, smooth, RENDER_FLAGS );
	}	
}
