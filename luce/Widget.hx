package luce;

import luce.utils.Timer;
import luce.utils.Tween;

import haxe.ds.Vector;

private typedef LinksStruct = {
	?transform: Widget,
	?color: Widget,
	?x: Widget,
	?y: Widget,
	?frame: Widget,
	?xscl: Widget,
	?yscl: Widget,
	?xskw: Widget,
	?yskw: Widget,
	?rot: Widget,
	?red: Widget,
	?green: Widget,
	?blue: Widget,
	?alpha: Widget,
	?xpiv: Widget,
	?ypiv: Widget,
	?visible: Widget,
	?centrify: Bool,
}

typedef WidgetConfig = {
	?name: String,
	?x: Float,
	?y: Float,
	?frame: Float,
	?xscl: Float,
	?yscl: Float,
	?xskw: Float,
	?yskw: Float,
	?rot: Float,
	?red: Float,
	?green: Float,
	?blue: Float,
	?alpha: Float,
	?xpiv: Float,
	?ypiv: Float,
	?visible: Bool,
	?hit: Array<Float>,
	?hitFromFrame: Int,
	//?onPress: Widget->Void,
	//?onRelease: Widget->Void,
	//?onStop: Widget->Void,
	?onPointer: Widget->Float->Float->Int->Bool,
	?frames: Array<String>,
	?framesList: Array<Float>,
	?parent: LinksStruct,
	?pivTo: Widget,
	?text: Text.TextConfig,
	?grid: Grid.GridConfig,
}

class Widget implements Tween.Tweenable {
	public static var NULL_FRAMES(default,null): Array<Float> = [0.0];
	public static var NULL_STRINGS(default,null) = new Array<String>();
	public static function onPointerDoNothing( self: Widget, x: Float, y: Float, msg: Int ): Bool { return true; } 
	
	// Attributes
	public inline static var X:       Int = 0;
	public inline static var Y:       Int = 1;
	public inline static var Frame:   Int = 2;
	public inline static var XScl:    Int = 3;
	public inline static var YScl:    Int = 4;
	public inline static var XSkw:    Int = 5;
	public inline static var YSkw:    Int = 6;
	public inline static var Rot:     Int = 7;
	public inline static var Red:     Int = 8;
	public inline static var Blue:    Int = 9;
	public inline static var Green:   Int = 10;
	public inline static var Alpha:   Int = 11;
	public inline static var XPiv:    Int = 12;
	public inline static var YPiv:    Int = 13;
	public inline static var Visible: Int = 14; 

	public inline static var N_ATTR: Int = 15;

	// Data fields
	public var attr(default,null)    = new Vector<Float>( N_ATTR ); 
	public var attrWld(default,null) = new Vector<Float>( N_ATTR ); 
	public var frameIdx(default,null) = 0.0;
	public var framesList(default,null): Array<Float> = NULL_FRAMES;
	public var parent(default,null)   = new Vector<Widget>( N_ATTR+1 );
	public var children(default,null) = new Vector<Array<Widget>>( N_ATTR + 1 );
	public var flags(default,null): Int = 0;
	public var hit(default,null): Array<Float> = null;
	public var sin_(default,null) = 0.0;
	public var cos_(default,null) = 0.0;
	public var shift(default,null): Int = 0;
	public var batch(default,null): Batch;
	public var onPointer: Widget->Float->Float->Int->Bool = onPointerDoNothing;
	
	// Flags
	public inline static var NotPointable: Int = 1 << 0;
	public inline static var NotCentred: Int = 1 << 1;
	public inline static var Rotated: Int = 1 << 2;

	// Localt getters
	public inline function getAttr( attr: Int )    return this.attr[attr];
	
