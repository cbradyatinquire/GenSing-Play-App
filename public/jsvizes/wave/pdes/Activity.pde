// ========================================
// GUI Component Class
// Ancestor class for all ...Activity classes
// An Activity object acts as the main GUI panel where other GUI components
// are attached to / registered on it. One of its members is an object of 
// class ActivityUI, which is where all the code for user interactions are defined 
// ( e.g. what happens when "button A" is clicked )
// See also: class ActivityUI

abstract class Activity extends ProtoPanel {

  // Fields

  LiveWave owner;
  //float x1, x2, y1, y2; // inherited from ProtoPanel
  //color bgColor;
  ActivityUI activityUI;
  PImage maskView;
  PImage maskBkground;
  PImage maskPopUp;
  PopUp activePopUp;




  // Constructor

  Activity( LiveWave o, int x1f, int y1f, int x2f, int y2f ) {
    super( x1f, y1f, x2f, y2f );
    owner = o;
    bgColor = color( 125, 125, 125 ); // default background color
  } // end Constructor




  // Methods

  void display() {
    if( activePopUp == null ) {
      makeMaskBkground();
      prerender();
      //if( maskView == null ) // tweak this to enhance performance
        makeMaskView();
      render();
      applyMaskView();
      applyMaskBkground();
      activityUI.update();
      activityUI.display();
    } else {
      makeMaskPopUp();
      applyMaskPopUp();
      activePopUp.display();
    }
  } // end display()
  


  
  void prerender() {
    drawFrameBkground();
  } // end prerender();
  
  
  
  
  abstract void render();
  // This is where the main drawing routines should be defined
  // Specific implementation is done by the child classes

    
  
    
  void makeMasks() {
    makeMaskBkground();
    makeMaskView();
  } // end makeMasks()
  
  
  
  
  void applyMasks() {
    applyMaskBkground();
    applyMaskView();
    //applyMaskBkground();  
  } // end applyMasks()
  
  


  void drawFrameBkground() {
    stroke( 0 );
    fill( bgColor );
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
//    /*
//    PImage tempFrame = get( (int)x1, 
//                            (int)y1, 
//                            (int)( x2 - x1 ), 
//                            (int)( y2 - y1 ) );
//    
//    // prepare cutout area
//    float[] viewCoords = new float[ 4 ];
//    viewCoords = activityUI.getViewCoords(); // retrieves absolute coordinates, start from the application window's 0,0
//    int[] cutout = new int[ int( ( x2 - x1 ) * ( y2 - y1 ) ) ];
//     // fill in non-transparent pixels
//    for( int k = 0; k < cutout.length; k++ )
//      cutout[ k ] = 0;
//      
//    
//    // fill in transparent pixels
//    for( int i = (int)(viewCoords[ 1 ] - y1); 
//         i <  (int)((y2 - y1) - (y2 - viewCoords[ 3 ]) ); 
//         i++ )
//      for( int j = (int)(viewCoords[ 0 ] - x1); 
//           j < (int)( (x2 - x1) - (x2 - viewCoords[ 2 ]) ); 
//           j++ )
//        cutout[ ( (int) (x2 - x1) ) * i + j ] = 255;  
//    // superimpose cutout area onto image to get the mask
//    tempFrame.mask( cutout );
//    image( tempFrame, x1, y1);
//    */
} // end drawFrameBackground()
 



  void makeMaskView() {
    //drawFrameBkground();
    if( activityUI.view != null ) { // only need to make mask if activityUI has a view object
      // get image of the Activity frame
      maskView = get( x1, 
                      y1, 
                      (x2 - x1), 
                      (y2 - y1) );

      // prepare cutout area
      float[] viewCoords = new float[ 4 ];
      viewCoords = activityUI.getViewCoords(); // retrieves absolute coordinates, start from the application window's 0,0
      int[] cutout = new int[ ( x2 - x1 ) * ( y2 - y1 ) ];

      // fill in non-transparent pixels
      for( int k = 0; k < cutout.length; k++ )
        cutout[ k ] = 255;
      
      // fill in transparent pixels
      int formula1 = viewCoords[ 1 ] - y1;
      int formula2 = ( (y2-y1) - (y2-viewCoords[ 3 ]) ) + 1;
      int formula3 = viewCoords[ 0 ] - x1;
      int formula4 = ( (x2-x1) - (x2-viewCoords[ 2 ]) ) + 1;
      for( int i = formula1; 
           i <  formula2; 
           i++ )
        for( int j = formula3; 
             j < formula4; 
             j++ )
	  cutout[ (x2 - x1) * i + j ] = 0;  
      // superimpose cutout area onto image to get the mask
      maskView.mask( cutout );
    }
  } // end makeMaskView()

  

  void makeMaskBkground() {
    // only make backgrop mask if activity's dimensions are smaller 
    // than application's window dimension
    if( x2 - x1 < width || y2 - y1 < height ) { 
      // get image of the whole window
      maskBkground = get();

      // prepare cutout area
      int[] cutout = new int[ width * height ];

      // fill in non-transparent pixels
      for( int k = 0; k < cutout.length; k++ ) 
        cutout[ k ] = 255;
     
      // fill in transparent pixels
      for( i = y1; i < y2 + 1; i++ )
        for( j = x1; j < x2 + 1; j++ )
 	  cutout[ ( width * i ) + j ] = 0;
      // superimpose cutout onto image to get the mask
      maskBkground.mask( cutout );
    }
  } // end makeMaskBkground()




  void applyMaskView() {
    //if( activityUI.view != null ) {
      //if( maskView == null )
      //  makeMaskView();
      //else 
        image( maskView, x1, y1 );
    //}
  } // end applyMaskView()




  void applyMaskBkground() {
    // only apply backgrop mask if activity's dimensions are smaller 
    // than application's window dimension
    if( x2 - x1 < width || y2 - y1 < height ) { 
      if( maskBkground == null )
        makeMaskBkground();
      else
        image( maskBkground, 0, 0 );
    }
  } // end applyMaskBkground()




  abstract String toString();




  void makeMaskPopUp() {

  } // end makeMaskPopUp()




  void applyMaskPopUp() {
    //fill( 255 );
    //rect( 0, 0, width, height );
  } // end applyMaskPopUp()



  
} // end class Activity