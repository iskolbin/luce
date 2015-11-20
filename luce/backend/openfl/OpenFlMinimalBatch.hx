package luce.backend.openfl;

import luce.Batch;
import luce.Widget;

class OpenFlMinimalBatch extends Batch {
	public var atlasFl: OpenFlAtlas;
	public var renderList(default,null) = new Array<Float>();
	
	static public inline var WGT_SIZE = 3;
	
	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float> ) {
		super( atlas, scissorRect );
		this.atlasFl = atlas;	
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

	inline function attrIdx( index: Int, attr: Int ) return (index<<1)+index+attr;
	
	override public function getX( index: Int )     return getRList( index, 0 ) - centerX;
	override public function getY( index: Int )     return getRList( index, 1	) - centerY;
	public function getCX( index: Int )    return getRList( index, 0 );
	public function getCY( index: Int )    return getRList( index, 1	);
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
}