	public var x(get,set): Float;					public inline function get_x() return getAttr( X );
	public var y(get,set): Float;         public inline function get_y() return getAttr( Y );
	public var frame(get,set): Float;     public inline function get_frame() return getAttr( Frame );
	public var xscl(get,set): Float;      public inline function get_xscl() return getAttr( XScl );
	public var yscl(get,set): Float;      public inline function get_yscl() return getAttr( YScl );
	public var xskw(get,set): Float;      public inline function get_xskw() return getAttr( XSkw );
	public var yskw(get,set): Float;      public inline function get_yskw() return getAttr( YSkw );
	public var rot(get,set): Float;       public inline function get_rot() return getAttr( Rot );
	public var red(get,set): Float;       public inline function get_red() return getAttr( Red );
	public var green(get,set): Float;     public inline function get_green() return getAttr( Green );
	public var blue(get,set): Float;      public inline function get_blue() return getAttr( Blue );
	public var alpha(get,set): Float;     public inline function get_alpha() return getAttr( Alpha );
	public var xpiv(get,set): Float;      public inline function get_xpiv() return getAttr( XPiv );
	public var ypiv(get,set): Float;      public inline function get_ypiv() return getAttr( YPiv );
	public var visible(get,set): Bool;    public inline function get_visible() return getAttr( Visible ) != 0.0;
	
	// World getters
	public inline function getAttrWld( attr: Int ) return this.attrWld[attr];
	
	public var xWld(get,null): Float;     public inline function get_xWld() return getAttrWld( X );
	public var yWld(get,null): Float;     public inline function get_yWld() return getAttrWld( Y );
	public var frameWld(get,null): Float; public inline function get_frameWld() return getAttrWld( Frame );
	public var xsclWld(get,null): Float;  public inline function get_xsclWld() return getAttrWld( XScl );
	public var ysclWld(get,null): Float;  public inline function get_ysclWld() return getAttrWld( YScl );
	public var xskwWld(get,null): Float;  public inline function get_xskwWld() return getAttrWld( XSkw );
	public var yskwWld(get,null): Float;  public inline function get_yskwWld() return getAttrWld( YSkw );
	public var rotWld(get,null): Float;   public inline function get_rotWld() return getAttrWld( Rot );
	public var redWld(get,null): Float;   public inline function get_redWld() return getAttrWld( Red );
	public var greenWld(get,null): Float; public inline function get_greenWld() return getAttrWld( Green );
	public var blueWld(get,null): Float;  public inline function get_blueWld() return getAttrWld( Blue );
	public var alphaWld(get,null): Float; public inline function get_alphaWld() return getAttrWld( Alpha );
	public var xpivWld(get,null): Float;  public inline function get_xpivWld() return getAttrWld( XPiv );
	public var ypivWld(get,null): Float;  public inline function get_ypivWld() return getAttrWld( YPiv );
	public var visibleWld(get,null):Bool; public inline function get_visibleWld() return getAttrWld( Visible ) != 0.0; 
	
	public var pointable(get,set): Bool;  public inline function get_pointable() return hit != null && !testFlag( NotPointable );

	inline function testFlag( flag: Int ) return ( flags & flag ) != 0;
	inline function unsetFlag( flag: Int ) flags &= ~flag;
	inline function setFlag( flag: Int ) flags |= flag; 
	
	public inline function get_lastFrame() return framesList.length - 1;
	
	// Setters
	public inline function set_x(v)     { setAttr( X, v ); return v; }
	public inline function set_y(v)     { setAttr( Y, v ); return v; }
	public inline function set_frame(v) { setAttr( Frame, v ); return v; }
	public inline function set_xscl(v)  { setAttr( XScl, v ); return v; }
	public inline function set_yscl(v)  { setAttr( YScl, v ); return v; }
	public inline function set_xskw(v)  { setAttr( XSkw, v ); return v; }
	public inline function set_yskw(v)  { setAttr( YSkw, v ); return v; }
	public inline function set_rot(v)   { setAttr( Rot, v ); return v; }
	public inline function set_red(v)   { setAttr( Red, v ); return v; }
	public inline function set_green(v) { setAttr( Green, v ); return v; }
	public inline function set_blue(v)  { setAttr( Blue, v ); return v; }
	public inline function set_alpha(v) { setAttr( Alpha, v ); return v; }
	public inline function set_xpiv(v)  { setAttr( XPiv, v ); return v; }
	public inline function set_ypiv(v)  { setAttr( YPiv, v ); return v; }
	public inline function set_visible( v: Bool ) { setAttr( Visible, v ? 1.0 : 0.0 ); return v; }

	public inline function set_pointable( v: Bool ) {
		if ( v ) unsetFlag( NotPointable ) else setFlag( NotPointable ); 
		return v;
	} 

