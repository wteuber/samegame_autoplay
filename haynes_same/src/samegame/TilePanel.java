package samegame;

import java.awt.*;
import java.applet.*;

public class TilePanel extends Panel implements Runnable{

    public final int TILESIZE = 30;

    public final static int TILES_WIDE = 20;
    public final static int TILES_HIGH = 10;

    int tiles[][] = new int[TILES_WIDE][TILES_HIGH];
    int savedTiles[][] = new int[TILES_WIDE][TILES_HIGH];
    boolean mask[][] = new boolean[TILES_WIDE][TILES_HIGH];

    // there can only ever be a maximum of (total blocks / 2) moves
    UndoInfo undo[] = new UndoInfo[(TILES_WIDE * TILES_HIGH) / 2];
    int	undoLevels = 0;
    int	curUndoLevel = 0;

    Image osImage = null;
    Graphics osGraphics = null;

    Image osMask = null;
    Graphics osMaskGraphics = null;

    boolean flashing = false;
    boolean flashState = false;
    Thread flashThread = null;

    final static Color	colors[] = {	Color.blue, 
					Color.red, 
					Color.cyan,   
					Color.green,
					Color.yellow,
					Color.black};

    // for testing & and easy win
    //    final static Color	colors[] = {	Color.blue, 
    //					Color.green,
    //					Color.yellow,
    //					Color.black};

    final static int BLANK = colors.length - 1;

    int	furthestLeft = 0;
    int	furthestRight = 0;
    int	furthestTop = 0;
    int	furthestBottom = 0;

    int	curTargetColor = BLANK;
    int	totalMatches = 0;

    int score = 0;
    int tilesLeft = 200;

    public TilePanel() {
    }

    public void addNotify() {
	super.addNotify();
	resize(TILES_WIDE * TILESIZE, TILES_HIGH * TILESIZE);

	osImage = this.createImage(TILES_WIDE * TILESIZE, TILES_HIGH * TILESIZE);
	osGraphics = osImage.getGraphics();

	osMask = this.createImage(TILES_WIDE * TILESIZE, TILES_HIGH * TILESIZE);
	osMaskGraphics = osMask.getGraphics();

	newGame();
    }

    public void newGame() {

	if (flashing == true) {
	    flashing = false;
	    if (flashThread != null)
		flashThread.stop();
	}


	for (int x = 0 ; x < TILES_WIDE ; x++) {
	    for (int y = 0 ; y < TILES_HIGH ; y++) {
		tiles[x][y] = random(colors.length - 1);
		savedTiles[x][y] = tiles[x][y];
		mask[x][y] = false;
	    }
	}
	
	score = 0;
	tilesLeft = 200;

	undoLevels = 0;
	curUndoLevel = 0;
	undo[0] = new UndoInfo(tiles, score, tilesLeft);

	((SameGame)getParent()).setUndoButtonState(false);
	((SameGame)getParent()).setRedoButtonState(false);

	updateImage(false);
	repaint();
    }

    public void paint(Graphics g) {
	Dimension d = this.size();

	if (flashing == true) {
	    if (flashState == true) {
		if (osMask != null)
		    g.drawImage(osMask, 0, 0, null);
	    }
	    else {
		if (osImage != null)
		    g.drawImage(osImage, 0, 0, null);
	    }
	}
	else {
	    if (osImage != null)
		g.drawImage(osImage, 0, 0, null);
	}
    }

    public void update(Graphics g) {
	paint(g);
    }

    public void updateImage() {
	updateImage(true);
    }

    public void updateImage(boolean checkSavedTiles) {
	int curColor = -1;
	for (int x = 0 ; x < TILES_WIDE ; x++) {
	    for (int y = 0 ; y < TILES_HIGH ; y++) {
		if ((checkSavedTiles==false) || ((checkSavedTiles==true) && (savedTiles[x][y] != tiles[x][y]))) {
		    if (tiles[x][y] != curColor) {
			osGraphics.setColor(colors[tiles[x][y]]);
			curColor = tiles[x][y];
		    }
		    osGraphics.fillRect(x * TILESIZE, y * TILESIZE, TILESIZE, TILESIZE);
		}
		savedTiles[x][y] = tiles[x][y];
	    }
	}

	osGraphics.setColor(Color.black);
	for (int x = 1 ; x < TILES_WIDE ; x++)
	    osGraphics.drawLine(x * TILESIZE, 0, x * TILESIZE, TILES_HIGH * TILESIZE);
	for (int y = 1 ; y < TILES_HIGH ; y++)
	    osGraphics.drawLine(0, y * TILESIZE, TILES_WIDE * TILESIZE, y * TILESIZE);
    }

    public void drawMask() {
	osMaskGraphics.drawImage(osImage, 0, 0, null);
	osMaskGraphics.setColor(Color.black);
	for (int x = furthestLeft ; x <= furthestRight ; x++) {
	    for (int y =  furthestTop; y <= furthestBottom ; y++)
		if (mask[x][y] == true)
		    osMaskGraphics.fillRect(x * TILESIZE, y * TILESIZE, TILESIZE, TILESIZE);
	}
    }


