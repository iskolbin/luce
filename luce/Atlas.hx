package luce;

import openfl.display.Tilesheet;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import de.polygonal.Printf;

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
	public var centers(default,null) = new Array<Point>();
	public var tilesheet(default,null): Tilesheet;
	public var bitmapData(default,null): BitmapData;
	public var ids9patch(default,null) = new Map<String, Array<Float>>();
	public var xscl(default,null) = 1.0;
	public var yscl(default,null) = 1.0;
	public var framesCache(default,null) = new Map<String, Array<Float>>();
	public var glyphsCache(default,null) = new Map<String, Array<Float>>();
	public var mappingsCache(default,null) = new Map<String, Map<Int,Float>>();
	public static var noSpecialMapping = new Map<String,String>();
	public static var specialSymbols: Map<String,String> = ["." => "dot", "," => "comma", "\\" => "backslash", "/" => "slash", "&" => "ampersand"];
	public static inline var NULL: Float = 0;

	var count: Int = 0;

	function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float ) {
		var rect = new Rectangle( x*xscl, y*yscl, w*xscl, h*yscl );
		var center = new Point( cx, cy );
		var id: Int;
		id = tilesheet.addTileRect( rect, center );

		count += 1;
		
		rects.push( rect );
		centers.push( center );
		if ( key != null ) {
			ids[key] = id;
		}
	}

	// NOT USE!
	// 1 2 3
	// 4 5 6
	// 7 8 9
	public function addNinePatchFrame( key: String, left: Float, right: Float, top: Float, bottom: Float ) {
		var id = ids[key];
		var rect = rects[Std.int(id)];
		var center = centers[Std.int(id)];

		var cx = center.x; var cy = center.y;
		var xL = rect.x; var xC = rect.x+left; var xR = rect.x+right;
		var yT = rect.y; var yC = rect.y+top;  var yB = rect.y+bottom;
		var wL = left; var wC = right-left; var wR = rect.width-right;
		var hT = top;  var hC = bottom-top; var hB = rect.height-bottom;
		var cCx= 0.5*wC; var cCy = 0.5*hC;
		//cCx = cx; cCy = cy;
		//		var cL = cx + 0.5*wL; var cR = -cx - 0.5*wR;
//		var cT = cy + 0.5*hT; var cB = -cy - 0.5*hB;
//		var cCx= 0; var cCy = 0;
		var cL = 0.5*wL; var cR = 0.5*wR;
		var cT = 0.5*hT; var cB = -cCy+0.5*hB;
	//	var cL = -wL; var cR = wR;
	//	var cT = -hT; var cB = hB;

	trace(cx, cy);	
		trace( rect.x, rect.y, rect.width, rect.height );		
		trace( key + "_9p_1", xL, yT, wL, hT, cL, cT );
		trace( key + "_9p_2", xC, yT, wC, hT, cCx,cT );
		trace( key + "_9p_3", xR, yT, wR, hT, cR, cT );
		trace( key + "_9p_4", xL, yC, wL, hC, cL, cCy);
		trace( key + "_9p_5", xC, yC, wC, hC, cCx,cCy);
		trace( key + "_9p_6", xR, yC, wR, hC, cR, cCy);
		trace( key + "_9p_7", xL, yB, wL, hB, cL, cB );
		trace( key + "_9p_8", xC, yB, wC, hB, cCx,cB );
		trace( key + "_9p_9", xR, yB, wR, hB, cR, cB );
	

		addFrame( key + ".9p.1", xL, yT, wL, hT, cL ,cT );
		addFrame( key + ".9p.2", xC, yT, wC, hT, cCx,cT );
		addFrame( key + ".9p.3", xR, yT, wR, hT, cR ,cT );
		addFrame( key + ".9p.4", xL, yC, wL, hC, cL ,cCy);
		addFrame( key + ".9p.5", xC, yC, wC, hC, cCx,cCy);
		addFrame( key + ".9p.6", xR, yC, wR, hC, cR ,cCy);
		addFrame( key + ".9p.7", xL, yB, wL, hB, cL ,cB );
		addFrame( key + ".9p.8", xC, yB, wC, hB, cCx,cB );
		addFrame( key + ".9p.9", xR, yB, wR, hB, cR ,cB );
	
		ids9patch[key] = [ for ( i in 1...10 ) ids['${key}.9p.${i}']];
	}

	function addTexturePackerFrame( frame: TexturePackerJsonFrame, ?filename: String ) {
		var filename = filename == null ? frame.filename : filename;
		var frameData = frame.frame;
		var cx = frame.trimmed ? ( 0.5*frame.sourceSize.w - frame.spriteSourceSize.x ) : 0.5*frame.sourceSize.w;
		var cy = frame.trimmed ? ( 0.5*frame.sourceSize.h - frame.spriteSourceSize.y ) : 0.5*frame.sourceSize.h;

		addFrame( filename, frameData.x, frameData.y, frameData.w, frameData.h, cx, cy );
	}

	public static function fromTexturePackerJsonHash( data: TexturePackerJsonHash, bitmapData: BitmapData, ?xscl, ?yscl ) {
		var self = new Atlas( bitmapData, xscl, yscl );
		
		for ( filename in Reflect.fields( data.frames )  ) {
			self.addTexturePackerFrame( Reflect.field( data.frames, filename ), filename );
		} 
		return self;
	}

	public static function fromTexturePackerJsonArray( data: TexturePackerJsonArray, bitmapData: BitmapData, ?xscl, ?yscl ) {
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

	public function cacheGlyphs( name: String, path: String, chars: String, ?specialSymbolsMapping: Map<String,String> ) {
		var ssmap = specialSymbolsMapping != null ? specialSymbolsMapping : specialSymbols;
		var s = [""];
		var framesList = new Array<Float>();
		var mapping  = new Map<Int,Float>();
		for ( i in 0...chars.length ) {
			var c = chars.charAt( i );
			var c_ = specialSymbols[c];
			s[0] = c_ != null ? c_ : c;
			var id = ids[Printf.format( path, s )]; 
			mapping[chars.charCodeAt( i )] = framesList.length;
			framesList.push( id );
		}

		glyphsCache[name] = framesList; 
		mappingsCache[name] = mapping;
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
		addFrame( null, 0, 0, 0, 0, 0, 0 );
	}
}
