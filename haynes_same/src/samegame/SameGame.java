package samegame;

import java.awt.*;
import java.applet.*;

public class SameGame extends Applet {

    Font labelFont = new Font("Helvetica", Font.PLAIN, 14);

    TilePanel tileArea = null;

    Button newGameButton = null;
    Button undoGameButton = null;
    Button redoGameButton = null;

    Label scoreLabel = null;
    Label tilesLeftLabel = null;

    ScorePanel scoreArea = null;
    TilesLeftPanel tilesLeftArea = null;


    public SameGame() {
    }

    public void addNotify() {
	super.addNotify();
    }

    // we are the right size coming into init()
    public void init() {
	Dimension d = this.size();

	tileArea = new TilePanel();
	setLayout(null);
	add(tileArea);
	tileArea.move(10, 10);

	newGameButton = new Button("New Game");
	add(newGameButton);
	Dimension prefSize = newGameButton.preferredSize();
	newGameButton.resize(prefSize.width, prefSize.height);
	newGameButton.move(10, (d.height - ((d.height - 310) / 2)) - (prefSize.height / 2) );

	undoGameButton = new Button("Undo");
	add(undoGameButton);
	undoGameButton.resize(prefSize.width, prefSize.height);
	undoGameButton.move(20 + prefSize.width, (d.height - ((d.height - 310) / 2)) - (prefSize.height / 2) );
	undoGameButton.disable();
	
	redoGameButton = new Button("Redo");
	add(redoGameButton);
	redoGameButton.resize(prefSize.width, prefSize.height);
	redoGameButton.move(30 + (prefSize.width * 2), (d.height - ((d.height - 310) / 2)) - (prefSize.height / 2) );
	redoGameButton.disable();
	
	scoreArea = new ScorePanel(getDocumentBase(), this);
	add(scoreArea);
	int tmpTop = (d.height - ((d.height - 310) / 2)) - (scoreArea.preferredSize().height / 2);
	int tmpLeft = this.size().width - (scoreArea.preferredSize().width + 10);
	scoreArea.move(tmpLeft, tmpTop);
	setScore(0);

	scoreLabel = new Label("Score:", Label.RIGHT);
	scoreLabel.setFont(labelFont);
	scoreLabel.setForeground(Color.black);
	scoreLabel.setBackground(Color.lightGray);
	add(scoreLabel);
	prefSize = scoreLabel.preferredSize();
	scoreLabel.resize(prefSize.width, prefSize.height);
	tmpTop = (d.height - ((d.height - 310) / 2)) - (prefSize.height / 2);
	tmpLeft  -= 5;
	tmpLeft  -= prefSize.width;
	scoreLabel.move(tmpLeft, tmpTop);

	//---

	tilesLeftArea = new TilesLeftPanel(getDocumentBase(), this);
	add(tilesLeftArea);
	tmpTop = (d.height - ((d.height - 310) / 2)) - (tilesLeftArea.preferredSize().height / 2);
	tmpLeft -= 30;
	tmpLeft = tmpLeft - tilesLeftArea.preferredSize().width;
	tilesLeftArea.move(tmpLeft, tmpTop);
	setTilesLeft(200);

	//---

	tilesLeftLabel = new Label("Tiles Left:", Label.RIGHT);
	tilesLeftLabel.setFont(labelFont);
	tilesLeftLabel.setForeground(Color.black);
	tilesLeftLabel.setBackground(Color.lightGray);
	add(tilesLeftLabel);
	prefSize = tilesLeftLabel.preferredSize();
	tilesLeftLabel.resize(prefSize.width, prefSize.height);
	tmpTop = (d.height - ((d.height - 310) / 2)) - (prefSize.height / 2);
	tmpLeft  -= 5;
	tmpLeft  -= prefSize.width;
	tilesLeftLabel.move(tmpLeft, tmpTop);
    }

    public void setScore(int newScore) {
	scoreArea.setScore(newScore);
    }

    public void setTilesLeft(int i) {
	tilesLeftArea.setTilesLeft(i);
    }

    public void setUndoButtonState(boolean enabled) {
	if (undoGameButton != null)
	    undoGameButton.enable(enabled);
    }

    public void setRedoButtonState(boolean enabled) {
	if (redoGameButton != null)
	    redoGameButton.enable(enabled);
    }
    

    public void paint(Graphics g) {
	Dimension d = this.size();
	g.setColor(Color.lightGray);
	g.draw3DRect(0, 0, d.width - 1, d.height - 1, false);
    }

    public boolean action(Event evt, Object obj) {
	if (obj.equals("New Game")) {

	    tileArea.newGame();
	    setScore(0);
	    setTilesLeft(200);
	    return(true);
	}
	if (obj.equals("Undo")) {
	    tileArea.handleUndo();
	    return(true);
	}
	if (obj.equals("Redo")) {
	    tileArea.handleRedo();
	    return(true);
	}

	DebugStr(obj.toString());
	return(false);
    }

    public void update(Graphics g) {
	paint(g);
    }

    private void DebugStr(String s){
	System.out.println("SameGame: " + s);
    }

}
