package luce.backend.openfl;

import luce.Batch;
import openfl.display.Graphics;

class OpenFlBatchDrawTiles extends OpenFlMinimalBatch {
	public var graphics(default,null): Graphics;
	public var smooth: Bool = true;

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, graphics: Graphics ) {
		super( atlas, scissorRect );
		this.graphics = graphics;
	}

	override public inline function clear() {
		this.graphics.clear();
	}

	override public inline function render() {
		this.atlasFl.tilesheet.drawTiles( this.graphics, this.renderList, this.smooth, 0 );	
	}	
}