	public inline function pointInside( xp: Float, yp: Float ) {
		var wx = xWld;
		var wy = yWld;
		return xp >= wx + hit[0] && yp >= wy + hit[1] && xp <= wx+hit[2] && yp <= wy+hit[3]; 
	}

	inline function updateWldAttrAdd( attr: Int ) {
		if ( parent[attr] == null ) {
			this.attrWld[attr] = this.attr[attr];
		} else {
			this.attrWld[attr] = this.attr[attr] + parent[attr].attrWld[attr];
		}
	}

	inline function updateWldAttrMul( attr: Int ) {
		if ( parent[attr] == null ) {
			this.attrWld[attr] = this.attr[attr];
		} else {
			this.attrWld[attr] = this.attr[attr] * parent[attr].attrWld[attr];
		}
	}
	
	public inline function setAttr( attr: Int, v: Float ) {
		this.attr[attr] = v;
		updateAttr( attr );
	}

	inline function _updateCentred() {
		if ( xpivWld == 0.0 && ypivWld == 0.0 ) {
			unsetFlag( NotCentred );
			batch.setX( shift, xWld );
			batch.setY( shift, yWld );
		}	else {
			setFlag( NotCentred );
			_updatePivot();
		}
	}

	inline function updateXPiv() {
		_updateCentred();
	}

	inline function updateYPiv() {
		_updateCentred();
	}

	inline function _updatePivot() {
		batch.setX( shift, xWld - xpivWld*batch.getTA( shift ) - ypivWld*batch.getTC( shift ) + xpivWld);
		batch.setY( shift, yWld - xpivWld*batch.getTB( shift ) - ypivWld*batch.getTD( shift ) + ypivWld);
	}

	inline function updateX() {
		updateWldAttrAdd( X );
		if ( testFlag( NotCentred )) {
			_updatePivot();
		} else {
			batch.setX( shift, xWld );
		}
	}

	inline function updateY() {
		updateWldAttrAdd( Y );
		if ( testFlag( NotCentred )) {
			_updatePivot();
		} else {
			batch.setY( shift, yWld );
		}
	}

