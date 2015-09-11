package luce;

import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

typedef TexturePackerJsonFrame = {
	?filename: String,
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

typedef TexturePackerJsonArray = {
	frames: Array< TexturePackerJsonFrame>
}

class Atlas {
	public var ids(default,null) = new Map<String, Float>();
	public var rects(default,null) = new Array<Rectangle>();
	public var sourceWidth(default,null) = new Array<Float>();
	public var sourceHeight(default,null) = new Array<Float>();
	public var centers(default,null) = new Array<Point>();
	public var tilesheet(default,null): Tilesheet;
	public var bitmapData(default,null): BitmapData;
	public var ids9patch(default,null) = new Map<String, Array<Float>>();
	public var xscl(default,null) = 1.0;
	public var yscl(default,null) = 1.0;
	public var framesCache(default,null) = new Map<String, Array<Float>>();
	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	static public inline var NULL: Float = 0;

	var count: Int = 0;

	function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float, srcW: Float, srcH: Float ) {
		var rect = new Rectangle( x*xscl, y*yscl, w*xscl, h*yscl );
		var center = new Point( cx, cy );
		var id: Int;
		id = tilesheet.addTileRect( rect, center );

		count += 1;
		
		rects.push( rect );
		centers.push( center );
		sourceWidth.push( srcW );
		sourceHeight.push( srcH );
		if ( key != null ) {
			ids[key] = id;
		}
	}

	function addTexturePackerFrame( frame: TexturePackerJsonFrame, ?filename: String ) {
		var filename = filename == null ? frame.filename : filename;
		var frameData = frame.frame;
		var cx = frame.trimmed ? ( 0.5*frame.sourceSize.w - frame.spriteSourceSize.x ) : 0.5*frame.sourceSize.w;
		var cy = frame.trimmed ? ( 0.5*frame.sourceSize.h - frame.spriteSourceSize.y ) : 0.5*frame.sourceSize.h;

		addFrame( filename, frameData.x, frameData.y, frameData.w, frameData.h, cx, cy, frame.sourceSize.w, frame.sourceSize.h );
	}

	static public function fromTexturePackerJsonHash( data: TexturePackerJsonHash, bitmapData: BitmapData, ?xscl, ?yscl ) {
		var self = new Atlas( bitmapData, xscl, yscl );
		
		for ( filename in Reflect.fields( data.frames )  ) {
			self.addTexturePackerFrame( Reflect.field( data.frames, filename ), filename );
		} 
		return self;
	}

	static public function fromTexturePackerJsonArray( data: TexturePackerJsonArray, bitmapData: BitmapData, ?xscl, ?yscl ) {
		var self = new Atlas( bitmapData, xscl, yscl );		
		
		for ( frame in data.frames ) {
		 	self.addTexturePackerFrame( frame );
		}

		return self;
	}

	public function framesFromStrings( frames: Array<String> ): Array<Float> {
		return [ for ( f in frames ) ids[f] ];
	}

	public function cacheFrames( name: String, frames: Array<String> ) {
		framesCache[name] = framesFromStrings( frames );	
	}

	function scaleBitmapData( bitmapData: BitmapData, xscl: Float, yscl: Float ) {
		var matrix = new openfl.geom.Matrix(xscl, 0,0,yscl, 0, 0);
		var newBitmapData = new BitmapData( Std.int(bitmapData.width * xscl), Std.int(bitmapData.height * yscl), true, 0x000000);
		newBitmapData.draw( bitmapData, matrix, null, null, null, true );
		return newBitmapData;
	}

	function new( bitmapData: BitmapData, ?xscl, ?yscl ) {
		this.bitmapData = bitmapData;
		if ( xscl != null || yscl != null ) {
			this.xscl = xscl != null ? xscl : 1.0;
			this.yscl = yscl != null ? yscl : 1.0;
			if ( this.xscl != 1.0 || this.yscl != 1.0 ) {
				bitmapData = scaleBitmapData( bitmapData, this.xscl, this.yscl );
			}
		}
		
		tilesheet = new Tilesheet( bitmapData );
		addFrame( null, 0, 0, 0, 0, 0, 0, 0, 0 );
	}
}
