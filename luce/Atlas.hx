package luce;

import haxe.ds.Vector;
import haxe.macro.Expr;
import haxe.macro.Context;

typedef TexturePackerJsonFrame = {
	frame: {x: Int, y: Int, w: Int, h: Int},
	rotated: Bool,
	trimmed: Bool,
	spriteSourceSize: {x: Int, y: Int, w: Int, h: Int},
	sourceSize: {w: Int, h: Int},
	pivot: {x: Float, y: Float},
}

typedef TexturePackerJsonHash = {
	frames: Dynamic,
}

class Atlas {
	public var ids(default,null) = new Map<String, Float>();
	public var rects(default,null) = new Array<Vector<Float>>();
	public var sourceRects(default,null) = new Array<Vector<Float>>();
	public var centers(default,null) = new Array<Vector<Float>>();
	public var sourceWidth(default,null) = new Array<Float>();
	public var sourceHeight(default,null) = new Array<Float>();
	public var framesCache(default,null) = new Map<String, Array<Float>>();
	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	static public inline var NULL: Float = 0.0;

	var count: Int = 0;

	function addFrameRect( x: Float, y: Float, w: Float, h: Float ) {
		var rect = new Vector<Float>( 4 );
		rect[0] = x; rect[1] = y; rect[2] = w; rect[3] = h;
		rects.push( rect );
	}

	function addSourceRect( x: Float, y: Float, w: Float, h: Float ) {
		var rect = new Vector<Float>( 4 );
		rect[0] = x; rect[1] = y; rect[2] = w; rect[3] = h;
		sourceRects.push( rect );
	}

	function addFrameCenter( x: Float, y: Float ) {
		var point = new Vector<Float>( 2 );
		point[0] = x; point[1] = y; 
		centers.push( point );	
	}

	public function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float, srcX: Float, srcY: Float, srcW: Float, srcH: Float ) {
		var id = count++;

		addFrameRect( x, y, w, h );
		addSourceRect( srcX, srcY, srcW, srcH );
		addFrameCenter( cx, cy );
		
		sourceWidth.push( srcW );
		sourceHeight.push( srcH );
		if ( key != null ) {
			ids[key] = id;
		}
	}

	function addTexturePackerFrame( frame: TexturePackerJsonFrame, filename: String ) {
		var frameData = frame.frame;
		var cx = frame.trimmed ? ( 0.5*frame.sourceSize.w - frame.spriteSourceSize.x ) : 0.5*frame.sourceSize.w;
		var cy = frame.trimmed ? ( 0.5*frame.sourceSize.h - frame.spriteSourceSize.y ) : 0.5*frame.sourceSize.h;

		addFrame( filename, frameData.x, frameData.y, frameData.w, frameData.h, cx, cy, frame.sourceSize.x, frame.sourceSize.y, frame.sourceSize.w, frame.sourceSize.h );
	}

	public function loadTexturePackerJsonHash( data: TexturePackerJsonHash ) {
		for ( filename in Reflect.fields( data.frames )  ) {
			addTexturePackerFrame( Reflect.field( data.frames, filename ), filename );
		} 
	}

	public function framesFromStrings( frames: Array<String> ): Array<Float> {
		return [ for ( f in frames ) ids[f] ];
	}

	public function cacheFrames( name: String, frames: Array<String> ) {
		framesCache[name] = framesFromStrings( frames );	
	}

	function addNullFrame() {
		addFrame( null, 0, 0, 0, 0, 0, 0, 0, 0 );
	}

	public function new() {
		addNullFrame();
	}
	
	macro public static function unrollTexturePackerHashJson( atlas: ExprOf<Atlas>, path: String ) {
		var data = haxe.Json.parse( sys.io.File.getContent( path ));
		var toadd = new Array<Expr>();
		for ( filename in Reflect.fields( data.frames  )) {
			var frame: TexturePackerJsonFrame = Reflect.field( data.frames, filename );
			var frameData = frame.frame;
			var cx = frame.trimmed ? ( 0.5*frame.sourceSize.w - frame.spriteSourceSize.x ) : 0.5*frame.sourceSize.w;
			var cy = frame.trimmed ? ( 0.5*frame.sourceSize.h - frame.spriteSourceSize.y ) : 0.5*frame.sourceSize.h;

			toadd.push( macro {${atlas}.addFrame( 
					$v{filename}, 
					$v{frameData.x}, $v{frameData.y}, $v{frameData.w}, $v{frameData.h}, 
					$v{cx}, $v{cy}, $v{frame.sourceSize.w}, $v{frame.sourceSize.h});});
		}
		return macro $b{toadd};
	}
}
