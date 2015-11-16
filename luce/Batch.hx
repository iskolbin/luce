package luce;

import haxe.ds.Vector;

class Batch {
	static public inline var WGT_SIZE = 3;
	
	public var namedWidgets(default,null) = new Map<String,Widget>();
	public var renderList(default,null) = new Array<Float>();
	public var pointableList(default,null) = new List<Widget>();
	public var pointableSet(default,null) = new Map<Int,Bool>();
	public var atlas(default,null): Atlas;	
	public var dirty = true;
	public var centerX(default,null): Float = 0;
	public var centerY(default,null): Float = 0;
	public var count(default,null): Int = 0;
	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	public var scissorRect(default,null): Array<Float>;

	public function setCenter( x: Float, y: Float ) {
		for ( id in 0...count ) {
			renderList[id*WGT_SIZE] += ( x - centerX );
			renderList[id*WGT_SIZE+1] += ( y - centerY );
		}
		centerX = x;
		centerY = y;
		dirty = true;
	}

	public function new( atlas: Atlas, scissorRect: Array<Float>  ) {
		this.atlas = atlas;
		this.scissorRect = scissorRect;	
	}

	public inline function newWidget( args: Widget.WidgetConfig ) {
		var shift = renderList.length;

		for ( i in 0...WGT_SIZE ) {
			renderList.push( 0 );
		}
			
		var wgt: Widget = if ( args.text != null ) {
			new Text( this, shift, args );
		} else if ( args.grid != null ) {
			new Grid( this, shift, args );
		} else {
			new Widget( this, shift, args );
		}

		if ( wgt.pointable ) {
			pointableList.push( wgt );
		}

		if ( args != null && args.name != null ) {
			namedWidgets[args.name] = wgt;
		}
		
		count++;

		return wgt;
	}

	public function newText( args: Widget.WidgetConfig ): Text {
		if ( args.text == null ) throw ".text field needed for creating text";
		return cast newWidget( args );
	}
	
	public function newGrid( args: Widget.WidgetConfig ): Grid {
		if ( args.grid == null ) throw ".grid field needed for creating grid";
		return cast newWidget( args );
	}

	public inline function getX( shift: Int )     return renderList[shift] - centerX;
	public inline function getY( shift: Int )     return renderList[shift+1] - centerY;
	public inline function getCX( shift: Int )    return renderList[shift];
	public inline function getCY( shift: Int )    return renderList[shift+1];
	public inline function getFrame( shift: Int ) return renderList[shift+2];

	public inline function setX( shift: Int, v: Float )     setRList( shift, 0, v + centerX);
	public inline function setY( shift: Int, v: Float )     setRList( shift, 1, v + centerY);
	public inline function setFrame( shift: Int, v: Float ) setRList( shift, 2, v); 

	inline function setRList( shift: Int, idx: Int, v: Float ) {
		if ( renderList[shift+idx] != v ) {
			renderList[shift+idx] = v;
			dirty = true;	
		}
	}

	public function render() {
		if ( !dirty ) return;
		dirty = false;
	}

	public function clear() {
		dirty = true;
	}

	public inline function getPointablesAt( x: Float, y: Float ) {
		// TODO: Spatial optimizations
		return pointableList;
	}

	public inline function addPointable( w: Widget ) {
		if ( !pointableSet.exists( w.shift )) {
			pointableList.push( w );
			pointableSet[w.shift] = true;
		}
	}

	public inline function removePointable( w: Widget ) {
		if ( pointableSet.exists( w.shift )) {
			pointableList.remove( w );
			pointableSet.remove( w.shift );
		}
	}

	public inline static var MOVE = 1;
	public inline static var UP = MOVE << 1;
	public inline static var DOWN = UP << 1;
	public inline static var CANCEL = DOWN << 1;
	public inline static var LEFT = CANCEL << 1;
	public inline static var RIGHT = LEFT << 1;
	public inline static var MIDDLE = RIGHT << 1;
	public inline static var WHEEL_UP = MIDDLE << 1;
	public inline static var WHEEL_DOWN = WHEEL_UP << 1;
	public inline static var TOUCH_1 = WHEEL_DOWN << 1;
	public inline static var TOUCH_2 = TOUCH_1 << 1;
	public inline static var TOUCH_3 = TOUCH_2 << 1;
	public inline static var TOUCH_4 = TOUCH_3 << 1;
	public inline static var TOUCH_5 = TOUCH_4 << 1;
	public inline static var TOUCH_6 = TOUCH_5 << 1;
	public inline static var TOUCH_7 = TOUCH_6 << 1;
	public inline static var TOUCH_8 = TOUCH_7 << 1;
	public inline static var TOUCH_9 = TOUCH_8 << 1;
	public inline static var TOUCH_10 = TOUCH_9 << 1;
	
	public inline function onPointer( x: Float, y: Float, msg: Int ) {
		for ( w in getPointablesAt( x, y )) {
			if ( w.pointInside( x, y )) {
				if ( w.visible ) {
					if (!w.onPointer( w, x, y, msg )) {
						break;
					}
				}
			}
		}
	}

	public function cacheGlyphs( name: String, path: String, chars: String ) {
		var framesList = new Array<Float>();
		var mapping  = new Map<Int,Float>();
		var prd = ~/%./;
		for ( i in 0...chars.length ) {
			var id = atlas.ids[ prd.replace( path, Std.string( chars.charCodeAt( i ))) ];
			mapping[chars.charCodeAt( i )] = framesList.length;
			framesList.push( id );
		}

		glyphsCache[name] = framesList; 
		mappingsCache[name] = mapping;
	}

	public function newFramesList( frames: Array<String> ): Array<Float> {
		return [ for ( f in frames )  (atlas.ids[f] != null ? atlas.ids[f] : Atlas.NULL) ];
	}

	public inline function byName( name: String ) {
		return namedWidgets[name];
	}
}
