package luce;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class RendererCopyPixels implements Batch.BatchRenderer {
	var auxPoint = new Point( 0, 0 );
	var zeroPoint = new Point( 0, 0 );
	var auxRect = new Rectangle( 0, 0, 0, 0 );
	public var buffer(default,null): BitmapData = null;

	public function new( buffer: BitmapData ) {
		this.buffer = buffer;
	}

	public inline function clear() {
		buffer.fillRect( buffer.rect, 0 );
	}

	public inline function render( batch: Batch ) {
		var shift = 0;
		
		for ( i in 0...batch.count) {
			var id_ = batch.getFrame(shift);
			if ( id_ != Atlas.NULL ) {
				var id = Std.int( id_ );
				var c = batch.atlas.centers[id];
				var rect = batch.atlas.rects[id];
				var xmin = batch.getCX( shift ) - c.x;
				var ymin = batch.getCY( shift ) - c.y;
				var xmax = xmin + rect.width;
				var ymax = ymin + rect.height;
				auxPoint.x = xmin;
				auxPoint.y = ymin;
				if ( xmin >= 0 && ymin >= 0 && xmax < buffer.width && ymax < buffer.height ) {
					buffer.copyPixels( batch.atlas.bitmapData, rect, auxPoint, null, zeroPoint, true);							
				} else {
					if ( xmin < buffer.width && xmax >= 0 && ymin < buffer.height && ymax >= 0 ) {
						auxRect.x = rect.x;
						auxRect.y = rect.y;
						auxRect.width = rect.width;
						auxRect.height = rect.height;

						if ( xmin < 0 ) {
							auxPoint.x = 0;
							auxRect.x -= xmin;
							auxRect.width += xmin;
						}
					
						if ( ymin < 0 ) {
							auxPoint.y = 0;
							auxRect.y -= ymin;
							auxRect.height += ymin;
						} 
						
						if ( xmax >= buffer.width ) {
							auxRect.width -= ( xmax - buffer.width + 1 );
						} 
						
						if ( ymax >= buffer.height ) {
							auxRect.height -= ( ymax - buffer.height + 1 ); 
						}
						
						buffer.copyPixels( batch.atlas.bitmapData, auxRect, auxPoint, null, zeroPoint, true );
					}
				}
			}
			shift += Batch.WGT_SIZE;
		}
	}
}