    boolean findMatchingBlocks(int x, int y) {
	boolean match = false;

	curTargetColor = tiles[x][y];

	tiles[x][y] = BLANK;

	// check left
	if (x != 0) {
	    if (tiles[x - 1][y] == curTargetColor) {
		if (findMatchingBlocks(x - 1, y)){}
		match = true;
		totalMatches++;
	    }
	}
	
	// check right
	if (x != TILES_WIDE - 1) {
	    if (tiles[x + 1][y] == curTargetColor){
		if (findMatchingBlocks(x + 1, y)){}
		match = true;
		totalMatches++;
	    }			
	}
	
	// check top
	if (y != 0) {
	    if (tiles[x][y - 1] == curTargetColor) {
		if (findMatchingBlocks(x, y - 1)) {}
		match = true;
		totalMatches++;
	    }			
	}
	
	// check bottom
	if (y != TILES_HIGH - 1) {
	    if (tiles[x][y + 1] == curTargetColor) {
		if (findMatchingBlocks(x, y + 1)){}
		match = true;
		totalMatches++;
	    }			
	}
	
	if (x > furthestRight)
	    furthestRight = x;
	if (x < furthestLeft)
	    furthestLeft = x;
	if (y > furthestBottom)
	    furthestBottom = y;
	if (y < furthestTop)
	    furthestTop = y;
	
	tiles[x][y] = curTargetColor;
	mask[x][y] = true;
	if (match == true)
	    return(true);
	
	return(false);
    }

    //returns true if shifted left
    boolean shiftBlocks() {
	boolean shifted;
	boolean shiftedleft = false;
	int i, j, k;

	// shift down
	do {
	    shifted = false;
	    for (j = 0 ; j < TILES_HIGH - 1 ; j++) {
		for ( i = 0 ; i < TILES_WIDE ; i++) {
		    if (tiles[i][j] != BLANK && tiles[i][j + 1] == BLANK) {
			tiles[i][j + 1] = tiles[i][j];
			tiles[i][j] = BLANK;
			shifted = true;
		    }
		}
	    }
	}while (shifted == true);
	
	// shift across
	
	boolean seenNonBlankRow =  false;
	int	lastBlankRow = -1;
	for ( i = TILES_WIDE - 1 ; i >= 0  ; i--) {
	    boolean nonblankfound = false;
	    
	    for (j = 0 ; j < TILES_HIGH ; j++) {
		if (tiles[i][j] != BLANK) {
		    nonblankfound = true;
		    if (seenNonBlankRow == false) {
			seenNonBlankRow = true;
			lastBlankRow = i+1;
		    }
		}
	    }
	    
	    if (nonblankfound == false && seenNonBlankRow == true) {
		for ( k = i ; k < TILES_WIDE - 1 ; k++)
		    for (j = 0 ; j < TILES_HIGH ; j++)
			tiles[k][j] = tiles[k+1][j];
		
		for (j = 0 ; j < TILES_HIGH ; j++) {
		    if (lastBlankRow == TILES_WIDE)
			tiles[TILES_WIDE - 1][j] = BLANK;
		    else
			tiles[lastBlankRow][j] = BLANK;
		}
		
		shiftedleft = true;
	    }
	}
	
	return(shiftedleft);
    }



    // events shit

    
    // events
    public boolean handleEvent(Event evt) {
	boolean handled = false;
	switch(evt.id) {
	  case Event.WINDOW_DESTROY:
	    break;
	  case Event.MOUSE_MOVE:
	  case Event.MOUSE_DRAG:
	  case Event.MOUSE_ENTER:
	  case Event.MOUSE_EXIT:
	  case Event.MOUSE_UP:
	    break;
	  case Event.MOUSE_DOWN:
	    handleMouseDown(evt, evt.x, evt.y);
	    break;
	  case Event.ACTION_EVENT:
	    break;
	  default:
	    break;
	}
	return((handled==false)?false:super.handleEvent(evt));
    }

