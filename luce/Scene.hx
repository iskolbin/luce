package luce;

typedef PropConfig = {
	?name: String,
	?x: Float,
	?y: Float,
	?xscl: Float,
	?yscl: Float,
	?xskw: Float,
	?yskw: Float,
	?rot: Float,
	?red: Float,
	?green: Float,
	?blue: Float,
	?alpha: Float,
	?frame: Float,
	?props: Array<PropConfig>,
}

class Scene {
	public static inline var RenderX     = 0;
	public static inline var RenderY     = 1;
	public static inline var RenderFrame = 2;
	public static inline var RenderTA  = 3;
	public static inline var RenderTB  = 4;
	public static inline var RenderTC  = 5;
	public static inline var RenderTD  = 6;
	public static inline var RenderRed   = 7;
	public static inline var RenderGreen = 8;
	public static inline var RenderBlue  = 9;
	public static inline var RenderAlpha = 10;
	public static inline var RENDER_N    = 11;

	public static inline var X    = 0;
	public static inline var Y    = 1;
	public static inline var XScl = 2;
	public static inline var YSkw = 3;
	public static inline var XSkw = 4;
	public static inline var YScl = 5;
	public static inline var Rot  = 6;
	public static inline var Sin  = 7;
	public static inline var Cos  = 8;
	public static inline var TA   = 9;
	public static inline var TB   = 10;
	public static inline var TC   = 11;
	public static inline var TD   = 12;
	public static inline var Red    = 13;
	public static inline var Green  = 14;
	public static inline var Blue   = 15;
	public static inline var Alpha  = 16;
	public static inline var ATTR_N  = 17;

	public static inline var NULL_PARENT = -1;

	public static inline var Parent = 0;
	public static inline var ChildrenShift = 1;
	public static inline var ChildrenCount = 2;
	public static inline var TransformLevel = 3;
	public static inline var TransformShift = 4;
	public static inline var RenderShift = 5;
	public static inline var LINKS_N2 = 3; // 2^3=8

	public var propsCount: Int = 0;

	public var linksList     = new Array<Int>();
	public var renderList    = new Array<Float>();
	public var transformList = new Array<Array<Float>>();
	public var id2name       = new Map<Int,String>();
	public var name2id       = new Map<String,Int>();

	public function new( props: Array<PropConfig> ) {
		addProp( {props: props}, 0, NULL_PARENT );
	}

	public inline function sin( x: Float ) return Math.sin( x );
	public inline function cos( x: Float ) return Math.cos( x );

	public inline function byName( name: String ) return name2id[name];
	public inline function toName( id: Int ) return id2name[id];
	public inline function getTransform( id: Int ): Array<Float> {
		var shift = _link( id, TransformShift );
		var t = transformList[_link( id, TransformLevel )];
		return [t[shift],t[shift+1],t[shift+2],t[shift+3],t[shift+4],
			t[shift+5],t[shift+6],t[shift+7],t[shift+8],t[shift+9],
			t[shift+10],t[shift+11],t[shift+12],t[shift+13],t[shift+14],
			t[shift+15],t[shift+16]];
	}

	public inline function getRenderAttrs( id: Int ): Array<Float> {
		var shift = _link( id, RenderShift );
		var r = renderList;
		return [r[shift],r[shift+1],r[shift+2],r[shift+3],r[shift+4],
			r[shift+5],r[shift+6],r[shift+7],r[shift+8],r[shift+9],r[shift+10]];
	}

	public function addProp( args: PropConfig, level: Int, parent: Int ) {	
		var id = propsCount;
		propsCount += 1;
		while ( level+1 >= transformList.length ) {
			transformList.push( new Array<Float>());
		}
		var transformShift = transformList[level].length;
		var childrenShift = transformList[level+1].length;
		var renderShift = renderList.length;

		for ( i in 0...ATTR_N ) transformList[level].push( 0.0 );
		for ( i in 0...RENDER_N ) renderList.push( 0.0 );
		for ( i in 0...(1<<LINKS_N2) ) linksList.push( 0 );

		var id_ = id<<LINKS_N2;
		linksList[id_ + Parent] = parent;
		linksList[id_ + ChildrenShift] = transformShift;
		linksList[id_ + ChildrenCount] = args.props != null ? args.props.length : 0;
		linksList[id_ + TransformLevel] = level;
		linksList[id_ + TransformShift] = transformShift;
		linksList[id_ + RenderShift] = renderShift;

		_setTransform( id, 
				args.x != null ? args.x : 0, args.y != null ? args.y : 0,
				args.xscl != null ? args.xscl : 1, args.yskw != null ? args.yskw : 0, 
				args.xskw != null ? args.xskw : 0, args.yscl != null ? args.yscl : 1, 
				args.rot != null ? args.rot : 0 );
		_setColor( id, 
				args.red != null ? args.red : 1, args.green != null ? args.green : 1, 
				args.blue != null ? args.blue : 1, args.alpha != null ? args.alpha : 1 );
		_setFrame( id, 
				args.frame != null ? args.frame : 0 );
	
		if ( args.name != null ) {
			id2name[id] = args.name;
			name2id[args.name] = id;
		}

		if ( args.props != null ) {
			for ( i in 0...args.props.length ) {
				addProp( args.props[i], level+1, id );
			}
		}
	}

