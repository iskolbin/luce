// NOT USE!

package luce;

import haxe.ds.Vector;

typedef NinePatchConfig = {
	frames: Array<String>,
}

class NinePatch extends Widget {
	
	public var nineWidgets(default,null) = new Vector<Widget>( 9 );
	
	override public function new( batch: Batch, shift: Int, args_: Widget.WidgetConfig ) {
		super( batch, shift, args_ );
	
		var args = args_.ninepatch;
		
		if	( args.frames == null ) {
			throw "Cannot create ninepatch: need .frames";
		}

		for ( i in 0...9 ) {
			var framesList: Array<Float> = [ for ( name in args.frames ) batch.atlas.ids9patch[name][8-i]];
			trace( i, framesList );
			nineWidgets[i] = batch.newWidget( {framesList: framesList, parent: {x: this, y: this, 
				xscl: ( i == 1 || i == 4 || i == 7 ) ? this : null, 
				yscl: ( i == 3 || i == 4 || i == 5 ) ? this : null, frame: this, visible: this }} );
		}

		setFramesList( [for ( i in 0...nineWidgets[0].framesList.length ) Atlas.NULL] );
		
		if ( args_.frame != null ) frame = args_.frame;
	}
}
