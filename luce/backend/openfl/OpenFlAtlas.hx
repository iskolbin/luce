package luce.backend.openfl;

import luce.Atlas;
import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

class OpenFlAtlas extends Atlas {
	public var tilesheet(default,null): Tilesheet;
	public var bitmapData(default,null): BitmapData;
	public var rectsFl(default,null) = new Array<Rectangle>();
	public var centersFl(default,null) = new Array<Point>();

	override function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float, srcW: Float, srcH: Float ) {
		super.addFrame( key, x, y, w, h, cx, cy, srcW, srcH );
		var rect = new Rectangle( x, y, w, h );
		var center = new Point( cx, cy );
		rectsFl.push( rect );
		centersFl.push( center );
		tilesheet.addTileRect( rect, center );
	}

	public function new( bitmapData: BitmapData ) {
		this.bitmapData = bitmapData;
		this.tilesheet = new Tilesheet( bitmapData );
		super();
	}
}