	inline function _link( id: Int, attr: Int ): Int {
		return linksList[(id<<LINKS_N2) + attr];
	}

	inline function _setFrame( id: Int, frame: Float ) {
		renderList[_link( id, RenderFrame )] = frame;	
	}
	
	inline function _setTransform( id: Int, x: Float, y: Float, xscl: Float, yskw: Float, xskw: Float, yscl: Float, rot: Float ) {
		var shift = _link( id, TransformShift );
		var t = transformList[_link( id, TransformLevel )];
		var rshift = _link( id, RenderShift );
		var parentId = _link( id, Parent );
		var r = renderList;
		
		t[shift + X] = x;
		t[shift + Y] = y;
		t[shift + XScl] = xscl;
		t[shift + YSkw] = yskw;
		t[shift + XSkw] = xskw;
		t[shift + YScl] = yscl;
		t[shift + Rot] = rot;
		
		if ( rot != 0.0 ) {
			var sin_ = sin( rot );
			var cos_ = cos( rot );
			t[shift + Sin] = sin_;
			t[shift + Cos] = cos_;
			t[shift + TA] = cos_ * xscl - sin_ * yskw;
			t[shift + TB] = sin_ * xscl + cos_ * yskw;
			t[shift + TC] = cos_ * xskw - sin_ * yscl;
			t[shift + TD] = sin_ * xskw + cos_ * yscl;
		} else {
			t[shift + Sin] = 0;
			t[shift + Cos] = 1;
			t[shift + TA] = 1;
			t[shift + TB] = 0;
			t[shift + TC] = 0;
			t[shift + TD] = 1;
		}
		
		if ( parentId != NULL_PARENT ) {
			var prshift = _link( parentId, RenderShift );
			var xp = r[prshift+RenderX] - t[shift+X];
			var yp = r[prshift+RenderY] - t[shift+Y];
			var pta = r[prshift+RenderTA];
			var ptb = r[prshift+RenderTB];
			var ptc = r[prshift+RenderTC];
			var ptd = r[prshift+RenderTD];

			r[rshift + RenderX]  = r[prshift+RenderX] + t[shift+X] - xp * pta - yp * ptc + xp;
			r[rshift + RenderY]  = r[prshift+RenderY] + t[shift+Y] - xp * ptb - yp * ptd + yp;
			r[rshift + RenderTA] = pta * t[shift+TA] + ptb * t[shift+TC];
			r[rshift + RenderTB] = pta * t[shift+TB] + ptb * t[shift+TD];
			r[rshift + RenderTC] = ptc * t[shift+TA] + ptd * t[shift+TC];
		  r[rshift + RenderTD] = ptc * t[shift+TB] + ptd * t[shift+TD];
		} else {
			r[rshift + RenderX]  = t[shift+X];
			r[rshift + RenderY]  = t[shift+Y];
			r[rshift + RenderTA] = t[shift+TA];
			r[rshift + RenderTB] = t[shift+TB];
			r[rshift + RenderTC] = t[shift+TC];
			r[rshift + RenderTD] = t[shift+TD];
		}
	}
	
	inline function _setColor( id: Int, red: Float, green: Float, blue: Float, alpha: Float ) {
		var shift = _link( id, TransformShift );
		var t = transformList[_link( id, TransformLevel )];
		var rshift = _link( id, RenderShift );
		var parentId = _link( id, Parent );
		var r = renderList;
		
		t[shift + Red] = red;
		t[shift + Green] = green;
		t[shift + Blue] = blue;
		t[shift + Alpha] = alpha;
		
		if ( parentId != NULL_PARENT ) {
			var prshift = linksList[parentId + RenderShift];			
			r[rshift + RenderRed]   = r[prshift+RenderRed] * t[shift+Red];
			r[rshift + RenderGreen] = r[prshift+RenderGreen] * t[shift+Green];
			r[rshift + RenderBlue]  = r[prshift+RenderBlue] * t[shift+Blue];
			r[rshift + RenderAlpha] = r[prshift+RenderAlpha] * t[shift+Alpha];
		} else {
			r[rshift + RenderRed]   = t[shift+Red];
			r[rshift + RenderGreen] = t[shift+Green];
			r[rshift + RenderBlue]  = t[shift+Blue];
			r[rshift + RenderAlpha] = t[shift+Alpha];
		}
	}

	public inline function getAttr( id: Int, attr: Int ): Float {
		return transformList[_link( id, TransformLevel )][_link( id, TransformShift ) + attr];
	}

	public function setAttr( id: Int, attr: Int, val: Float ): Float { 
		switch( attr ) {
			case X: 
		}
		return val;
	}
}

