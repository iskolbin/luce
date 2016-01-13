package luce;

enum EmitterType {
	PointEmitter;
	RectEmitter( xmin: Float, ymin: Float, xmax: Float, ymax: Float );
	CircleEmitter( r: Float, cr: Float );
}

typedef EmitterConfig = {
	type: AttractorType;
	?angle: Float;
	?velocity: Float;
	?intensity: Float;
	?life: Float;
	?frame: Float;

	?angleVar: Float;
	?velocityVar: Float;
	?intensityVar: Float;
	?lifeVar: Float;
	?frameVar: Float;
}

class Emitter extends Widget {
	public var type: EmitterType;
	
	public var angle: Float;
	public var velocity: Float;
	public var intesivity: Float;
	public var life: Float;
	public var frame: Float;

	public var angleVar = 0.0;
	public var velocityVar = 0.0;
	public var intesivityVar = 0.0;
	public var lifeVar = 0.0;
	public var frameVar = 0.0;

	var creationCounter = 0.0;

	public function new() {
		
	}
}

enum AttractorType {
	PointAttractor;
}

typedef AttractorConfig = {
	type: AttractorType;
	?force: Float;
}

class Attractor extends Widget {
	public var force: Float;
	public var type: AttractorType;

	public function new() {
	}
}

class ParticleSystem {
	public var gravityx: Float;
	public var gravityy: Float;
	public var particles: Array<Float> = [];
	public var attractors: Array<Attractor> = [];
	public var emitters: Array<Emitter> = [];
	public var maxFrames: Float;

	static public inline var PARTICLE_PARAMS = 5;

	public inline function addAttractor( a: Attractor ) if ( attractors.indexOf( a ) < 0 ) attractors.push( a );
	public inline function removeAttractor( a: Attractor ) attractors.remove( a );
	public inline function addEmitter( e: Emitter ) if ( emitters.indexOf( e ) < 0 ) emitters.push( e );
	public inline function removeEmitter( e: Emitter ) emitters.remove( e ):

	inline function px( index ) return particles[shift];
	inline function py( index ) return particles[shift+1];
	inline function pvx( index ) return particles[shift+2];
	inline function pvy( index ) return particles[shift+3];
	inline function plife( index ) return particles[shift+4];
	inline function pframe( index ) return particles[shift+5];

	inline function addpx( index, dv ) particles[shift] += dv;
	inline function addpy( index, dv ) particles[shift+1] += dv;
	inline function addpvx( index,dv ) particles[shift+2] += dv;
	inline function addpvy( index, dv ) particles[shift+3] += dv;
	inline function addplife( index, dv ) particles[shift+4] += dv;
	inline function addpframe( index, dv ) {
		var frame = particles[index+5] + dv;
		if ( frmae >= maxFrames || frame < 0.0 ) {
			particles[index+5] = 0.0;
		} else {
			particles[index+5] = frame;
		}
	}

	inline function addParticle( x, y, vx, vy, life, frame ) {
		var shift = particlesCount*PARTICLE_PARAMS;
		particles[shift] = x;
		particles[shift+1] = y;
		particles[shift+2] = vx;
		particles[shift+3] = vy;
		particles[shift+4] = life;
		particles[shift+5] = ( frame > maxFrames || frame < 0.0 ) ? 0.0 : frame;
		particlesCount++;
	}

	public inline function dist2( x1: Float, y1: Float, x2: Float, y2: Float ): Float {
		var dx = x1 - x2;
		var dy = y1 - y2;
		return dx*dx + dy*dy;
	}
	
	public inline function angleBetween( x1: Float, y1: Float, x2: Float, y2: Float ): Float {
		return Math.atan( y1 - y2, x1 - x2 );
	}

	var particlesCount: Int;
	
	public inline function sin( x: Float ) return Math.sin( x );
	public inline function cos( x: Float ) return Math.cos( x );

	static inline var G_EPSILON = 0.00001;
	static inline var DEFRAG_THRESHOLD = 1000;

	inline function pmove( src: Int, dest: Int ) {
		var srcShift = PARTICLE_PARAMS*src;
		var destShift = PARTICLE_PARAMS*dest;
		for ( i in 0...PARTICLE_PARAMS ) {
			particles[destShift+i] = particles[srcShift+i];
		}
	}

	function defragParticles() {
		var j = 0;
		var n = 0;
		for ( i in 0...particlesCount ) {			
			if ( plife( i ) <= 0 ) {
				if ( n == 0 ) {
					n = 1;
					j = i;
				} else {
					n += 1;
				}
			} else {
				if ( n > 0 ) {
					pmove( i, j );
					j += 1;
				}
			}
		}
		particlesCount -= n;	
	}

	inline function generateRandom( mean: Float, variance: Float ) return mean + 2.0*(Math.random()-0.5)*variance;

	public function update( dt: Float ) {
		for ( em in emitters ) {
			em.creationCounter += em.intesivity * dt;
			if ( em.creationCounter >= 1.0 ) {
				var count = Std.int( em.creationCounter );
				em.creationCounter = Math.ffloor( em.creationCounter );
				for ( i in 0...count ) {

					var x = em.x;
					var y = em.y;

					switch ( em.type ) {
						case PointEmitter: 
						case RectEmitter( xmin, ymin, xmax, ymax ):
							x += xmin + Math.random()*( xmax - xmin );
							y += ymin + Math.random()*( ymax - ymin );
						case CircleEmitter( r, cr ):
							var r_ = cr + Math.random()*(r - cr);
							x += r * cos( r_ );
							y += r * sin( r_ );
					}

					var angle = generateRandom( em.angle, em.angleVar );
					var velocity = generateRandom( em.velocity, em.velocityVar );
					var life = generateRandom( em.life, em.lifeVar );
					var frame = generateRandom( em.frame, em.frameVar );
					if ( life > 0.0 ) {
						addParticle( x, y, velocity * cos( angle ), velocity * sin( angle ), life, frame );
					}
				}				
			}
		}
		
		var deadParticles = 0;
		for ( i in 0...particlesCount ) {
			if ( plife( i ) > 0 ) {
				addpframe( i, dv );
				addplife( i, -dv );
				var ax = gravityx;
				var ay = gravityy;
				for ( attr in attractors ) {
					var a = attr.force / dist2( attr.x, attr.y, px(i), py(i)) ;
					if ( a > G_EPSILON || a < -G_EPSILON ) {
						var angle = angleBetween( attr.x, attr.y, px(i), py(i) );
						ax += a * cos( angle );
						ay += a * sin( angle );
					}			
					addpvx( i, ax * dt );
					addpvy( i, ay * dt );
					addpx( i, pvx(i) * dt );
					addpy( i, pvy(i) * dt );
				}
			} else {
				deadParticles++;
			}
		}

		if ( deadParticles > DEFRAG_THRESHOLD ) {
			defragParticles();
		}
	}

	public function new ( maxFrames: Float ) {
		this.maxFrames = maxFrames;
	}
}
