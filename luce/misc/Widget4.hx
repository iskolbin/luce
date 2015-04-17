package ;

class WidgetShift {
	public var render: Int;
	public var transform: Int;
	public var flags: Int;
	public var color: Int;
	public var frames: Int;
	public inline function( r, t, f, c, fr ) {
		render = r;
		transform = t;
		flags = f;
		color = c;
		frames = fr;
	}
}

class WidgetData {
	public static inline var RenderX     = 0;
	public static inline var RenderY     = 1;
	public static inline var RenderFrame = 2;
	public static inline var RenderXScl  = 3;
	public static inline var RenderYSkw  = 4;
	public static inline var RenderXSkw  = 5;
	public static inline var RenderYScl  = 6;
	public static inline var RenderRed   = 7;
	public static inline var RenderGreen = 8;
	public static inline var RenderBlue  = 9;
	public static inline var RenderAlpha = 10;
	public static inline var RENDER_N    = 11;

	public static inline var LocalX    = 0;
	public static inline var LocalY    = 1;
	public static inline var LocalXcl  = 2;
	public static inline var LocalYSkw = 3;
	public static inline var LocalXSkw = 4;
	public static inline var LocalYScl = 5;
	public static inline var LocalRot  = 6;
	public static inline var LocalXPiv = 7;
	public static inline var LocalYPiv = 8;
	public static inline var LocalVisible = 9;
	public static inline var WorldX    = 10;
	public static inline var WorldY    = 11;
	public static inline var WorldXcl  = 12;
	public static inline var WorldYSkw = 13;
	public static inline var WorldXSkw = 14;
	public static inline var WorldYScl = 15;
	public static inline var WorldRot  = 16;
	public static inline var WorldXPiv = 17;
	public static inline var WorldYPiv = 18;
	public static inline var WorldVisible = 19;
	public static inline var Sin       = 20;
	public static inline var Cos       = 21;
	public static inline var PivotDx   = 22;
	public static inline var PivotDy   = 23;
	public static inline var TRANSFORM_N = 24;

	public static inline var LocalRed    = 0;
	public static inline var LocalGreen  = 1;
	public static inline var LocalBlue   = 2;
	public static inline var LocalAlpha  = 3;
	public static inline var GlobalRed   = 4;
	public static inline var GlobalGreen = 5;
	public static inline var GlobalBlue  = 6;
	public static inline var GlobalAlpha = 7;
	public static inline var COLOR_N     = 8;

	public var count: Int = 0;

	public var renderShift   = new Array<Int>();
	public var transformShift= new Array<Int>();
	public var flagsShift    = new Array<Int>();
	public var colorsShift   = new Array<Int>();
	public var framesShift   = new Array<Int>();

	public var renderList    = new Array<Float>();
	public var transformList = new Array<Float>();
	public var flagsList     = new Array<Int>();
	public var colorsList    = new Array<Int>();
	public var framesList    = new Array<Float>();
	
	public var new() {}

	public var alloc( ?nframes: Int ) {
		nframes = nframes != null ? nframes : 1;
		var id = count;
		count += 1;

		renderShift.push( renderList.length );
		transformShift.push( transformList.length );
		flagsShift.push( flagsList.length );
		colorShift.push( colorsList.length );
		framesShift.push( framesList.length );

		for ( i in 0...RENDER_N ) renderList.push( 0 );
		for ( i in 0...TRANSFORM_N ) transformList.push( 0 );
		for ( i in 0...COLOR_N ) colorList.push( 0 );
		for ( i in 0...FLAGS_N ) flagsList.push( 0 );
		for ( i in 0...nframes ) frames.push( 0 );
		
		return id;
	}

	static inline function setX( id: Int, val: Float ) {
		var ts = transformShift[id];
		transformList[ts + LocalX] = val;
		renderList[renderShift[id] +	RenderX] = val + transformList[ts + WorldX];
	}
	
	static inline function updateTransformAttrX( id: Int, val: Float ) {
		transformList[transformShift[i]+X] = val;

	}

	static inline function updateTransformAttr( id: Int, attr: Int, val: Float ) {
		transformList[transformShift[i]+attr] = val;
	}
}

class Widget {
	public static inline var X = 0;
	public static inline var Y = 1;
	public static inline var XScl = 2;
	public static inline var YSkw = 3;
	public static inline var XSkw = 4;
	public static inline var YScl = 5;
	public static inline var Rot = 6;
	public static inline var XPiv = 7;
	public static inline var YPiv = 8;
	
	public static inline var Frame = 9;
	
	public static inline var Red = 10;
	public static inline var Green = 11;
	public static inline var Blue = 12;
	public static inline var Alpha = 13;
	public static inline var Visible = 14;

	public var id: Int;
	public var data: WidgetData;

	public function setAttr( attr: Int, val: Float ) {
		switch ( attr ) {
			case X: data.updateTransformAttrX( id, val );
			case Y: data.updateTransformAttrY( id, val );
			case XPiv: data.updateTransformAttrXPiv( id, val );
			case YPiv: data.updateTransformAttrYPiv( id, val );
			case XScl: data.updateTransformAttr( id, WidgetData.TransformXScl, val );
			case YScl: data.updateTransformAttr( id, WidgetData.TransformYScl, val );
			case XSkw: data.updateTransformAttr( id, WidgetData.TransformXSkw, val );
			case YSkw: data.updateTransformAttr( id, WidgetData.TransformYSkw, val );
			case Rot: 
				data.updateTransformAttr( id, WidgetData.TransformSin, val == 0 ? 0 : Math.sin( val ));
				data.updateTransformAttr( id, WidgetData.TransformCos, val == 0 ? 1 : Math.cos( val ));
				data.updateTransformAttr( id, WidgetData.TransformRot, val );
			
			case Red: data.updateColorAttr( id, WidgetData.ColorRed, val );
			case Green: data.updateColorAttr( id, WidgetData.ColorGreen, val );
			case Blue: data.updateColorAttr( id, WidgetData.ColorBlue, val );
			case Alpha: data.updateColorAttr( id, WidgetData.ColorAlpha, val );	
			
			case Frame: data.updateFrameAttr( id, val );
			
			case Visible: data.updateFlagAttr( id, WidgetData.Visible, val );
		}
	}
}
