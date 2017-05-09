package luce.backend.pixi;

import pixi.textures.Texture;
import pixi.core.math.shapes.Rectangle;
import luce.Atlas;

class PixiAtlas extends Atlas {
	public var baseTexture(default,null): Texture;
	public var textures(default,null) = new Array<Texture>();

	public function new( base: Texture ) {
		super()
		this.baseTexture = base;
	}

	override function addNullFrame() {
		textures.push( Texture.EMPTY );
	}

	public function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float, srcX: Float, srcY: Float, srcW: Float, srcH: Float ) {
		super( key, x, y, w, h, cx, cy, srcX, srcY, srcW, srcH );
		var texture = new Texture( this.baseTexture,
				new Rectangle( x, y, w, h ),
				new Rectangle( 0, 0, srcW, srcH ),
				new Rectangle( srcX, srcY, w, h ), false );
		textures.push( texture );
	}
}
