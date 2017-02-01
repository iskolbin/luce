package luce.backend.openfl;

#if openfl
#if (openfl < "4.0.0")
import luce.Batch;
import openfl.display.Graphics;
import openfl.display.Sprite;

class OpenFlBatchDrawTiles extends OpenFlMinimalBatch {
	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, parent: Sprite ) {
		super( atlas, scissorRect, parent );
	}

	override public inline function clear() {
		parent.graphics.clear();
	}

	override public inline function render() {
		atlasFl.tilesheet.drawTiles( parent.graphics, renderList, smoothing, 0 );	
	}	
}
#else
#error "openfl.display.Tilesheet is deprecated since OpenFl 4+, so drawTiles method is unusable"
#end
#end
