package luce.backend.openfl;

import openfl.display.Sprite;
import openfl.display.Tilemap;
import openfl.display.Tile;
import openfl.display.Tileset;
import luce.Batch;

class OpenFlBatchTilemap extends OpenFlMinimalBatch {
	public var tilemap: Tilemap;
	public var tileset: Tileset;
	public var tiles = new Array<Tile>();

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, host: Sprite ) {
		super( atlas, scissorRect );
		tileset = new Tileset( atlas.bitmapData );
		for ( i in 0...atlas.rectsFl.length ) {
			tileset.addRect( atlas.rectsFl[i] );
		}
		if ( scissorRect == null ) {
			tilemap = new Tilemap( host.stage.stageWidth, host.stage.stageHeight, tileset );
		} else {
			tilemap = new Tilemap( Std.int(scissorRect[2] - scissorRect[0]), Std.int(scissorRect[3] - scissorRect[1]), tileset );
		}
		host.addChild( tilemap );
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		var tile = new Tile( 0, 0, 0 );
		tiles.push( tile );
		tilemap.addTile( tile );
		return super.newWidget( args );
	}
	override public function setCenter( centerX: Float, centerY: Float ) {
		for ( tile in tiles ) {
			tile.x += centerX - this.centerX;
			tile.y += centerY - this.centerY;
		}
		super.setCenter( centerX, centerY );
	}

	override inline public function setX( index: Int, v: Float )  { 
		super.setX( index, v ); 
		tiles[index].x = getRList( index, 0 ) - atlas.centers[tiles[index].id][0];
	}
	
	override inline public function setY( index: Int, v: Float )  { 
		super.setY( index, v ); 
		tiles[index].y = getRList( index, 1 ) - atlas.centers[tiles[index].id][1];
	}

	override inline public function setFrame( index: Int, v: Float )  { 
		super.setFrame( index, v ); 
		tiles[index].id = Std.int( v );
		tiles[index].x = getRList( index, 0 ) - atlas.centers[tiles[index].id][0];
		tiles[index].y = getRList( index, 1 ) - atlas.centers[tiles[index].id][1];
	}
}
