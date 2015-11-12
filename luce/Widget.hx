package luce;

import junge.Timer;
import junge.Tween;

import haxe.ds.Vector;

typedef WidgetConfig = {
	?name: String,
	?x: Float,
	?y: Float,
	?frame: Float,
	?visible: Bool,
	?hit: Array<Float>,
	?hitFromFrame: Int,
	?onPointer: Widget->Float->Float->Int->Bool,
	?frames: Array<String>,
	?framesList: Array<Float>,
	?parent: Widget,
	?text: Text.TextConfig,
	?grid: Grid.GridConfig,
}

class Widget implements Tween.Tweenable {
	static public var NULL_FRAMES(default,null): Array<Float> = [0.0];
	static public var NULL_STRINGS(default,null) = new Array<String>();
	static public function onPointerDoNothing( self: Widget, x: Float, y: Float, msg: Int ): Bool { return true; } 
	
	// Attributes
	public inline static var X:      Int = 0;
	public inline static var Y:      Int = 1;
	public inline static var Frame:  Int = 2;

	// Data fields
	public var frameIdx(default,null) = 0.0;
	public var framesList(default,null): Array<Float> = NULL_FRAMES;
	public var parent(default,null): Widget;
	public var children(default,null): Array<Widget>;
	public var hit(default,null): Array<Float> = null;
	public var shift(default,null): Int = 0;
	public var batch(default,null): Batch;
	public var onPointer(default,set): Widget->Float->Float->Int->Bool = onPointerDoNothing;
	
	
	public var x(default,set)       = 0.0;	
	public var y(default,set)       = 0.0;
	public var frame(default,set)   = 0.0;
	public var visible(default,set) = true;

	public var xWld(default,null)       = 0.0;
	public var yWld(default,null)       = 0.0;
	public var frameWld(default,null)   = 0.0;
	public var visibleWld(default,null) = true;
	
	public var scissored(default,null) = false;
	public var pointable(get,null): Bool; 
	
	public inline function get_pointable() return onPointer != onPointerDoNothing;
	public inline function set_onPointer( v: Widget->Float->Float->Int->Bool ) {
		if ( v == null || v == onPointerDoNothing ) {
			onPointer = onPointerDoNothing;
			batch.removePointable( this );
			return onPointerDoNothing;
		} else {
			onPointer = v;
			batch.addPointable( this );
			return v;
		}			
	}

	// Setters
	public inline function set_x(v)       { this.x = v; updateX(); return v; }
	public inline function set_y(v)       { this.y = v; updateY(); return v; }
	public inline function set_frame(v)   { this.frame = v; updateFrame(); return v; }
	public inline function set_visible(v) { this.visible = v; updateVisible(); return v; }

	public inline function pointInside( xp: Float, yp: Float ) {
		return xp >= xWld + hit[0] && yp >= yWld + hit[1] && xp <= xWld+hit[2] && yp <= yWld+hit[3]; 
	}

	public inline function getAttr( attr: Int ) {
		return switch( attr ) {
			case X: x;
			case Y: y;
			case Frame: frame;
			case _: 0.0;
		}
	}

	public inline function setAttr( attr: Int, v: Float ) {
		switch ( attr ) {
			case X: x = v;
			case Y: y = v;
			case Frame: frame = v;
		}
	}

	function updateX() {
		xWld = x;
		if ( parent != null ) {
			xWld += parent.xWld; 
		}
		batch.setX( shift, xWld );
		//updateScissor();
		if ( children != null ) {
			for ( c in children ) {
				c.updateX();
			}
		}
	}

	function updateY() {
		yWld = y;
		if ( parent != null ) {
			yWld += parent.yWld; 
		}
		batch.setY( shift, yWld );
	//	updateScissor();
	
		if ( children != null ) {
			for ( c in children ) {
				c.updateY();
			}
		}
	}

