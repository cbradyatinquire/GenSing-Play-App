abstract class ProtoPanel {

  // Fields
  
  float x1, y1, x2, y2;
  float poWidth, poHeight;
  Color bgColor;
  ProtoUI protoUI;




  // Constructor

  ProtoPanel( float x1a, float y1a, float x2a, float y2a ) {
    x1 = x1a;
    y1 = y1a;
    x2 = x2a;
    y2 = y2a;
    poWidth = x2 - x1;
    poHeight = y2 - y1;
    setDefaultBgColor();
  } // end constructor 




  // Overloaded constructor

  ProtoPanel( float pow, float poh ) { 
  // use this for middle positioning and when width and height are known
    poWidth = pow;
    poHeight = poh;
    x1 = ( width / 2 ) - ( poWidth / 2 );
    y1 = ( height / 2 ) - ( poHeight / 2 );
    x2 = x1 + poWidth;
    y2 = y1 + poHeight;
    setDefaultBgColor();
  } // end overloaded constructor 




  // Methods

  void setDefaultBgColor() {
    bgColor = color( 0 ); // default is BLACK
  } // end setDefaultBgColor()

  


  abstract void display();




} // end class ProtoPanel