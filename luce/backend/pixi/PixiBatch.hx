package luce.backend.pixi;

import luce.Batch;
import luce.Widget;

import pixi.sprites.Sprite;
import pixi.display.Container;

class PixiBatch extends Batch {
	public var pixiSprites(default,null) = new Array<Sprite>();
	public var pixiAtlas(default,null): PixiAtlas;
	public var pixiParent(default,null): Container;

	public function new( atlas: PixiAtlas, scissorRect: Array<Float>, parent?: Container ) {
		super( atlas, scissorRect );
		this.pixiAtlas = atlas;
		this.pixiParent = parent != null ? parent : new Container();
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		var sprite = new Sprite();
		sprite.anchor.x = 0.5;
		sprite.anchor.y = 0.5;
		pixiSprites.push( sprite );
		pixiParent.addChild( sprite );
		return super.newWidget( args );
	}
	
	override public function setCenter( centerX: Float, centerY: Float ) {
		for ( sprite in pixiSprites ) {
			sprite.x += centerX - this.centerX;
			sprite.y += centerY - this.centerY;
		}
		super.setCenter( centerX, centerY );
	}

	override inline public function setX( index: Int, v: Float )  { 
		super.setX( index, v ); 
		pixiSprites[index].x = getRList( index, 0 );
	}
	
	override inline public function setY( index: Int, v: Float )  { 
		super.setY( index, v ); 
		pixiSprites[index].y = getRList( index, 1 );
	}

	override inline public function setFrame( index: Int, v: Float )  { 
		super.setFrame( index, v ); 
		pixiSprites[index].texture = pixiAtlas.textures[Std.int( v )] || pixiAtlas.textures[0];
		pixiSprites[index].x = getRList( index, 0 );// - atlas.centers[sprites[index].id][0];
		pixiSprites[index].y = getRList( index, 1 );// - atlas.centers[sprites[index].id][1];
	}
}
