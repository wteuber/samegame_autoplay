package samegame;

import java.awt.*;
import java.applet.*;

public class UpdateThread extends Thread {

    Component comp = null;

    public UpdateThread(Component comp) {
	this.comp = comp;
    }

    public void run() {
	boolean running = true;
	while (running == true) {
	    comp.repaint();
	    try {
		sleep(100);
	    }
	    catch(InterruptedException e) {
	    }
	}
	running = false;
    }
}
