class CheckBox {

  // Fields

  float x1, y1, x2, y2, wCB, hCB;
  float x1Box, y1Box, x2Box, y2Box, wBox, hBox;
  float x1Caption, y1Caption, x2Caption, y2Caption, wCaption, hCaption;
  float vSpacing, hSpacing;
  String displayCaption, actualCaption;
  boolean status;
  color bgColor, selBgColor, textColor;
  int captionSize;
  boolean over;




  // Constructor

  CheckBox( float x1c, float y1c, float x2c, float y2c, String caption ) {
    x1 = x1c;
    y1 = y1c;
    x2 = x2c;
    y2 = y2c;
    wCB = x2 - x1;
    hCB = y2 - y1;

    vSpacing = 5; // default
    hSpacing = 5; // default

    wBox = 15; // default
    hBox = 15; // default
    x1Box = x1 + hSpacing;
    y1Box = y1 + ( (hCB-hBox) /2 ); // middle height
    x2Box = x1Box + wBox;
    y2Box = y1Box + hBox;

    x1Caption = x2Box + hSpacing;
    x2Caption = x2Box - hSpacing;
    wCaption = x2Caption - x1Caption;
    y1Caption = y1 + vSpacing;
    y2Caption = y2 - vSpacing;
    hCaption = y2Caption - y1Caption;
    
    actualCaption = caption;
    displayCaption = fitToDisplay( caption );

    status = false;

    bgColor = color( 0 );
    selBgColor = color( 255, 255, 255, 25 );
    textColor = color( 128 );

    captionSize = 10; // default
    
    over = false;

  } // end constructor




  // Methods

  String fitToDisplay( String s ){
    return s; // no processing, for now
  } // end fitToDisplay()



  void display() {
    // draw the background
    if( status == true )
      fill( selBgColor );
    else 
      fill( bgColor );
    noStroke();
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );

    // draw the box
    stroke( textColor );
    strokeWeight( 1 );
    noFill();
    rect( x1Box, y1Box, x2Box, y2Box );
    if( status == true ) {
      line( x1Box, y1Box, x2Box, y2Box );
      line( x2Box, y1Box, x1Box, y2Box );
    }

    // draw the caption
    fill( textColor );
    noStroke();
    textSize( captionSize );
    text( displayCaption, x1Caption, y2Caption - 4 ); 

  } // end display()




  void update() {
    if( mouseX > x1 && mouseX < x2 && 
        mouseY > y1 && mouseY < y2 )
      over = true;
    else
      over = false;
  } // end update()

  

  
  void toggle() {
    status = !status;
  } // end toggle()




} // end class CheckBox