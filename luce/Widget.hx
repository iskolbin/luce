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
	?toggle: Bool,
	?visible: Bool,
	?hit: Array<Float>,
	?block: Bool,
	?onPress: Widget->Void,
	?onRelease: Widget->Void,
	?onStop: Widget->Void,
	?frames: Array<String>,
	?framesList: Array<Float>,
	?parent: LinksStruct,
	?text: Text.TextConfig,
	?grid: Grid.GridConfig,
	?ninepatch: NinePatch.NinePatchConfig,
}

private class WidgetLink {
	public var widget: Widget;
	public var attrInit: Float;
	public inline function new( widget, attrInit ) {
		this.widget = widget;
		this.attrInit = attrInit;
	}
}

class Widget implements Tween.Tweenable {
	static var NULL_FRAMES:Array<Float> = [0];
	static var NULL_ARGS:WidgetConfig = {};

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

	public inline static var N_ATTR: Int = 14;

	var attr = new Vector<Float>( N_ATTR );
	var attrAdd = new Vector<Float>( N_ATTR );

	public var frameIdx(default,null): Float = 0;
	var framesList: Array<Float> = null;
	var links = { 
		var links = new Vector<Array<WidgetLink>>( N_ATTR );
		for ( i in 0...N_ATTR ) links[i] = new Array<WidgetLink>();
		links;
	}
	var sin_: Float = 0;
	var cos_: Float = 0;
	var shift: Int;

	public inline static var Invisible: Int = 1 << 0;
	public inline static var InvisibleAdd: Int = 1 << 1;
	public inline static var Block: Int = 1 << 2;
	public inline static var NotCentred: Int = 1 << 3;
	public inline static var Disabled: Int = 1 << 4;
	public inline static var Rotated: Int = 1 << 5;

	public inline static var Active = 0;
	public inline static var Press = 1;
	public inline static var Disable = 2;

	public inline static var LAST_FRAME = -1;
	public inline static var DEFAULT_FPS = 24.;

	public static var pressDelay(default,default) = 300;

	public var flags(default,null): Int = 0;
	public var x(get,set): Float;
	public var y(get,set): Float;
	public var frame(get,set): Float;
	public var xscl(get,set): Float;
	public var yscl(get,set): Float;
	public var xskw(get,set): Float;
	public var yskw(get,set): Float;
	public var rot(get,set): Float;
	public var red(get,set): Float;
	public var green(get,set): Float;
	public var blue(get,set): Float;
	public var alpha(get,set): Float;
	public var xpiv(get,set): Float;
	public var ypiv(get,set): Float;

	public var toggle(default,null): Bool = false;
	public var hit(default,null): Array<Float> = null;

	public var block(get,set): Bool;
	public var disabled(get,set): Bool;
	public var enabled(get,set): Bool;
	public var visible(get,set): Bool;

	static function doNothing( self: Widget ): Void {} 

	public var onPress: Widget->Void = doNothing;
	public var onRelease: Widget->Void = doNothing;

	var visibleLink: Array<Widget>;

	inline function testFlag( flag: Int ) return ( flags & flag ) != 0;
	inline function unsetFlag( flag: Int ) flags &= ~flag;
	inline function setFlag( flag: Int ) flags |= flag; 

	public inline function get_x() return getAttr( X );
	public inline function get_y() return getAttr( Y );
	public inline function get_frame() return getAttr( Frame );
	public inline function get_xscl() return getAttr( XScl );
	public inline function get_yscl() return getAttr( YScl );
	public inline function get_xskw() return getAttr( XSkw );
	public inline function get_yskw() return getAttr( YSkw );
	public inline function get_rot() return getAttr( Rot );
	public inline function get_red() return getAttr( Red );
	public inline function get_green() return getAttr( Green );
	public inline function get_blue() return getAttr( Blue );
	public inline function get_alpha() return getAttr( Alpha );
	public inline function get_xpiv() return getAttr( XPiv );
	public inline function get_ypiv() return getAttr( YPiv );
	public inline function get_lastFrame() return framesList.length - 1;
	public inline function get_visible() return !testFlag( Invisible );
	public inline function get_disabled() return testFlag( Disabled );
	public inline function get_enabled() return !get_disabled();
	public inline function get_block() return testFlag( Block );

