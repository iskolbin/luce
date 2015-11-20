package luce.backend.openfl;

import luce.Batch;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class OpenFlBatchCopyPixels extends OpenFlMinimalBatch {
	var auxPoint = new Point( 0, 0 );
	var zeroPoint = new Point( 0, 0 );
	var auxRect = new Rectangle( 0, 0, 0, 0 );
	public var buffer(default,null): BitmapData = null;

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, buffer: BitmapData ) {
		super( atlas, scissorRect );
		this.buffer = buffer;
	}

	override public inline function clear() {
		dirty = true;
		this.buffer.fillRect( buffer.rect, 0 );
	}

	override public inline function render() {
		if ( this.dirty ) {
			this.dirty = false;
			var sxmin: Float = 0.0;
			var symin: Float = 0.0;
			var sxmax: Float = buffer.width;
			var symax: Float = buffer.height;
			if ( scissorRect != null ) {
				sxmin = scissorRect[0];
				sxmax = scissorRect[2];
				symin = scissorRect[1];
				symax = scissorRect[3];
			}
			var shift = -OpenFlMinimalBatch.WGT_SIZE;
			for ( i in 0...this.count) {
				shift += OpenFlMinimalBatch.WGT_SIZE;
				var id_ = this.getFrame(shift);
				if ( id_ != Atlas.NULL ) {
					var id = Std.int( id_ );
					var c = this.atlasFl.centersFl[id];
					var rect = this.atlasFl.rectsFl[id];
					var xmin = this.getCX( shift ) - c.x;
					var ymin = this.getCY( shift ) - c.y;
					var xmax = xmin + rect.width;
					var ymax = ymin + rect.height;
					auxPoint.x = xmin;
					auxPoint.y = ymin;
					if ( xmin >= 0 && ymin >= 0 && xmax < sxmax && ymax < symax ) {
						this.buffer.copyPixels( this.atlasFl.bitmapData, rect, this.auxPoint, null, this.zeroPoint, true);							
					} else {
						if ( xmin < sxmax && xmax >= 0 && ymin < symax && ymax >= 0 ) {
							this.auxRect.x = rect.x;
							this.auxRect.width = rect.width;

							if ( xmin < 0.0 ) {
								this.auxPoint.x = 0;
								this.auxRect.x -= xmin;
								this.auxRect.width += xmin;
							}
						
							if ( xmax >= sxmax ) {
								this.auxRect.width -= ( xmax - sxmax + 1 );
							} 
								
							if ( this.auxRect.width >= 1.0 ) {
								this.auxRect.y = rect.y;
								this.auxRect.height = rect.height;
							
								if ( ymin < symin ) {
									this.auxPoint.y = 0.0;
									this.auxRect.y -= ymin;
									this.auxRect.height += ymin;
								}
							
								if ( ymax >= symax ) {
									this.auxRect.height -= ( ymax - symax + 1 ); 
								}
							
								if ( this.auxRect.height >= 1.0 ) {
									this.buffer.copyPixels( this.atlasFl.bitmapData, this.auxRect, this.auxPoint, null, this.zeroPoint, true );
								}
							}
						}
					}
				}
			}
		}
	}
}
