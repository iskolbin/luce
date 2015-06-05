package luce;

import haxe.ds.Vector;

typedef ParticleConfig = {
}

class Particle extends Widget  {
	public var bufferSize(get,null): Int;
	public var textureId: Float;
	public var lifetimeMin: Float;
	public var lifetimeMax: Float;
	public var emissionRate: Float;
	public var sizeVariation: Float;
	public var linearXMin: Float;
	public var linearYMin: Float;
	public var linearXMax: Float;
	public var linearYMax: Float;
	public var linearDampX: Float;
	public var linearDampY: Float;
	public var areaSpreadDx: Float;
	public var areaSpreadDy: Float;
	public var areaSpreadUniform: Bool;
	public var direction: Float;
	public var speedX: Float;
	public var speedY: Float;


	public function new( config: ParticleConfig ) {
		 
	}

	public var updateParticles() {
		
	}
}
