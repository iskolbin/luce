package luce;

class AtlasPack {
	public var atlases(default,null) = new Array<Atlas>();
	public var keyToAtlas(default,null) = new Map<String,Atlas>();

	public function new( ?atlases: Array<Atlas> ) {
		if ( atlases != null ) {
			for ( atlas in atlases ) {
				add( atlas );
			}
		}
	}

	static public inline function generateFullIndex( atlasIndex: Int, imageIndex: Int ) return ( atlasIndex << 0x10 ) + imageIndex;
	static public inline function extractAtlasIndex( fullIndex: Int ) return ( fullIndex & 0x7fffffff ) >> 0x10;
	static public inline function extractImageIndex( fullIndex: Int ) return ( fullIndex & 0x0000ffff );
	
	public inline function extractAtlas( fullIndex: Int ) return atlases[extractAtlasIndex( fullIndex )];
	public inline function getAtlasIndex( atlas: Atlas ) return atlases.indexOf( atlas );
	public inline function isAtlasAdded( atlas: Atlas ) return getAtlasIndex( atlas ) < 0;

	public function add( atlas: Atlas ) {
		if ( !isAtlasAdded( atlas )) {
			var atlasIndex = atlases.length;
			var imageIndex = 0;
			atlases.push( atlas );
			for ( path in atlases.ids.keys()) {
				if ( !keyToAtlas.exists( path ) {
					keyToAtlas[path] = generateFullIndex( atlasIndex, imageIndex ); 
				} else {
					throw 'Image path "${path}" already exists in atlas with index ${getAtlasIndex( keyToAtlas[path] )}';
				}
				imageIndex += 1;
			}	
		}
	} else {
		throw 'Atlas already added as index ${getAtlasIndex( atlas )}';
	}
}
