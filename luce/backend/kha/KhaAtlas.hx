package luce.backend.kha;

#if kha
import luce.Atlas;

import kha.Image;

class KhaAtlas extends Atlas {
	public var image(default,null): Image;
	
	public function new( image: Image ) {
		this.image = image;
		super();
	}
}
#end
