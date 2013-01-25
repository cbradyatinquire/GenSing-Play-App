class PopUpTest extends PopUp {

  // Fields

  boolean statusBox;
  color boxColor;
  float x1Box, y1Box, x2Box, y2Box;
  PopUpTestUI potUI;




  // Constructor

  PopUpTest( Activity o, float pow, float poh ) {
    super( o, pow, poh );  
    x1Box = this.x1 + 10;
    y1Box = this.y1 + 50;
    x2Box = this.x1 + 390;
    y2Box = this.y1 + 200;
    boxColor = color( 200, 50, 40 );
    title = "Test PopUp!";
    potUI = new PopUpTestUI( this );
    protoUI = potUI;
  } // end constructor




  // Methods

  //@Override
  void drawContents() {
    //stroke( boxColor );
    //fill( boxColor );
    //strokeWeight( 1 );
    //rectMode( CORNERS );
    //rect( x1Box, y1Box, x2Box, y2Box );
  } // end drawContents()




  String toString() {
    return( "PopUpTest. Width:" + poWidth + " Height:" + poHeight );
  } // end toString()




 } // end class PopUpTest