    public boolean handleMouseDown(Event evt, int x, int y) {

	int tile_x = (x / TILESIZE);
	int tile_y = (y / TILESIZE);

	if (flashing == true) {
	    flashing = false;
	    if (flashThread != null)
		flashThread.stop();

	    int numCleared = 0;
	    if (mask[tile_x][tile_y] == true) {
		for (int k = 0 ; k < TILES_WIDE ; k++) {
		    for (int j = 0 ; j < TILES_HIGH ; j++) {
			if (mask[k][j] == true) {
			    numCleared++;
			    tiles[k][j] = BLANK;
			    mask[k][j] = false;
			}
		    }
		}

		numCleared -= 2;
		numCleared *= numCleared;
		score += numCleared;

		if (shiftBlocks() == true) {
		}

		updateImage();

		repaint();

		if (checkForWin() == true) {
		    DialogFrame df = new DialogFrame("You Won!", "Yeah!", "SameGame");
		    df.show();
		    score *= 5;
		}
		else if (checkForStuck() == true) {
		    score -= countTiles();
		    DialogFrame df = new DialogFrame("No more moves!", "OK", "SameGame");
		    df.show();
		}

		tilesLeft = countTiles();
		((SameGame)getParent()).setTilesLeft(tilesLeft);
		((SameGame)getParent()).setScore(score);

		setUndoInfo();

		return(false);
	    }
	    else {
		for (int k = 0 ; k < TILES_WIDE ; k++) {
		    for (int j = 0 ; j < TILES_HIGH ; j++) {
			if (mask[k][j] == true)
			    mask[k][j] = false;
		    }
		}
		repaint();
	    }
	}

	int colorIndex = tiles[tile_x][tile_y];
	if (colorIndex == BLANK) {
	    return(false);
	}

	// clear mask
	for (int i = 0 ; i < TILES_WIDE ; i++)
	    for (int j = 0 ;j < TILES_HIGH ; j++)
		mask[i][j] = false;

	if (findMatchingBlocks(tile_x, tile_y) == true) {
	    drawMask();
	    flashing = true;
	    flashThread = new Thread(this);
	    flashThread.start();
	    flashState = true;
	}
	else {
	    for (int k = 0 ; k < TILES_WIDE ; k++) {
		for (int j = 0 ; j < TILES_HIGH ; j++) {
		    if (mask[k][j] == true)
			mask[k][j] = false;
		}	
	    }
	}



	return(true);
    }

    
    private int countTiles() {
	int returnValue = 0;
	for (int i = 0 ; i < TILES_WIDE ; i++)
	    for (int j = 0 ; j < TILES_HIGH ; j++)
		if (tiles[i][j] != BLANK)
		    returnValue++;
	return(returnValue);
    }

    /*-------------------------------------------*/

    private boolean checkForWin() {
	for (int i = 0 ; i < TILES_WIDE ; i++) {
	    for (int j = 0 ; j < TILES_HIGH ; j++)
		if (tiles[i][j] != BLANK)
		    return(false);
	}
	return(true);
    }

    /*-------------------------------------------*/

    private boolean checkForStuck() {
	for (int i = 0 ; i < TILES_WIDE ; i++) {
	    for (int j = 0 ; j < TILES_HIGH ; j++)
		if (tiles[i][j] != BLANK)
		    if (findMatchingBlocks(i, j))
			return(false);
	}
	return(true);
    }


    private void setUndoInfo() {
	undo[++curUndoLevel] = new UndoInfo(tiles, score, tilesLeft);
	undoLevels = curUndoLevel;

	((SameGame)getParent()).setUndoButtonState(true);
	((SameGame)getParent()).setRedoButtonState(false);
    }

    public void handleUndo() {
	if (curUndoLevel <= 0) 
	    return;

	if (flashing == true) {
	    flashing = false;
	    if (flashThread != null)
		flashThread.stop();
	}

	curUndoLevel--;

	for (int i = 0 ; i < TilePanel.TILES_WIDE ; i++)
	    for (int j = 0 ; j < TilePanel.TILES_HIGH ; j++)
		tiles[i][j] = undo[curUndoLevel].tiles[i][j];

	score = undo[curUndoLevel].score;
	tilesLeft = undo[curUndoLevel].tilesLeft;

	updateImage();
	repaint();
	((SameGame)getParent()).setTilesLeft(tilesLeft);
	((SameGame)getParent()).setScore(score);

	((SameGame)getParent()).setUndoButtonState((curUndoLevel>0)?true:false);
	((SameGame)getParent()).setRedoButtonState((curUndoLevel<undoLevels)?true:false);
    }

    public void handleRedo() {
	if (curUndoLevel >= undoLevels) 
	    return;

	if (flashing == true) {
	    flashing = false;
	    if (flashThread != null)
		flashThread.stop();
	}

	curUndoLevel++;

	for (int i = 0 ; i < TilePanel.TILES_WIDE ; i++)
	    for (int j = 0 ; j < TilePanel.TILES_HIGH ; j++)
		tiles[i][j] = undo[curUndoLevel].tiles[i][j];

	score = undo[curUndoLevel].score;
	tilesLeft = undo[curUndoLevel].tilesLeft;

	updateImage();
	repaint();
	((SameGame)getParent()).setTilesLeft(tilesLeft);
	((SameGame)getParent()).setScore(score);

	((SameGame)getParent()).setUndoButtonState((curUndoLevel>0)?true:false);
	((SameGame)getParent()).setRedoButtonState((curUndoLevel<undoLevels)?true:false);
    }


    public Dimension preferredSize() {
	return(new Dimension(TILES_WIDE * TILESIZE, TILES_HIGH * TILESIZE));
    }

    private int random(int max) {
	return (int)Math.floor(Math.random() * max);
    }

    private void DebugStr(String s){
	System.out.println("TilePanel: " + s);
    }

    public void run() {
	boolean running = true;
	while (running) {
	    repaint();
	    try {
		Thread.sleep(650);
	    }
	    catch (InterruptedException e) {
		running = false;
	    }
	    flashState = (flashState==true)?false:true;
	}

	flashing = false;
	flashThread = null;
    }

}


