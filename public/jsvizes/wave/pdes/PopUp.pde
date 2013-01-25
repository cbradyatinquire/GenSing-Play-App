abstract class PopUp extends ProtoPanel {

  // Fields

  Activity owner;
  String title, message;




  // Constructor

  PopUp( Activity o, float pow, float poh ) {
    super( pow, poh );
    owner = o;
  } // end constructor




  // Methods

  void display() {
    drawPanel();
    drawContents();
    protoUI.update();
    protoUI.display();
  } // end display()




  void drawPanel() {
    stroke( 128 );
    strokeWeight( 3 );
    fill( bgColor );
    rectMode( CORNERS );
    rect( x1 - 3, y1 - 3, x2 + 3, y2 + 3 );   
    fill ( 128 );
    text( title, x1 + ( poWidth - textWidth( title ) )/2, y1 + 15 );

  } // end drawPanel()




  abstract void drawContents();




  void selfDestruct() {
    owner.activePopUp = null;
  } // end selfDestruct()




  abstract String toString();




} // end class PopUp