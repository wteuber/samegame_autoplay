package samegame;

public class UndoInfo {
    public int tilesLeft = 0;
    public int score = 0;
    public int tiles[][] = new int[TilePanel.TILES_WIDE][TilePanel.TILES_HIGH];

    public UndoInfo(int tiles[][], int score, int tilesLeft) {
	for (int i = 0 ; i < TilePanel.TILES_WIDE ; i++)
	    for (int j = 0 ; j < TilePanel.TILES_HIGH ; j++)
		this.tiles[i][j] = tiles[i][j];

	this.score = score;
	this.tilesLeft = tilesLeft;
    }


}

