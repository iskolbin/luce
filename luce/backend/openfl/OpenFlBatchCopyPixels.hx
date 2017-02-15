package luce.backend.openfl;

#if openfl
import luce.Batch;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class OpenFlBatchCopyPixels extends OpenFlMinimalBatch {
	var auxPoint = new Point( 0, 0 );
	var zeroPoint = new Point( 0, 0 );
	var auxRect = new Rectangle( 0, 0, 0, 0 );
	public var buffer(default,null): BitmapData;
	public var proxy(default,null): Bitmap;

	override public inline function set_smoothing( v ) {
		proxy.smoothing = v;
		return super.set_smoothing( v );
	}

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, parent: Sprite, ?prevProxy: Bitmap ) {
		super( atlas, scissorRect, parent );
		if ( prevProxy != null ) {
			proxy = prevProxy;
			buffer = prevProxy.bitmapData;
		} else {
			if ( scissorRect != null ) {
				var width = scissorRect[2] - scissorRect[0];
				var height = scissorRect[3] - scissorRect[1];
				buffer = new BitmapData( Std.int(width), Std.int(height), false, 0 );
			} else if ( parent.stage != null ) {
				buffer = new BitmapData( parent.stage.stageWidth, parent.stage.stageHeight, false, 0 );
			} else {
				throw "Specify scissorRect";
			}
			proxy = new Bitmap( buffer );
			proxy.smoothing = true;
			parent.addChild( proxy );
		}
	}

	override public inline function clear() {
		dirty = true;
		this.buffer.fillRect( buffer.rect, 0 );
	}

	override public inline function render() {
		if ( this.dirty ) {
			var auxPoint = this.auxPoint;
			var zeroPoint = this.zeroPoint;
			var auxRect = this.auxRect;
			var buffer = this.buffer;
			this.dirty = false;
			var bw = buffer.width;
			var bh = buffer.height;
			var sxmin: Float = 0.0;
			var symin: Float = 0.0;
			var sxmax: Float = bw;
			var symax: Float = bh;
			if ( scissorRect != null ) {
				sxmin = scissorRect[0] + 0.5*bw;
				sxmax = scissorRect[2] + 0.5*bw;
				symin = scissorRect[1] + 0.5*bh;
				symax = scissorRect[3] + 0.5*bh;
			}
			var shift = -OpenFlMinimalBatch.WGT_SIZE;
			var centers = atlasFl.centersFl;
			var rects = atlasFl.rectsFl;
			var bitmapData = atlasFl.bitmapData;
			for ( i in 0...this.count) {
				shift += OpenFlMinimalBatch.WGT_SIZE;
				var id_ = this.getFrame(i);
				if ( id_ != Atlas.NULL ) {
					var id = Std.int( id_ );
					var c = centers[id];
					var rect = rects[id];
					var xmin = this.getCX( i ) - c.x;
					var ymin = this.getCY( i ) - c.y;
					var xmax = xmin + rect.width;
					var ymax = ymin + rect.height;
					auxPoint.x = xmin;
					auxPoint.y = ymin;
					if ( xmin >= 0 && ymin >= 0 && xmax < sxmax && ymax < symax ) {
						buffer.copyPixels( bitmapData, rect, auxPoint, null, zeroPoint, true);							
					} else {
						if ( xmin < sxmax && xmax >= 0 && ymin < symax && ymax >= 0 ) {
							auxRect.x = rect.x;
							auxRect.width = rect.width;

							if ( xmin < 0.0 ) {
								auxPoint.x = 0;
								auxRect.x -= xmin;
								auxRect.width += xmin;
							}
						
							if ( xmax >= sxmax ) {
								auxRect.width -= ( xmax - sxmax + 1 );
							} 
								
							if ( auxRect.width >= 1.0 ) {
								auxRect.y = rect.y;
								auxRect.height = rect.height;
							
								if ( ymin < symin ) {
									auxPoint.y = 0.0;
									auxRect.y -= ymin;
									auxRect.height += ymin;
								}
							
								if ( ymax >= symax ) {
									auxRect.height -= ( ymax - symax + 1 ); 
								}
							
								if ( auxRect.height >= 1.0 ) {
									buffer.copyPixels( bitmapData, auxRect, auxPoint, null, zeroPoint, true );
								}
							}
						}
					}
				}
			}
		}
	}
}
#end