	inline function updateScissor() {
		var frameIdx = framesList[Std.int( frameWld )];
		var id = Std.int( frameIdx );
		var c = batch.atlas.centers[id];
		var rect = batch.atlas.rects[id];
		var xmin = xWld - c.x;
		var ymin = yWld - c.y;
		var xmax = xmin + rect.width;
		var ymax = ymin + rect.height;

		scissored = ( xmin > batch.scrollXmax || xmax < batch.scrollXmin || ymin > batch.scrollYmax || ymax < batch.scrollYmin );
		updateFrameVisible();
	}

	inline function updateFrameVisible() {
		frameIdx = (visibleWld && !scissored) ? framesList[Std.int( frameWld )] : Atlas.NULL; 
		batch.setFrame( shift, frameIdx ); 
	}

	inline function updateFrame() {
		frameWld = frame;
		updateFrameVisible();
	}

	function updateVisible() { 
		if ( parent != null ) {
			visibleWld = visible && parent.visibleWld;
		} else {
			visibleWld = visible;
		}
		updateFrameVisible(); 
		if ( children != null ) {
			for ( c in children ) {
				c.updateVisible();
			}
		}
	}
	
	inline function updateAll() {
		updateX();
		updateY();
		updateFrame();
		updateVisible();
	}

	public function setParent( newParent: Widget ) {
		if ( parent != newParent ) {
			if ( newParent == null ) {
				parent.removeChild( this );
			} else if ( parent == null ) {
				newParent.addChild( this );
			} else {
				parent.removeChild( this );
				newParent.addChild( this );
			}
		}
	}

	public function addChild( child: Widget ) {
		if ( child.parent != this ) {
			if ( child.parent != null ) {
				child.parent.removeChild( child );
			}
			if ( children == null ) {
				children = new Array<Widget>();
				children.push( child );
				child.parent = this;
			} else {
				if ( children.indexOf( child ) == -1 ) {
					children.push( child );
					child.parent = this;
				}
			}
			child.updateAll();
		}
	}

	public function removeChild( child: Widget ) {
		if ( child.parent == this ) {	
			children.remove( child );
			child.parent = null;
			child.updateAll();
		}
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
	public inline function getFrameSourceWidth()  return batch.atlas.sourceWidth[Std.int( framesList[Std.int( frameWld )] )];
	public inline function getFrameSourceHeight() return batch.atlas.sourceHeight[Std.int( framesList[Std.int( frameWld )] )];
	
	public inline function move ( attr: Int, target: Float, length: Float, ease: Int, after: Int ) return Tween.move( this, attr, target, length, ease, after ); 
	public inline function move2( attr: Int, pairsList: Array<Float>, ease: Int, after: Int ) return Tween.move2( this, attr, pairsList, ease, after ); 
	public inline function move3( attr: Int, pairsList: Array<Float>, after: Int ) return Tween.move3( this, attr, pairsList, after ); 

	inline function init( args: WidgetConfig ) {
		x = args.x != null ? args.x : 0;
		y = args.y != null ? args.y : 0;
		visible = args.visible != null ? args.visible : true;
		
		if ( args.frames != null && args.frames != NULL_STRINGS  ) {
			framesList = batch.newFramesList( args.frames );
		} else if ( args.framesList != null ) {
			framesList = args.framesList;
		} 
		
		frame = args.frame != null ? args.frame : 0;
		
		if ( args.hit != null ) {
			hit = args.hit;
		} else if ( args.hitFromFrame != null ) {
			var f = framesList.length > args.hitFromFrame ? Std.int( framesList[args.hitFromFrame] ) : 0;
			var w = batch.atlas.rects[f].width; 
			var h = batch.atlas.rects[f].height;
			hit = [-0.5*w,-0.5*h,0.5*w,0.5*h];
		}

		if ( args.onPointer != null ) onPointer = args.onPointer;
		if ( args.parent != null ) setParent( args.parent );
	}

	public function new( batch: Batch, shift: Int, ?args: WidgetConfig ) {
		this.batch = batch;
		this.shift = shift;
	 	if ( args != null ) init( args );
	}
}