	public inline function set_x(v) { attr[X] = v; updateX(); updateLink( X ); return v; }
	public inline function set_y(v) { attr[Y] = v; updateY(); updateLink( Y ); return v; }
	public inline function set_frame(v) { attr[Frame] = v; updateFrame(); updateLink( Frame ); return v; }
	public inline function set_xscl(v) { attr[XScl] = v; updateXScl(); updateLink( XScl ); return v; }
	public inline function set_yscl(v) { attr[YScl] = v; updateYScl(); updateLink( YScl ); return v; }
	public inline function set_xskw(v) { attr[XSkw] = v; updateXSkw(); updateLink( XSkw ); return v; }
	public inline function set_yskw(v) { attr[YSkw] = v; updateYSkw(); updateLink( YSkw ); return v; }
	public inline function set_rot(v) { attr[Rot] = v; updateRot(); updateLink( Rot ); return v; }
	public inline function set_red(v) { attr[Red] = v; batch.setR( shift, v + attrAdd[Red] ); updateLink( Red ); return v; }
	public inline function set_green(v) { attr[Green] = v; batch.setG( shift, v + attrAdd[Green] ); updateLink( Green ); return v; }
	public inline function set_blue(v) { attr[Blue] = v; batch.setB( shift, v + attrAdd[Blue] ); updateLink( Blue ); return v; }
	public inline function set_alpha(v) { attr[Alpha] = v; batch.setA( shift, v + attrAdd[Alpha] );return v; }
	public inline function set_xpiv(v) { attr[XPiv] = v; updateCentred(); if (testFlag( NotCentred )) updatePivot(); updateLink( XPiv ); return v; }
	public inline function set_ypiv(v) { attr[YPiv] = v; updateCentred(); if (testFlag( NotCentred )) updatePivot(); updateLink( YPiv ); return v; }
	public inline function set_disabled( disabled: Bool ) {
		if ( disabled ) setFlag( Disabled ) else unsetFlag( Disabled );
		frame = disabled ? Disable : Active ; 
		return disabled; }
	public inline function set_enabled( enabled: Bool ) return set_disabled( !enabled );
	public inline function set_visible( visible: Bool ) { 
		if ( visible ) unsetFlag( Invisible ) else setFlag( Invisible );
		updateFrame(); 
		updateVisibleLink(); 
		return visible; }
	public inline function set_block( block: Bool ) { 
		if ( block ) setFlag( Block ) else unsetFlag( Block ); 
		return block; }

	public var batch(default,null): Batch;
	
	public inline function getAttr( attr: Int ) return this.attr[attr];
	inline function sum( attr: Int ) return this.attr[attr] + this.attrAdd[attr];
	public inline function getAttrWorld( attr: Int ) return sum( attr );

	public inline function pointInside( xp: Float, yp: Float ) {
		var wx = sum( X );
		var wy = sum( Y );
		return xp >= wx + hit[0] && yp >= wy + hit[1] && xp <= wx+hit[2] && yp <= wy+hit[3]; 
	}

	public inline function setAttr( attr: Int, v: Float ) {
		this.attr[attr] = v;
		updateAttr( attr );
		updateLink( attr );
	}

	inline function updateCentred() if ( sum( XPiv ) == 0.0 && sum( YPiv ) == 0.0 ) unsetFlag( NotCentred ) else setFlag( NotCentred );

	inline function updatePivot() {
		batch.setX( shift, sum(X) + sum(XPiv)*batch.getTA( shift ) + sum(YPiv)*batch.getTB( shift ) - sum(XPiv));
		batch.setY( shift, sum(Y) + sum(XPiv)*batch.getTC( shift ) + sum(YPiv)*batch.getTD( shift ) - sum(YPiv));
	}

	inline function updateX() {
		if ( testFlag( NotCentred )) {
			updatePivot();
		} else {
			batch.setX( shift, sum(X));
		}
	}

	inline function updateY() {
		if ( testFlag( NotCentred )) {
			updatePivot();
		} else {
			batch.setY( shift, sum(Y));
		}
	}

