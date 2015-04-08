package luce;

import openfl.geom.Point;
import openfl.display.BitmapData;

class RendererCopyPixelsCrop implements Batch.BatchRenderer {
	var xy = new Array<Point>();
	var zeroPoint = new Point( 0, 0 );
	var buffer: BitmapData;

	public function new( buffer: BitmapData ) {
		this.buffer = buffer;
	}

	public inline function render( batch: Batch ) {
		var shift = 0;
		
		while ( xy.length < batch.count ) {
			xy.push( new Point( 0, 0 ));
		}
		
		for ( i in 0...batch.count) {
			var id_ = batch.getFrame(shift);
			if ( id_ != Atlas.NULL ) {
				var id = Std.int( id_ );
				var c = batch.atlas.centers[id];
				var x = batch.getCX( shift ) - c.x;
				var y = batch.getCY( shift ) - c.y;
				var rect = batch.atlas.rects[id];
				if ( x >= 0 && y >= 0 && x + rect.width < buffer.width && y + rect.height < buffer.height ) {
					var p = xy[i];

					p.x = batch.getCX( shift ) - c.x;
					p.y = batch.getCY( shift ) - c.y;

					buffer.copyPixels( batch.atlas.bitmapData, rect, p, null, zeroPoint, true);							}													
				}
			}
			shift += Batch.WGT_SIZE;
		}
	}
}
