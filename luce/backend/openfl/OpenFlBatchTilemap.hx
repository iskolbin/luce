package luce.backend.openfl;

import openfl.display.Sprite;
import openfl.display.TilemapLayer;
import openfl.display.Tilemap;
import openfl.display.Tile;
import openfl.display.Tileset;
import luce.Batch;

class OpenFlBatchTilemap extends Batch {
	public var layer: TilemapLayer;
	public var tilemap: Tilemap;
	public var tileset: Tileset;
	public var tiles = new Array<Tile>();

	public function new( atlas: OpenFlAtlas, scissorRect: Array<Float>, host: Sprite ) {
		super( atlas, scissorRect );
		tileset = new Tileset( atlas.bitmapData );
		for ( i in 0...atlas.rectsFl.length ) {
			tileset.addRect( atlas.rectsFl[i] );
		}
		layer = new TilemapLayer( tileset );
		tilemap = new Tilemap( host.stage.stageWidth, host.stage.stageHeight );
		tilemap.addLayer( layer );
		host.addChild( tilemap );
	}

	override public function newWidget( args: Widget.WidgetConfig ) {
		tiles.push( new Tile( 0, 0, 0 ));
		return super.newWidget( args );
	}
	
	override public function setCenter( centerX: Float, centerY: Float ) {
		for ( tile in tiles ) {
			tile.x += centerX - this.centerX;
			tile.y += centerY - this.centerY;
		}
		super.setCenter( centerX, centerY );
	}

	override public function getX( index: Int ) return tiles[index].x;
	override public function getY( index: Int ) return tiles[index].y;
	override public function getFrame( index: Int ): Float return tiles[index].id;

	override public function setX( index: Int, v: Float )  tiles[index].x = v + centerX;
	override public function setY( index: Int, v: Float )  tiles[index].y = v + centerY;
	override public function setFrame( index: Int, v: Float ) tiles[index].id = Std.int(v);
}
