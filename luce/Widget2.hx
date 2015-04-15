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
	?onPress: Widget->Void,
	?onRelease: Widget->Void,
	?onStop: Widget->Void,
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
	public inline static var X: Int = 0;
	public inline static var Y: Int = 1;
	public inline static var Frame: Int = 2;
	public inline static var XScl: Int = 3;
	public inline static var YScl: Int = 4;
	public inline static var XSkw: Int = 5;
	public inline static var YSkw: Int = 6;
	public inline static var Rot: Int = 7;
	public inline static var Red: Int = 8;
	public inline static var Blue: Int = 9;
	public inline static var Green: Int = 10;
	public inline static var Alpha: Int = 11;
	public inline static var XPiv: Int = 12;
	public inline static var YPiv: Int = 13;
	public inline static var Visible: Int = 14; // only for parent/children

	public inline static var N_ATTR: Int = 14;

	// Data fields
	public var attr(default,null) = new Vector<Float>( N_ATTR ); 
	public var attrWld(default,null) = new Vector<Float>( N_ATTR ); 
	public var frameIdx(default,null): Float = 0;
	public var framesList(default,null): Array<Float> = NULL_FRAMES;
	public var parent(default,null) = new Vector<Widget>( N_ATTR+1 );
	public var children(default,null) = new Array<Widget>();
	public var flags(default,null): Int = 0;
	public var hit(default,null): Array<Float> = null;
	public var sin_(default,null): Float = 0;
	public var cos_(default,null): Float = 0;
	public var shift(default,null): Int;
	public var batch(default,null): Batch;
	public var onPointer: Widget->Float->Float->Int->Bool = onPointerDoNothing;
	
	// Flags
	public inline static var Invisible: Int = 1 << 0;
	public inline static var NotPointable: Int = 1 << 1;
	public inline static var NotCentred: Int = 1 << 2;
	public inline static var Rotated: Int = 1 << 3;

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
	public var green(get,set): Float;     public inline function get_green() return getAttr( Green )
	public var blue(get,set): Float;      public inline function get_blue() return getAttr( Blue );
	public var alpha(get,set): Float;     public inline function get_alpha() return getAttr( Alpha )
	public var xpiv(get,set): Float;      public inline function get_xpiv() return getAttr( XPiv );
	public var ypiv(get,set): Float;      public inline function get_ypiv() return getAttr( YPiv );
	public var visible(get,set): Bool;    public inline function get_visible() return !testFlag( Invisible );
	
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
	public var visibleWld(get,null):Bool; public inline function get_visibleWld() return !testFlag( Invisible ) && ( !parent[Visible] || !parent[Visible].testFlag( Invisible ));
	
	public var pointable(get,set): Bool;  public inline function get_pointable() return hit != null && !testFlag( NotPointable );

	inline function testFlag( flag: Int ) return ( flags & flag ) != 0;
	inline function unsetFlag( flag: Int ) flags &= ~flag;
	inline function setFlag( flag: Int ) flags |= flag; 
	
	public inline function get_lastFrame() return framesList.length - 1;
	
	// Setters
	public inline function set_x(v)     { attr[X] = v; updateX(); updateChildren( X ); return v; }
	public inline function set_y(v)     { attr[Y] = v; updateY(); updateChildren( Y ); return v; }
	public inline function set_frame(v) { attr[Frame] = v; updateFrame(); updateChildren( Frame ); return v; }
	public inline function set_xscl(v)  { attr[XScl] = v; updateXScl(); updateChildren( XScl ); return v; }
	public inline function set_yscl(v)  { attr[YScl] = v; updateYScl(); updateChildren( YScl ); return v; }
	public inline function set_xskw(v)  { attr[XSkw] = v; updateXSkw(); updateChildren( XSkw ); return v; }
	public inline function set_yskw(v)  { attr[YSkw] = v; updateYSkw(); updateChildren( YSkw ); return v; }
	public inline function set_rot(v)   { attr[Rot] = v; updateRot(); updateChildren( Rot ); return v; }
	public inline function set_red(v)   { attr[Red] = v; updateRed(); updateChildren( Red ); return v; }
	public inline function set_green(v) { attr[Green] = v; updateGreen(); updateChildren( Green ); return v; }
	public inline function set_blue(v)  { attr[Blue] = v; updateBlue(); updateChildren( Blue ); return v; }
	public inline function set_alpha(v) { attr[Alpha] = v; updateAlpha(); updateChildren( Alpha ); return v; }
	public inline function set_xpiv(v)  { attr[XPiv] = v; updateCentred(); updateChildren( XPiv ); return v; }
	public inline function set_ypiv(v)  { attr[YPiv] = v; updateCentred(); updateChildren( YPiv ); return v; }
	
	public inline function set_visible( visible: Bool ) { 
		if ( visible ) unsetFlag( Invisible ) else setFlag( Invisible );
		updateFrame(); 
		updateChildren( Visible ); 
		return visible; 
	}

	public inline function set_pointable( v: Bool ) {
		if ( v ) unsetFlag( NotPointable ) else setFlag( NotPointable ); 
		return v;
	} 

	public inline function pointInside( xp: Float, yp: Float ) {
		var wx = xWld;
		var wy = yWld;
		return xp >= wx + hit[0] && yp >= wy + hit[1] && xp <= wx+hit[2] && yp <= wy+hit[3]; 
	}

	public inline function setAttr( attr: Int, v: Float ) {
		this.attr[attr] = v;
		updateAttr( attr );
		updateChildren( attr );
	}

	inline function updateCentred() {
		if ( xpivWld == 0.0 && ypivWld == 0.0 ) {
			unsetFlag( NotCentred );
			batch.setX( shift, xWld );
			batch.setY( shift, yWld );
		}	else {
			setFlag( NotCentred );
			updatePivot();
		}
	}

	inline function updatePivot() {
		batch.setX( shift, xWld - xpivWld*batch.getTA( shift ) - ypivWld*batch.getTC( shift ) + xpivWld);
		batch.setY( shift, yWld - xpivWld*batch.getTB( shift ) - ypivWld*batch.getTD( shift ) + ypivWld);
	}

	inline function updateX() {
		if ( testFlag( NotCentred )) {
			updatePivot();
		} else {
			batch.setX( shift, xWld );
		}
	}

	inline function updateY() {
		if ( testFlag( NotCentred )) {
			updatePivot();
		} else {
			batch.setY( shift, yWld );
		}
	}

	inline function updateXScl() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * xsclWld - sin_ * yskwWld );
			batch.setTB( shift, sin_ * xsclWld + cos_ * yskwWld );
		} else {
			batch.setTA( shift, xsclWld );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}

	inline function updateYScl() {
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * xskwWld - sin_ * ysclWld );
			batch.setTD( shift, sin_ * xskwWld + cos_ * ysclWld );
		} else {
			batch.setTD( shift, ysclWld );
		}
		if ( testFlag( NotCentred ) ) {
			updatePivot();
		}
	}

	inline function updateXSkw() {
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * xskwWld - sin_ * ysclWld );
			batch.setTD( shift, sin_ * xskwWld + cos_ * ysclWld );
		} else {
			batch.setTC( shift, xskwWld );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}
	
	inline function updateYSkw() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * xsclWld - sin_ * yskwWld );
			batch.setTB( shift, sin_ * xsclWld + cos_ * yskwWld );
		} else {
			batch.setTB( shift, yskwWld );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}

	inline function updateTransform() {
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
			updatePivot();
		}
	}
	
	inline function updateRot() {
		// TODO: Lookup math
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
		updateTransform();
	}


	inline function updateFrame() {
		frameIdx = visibleWld ? framesList[Std.int( frameWld )] : Atlas.NULL; 
		batch.setFrame( shift, frameIdx ); 
	}

	inline function updateRed()   batch.setR( shift, redWld );
	inline function updateGreen() batch.setG( shift, greenWld );
	inline function updateBlue()  batch.setB( shift, blueWld );
	inline function updateAlpha() batch.setA( shift, alphaWld );
	
	inline function updateColor() { 
		updateRed();
		updateGreen();
		updateBlue();
		updateAlpha();
	}

	inline function updateAttr( attr_: Int ) {
		switch( attr_ ) {
			case X: updateX(); 
			case Y: updateY();
			case Red: updateRed();
			case Green: updateGreen();
			case Blue: updateBlue();
			case Alpha: updateAlpha();
			case XScl: updateXScl();
			case YScl: updateYScl();
			case XSkw: updateXSkw();
			case YSkw: updateYSkw();
			case Rot: updateRot();
			case Frame, Visible: updateFrame();		
			case XPiv, YPiv: updateCentred(); if ( testFlag( NotCentred )) updatePivot();
		}
	}
	
	function updateAll() {
		updateColor();	
		updateCentred();	
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
		if ( child.parent[attr] != null ) {
			parent.removeChild( child, attr, centrify );
		}
		children.push( child );
		child.parent[attr] = this;
		if ( attr != Visible ) {
			if ( centrify == true ) {
				child.attr[attr] -= this.attrWld[attr];
			}
			child.attrWld[attr] = child.attr[attr] + this.attrWld[attr];
		}
		
		child.updateAttr( attr );
		child.updateChildren( attr );
	}

	public function removeChild( child: Widget, attr: Int, ?centrify: Bool ) {
		var i = children.indexOf( child );
		if ( i >= 0 ) {
			var child = children[i];
			if ( child.parent[attr] = this ) {
				if ( attr != Visible ) {
					if ( centrify == true ) {
						child.attr[attr] += this.attrWld[attr];
					}
					child.attrWld[attr] = child.attr[attr];
				}
				child.parent[attr] = null;
				child.splice( i, 1 );
			}
		}
	}

	public function updateChildren( attr: Int ) {
		for ( i in 0...children.length ) {
			var child = children[i];
			if ( child.parent[attr] == this ) {
				child.attrWld[attr] = child.attr[attr] + this.attrWld[attr];
				child.updateAttr( attr );
				child.updateChildren( attr );
			}
		}
	}

	public inline function isPointable() return !testFlag( NotPointable ) && hit != null;

	public inline function setPos( x: Float, y: Float ) { set_x( x ); set_y( y );}
	public inline function setRGB( r: Float, g: Float, b: Float ) { set_red( r ); set_green( g ); set_blue( b ); }
	public inline function setPiv( x: Float, y: Float ) { set_xpiv( x ); set_ypiv( y );}
	public inline function setPivTo( w: Widget ) setPiv( w.x - x, w.y - y );
	
	public inline function setScl( x: Float, y: Float ) { attr[XScl] = x; attr[YScl] = y; updateTransform();}
	public inline function setSclByFrameWidth( w: Float ) { attr[XScl] = w/getFrameWidth(); updateTransform(); }
	public inline function setSclByFrameHeight( h: Float ) { attr[YScl] = h/getFrameHeight(); updateTransform(); }
	public inline function setSclByFrame( w: Float, h: Float ) { setScl( w/getFrameWidth(), h/getFrameHeight()); }

	public inline function setSkw( x: Float, y: Float ) { attr[XSkw] = xskw; attr[YSkw] = yskw; updateTransform(); }
	public inline function setXSkwAngle( a: Float ) { attr[XSkw] = Math.tan( a ); updateXSkw();}
	public inline function setYSkwAngle( b: Float ) { attr[YSkw] = Math.tan( b ); updateYSkw();}
	public inline function setSkwAngle( a: Float, b: Float ) { attr[XSkw] = Math.tan( a ); attr[YSkw] = Math.tan( b ); updateTransform();}

	public inline function setTransform( xscl: Float, yskw: Float, xskw: Float, yscl: Float ) { 
		attr[XScl] = xscl; attr[YSkw] = yskw; attr[XSkw] = xskw; attr[YScl] = yscl; 
		updateTransform();
	}
	
	public inline function setIdentityTransform() { 
		attr[XScl] = 1; attr[YSkw] = 0; attr[XSkw] = 0; attr[YScl] = 1; 
		updateTransform();
	}
	
	public inline function applyTransform( a: Float, b: Float, c: Float, d: Float ) { 
		var xscl = attr[XScl]; var yskw = attr[YSkw]; var xskw = attr[XSkw]; var yscl = attr[YScl];
		attr[XScl] = xscl*a + yskw*c; attr[YSkw] = xscl*b + yskw*d; attr[XSkw] = xskw*a + yscl*c; attr[YScl] = xskw*b + yscl*d; 
		updateTransform();
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

	public inline function setNextFrame() { attr[Frame] = (attr[Frame]+1) % framesList.length; updateFrame(); }
	public inline function setPrevFrame() { attr[Frame] = (attr[Frame]-1) % framesList.length; updateFrame(); }
	public inline function setFirstFrame(){ attr[Frame] = 0; updateFrame(); }
	public inline function setLastFrame() { attr[Frame] = framesList.length - 1; updateFrame(); }
	public inline function getLastFrame() return framesList.length-1;

	public inline function getFrameWidth()  return batch.atlas.rects[Std.int( frameIdx )].width;
	public inline function getFrameHeight() return batch.atlas.rects[Std.int( frameIdx )].height;
	public inline function getActualFrameWidth()  return batch.atlas.rects[Std.int( framesList[Std.int( frameWld )] )].width;
	public inline function getActualFrameHeight() return batch.atlas.rects[Std.int( framesList[Std.int( frameWld )] )].height;
   
	public inline function move ( attr: Int, target: Float, length: Float, ease: Int, after: Int ) { return Tween.move( this, attr, target, length, ease, after ); }
	public inline function move2( attr: Int, pairsList: Array<Float>, ease: Int, after: Int ) { return Tween.move2( this, attr, pairsList, ease, after ); }
	public inline function move3( attr: Int, pairsList: Array<Float>, after: Int ) { return Tween.move3( this, attr, pairsList, after ); }

	function setFramesList( l: Array<Float> ) {
		framesList = l;
		frame = 0;
	}
	
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

		if ( args.visible == false ) {
			setFlag( Invisible );
		}

		if ( args.frames != null && args.frames != NULL_STRINGS  ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.framesList != null ) {
			framesList = args.framesList;
		} 
		
		updateAll();
		
		if ( args.hit != null ) {
			hit = args.hit;
		} else if ( args.hitFromFrame != null ) {
			var f = framesList.length > args.hitFromFrame ? Std.int( framesList[args.hitFromFrame] ) : 0;
			var w = batch.atlas.rects[f].width; 
			var h = batch.atlas.rects[f].height;
			hit = [-0.5*w,-0.5*h,0.5*w,0.5*h];
		}

		if ( args.parent != null ) {
			addParentLinks( args.parent );
		}

		if ( args.pivTo != null ) {
			setPivTo( args.pivTo );
		}
	}

	public function new( batch: Batch, shift: Int, ?args: WidgetConfig ) {
		this.batch = batch;
		this.shift = shift;
		for ( i in 0...N_ATTR ) {
			attrWld[i] = attr[i];
		}
	 	if ( args != null ) {	
			init( args );
		}
	}
}
