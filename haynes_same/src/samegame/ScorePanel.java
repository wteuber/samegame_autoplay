package samegame;

import java.awt.*;
import java.applet.*;
import java.net.*;

public class ScorePanel extends Panel implements Runnable {

    Image num[] = new Image[10];

    final static String	numberFileName[] = {	"images/0.gif", 
						"images/1.gif",
						"images/2.gif",
						"images/3.gif",
						"images/4.gif",
						"images/5.gif",
						"images/6.gif",
						"images/7.gif",
						"images/8.gif",
						"images/9.gif"};


    final static int numWidth = 18;
    final static int numHeight = 24;

    final static int panelWidth = (18 * 4) + 10;
    final static int panelHeight = 24;

    MediaTracker media = null;

    private int score = 0;

    private UpdateThread updater = null;

    Image osImage = null;
    Graphics osGraphics = null;

    public ScorePanel(URL docBase, Applet app) {
	media = new MediaTracker(this);
	for (int i = 0 ; i < 10 ; i++) {
	    num[i] = app.getImage(docBase, numberFileName[i]);
	    media.addImage(num[i], i);
	    boolean ret = media.checkAll(true);
	}
	new Thread(this).start();
    }

    public void addNotify() {
	super.addNotify();
	resize(panelWidth, panelHeight);

	osImage = createImage(panelWidth, panelHeight);
	osGraphics = osImage.getGraphics();
	updateImage();
    }

    public void paint(Graphics g) {
	if (updater != null) {
	    updater.stop();
	    updater = null;
	}

	g.drawImage(osImage, 0, 0, null);
    }

    public void update(Graphics g) {
	paint(g);
    }

    public void updateImage() {
	Dimension d = this.size();

	osGraphics.setColor(Color.black);
	osGraphics.fillRect(0, 0, d.width, d.height);

	if (media.checkAll(true) == false) {
	    return;
	}

	int thousands = score / 1000;
	int hundreds = (score - (thousands * 1000)) / 100;
	int tens = (
		    (score - (thousands * 1000))
		    - (hundreds * 100)
		    ) / 10;
	int ones = (
		    (score - (thousands * 1000))
		    - (hundreds * 100)
		    ) - (tens * 10);

	int imageLeft = d.width - (numWidth + 5);
	int imageWidth = num[ones].getWidth(null);
	osGraphics.drawImage(num[ones], (imageLeft + numWidth) - imageWidth, 0, null);
	
	imageLeft -= numWidth;
	imageWidth = num[tens].getWidth(null);
	osGraphics.drawImage(num[tens], (imageLeft + numWidth) - imageWidth, 0, null);
	
	imageLeft -= numWidth;
	imageWidth = num[hundreds].getWidth(null);
	osGraphics.drawImage(num[hundreds], (imageLeft + numWidth) - imageWidth, 0, null);
	
	imageLeft -= numWidth;
	imageWidth = num[thousands].getWidth(null);
	osGraphics.drawImage(num[thousands], (imageLeft + numWidth) - imageWidth, 0, null);
    }

    public Dimension preferredSize() {
	Dimension d = new Dimension(panelWidth, panelHeight);
	return(d);
    }


    public void setScore(int newScore) {

	if (score == newScore)
	    return;

	score = newScore;

	updateImage();

	if (updater == null) {
	    updater = new UpdateThread(this);
	    updater.start();
	}
    }


    public void run() {

	while (media.checkAll(true) == false) {
	    try {
		Thread.sleep(500);
	    }
	    catch (InterruptedException e) {
	    }
	}

	updateImage();

	if (updater == null) {
	    updater = new UpdateThread(this);
	    updater.start();
	}
    }

    private void DebugStr(String s){
	System.out.println("ScorePanel: " + s);
    }


}
