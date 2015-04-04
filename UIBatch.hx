// batch_no_altered_test -- не проверять, изменилось ли что либо перед перерисовкой
// batch_no_changed_test -- не проверять, изменилось ли что либо по факту перед перерисовкой
// batch_no_round_xy -- перед выводом не округлять координаты

package ;

import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.geom.Point;
import de.polygonal.Printf;

interface BatchRenderer {
	public function render( batch: UIBatch ): Void;
}

class UIBatch {
	public static inline var WGT_SIZE = 11;

	public var namedWidgets(default,null) = new Map<String,UIWidget>();
	public var renderList(default,null) = new Array<Float>();
	public var buttonList(default,null) = new Array<UIWidget>();
	public var atlas(default,null): UIAtlas;	
	public var altered(default,null) = true;
	public var centerX(default,null): Float = 0;
	public var centerY(default,null): Float = 0;
	public var count(default,null): Int = 0;
	public var renderer(default,null): BatchRenderer;
	public var allowInvisibleButtons: Bool = false;

	public function setCenter( x: Float, y: Float ) {
		for ( id in 0...count ) {
			renderList[id*WGT_SIZE] += ( x - centerX );
			renderList[id*WGT_SIZE+1] += ( y - centerY );
		}
		centerX = x;
		centerY = y;
		altered = true;
	}

	public function new( atlas: UIAtlas, renderer: BatchRenderer  ) {
		this.atlas = atlas;
		this.renderer = renderer;
	}

	public inline function alter() altered = true;

	public inline function newWidget( args: UIWidget.WidgetConfig ) {
		var shift = renderList.length;

		for ( i in 0...WGT_SIZE ) {
			renderList.push( 0 );
		}
			
		var wgt: UIWidget = if ( args.text != null ) {
			new UIText( this, shift, args );
		} else if ( args.grid != null ) {
			new UIGrid( this, shift, args );
		} else if ( args.ninepatch != null ) {
			new UINinePatch( this, shift, args );
		} else {
			new UIWidget( this, shift, args );
		}

		if ( wgt.isButton() ) {
			buttonList.push( wgt );
		}

		if ( args != null && args.name != null ) {
			namedWidgets[args.name] = wgt;
		}
		
		count++;

		return wgt;
	}

	public function newText( args: UIWidget.WidgetConfig ): UIText {
		if ( args.text == null ) throw ".text field needed for creating text";
		return cast newWidget( args );
	}
	
	public function newGrid( args: UIWidget.WidgetConfig ): UIGrid {
		if ( args.grid == null ) throw ".grid field needed for creating grid";
		return cast newWidget( args );
	}

	public function newNinePatch( args: UIWidget.WidgetConfig ): UINinePatch {
		if ( args.ninepatch == null ) throw ".ninepatch field needed for creating ninepatch";
		return cast newWidget( args );
	}

	public inline function getX( shift: Int ) { return renderList[shift] - centerX; }
	public inline function getY( shift: Int ) { return renderList[shift+1] - centerY; }
	public inline function getCX( shift: Int ) { return renderList[shift]; }
	public inline function getCY( shift: Int ) { return renderList[shift+1]; }
	public inline function getFrame( shift: Int ) { return renderList[shift+2]; }
	public inline function getTA( shift: Int ) { return renderList[shift+3]; }
	public inline function getTB( shift: Int ) { return renderList[shift+4]; }
	public inline function getTC( shift: Int ) { return renderList[shift+5]; }
	public inline function getTD( shift: Int ) { return renderList[shift+6]; }
	public inline function getR( shift: Int ) { return renderList[shift+7]; }
	public inline function getG( shift: Int ) { return renderList[shift+8]; }
	public inline function getB( shift: Int ) { return renderList[shift+9]; }
	public inline function getA( shift: Int ) { return renderList[shift+10]; }

	public inline function setX( shift: Int, v: Float ) { setRList( shift, 0, v + centerX); }
	public inline function setY( shift: Int, v: Float ) { setRList( shift, 1, v + centerY); }
	public inline function setFrame( shift: Int, v: Float ) { setRList( shift, 2, v); }
	public inline function setTA( shift: Int, v: Float ) { setRList( shift, 3, v); }
	public inline function setTB( shift: Int, v: Float ) { setRList( shift, 4, v); }
	public inline function setTC( shift: Int, v: Float ) { setRList( shift, 5, v); }
	public inline function setTD( shift: Int, v: Float ) { setRList( shift, 6, v); }
	public inline function setR( shift: Int, v: Float )  { setRList( shift, 7, v); }
	public inline function setG( shift: Int, v: Float )  { setRList( shift, 8, v); }
	public inline function setB( shift: Int, v: Float )  { setRList( shift, 9, v); }
	public inline function setA( shift: Int, v: Float )  { setRList( shift, 10, v); }

	inline function setRList( shift, idx: Int, v: Float ) {
#if batch_no_altered_test
		renderList[shift+idx] = v;
#else
	#if batch_no_changed_test
		renderList[shift+idx] = v; 
		altered = true;
	#else
		if ( renderList[shift+idx] != v ) {
			renderList[shift+idx] = v;
			altered = true;
		}
	#end
#end
	}

	public inline function render() {
#if !batch_no_altered_test
		if ( !altered ) return;
#end

		renderer.render( this );

		altered = false;
	}

	public inline function getButtonsAt( x: Float, y: Float ) {
		// TODO: Spatial optimizations
		return buttonList;
	}

	public inline function onPress( x: Float, y: Float ) {
		for ( w in getButtonsAt( x, y )) {
			if ( w.pointInside( x, y )) {
				if ( w.visible || allowInvisibleButtons ) {
					w.press();
					if ( w.block ) {
						break;
					}
				}
			}
		}
	}

	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	
	public static var noSpecialMapping = new Map<String,String>();
	public static var specialSymbols: Map<String,String> = [
		"." => "dot", "," => "comma", "\\" => "backslash", "/" => "slash", "&" => "ampersand"
		];

	public function cacheGlyphs( name: String, path: String, chars: String, ?specialSymbolsMapping: Map<String,String> ) {
		var ssmap = specialSymbolsMapping != null ? specialSymbolsMapping : specialSymbols;
		var s = [""];
		var framesList = new Array<Float>();
		var mapping  = new Map<Int,Float>();
		for ( i in 0...chars.length ) {
			var c = chars.charAt( i );
			var c_ = specialSymbols[c];
			s[0] = c_ != null ? c_ : c;
			var id = atlas.ids[Printf.format( path, s )]; 
			mapping[chars.charCodeAt( i )] = framesList.length;
			framesList.push( id );
		}

		glyphsCache[name] = framesList; 
		mappingsCache[name] = mapping;
	}

	public function newFramesList( frames: Array<String> ): Array<Float> {
		return [ for ( f in frames )  atlas.ids[f] ];
	}

	public inline function byName( name: String ) {
		return namedWidgets[name];
	}
}
