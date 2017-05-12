package luce.backend.pixi;

import luce.Batch;
import luce.Widget;

import pixi.core.sprites.Sprite;
import pixi.core.display.Container;

class PixiBatch extends Batch {
	public var pixiSprites(default,null) = new Array<Sprite>();
	public var pixiAtlas(default,null): PixiAtlas;
	public var parent(default,null): Container;

	public function new( atlas: PixiAtlas, scissorRect: Array<Float>, parent: Container ) {
		super( atlas, scissorRect );
		this.pixiAtlas = atlas;
		this.parent = parent;
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		var sprite = new Sprite();
		sprite.anchor.x = 0.5;
		sprite.anchor.y = 0.5;
		pixiSprites.push( sprite );
		parent.addChild( sprite );
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
		pixiSprites[index].x = v + centerX;
	}
	
	override inline public function setY( index: Int, v: Float )  { 
		pixiSprites[index].y = v + centerY;
	}

	override inline public function setFrame( index: Int, v: Float )  { 
		var tIdx = Std.int( v );
		var ts = this.pixiAtlas.textures;
		pixiSprites[index].texture = tIdx < ts.length ? ts[tIdx] : ts[0];
	}
}
