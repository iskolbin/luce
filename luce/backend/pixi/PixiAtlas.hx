package luce.backend.pixi;

import pixi.core.textures.Texture;
import pixi.core.textures.BaseTexture;
import pixi.core.math.shapes.Rectangle;
import luce.Atlas;

class PixiAtlas extends Atlas {
	public var baseTexture(default,null): BaseTexture;
	public var textures(default,null) = new Array<Texture>();

	public function new( base: BaseTexture ) {
		super();
		this.baseTexture = base;
	}

	override public function addFrame( key: String, x: Float, y: Float, w: Float, h: Float, cx: Float, cy: Float, srcX: Float, srcY: Float, srcW: Float, srcH: Float ) {
		super.addFrame( key, x, y, w, h, cx, cy, srcX, srcY, srcW, srcH );
		var texture = (w == 0 || h == 0 || srcW == 0 || srcH == 0) ? Texture.EMPTY : new Texture( this.baseTexture,
				new Rectangle( x, y, w, h ),
				new Rectangle( 0, 0, srcW, srcH ),
				new Rectangle( srcX, srcY, w, h ), false );
		textures.push( texture );
	}
}
