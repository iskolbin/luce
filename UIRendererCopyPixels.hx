import openfl.geom.Point;
import openfl.display.BitmapData;

class UIRendererCopyPixels implements UIBatch.BatchRenderer {
	var xy = new Array<Point>();
	var zeroPoint = new Point( 0, 0 );
	var buffer: BitmapData;

	public function new( buffer: BitmapData ) {
		this.buffer = buffer;
	}

	public inline function render( batch: UIBatch ) {
		var shift = 0;
		
		while ( xy.length < batch.count ) {
			xy.push( new Point( 0, 0 ));
		}
		
		for ( i in 0...batch.count) {
			var id_ = batch.getFrame(shift);
			if ( id_ != UIAtlas.NULL ) {
				var id = Std.int( id_ );
				var c = batch.atlas.centers[id];
				var rect = batch.atlas.rects[id];
				var p = xy[i];
				p.x = batch.getCX( shift ) - c.x;
				p.y = batch.getCY( shift ) - c.y;
				buffer.copyPixels( batch.atlas.bitmapData, rect, p, null, zeroPoint, true);																					
			}
			shift += UIBatch.WGT_SIZE;
		}
	}
}