	inline function updateXScl() {
		updateWldAttrMul( XScl );
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * xsclWld - sin_ * yskwWld );
			batch.setTB( shift, sin_ * xsclWld + cos_ * yskwWld );
		} else {
			batch.setTA( shift, xsclWld );
		}
		if ( testFlag( NotCentred )) {
			_updatePivot();
		}
	}

	inline function updateYScl() {
		updateWldAttrMul( YScl );
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * xskwWld - sin_ * ysclWld );
			batch.setTD( shift, sin_ * xskwWld + cos_ * ysclWld );
		} else {
			batch.setTD( shift, ysclWld );
		}
		if ( testFlag( NotCentred ) ) {
			_updatePivot();
		}
	}

	inline function updateXSkw() {
		updateWldAttrMul( XSkw );
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * xskwWld - sin_ * ysclWld );
			batch.setTD( shift, sin_ * xskwWld + cos_ * ysclWld );
		} else {
			batch.setTC( shift, xskwWld );
		}
		if ( testFlag( NotCentred )) {
			_updatePivot();
		}
	}
	
	inline function updateYSkw() {
		updateWldAttrMul( YSkw );
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * xsclWld - sin_ * yskwWld );
			batch.setTB( shift, sin_ * xsclWld + cos_ * yskwWld );
		} else {
			batch.setTB( shift, yskwWld );
		}
		if ( testFlag( NotCentred )) {
			_updatePivot();
		}
	}

	inline function _updateTransform() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * xsclWld - sin_ * yskwWld );
			batch.setTC( shift, cos_ * xskwWld - sin_ * ysclWld );
			batch.setTB( shift, sin_ * xsclWld + cos_ * yskwWld );
			batch.setTD( shift, sin_ * xskwWld + cos_ * ysclWld );
		} else {
			batch.setTA( shift, xsclWld );
			batch.setTC( shift, xskwWld );
			batch.setTB( shift, yskwWld );
			batch.setTD( shift, ysclWld );
		}
		if ( testFlag( NotCentred )) {
			_updatePivot();
		}
	}

	inline function updateRot() {
		updateWldAttrAdd( Rot );
		var rot_ = rotWld;
		if ( rot_ != 0.0 ) {
			sin_ = Math.sin( rot_ );
			cos_ = Math.cos( rot_ );
			setFlag( Rotated );
		} else {
			sin_ = 0;
			cos_ = 1;
			unsetFlag( Rotated );
		}
		_updateTransform();
	}

	inline function _updateFrameVisible() {
		frameIdx = visibleWld ? framesList[Std.int( frameWld )] : Atlas.NULL; 
		batch.setFrame( shift, frameIdx ); 
	}

	inline function updateFrame() {
		updateWldAttrAdd( Frame );
		_updateFrameVisible();
	}

	inline function updateRed()    { updateWldAttrMul( Red ); batch.setR( shift, redWld ); }
	inline function updateGreen()  { updateWldAttrMul( Green ); batch.setG( shift, greenWld ); } 
	inline function updateBlue()   { updateWldAttrMul( Blue ); batch.setB( shift, blueWld ); }
	inline function updateAlpha()  { updateWldAttrMul( Alpha ); batch.setA( shift, alphaWld ); }
	inline function updateVisible() { updateWldAttrMul( Visible ); _updateFrameVisible(); }

	static var chstck = new Vector<Int>( 256 );
	
	function updateAttr( attr_: Int ) {
		var w = this;
		var chsidx: Int = 0;
		
		//do {
			switch( attr_ ) {
				case X: w.updateX(); 
				case Y: w.updateY();
				case Red: w.updateRed();
				case Green: w.updateGreen();
				case Blue: w.updateBlue();
				case Alpha: w.updateAlpha();
				case XScl: w.updateXScl();
				case YScl: w.updateYScl();
				case XSkw: w.updateXSkw();
				case YSkw: w.updateYSkw();
				case Rot: w.updateRot();
				case Frame: w.updateFrame();		
				case XPiv: w.updateXPiv();
				case YPiv: w.updateYPiv();
				case Visible: w.updateVisible();
			}
			
		if ( children[attr_] != null ) {
			for ( c in children[attr_] ) {
				c.updateAttr( attr_ );
			}
		}
			
	/*		var cs = w.children[attr_];
			if ( cs == null ) {
				while ( chsidx > 0 && ( cs == null || chstck[chsidx] <= 0 )) {
					w = w.parent[attr_];
					chsidx -= 1;
				}	
				if ( chstck[chsidx] > 0 ) {
					chstck[chsidx] -= 1;
					w = w.children[chstck[chsidx]];
					chsidx += 1;
				}
			} else {
				chstck[chsidx] = cs.length;
				chstck[chsidx] -= 1;
				w = w.chidren[chstck[chsidx]];
				chsidx += 1;
			}
		} while ( chsidx >= 0 );
		//updateChildren( attr_ ); */
	}
	
	function updateAll() {
		updateRed();
		updateGreen();
		updateBlue();
		updateAlpha();
		updateVisible();
		_updateCentred();	
		updateRot();
		updateFrame();
	}

	public function setParent( parent: Widget, attr: Int, ?centrify: Bool ) {
		if ( parent != null ) {
			parent.addChild( this, attr, centrify );
		} else {
			if ( this.parent[attr] != null ) {
				this.parent[attr].removeChild( this, attr, centrify );
			}
		}
	}

	public function addChild( child: Widget, attr: Int, ?centrify: Bool ) {
		if ( child.parent[attr] != this ) {
			if ( child.parent[attr] != null ) {
				child.parent[attr].removeChild( child, attr, centrify );
			}
			if ( children[attr] == null ) {
				children[attr] = new Array<Widget>();
			}
			children[attr].push( child );
			child.parent[attr] = this;
			child.updateAttr( attr );
		}
	}

	public function removeChild( child: Widget, attr: Int, ?centrify: Bool ) {
		if ( children[attr] != null ) {
			var i = children[attr].indexOf( child );
			if ( i >= 0 ) {
				var child = children[attr][i];
				if ( child.parent[attr] == this ) {
					child.parent[attr] = null;
					if ( children[attr].length > 1 ) {
						children[attr].splice( i, 1 );
					} else {
						children[attr] = null;
					}
					child.updateAttr( attr );
				}
			}
		}
	}

	public inline function isPointable() return !testFlag( NotPointable ) && hit != null;

	public inline function setPos( x: Float, y: Float ) { this.x = x; this.y = y;( x );}
	public inline function setRGB( r: Float, g: Float, b: Float ) { this.red = r; this.green = g; this.blue = b; }
	public inline function setPiv( x: Float, y: Float ) { this.xpiv = x; this.ypiv = y ;}
	public inline function setPivTo( w: Widget ) setPiv( w.x - x, w.y - y );
	
	public inline function setScl( x: Float, y: Float ) { this.xscl = x; this.yscl = y; }
	public inline function setSclByFrameWidth( w: Float ) this.xscl = w/getFrameWidth();
	public inline function setSclByFrameHeight( h: Float ) this.yscl = h/getFrameHeight();
	public inline function setSclByFrame( w: Float, h: Float ) setScl( w/getFrameWidth(), h/getFrameHeight());

	public inline function setSkw( x: Float, y: Float ) { this.xskw = x; this.yskw = y; }
	public inline function setXSkwAngle( a: Float ) this.xskw = Math.tan( a );
	public inline function setYSkwAngle( b: Float ) this.yskw = Math.tan( b );
	public inline function setSkwAngle( a: Float, b: Float ) setSkw( Math.tan( a ), Math.tan( b ));

	public inline function setTransform( xscl: Float, yskw: Float, xskw: Float, yscl: Float ) { setScl( xscl, yscl ); setSkw( xskw, yskw ); }
	public inline function applyTransform( a: Float, b: Float, c: Float, d: Float ) { 
		var xscl = attr[XScl]; var yskw = attr[YSkw]; var xskw = attr[XSkw]; var yscl = attr[YScl];
		setTransform( xscl*a + yskw*c, xscl*b + yskw*d, xskw*a + yscl*c, xskw*b + yscl*d ); 
	}
	
	public inline function applyReflection( lx: Float, ly: Float ) {
		var lx2 = lx*lx; var ly2 = ly*ly; var d = 1.0 / (lx2 + ly2);
		var lxly = 2*lx*ly*d; var lx2_ly2 = (lx2 - ly2)*d;
		applyTransform( lx2_ly2, lxly, lxly, -lx2_ly2 );
	}
	
	public inline function applyOrthProjection( ux: Float, uy: Float ) {
		var ux2 = ux*ux; var uy2 = uy*uy;
		var d = 1.0 / (ux2 + uy2); var uxuy = 2*ux*uy*d;
		applyTransform( ux2*d, uxuy, uxuy, uy2*d );
	}
	
	public inline function setNextFrame()  frame = (frame+1) % framesList.length;
	public inline function setPrevFrame()  frame = (frame-1) % framesList.length;
	public inline function setFirstFrame() frame = 0; 
	public inline function setLastFrame()  frame = framesList.length - 1;
	public inline function getLastFrame()  return framesList.length-1;

	public inline function getFrameWidth()  return batch.atlas.rects[Std.int( frameIdx )].width;
	public inline function getFrameHeight() return batch.atlas.rects[Std.int( frameIdx )].height;
	public inline function getActualFrameWidth()  return batch.atlas.rects[Std.int( framesList[Std.int( frameWld )] )].width;
	public inline function getActualFrameHeight() return batch.atlas.rects[Std.int( framesList[Std.int( frameWld )] )].height;
   
	public inline function move ( attr: Int, target: Float, length: Float, ease: Int, after: Int ) return Tween.move( this, attr, target, length, ease, after ); 
	public inline function move2( attr: Int, pairsList: Array<Float>, ease: Int, after: Int ) return Tween.move2( this, attr, pairsList, ease, after ); 
	public inline function move3( attr: Int, pairsList: Array<Float>, after: Int ) return Tween.move3( this, attr, pairsList, after ); 

	public function addParentTransformLinks( parent: Widget, c: Bool ) {
		setParent( parent, X, c );
		setParent( parent, Y, c );
		setParent( parent, XScl, c );
		setParent( parent, YScl, c );
		setParent( parent, XSkw, c );
		setParent( parent, YSkw, c );
		setParent( parent, Rot, c );
		setParent( parent, XPiv, c );
		setParent( parent, YPiv, c );
	}

	public function addParentColorLinks( parent: Widget, c: Bool ) {
		setParent( parent, Red, c );
		setParent( parent, Green, c );
		setParent( parent, Blue, c );
		setParent( parent, Alpha, c );
	}

	public function addParentLinks( links: LinksStruct ) {
		var c = links.centrify == true;
		if ( links.frame != null ) links.frame.addChild( this, Frame, c );
		if ( links.transform != null ) {
			addParentTransformLinks( links.transform, c );
		} else {
			if ( links.x != null ) setParent( links.x, X, c );
			if ( links.y != null ) setParent( links.y, Y, c );
			if ( links.xscl != null ) setParent( links.xscl, XScl, c );
			if ( links.yscl != null ) setParent( links.yscl, YScl, c );
			if ( links.xskw != null ) setParent( links.xskw, XSkw, c );
			if ( links.yskw != null ) setParent( links.yskw, YSkw, c );
			if ( links.rot != null ) setParent( links.rot, Rot, c );
			if ( links.xpiv != null ) setParent( links.xpiv, XPiv, c );
			if ( links.ypiv != null ) setParent( links.ypiv, YPiv, c );
		}
		if ( links.color != null ) {
			addParentColorLinks( links.color, c );
		} else {
			if ( links.red != null ) setParent( links.red, Red, c );
			if ( links.green != null ) setParent( links.green, Green, c );
			if ( links.blue != null ) setParent( links.blue, Blue, c );
			if ( links.alpha != null ) setParent( links.alpha, Alpha, c );
		}
		if ( links.visible != null ) setParent( links.visible, Visible, c );
	}

	inline function init( args: WidgetConfig ) {
		attr[X]     = args.x != null ? args.x : 0;
		attr[Y]     = args.y != null ? args.y : 0;
		attr[Frame] = args.frame != null ? args.frame : 0;
		attr[XScl]  = args.xscl != null ? args.xscl : 1;
		attr[YScl]  = args.yscl != null ? args.yscl : 1;
		attr[XSkw]  = args.xskw != null ? args.xskw : 0;
		attr[YSkw]  = args.yskw != null ? args.xskw : 0;
		attr[Rot]   = args.rot != null ? args.rot : 0;
		attr[Red]   = args.red != null ? args.red : 1;
		attr[Green] = args.green != null ? args.green : 1;
		attr[Blue]  = args.blue != null ? args.blue : 1;
		attr[Alpha] = args.alpha != null ? args.alpha : 1;
		attr[XPiv]  = args.xpiv != null ? args.xpiv : 0;
		attr[YPiv]  = args.ypiv != null ? args.ypiv : 0;
		attr[Visible]=args.visible != null ? ( args.visible ? 1.0 : 0.0 ) : 1.0;
		
		if ( args.frames != null && args.frames != NULL_STRINGS  ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.framesList != null ) {
			framesList = args.framesList;
		} 
		
		if ( args.hit != null ) {
			hit = args.hit;
		} else if ( args.hitFromFrame != null ) {
			var f = framesList.length > args.hitFromFrame ? Std.int( framesList[args.hitFromFrame] ) : 0;
			var w = batch.atlas.rects[f].width; 
			var h = batch.atlas.rects[f].height;
			hit = [-0.5*w,-0.5*h,0.5*w,0.5*h];
		}

		if ( args.onPointer != null ) onPointer = args.onPointer;
		if ( args.parent != null ) addParentLinks( args.parent );
		if ( args.pivTo != null )  setPivTo( args.pivTo );
	
		for ( i in 0...N_ATTR ) updateAttr( i );
	}

	public function new( batch: Batch, shift: Int, ?args: WidgetConfig ) {
		this.batch = batch;
		this.shift = shift;
		for ( i in 0...N_ATTR ) { attr[i] = 0; attrWld[i] = 0; }
		for ( i in 0...parent.length ) parent[i] = null;
		for ( i in 0...children.length ) children[i] = null;
	
	 	if ( args != null ) init( args );
	}
}
