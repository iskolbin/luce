package luce;

import openfl.geom.Point;
import openfl.geom.Rect;
import openfl.display.BitmapData;

class RendererCopyPixelsCrop implements Batch.BatchRenderer {
	var auxPoint = new Point( 0, 0 );
	var zeroPoint = new Point( 0, 0 );
	var auxRect = new Rectangle( 0, 0, 0, 0 );
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
				var xmin = batch.getCX( shift ) - c.x;
				var ymin = batch.getCY( shift ) - c.y;
				var xmax = xmin + rect.width;
				var ymax = ymin + rect.height;
				var rect = batch.atlas.rects[id];
				auxPoint.x = xmin;
				auxPoint.y = ymin;
				if ( xmin >= 0 && ymin >= 0 && xmax < buffer.width && ymax < buffer.height ) {
					buffer.copyPixels( batch.atlas.bitmapData, rect, auxPoint, null, zeroPoint, true);							
				} else {
					auxRect.x = rect.x;
					auxRect.y = rect.y;
					auxRect.width = rect.width;
					auxRect.height = rect.height;
					if ( xmin < 0 ) {
						auxRect.x -= xmin;
						auxRect.width += xmin;
					} else if ( xmin >= buffer.width ) {
						continue;
					}
					if ( ymin < 0 ) {
						auxRect.y -= ymin;
						auxRect.height += ymin;
					} else if ( ymin >= buffer.height ) {
						continue;
					}
					if ( xmax >= buffer.width ) {
						auxRect.width -= ( xmax - buffer.width + 1 )
					} else if ( xmax < 0 ) {
						continue;
					}
					if ( ymax >= buffer.height ) {
						auxRect.height -= ( ymax - buffer.height + 1 ) 
					} else if ( ymax < 0 ) {
						continue;
					}
					buffer.copyPixels( batch.atlas.bitmapData, auxRect, auxPoint, null, zeroPoint, true );
				}
			}
			shift += Batch.WGT_SIZE;
		}
	}
}