	inline function updateXScl() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * sum(XScl) - sin_ * sum(YSkw) );
			batch.setTB( shift, sin_ * sum(XScl) + cos_ * sum(YSkw) );
		} else {
			batch.setTA( shift, sum(XScl) );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}

	inline function updateYScl() {
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * sum(XSkw) - sin_ * sum(YScl) );
			batch.setTD( shift, sin_ * sum(XSkw) + cos_ * sum(YScl) );
		} else {
			batch.setTD( shift, sum(YScl) );
		}
		if ( testFlag( NotCentred ) ) {
			updatePivot();
		}
	}

	inline function updateXSkw() {
		if ( testFlag( Rotated )) {
			batch.setTC( shift, cos_ * sum(XSkw) - sin_ * sum(YScl) );
			batch.setTD( shift, sin_ * sum(XSkw) + cos_ * sum(YScl) );
		} else {
			batch.setTC( shift, sum(XSkw) );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}
	
	inline function updateYSkw() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * sum(XScl) - sin_ * sum(YSkw) );
			batch.setTB( shift, sin_ * sum(XScl) + cos_ * sum(YSkw) );
		} else {
			batch.setTB( shift, sum(YSkw) );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}

	inline function updateTransform() {
		if ( testFlag( Rotated )) {
			batch.setTA( shift, cos_ * sum(XScl) - sin_ * sum(YSkw) );
			batch.setTC( shift, cos_ * sum(XSkw) - sin_ * sum(YScl) );
			batch.setTB( shift, sin_ * sum(XScl) + cos_ * sum(YSkw) );
			batch.setTD( shift, sin_ * sum(XSkw) + cos_ * sum(YScl) );
		} else {
			batch.setTA( shift, sum(XScl) );
			batch.setTC( shift, sum(XSkw) );
			batch.setTB( shift, sum(YSkw) );
			batch.setTD( shift, sum(YScl) );
		}
		if ( testFlag( NotCentred )) {
			updatePivot();
		}
	}
	
	inline function updateRot() {
		// TODO: Lookup math
		var rot_ = sum(Rot);
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
		frameIdx = (!testFlag( Invisible ) && !testFlag( InvisibleAdd )) ? framesList[Std.int( attr[Frame] + attrAdd[Frame] )] : Atlas.NULL; 
		batch.setFrame( shift, frameIdx ); 
	}
	
	inline function updateAttr( attr_: Int ) {
		switch( attr_ ) {
			case X: updateX(); 
			case Y: updateY();
			case Red: batch.setR( shift, sum(Red) );
			case Green: batch.setG( shift, sum(Green) );
			case Blue: batch.setB( shift, sum(Blue) );
			case Alpha: batch.setA( shift, sum(Alpha) );
			case XScl: updateXScl();
			case YScl: updateYScl();
			case XSkw: updateXSkw();
			case YSkw: updateYSkw();
			case Rot: updateRot();
			case Frame: updateFrame();		
			case XPiv, YPiv: updateCentred(); if ( testFlag( NotCentred )) updatePivot();
		}
	}
	
	function updateAll() {
		batch.setR( shift, sum(Red)	);
		batch.setG( shift, sum(Green) );
		batch.setB( shift, sum(Blue) );
		batch.setA( shift, sum(Alpha) );
	
		updateCentred();	
		updateRot();
		updatePivot();
		updateFrame();
	}

	public function addLink( child: Widget, attr: Int, ?centrify: Bool ) {
		if ( centrify == true ) {
			links[attr].push( new WidgetLink( child, 0 ));
		} else {
			links[attr].push( new WidgetLink( child, this.attr[attr] + this.attrAdd[attr] ));
		}
	}

	public function addVisibleLink( child: Widget ) {
		if ( visibleLink == null ) {
			visibleLink = new Array<Widget>();
		}

		visibleLink.push( child );
		
		updateSingleVisibleLink( visibleLink.length-1 );
	}

	public function removeVisibleLink( child: Widget ) {
		if ( visibleLink != null ) {
			var idx = visibleLink.indexOf( child );
			if ( idx >= 0 ) {
				visibleLink.splice( idx, 1 );
			}
		}
	}

	public function removeLink( child: Widget, attr: Int ) {
		for ( i in 0...links[attr].length ) {
			if ( links[attr][i].widget == child ) {
				links[attr][i].widget.attrAdd[attr] = 0;
				links[attr].splice( i, 1 );
				break;
			}
		}
	}

	public function updateLink( attr: Int ) {
		for ( i in 0...links[attr].length ) {
			var link = links[attr][i];
			link.widget.attrAdd[attr] = this.attr[attr] + this.attrAdd[attr] - link.attrInit;
			link.widget.updateAttr( attr );

			link.widget.updateLink( attr );
		}
	}

	inline function updateSingleVisibleLink( i: Int ) {
		if ( testFlag( Invisible )) visibleLink[i].setFlag( InvisibleAdd ) else visibleLink[i].unsetFlag( InvisibleAdd );
		visibleLink[i].updateFrame();
		visibleLink[i].updateVisibleLink();
	}

	public function updateVisibleLink() {
		if ( visibleLink != null ) {
			for ( i in 0...visibleLink.length ) {
				updateSingleVisibleLink( i );
			}
		}
	}
	
	public inline function isButton() return onPress != doNothing || onRelease != doNothing;

	public inline function setPos( x: Float, y: Float ) { set_x( x ); set_y( y );}
	public inline function setRGB( r: Float, g: Float, b: Float ) { set_red( r ); set_green( g ); set_blue( b ); }
	public inline function setPiv( x: Float, y: Float ) { set_xpiv( x ); set_ypiv( y );}

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
		updateTransform();}
	
	public inline function setIdentityTransform() { 
		attr[XScl] = 1; attr[YSkw] = 0; attr[XSkw] = 0; attr[YScl] = 1; 
		updateTransform();}
	
	public inline function applyTransform( a: Float, b: Float, c: Float, d: Float ) { 
		var xscl = attr[XScl]; var yskw = attr[YSkw]; var xskw = attr[XSkw]; var yscl = attr[YScl];
		attr[XScl] = xscl*a + yskw*c; attr[YSkw] = xscl*b + yskw*d; attr[XSkw] = xskw*a + yscl*c; attr[YScl] = xskw*b + yscl*d; 
		updateTransform();}
	
	public inline function applyReflection( lx: Float, ly: Float ) {
		var lx2 = lx*lx; var ly2 = ly*ly; var d = 1.0 / (lx2 + ly2);
		var lxly = 2*lx*ly*d; var lx2_ly2 = (lx2 - ly2)*d;
		applyTransform( lx2_ly2, lxly, lxly, -lx2_ly2 );}
	
	public inline function applyOrthProjection( ux: Float, uy: Float ) {
		var ux2 = ux*ux; var uy2 = uy*uy;
		var d = 1.0 / (ux2 + uy2); var uxuy = 2*ux*uy*d;
		applyTransform( ux2*d, uxuy, uxuy, uy2*d );}

	public inline function setNextFrame() { attr[Frame] = (attr[Frame]+1) % framesList.length; updateFrame(); }
	public inline function setPrevFrame() { attr[Frame] = (attr[Frame]-1) % framesList.length; updateFrame(); }
	public inline function setFirstFrame() { attr[Frame] = 0; updateFrame(); }
	public inline function setLastFrame() { attr[Frame] = framesList.length - 1; updateFrame(); }
	public inline function getLastFrame() return framesList.length-1;

	public inline function getFrameWidth() return batch.atlas.rects[Std.int(frameIdx)].width;
	public inline function getFrameHeight() return batch.atlas.rects[Std.int(frameIdx)].height;
	public inline function getActualFrameWidth() return batch.atlas.rects[Std.int(framesList[Std.int(sum(Frame))])].width;
	public inline function getActualFrameHeight() return batch.atlas.rects[Std.int(framesList[Std.int(sum(Frame))])].height;
   
	public inline function move ( attr: Int, target: Float, length: Float, ease: Int, after: Int ) { return Tween.move( this, attr, target, length, ease, after ); }
	public inline function move2( attr: Int, pairsList: Array<Float>, ease: Int, after: Int ) { return Tween.move2( this, attr, pairsList, ease, after ); }
	public inline function move3( attr: Int, pairsList: Array<Float>, after: Int ) { return Tween.move3( this, attr, pairsList, after ); }

	function setFramesList( l: Array<Float> ) {
		framesList = l;
		frame = 0;
	}

	function tryRelease( t: Timer ) if ( !disabled ) release();

	public function press() {
		if ( framesList != null && framesList.length > 1 && !disabled ) {
			if( !toggle ) {
				if ( frame != Press ) {
					frame = Press;
					onPress( this );
					Timer.dcall( tryRelease, 0.3, 0 );
				}
			} else {
				if ( frame == Press ) {
					release();
				} else {
					frame = Press;
					onPress( this );
				}
			}
		}
	}

	public inline function release() {
		if ( !disabled && frame != Active ) {
			frame = Active;
			onRelease( this );
		}
	}

	public inline function addParentTransformLinks( parent: Widget, c: Bool ) {
		parent.addLink( this, X, c );
		parent.addLink( this, Y, c );
		parent.addLink( this, XScl, c );
		parent.addLink( this, YScl, c );
		parent.addLink( this, XSkw, c );
		parent.addLink( this, YSkw, c );
		parent.addLink( this, Rot, c );
		parent.addLink( this, XPiv, c );
		parent.addLink( this, YPiv, c );
	}

	public inline function addParentColorLinks( parent: Widget, c: Bool ) {
		parent.addLink( this, Red, c );
		parent.addLink( this, Green, c );
		parent.addLink( this, Blue, c );
		parent.addLink( this, Alpha, c );
	}

	public inline function addParentLinks( links: LinksStruct ) {
		var c = links.centrify == true;
		if ( links.frame != null ) links.frame.addLink( this, Frame, c );
		if ( links.transform != null ) {
			addParentTransformLinks( links.transform, c );
		} else {
			if ( links.x != null ) links.x.addLink( this, X, c );
			if ( links.y != null ) links.y.addLink( this, Y, c );
			if ( links.xscl != null ) links.xscl.addLink( this, XScl, c );
			if ( links.yscl != null ) links.yscl.addLink( this, YScl, c );
			if ( links.xskw != null ) links.xskw.addLink( this, XSkw, c );
			if ( links.yskw != null ) links.yskw.addLink( this, YSkw, c );
			if ( links.rot != null ) links.rot.addLink( this, Rot, c );
			if ( links.xpiv != null ) links.xpiv.addLink( this, XPiv, c );
			if ( links.ypiv != null ) links.ypiv.addLink( this, YPiv, c );
		}
		if ( links.color != null ) {
			addParentColorLinks( links.color, c );
		} else {
			if ( links.red != null ) links.red.addLink( this, Red, c );
			if ( links.green != null ) links.green.addLink( this, Green, c );
			if ( links.blue != null ) links.blue.addLink( this, Blue, c );
			if ( links.alpha != null ) links.alpha.addLink( this, Alpha, c );
		}
		if ( links.visible != null ) links.visible.addVisibleLink( this );
	}

	public function new( batch: Batch, shift: Int, ?args: WidgetConfig ) {
		args = args != null ? args : NULL_ARGS;
		this.batch = batch;
		this.shift = shift; 
		attr[X] = args.x != null ? args.x : 0;
		attr[Y] = args.y != null ? args.y : 0;
		attr[Frame] = args.frame != null ? args.frame : 0;
		attr[XScl] = args.xscl != null ? args.xscl : 1;
		attr[YScl] = args.yscl != null ? args.yscl : 1;
		attr[XSkw] = args.xskw != null ? args.xskw : 0;
		attr[YSkw] = args.yskw != null ? args.xskw : 0;
		attr[Rot] = args.rot != null ? args.rot : 0;
		attr[Red] = args.red != null ? args.red : 1;
		attr[Green] = args.green != null ? args.green : 1;
		attr[Blue] = args.blue != null ? args.blue : 1;
		attr[Alpha] = args.alpha != null ? args.alpha : 1;
		attr[XPiv] = args.xpiv != null ? args.xpiv : 0;
		attr[YPiv] = args.ypiv != null ? args.ypiv : 0;
			
		for ( i in 0...N_ATTR ) attrAdd[i] = 0;

		if ( args.visible == false ) {
			setFlag( Invisible );
		}

		if ( args.frames != null ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.framesList != null ) {
			framesList = args.framesList;
		} else {
			framesList = NULL_FRAMES;
		}

		updateAll();
		
		if ( args.onPress != null || args.onRelease != null ) {
			if ( args.hit != null ) {
				hit = args.hit;
			} else {
				var f = framesList.length > 0 ? Std.int( framesList[0] ) : 0;
				var w = batch.atlas.rects[f].width; 
				var h = batch.atlas.rects[f].height;
				hit = [-0.5*w,-0.5*h,0.5*w,0.5*h];
			}

			toggle = args.toggle != null ? args.toggle : false;
			block = args.block != null ? args.block : false;
			
			onPress = args.onPress != null ? args.onPress : doNothing;	
			onRelease = args.onRelease != null ? args.onRelease : doNothing;	
		}

		if ( args.parent != null ) {
			addParentLinks( args.parent );
		}
	}
}
