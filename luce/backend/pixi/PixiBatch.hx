/* TODO
package luce.backend.pixi;

import luce.Batch;
import luce.Widget;

import pixi.extras.AnimatedSprite;

class PixiBatch extends Batch {
	public var sprites = new Array<Sprites>();
//	public var container = new  

	public function new( atlas: Atlas, scissorRect: Array<Float> ) {
		super( atlas, scissorRect );
		parent.addChild( spritemap );
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		var frames = args.frames;
		if ( frames == null ) {
			var framesList = args.frames;
			if ( framesList == null )	{
				frames = Widget.NULL_STRINGS; 
			} else {
				frames = [];
				for ( frameId in framesList ) {
					frames.push( this.atlas.ids[frameId] );
				}
			}
		}
		sprites.push( new AnimatedSprite( frames ));
		return super.newWidget( args );
	}
	
	override public function setCenter( centerX: Float, centerY: Float ) {
		for ( sprite in sprites ) {
			sprite.x += centerX - this.centerX;
			sprite.y += centerY - this.centerY;
		}
		super.setCenter( centerX, centerY );
	}

	override inline public function setX( index: Int, v: Float )  { 
		super.setX( index, v ); 
		sprites[index].x = getRList( index, 0 ) - atlas.centers[sprites[index].id][0];
	}
	
	override inline public function setY( index: Int, v: Float )  { 
		super.setY( index, v ); 
		sprites[index].y = getRList( index, 1 ) - atlas.centers[sprites[index].id][1];
	}

	override inline public function setFrame( index: Int, v: Float )  { 
		super.setFrame( index, v ); 
		sprites[index].id = Std.int( v );
		sprites[index].x = getRList( index, 0 ) - atlas.centers[sprites[index].id][0];
		sprites[index].y = getRList( index, 1 ) - atlas.centers[sprites[index].id][1];
	}
}
*/
