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
	count: Int,
	?tracking: Float,
	?spaceWidth: Float,
}

class UIText extends UIWidget {
	public static inline var Center: Int = 0;
	public static inline var Left: Int = 1;
	public static inline var Right: Int = 2;

	public static inline var NONE: Int = -0xfff;
	public static inline var SPACE: Int = -0xffe;

	public var length(default,null): Int = 0;
	public var glyphs(default,null): Vector<UIWidget>;
	public var codes(default,null): Vector<Int>;
	public var align(default,null): Int;
	public var mapping(default,null): Map<Int,Float>;
	public var nglyphs(default,null): Int;
	public var tracking(default,set): Float = 0;
	public var totalWidth(get,null): Float;
	public var spaceWidth(default,set): Float = 0;

	public inline function set_tracking(v) { tracking = v; updateGlyphs(); return v; }
	public inline function set_spaceWidth(v) { spaceWidth = v; updateGlyphs(); return v; }

	public inline function get_totalWidth() {
		var w = length > 0 ? -tracking : 0.;
		for ( i in 0...length ) {
			w += getGlyphWidth( i ) + tracking;
		}
		return w;
	}

	override public function new( batch: UIBatch, shift: Int, args_: UIWidget.WidgetConfig ) {
		super( batch, shift, args_ );
	
		var args = args_.text;
		glyphs = new Vector<UIWidget>( args.count );
		codes = new Vector<Int>( args.count );
		align = args.align != null ? args.align : Center;
		mapping = args.mapping;
		if ( args.tracking != null ) tracking = args.tracking;

		var x_ = x;
		var y_ = y;
		x = 0;
		y = 0;
		
		var framesList: Array<Float>;

		if ( args.framesList != null ) {
			framesList = args.framesList;
		} else if	( args.frames != null ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.cached != null ) {
			framesList = batch.glyphsCache[args.cached];
			mapping = batch.mappingsCache[args.cached];
			
		} else {
			throw "Cannot create text: need .mapping and .frame/.framesList or .cached";
		}

		if ( args.spaceWidth != null ) {
			spaceWidth = args.spaceWidth;
		} else {
			spaceWidth = batch.atlas.rects[Std.int(framesList[0])].width;
		}

		for ( i in 0...glyphs.length ) {
			// TODO: more parent
			glyphs[i] = batch.newWidget( {framesList: framesList, parent: {x: this, y: this, visible: this }} );
		}

		x = x_;
		y = y_;
	
		if ( args.codes != null ) {
			setCodes( args.codes );
		} else if ( args.string != null ) {
			setString( args.string );
		}
	}

	override function updateVisibleLink() {
		super.updateVisibleLink();
		updateGlyphs();
	}

	inline function getGlyphWidth( i: Int ) return switch( codes[i] ) {
		case NONE: 0;
		case SPACE: spaceWidth;
		default: glyphs[i].getActualFrameWidth();
	}

	function updateGlyphs() {
		var x0: Float = switch ( align ) {
			case Center: -totalWidth / 2; 
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

	public function setString( string: String ) {
		var n = string.length < glyphs.length ? string.length: glyphs.length;
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
	}
}
