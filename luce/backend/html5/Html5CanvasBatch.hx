package luce.backend.html5;

import luce.Batch;
import luce.Widget;
import luce.Atlas;

import js.html.CanvasRenderingContext2D;

class Html5CanvasBatch extends Batch {
	static public inline var WGT_SIZE = 3;
	
	public var atlasHtml5(default,null): Html5Atlas;
	public var context(default,null): CanvasRenderingContext2D;
	public var renderList(default,null): Array<Float>;

	public function new( atlas: Html5Atlas, scissorRect: Array<Float>, context: CanvasRenderingContext2D ) {
		super( atlas, scissorRect );
		this.atlasHtml5 = atlas;
		this.context = context;
		this.renderList = [];
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		for ( i in 0...WGT_SIZE ) {
			renderList.push( 0 );
		}

		return super.newWidget( args );
	}

	override public function setCenter( centerX: Float, centerY: Float ) {
		var wid = 0;
		for ( id in 0...count ) {
			renderList[wid] += ( centerX - this.centerX );
			renderList[wid+1] += ( centerY - this.centerY );
			wid += WGT_SIZE;
		}
		super.setCenter( centerX, centerY );
	}

	inline function attrIdx( index: Int, attr: Int ) return WGT_SIZE*index + attr;
	
	override public function getX( index: Int )     return getRList( index, 0 ) - centerX;
	override public function getY( index: Int )     return getRList( index, 1	) - centerY;
	public function getCX( index: Int )    return getRList( index, 0 );
	public function getCY( index: Int )    return getRList( index, 1 );
	override public function getFrame( index: Int ) return getRList( index, 2 );

	inline function getRList( index: Int, attr: Int ) return renderList[attrIdx( index, attr )];

	override public function setX( index: Int, v: Float )     setRList( index, 0, v + centerX);
	override public function setY( index: Int, v: Float )     setRList( index, 1, v + centerY);
	override public function setFrame( index: Int, v: Float ) setRList( index, 2, v); 

	inline function setRList( index: Int, attr: Int, v: Float ) {
		var aidx = attrIdx( index, attr );
		if ( renderList[aidx] != v ) {
			renderList[aidx] = v;
			dirty = true;	
		}
	}
	
	override public inline function clear() {
		this.dirty = true;
		context.clearRect( 0, 0, context.canvas.width, context.canvas.height );	
	}

	override public inline function render() {
		if ( this.dirty ) {
			this.dirty = false;
			var bw = context.canvas.width;
			var bh = context.canvas.height;
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
			var shift = -WGT_SIZE;
			for ( i in 0...this.count) {
				shift += WGT_SIZE;
				var id_ = renderList[shift+2];
				if ( id_ != Atlas.NULL ) {
					var id = Std.int( id_ );
					var c = this.atlas.centers[id];
					var rect = this.atlas.rects[id];
					var xmin = renderList[shift] - c[0];
					var ymin = renderList[shift+1] - c[1];
					var xmax = xmin + rect[2];
					var ymax = ymin + rect[3];
					var auxPointX = xmin;
					var auxPointY = ymin;
					var auxRectX = rect[0];
					var auxRectY = rect[1];
					var auxRectWidth = rect[2];
					var auxRectHeight = rect[3];
					if ( xmin >= 0 && ymin >= 0 && xmax < sxmax && ymax < symax ) {
						context.drawImage( atlasHtml5.image, auxRectX, auxRectY, auxRectWidth, auxRectHeight, auxPointX, auxPointY, auxRectWidth, auxRectHeight );
					} else {
						if ( xmin < sxmax && xmax >= 0 && ymin < symax && ymax >= 0 ) {
							if ( xmin < 0.0 ) {
								auxPointX = 0;
								auxRectX -= xmin;
								auxRectWidth += xmin;
							}

							if ( xmax >= sxmax ) {
								auxRectWidth -= ( xmax - sxmax + 1 );
							} 

							
							if ( auxRectWidth >= 1.0 ) {
								auxRectY = rect[1];
								auxRectHeight = rect[3];

								if ( ymin < symin ) {
									auxPointY = 0.0;
									auxRectY -= ymin;
									auxRectHeight += ymin;
								}

								if ( ymax >= symax ) {
									auxRectHeight -= ( ymax - symax + 1 ); 
								}

								if ( auxRectHeight >= 1.0 ) {
									context.drawImage( atlasHtml5.image, auxRectX, auxRectY, auxRectWidth, auxRectHeight, auxPointX, auxPointY, auxRectWidth, auxRectHeight );
								}
							}
						}
					}
				}
			}
		}
	}
}
