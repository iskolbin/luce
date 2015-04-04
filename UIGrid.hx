typedef GridConfig = {
	?framesList: Array<Float>,
	?frames: Array<String>,
	cols: Int,
	rows: Int,
	cellWidth: Float,
	cellHeight: Float,
}

class UIGrid extends UIWidget {
	public var cols(default,null): Int;
	public var rows(default,null): Int;
	public var cellWidth(default,null): Float;
	public var cellHeight(default,null): Float;

	var grid = new Array<Array<UIWidget>>();
	
	override public function new( batch: UIBatch, shift: Int, args_: UIWidget.WidgetConfig ) {
		super( batch, shift, args_ );
	
		var args = args_.grid;

		var x_ = x;
		var y_ = y;
		x = 0;
		y = 0;
		
		var framesList: Array<Float>;

		if ( args.framesList != null ) {
			framesList = args.framesList;
		} else if	( args.frames != null ) {
			framesList = batch.newFramesList( args.frames );
		} else {
			throw "Cannot create grid: need .frames/.framesList";
		}

		cols = args.cols;
		rows = args.rows;
		cellWidth = args.cellWidth;
		cellHeight = args.cellHeight;		

		for ( x in 0...cols ) {
			grid[x] = new Array<UIWidget>();
			for ( y in 0...rows ) {
				// TODO: more parent
				// TODO: align (now center)
				grid[x][y] = batch.newWidget( {
					x: (-0.5*(cols-1)+x)*cellWidth, 
					y: (-0.5*(rows-1)+y)*cellHeight, 
					framesList: framesList, 
					parent: {x: this, y: this, visible: this }} );
			}
		}

		x = x_;
		y = y_;
	}

	public inline function getCell( x: Int, y: Int ) return grid[x][y];
	public inline function setRowAttr( row: Int, attr: Int, v: Float ) for ( x in 0...cols ) grid[x][row].setAttr( attr, v );
	public inline function setColAttr( col: Int, attr: Int, v: Float ) for ( y in 0...rows ) grid[col][y].setAttr( attr, v );
		
	public inline function setRectAttr( xmin: Int, ymin: Int, xmax: Int, ymax: Int, attr: Int, v: Float ) {
		xmin = xmin < 0 ? 0 : xmin;
		ymin = ymin < 0 ? 0 : ymin;
		xmax = xmax > cols ? cols : xmax;
		ymax = ymax > rows ? rows : ymax;
		for ( x in xmin...xmax ) {
			for ( y in ymin...ymax ) {
				grid[x][y].setAttr( attr, v );
			}
		}
	}	
	
	public inline function setRowVisible( row: Int, v: Bool ) for ( x in 0...cols ) grid[x][row].visible = v;
	public inline function setColVisible( col: Int, v: Bool ) for ( y in 0...rows ) grid[col][y].visible = v;
	public inline function setRectVisible( xmin: Int, ymin: Int, xmax: Int, ymax: Int, v: Bool ) {
		xmin = xmin < 0 ? 0 : xmin;
		ymin = ymin < 0 ? 0 : ymin;
		xmax = xmax > cols ? cols : xmax;
		ymax = ymax > rows ? rows : ymax;
		for ( x in xmin...xmax ) {
			for ( y in ymin...ymax ) {
				grid[x][y].visible = v;
			}
		}
	}
}
