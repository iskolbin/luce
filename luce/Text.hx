package luce;

import haxe.ds.Vector;

typedef TextConfig = {
	?frames: Array<String>,
	?framesList: Array<Float>,
	?align: Int,
	?visible: Bool,
	?mapping: Map<Int,Float>,
	?cached: String,
	?codes: Array<Int>,
	?string: String,
	?tracking: Float,
	?spaceWidth: Float,
	?squeeze: Bool,
	count: Int,
}

class Text extends Widget {
	static public inline var Center: Int = 0;
	static public inline var Left: Int = 1;
	static public inline var Right: Int = 2;

	static public inline var NONE: Int = -0xfff;
	static public inline var SPACE: Int = -0xffe;

	public var string(default,set): String = "";
	public var length(default,null): Int = 0;
	public var glyphs(default,null): Vector<Widget>;
	public var codes(default,null): Vector<Int>;
	public var align(default,null): Int;
	public var mapping(default,null): Map<Int,Float>;
	public var nglyphs(default,null): Int;
	public var tracking(default,set): Float = 0;
	public var totalWidth(get,null): Float;
	public var spaceWidth(default,set): Float = 0;
	public var squeeze(default,set): Bool = true;

	public inline function set_tracking(v) { tracking = v; updateGlyphs(); return v; }
	public inline function set_spaceWidth(v) { spaceWidth = v; updateGlyphs(); return v; }
	public inline function set_squeeze(v) { squeeze = v; updateGlyphs(); return v; }

	public inline function get_totalWidth() {
		var w = length > 0 ? -tracking : 0.;
		for ( i in 0...length ) {
			w += getGlyphWidth( i ) + tracking;
		}
		return w;
	}

	override public function new( batch: Batch, shift: Int, args_: Widget.WidgetConfig ) {
		super( batch, shift, args_ );
	
		var args = args_.text;
		glyphs = new Vector<Widget>( args.count );
		codes = new Vector<Int>( args.count );
		align = args.align != null ? args.align : Center;
		mapping = args.mapping;
		if ( args.tracking != null ) tracking = args.tracking;
		if ( args.squeeze != null ) squeeze = args.squeeze;

		var x_ = x;
		var y_ = y;
		x = 0;
		y = 0;
		
		var framesList: Array<Float>;

		if ( args.framesList != null ) {
			framesList = args.framesList;
		} else if ( args.frames != null ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.cached != null ) {
			if ( !batch.glyphsCache.exists( args.cached ))
				throw 'Cached glyphs "${args.cached}" not exist!';
			if ( !batch.mappingsCache.exists( args.cached ))
				throw 'Cached mapping "${args.cached}" not exist!'; 
			framesList = batch.glyphsCache[args.cached];
			mapping = batch.mappingsCache[args.cached];
		} else {
			throw "Cannot create text: need .mapping and .frame/.framesList or .cached";
		}

		if ( args.spaceWidth != null ) {
			spaceWidth = args.spaceWidth;
		} else {
			spaceWidth = batch.atlas.rects[Std.int(framesList[0])][2];
		}

		for ( i in 0...glyphs.length ) {
			glyphs[i] = batch.newWidget( {framesList: framesList, parent: this } );
		}

		x = x_;
		y = y_;
	
		if ( args.codes != null ) {
			setCodes( args.codes );
		} else if ( args.string != null ) {
			set_string( args.string );
		} else {
			set_string( "" );
		}
	}

	inline function getGlyphWidth( i: Int ) return switch( codes[i] ) {
		case NONE: 0;
		case SPACE: spaceWidth;
		default: squeeze ? glyphs[i].getActualFrameWidth() : glyphs[i].getFrameSourceWidth();
	}

	function updateGlyphs() {
		var x0: Float = switch ( align ) {
			case Center: -Math.ffloor( 0.5 * totalWidth ); 
			case Left: 0;
			case Right: -totalWidth;
			default: 0;
		}
		
		var w = 0.0;
		for ( i in 0...length ) {
			var hw = 0.5*getGlyphWidth( i );
			w += hw;
			glyphs[i].x = w + x0;

			w += hw;
			w += tracking;
		}
	}

	public function setCodes( array: Array<Int> ) {
		var n = array.length < glyphs.length ? array.length: glyphs.length;
		for ( i in 0...n ) {
			if ( array[i] == NONE ) {
				glyphs[i].visible = false;
				codes[i] = NONE;
			} else if ( array[i] == SPACE ) {
				glyphs[i].visible = false;
				codes[i] = SPACE;
			} else {
				glyphs[i].visible = true;
				glyphs[i].frame = mapping[array[i]];
				codes[i] = array[i];
			}
		}
		for ( i in n...glyphs.length ) {
			glyphs[i].visible = false;
			codes[i] = NONE;
		}
		length = n;
		updateGlyphs();
	}	

	public function set_string( string: String ) {
		var n = string.length < glyphs.length ? string.length: glyphs.length;
		this.string = string;
		for ( i in 0...n ) {
			if ( string.charAt( i ) == ' ' ) {
				glyphs[i].visible = false;
				codes[i] = SPACE;
			} else {
				var code = string.charCodeAt( i );
				glyphs[i].visible = true;
				glyphs[i].frame = mapping[code];
				codes[i] = code;
			}
		}
		for ( i in n...glyphs.length ) {
			glyphs[i].visible = false;
			codes[i] = NONE;
		}
		length = n;
		updateGlyphs();
		return string;
	}
}
