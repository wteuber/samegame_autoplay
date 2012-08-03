package samegame;

import java.awt.*;
import java.applet.*;

public class DialogFrame extends Frame {

    static final Font txtFont = new Font("Helvetica", Font.PLAIN, 18);

    String paramText;
    String buttonText;

    int appWidth = 300;
    int appHeight = 100;

    public DialogFrame(String paramText, String buttonText, String title) {
	super(title);
	this.paramText = paramText;
	this.buttonText = buttonText;
	this.setResizable(false);
    }

    public void addNotify() {
	super.addNotify();
	
	resize(appWidth, appHeight);

	positionOnScreen();

	Panel buttonPanel = new Panel();
	buttonPanel.setLayout(new GridLayout(1, 4));
	Button okButton = new Button(buttonText);
	Label tmp = new Label("    ");
	buttonPanel.add(tmp);
	Label tmp2 = new Label("    ");
	buttonPanel.add(tmp2);
	Label tmp3 = new Label("    ");
	buttonPanel.add(tmp3);
	buttonPanel.add(okButton);
	add("South", buttonPanel);

	Label paramLabel = new Label(paramText);
	paramLabel.setFont(txtFont);
	add("Center", paramLabel);

	this.show();
    }

    private void positionOnScreen() {
	Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
	this.move((screen.width / 2) - (this.size().width / 2), (screen.height / 3) - (this.size().height / 2));
    }


    // events
    public boolean handleEvent(Event evt) {
	boolean handled = false;
	switch(evt.id) {
	  case Event.WINDOW_DESTROY:
	    this.hide();
	    this.dispose();
	    break;
	  case Event.MOUSE_MOVE:
	  case Event.MOUSE_DRAG:
	  case Event.MOUSE_ENTER:
	  case Event.MOUSE_EXIT:
	  case Event.MOUSE_UP:
	    break;
	  case Event.MOUSE_DOWN:
	    break;
	  case Event.ACTION_EVENT:
	    if (evt.arg.equals(buttonText) == true) {
		this.hide();
		this.dispose();
		handled = true;
	    }
	    break;
	  default:
	    break;
	}
	return((handled==false)?false:super.handleEvent(evt));
    }

    private void DebugStr(String s){
	System.out.println("DialogFrame: " + s);
    }
}
