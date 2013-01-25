class TextBox {

  // Fields
  float x1, y1, x2, y2, wTB, hTB;
  float vSpacing, hSpacing, lSpacing;
  String displayText, actualText;
  boolean onFocus;
  color bgColor, textColor;
  int tSize;
  boolean over;




  // Constructor

  TextBox( float x1t, float y1t, float x2t, float y2t, String initText ) {
    x1 = x1t;
    y1 = y1t;
    x2 = x2t;
    y2 = y2t;
    actualText = initText;
    onFocus = false;
    bgColor = color( 255, 255, 255 );
    textColor = color( 128, 128, 128 );
    tSize = 12;
    over = false;    
  } // end constructor




  // Methods

  void update() {
    if( mouseX > x1 && mouseX < x2 &&
        mouseY > y1 && mouseY < y2 )
      over = true;
    else
      over = false;
  } // end update()




  void display() {
    // draw borders
    stroke( textColor );
    fill( bgColor );
    strokeWeight( 1 );
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );

    // draw text
    fill( textColor);
    noStroke();
    text( actualText, x1 + hSpacing, tSize + vSpacing + y1 );
  } // end display()




  void doPressed( int k ) {
    if( k == BACKSPACE ){
      actualText = actualText.substring( 0, actualText.length-2 );
    } else if( k == ENTER || k == RETURN ) {
      actualText += "\n";
    } else {
      actualText += String.fromCharCode( k ); // JavaScript unicode
    }
  } // end doPressed()




} // end class TextBox