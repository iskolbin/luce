package luce;

// Compiler defs:
// 
// batch_minimal -- use only x, y, id for rendering

import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.geom.Point;
import de.polygonal.Printf;
import haxe.ds.Vector;

interface BatchRenderer {
	public function render( batch: Batch ): Void;
	public function clear(): Void;
}

class Batch {
	static public inline var WGT_SIZE = #if batch_minimal 3 #else 11 #end;
	
	public var namedWidgets(default,null) = new Map<String,Widget>();
	public var renderList(default,null) = new Array<Float>();
	public var pointableList(default,null) = new Array<Widget>();
	public var atlas(default,null): Atlas;	
	public var altered(default,null) = true;
	public var centerX(default,null): Float = 0;
	public var centerY(default,null): Float = 0;
	public var count(default,null): Int = 0;
	public var renderer(default,null): BatchRenderer;
	public var allowInvisiblePointables: Bool = false;
	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	public var scrolling: Bool = false;
	public var scrollXmin: Float = 0;
	public var scrollYmin: Float = 0;
	public var scrollXmax: Float = 0;
	public var scrollYmax: Float = 0;

	public function setCenter( x: Float, y: Float ) {
		for ( id in 0...count ) {
			renderList[id*WGT_SIZE] += ( x - centerX );
			renderList[id*WGT_SIZE+1] += ( y - centerY );
		}
		centerX = x;
		centerY = y;
		altered = true;
	}

	public function new( atlas: Atlas, renderer: BatchRenderer, ?scroll: Array<Float>  ) {
		this.atlas = atlas;
		this.renderer = renderer;
		
		if ( scroll != null ) {
			scrollXmin = scroll[0];
			scrollYmin = scroll[1];
			scrollXmax = scroll[2];
			scrollYmax = scroll[3];
			scrolling = true;
		}
	}

	public inline function alter() altered = true;

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

		if ( wgt.isPointable() ) {
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
	public inline function getTA( shift: Int )    return renderList[shift+3];
	public inline function getTB( shift: Int )    return renderList[shift+4];
	public inline function getTC( shift: Int )    return renderList[shift+5];
	public inline function getTD( shift: Int )    return renderList[shift+6];
	public inline function getR( shift: Int )     return renderList[shift+7];
	public inline function getG( shift: Int )     return renderList[shift+8];
	public inline function getB( shift: Int )     return renderList[shift+9];
	public inline function getA( shift: Int )     return renderList[shift+10];

	public inline function setX( shift: Int, v: Float )     setRList( shift, 0, v + centerX);
	public inline function setY( shift: Int, v: Float )     setRList( shift, 1, v + centerY);
	public inline function setFrame( shift: Int, v: Float ) setRList( shift, 2, v); 
	public inline function setTA( shift: Int, v: Float )    setRList( shift, 3, v);
	public inline function setTB( shift: Int, v: Float )    setRList( shift, 4, v);
	public inline function setTC( shift: Int, v: Float )    setRList( shift, 5, v);
	public inline function setTD( shift: Int, v: Float )    setRList( shift, 6, v); 
	public inline function setR( shift: Int, v: Float )     setRList( shift, 7, v);
	public inline function setG( shift: Int, v: Float )     setRList( shift, 8, v);
	public inline function setB( shift: Int, v: Float )     setRList( shift, 9, v);
	public inline function setA( shift: Int, v: Float )     setRList( shift, 10, v);

	inline function setRList( shift: Int, idx: Int, v: Float ) {
#if batch_minimal
		if ( idx >= 3 ) return;
#end
		renderList[shift+idx] = v; 
		altered = true;
		if ( renderList[shift+idx] != v ) {
			renderList[shift+idx] = v;
			altered = true;
		}
	}

	public inline function render() {
		if ( !altered ) return;
		renderer.render( this );
		altered = false;
	}

	public inline function clear() {
		renderer.clear();
		altered = true;
	}

	public inline function getPointablesAt( x: Float, y: Float ) {
		// TODO: Spatial optimizations
		return pointableList;
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
				if ( w.visible || allowInvisiblePointables ) {
					if (!w.onPointer( w, x, y, msg )) {
						break;
					}
				}
			}
		}
	}

	public function cacheGlyphs( name: String, path: String, chars: String/*,?specialSymbolsMapping: Map<String,String> */) {
		//var ssmap = specialSymbolsMapping != null ? specialSymbolsMapping : specialSymbols;
		var s = [0];
		var framesList = new Array<Float>();
		var mapping  = new Map<Int,Float>();
		for ( i in 0...chars.length ) {
			//var c = chars.charCodeAt( i );
			//var c_ = specialSymbols[c];
			s[0] = chars.charCodeAt( i );
			var id = atlas.ids[Printf.format( path, s )]; 
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
