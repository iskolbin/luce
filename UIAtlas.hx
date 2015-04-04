package;

import openfl.Assets;
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

class UIAtlas {
	public var ids(default,null) = new Map<String, Float>();
	public var rects(default,null) = new Array<Rectangle>();
	public var centers(default,null) = new Array<Point>();
	public var tilesheet(default,null): Tilesheet;
	public var bitmapData(default,null): BitmapData;
	public var ids9patch(default,null) = new Map<String, Array<Float>>();

	public static inline var NULL: Float = 0;

	var count: Int = 0;

	function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float ) {
		var rect = new Rectangle( x, y, w, h );
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

	public static function fromTexturePackerJsonHash( data: TexturePackerJsonHash, imagePath: String ) {
		var self = new UIAtlas( imagePath );
		
		for ( filename in Reflect.fields( data.frames )  ) {
			self.addTexturePackerFrame( Reflect.field( data.frames, filename ), filename );
		} 
		return self;
	}

	public static function fromTexturePackerJsonArray( data: TexturePackerJsonArray, imagePath: String ) {
		var self = new UIAtlas( imagePath );		
		
		for ( frame in data.frames ) {
		 	self.addTexturePackerFrame( frame );
		}

		return self;
	}

	function new( atlasImagePath: String ) {
		bitmapData = Assets.getBitmapData( atlasImagePath );
		tilesheet = new Tilesheet( bitmapData );
		addFrame( null, 0, 0, 0, 0, 0, 0 );
	}
}
