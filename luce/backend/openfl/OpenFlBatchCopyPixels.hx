package luce.backend.openfl;

import luce.Batch;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class OpenFlBatchCopyPixels extends Batch {
	var auxPoint = new Point( 0, 0 );
	var zeroPoint = new Point( 0, 0 );
	var auxRect = new Rectangle( 0, 0, 0, 0 );
	public var buffer(default,null): BitmapData = null;
	public var atlasFl(default,null): OpenFlAtlas;

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, buffer: BitmapData ) {
		super( atlas, scissorRect );
		this.atlasFl = atlas;
		this.buffer = buffer;
	}

	override public inline function clear() {
		dirty = true;
		this.buffer.fillRect( buffer.rect, 0 );
	}

	override public inline function render() {
		if ( this.dirty ) {
			this.dirty = false;
			var shift = -Batch.WGT_SIZE;
			for ( i in 0...this.count) {
				shift += Batch.WGT_SIZE;
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
					if ( xmin >= 0 && ymin >= 0 && xmax < buffer.width && ymax < buffer.height ) {
						this.buffer.copyPixels( this.atlasFl.bitmapData, rect, this.auxPoint, null, this.zeroPoint, true);							
					} else {
						if ( xmin < this.buffer.width && xmax >= 0 && ymin < this.buffer.height && ymax >= 0 ) {
							this.auxRect.x = rect.x;
							this.auxRect.width = rect.width;

							if ( xmin < 0.0 ) {
								this.auxPoint.x = 0;
								this.auxRect.x -= xmin;
								this.auxRect.width += xmin;
							}
						
							if ( xmax >= this.buffer.width ) {
								this.auxRect.width -= ( xmax - this.buffer.width + 1 );
							} 
								
							if ( this.auxRect.width >= 1.0 ) {
								this.auxRect.y = rect.y;
								this.auxRect.height = rect.height;
							
								if ( ymin < 0.0 ) {
									this.auxPoint.y = 0.0;
									this.auxRect.y -= ymin;
									this.auxRect.height += ymin;
								} 
							
								if ( ymax >= this.buffer.height ) {
									this.auxRect.height -= ( ymax - this.buffer.height + 1 ); 
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
