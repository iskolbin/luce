package luce.backend.html5;

import luce.Atlas;

import js.html.ImageElement;

class Html5Atlas extends Atlas {
	public var image(default,null): ImageElement;
	
	public function new( image: ImageElement ) {
		this.image = image;
		super();
	}
}

