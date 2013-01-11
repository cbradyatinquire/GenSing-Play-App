// ========================================
// This is the main class (top-level class) for the Live Spiral visualizer


// Globally define a class to handle Ajax tasks
// ----------------------//
// START JavaScript code //
// --------------------- //

function AjaxObject() {
  this.dataAjax = "";
  this.dataBuffered = false;
  this.dataDelivered = false;
  this.request = new ajaxRequest();

  this.makeAjaxCall = function( urlAddress ) {
    this.request.open( "GET", urlAddress, true );
    this.request.send( null );
  } // end method makeAjaxCall()

  this.request.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        if (this.responseText != null) {
          dataBuffered = true;          // how to refer to the
          dataAjax = this.responseText; // members of AjaxObject?
        } else 
          alert("Ajax error: No data received");
      } else     
        alert( "Ajax error: " + this.statusText);
    }
  } // end function ajaxCallback    
        
  this.grabData = function() {
    if( this.dataDelivered == true )
      return "";
    else { 
      if( this.dataBuffered == false )
        return "";
      else {
        this.dataDelivered = true;
        return this.dataAjax;
      }
    }
  } // end grabData()




} // end constructor for YAObject




  function ajaxRequest() {
    try {
      var request = new XMLHttpRequest();
    } catch(e1) {
      try { 
        request = new ActiveXObject("Msxml2.XMLHTTP");
      } catch(e2) {
        try {
          request = new ActiveXObject("Microsoft.XMLHTTP");
        } catch(e3) {
          request = false;
        }
      }
    }
    return request;
  } // end function ajaxRequest()

// ------------------- //
// END JavaScript Code //
// ------------------- //




// --------------------- //
// START Processing Code //
// --------------------- //

// Fields

  SpiralActivity spa;

  color hitColor, noHitColor, hitColorScatter, noHitColorScatter;
  color popUpBkgrd, popUpTxt, butOv, butPress;
  PFont spiralFont;
  PFont pdfFont;
  Divider[] dividers;

  String[] aDetails = new String[ 3 ];

  // applet params
  String hostip, school, teacher, cnameandcyear, cname, cyear, actid, starttimeFull, starttimeTrimmed, functioncall;




void setup() {
  setupDisplayElements(); 
  
  loadParams();  //new method
  //readParams();  // comment to debug, uncomment before deploying
  
  // use these for deployment 
  aDetails[ 0 ] = "http://" + hostip + "/" + functioncall + "?aid=" + actid + "&ind=0";
  
  //aDetails[ 0 ] = "/" + functioncall + "?aid=" + actid + "&ind=0";
 
  aDetails[ 1 ] = starttimeTrimmed;  
  aDetails[ 2 ] = actid + " " + cnameandcyear + " " + school + " " + teacher;  
  
  // use these for debugging
  /*
  //aDetails[ 0 ] = "http://localhost:9000/getAllContributionsAfterVerbose?aid=2&ind=0";
  //aDetails[ 1 ] = "15:00:00";
  //aDetails[ 2 ] = "Just for testing";
  */
  spa = new SpiralActivity( this );
  spa.startSpiral( aDetails );

} // end setup()




void draw() {
  spa.display();
} // end draw()




void mousePressed() {
  spa.aUI.executeMousePressed(); 
  if ( mouseButton == RIGHT ) {
    /*
    Right-click now does nothing, was used to switch between Activities
    */
  } // end if mouseButton == RIGHT
} // end mousePressed()




void mouseDragged() {
  spa.aUI.executeMouseDragged();
} // end mouseDragged()




void mouseReleased() {
  spa.aUI.executeMouseReleased();
} // end mouseReleased()




void setupDisplayElements() {
  size( 1180, 1000 );
  smooth();
  spiralFont = loadFont( "SansSerif.plain-12.vlw" ); // set as global to make changing easier
  textFont( spiralFont );
  hitColor = color( 0, 200, 0 );
  noHitColor = color( 200, 0, 0 );
  hitColorScatter = hitColor;
  noHitColorScatter = noHitColor;
  popUpBkgrd = color ( 0, 0, 0, 180 );
  popUpTxt = color( 255, 255, 0 );
  butOv = color( 0, 0, 0, 100 );
  butPress = color ( 10, 250, 10, 255 ); 

  dividers = new Divider[ 2 ];
  dividers[ 0 ] = new Divider( true, 0, 300, 350, 300, 90 );
  dividers[ 1 ] = new Divider( false, 350, 0, 350, height, 90 );
} // end setupDisplayElements()


void loadParams() {
  hostip = jsHostIp();
  school = jsSchool();
  teacher = jsTeacher();
  cnameandcyear = jsCnameandcyear();
  String[] cpieces = splitTokens( cnameandcyear, ":" );
  cname = cpieces[ 0 ];
  cyear = cpieces[ 1 ];
  actid = jsActid();
  starttimeFull = jsStarttimefull();
  starttimeTrimmed = starttimeFull.substring( starttimeFull.length()-17, starttimeFull.length()-9 );
  functioncall = jsFunctioncall();
}


void readParams() {
// Reads applet param tags from HTML file
//

  hostip = param( "hostip" );
  school = param( "school" );
  teacher = param( "teacher" );
  cnameandcyear = param( "cnameandcyear" );
  String[] cpieces = splitTokens( cnameandcyear, ":" );
  cname = cpieces[ 0 ];
  cyear = cpieces[ 1 ];
  actid = param( "actid" );
  starttimeFull = param( "starttime" );
  starttimeTrimmed = starttimeFull.substring( starttimeFull.length()-17, starttimeFull.length()-9 );
  functioncall = param( "functioncall" );
} // end readParams() 




float myRound( float val, int dp ) {
  return int( val * pow( 10, dp ) ) / pow( 10, dp );
} // end myRound()




// ========================================
// GUI Component Class
// Ancestor class for GUI buttons

class AButton {

  // Fields

  float x1, y1;                      // The Upper Left x- and y- coordinate
  float x2, y2;                      // The Lower Right x- and y- coordinate
  color baseGray;                    // Default Gray value
  color overGray;                    // Value when mouse is over the button
  color pressGray;                   // Value when mouse is over and pressed
  boolean over = false;              // True when the mouse is over
  boolean pressed = false;           // True when the mouse is over and pressed
  int linkIndex;




  // Constructor

  AButton( float x1p, float y1p, float x2p, float y2p, int linkIndexp ) {
    x1 = x1p;
    y1 = y1p;
    x2 = x2p;
    y2 = y2p;
    linkIndex = linkIndexp;
  } // end constructor




  // Methods

  // Updates the over field every frame
  void update() {
    if( ( mouseX > x1 ) && ( mouseX < x2 ) &&
      ( mouseY > y1 ) && ( mouseY < y2 ) )
      over = true;
    else
      over = false;
  } // end update()




  boolean press() {
    if( over == true ) {
      pressed = true;
      return true;
    } 
    else
      return false;
  } // end press()




  void release() {
    pressed = false;                 // Set to false when the mouse is released
  }



  
  void display() {
    stroke( 0 );
    if( pressed )
      fill( 50, 50, 50 );
    else {
      if( over )  
        fill( 240, 240, 240 );
      else
        fill( 180, 180, 180 );
    }
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
  } // end display()



  
  int getIndex() {
    return linkIndex;
  } // end getIndex()




} // end AButton class

// ========================================
// GUI Component Class
// Ancestor class for all ...Activity classes
// An Activity object acts as the main GUI panel where other GUI components
// are attached to / registered on it. One of its members is an object of 
// class AUI, which is where all the code for user interactions are defined 
// ( e.g. what happens when "button A" is clicked )
// See also: class AUI

abstract class Activity {

  // Fields

  LiveSpiral owner;
  float x1Frame, x2Frame, y1Frame, y2Frame;
  color bgColor;
  AUI aUI;
  PImage maskView;
  PImage maskBkground;




  // Constructor

  Activity( LiveSpiral o, int x1f, int y1f, int x2f, int y2f ) {
    owner = o;
    x1Frame = x1f;
    y1Frame = y1f;
    x2Frame = x2f;
    y2Frame = y2f;
    bgColor = color( 125, 125, 125 ); // default background color
  } // end Constructor




  // Methods

  void display() {
    makeMaskBkground();
    prerender();
    makeMaskView();
    render();
    applyMaskView();
    applyMaskBkground();
    aUI.update();
    aUI.display();
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
    rect( x1Frame, y1Frame, x2Frame, y2Frame );
    /*
    PImage tempFrame = get( (int)x1Frame, 
                            (int)y1Frame, 
                            (int)( x2Frame - x1Frame ), 
                            (int)( y2Frame - y1Frame ) );
    
    // prepare cutout area
    float[] viewCoords = new float[ 4 ];
    viewCoords = aUI.getViewCoords(); // retrieves absolute coordinates, start from the application window's 0,0
    int[] cutout = new int[ int( ( x2Frame - x1Frame ) * ( y2Frame - y1Frame ) ) ];
     // fill in non-transparent pixels
    for( int k = 0; k < cutout.length; k++ )
      cutout[ k ] = 0;
      
    
    // fill in transparent pixels
    for( int i = (int)(viewCoords[ 1 ] - y1Frame); 
         i <  (int)((y2Frame - y1Frame) - (y2Frame - viewCoords[ 3 ]) ); 
         i++ )
      for( int j = (int)(viewCoords[ 0 ] - x1Frame); 
           j < (int)( (x2Frame - x1Frame) - (x2Frame - viewCoords[ 2 ]) ); 
           j++ )
        cutout[ ( (int) (x2Frame - x1Frame) ) * i + j ] = 255;  
    // superimpose cutout area onto image to get the mask
    tempFrame.mask( cutout );
    image( tempFrame, x1Frame, y1Frame);
    */
} // end drawFrameBackground()
 



  void makeMaskView() {
    //drawFrameBkground();
    if( aUI.view != null ) { // only need to make mask if aUI has a view object
      // get image of the Activity frame
      maskView = get( ( int )x1Frame, 
                      ( int )y1Frame, 
                      ( int )(x2Frame - x1Frame), 
                      ( int )(y2Frame - y1Frame) );

      // prepare cutout area
      float[] viewCoords = new float[ 4 ];
      viewCoords = aUI.getViewCoords(); // retrieves absolute coordinates, start from the application window's 0,0
      int[] cutout = new int[ int( ( x2Frame - x1Frame ) * ( y2Frame - y1Frame ) ) ];

      // fill in non-transparent pixels
      for( int k = 0; k < cutout.length; k++ )
        cutout[ k ] = 255;
      
      // fill in transparent pixels
      for( int i = (int)(viewCoords[ 1 ] - y1Frame); 
           i <  (int)((y2Frame - y1Frame) - (y2Frame - viewCoords[ 3 ] ) ) + 1; 
           i++ )
        for( int j = (int)(viewCoords[ 0 ] - x1Frame); 
             j < (int)( (x2Frame - x1Frame) - (x2Frame - viewCoords[ 2 ] ) ) + 1; 
             j++ )
	  cutout[ ( (int) (x2Frame - x1Frame) ) * i + j ] = 0;  
      // superimpose cutout area onto image to get the mask
      maskView.mask( cutout );
    }
  } // end makeMaskView()

  

  void makeMaskBkground() {
    // only make backgrop mask if activity's dimensions are smaller 
    // than application's window dimension
    if( x2Frame - x1Frame < width || y2Frame - y1Frame < height ) { 
      // get image of the whole window
      maskBkground = get();

      // prepare cutout area
      int[] cutout = new int[ width * height ];

      // fill in non-transparent pixels
      for( int k = 0; k < cutout.length; k++ ) 
        cutout[ k ] = 255;
     
      // fill in transparent pixels
      for( int i = (int)y1Frame; i < (int)y2Frame + 1; i++ )
        for( int j = (int)x1Frame; j < (int)x2Frame + 1; j++ )
 	  cutout[ ( width * i ) + j ] = 0;
      // superimpose cutout onto image to get the mask
      maskBkground.mask( cutout );
    }
  } // end makeMaskBkground()




  void applyMaskView() {
    if( aUI.view != null ) {
      if( maskView == null )
        makeMaskView();
      else 
        image( maskView, x1Frame, y1Frame );
    }
  } // end applyMaskView()




  void applyMaskBkground() {
    // only apply backgrop mask if activity's dimensions are smaller 
    // than application's window dimension
    if( x2Frame - x1Frame < width || y2Frame - y1Frame < height ) { 
      if( maskBkground == null )
        makeMaskBkground();
      else
        image( maskBkground, 0, 0 );
    }
  } // end applyMaskBkground()




  abstract String toString();




} // end class Activity

// ========================================
// GUI Component Class
// Ancestor class of all ...UI classes 
// AUI stands for "Activity UI". An object of this class is a member of an 
// object of class Activity (or ...Activity). This class is where all the 
// interaction-related code is defined. ( e.g. what happens whe "button A" 
// is clicked ).
// see also: class Activity

abstract class AUI {

  // Fields

  Activity owner;
  ArrayList <AButton> arrButtons;
  ArrayList <SpButton> arrSpButtons;
  ArrayList <Dropdown> arrDropdowns;
  View view;


  

  // Constructor

  AUI () {  // this version of the constructor does NOT have a View object
    arrButtons = new ArrayList();
    arrSpButtons = new ArrayList();
    arrDropdowns = new ArrayList();
  } // end constructor



  
  AUI( float x1v, float y1v, float x2v, float y2v ) {  // this version of the constructor has a View object
    arrButtons = new ArrayList();
    arrSpButtons = new ArrayList();
    arrDropdowns = new ArrayList();
    view = new View( x1v, y1v, x2v, y2v ); 
  } // end constructor



  
  // Methods
  
  // ------------ //
  // View Methods //
  // ------------ //
  
float[] getViewCoords() {
    float[] vc = new float[ 4 ];
    for( int i = 0; i < vc.length; i++ ) {
      if( view == null )
        vc[ i ] = 0;
      else {
        if( i == 0 )
          vc[ i ] = view.getX1A();
        else if( i == 1 )
          vc[ i ] = view.getY1A();
	else if( i == 2 )
	  vc[ i ] = view.getX2A();
	else if( i == 3 )
	  vc[ i ] = view.getY2A();
    	else
    	  vc[ i ] = 0;  
      } // end for 
    }
    return vc;
  } // end getViewCoords()
  
  
  
  
  float[] getViewScrollPos() {
    return view.getScrollPos();
  } // end getViewScrollPos()




  void releaseViewButtons() {
    if( view != null )
      view.releaseAllButtons();
  }  // end releaseViewButtons()
  
  
  
  
  void processClickedView() {
    if( view != null ) {      
     
      if( view.sbUp.press() ) {
        view.stepUp();
      }
      
      if( view.sbDown.press() ) {
        view.stepDown();
      }
      
      if( view.sbLeft.press() ) {
        view.stepLeft();
      }
      
      if( view.sbRight.press() ) {
        view.stepRight();
      }
    
    }
  } // end processClickedView
  
  
  
  
  void processDraggedView() {
    if( view != null )
      view.updateDrag(); 
  } // end processDraggedView()  
  
  
  

  // ------------- //
  // Button Mehods //
  // ------------- //

  void createButton( float x1c, float y1c, float x2c, float y2c, int index ){
    // This will create one button and attach it into the arrButtons arraylist
    arrButtons.add( new AButton( x1c, y1c, x2c, y2c, index ) );
  } // end createButton



  
  int getNextIndexArrButtons() {
    if( arrButtons == null )
      return 0;
    else
      return arrButtons.size();
  } // end getLastIndexArrButtons



  
  int getPressedArrButton() {
    // Returns the index number of an arrButton whose status is on pressed
    // Returns -1 if no Buttons are pressed
    int ret = -1;
    if( arrButtons != null ) {
      for( int i = 0; i < arrButtons.size(); i++ ) {
        AButton b = arrButtons.get( i );
        if( b.press() )
          ret = i;
      } // end for
      return ret;
    } else
    return ret;
  } // end getPressedArrButton()


  
  
  void releaseButtons() {
    int whichOne = getPressedArrButton();
    if( whichOne != -1 ) {
      AButton b = arrButtons.get( whichOne );  
      b.release();
    } // end if
  } // end releaseButtons()




  // --------------- //
  // SpButton Mehods //
  // --------------- //
  
  void createSpButton( float x1p, float y1p, float x2p, float y2p, int linkIndexp, 
                       String labelp, color labelcolp, color basep, color overp, color pressedp ) {
    // This will create one SpButton and attach it into the arrSpButtons arraylist
    arrSpButtons.add( new SpButton( x1p, y1p, x2p, y2p, linkIndexp, 
                                    labelp, labelcolp, basep, overp, pressedp ) );
  } // end createSpButton
  



  int getNextIndexArrSpButtons() {
    if( arrSpButtons == null )
      return 0;
    else
      return arrSpButtons.size();
  } // end getLastIndexArrSpButtons



  
  int getPressedArrSpButton() {
    // Returns the index number of an arrSpButton whose status is on pressed
    // Returns -1 if no SpButtons are pressed
    int ret = -1;
    if( arrSpButtons != null ) {
      for( int i = 0; i < arrSpButtons.size(); i++ ) {
        SpButton b = arrSpButtons.get( i );
        if( b.press() )
          ret = i;
      } // end for
      return ret;
    } else
    return ret;
  } // end getPressedArrSpButton()




  void releaseSpButtons() {
    if( arrSpButtons != null )
      for( SpButton s : arrSpButtons )
        s.release();
  } // end releaseSpButtons()



  
  // ---------------- //
  // Dropdown Methods //
  // ---------------- //

  void createDropdown( float x1d, float y1d, float x2d, float y2d, int index, String lbl ) {
    arrDropdowns.add( new Dropdown( x1d, y1d, x2d, y2d, index, lbl ) );
  } // end createDropdown()
  


  
  int getNextIndexArrDropdowns() {
    if( arrDropdowns == null )
      return( 0 );
    else
      return( arrDropdowns.size() );
  } // end getNextIndexArrDropdowns()



  
  void expandClickedDropdown() {
    if( arrDropdowns != null )
      for( Dropdown d : arrDropdowns )
        if( d.ddButton.over ) {
          d.ddButton.press();
          d.expand();
        }
  } // end expandClickedDropdown()



  
  int getExpandedArrDropdowns() {
    // Returns the index number of an arrDropdown object whose status is on expanded
    // Returns -1 if no arrDropdowns are pressed
    int ret = -1;
    if( arrDropdowns != null ) {
      for( Dropdown d : arrDropdowns )
        if( d.getExpanded() )
          ret = d.linkIndex;
      return ret;
    } else
    return ret; 
  } // end getExpandedArrDropdowns()



  
  void processClickedDropdown() {
    expandClickedDropdown();
    int indexExpanded = getExpandedArrDropdowns();
    if( indexExpanded != -1 ) {
      Dropdown d = arrDropdowns.get( indexExpanded );
      d.updateSelection();
    }
  } // end processClickedDropdown()



  
  void releaseDropdownButtons() {
    if( arrDropdowns != null )
      for( Dropdown d : arrDropdowns )
        d.ddButton.release();
  } // end releaseDropdownButtons()
  
  

  
  // --------------- //
  // Generic methods //
  // --------------- //

  void update() {
    // For Buttons
    if( arrButtons != null )
      for( AButton b : arrButtons ) {
        b.update();
      }
      
      // For SpButtons
      if( arrSpButtons != null ) 
        for( SpButton b : arrSpButtons ) {
          b.update(); 
        }
  } // end update



  
  void display() {
    // First layer of display() - MOST of the drawing of the UI components happen here
    // For View
    if( view != null ) {
      view.display();
    }
    
    // For Buttons
    if( arrButtons != null )
      for( AButton b : arrButtons ) {
        b.display();
      }  
      
    // For SpButtons
    if( arrSpButtons != null )
      for( SpButton b : arrSpButtons ) {
        b.display(); 
      }
        
    // For Dropdowns
    if( arrDropdowns != null )
      for( Dropdown d : arrDropdowns ) {
        d.display(); 
      }
      
    // Second layer of display() - NEEDED for properly displaying expanded Dropdowns
    if( arrDropdowns != null )
      for( Dropdown d : arrDropdowns ) {
        d.secondLayerDisplay(); 
      }
  } // end display()



  
  abstract void executeMousePressed();
  // to be made concrete by individual child classes



  
  abstract void executeMouseDragged();
  // to be made concrete by individual child classes
  
  
  
  
  void executeMouseReleased() {
    releaseButtons();
    releaseSpButtons();
    releaseDropdownButtons();
    releaseViewButtons();
  } // end executeMouseReleased()




  abstract String toString();




} // end abstract class AUI

// ========================================
// Contribution Coding Class
// this is just a wrapper class so we can more conveniently pass 
// around all those lists and hashmaps on codes ( contribution codes )
// The constructor will take no argument. Initiation will create
// an object with no data (just a shell)
// data will be fed in via methods of other classes

class CodeCabinet {

  // Fields
  
  ArrayList<CodeItem> codeItemsList;
  ArrayList<CodeCategory> codeCategoriesList;
  Map<String, CodeItem> codeItemsDictionary;
  Map<String, CodeCategory> codeCategoriesDictionary;
  Map<CodeItem, CodeCategory> codeBook;




  // Constructor

  CodeCabinet() {
    codeItemsList = new ArrayList<CodeItem>();
    codeCategoriesList = new ArrayList<CodeCategory>();
    codeItemsDictionary = new HashMap<String, CodeItem>();
    codeCategoriesDictionary = new HashMap<String, CodeCategory>();
    codeBook = new HashMap<CodeItem, CodeCategory>();
  } // end constructor




  // Methods

} // end class CodeCabinet

// ========================================
// Contribution Coding Class
// This class models code categories (e.g. Social, Math)

class CodeCategory {

// Fields
String dispName, fullName;
ArrayList<CodeItem> codeItems;




// Constructor

CodeCategory( String cat ) {
  dispName = cat;
  fullName = cat; // just leave this here for now but may change in future
  codeItems = new ArrayList<CodeItem>(); // create empty arraylist, to be populated later
} // end constructor




CodeCategory( String cat, String cod ) {
// Overloaded constructor to facilitate instantiation with one code item
//
  dispName = cat;
  fullName = cat;
  codeItems = new ArrayList<CodeItem>();
  codeItems.add( new CodeItem( this, cod ) );
} // end overloaded constructor




// Methods

void addCodeItem( String cod ) {
  if( codeItems == null )
    codeItems = new ArrayList<CodeItem>();
  codeItems.add( new CodeItem( this, cod ) );
} // end addCodeItem()




void addCodeItem( CodeItem citem ) {
  if( codeItems == null )
    codeItems = new ArrayList<CodeItem>();
  codeItems.add( citem );
} // end addCodeItem() CodeItem flavor




void removeCodeItem( String cod ) {
  for( CodeItem citem : codeItems ) {
    if( citem.dispName.equals( cod ) ) {
      codeItems.remove( citem );
      break;
    }
  }
} // end removeCodeItem()




  void removeCodeItem( CodeItem citem ) {
    if( codeItems.contains( citem ) )
      codeItems.remove( citem );
  } // end removeCodeItem() CodeItem flavor




  ArrayList<CodeItem> getCodeItems() {
    return( codeItems );
  } // end getCodeItems()




  String toString() {
    String ret = "CodeCategory: " + dispName + "\t" + fullName + "\n";
    ret += "CodeItems: \t";
    for( CodeItem citem : codeItems ) {
      ret += citem.dispName + "\t" ;
    }
    ret += "\n";
    return ret;
  } // end toString()




} // end class CodeCategory

// ========================================
// Contribution Coding Class
// This class models code items (e.g. VASM, R1)

class CodeItem {

  // Fields
  String dispName, fullName;
  CodeCategory owner;




  // Constructor

  CodeItem( String cod ) {
    dispName = cod;
    fullName = cod; // may want to change this in future
    owner = null;
  } // end constructor




  CodeItem( CodeCategory cat, String cod ) {
  // Overloaded constructor to facilitate simultaneous assignment of owner on instantiation
  //
    dispName = cod;
    fullName = cod;
    owner = cat;
  } // end constructor




  // Methods

  void assignCategory( CodeCategory cat ) {
    owner = cat;
  } // end assignCategory()




  void revokeCategory() {
    owner = null;
  } // end revokeCategory()




  void reassignCategory( CodeCategory cat ) {
    revokeCategory();
    assignCategory( cat );
  } // end reassignCategory()




  String toString() {
    String ret = "CodeItem: " + dispName + "\t" + fullName + "\n";
    return ret;
  } // end toString()




} // end class CodeItem

// ========================================
// Contribution Metrics Class
// DistribPt stands for Distribution Point

class DistribPt {

  // Fields

  int value, count;



  
  // Constructor

  DistribPt( int _value, int _count ) {
    value = _value;
    count = _count;
  }




  // Methods

  String toString() {
    return( "Val:" + value + " , Count:" + count );
  }




} // end class DistribPt

// ========================================
// GUI Component Class
// This is just a single straight line divider for decorative purposes.

class Divider {

  // Fields

  float x1, y1, x2, y2;
  int coll, colb, cold;
  boolean horizontal;




  // Constructor

  Divider( boolean _horizontal, float _x1, float _y1, float _x2, float _y2, int _col ) {
    horizontal = _horizontal;
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    coll = constrain( _col + 60, 0, 255 );
    colb = _col;
    cold = constrain( _col - 60, 0, 255 );
  } // end constructor




  // Methods

  void display() {
    strokeWeight( 1 );
    if( horizontal ) { // divider is horizontal
      stroke( coll );
      line( x1, y1 - 1, x2, y2 - 1 );
      stroke( colb );
      line( x1, y1,      x2,      y2 );
      stroke( cold );
      line( x1, y1 + 1, x2, y2 + 1 );
    } else { // divider is vertical
      stroke( coll );
      line( x1 - 1, y1, x2 - 1, y2 );
      stroke( colb );
      line( x1, y1,      x2,      y2 );
      stroke( cold );
      line( x1 + 1, y1, x2 + 1, y2 );
    }
  } // end display()




} // end class Divider

// ========================================
// GUI Component Class 
// This imitates classic drop-down boxes

class Dropdown {
  
  // Fields
  
  float x1, y1, x2, y2;  // edge to edge coordinats
  float x1b, y1b, x2b, y2b; // dropdown button coordinates
  float x1e, y1e, x2e, y2e; // expanded coordinates
  int maxExpandedRows; // maximum number of rows displayed when expanded
  float rowWidth, rowHeight; // width and height (in pixels) of each row
  float stepperWidth; // width of the "stepper", the interface to scroll up & down an expanded list
  int linkIndex;  // unique index for each Dropdown object instance
  String label;
  float xlabel, ylabel;
  color bgColor;  // background color
  color selColor;  // selector color
  color textColor;  // text color
  String[] ddItems;  // dropdown items
  String selItem;  // selected item
  String prevSelItem;  // previous selected Item
  AButton ddButton;  // dropdown button
  boolean expanded;  // true if displaying items to user for selection




  // Constructor
  
  Dropdown( float x1d, float y1d, float x2d, float y2d, int index, String lbl ) {
    expanded = false;
    maxExpandedRows = 5;
    rowHeight = 20;
    rowWidth = 40;
    stepperWidth = 20;
    if( x2d - x1d >= rowWidth || y2d - y1d >= rowHeight ) {  // minimum size is 40x20
      x1 = x1d;
      y1 = y1d;
      x2 = x2d;
      y2 = y2d;
      x1b = x2 - rowHeight;
      y1b = y1;
      x2b = x2;
      y2b = y2;
      linkIndex = index;
      label = lbl;
      xlabel = x1 - 10 - textWidth( label );
      ylabel = y2 - 5;
    } else {
      x1 = 0;
      y1 = 0;
      x2 = 0;
      y2 = 0;
      x1b = 0;
      y1b = 0;
      x2b = 0;
      y2b = 0;
      linkIndex = index;
      label = "Dropdown box for [" + lbl + "] is defined too small!";
      xlabel = width * 0.1;
      ylabel = ( linkIndex + 1 ) * rowHeight;
    }
    ddButton = new AButton( x1b, y1b, x2b, y2b, 0 );
    bgColor = color( 255, 255, 255 );
    selColor = color( 200, 80, 80 );
    textColor = color( 0, 0, 0 );
    selItem = "";
    prevSelItem = "";
  } // end constructor




  // Methods

  void display() {
    fill( 0 );
    text( label, xlabel, ylabel );
    stroke( 0, 0, 0 );
    fill( bgColor );
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
    // print selected item
    fill( 0 );
    if( selItem == "" )
      text( " --- ", x1 + 3, y2 - 3 );
    else
      text( selItem, x1 + 3, y2 - 3 );
    // handle dropdown button
    ddButton.update();
    ddButton.display();
    fill( 0 );
    triangle( ddButton.x1 + 5, ddButton.y1 + 5, ddButton.x1 + ((ddButton.x2-ddButton.x1)/2), ddButton.y2 - 5, ddButton.x2 - 5, ddButton.y1+5 );
  } // end display()



  
  void secondLayerDisplay() {
    if( getExpanded() ) {
      updateExpanded();
      displayExpanded();
    }
  } // end secondLayerDisplay()



  
  void expand() {
    expanded = true;
  } // end expanded()



  
  boolean getExpanded() {
    return expanded;
  }



  
  String getSelectedItem() {
   return selItem; 
  }



  
  void setSelectedItem( String s ) {
    selItem = s; 
  }



  
  String getPrevSelectedItem() {
   return prevSelItem; 
  }



  
  void setPrevSelectedItem( String s ) {
   prevSelItem = s; 
  }



  
  void destroyDDItems() {
    ddItems = new String[ 0 ];
    x1e = x1;
    y1e = y2;
    x2e = x2;
    y2e = y1e + ( ddItems.length * rowHeight );
  } // end destroyDDItems()




  void buildDDItems( String[] ddi ) {
    ddItems = new String[ ddi.length ];
    for( int i = 0; i < ddi.length; i++ )
      ddItems[ i ] = ddi[ i ];
    x1e = x1;
    y1e = y2;
    x2e = x2;
    if( ddi.length <= maxExpandedRows ) 
      y2e = y1e + ( ddi.length * rowHeight );
    else
      y2e = y1e + ( maxExpandedRows * rowHeight );
  } // end buildDDItems()




  void updateExpanded() {
    if( mouseX <= x1 || mouseX >= x2 || mouseY <= y1 || mouseY >= y2e ) {
      expanded = false;
    }
  } // end updateExpanded()
  


  
  void displayExpanded() {
    if( ddItems != null ) {
      // draw dropdown box
      stroke( 0, 0, 0 );
      fill( bgColor );
      rectMode(CORNERS );
      int numItems = ddItems.length;
      rect( x1e, y1e, x2e, y2e );

      if( numItems <= maxExpandedRows ) {  // draw dropdown contents
        for( int i = 0; i < ddItems.length; i++ ) {
          // draw highlight
          if( mouseX >= x1e && mouseX <= x2e && mouseY > y1e + ( i * rowHeight ) && mouseY <= y1e + ((i+1)*rowHeight) ) {
            fill( 180, 180, 240 );
            noStroke();
            rectMode( CORNERS );
            rect( x1e, y1e+( i * rowHeight ), x2e, y1e+((i+1)*rowHeight) );
          } 
          // print dropdown items 
          fill( 0 );
          text( ddItems[ i ], x1+ 3, y2 - 3 + ( ( i+1 ) * rowHeight ) );
        } // end for
      } else {
        int curIndex = getItemIndex( selItem ); 
        if( curIndex == -1 )
          curIndex = 0;
        int expStartIndex = curIndex;
        if( numItems - 1 - curIndex < maxExpandedRows) // if current sel Index is within the 'last screen' of expanded display
	  expStartIndex = numItems - maxExpandedRows;  // set the beginning of the expanded display to show the 'last screen'
        int expStopIndex = expStartIndex + maxExpandedRows; 
       	for( int i = expStartIndex; i < expStopIndex; i++ ) {
          // draw highlight
	  if( mouseX >= x1e && mouseX <= x2e - stepperWidth && mouseY > y1e + ( (i-expStartIndex) * rowHeight ) && mouseY <= y1e + (i-expStartIndex+1) * rowHeight ) {
	    fill( 180, 180, 240 );
	    noStroke();
	    rectMode( CORNERS );
	    rect( x1e, y1e+( ( i-expStartIndex ) * rowHeight ), x2e-stepperWidth, y1e+((i-expStartIndex+1)*rowHeight) );
	  }
	  // print dropdown items
	  fill( 0 );
	  text( ddItems[ i ], x1+3, y2-3 + ( (i-expStartIndex+1) * rowHeight ) );
        }
        // draw stepper bar
        stroke( 0 );
        fill( 200, 200, 200 );
        rect( x2e - stepperWidth, y1e, x2e, y2e );
        line( x2e - stepperWidth, y1e + ( (y2e-y1e) / 2 ), x2e, y1e + ((y2e-y1e)/2) );
        
        line( x2e-(stepperWidth/2), y1e+20, x2e - 3, y1e + 40 );
        line( x2e-(stepperWidth/2), y1e+20, x2e-stepperWidth + 3, y1e + 40 );
        line( x2e-(stepperWidth/2), y2e-20, x2e - 3, y2e - 40 );
        line( x2e-(stepperWidth/2), y2e-20, x2e-stepperWidth + 3, y2e - 40 );
      } // end else 
    }
  } // end displayExpanded()



  
  int getItemIndex( String sel ) {
  // returns index number of selected item, starts from 0 and not 1
  // if can't find item, or selected item is "", returns -1
  //
    if( sel.equals( "" ) )
      return -1;
    else {
      int ret = 0;
      while( ret < ddItems.length ) {
        if( ddItems[ ret ].equals( sel ) )
	  break;
        ret++;
      }
      if( ret == ddItems.length ) // can't find sel in ddItems
        ret = -1;
      return ret;
    }
  } // end getItemIndex()




  int getItemCount() {
    if( ddItems != null )
      return ddItems.length;
    else
      return 0;
  } // end getItemCount()



  
  String getLabel() {
    return label;
  } // end getLabel()
  



  void clearSelection() {
    selItem = "";
    destroyDDItems();
    prevSelItem = "";
  } // end clearSelection



  
  void updateSelection() { // This would be called only after following a LEFT MOUSECLICK
    if( ddItems != null )
      if( ddItems.length <= maxExpandedRows ) {
        for( int i = 0; i < ddItems.length; i++ ) {
          if( mouseX >= x1e && mouseX <= x2e && mouseY > y1e + ( i * rowHeight ) && mouseY <= y1e + ((i+1)*rowHeight) ) {
            setPrevSelectedItem( getSelectedItem() );
            setSelectedItem( ddItems[ i ] );
            expanded = false;
          }
        } // end for
      } else {
        // scrolling ddItems up and down
	if( mouseX >= x2e-stepperWidth && mouseX <= x2e ) {
          int selIndex = 0;
          if( mouseY >= y1e && mouseY <= y1e+((y2e-y1e)/2) ) { // scroll up
            selIndex = max( getItemIndex( getSelectedItem() ) - maxExpandedRows, 0 );    
	  } else if( mouseY >= y1e+((y2e-y1e)/2) && mouseY <= y2e ) { // scroll up
            selIndex = min( getItemIndex( getSelectedItem() ) + maxExpandedRows, ddItems.length - 1 );
          }
	  setPrevSelectedItem( getSelectedItem() );
          setSelectedItem( ddItems[ selIndex ] );
	  expanded = true;
	  displayExpanded();
          //break();
        }
        int numItems = ddItems.length;
        int curIndex = getItemIndex( selItem ); 
        int expStartIndex = curIndex;
        if( numItems - 1 - curIndex < maxExpandedRows) // if current sel Index is within the 'last screen' of expanded display
	  expStartIndex = numItems - maxExpandedRows;  // set the beginning of the expanded display to show the 'last screen'
        int expStopIndex = expStartIndex + maxExpandedRows; 
       	for( int i = expStartIndex; i < expStopIndex; i++ ) {
	  if( mouseX >= x1e && mouseX <= x2e - stepperWidth && mouseY > y1e + ( (i-expStartIndex) * rowHeight ) && mouseY <= y1e + (i-expStartIndex+1) * rowHeight ) {
	    setPrevSelectedItem( getSelectedItem() );
	    setSelectedItem( ddItems[ i ] );
	    expanded = false;
	  }
      } // end else
    }
  } // end updateSelection()




} // end class Dropdown

// ========================================
// Data Modelling Class 
// Used by the Wave and Spiral visualizers
// A Function object holds all the fields of the GenSing artefacts dataset
// plus a few more 'derived' fields such as serialNum and cPostTime

class Function {
  
  // Fields

  int serialNum;
  int postTime;
  Post_Time cPostTime;
  String studentID, yOrder, funcString;
  boolean hit; // 1 is "HIT", 0 is "NO-HIT" OR "UNASSESSED"
  String hitTxt; // raw value of the HIT/NO-HIT cell: "HIT" / "NO-HIT" / "UNASSESSED"
  //boolean tagged; // 1 is tagged, 0 is not tagged
  boolean isValid;  // true if this is a valid mathematical equation
  



  // Constructor
  
  Function( Table _artefacts, int row ) {
    serialNum = _artefacts.getInt( row, 0 );
    isValid = _artefacts.getString( row, 1 ).toLowerCase() === 'true';
    postTime = _artefacts.getInt( row, 2 );
    cPostTime = new Post_Time( postTime, _artefacts.getString( 0, 0 ) );
    studentID = _artefacts.getString( row, 3 );
    yOrder = _artefacts.getString( row, 4 );
    funcString = _artefacts.getString( row, 5 );
    hit = loadStatus( _artefacts, row, 6 );
    hitTxt = _artefacts.getString( row, 6 );
  } // end constructor Functions



  // Overloaded Constructor for live Database "Streaming"

  Function( Table t, int row, int lastSerNum ) {
  // serial number is derived from one of the arguments passed into the 
  // constructor
  // example INPUT:      -- NOTE: May change following implementation of "assessor"
  // 39   true   103   [student20]   Y1  2x+3x+2x+3x-x-x   UNASSESSED   VASM|MT   annotation1|ann2
  // 
    serialNum = t.getInt( row, 0 );
    isValid = t.getString( row, 1 ).toLowerCase() === 'true';
    postTime = t.getInt( row, 2 );
    cPostTime = new Post_Time( postTime, t.getString( row, 2 ) );
    studentID = t.getString( row, 3 );
    yOrder = t.getString( row, 4 );
    funcString = t.getString( row, 5 );
    hit = loadStatus( t, row, 6 );
    hitTxt = t.getString( row, 6 );
  } // end overloaded constructor




  // Methods

  boolean loadStatus( Table _artefacts, int row, int col ){ 
  // will convert values of the given column from string "HIT" and "NO-HIT" to boolean "true" and "false"
    if( _artefacts.getString( row, col ).equals( "HIT" ) )
      return true;
    else if( _artefacts.getString( row, col ).equals( "NO-HIT" ) )
      return false;
    else
      return false;
  } // end loadStatus()




  String toString() {
    String ret = "";
    ret += "serialNum:" + serialNum + " ";
    ret += "cPostTime:" + cPostTime.getPost_Time_Mins() + " ";
    ret += "studentID:" + studentID + " ";
    ret += "funcString:" + funcString + " ";
    ret += "isValid:" + isValid + ".";
    returnret; 
  } // end toString method




} // end class Function



// ========================================
// Live Visualizer Activity Class ( Extends Activity )
// The parent class for both the Live Spiral and Live Wave visualizer

class LVActivity extends Activity {
    
  // Fields
  
  Table databaseStream;
  String activityDetails;
  String dataWholeChunk, prevDataWholeChunk;
  String baseURLAddress;
  int lastRequestTime;
  int lastIndexReceived;
  boolean hasNewValidDatastream;
  /*
  ArrayList<CodeItem> codeItemsList;
  ArrayList<CodeCateogry> codeCategoriesList;
  Map<String, CodeItem> codeItemsDictionary;
  Map<String, CodeCategory> codeCategoriesDictionary;
  Map<CodeItem, CodeCategory> codeBook;
  */
  CodeCabinet codeCabinet; 




  // Constructor  
  
  LVActivity( LiveSpiral o ) {
    super( o, 0, 0, o.width, o.height ); // maximize window area
    bgColor = color( 255, 255, 255 );    // default bgColor is white

    // does not have a concrete member that extends AUI, 
    // those will be done at the children classes of SpiralActivity and WaveActivity

    dataWholeChunk  ="";
    prevDataWholeChunk = dataWholeChunk;
    lastRequestTime = millis();
    lastIndexReceived = 0;
    baseURLAddress = "";
    hasNewValidDatastream = false;
    /*
    codeItemsList = new ArrayList<CodeItem>();
    codeCategoriesList = new ArrayList<CodeCategory>();
    codeItemsDictionary = new HashMap<String, CodeItem>();
    codeCategoriesDictionary = new HashMap<String, CodeCategory>();
    codeBook = new HashMap<CodeItem, CodeCategory>();
    */
    codeCabinet = new CodeCabinet();
  } // end constructor
  



  // Methods

  void startLV( String[] aDetails ) {
  // NOTE: aDetails [0] [1] [2] is the database url, startTime and title

    buildCodeCabinet();
    myAjaxObject = new AjaxObject();
    connectDB( aDetails[ 0 ] );
    baseURLAddress = makeBaseURLAddress( aDetails[ 0 ] );
    activityDetails = aDetails[ 1 ] + "\t" + aDetails[ 2 ] + "\t\t\t\t\t\t\t\t"; // REMEMBER to tally number of \t-s with number of column in the dataset 
    // as this will become the column title row for the dataStream
  } // end startLV() 




  void display() {
    super.display();
    // Put details of drawing stuff inside render() below
  } // end display()




  void prerender() {
    super.prerender();
  } // end prerender()
    
    
    
    
  void render() {
  // draw background and update datastream from the database
  //
    super.drawFrameBkground();
    updateDatastream();
  } // end render()




  void updateDatastream() {
    
    // fetch new data stream and inspect it
    dataWholeChunk = myAjaxObject.request.responseText;
    if( dataWholeChunk.equals( "" ) == false &&
        dataWholeChunk.equals( prevDataWholeChunk ) == false ) {
      // println( "\t\t\t >>> dataWholeChunk is: " + dataWholeChunk + " . " );
      String[] dataInRows = split( dataWholeChunk, "\n"); 

      // if looks ok, turn it into a Table and populate funcs then add spokes
      if( dataInRows[ 0 ].equals( "Contributions:" ) == true && dataInRows.length > 1 ) {
        lastIndexReceived = updateLastIndexReceived( dataInRows );
        dataInRows = cleanRows( dataInRows );
        databaseStream = new Table( dataInRows );
        hasNewValidDatastream = true;
        // NOTE: children classes will need to check if hasNewValidDatastream
        // is true, before running their processDatastream() method
      }
    }
    prevDataWholeChunk = dataWholeChunk;

    // the polling every 5 seconds:  //new: 50
    int now = millis();
    if( now - lastRequestTime > 50000 ) {
      String s = makeNextURLAddress( baseURLAddress );
      println( "About to poll database on this address: " + s );
      if( myAjaxObject == null ) {
        myAjaxObject = new AjaxObject();
      }
      connectDB( s );
      lastRequestTime = millis();
    }
           
  } // end updateDatastream()




  String makeBaseURLAddress( String adetails ) {
      String ret = "";
      String lastOne = adetails.substring( adetails.length() - 1, adetails.length() );
      //if( lastOne.matches( "[0..9]" ) ) { // ends with an index number
        ret = adetails.substring( 0, adetails.length() - 1 );
      //}
      //else
      //  ret = adetails;
      println( "baseURLAddress is now: " + ret );
      return ret;
    } // end makeBaseURLAddress()
    
    
    
    
  String makeNextURLAddress( String baseAdd ) {
    if( baseAdd.endsWith( "getAllContributions" ) )
      return baseAdd;
    else
      return baseAdd + lastIndexReceived;
  } // end makeNextURLAddress() 
    
    

    
  void buildCodeCabinet() {
  // populates the ArrayLists and HashMaps that facilitate usage of Codes
  //     
    println( "BUILDING CODECABINET : " );
    String[] dbGetCodeD = loadStrings( "http://localhost:9000/getCodeDictionary" );
    //String[] dbGetCodeD = loadStrings( "http://localhost:9914/dbGetCodeD" );
    String codeCatStamp = "";
    CodeCategory stampObject = null;
    String codeItemStamp = "";

    if( dbGetCodeD != null && dbGetCodeD[ 0 ].equals( "FAILED" ) == false ) { // safety check
      // clean dbGetCodeD from blank rows
      ArrayList<String> dbGetCodeDCleaned = new ArrayList();
      for( String row : dbGetCodeD ) {
        if( row.equals( "" ) == false )
          dbGetCodeDCleaned.add( row );
      }
      // overwrite the original dbGetCodeD
      dbGetCodeD = new String[ dbGetCodeDCleaned.size() ];
      for( int i = 0; i < dbGetCodeD.length; i++ ) {
        dbGetCodeD[ i ] = dbGetCodeDCleaned.get( i ); 
      }
      String [] [] dbCodeDPieces = new String[ dbGetCodeD.length ][ 2 ];
      
      for( int i = 0; i <  dbGetCodeD.length; i++ ) {
        dbCodeDPieces [ i ] = splitTokens( dbGetCodeD[ i ], " " );
        
        String tempPiece = dbCodeDPieces[ i ] [ 0 ];
        if( tempPiece.equals( "CATEGORY:" ) ) {
          codeCatStamp = dbCodeDPieces[ i ] [ 1 ];  
          if( codeCatStamp.equals( "UNCATEGORIZED" ) == false ) { // if category is concrete
            stampObject = new CodeCategory( codeCatStamp );
            println( "\tAdded " + stampObject );
            codeCabinet.codeCategoriesList.add( stampObject );
            codeCabinet.codeCategoriesDictionary.put( codeCatStamp, stampObject );
          }

        } else if( tempPiece.equals( "DESCRIPTOR:" ) ) {
          codeItemStamp = dbCodeDPieces[ i ] [ 1 ];
          //println( dbCodeDPieces[ i ] [1] );
          CodeItem ctemp = null;
          if( codeCatStamp.equals( "UNCATEGORIZED" ) == false ) { // if category is concrete
            ctemp = new CodeItem( stampObject, codeItemStamp );
            println( "\t\tAdded: " + ctemp );
            codeCabinet.codeBook.put( ctemp, stampObject );
            stampObject.addCodeItem( ctemp );
          } else {
            // dont put in codeBook HashMap coz ctemp's owner is null, 
            // the owner is  NOT an instance of CodeCategory with dispName="UNCATEGORIZED"
            ctemp = new CodeItem( codeItemStamp );
            println( "\tAdded: " + ctemp ); 
          }
          codeCabinet.codeItemsList.add( ctemp );
          codeCabinet.codeItemsDictionary.put( codeItemStamp, ctemp );
            
        } // end else "DESCRIPTOR:"
      } // end for i
    } // end if got valid data
  
    // below are just a block of dummy data for testing
    CodeCategory catMath = codeCabinet.codeCategoriesDictionary.get( "Math" );
    CodeItem c1, c2, c3, c4, c5, c6, c7, c8, c9, c10;
    c1 = new CodeItem( "M1" );
    c2 = new CodeItem( "M2" );
    c3 = new CodeItem( "M3" );
    c4 = new CodeItem( "M4" );
    c5 = new CodeItem( "M5" );
    c6 = new CodeItem( "M6" );
    c7 = new CodeItem( "M7" );
    c8 = new CodeItem( "M8" );
    c9 = new CodeItem( "M9" );
    c10 = new CodeItem("M10" );
    codeCabinet.codeItemsList.add( c1 );
    codeCabinet.codeItemsList.add( c2 );
    codeCabinet.codeItemsList.add( c3 );
    codeCabinet.codeItemsList.add( c4 );
    codeCabinet.codeItemsList.add( c5 );
    codeCabinet.codeItemsList.add( c6 );
    codeCabinet.codeItemsList.add( c7 );
    codeCabinet.codeItemsList.add( c8 );
    codeCabinet.codeItemsList.add( c9 );
    codeCabinet.codeItemsList.add( c10 );
    codeCabinet.codeItemsDictionary.put( c1.dispName, c1 );
    codeCabinet.codeItemsDictionary.put( c2.dispName, c2 );
    codeCabinet.codeItemsDictionary.put( c3.dispName, c3 );
    codeCabinet.codeItemsDictionary.put( c4.dispName, c4 );
    codeCabinet.codeItemsDictionary.put( c5.dispName, c5 );
    codeCabinet.codeItemsDictionary.put( c6.dispName, c6 );
    codeCabinet.codeItemsDictionary.put( c7.dispName, c7 );
    codeCabinet.codeItemsDictionary.put( c8.dispName, c8 );
    codeCabinet.codeItemsDictionary.put( c9.dispName, c9 );
    codeCabinet.codeItemsDictionary.put( c10.dispName, c10 );
    catMath.addCodeItem( c1 );
    catMath.addCodeItem( c2 );
    catMath.addCodeItem( c3 );
    catMath.addCodeItem( c4 );
    catMath.addCodeItem( c5 );
    catMath.addCodeItem( c6 );
    catMath.addCodeItem( c7 );
    catMath.addCodeItem( c8 );
    catMath.addCodeItem( c9 );
    catMath.addCodeItem( c10 );
    codeCabinet.codeBook.put( c1, catMath );
    codeCabinet.codeBook.put( c2, catMath );
    codeCabinet.codeBook.put( c3, catMath );
    codeCabinet.codeBook.put( c4, catMath );
    codeCabinet.codeBook.put( c5, catMath );
    codeCabinet.codeBook.put( c6, catMath );
    codeCabinet.codeBook.put( c7, catMath );
    codeCabinet.codeBook.put( c8, catMath );
    codeCabinet.codeBook.put( c9, catMath );
    codeCabinet.codeBook.put( c10, catMath );
  
  } // end buildCodeCabinet()



  
  void connectDB( String s ) {
    lastRequestTime = millis();
println("about to attempt connectDB with get request at " + s);
    myAjaxObject.request.open( "GET", s + makeNoCache(), true );
    myAjaxObject.request.send( null );
    println( "connecting to DB @ " + s + makeNoCache() );
  } // end connectDB()




  String makeNoCache() {
    noCache = "&noCache=" + Math.random() * 1000000;
    String ret = noCache;
    return ret;
  } // end makeNoCache()




  int updateLastIndexReceived( String[] received ) {
    String lastRow = received[ received.length - 2 ];
    String[] pieces = split( lastRow, "\t" );
    int ret = parseInt( pieces[ 0 ] );
    return ret;
  }  // end updateLastIndexReceived()




  String[] cleanRows( String[] tbCleaned ) {
  // discards all rows which is not a contribution of type "EQUATION" and 
  // ensures  that each row contains the correct number of columns with 
  // correct column data in place.
  // example INPUT:
  // 39	  true   EQUATION  103   [student20]   Y1   2x+3x+2x+3x-x-x    VASM|MT   annotation1|ann2
  // example OUTPUT:      -- NOTE: May change following implementation of "assessor"
  // 39   true  103   [student20]   Y1  2x+3x+2x+3x-x-x   UNASSESSED   VASM|MT   annotation1|ann2
  //
    int irrelevantRows = 0;
    for( int i = 1; i < tbCleaned.length - 1; i++ ) {
      String[] cells = fixedSplitToken( tbCleaned[ i ], "\t", 9 ); 
      if( cells[ 2 ].equals( "EQUATION" ) == false ) { // discard non "EQUATION" contributions
        tbCleaned[ i ] = ""; // overwrite the row with blank String        
        irrelevantRows++;
      }
    }

    // Copy over all non-blank rows into a new array of rows
    String[] cleaned = new String[ tbCleaned.length - irrelevantRows - 1 ];     
    cleaned[ 0 ] = activityDetails;
    int nextPosCleaned = 1;
    for( int z = 1; z < tbCleaned.length; z++ ) {    
      if( tbCleaned[ z ].equals( "" ) == false ) {
        String[] cells = fixedSplitToken( tbCleaned[ z ], "\t", 9 );
        // sewing back all the columns received from database except Contribution Type )
        String tempR = cells[ 0 ] + "\t" + cells[ 1 ] + "\t";
        // So we'll start with the fourth column (index 3)
        for( int k = 3; k < cells.length-2; k++ ) {
          tempR += cells[ k ] + "\t";  
        }
        tempR += "UNASSESSED\t" + cells[ cells.length-2 ] + "\t" + cells[ cells.length-1 ];
        // NOTE: the line above mayneed to be changed following implementation of an assessor
        // for (Hit/No-Hit) for historical sessions.
        cleaned[ nextPosCleaned ] = tempR;
	nextPosCleaned++;
      }
    }
    println( "VERIFY IF INDEED CLEANED:" );
    println( cleaned );
    return cleaned; 
  }  // end cleanRows()
  
  
  
  String[] fixedSplitToken( String row, String tkn, int targetCol ) {
    String input = row;
    String token = tkn;
    int colCount = targetCol;
    String[] ret = new String[ colCount ];

    int i = 0;
    int j = input.indexOf( token, i+1 );

    for( int index = 0; index < colCount - 1; index++ ) {
      String nextpiece = input.substring( i, j );
      ret[ index ] = nextpiece;
      i = j+1;
      j = input.indexOf( token, i );
    }
    ret[ colCount-1 ] = input.substring( i );
  return ret;
} // end fixedSplitToken()



  
  void prepForNextDatastream() {
    // prepare for next wave of data - designed to be called only
    // by children classes of SpiralActivity and WaveActivity,
    // after they called super.render() and their respective 
    // populatefuncs() and applyToX() routines
    // 
    dataWholeChunk = "";
    databaseStream = null;
    hasNewValidDatastream = false;
    String addressForNextPoll = makeNextURLAddress( baseURLAddress );
    //htmlRequest = new HTMLRequest( owner, addressForNextPoll );
  } // end prepForNextDatastream()  

  


  String toString() {
   return( "This is LVActivity, an object of class Activity which is the ancestor for both the Live Spiral and Live Wave viz" ); 
  }

  

  
} // end class LVActivity
// ========================================
// Contribution Metrics Class
// OpDistrib stands for Operand Distribution

class OpDistrib {
  
  // Fields:
  
  int[] procVals, procCounts;
  int walker = 0;
  ArrayList pointsHit, pointsNoHit, pointsAll;
  String label;
  



  // Constructor

  OpDistrib( char opType, Spiral _spiral ) {
    procVals = new int[ 1 ];
    procCounts = new int[ 1 ];
    
    // Live Spiral will ignore the seed - populate - harvest cycles 
    // for HIT and NO-HITs since the live data are still UNASSESSED
    /*
    seedProcArrs( opType, _spiral, true ); // for Hit functions first; HIT = true, No-Hit = false;
    populateProcArrs( opType, _spiral, true );
    harvestProcArrs( true );
    
    resetProcArrs();
    
    seedProcArrs( opType, _spiral, false ); // now for NoHit functions; HIT = true, No-Hit = false;
    populateProcArrs( opType, _spiral, false );
    harvestProcArrs( false );
    
    resetProcArrs();
    */
    populateProcArrs( opType, _spiral ); // now for both Hit and NoHit functions. Note: No Seeding needed for All
    harvestProcArrs();
    
    // Live Spiral will ignore HIT and NO-HIT 
    // sortDistribPoints( pointsHit );
    // sortDistribPoints( pointsNoHit );
    sortDistribPoints( pointsAll );
        
    //showDistribPoints();
  
  } // end constructor
  


  // Overloaded constructor for instantiating OpDistrib objects for datasets 
  // which contain no data ("NO DATA")
  OpDistrib( char _opType ) {         
    switch( _opType ) {      // pass on _opType to determine label
      case 'P':
        label = "[ + ]";
      break;
      case 'M':
        label = "[ - ]";
      break;
      case 'T':
        label = "[ * ]";
      break;
      case 'D':
        label = "[ / ]";
      break;
      case 'S':
        label = "[ ^ ]";
      break;
      case 'N':
        label = "[ -() ]";
      break;
      default :
        label = "";
      break;      
    } // end switch
    
    // create three ArrayLists of DistribPt objects, 
    // with value and count of 0 and 0 - for the NO DATA section
    pointsHit = new ArrayList();
    pointsHit.add( new DistribPt( 0, 0 ) );
    pointsNoHit = new ArrayList();
    pointsNoHit.add( new DistribPt( 0, 0 ) );
    pointsAll = new ArrayList();
    pointsAll.add( new DistribPt( 0, 0 ) );   
  } // end constructor (Overloaded)




  // overloaded constructor for instantiating School-level OpDistrib objects
  OpDistrib( ArrayList _pointsHit, ArrayList _pointsNoHit, ArrayList _pointsAll, String _label ) { 
    pointsHit = _pointsHit;
    pointsNoHit = _pointsNoHit;
    pointsAll = _pointsAll;
    label = _label;
  } // end constructor ( Overloaded )
  
  


  // Methods
  
  void seedProcArrs( char opType, Spiral _spiral, boolean _hit ) {
    int comparisonOp = 0;
    boolean hitMatch = false;
    int c = 0;
    while( ( hitMatch == false )  && ( c <= _spiral.spokes.size() )  ){
      Spoke s1 = ( Spoke ) _spiral.spokes.get( c ); // go through each row till first hitMatch is found
      c++;
      if( _hit == s1.hit ) {
        hitMatch = true;
        switch( opType ) {
          case 'P' :
            comparisonOp = s1.numOpPlus;
            label = "[ + ]";
          break;
          case 'M' :
            comparisonOp = s1.numOpMinus;
            label = "[ - ]";
          break;
          case 'T' :
            comparisonOp = s1.numOpTimes;
            label = "[ * ]";
          break;
          case 'D' :
            comparisonOp = s1.numOpDivides;
            label = "[ / ]";
          break;
          case 'S' :
            comparisonOp = s1.numBonSquare;
            label = "[ ^ ]";
          break;
          case 'N' :
            comparisonOp = s1.numBonNegative;
            label = "[ -() ]";
          break;
          default :
            //comparisonOp = 0;
          break;
        } // end switch
        
        // switch
        // label = 
        // TO BE CONTINUED
        
        procVals[ 0 ] = comparisonOp;
        procCounts[ 0 ] = 1;
        walker = c + 1;
        //hitMatch = true;
      } // end if hitMatch
    } // end while
  } // end seedProcArrs()  
  



  void populateProcArrs( char opType, Spiral _spiral, boolean _hit ) {
    int comparisonOp = 0;
    for( int i = walker - 1; i < _spiral.spokes.size(); i++ ) {
      Spoke s = ( Spoke ) _spiral.spokes.get( i );
      if( _hit == s.hit ) { // only execute the code below if hitMatch
        switch( opType ) {
          case 'P' :
            comparisonOp = s.numOpPlus;
          break;
          case 'M' :
            comparisonOp = s.numOpMinus;
          break;
          case 'T' :
            comparisonOp = s.numOpTimes;
          break;
          case 'D' :
            comparisonOp = s.numOpDivides;
          break;
          case 'S' :
            comparisonOp = s.numBonSquare;
          break;
          case 'N' :
            comparisonOp = s.numBonNegative;
          break;
          default :
            //comparisonOp = 0;
          break;
        } // end switch
          
        int found = 0;
        int sumfound = 0;
        for( int l = 0; l < procVals.length; l++ ) { // go through procVals array
          if( procVals[ l ] == comparisonOp ) { // check if the value of comparisonOp is already in the procVals array
            found = 1;  
            procCounts[ l ] ++; // increase the count for that value
          } // end if the value of comparisonOp is already in the procVals array
          sumfound += found;
        } // end for l   

        if( sumfound == 0 ) { // the value of comparisonOp is not found within the current procVals array (its a new value)
          procVals = append( procVals, comparisonOp );
          procCounts = append( procCounts, 1 );

        } // end if its a new value
      } // end if hitMatch
    } // end for i
  } // end populateProcArrs()



  
  void populateProcArrs( char opType, Spiral _spiral ) { // OVERLOADED METHOD FOR BOTH HIT & NOHIT FUNCTIONS
    int comparisonOp = 0;
    for( int i = 0; i < _spiral.spokes.size(); i++ ) {
      Spoke s = ( Spoke ) _spiral.spokes.get( i );
      switch( opType ) {
        case 'P' :
          comparisonOp = s.numOpPlus;
        break;
        case 'M' :
          comparisonOp = s.numOpMinus;
        break;
        case 'T' :
          comparisonOp = s.numOpTimes;
        break;
        case 'D' :
          comparisonOp = s.numOpDivides;
        break;
        case 'S' :
          comparisonOp = s.numBonSquare;
        break;
        case 'N' :
          comparisonOp = s.numBonNegative;
        break;
        default :
          //comparisonOp = 0;
        break;
      } // end switch
          
      int found = 0;
      int sumfound = 0;
      for( int l = 0; l < procVals.length; l++ ) { // go through procVals array
        if( procVals[ l ] == comparisonOp ) { // check if the value of comparisonOp is already in the procVals array
          found = 1;  
          procCounts[ l ] ++; // increase the count for that value
        } // end if the value of comparisonOp is already in the procVals array
        sumfound += found;
      } // end for l   

      if( sumfound == 0 ) { // the value of comparisonOp is not found within the current procVals array (its a new value)
        procVals = append( procVals, comparisonOp );
        procCounts = append( procCounts, 1 );
      } // end if its a new value
    } // end for i
  } // end populateProcArrs()
  
  void harvestProcArrs( boolean _hit ) {
    if( _hit ) { // store to Hit araylist
      pointsHit = new ArrayList();
      for( int i = 0; i < procVals.length; i++ )
        pointsHit.add( new DistribPt( procVals[ i ], procCounts[ i ] ) );
    } else { // store to NoHit arraylist
      pointsNoHit = new ArrayList();
      for( int i = 0; i < procVals.length; i++ )
        pointsNoHit.add( new DistribPt( procVals[ i ], procCounts[ i ] ) );      
    } // end else
  } // end harvestProcArrs



  
  void harvestProcArrs() { // OVERLOADED METHOD FOR BOTH HIT & NOHIT (ALL) FUNCTIONS
    pointsAll = new ArrayList();
    for( int i = 0; i < procVals.length; i++ )
      pointsAll.add( new DistribPt( procVals[ i ], procCounts[ i ] ) );
  } // end harvestProcArrs
  
  

  
  void resetProcArrs() {
    procVals = expand( procVals, 1 );
    procVals[ 0 ] = 0;
    procCounts = expand( procCounts, 1 );
    procCounts[ 0 ] = 0;
    walker = 0;
  } // end resetProcArrs()



  
  void sortDistribPoints( ArrayList _points ) {
   // will sort pointsHit, pointsNoHit, pointsAll depending on the passed argument 
   for( int i = 0; i < _points.size(); i++ ) {
     
     for( int j = 0; j < i; j++ ) {
         DistribPt pj = ( DistribPt ) _points.get( j );
         DistribPt pi = ( DistribPt ) _points.get( i );
         if( pj.value > pi.value ) { 
           // swap
           DistribPt pswap = pj;
           
           _points.remove( j );
           _points.add( j, new DistribPt( pi.value, pi.count ) );
           
           _points.remove( i );
           _points.add( i, new DistribPt( pswap.value, pswap.count ) );
             
         } // end if
     } // end for j
   } // end for i
  } // end sortDistrib()



  
  void showArrayPoints(  ) {
    println( "====================================");
    println( "Array of Points for the " + label + " operator : ");
    println( "Values >-< Counts" );
    for( int i = 0; i < procVals.length; i++ ) {
      println( procVals[ i ] + " >-< " + procCounts[ i ] );
   } // end for i
  } // end showArrayPoints()



  
  void showDistribPoints() {
    println( "====================================");
    println( "Distribution Points for the " + label + " operator  (from the ArrayList): ");
    println( "HIT");
    println( "------------" );
    println( "Values >-< Counts" );
    for( int i = 0; i < pointsHit.size(); i++ ) {
      DistribPt p = ( DistribPt ) pointsHit.get( i );
      println( p.value + " >-< " + p.count );
    } // end for i
    println( "------------" );
    println( "NO-HIT");
    println( "------------" );
    println( "Values >-< Counts" );      
    for( int i = 0; i < pointsNoHit.size(); i++ ) {
      DistribPt p = ( DistribPt ) pointsNoHit.get( i );
    println( p.value + " >-< " + p.count );
    } // end for i
    println( "------------" );
    println( "ALL");
    println( "------------" );
    println( "Values >-< Counts" );      
    for( int i = 0; i < pointsAll.size(); i++ ) {
      DistribPt p = ( DistribPt ) pointsAll.get( i );
    println( p.value + " >-< " + p.count );
    } // end for i
  } // end showDistribPoitn
  



} // end class OpDistrib

// ========================================
// Contribution Metrics Class
// OpsStats stands for Operands Statistics

class OpsStats {
  
  // Fields
  
  OpsUsage schOpsUsage;
  ArrayList < OpsUsage > clsOpsUsage = new ArrayList();
  



  // Constructor

  OpsStats( Spiral spir ) {
    clsOpsUsage.add( new OpsUsage() );
    OpsUsage co = ( OpsUsage ) clsOpsUsage.get( 0 );
    // check to see if spir has data
    if( spir.hasData ) {
      co.plusOp     = new OpDistrib( 'P', spir );
      co.minusOp    = new OpDistrib( 'M', spir );
      co.timesOp    = new OpDistrib( 'T', spir );
      co.dividesOp  = new OpDistrib( 'D', spir );
      co.squareOp   = new OpDistrib( 'S', spir );
      co.negativeOp = new OpDistrib( 'N', spir );
    } else {    // tempSections has no data
      co.plusOp     = new OpDistrib( 'P' );
      co.minusOp    = new OpDistrib( 'M' );
      co.timesOp    = new OpDistrib( 'T' );
      co.dividesOp  = new OpDistrib( 'D' );
      co.squareOp   = new OpDistrib( 'S' );
      co.negativeOp = new OpDistrib( 'N' );
    } // end if tempSections has no data
    
    // building the schOpsUsage instance object
    schOpsUsage = new OpsUsage();
    // building instances of OpDistrib objects at the School-level should only be done after building for the Class-level
    schOpsUsage.plusOp     = buildOpDistribSch( 'P', spir );
    schOpsUsage.minusOp    = buildOpDistribSch( 'M', spir );
    schOpsUsage.timesOp    = buildOpDistribSch( 'T', spir );
    schOpsUsage.dividesOp  = buildOpDistribSch( 'D', spir );
    schOpsUsage.squareOp   = buildOpDistribSch( 'S', spir );
    schOpsUsage.negativeOp = buildOpDistribSch( 'N', spir );
   
    //showOpDistribSch( schOpsUsage.negativeOp );
    
  } // end constructor




  // Methods  

  OpDistrib buildOpDistribSch( char opType, Section[] sections ) {
    ArrayList tempPointsHit = new ArrayList();
    ArrayList tempPointsNoHit = new ArrayList();
    ArrayList tempPointsAll = new ArrayList();
    String tempLabel = " ";
    
    // Live Spiral will ignore HIT and NO-HIT routines
    for( int i = 0; i < sections.length; i++ ) { // go through each section, get the appropriate OpDistrib object's pointsHit, pointsNoHit and pointsAll
      OpsUsage co = ( OpsUsage ) clsOpsUsage.get( i );
      switch ( opType ) {
        case 'P' :
          //tempPointsHit = buildSchDistribPt( co.plusOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.plusOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.plusOp.pointsAll, tempPointsAll );
          tempLabel = "[ + ]";  
        break;   
        case 'M' :
          //tempPointsHit = buildSchDistribPt( co.minusOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.minusOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.minusOp.pointsAll, tempPointsAll );
          tempLabel = "[ - ]";  
        break;
        case 'T' :      
          //tempPointsHit = buildSchDistribPt( co.timesOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.timesOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.timesOp.pointsAll, tempPointsAll );
          tempLabel = "[ * ]";  
        break;
        case 'D' :
          //tempPointsHit = buildSchDistribPt( co.dividesOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.dividesOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.dividesOp.pointsAll, tempPointsAll );
          tempLabel = "[ / ]";  
        break;
        case 'S' :    
          //tempPointsHit = buildSchDistribPt( co.squareOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.squareOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.squareOp.pointsAll, tempPointsAll );
          tempLabel = "[ ^ ]";  
        break;
        case 'N' :
          //tempPointsHit = buildSchDistribPt( co.negativeOp.pointsHit, tempPointsHit);
          //tempPointsNoHit = buildSchDistribPt( co.negativeOp.pointsNoHit, tempPointsNoHit );
          tempPointsAll = buildSchDistribPt( co.negativeOp.pointsAll, tempPointsAll );
          tempLabel = "[ -() ]";  
        break;
        default :
          tempLabel = " ";
        break;
      } // end switch
    } // end for i
    OpDistrib tempOpSch = new OpDistrib( tempPointsHit, tempPointsNoHit, tempPointsAll, tempLabel );
    /*
    println( "From tempOpSch - Label: " + tempOpSch.label );  
    for( int i = 0; i < tempOpSch.pointsHit.size(); i++ ) {
     DistribPt pt = ( DistribPt ) tempOpSch.pointsHit.get( i );
      println( pt.value +"---"+pt.count ); 
    }
    println(" +++++++++++++ " );
    */
    return tempOpSch;
  } // end buildOpDistribSch
  
  
  
  
  OpDistrib buildOpDistribSch( char opType, Spiral spir ) {
  // Overloaded version for use with Live Spiral, takes Spiral as argument instead of Section[]
  //
    ArrayList tempPointsHit = new ArrayList();
    ArrayList tempPointsNoHit = new ArrayList();
    ArrayList tempPointsAll = new ArrayList();
    String tempLabel = " ";
    
    // Live Spiral will ignore HIT and NO-HIT routines
    // get the appropriate OpDistrib object's pointsHit, pointsNoHit and pointsAll
    OpsUsage co = ( OpsUsage ) clsOpsUsage.get( 0 );
    switch ( opType ) {
        case 'P' :
          tempPointsAll = buildSchDistribPt( co.plusOp.pointsAll, tempPointsAll );
          tempLabel = "[ + ]";  
        break;   
        case 'M' :
          tempPointsAll = buildSchDistribPt( co.minusOp.pointsAll, tempPointsAll );
          tempLabel = "[ - ]";  
        break;
        case 'T' :      
          tempPointsAll = buildSchDistribPt( co.timesOp.pointsAll, tempPointsAll );
          tempLabel = "[ * ]";  
        break;
        case 'D' :
          tempPointsAll = buildSchDistribPt( co.dividesOp.pointsAll, tempPointsAll );
          tempLabel = "[ / ]";  
        break;
        case 'S' :    
          tempPointsAll = buildSchDistribPt( co.squareOp.pointsAll, tempPointsAll );
          tempLabel = "[ ^ ]";  
        break;
        case 'N' :
          tempPointsAll = buildSchDistribPt( co.negativeOp.pointsAll, tempPointsAll );
          tempLabel = "[ -() ]";  
        break;
        default :
          tempLabel = " ";
        break;
    } // end switch

    OpDistrib tempOpSch = new OpDistrib( tempPointsHit, tempPointsNoHit, tempPointsAll, tempLabel );
    /*
    println( "From tempOpSch - Label: " + tempOpSch.label );  
    for( int i = 0; i < tempOpSch.pointsHit.size(); i++ ) {
     DistribPt pt = ( DistribPt ) tempOpSch.pointsHit.get( i );
      println( pt.value +"---"+pt.count ); 
    }
    println(" +++++++++++++ " );
    */
    return tempOpSch;
  } // end buildOpDistribSch
  
  

  
  ArrayList buildSchDistribPt( ArrayList _points, ArrayList _pointsSch ) {
    for( int i = 0; i < _points.size(); i++ ) { // go through each element of _points
      int found = 0;
      int sumfound = 0;
      DistribPt pi = ( DistribPt ) _points.get( i );
      for( int j = 0; j < _pointsSch.size(); j++ ) { // go through each element of _pointsSch and look for current match
        DistribPt pj = ( DistribPt ) _pointsSch.get( j );
        if( pi.value == pj.value ) {
          found = 1;
          pj.count += pi.count; // add the count of pi to the count of pj
        
        } // end if found already in the _pointsSch list
      } // end for j
      sumfound += found;
      if( sumfound == 0 ) { // element not found, must add to _pointsSch
        _pointsSch.add( new DistribPt( pi.value, pi.count ) );
      } // end if element not found, adding new element to _pointsSch
    } // end for i
    return _pointsSch; 
  } // end buildSchDistribPt
    
  void showOpDistribSch( OpDistrib _toShow ) { // for Debugging and Double-checking purposes
    println( _toShow.label );
    int total = 0;
    println( "HIT" );
    for( int i = 0; i < _toShow.pointsHit.size(); i++ ) {
      DistribPt pi = ( DistribPt ) _toShow.pointsHit.get( i );
      println( pi.value + " <===> " + pi.count );
      total += pi.count;
    }
    println( "total: " + total );
  
    total = 0;
  
    println( "NO-HIT" );
    for( int i = 0; i < _toShow.pointsNoHit.size(); i++ ) {
      DistribPt pi = ( DistribPt ) _toShow.pointsNoHit.get( i );
      println( pi.value + " <===> " + pi.count );
      total += pi.count;
    }
    println( "total: " + total );
  
    total = 0;
  
    println( "ALL" );
    for( int i = 0; i < _toShow.pointsAll.size(); i++ ) {
      DistribPt pi = ( DistribPt ) _toShow.pointsAll.get( i );
      println( pi.value + " <===> " + pi.count );
      total += pi.count;
    }
    println( "total: " + total );
  } // end showOpDistribSch()
  



} // end class OpsStats

// ========================================
// Contribution Metrics Class
// OpsUsage stands for Operands Usage

class OpsUsage {

  // Fields

  OpDistrib plusOp, minusOp, timesOp, dividesOp, squareOp, negativeOp;



  
  // Constructors



  
  // Methods

  String toString() {
    String ret = "";
    ret += "showing details of OpsUsage object instance:\n";
    ret += "============================================\n"; 
    
    ret += "\tplusOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < plusOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) plusOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    ret += "\tminusOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < minusOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) minusOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    ret += "\ttimesOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < timesOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) timesOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    ret += "\tdividesOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < dividesOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) dividesOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    ret += "\tsquareOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < squareOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) squareOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    ret += "\tnegativeOp:\n";
    ret += "\t\tpointsAll:\n";
    for( int i = 0; i < negativeOp.pointsAll.size(); i++ ) {
      DistribPt dp = ( DistribPt ) negativeOp.pointsAll.get( i );
      ret += "\t\t\t" + dp.toString() + "\n";
    }
    ret += "\n";

    return ret;
  } // end toString()




} // end class OpsUsage

// ========================================
// a utility class to convert time ( that signifies when a contribution 
// was posted ) from a String input into Post_Time type. 
// Used by both the Wave and the Spiral viz
// Holds posting time data in hh:mm:ss format
// Constructed by passing the post time of a function and the starting time of that exercise

class Post_Time {
    
  // Fields

  int postH,postM,postS;
  int startH, startM, startS;
  int h, m, s;




// Constructor for Post_Time  

Post_Time (int tempPostTime, String startTime) {
  postM= floor(tempPostTime/60);
  postH = floor(postM/60);
  postS = tempPostTime%60;
  println( "startTime is : " + startTime );
  if ( (startTime.charAt(2) == ':') && (startTime.length() == 8)) {
    startH = int(startTime.charAt(0)-'0')*10 + int(+startTime.charAt(1)-'0');
    startM = int(startTime.charAt(3)-'0')*10 + int(+startTime.charAt(4)-'0');
    startS = int(startTime.charAt(6)-'0')*10 + int(+startTime.charAt(7)-'0');
  } else {
    startH = 0;
    startM = 0;
    startS = 0;
  }
  
  // for positive timing
  s = postS + startS;
  m = postM + startM;
  h = postH + startH;
  
  // for negative timing
  if (s <0) {
    s = 60+s;
    m--;
  }
  if (m<0) {
    m = 60+m;
    h--;
  }
  
  // convert to 24h 60m 60s format
  if (s >=60) {
    m+=floor(s/60); 
    s %= 60;
    
  } 
  
  if (m >= 60) {
    h+=floor(m/60);
    m %= 60;
    
  }
  
} // end Post_Time constructor 




String getPost_Time() {
  return (nf(h,2)+":"+nf(m,2)+":"+nf(s,2));
}




String getPost_Time_Mins() {
  return (nf(m,2)+":"+nf(s,2));
}




  String toString() {
    return( getPost_Time() );    
  } // end toString()




} // end class Post_Time


// ========================================
// Contribution Metrics Class
// Holds information to build a scatterplot of "Time vs CRVScore"

class Scatter {
  
  // Fields
  
  float xOffset;           // the Origin - X value
  float yOffset;         // the Origin - Y value
  float xLength;        // length of horizontal axis
  float yLength;        // length of vertical axis
  float oneMinGraph, oneMinDefault;      // Horizontal Scaling - determine the length of "one-min" interval
  float metricStepGraph, metricStepDefault;          //  Vertical Scaling - determine the length of "one-step" interval for the Metric
  int displayStringScatter, gotDisplayStringScatter; // for use in mouseover check for Scatterplot points
  int maxPostTime;
  float maxMetric;
  Spiral spiralScatter;
  String metricLabel;
  int hitButtonX1, hitButtonY1, hitButtonX2, hitButtonY2, noHitButtonX1, noHitButtonY1, noHitButtonX2, noHitButtonY2;
  boolean hasData;
  



  // Constructor

  Scatter( Spiral _spiral ) {
    hasData = _spiral.hasData;
    xOffset = 30;           // the Origin - X value
    yOffset = 260;         // the Origin - Y value
    xLength = 150;        // length of horizontal axis
    yLength = 150;        // length of vertical axis
    oneMinDefault = 60;
    metricStepDefault = 5.0;
    metricLabel = "Creativity Score";
    maxMetric = _spiral.getMaxMetric();
    maxPostTime = _spiral.getMaxPostTime();
    if( hasData ) {
      oneMinGraph = map( oneMinDefault, 0, _spiral.getMaxPostTime(), 0,xLength );      // default Time value per step is 60 secs
      metricStepGraph = map( metricStepDefault, 0, maxMetric, 0, yLength );         // default Metric value per step is 5.00
    } else { // means, has no data
      oneMinGraph = 0;
      metricStepGraph = 0;
    }
    displayStringScatter = 0;
    gotDisplayStringScatter = 0;
    spiralScatter = _spiral;    
  } // end Constructor
  



  // Methods

  void display() {
    clearPanel();
    //inspectScatter();
    if( hasData ) { // draw these if has data
      drawSummStats();
      drawShowHideUI();
      drawBarChart();
      drawScatterPlot();
    } else { // draw the following if has no data
      textSize( 16 );
      stroke( popUpTxt );
      fill( popUpBkgrd );
      rect( xOffset + 20, yOffset - 170, xOffset + textWidth( "No Data For This Class" ) + 40, yOffset - 140 );
      fill( popUpTxt );
      text( "No Data For This Class", xOffset + 30, yOffset - 150 );
    } // end if no data    
  } // end display()



  
  void clearPanel() {
    fill( 255 );
    stroke( 255 );
    rect( 0, 0, 348, 298 );
  } // end clearPanel();



  
  void drawSummStats() {
    fill( 0 );
    textSize( 8 );
    text( "Exercise Duration : " + spiralScatter.cDuration.getPost_Time_Mins(), 20, yOffset - 240 );
    text( "Number of Unique Fns: " + spiralScatter.spokes.size(), 200, yOffset - 240 );
   text( "Total Creativity Metric: " + spiralScatter.crvTotal, 20, yOffset - 225 ); 
  } // end drawSummStats()



    
  void drawBarChart() {
     // draws barchart of Metric for the HIT and NO-HIT functions
    fill( 0 );
    textSize( 8 );
    text( "Distribution Shape: ", xOffset + xLength + 20, yOffset - yLength - 20 );
    plotDistribution( xOffset + xLength + 20, yOffset, yLength, metricStepGraph, metricStepDefault, maxMetric, spiralScatter.spokes ); // default Metric value per step is 5.00
  } // end drawBarChart();
  



  void drawScatterPlot() {
    // draws scatterplot
    fill( 0 );
    textSize( 10 );
    text( "CREATIVITY BY TIME", xOffset + 70, yOffset - 185 );
    textSize( 8 );
    text( "Scatterplot - Unique Fns Only : ", 20, yOffset - yLength - 20 );
    drawAxes(xOffset, yOffset, xLength, yLength, oneMinGraph, metricStepGraph); // draws the X and Y axes  and labelling and markings for the scatterplot
    plotPoints( xOffset, yOffset, xLength, yLength ); // plots the points
  } // end drawScatterPlot()



  
  void drawShowHideUI() {  
   // draws Show-Hide UI
   rectMode( CORNER );
   stroke( 0 );
   fill( 0, 255, 0 );
    rect( xOffset + 280, yOffset - 150, 30, 20 );
    hitButtonX1 = int( xOffset + 280 );
    hitButtonY1 = int( yOffset - 150 );
    hitButtonX2 = int( hitButtonX1 + 30 );
    hitButtonY2 = int( hitButtonY1 + 20 );
    fill( 255, 0, 0 );
    rect( xOffset + 280, yOffset - 120, 30, 20 );
    noHitButtonX1 = int( xOffset + 280 );
    noHitButtonY1 = int( yOffset - 120 );
    noHitButtonX2 = int( hitButtonX1 + 30 );
    noHitButtonY2 = int( hitButtonY1 + 20 );
    textSize( 10 );
    fill( 0 );
    if ( alpha( hitColorScatter ) == 255 )
      text( "ON", xOffset + 287, yOffset - 135 );
    else 
      text( "OFF", xOffset + 285, yOffset - 135 );
    fill( 0 );
    if ( alpha( noHitColorScatter ) == 255 )
      text( "ON", xOffset + 287, yOffset - 105 );
    else 
      text( "OFF", xOffset + 285, yOffset - 105 );
  } // end drawShowHideUI()



  
  void plotDistribution( float tempXOffset, float tempYOffset, float tempYLength, float tempMetricStepGraph, float tempMetricStepDefault, float tempMaxMetric, ArrayList tempSpokes ) {
    int numBins = ceil( tempMaxMetric / tempMetricStepDefault );
    int [] hitDistrib = new int[ numBins ];
    int [] no_hitDistrib = new int[ numBins ];
    float scaleFactor = 2; // width (in pixels) of one count for the Metric barchart
    float no_hitXOffset = 0;
  
    for( int i = 0; i < tempSpokes.size(); i++ ) { // go through the spokes and populate the hitDistrib and no-hitDistrib distribution arrays
      
      Spoke s = ( Spoke ) tempSpokes.get( i );
        int targetBin = 0;
      if ( s.hit == true ) {
        targetBin = int( ceil( s.crvScore / tempMetricStepDefault ) ) - 1;
        targetBin = constrain( targetBin, 0, numBins ); // takes care of Metric scores of 0, which will yield targetBin of value -1 and creates an error when its plugged into arrayIndex
        hitDistrib[ targetBin ] += 1;
      } else if( s.hit == false ) {
        no_hitDistrib[ targetBin ] += 1;
      } else {
        text( "ERROR! FUNCSHIT[ ] got values other than 'HIT' and 'NO-HIT'! Check Data ", 0, 150 );
      }
    } // end for( i )  
    
    // draw the bar chart for HIT
    stroke( 0, 0, 0, alpha( hitColorScatter ) );
    fill( hitColorScatter );
    rectMode( CORNERS );
    for( int j = 0; j < numBins; j++ ) {
      rect( tempXOffset, tempYOffset - metricStepGraph - ( j * metricStepGraph ), tempXOffset + hitDistrib[ j ] * scaleFactor, tempYOffset - ( j * metricStepGraph ) );
    
      // update no_hitXOffset
      if( tempXOffset + hitDistrib[ j ] * scaleFactor > no_hitXOffset ) {       // always take the biggest value for setting xOffset for NO-HIT barchart
        no_hitXOffset = tempXOffset + hitDistrib[ j ] * scaleFactor;
      }
    } // end for( j )
  
    // draw the bar chart for NO-HIT
    no_hitXOffset += 5;
    stroke( 0, 0, 0, alpha( noHitColorScatter ) );
    fill( noHitColorScatter );
    for( int j = 0; j < numBins; j++ ) {
      rect( no_hitXOffset, tempYOffset - metricStepGraph - ( j * metricStepGraph ), no_hitXOffset + ( no_hitDistrib[ j ] * scaleFactor ), tempYOffset - ( j * metricStepGraph ) );
    } // end for( j )
  } // end plotDistribution()




  void drawAxes(float xOffset, float yOffset, float xLength, float yLength, float oneMin, float twoTerm) { 
    stroke( 0 );
    textSize( 8 );
    line( xOffset + 5, yOffset + 0, xOffset + 5 + xLength, yOffset + 0 ); // draw horizontal axis
    for( int i = 0; i * oneMinGraph <= xLength; i++ ) {
      line( xOffset + 5 + i * oneMinGraph, yOffset + 0, xOffset + 5 + i * oneMinGraph, yOffset + 5 ); // draw markings for the horizontal axis
      text( i, xOffset + 5 - 3 + i * oneMinGraph, yOffset + 15 );
    }
    text ("Time (mins)", xOffset + xLength - textWidth( "Time (mins)" ), yOffset + 25); // draw label for the horizontal axis
    
    line( xOffset + 5, yOffset + 0, xOffset + 5, yOffset - yLength ); // draw vertical axis
    for( int i = 0; i * metricStepGraph <= yLength; i++ ) {
      if( i % 4 == 0 ) { // only show markings per 4 metricSteps
        line( xOffset + 5, yOffset - i * metricStepGraph, xOffset +5 - 5, yOffset - i * metricStepGraph ); // draw markings for the vertical axis
        text (( i * int( metricStepDefault ) ), xOffset - 15, yOffset + 3 - i * metricStepGraph );
      } // end if
    } // end for i
    pushMatrix();
    translate (xOffset - 20, yOffset - yLength + textWidth (metricLabel) );
    rotate( radians( 270 ) );
    text ( metricLabel, 0, 0  ); // draw label for the horizontal axis
    popMatrix();
  } // end drawAxes()
  



  void inspectScatter() {
    println( "[ INSPECTING SCATTER ]" );
    println( "     xOffset=" + xOffset + " yOffset=" + yOffset );
    println( "     xLength=" + xLength + " yLength=" + yLength );
    println( "     oneMinGraph="  + oneMinGraph + " oneMinDefault=" + oneMinDefault );
    println( "     metricStepGraph=" + metricStepGraph + " metricStepDefault=" + metricStepDefault );
    println( "     displayStringScatter=" + displayStringScatter + " gotDisplayStringScatter=" + gotDisplayStringScatter );
    println( "     maxPostTime=" + maxPostTime );
    println( "     maxMetric=" + maxMetric );
    println( "     printing spiralScatter instance object's spkes' crvScore, for each spoke: " );
    println( "     spiralScatter.size()=" + spiralScatter.spokes.size() );
    for( int i = 0; i < spiralScatter.spokes.size(); i++ ) {
      Spoke s = ( Spoke ) spiralScatter.spokes.get( i );
      println( "          " + i + ". " + s.crvScore );
    } // end for i
    println( "     finished printing crvScore for each Spoke instance object of spiralScatter" );
    
    println( "     metricLabel=" + metricLabel );
    println( "     hitButton: X1-Y1 X2-Y2=" + hitButtonX1 + " " + hitButtonY1 + " " + hitButtonX2 + " " + hitButtonY2 );
    println( "     noHitButton: X1-Y1 X2-Y2=" + " " + noHitButtonX1 + " " + noHitButtonY1 + " " + noHitButtonX2 + " " + noHitButtonY2 );
    println( "     hasData=" + hasData );
    println( "[ DONE INSPECTING SCATTER ]" );
  } // end inspectScatter()
  


  
  void plotPoints( float xOffset, float yOffset, float xLength, float yLength ) {
    float pointX = 0;
    float pointY = 0;
    for( int i = 0; i < spiralScatter.spokes.size(); i++ ) {
      // set the color of the point
      Spoke s = ( Spoke ) spiralScatter.spokes.get( i );
      if( s.hit == true ) {
        stroke( 0, 0, 0, alpha( hitColorScatter ) );
        fill( hitColorScatter ); // set to green if HIT
      } else {
        stroke( 0, 0, 0, alpha( noHitColorScatter ) );
        fill( noHitColorScatter ); // set to red if NO-HIT
      }
      pointX =xOffset + 5 + map( s.genesis, 0, maxPostTime, 0, xLength );
      pointY = yOffset - map( s.crvScore, 0, maxMetric, 0, yLength );
      ellipse( pointX + 5, pointY, 6, 6 );
      if( dist( float( mouseX ), float( mouseY ), pointX + 5, pointY ) <= 3 ) { // mouseover
      displayStringScatter = i+1;    
      if( gotDisplayStringScatter == 0 )
        gotDisplayStringScatter = displayStringScatter;
      } else {
        displayStringScatter = 0;
      }
    } // end for( i < spiralScatter.spokes.size() )
    
    if( gotDisplayStringScatter != 0 ) {         // calling displayString function
      displayFuncString( gotDisplayStringScatter, mouseX, mouseY );
      gotDisplayStringScatter = 0;
    }    
  } // end plotPoints()
  



  void displayFuncString (int tempDisplayString, float tempDisplayOuterX, float tempDisplayOuterY) { // to display pop-up box containing string of the function, on mouseover
    rectMode( CORNER );
    Spoke s  = ( Spoke ) spiralScatter.spokes.get( tempDisplayString - 1 );
    textSize( 16 );
    float standardLength = textWidth(s.funcString);
    textSize( 11 );
    float minLength = textWidth("Genesis:  xx:xx") + textWidth( "     Freq : xx") + textWidth( "     CRV Score: xx.xx" );
  
    if(tempDisplayString != 0) {
      //Spoke s = ( Spoke ) spiralScatter.spokes.get( tempDisplayString - 1 );
      if (tempDisplayOuterX + standardLength+10 <= width) { // if length  of popup, given mouse location exceeds width of the window
        if (standardLength <= minLength) { // pop up cant be narrower than the minLength
          fill(0,0,0,180);
          rect(tempDisplayOuterX,tempDisplayOuterY-45, minLength+20,40);
        } else {
          fill(0,0,0,180);
          rect(tempDisplayOuterX,tempDisplayOuterY-45, standardLength+20,40);
        }
        stroke(255,255,0);
        fill(255,255,0);
        textSize(16);
        text( s.funcString,tempDisplayOuterX+5,tempDisplayOuterY-25);
        textSize(11);
        text ("Genesis:  "+ s.cGenesis.getPost_Time_Mins() + "     Freq:" + s.freq + "     CRV Score : " + myRound( s.crvScore, 2 ),tempDisplayOuterX+5,tempDisplayOuterY-10);
      
      } else if (width - textWidth(s.funcString)*2+10 >= 350 ) { // if length of popup, given mouse location exceeds width of the window but is still within the viewing area
        float textX = 0; // to hold pop up starting loc
        if (standardLength <= minLength) { // pop up cant be narrower than the minLength
          fill(0,0,0,180);
          rect(tempDisplayOuterX - minLength-10   ,tempDisplayOuterY-45, minLength+20,40);
          textX = ( tempDisplayOuterX - textWidth(s.funcString) -20 ) ;
        } else {
          fill(0,0,0,180);
          rect(tempDisplayOuterX - standardLength-30   ,tempDisplayOuterY-45, standardLength+20,40);
          textX = ( tempDisplayOuterX - textWidth( s.funcString ) -30 ) ;
      }
        stroke(255,255,0);
        fill(255,255,0);
        textSize(16);
        text(s.funcString, textX+5 ,tempDisplayOuterY-25);
        textSize(11);
        text ("Genesis:  "+ s.cGenesis.getPost_Time_Mins() + "     Freq:" + s.freq + "     CRV Score : " + myRound( s.crvScore, 2 ),tempDisplayOuterX+5,tempDisplayOuterY-10);
      } else { // if length of popup cant fit within the viewing area (for extremely long function)
         fill(0,0,0,180);
        rect(350 ,tempDisplayOuterY-45, textWidth( s.funcString )*2+10,40);
        stroke(255,255,0);
        fill(255,255,0);
        textSize(11);
        text( s.funcString,350+5,tempDisplayOuterY-25);
        textSize(11);
        text ("Genesis:  "+ s.cGenesis.getPost_Time_Mins() + "     Freq:" + s.freq + "     CRV Score : " + myRound( s.crvScore, 2 ),tempDisplayOuterX+5,tempDisplayOuterY-10);
      }
    } else {
    }
  } // end displayFuncString()




  // --------------------------------------------------- // 
  // Computation and Algorithm for Scatterplot ends here //
  // --------------------------------------------------- //




} // end class Scatter()

// ========================================
// GUI Component Class
// Models the draggable button of a classic scrollbar

class ScrollPosButton  extends AButton {

  // Fields

  View owner;
  String orientation; // values are either: "HORIZONTAL" or "VERTICAL"
  float spbWidth, spbHeight;
  boolean onDrag;




  // Constructor

  ScrollPosButton( View o, float x1Temp, float y1Temp, float x2Temp, float y2Temp, int linkIndexTemp, String typeTemp ) {
    // value of typeTemp is either "HORIZONTAL" or "VERTICAL"
    super( x1Temp, y1Temp, x2Temp, y2Temp, linkIndexTemp );
    owner = o;
    spbWidth = x2 - x1;
    spbHeight = y2 - y1;
    onDrag = false;
    orientation = typeTemp;
  } // end constructor




  // Methods

  void reposition( float[] scrollPosTemp ) {
    if( orientation.equals( "VERTICAL" ) ) {
      y1 = map( scrollPosTemp[ 1 ], 0, owner.contentHeight, owner.y1+20, owner.y2a - 20 );
     y2 = map( scrollPosTemp[ 3 ], 0, owner.contentHeight, owner.y1+20, owner.y2a - 20 );
    } else { 
    // making implicit assumption here that type must be "HORIZONTAL" if its not "VERTICAL"
      x1 = map( scrollPosTemp[ 0 ], 0, owner.contentWidth, owner.x1a + 20, owner.x2a - 20 );
      x2 = map( scrollPosTemp[ 2 ], 0, owner.contentWidth, owner.x1a + 20, owner.x2a - 20 );
    }
  } // end reposition()
  
  

  
  void release() {
    super.release();
    onDrag = false;
  } // end release()




} // end class ScrollPosButton

// ========================================
// Data Modelling Class
// used by both the Wave and the Spiral viz. Holds very important 
// information on the activity from the class (section) of interest.

class Section {

  // Fields

  Table artefacts;
  
  int maxPostTime, minPostTime;
  String exerciseStart, exerciseTitle;
  Post_Time cExerciseStart, cMaxPostTime, cMinPostTime, cDuration;
  ArrayList funcs; // of type Function
  int lastCountForFuncs;
  String pdfName;
  boolean hasData;  



  
  // Constructor

  Section() {
    artefacts = null;         // NOT going to use artefacts in Database "Streaming"
    funcs = new ArrayList();
    lastCountForFuncs = 0;
    pdfName =  "";
    
    maxPostTime = 0;
    minPostTime = 0; // call updateMinMaxPostTime() later to fill these
    exerciseStart = "";
    exerciseTitle = "";
    hasData = false;
    
    // This version of the constructor only creates a new instance, but will NOT populate it with data.
    // Population of data will come in via another method populateWStream()
    
    // stats will be built after the section's spiral is built, and after OpUsage has been built
  } // end Overloaded constructor for Database "Streaming"
  



  // Methods 

  void setStartTime( String st ) {
    exerciseStart = st;
  } // end setStartTime()




  void setTitle( String t ) {
    exerciseTitle = t;
  } // end setTitle()




  int getColumnMax(int col) {
    int m = MIN_INT;
    for (int row = 0; row < artefacts.getRowCount(); row++) {
      if (artefacts.getInt(row,col) > m) {
        m = artefacts.getInt(row,col);
      }
    }
    return m;
  } // end getColumnMax fudnction




  int getColumnMin(int col) {
    int m = MAX_INT;
    for (int row = 0; row < artefacts.getRowCount(); row++) {
      if (artefacts.getInt(row,col) < m) {
        m = artefacts.getInt(row,col);
      }
    }
    return m;
  }  // end getColumnMin()

  


  void updateHasData(){
    if( getFuncsCount() > 0 )
      hasData = true;
    else
      hasData = false;
  } // end updateHasData()



  
  void updateMinMaxPostTime() {
    if( funcs.size() > 0 ) {
      // I'm setting minPostTime and maxPostTime to be simply the postTime
      // of the first and last element of the funcs arraylist.
      // This is BAD practice, should implement a sorting here.
      // Will come back to it at a later date.
      Function f = ( Function ) funcs.get( 0 );
      minPostTime = f.postTime;
      f = ( Function ) funcs.get( funcs.size() - 1 );
      maxPostTime = f.postTime;
    }
  }  // end updateMinMaxPostTime()




  int getFuncsCount() {
    return funcs.size();
  } // end getFuncsCount()




  Table fetchDatastream( String urlAddress ) {  // consider removing, not called by any one
  // connects to the database and get new datastream ( if any )
    String[] rows;
    rows = loadStrings( urlAddress );
    Table t = new Table ( rows );
    return t;
  }  // end fetchDatastream()




  void populateFuncs( Table t ) {
  // Only used with live database "streaming"
    print( "populating funcs with Datastream ... " );
    for( int i = 1; i < t.getRowCount(); i++ )
      funcs.add( new Function ( t, i, getFuncsCount() ) );
    //lastCountForFuncs = funcs.size();
    updateHasData();
    updateMinMaxPostTime();
    println( "funcs count is now: " + funcs.size() + " maxPostTime is now: " + maxPostTime + " [ DONE ]" );

    println( "\t \t PRINTING FUNCTIONS: " );
    for( int i = 0; i < funcs.size(); i++ ) {
      Function f = (Function) funcs.get( i );
      println( "\t \t " + f.serialNum + " " + f.funcString );
    } 
  } // end populateFuncs()




  String toString() {
    String ret = ( "=========================================" + "\n" );
    ret += ( "Section Object Instance Details: " + "\n" );
    ret += ( "exerciseTitle:" + exerciseTitle + "\n" );
    ret += ( "exerciseStart:" + exerciseStart + "\n" );
    ret += ( "maxPostTime:" + maxPostTime + "           minPostTime:" + minPostTime + "\n" );
    ret += ( "pdfName:" + pdfName + "\n" );
    ret += ( "hasData:" + hasData + "\n" );
    ret += ( "size of funcs:" + funcs.size() + "\n");
    ret += ( "listing all Function objects inside funcs:" + "\n" );
    ret += ( "-------------------------------------------" + "\n" );
    for( int i = 0; i < funcs.size(); i++ ) {
      Function f = ( Function ) funcs.get( i );
      ret += ( f + "\n" );
    }
    ret += ( "-------------------------------------------" + "\n" );
    
    ret += ( "artefacts is:" );
    if( artefacts == null )
      ret += ( "still NULL" + "\n" );
    else
      ret += ( "NOT null" + "\n" );
    
    ret += ( "=============x===============================" + "\n" );
    return ret;
  } // end toString()




} // end class Section

// ========================================
// GUI Component Class
// Models a regular push button

class SpButton  extends AButton {

  // Fields

  String label;
  float xlabel, ylabel;
  color labelCol, baseCol, overCol, pressedCol;




  // Constructor

  SpButton( float x1p, float y1p, float x2p, float y2p, int linkIndexp, String labelp, color labelcolp, color basep, color overp, color pressedp ) {
    super( x1p, y1p, x2p, y2p, linkIndexp );
    x1 = x1p;
    y1 = y1p;
    x2 = x2p;
    y2 = y2p;
    linkIndex = linkIndexp;
    label = labelp;
    xlabel = x1 + ( ( (x2-x1) - textWidth( label ) ) / 2 );
    ylabel = y2 - ( ( (y2-y1) - 10 ) / 2 );
    labelCol = labelcolp;
    baseCol = basep;
    overCol = overp;
    pressedCol = pressedp;
  } // end constructor




  // Methods

  //@Override
  void update() {
   super.update(); 
  }




  //@Override
  void display() {
    //super.display();
    rectMode( CORNERS );
    if( over == true ) {
      if( pressed == true ) {
        stroke( labelCol );
        fill( pressedCol );              // Button pressed
        rect( x1, y1, x2, y2 );
      } 
      else {
        stroke( labelCol );
        fill( overCol );                    // Mouseover
        rect( x1, y1, x2, y2 );
      }
    } 
    else {
      stroke( labelCol );
      fill( baseCol );
      rect( x1, y1, x2, y2 ); // Base
    }
    textSize( 12 );
    fill( labelCol );
    text( label, xlabel, ylabel );     // Label
  } // end display()




} // end class spButton

// ========================================
// Spiral Activity Class ( a child class of LVActivity)
// The main class for the Live Spiral visualizer
// see also: class SpiralUI

class SpiralActivity extends LVActivity {
    
  // Fields
  
  SpiralUI spaUI;
  Spiral spiral;
  OpsStats opsStats;
  String[] dummyRows = { 
      "Contributions:\t\t\t\t\t\t\t\t",
      "1\ttrue\tEQUATION\t0.02\t[contributor]\tY1\t0.1sin(x)\t\t",
      "2\ttrue\tEQUATION\t0.049\t[contributor]\tY2\t0.2sin(x)\t\t",
      "3\ttrue\tEQUATION\t0.058\t[contributor]\tY3\t0.3sin(x)\t\t",
      "4\ttrue\tEQUATION\t0.067\t[contributor]\tY4\t0.4sin(x)\t\t",
      "5\ttrue\tEQUATION\t0076\t[contributor]\tY5\t0.5sin(x)\t\t",
      ""
    };
  Table dummyDatabaseStream;



  // Constructor  
  
  SpiralActivity( LiveSpiral o ) {
    super( o );
    //alert( "LVActivity built" );
    bgColor = color( 255, 255, 255 );
    spaUI = new SpiralUI( this );
    aUI = spaUI;
       
    // only create a "blank shell" for the spiral object instance
    spiral = new Spiral();
  } // end constructor
  



  // Methods
  
  void display() {
    super.display();
    // Put details of drawing stuff inside render() below
  } // end display()



  
  void render() {
    super.render();
    if( hasNewValidDatastream )
      processDatastream( databaseStream );
    prepForNextDatastream();
    View renderer = aUI.view;
    // Drawing routines
    spiral.display();
    // CRV score metric needs to be tweaked, Dont show them yet
    /*
    fill( popUpBkgrd );
    stroke( popUpTxt );
    rectMode( CORNERS );
    rect( 30, 30, 230, 130 );
    fill( popUpTxt );
    textSize( 15 );
    text( "Total Creativity Score:", 50, 55 );
    textSize( 40 );
    spiral.crvTotal, 40, 100 );
    */
  } // end render()




  void startSpiral( String[] aDetails ) {
    // aDetails [0] [1] [2] is url, startTime and title
    super.startLV( aDetails );
    
    // create a new spiral and put in activity details into it
    print( "Creating new Spiral using provided details: " + aDetails[ 1 ] + " " + aDetails[ 2 ] + " ... " );
    spiral.sproutSpiral( aDetails[ 1 ], aDetails[ 2 ] );
    //dummyRows = cleanRows( dummyRows );
    //dummyDatabaseStream = new Table ( dummyRows );
    hasNewValidDatastream = false;
    //processDatastream( dummyDatabaseStream );
    println( "[DONE]" );

  } // end startSpiral()



  
  void processDatastream( Table databaseStream ){
  // this method processes the datastream received from the database. It's unique for Spiral and Wave
  //
    spiral.growSpokes( databaseStream );
    spiral.lastCountForFuncs = spiral.funcs.size();

	        
    // rebuild opsStats after each wave of new datastream
    // NOTE: may need a persistent cumulative Table of Data
    opsStats = new OpsStats( spiral );
    //println( opsStats.schOpsUsage + "SCHOOL" );
    //println( opsStats.clsOpsUsage.get( 0 ) + spiral.pdfName );

    // build stats for the spiral
    spiral.stats = new Stats( spiral, ( OpsUsage )  opsStats.clsOpsUsage.get( 0 ), opsStats.schOpsUsage );
    //println( spiral.stats.plusWt );
    //println( spiral.stats.minusWt );
    //println( spiral.stats.timesWt );
    //println( spiral.stats.dividesWt );
    //println( spiral.stats.squareWt );
    //println( spiral.stats.negativeWt );
        
    // recalculate CRV scores
    for( int i = 0; i < spiral.spokes.size(); i++ ) {
      Spoke s = ( Spoke ) spiral.spokes.get( i );
      s.computeCRVScore( spiral.stats.plusWt, spiral.stats.minusWt, spiral.stats.timesWt, spiral.stats.dividesWt, spiral.stats.squareWt, spiral.stats.negativeWt );
    }
    spiral.computeCRVTotal();
    println( "Showing contents of spiral: " );
    println( spiral );
  } // end processDatastream()




  String toString() {
   return( "This is SpiralActivity, a descendant of class Activity ( extends LVActivity, which extends Activity ) which is set to hold a spiral viz" ); 
  }

  

  
} // end class SpiralActivity

// ========================================
// Data Modelling Class
// Models the Spiral
                    
class Spiral extends Section {

  // Fields

  ArrayList<Spoke> spokes;
  float crvTotal;
  Stats stats;
  float x, y, diam, rad;
  PFont f;
  String title;
  int titleSize, spokeFontSize;
  color spokeFreqBar;
  float pWidth, gWidth, px1, py1, px2, py2;  
  boolean hasData;
  float userRotate;     // to hold target degree rotated, as input fromeuser
  float deltaRotate;    // to hold incremental degree rotated for this frame. Value changes every frame
  PFont spiralFont = loadFont( "SansSerif.plain-12.vlw" );
  ArrayList<Boolean> selValds; // to hold selected validity values
  int countValids, countInValids;




  // Constructor

  Spiral( ArrayList tempFuncs, int tempMaxPostTime, int tempMinPostTime, String tempExerciseStart, String tempExerciseTitle, Table _artefacts, boolean tempHasData ) { // Spiral object is constructed by passing an ArrayList of Function objects and a Table object
    x = 150 + ( ( width - 350 ) / 2 );   // hard-coded to width of the left panel (350)
    y= height / 2;
    diam = 200;
    rad = diam / 2;
    spokes = new ArrayList<Spoke>();
    maxPostTime = tempMaxPostTime;
    cExerciseStart = new Post_Time( 0, tempExerciseStart );
    cMaxPostTime = new Post_Time( tempMaxPostTime, tempExerciseStart );
    cMinPostTime = new Post_Time( tempMinPostTime, tempExerciseStart );
    cDuration = new Post_Time( tempMaxPostTime, "00:00:00" );
    
    title = tempExerciseTitle; 
    userRotate = 0;
    deltaRotate = userRotate;
    //f = createFont("SansSerif.plain-12.vlw", 12 );                       // spiralFont is a global variable for easy modification
    titleSize = 20;
    spokeFontSize = 11;
    spokeFreqBar = color( 40, 40, 40 );
    
    buildSpokes( tempFuncs, tempMaxPostTime, _artefacts );
    hasData = tempHasData; 
  } // end constructor Spiral



  
  // Overloaded constructor for use with live database "streaming"
  Spiral() {
    super();
    x = 350 + ( ( width - 350 ) / 2 );   // hard-coded to width of the left panel (350)
    y= height / 2;
    diam = 200;
    rad = diam / 2;
    spokes = new ArrayList();  // just creates an empty spokes ArrayList, to be populated later
    maxPostTime = 0;
    cExerciseStart = null;
    cMaxPostTime = null;
    cMinPostTime = null;
    cDuration = new Post_Time( maxPostTime, "00:00:00" );
    
    title = ""; 
    userRotate = 0;
    deltaRotate = userRotate;
    //f = createFont("SansSerif.plain-12.vlw", 12 );                       // spiralFont is a global variable for easy modification
    titleSize = 20;
    spokeFontSize = 11;
    spokeFreqBar = color( 40, 40, 40 );
    
    hasData = false; 
    selValds = new ArrayList<Boolean>();
    selValds.add( true ); // sets default to show only valid ( true ) equations
    countValids = updateCountValids();
    countInValids = updateCountInValids();
  } // end overloaded constructor
  
  
  
  void sproutSpiral( String tempExerciseStart, String tempExerciseTitle ) {
    setStartTime( tempExerciseStart );
    setTitle( tempExerciseTitle );  
    pdfName = tempExerciseTitle + ".pdf";
    cExerciseStart = new Post_Time( 0, tempExerciseStart );  // the timings should be updated upon addSpokes()
    cMaxPostTime = new Post_Time( 0, tempExerciseStart );
    cMinPostTime = new Post_Time( 0, tempExerciseStart );
    title = tempExerciseTitle; 
  } // end sproutSpiral()



  // Methods

  void growSpokes( Table t ) {
    super.populateFuncs( t );
    print( "Applying Datastream To Spiral ... " );
    addSpokes( funcs, lastCountForFuncs, minPostTime, maxPostTime, t );
    updateHasData();
    String tempExerciseStart = t.getString( 0, 0 );
    updateTimings( tempExerciseStart, minPostTime, maxPostTime );
    println( "Spiral spoke count is now " + spokes.size() + " [ DONE ]" );
  }  // end growSpokes()




  void updateTimings( String tempExerciseStart, int tempMinPostTime, int tempMaxPostTime ) {
    maxPostTime = tempMaxPostTime;
    cMaxPostTime = new Post_Time( maxPostTime, tempExerciseStart );
    cMinPostTime = new Post_Time( tempMinPostTime, tempExerciseStart );
    cDuration = new Post_Time( maxPostTime, "00:00:00" );
  }  // end updateTimings()



  
  void display() {
    textFont( spiralFont );
    clearPanel();
    drawYolk();    
    drawSpokes();
    drawTitle();
    drawMouseOverFunc();
    drawMouseOverFreq();
    displayCountBox( 20, 20 );
    
  } // end display()



  
  void buildSpokes( ArrayList tempFuncs, int ctempMaxPostTime, Table _artefacts ) {
    // this will build an ArrayList of Spoke objects, using the input of an ArrayList of Function objects
    // go through the ArrayList, check for duplication and set genesis and frequency appropriately, 
    for( int i = 0; i < tempFuncs.size(); i++ ) {
      Function tf = ( Function ) tempFuncs.get( i );
      int dup = 0; 
      int sumDup = 0;
      if( spokes.size() == 0 ) {                                          // first entry of the spokes list
        spokes.add( new Spoke( _artefacts, tf.serialNum ) );
        Spoke newS = ( Spoke ) spokes.get( spokes.size() - 1 );
        newS.genesis = tf.postTime;
        newS.cGenesis = new Post_Time( newS.genesis, "00:00:00" );
        newS.mappedLength = map( float(newS.genesis), 0.0, float(ctempMaxPostTime), 0.0, 200.0 );
	// newS.freq++;                                              // is this the OFF BY ONE BUG?
      } else {
        for( int j = 0; j < spokes.size(); j++ ) {                   // subsequent entry to the spokes list, need to check for duplication
        Spoke s = ( Spoke ) spokes.get( j );
          if( tf.funcString.equals( s.funcString ) ) {
            s.freq ++;
            dup ++;
            // check if need to update s' genesis and cGenesis
            if( s.genesis > tf.postTime ) {
              s.genesis = tf.postTime;
              s.cGenesis = new Post_Time( s.genesis, "00:00:00" );
            } // end of checking
          }
          sumDup += dup;
        } // end for j
        if( sumDup == 0 ) {      // no duplicates found in the current ArrayList of j Spoke objects
          spokes.add( new Spoke( _artefacts, tf.serialNum ) );
          Spoke newS = ( Spoke ) spokes.get( spokes.size() - 1 );
          newS.genesis = tf.postTime;
          newS.cGenesis = new Post_Time( newS.genesis, "00:00:00" );
          newS.mappedLength = map( float(newS.postTime), 0.0, float(ctempMaxPostTime), 0.0, 200.0 );
        } // end if sumDup == 0
      } // end else
    } // end for i
  } // end buildSpokes()



 
  void addSpokes( ArrayList tempFuncs, int tempLastCountForFuncs, int tempMinPostTime, int tempMaxPostTime, Table tempTable ) {
    // this will add Spoke objects into the Arraylist spokes, using the input of an ArrayList of Function objects
    // go through tempFuncs, check for duplication and set genesis and frequency appropriately, 
    for( int i = tempLastCountForFuncs; i < tempFuncs.size(); i++ ) {
      Function tf = ( Function ) tempFuncs.get( i );
      int dup = 0; 
      int sumDup = 0;
      
      if( spokes.size() == 0 ) {     // first entry of the spokes list
        spokes.add( new Spoke( tempTable, i + 1, tf.serialNum ) );
        Spoke newS = ( Spoke ) spokes.get( spokes.size() - 1 );
        newS.genesis = tf.postTime;
        newS.cGenesis = new Post_Time( newS.genesis, "00:00:00" );
        // newS.freq++;                 // is this the OFF BY ONE BUG?
      
    } else {
      for( int j = 0; j < spokes.size(); j++ ) { // subsequent entry to the spokes list, need to check for duplication
          Spoke s = ( Spoke ) spokes.get( j );
          if( tf.funcString.equals( s.funcString ) ) {
            s.freq ++;
            dup ++;
            // check if need to update s' genesis and cGenesis
            if( tf.postTime < s.genesis ) {
              s.genesis = tf.postTime;
              s.cGenesis = new Post_Time( s.genesis, "00:00:00" );
              println( "\t\t\t Check Spoke data accuracy: " + s );
            } // end of checking
          }
          sumDup += dup;
        } // end for j
        if( sumDup == 0 ) {      // no duplicates found in the current ArrayList of j Spoke objects
          spokes.add( new Spoke( tempTable, 0 - tempLastCountForFuncs + i + 1, tf.serialNum ) );
          Spoke newS = ( Spoke ) spokes.get( spokes.size() - 1 );
          newS.genesis = tf.postTime;
          newS.cGenesis = new Post_Time( newS.genesis, "00:00:00" );
          println( "check newS Sopke accuracy: " + newS );
        } // end if sumDup == 0
      } // end else
    } // end for i
    // println( "Done adding spokes. Count of spokes is now " + spokes.size() );
    updateSpokesMappedLength( tempMaxPostTime );
  } // end addSpokes()




  void updateSpokesMappedLength( int tempMaxPostTime ) {
  // Need to do an update on the spokes' mappedLength after adding new spokes, which has a new maxPostTime
    for( int i = 0; i < spokes.size(); i ++ ) {
      Spoke newS = ( Spoke ) spokes.get( i );
      newS.mappedLength = map( float(newS.genesis), 0.0, float(tempMaxPostTime), 0.0, 200.0 );
    }  
  } // end updateSpokesMappedLength()
  



  void computeCRVTotal() {
    crvTotal = 0;
    for( int i = 0; i < spokes.size(); i++ ) {  
      Spoke s = ( Spoke ) spokes.get( i );  
      crvTotal += s.crvScore;
    } // end for i
    crvTotal = myRound( crvTotal, 2 );
  } // end computeCRVTotal()
  



  boolean checkMouseFunc( Spoke sMouse, int xCheck, int yCheck ) {
    if( dist( xCheck, yCheck, sMouse.outerX, sMouse.outerY ) < 5 ) {
      sMouse.xMOFunc = xCheck;
      sMouse.yMOFunc = yCheck;
      return true;
    } else 
      return false;
  } // end checkMouseFunc()
  



  boolean checkMouseFreq( Spoke sMouse, int xCheck, int yCheck ) {
    if( dist( xCheck, yCheck, sMouse.innerX, sMouse.innerY ) < 5 ) {
      sMouse.xMOFreq = xCheck;
      sMouse.yMOFreq = yCheck;
      return true;
    } else 
      return false;
  } // end checkMouseFreq()




  void clearPanel() {
    fill( 255 );
    stroke( 255 );
    rectMode( CORNERS );
    rect( 152, 0, width, height );
  } // end clearPanel()




  void drawYolk() {
    if( !hasData ) {           // Message display to notify user that no data is available for this class
      stroke( popUpTxt );
      fill( popUpBkgrd );
      rectMode( CORNER );
      textSize( 30 );
      rect( x - ( (  textWidth( "No Data For This Class" ) ) / 2 ) - 10, y - 30, textWidth( "No Data For This Class" ) + 18, 40 );
      rectMode( CORNERS );
      fill( popUpTxt );   
      text( "No Data For This Class", x - ( (  textWidth( "No Data For This Class" ) ) / 2 ), y ); 
    } else { // if hasData is true
      fill( 128 );
      strokeWeight( 1 );
      stroke( 40 );
      ellipse( x, y, diam, diam );                                    // draw the yolk
    } // end if hasData is true
  } // end drawYolk()




  void drawSpokes() {
    //textFont( f );
    textSize( spokeFontSize );
    
    if( round( deltaRotate ) != round( userRotate ) ) {
    deltaRotate = deltaRotate + ( ( userRotate - deltaRotate ) / 2 );
    /*
    if( deltaRotate > 360 )
      deltaRotate = deltaRotate - 360;
    if( deltaRotate < 0 )
      deltaRotate = 360 - deltaRotate;
    */
    }
    
    float angleinc = 360 / float( getCountSpokesOnShow( selValds ) );
  
    int finc = 0;
    for( int f = 0; f < spokes.size(); f++ ) {
      Spoke s = (Spoke) spokes.get( f );
      if( selValds.contains( s.isValid ) ) {
        s.baseX = ( cos( radians( ( angleinc * finc ) + deltaRotate ) ) * rad ) + x;                                                 // positioning the spoke
        s.baseY = ( sin( radians( ( angleinc * finc ) + deltaRotate ) ) * rad ) + y;
        s.outerX = ( cos( radians( ( angleinc * finc ) + deltaRotate ) ) * ( rad + s.mappedLength ) ) + x;
        s.outerY = ( sin( radians( ( angleinc * finc ) + deltaRotate ) ) * ( rad  + s.mappedLength ) ) + y;
    
        s.shortX = ( cos( radians( ( angleinc * finc ) + deltaRotate ) ) * ( rad - 5 ) ) + x;                                               // positioning the freq count of the spoke
        s.shortY = ( sin( radians( ( angleinc * finc ) + deltaRotate ) ) * ( rad - 5 ) ) + y;
        s.innerX = ( cos( radians( ( angleinc * finc ) + deltaRotate ) ) * ( ( rad - 5 ) - s.freq ) ) + x;
        s.innerY = ( sin( radians( ( angleinc * finc ) + deltaRotate ) ) * ( ( rad - 5 ) - s.freq ) ) + y;
    
        stroke ( s.c );
        strokeWeight( 1 );
        line( s.baseX, s.baseY, s.outerX, s.outerY );        // draw spoke
    
        stroke( spokeFreqBar );
        strokeWeight( 2 );
        line( s.innerX, s.innerY, s.shortX, s.shortY );            // draw freq bar
    
        fill( 0 );
        textSize( spokeFontSize );                                  // draw text function string
        if( ( ( ( angleinc * finc ) + deltaRotate ) % 360 > 90 ) && ( ( ( angleinc * finc ) + deltaRotate ) % 360 < 270 ) ) { // determining text orientation for the left half of the spiral
          pushMatrix();
          translate( s.outerX, s.outerY );
          rotate( radians( ( angleinc * finc ) + deltaRotate - 180 ) );
          textSize( spokeFontSize );      
          markUncleaned( s, ( angleinc * finc ) + deltaRotate );    // this will highlight all spokes that are still "uncleaned" after all the processing so far (e.g. #Name?, 0 crvScore )
          fill( 0, 0, 0, 255 );
          text( s.funcString, 0 - textWidth( s.funcString ), 0 );
          popMatrix();
      
        } else {                                                            // determining text orientation for the right half of the spiral
      
          pushMatrix();
          translate( s.outerX, s.outerY );
          rotate( radians( ( angleinc * finc ) + deltaRotate ) );
          markUncleaned( s, ( angleinc * finc ) + deltaRotate );
          /*
          if( s.funcString.equals("#NAME?") ) {                 // markings for "#Name?" function strings
            fill( 200, 0, 0, 127 );
            rect( 0, 0, textWidth( s.funcString ), -15 );
          } 
	  */
          fill( 0, 0, 0, 255 );
          text( s.funcString, 0, 0 );
          popMatrix();
        } // end for determining text orientation
    
        // determining mouse over
        s.isMouseOverFunc = checkMouseFunc( s, mouseX, mouseY );
        if( !s.isMouseOverFunc ) {
          //s.isMouseOverFunc = checkMouseFunc( s, myJays[0].xPos, myJays[0].yPos );
          //if( !s.isMouseOverFunc ) 
            //s.isMouseOverFunc = checkMouseFunc( s, myJays[1].xPos, myJays[1].yPos );
        }
      
        s.isMouseOverFreq = checkMouseFreq( s, mouseX, mouseY );
        if( !s.isMouseOverFreq ) {
          //s.isMouseOverFreq = checkMouseFreq( s, myJays[0].xPos, myJays[0].yPos );
          //if( !s.isMouseOverFreq )
            //s.isMouseOverFreq = checkMouseFreq( s, myJays[1].xPos, myJays[1].yPos );
        }
        finc++;   
      } // end if isValid matches
    } // end for f
  } // end drawSpokes()




  void drawTitle() {
    stroke( 0 );                                                                    // draw spiral title
    strokeWeight( 1 );
    fill( 255 );
    textSize( titleSize );
    rect( 350 + ( width - 350 ) / 2 - ( ( textWidth( title ) + 10 )/ 2 ), 0, 350 + ( width - 350 ) / 2 + ( ( textWidth( title ) + 10 ) / 2 ), 30 );
    fill( 0 );
    text( title, 350 + ( width - 350 ) / 2 - textWidth( title ) / 2, 22 );
  } // end drawTitle()




  void drawMouseOverFunc() {
    for( int k = 0; k < spokes.size(); k++ ) {
      Spoke mouseS = ( Spoke ) spokes.get( k );
      if( mouseS.isMouseOverFunc ) {
        gWidth = getGnsTextWidth();
        pWidth = getPopUpWidth( mouseS.funcString );
        if( pWidth >= gWidth )
          positionPopUpFunc( mouseS, pWidth );
        else {
         pWidth = gWidth;
        positionPopUpFunc( mouseS, pWidth ); 
        }
        drawPopUpFunc( mouseS.funcString, mouseS.cGenesis.getPost_Time_Mins(), mouseS.freq, mouseS.crvScore );
      } // end if
    } // end for k
  } // end void drawMouseOverFunc()
  



  void drawMouseOverFreq() {
    for( int k = 0; k < spokes.size(); k++ ) {
      Spoke mouseS = ( Spoke ) spokes.get( k );
      if( mouseS.isMouseOverFreq ) {
        pWidth = getPopUpWidth( String(mouseS.freq) );
        positionPopUpFreq( mouseS, pWidth );
        drawPopUpFreq( String(mouseS.freq) );
      } // end if
    } // end for k
  } // end void drawMouseOverFreq()
  



  float getGnsTextWidth() {
    textSize( 10 );
    float gTextWidth = textWidth( "Genesis: XX:XX          Freq: XXX          CRV Score: XXX.XX" );
    return gTextWidth;
  } // end getGnsTextWidth()



  
  float getPopUpWidth( String popUpString ) {
    textSize( 16 );
    return( textWidth( popUpString ) + 10 );
  } // end getPopUpWidth()
  



  void positionPopUpFunc( Spoke s, float _pWidth ) {
    if( s.xMOFunc + _pWidth < width ) {                 // if PopUp doesnt protrude the right hand side of the spiral panel
      px1 = s.xMOFunc - 5;
      py1 = s.yMOFunc - 30;
      px2 = px1 + _pWidth;
      py2 = py1 + 25; 
    } else {                                                       // if PopUp protrudes out of the right hand side of the spiral panel
      px1 = width - ( _pWidth + 5 );
      py1 = s.yMOFunc - 30;
      px2 = px1 + _pWidth;
      py2 = py1 + 25;
    }
  } // end positionPopUpFunc()
  



  void positionPopUpFreq( Spoke s, float _pWidth ) {
    if( s.xMOFreq + _pWidth < width ) {                 // if PopUp doesnt protrude the right hand side of the spiral panel
      px1 = s.xMOFreq - 5;
      py1 = s.yMOFreq - 30;
      px2 = px1 + _pWidth;
      py2 = py1 + 25; 
    } else {                                                       // if PopUp protrudes out of the right hand side of the spiral panel
      px1 = width - ( _pWidth + 5 );
      py1 = s.yMOFreq - 30;
      px2 = px1 + _pWidth;
      py2 = py1 + 25;
    }
  } // end positionPopUpFreq()
  



  void drawPopUpFunc( String popUpString, String gen, int frq, float crvScore ) {
    fill( popUpBkgrd );
    stroke( popUpTxt );
    rectMode( CORNERS );
    rect( px1, py1 - 20, px2, py2 );
    fill( popUpTxt );
        textSize( 16 );
        text( popUpString, px1 + 5, py2 - 25 );
        textSize( 10 );
        text( "Genesis: " + gen + "          Freq: " + ( frq ) + "          CRV Score: " + crvScore , px1 + 5, py2 - 7 );
  } // end drawPopUpFunc
  



  void drawPopUpFreq( String popUpString) {
    fill( popUpBkgrd );
    stroke( popUpTxt );
    rectMode( CORNERS );
    rect( px1, py1, px2, py2 );
    fill( popUpTxt );
        textSize( 16 );
        text( popUpString, px1 + 5, py2 - 5 );
  } // end drawPopUpFreq



  
  int getMaxPostTime() {
   return maxPostTime; 
  } // end getMaxPostTime()



  
  float getMaxMetric() {
    float mm = 0.0;
    for( int i = 0; i < spokes.size(); i++ ) {
      Spoke s = ( Spoke ) spokes.get( i );
      if( s.crvScore > mm ) {
        mm = s.crvScore; 
      }
    } // end for i  
    return myRound( mm, 2 );
  } // end getMaxMetric()
  



  void markUncleaned( Spoke _s, float sAngle ) {        // markings for "#Name?" function strings
    /* Do Nothing - this maybe temporary */
    float xOrientation = 0;
    float yOrientation = 0;
    if( ( sAngle % 360 > 90 ) && ( sAngle % 360 < 270 ) ) {
      xOrientation = 0 - textWidth( _s.funcString );
      yOrientation = -10;
    } else { 
       xOrientation = textWidth( _s.funcString );
       yOrientation = -10;
    }
    if( _s.funcString.equals("#NAME?") || ( _s.isValid == false ) ) {                // Mark Invalid or "#Name?" funcString
      fill( 255, 0, 0, 127 );
      noStroke();
      rect( 0, 0, xOrientation, yOrientation );
    } 
    /*
    else if( _s.crvScore == 0 ) {                              // Mark Zero CRV Score
      fill( 250, 150, 0, 127 );
      noStroke();
      rect( 0, 0, xOrientation, yOrientation );
    }            
    */
  } // end markUncleaned()
        
        
        
        
  public void rotateClockWise() {
    userRotate += 360 / getCountSpokesOnShow( selValds );
    if( userRotate > 360 ) {
      userRotate = abs( userRotate ) - 360;
      deltaRotate = abs( deltaRotate ) - 360; 
    }
  } // end rorateClockwise()

        
        
        
  public void rotateCounterClockWise() {
    userRotate -= 360 / getCountSpokesOnShow( selValds );
    if( userRotate < 0 ) {
      userRotate = 360 - abs( userRotate );
      deltaRotate = 360 - abs( deltaRotate );
    }
  } // end rorateCounterClockwise()
        


        
  public void rotateReset() {
    userRotate = 0;
  } // end rotateReset()
  



  public int getSpokesCount() {
    return spokes.size();
  }




  public void updateHasData() {
    if( getSpokesCount() > 0 )
      hasData = true;      
    else
      hasData = false;
    countValids = updateCountValids();
    countInValids = updateCountInValids();
  } // end updateHasData()




  public String toString() {
    String ret = "";
    ret += ( "=====================================" + "\n" );
    ret += ( "Spiral Object Instance Details: " + "\n" );
    ret += ( "title: " + title + "\n" );
    ret += ( "cExerciseStart: " + cExerciseStart + "\n" );
    ret += ( "cDuration: " + cDuration + "\n" );
    ret += ( "cMinPostTime: " + cMinPostTime + "\n" );
    ret += ( "cMaxPostTime: " + cMaxPostTime + "\n" );
    ret += ( "hasData: " + hasData + "\n" );
    ret += ( "x, y, diam and rad: " + x + " " + y + " " + diam + " " + rad + "\n" );
    ret += ( "pWidth: " + pWidth + "     " + "gWidth: " + gWidth + "\n" );
    ret += ( "px1: " + px1 + "     py1: " + py1 + "\n" );
    ret += ( "px2: " + px2 + "     py2: " + py2 + "\n" );
    ret += ( "number of spokes: " + spokes.size() + "\n" );
    ret += ( "Now printing the spokes:" + "\n" );
    ret += ( "------------------------" + "\n" );
    for( int i = 0; i < spokes.size(); i++ ) {
      Spoke s = ( Spoke ) spokes.get( i );
      ret += ( s + "\n" );
    }
    ret += ( "------------------------" + "\n" );
    ret += ( "crvTotal: " + crvTotal + "\n" );
    ret += ( "=====================================" + "\n" );
    return ret;
  } // end toString()



  int updateCountValids() {
    int ret = 0;
    for( Spoke s : spokes )
      if( s.isValid )
        ret++;
    return ret;
  } // end updateCountValids()




  int updateCountInValids() {
    int ret = 0;
    for( Spoke s : spokes )
      if( s.isValid == false )
        ret++;
    return ret;
  } // end updateCountInvalids()




  int getCountSpokesOnShow( ArrayList<Boolean> input ) {
    int ret = 0;
    for( boolean sv : input ) {
      if( sv == true )
        ret += updateCountValids();
      if( sv == false )
        ret += updateCountInValids();
    }
    return ret;
  } // end getCountSpokesOnShow()
  
  
  
  void displayCountBox( float x1, float y1 ) {
      textSize( 20 );
      fill( 255, 255, 255, 140 );
      rect( x1, y1, x1+130, y1+30 );
      fill( 0, 0, 255 );
      text( countValids, x1+10, y1+23 );
      fill( 0 );
      text( "/", x1+60, y1+23 );
      fill( 255, 0, 0 );
      text( countInValids, x1+70, y1+23 );
    } // end displayCountBox()
      



} // end class Spiral

// ========================================
// Spiral Activity's User Interface Class ( Extends Class AUI )
// an extension of the AUI class which holds the code for all user 
// interactions for the Live Spiral visualizer
// See also: SpiralActivity.pde

class SpiralUI extends AUI {

  // Fields



  
  // Constructor

  SpiralUI ( SpiralActivity o ) {
    super();
    owner = o;

    createSpButton( o.x2Frame -100, o.y1Frame + 595, o.x2Frame - 45, o.y1Frame + 615, getNextIndexArrSpButtons(), "Font +", popUpTxt, popUpBkgrd, butOv, butPress );
    createSpButton( o.x2Frame -100, o.y1Frame + 620, o.x2Frame - 45, o.y1Frame + 640, getNextIndexArrSpButtons(), "Font -", popUpTxt, popUpBkgrd, butOv, butPress );

    createSpButton( o.x2Frame -100, o.y1Frame + 665, o.x2Frame - 45, o.y1Frame + 685, getNextIndexArrSpButtons(), "R. CW", popUpTxt, popUpBkgrd, butOv, butPress );
    createSpButton( o.x2Frame -160, o.y1Frame + 665, o.x2Frame - 105, o.y1Frame + 685, getNextIndexArrSpButtons(), "Reset", popUpTxt, popUpBkgrd, butOv, butPress );
    createSpButton( o.x2Frame -220, o.y1Frame + 665, o.x2Frame - 165, o.y1Frame + 685, getNextIndexArrSpButtons(), "R. CCW", popUpTxt, popUpBkgrd, butOv, butPress );
    createSpButton( o.x2Frame -280, o.y1Frame + 665, o.x2Frame - 225, o.y1Frame + 685, getNextIndexArrSpButtons(), "VALIDs", popUpTxt, popUpBkgrd, butOv, butPress );

  } // end constructor



  
  // Methods

  //@Override
  void update() {
    super.update();
  } // end update()



  
  //@Override
  void display() {
    super.display();
  } // end display()



  
  //@Override
  void executeMousePressed() {
  // All The Logic For UI Interaction go in here
  
  // First, some temp local variables for helpers
  SpiralActivity downcasted = (SpiralActivity) owner;
  Spiral currentSpiral = downcasted.spiral;
  
  // then, UI routines
  if( mouseButton == LEFT ) {
    int whichOne = getPressedArrSpButton();
    if( whichOne == 0 ) {  // "Font +"
      currentSpiral.spokeFontSize++;
      currentSpiral.spokeFontSize = constrain( currentSpiral.spokeFontSize, 8, 18 );
    }
    else if( whichOne == 1 ) {  // "Font -"
      currentSpiral.spokeFontSize--;
      currentSpiral.spokeFontSize = constrain( currentSpiral.spokeFontSize, 8, 18 );
    }
    else if( whichOne == 2 ) {  // "R. CW"
      currentSpiral.rotateClockWise();
    }
    else if( whichOne == 3 ) {  // "Reset"
      currentSpiral.rotateReset();
    } 
    else if( whichOne == 4 ) {  // "R. CCW"
      currentSpiral.rotateCounterClockWise();
    } 
    else if( whichOne == 5 ) { // VALIDITY TOGGLE SWITCH
      if( currentSpiral.selValds.contains( true ) && currentSpiral.selValds.contains( false ) ) {
        currentSpiral.selValds.remove( false );
        arrSpButtons.get( 5 ).label = "VALIDs";
      } else if( currentSpiral.selValds.contains( true ) && currentSpiral.selValds.size() == 1 ) {
        currentSpiral.selValds.remove( true );
        currentSpiral.selValds.add( false );
        arrSpButtons.get( 5 ).label = "INVALIDs";
      } else if( currentSpiral.selValds.contains( false ) && currentSpiral.selValds.size() == 1 ) {
        currentSpiral.selValds.add( true );
        arrSpButtons.get( 5 ).label = "Vs & IVs";
      }
      arrSpButtons.get( 5 ).display();
    }
  } // end if mouseButton == LEFT
  
  } // end executeMousePressed()



  
  //@Override
  void executeMouseDragged() {
    // First, some temp local variables for helpers
    SpiralActivity downcasted = (SpiralActivity) owner;
    Spiral currentSpiral = downcasted.spiral;

    // then, UI routines
    if( dist( mouseX, mouseY, currentSpiral.x, currentSpiral.y ) < currentSpiral.rad ) {
      currentSpiral.x = mouseX;
      currentSpiral.y = mouseY;
    }
  } // end executeMouseDragged()
  
  
  
  
  //@Override
  void executeMouseReleased() {
    super.executeMouseReleased();
  } // end executeMouseReleased()




} // end class SpiralUI

// ========================================
// Data Modelling Class ( Extends Class Function )
// used by the Sipral viz. Each instance of Spoke holds information about 
// one UNIQUE contribution.
// see also : class Function

class Spoke extends Function {

  // Fields

  int serialNum; // holds the serial number of the Spoke, sorted by Genesis, in min to max
  int genesis; // holds the time (in int) this function first occured in the exercise
  Post_Time cGenesis; // holds the genesis converted into Post_Time object
  int freq; // holds the frequency of occurence of this function throughout the exercise
  float mappedLength; // holds the length of the spoke, mapped from (0 - maximum post time in the exercise) to (0 - 200 pixels). Value is not set in constructor
  color c; // color of the spoke when displayed. Green - HIT; Red - NO-HIT
  PFont f; // holds the font to display the function string

  int numOpPlus, numOpMinus, numOpTimes, numOpDivides, numBonSquare, numBonNegative;

  float baseX, baseY, innerX, innerY, outerX, outerY, shortX, shortY;
  boolean isMouseOverFunc;
  int xMOFunc, yMOFunc; // coordinate of the pointer that is hovering over the spoke's Func
  boolean isMouseOverFreq;
  int xMOFreq, yMOFreq; // coordinate of the pointer that is hovering over the spoke's Freq

  float crvScore; // Creativity Metric Score




    // Constructor

  Spoke( Table _artefacts, int row ) {
    super( _artefacts, row );
    c = setColor( hitTxt );
    freq = 1;
    isMouseOverFunc = false;
    isMouseOverFreq = false;
    mineOpsBons( funcString );
    cGenesis = new Post_Time( genesis, "00:00:00" );
    xMOFunc = int( outerX );
    yMOFunc = int( outerY );
    xMOFreq = int( innerX );
    yMOFreq = int( innerY );
  } // end constructor




  // Overloaded constructor for live database streaming
  Spoke( Table _artefacts, int row, int tempSN ) {
    super( _artefacts, row, tempSN );
    c = setColor( hitTxt );
    freq = 1;
    isMouseOverFunc = false;
    isMouseOverFreq = false;
    mineOpsBons( funcString );
    cGenesis = new Post_Time( genesis, "00:00:00" );
    xMOFunc = int( outerX );
    yMOFunc = int( outerY );
    xMOFreq = int( innerX );
    yMOFreq = int( innerY );
  } // end overloaded constructor




  // Methods

  color setColor( boolean hit ) {
    if ( hit )
      return color( hitColor ); // hitColor and noHitColor are global variables for easy modification
    else
      return color( noHitColor);
  } // end setColor




    // Overloaded version
  color setColor( String s ) {
    if ( s.equals( "HIT" ) )
      return color( hitColor );
    else if ( s.equals( "NO-HIT" ) )
      return color( noHitColor );
    else if ( s.equals( "UNASSESSED" ) )
      return color( 128 );
    else
      return color( 128 );
  } // end setColor




  void mineOpsBons( String tempFuncString ) {
    for ( int i = 0; i < tempFuncString.length(); i++ ) {
      if ( tempFuncString.charAt( i ) == '+' )
        numOpPlus++;
      else if ( tempFuncString.charAt( i ) == '*' )
        numOpTimes++;
      else if ( tempFuncString.charAt( i ) == '/' )
        numOpDivides++;
      else if ( tempFuncString.charAt( i ) == '^' )
        numBonSquare++;
      else if ( tempFuncString.charAt( i ) == '-' ) {
        if ( ( i == 0 ) || ( hasPrecedingOp( tempFuncString, i - 1 ) ) )
          numBonNegative++;
        else
          numOpMinus++;
      } // end if found minus sign
    } // end for i
  } // end mineOpsBons()




  boolean hasPrecedingOp( String func, int loc ) {
    if ( ( func.charAt( loc ) == '+' ) || ( func.charAt( loc ) == '-' ) || ( func.charAt( loc ) == '*' )
      || ( func.charAt( loc ) == '/' ) || ( func.charAt( loc ) == '^' ) ) {
      return true;
    }
    else {
      return false;
    }
  } // end hasPrecedingOp()




  void computeCRVScore( float _plusWt, float _minusWt, float _timesWt, float _dividesWt, float _squareWt, float _negativeWt ) {
    crvScore = 0;
    crvScore = ( numOpPlus * _plusWt ) + ( numOpMinus * _minusWt ) + ( numOpTimes * _timesWt ) + ( numOpDivides * _dividesWt ) + ( numBonSquare * _squareWt ) + ( numBonNegative * _negativeWt );
  } // end computeCRVScore()




  String toString() {
    String ret = "";
    ret += "serialNum:" + serialNum + " ";
    ret += "genesis:" + genesis + " ";
    ret += "cGenesis:" + cGenesis + " ";
    ret += "funcString:" + funcString + " ";
    ret += "isValid" + isValid + " ";
    ret += "freq:" + freq + " ";
    ret += "mappedLength:" + mappedLength + " ";
    ret += "crvScore:" + crvScore + "\n";
    ret += "baseX:" + baseX + " baseY:" + baseY;
    ret += " innerX:" + innerX + " innerY:" + innerY;
    ret += " outerX:" + outerX + " outerY:" + outerY;
    ret += " shortX:" + shortX + " shortY:" + shortY + "\n";
    return ret;
  } // end toString()




} // end class Spoke

// ========================================
// Contribution Metrics Class
// used by the Spiral viz. Holds statistics on operands usage in the 
// spokes of the spiral

class Stats {

  // Fields

  Spiral statsSpiral;
  OpsUsage cou; // cou stands for classOpsUsage
  OpsUsage sou; // sou stands for schoolOpsUsage
  boolean hasData;
  
  SyringeSet clsSyringes, schSyringes;
  
  int maxNumOps;
  
  int[] opsWt = new int[ 6 ];       // REMEMBER TO INCREASE THIS AS NEW TYPES OF OPERANDS ARE ADDED
  
    float plusWt, minusWt, timesWt, dividesWt, squareWt, negativeWt; // the Weight for the various Ops



  
  // Constructor

  Stats( Spiral tempSpiral, OpsUsage tempCou, OpsUsage tempSou ) {
    statsSpiral = tempSpiral;
    cou = tempCou;
    sou = tempSou;
    hasData = tempSpiral.hasData;
    
    // obtaining maxNumOps - to be passed on as argument when creating Syringe instance objects ( called scaleBase )
    maxNumOps = 0;
    
    int[] numOpsSch = new int[ 6 ]; // REMEMBER TO INCREASE THIS AS NEW TYPES OF OPERANDS ARE ADDED
        
    for( int i = 0; i < tempSou.plusOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.plusOp.pointsAll.get( i );
      numOpsSch[ 0 ] += pt.value * pt.count;      
    } // end for i for plusOp 
    
    for( int i = 0; i < tempSou.minusOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.minusOp.pointsAll.get( i );
      numOpsSch[ 1 ] += pt.value * pt.count;      
    } // end for i for minusOp
    
    for( int i = 0; i < tempSou.timesOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.timesOp.pointsAll.get( i );
      numOpsSch[ 2 ] += pt.value * pt.count;      
    } // end for i for timesOp
    
    for( int i = 0; i < tempSou.dividesOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.dividesOp.pointsAll.get( i );
      numOpsSch[ 3 ] += pt.value * pt.count;      
    } // end for i for dividesOp
    
    for( int i = 0; i < tempSou.squareOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.squareOp.pointsAll.get( i );
      numOpsSch[ 4 ] += pt.value * pt.count;      
    } // end for i for squareOp
    
    for( int i = 0; i < tempSou.negativeOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.negativeOp.pointsAll.get( i );
      numOpsSch[ 5 ] += pt.value * pt.count;     
    } // end for i for negativeOp
    
    maxNumOps = max( numOpsSch );
    // end of calculating maxNumOps
    

    /* NOTE : bypassing the routines below for Live Spiral
    // calculating Weight for the various types of Ops
        // <<see Stats.Fields above>> int[] opsWt = new int[ 6 ];       // REMEMBER TO INCREASE THIS AS NEW TYPES OF OPERANDS ARE ADDED
        
    for( int i = 0; i < tempSou.plusOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.plusOp.pointsHit.get( i );
      opsWt[ 0 ] += pt.value * pt.count;
    } // end for i for plusOp 
    
    for( int i = 0; i < tempSou.minusOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.minusOp.pointsHit.get( i );
      opsWt[ 1 ] += pt.value * pt.count;      
    } // end for i for minusOp
    
    for( int i = 0; i < tempSou.timesOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.timesOp.pointsHit.get( i );
      opsWt[ 2 ] += pt.value * pt.count;      
    } // end for i for timesOp
    
    for( int i = 0; i < tempSou.dividesOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.dividesOp.pointsHit.get( i );
      opsWt[ 3 ] += pt.value * pt.count;      
    } // end for i for dividesOp
    
    for( int i = 0; i < tempSou.squareOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.squareOp.pointsHit.get( i );
      opsWt[ 4 ] += pt.value * pt.count;      
    } // end for i for squareOp
    
    for( int i = 0; i < tempSou.negativeOp.pointsHit.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.negativeOp.pointsHit.get( i );
      opsWt[ 5 ] += pt.value * pt.count;
    } // end for i for negativeOp
    
    // FORMULA FOR CALCULATING WEIGHTS: WeightforOperandtypeX = Sum of totalnumberofHitOperands across all types of Operands / totalnumberofHitOperandsforOperandtypeX
    int grandTotalNumOps = 0;
    for( int i = 0; i < opsWt.length; i++ ) {
     grandTotalNumOps += opsWt[ i ];
    }
    plusWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 0 ] ), 2 );
      if( opsWt[ 0 ] == 0 )         // Be careful of DIVISION BY ZERO!
        plusWt = 0;
    minusWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 1 ] ), 2 );
      if( opsWt[ 1 ] == 0 ) 
        minusWt = 0;
    timesWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 2 ] ), 2 );
      if( opsWt[ 2 ] == 0 ) 
        timesWt = 0;
    dividesWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 3 ] ), 2 );
      if( opsWt[ 3 ] == 0 ) 
        dividesWt = 0;
    squareWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 4 ] ), 2 );
      if( opsWt[ 4 ] == 0 ) 
        squareWt = 0;
    negativeWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 5 ] ), 2 );
      if( opsWt[ 5 ] == 0 ) 
        negativeWt = 0;
    
    
    // end of calculating Weight for the various types of Ops
    */
    calculateWeightsForLiveSpiral( sou );
    
    
    //clsSyringes = new SyringeSet( tempCou, "cls", maxNumOps );
    //schSyringes = new SyringeSet( tempSou, "sch", maxNumOps );
    
  } // end constructor



  
  // Methods

  void display() {
    fill( 255 );
    stroke( 255 );
    rect( 0, 302, 348, height ); // clears panel
    fill( 0 );
    textSize( 10 );
    text( "DISTRIBUTION OF OPERANDS", 70, 335 );
    textSize( 8 );
    text( "Class", 280, 330 );
    text( "School", 280, 340 );
    stroke( 0, 64, 28 ); fill( 0, 64, 28 ); rect( 255, 320, 265,330);
    stroke( 61, 178, 112 ); fill( 61, 178, 112 ); rect( 265, 320, 275,330);
    stroke( 21, 137, 72 ); fill( 21, 137, 72 ); rect( 255, 330, 265,340);
    stroke(117, 232, 166 ); fill(117, 232, 166 ); rect( 265, 330, 275,340);
    // Displaying the pointsHit and PointsNoHit distributions of the specified operator in the current Active Dataset <testing>
    text( "For negativeOp, its Hit Distribution are as follows: ", 30, 400 );
    for( int i = 0; i < cou.negativeOp.pointsHit.size(); i++ ) {
      DistribPt p = ( DistribPt ) cou.negativeOp.pointsHit.get( i );
     text( p.value + " <===> " + p.count, 50, 410 + ( i * 10 ) );
    }
    
     text( "For negativeOp, its No-Hit Distribution are as follows: ", 30, 500 );
    for( int i = 0; i < cou.negativeOp.pointsNoHit.size(); i++ ) {
      DistribPt p = ( DistribPt ) cou.negativeOp.pointsNoHit.get( i );
     text( p.value + " <===> " + p.count, 50, 510 + ( i * 10 ) );
    }
        
    clsSyringes.plusSyr.drawSyringe();
    clsSyringes.minusSyr.drawSyringe();
    clsSyringes.timesSyr.drawSyringe();
    clsSyringes.dividesSyr.drawSyringe();
    clsSyringes.squareSyr.drawSyringe();
    clsSyringes.negativeSyr.drawSyringe();
    
    schSyringes.plusSyr.drawSyringe();
    schSyringes.minusSyr.drawSyringe();
    schSyringes.timesSyr.drawSyringe();
    schSyringes.dividesSyr.drawSyringe();
    schSyringes.squareSyr.drawSyringe();
    schSyringes.negativeSyr.drawSyringe();
    
    clsSyringes.plusSyr.isMouseOver = checkMouse( clsSyringes.plusSyr );
    clsSyringes.minusSyr.isMouseOver = checkMouse( clsSyringes.minusSyr );
    clsSyringes.timesSyr.isMouseOver = checkMouse( clsSyringes.timesSyr );    
    clsSyringes.dividesSyr.isMouseOver = checkMouse( clsSyringes.dividesSyr );
    clsSyringes.squareSyr.isMouseOver = checkMouse( clsSyringes.squareSyr );
    clsSyringes.negativeSyr.isMouseOver = checkMouse( clsSyringes.negativeSyr );  
    
    schSyringes.plusSyr.isMouseOver = checkMouse( schSyringes.plusSyr );
    schSyringes.minusSyr.isMouseOver = checkMouse( schSyringes.minusSyr );
    schSyringes.timesSyr.isMouseOver = checkMouse( schSyringes.timesSyr );    
    schSyringes.dividesSyr.isMouseOver = checkMouse( schSyringes.dividesSyr );
    schSyringes.squareSyr.isMouseOver = checkMouse( schSyringes.squareSyr );
    schSyringes.negativeSyr.isMouseOver = checkMouse( schSyringes.negativeSyr );  
    
    // display calculated Weights and the formula for the calculation
    String formula1, formula2, formula3;
    formula1 = "Weight of Operand type X = ";
    formula2 = "Schol-wise sum of ( Number of Operands on Hit functions ) across all Operands";
     formula3 = "School-wise Number of Operands on Hit functions for Operand type X ";
    fill( 0 );
    textSize( 10 );
    text( "CALCULATED WEIGHTS" , 70, 585 );
    fill( popUpBkgrd );
    stroke( popUpTxt ); 
    textSize( 8 );
    rect( 275, 575, 275 + (textWidth ( "  Formula?  " ) ), 588 );
    fill( popUpTxt );
    text( "  Formula?  ", 275, 585 );
    
    // show formula on mouseover
    if( ( mouseX > 275 ) && ( mouseX < 275 + (textWidth ( "  Formula?  " ) ) ) && ( mouseY > 575 ) && ( mouseY < 585 ) )  {
      fill( popUpBkgrd );
      stroke( popUpTxt );
      textSize(10  );
      rect( 275, 575 - 100, 275 + textWidth( formula1 ) + textWidth( formula2 ) + 30, 575 ); 
      // printing formula
      fill( popUpTxt );
      text( formula1, 275 + 5, 575  - 70 );
      text( formula2, 275 + 5 + textWidth( formula1 ) + 10, 575 - 80 );
      line( 275 + 5 + textWidth( formula1 ) + 5, 575 - 75, 275 + 5 + textWidth( formula1 ) + textWidth( formula2 ) + 15, 575 - 75 );
      text( formula3, 275 + 5 + textWidth( formula1 ) + 40, 575 - 60 );
      
      // printing example
      text( "Ex.      Weight [ + ] = ", 275 + 5, 575  - 20 );
      text( opsWt[ 0 ] + " + " + opsWt[ 1 ] + " + " + opsWt[ 2 ] + " + ... + " + opsWt[ 5 ], 275 + 5 + textWidth( "Ex.      Weight [ + ] = " ) + 10, 575 - 30 );
      line( 275 + 5 + textWidth( "Ex.      Weight [ + ] = " ) + 5, 575 - 25, 275 + 5 + textWidth( "Ex.      Weight [ + ] = " ) + 145 + 15, 575 - 25 );
      text( opsWt[ 0 ], 275 + 5 + textWidth( "Ex.      Weight [ + ] = " ) + 70, 575 - 10 );
      text( " = " + plusWt, 275 + 5 + textWidth( "Ex.      Weight [ + ] = " ) + 145 + 15 + 10, 575 - 20 );
    
    } // end if mouse within formula button
        
    fill( 0 );
    textSize( 8 );
    text( "The calculated Weights for the Operands are as follows: ", 30, 600 );
    text( "Weight  [ + ]    : " + plusWt, 50, 610 );
    text( "Weight   [ - ]    : " + minusWt, 50, 620 );
    text( "Weight   [ * ]    : " + timesWt, 50, 630 );
    text( "Weight   [ / ]    : " + dividesWt, 50, 640 );
    text( "Weight  [ ^ ]    : " + squareWt, 50, 650 );
    text( "Weight [ -() ]    : " + negativeWt, 50, 660 );
      
  } // end display(); 
 



  int[] getUniqueVals( int[] _dataArr ) {
    int[] result = new int[ 1 ];
    result[ 0 ] = _dataArr[ 0 ];
    
    for( int i = 1; i < _dataArr.length; i++ ) {
      int accounted = 0;
      for (int j = 0; j < result.length; j++ ) {
        if( _dataArr[ i ] == result[ j ] ) {
          accounted++;
        }
      } // end for j
      if( accounted == 0 ) {
        result = append( result, _dataArr[ i ] );// add to result array
      }
    } // end for i
    return result;
  } // end int[] makeDistrib



  
  int[] getCountVals( int[] _dataArr, int[] _vals ) {
    int[] result = new int[ _vals.length ];
    for( int i = 0; i < _vals.length; i++ ) { 
      for( int j = 0; j < _dataArr.length; j++ ) {
        if( _dataArr[ j ] == _vals[ i ] )
          result[ i ] ++; 
      } // end for j
    } // end for i
    return result;
  } // end getCountVals()
  



  boolean checkMouse( Syringe _s ) {
    if( ( mouseX >= _s.xS - 30 ) && ( mouseX <= _s.xS + _s.maxLength ) && ( mouseY >= _s.yS ) && ( mouseY <= _s.yS + _s.maxHeight ) ) {
      return true;
    } else
    return false;
  } // end checkMouse()




void calculateWeightsForLiveSpiral( OpsUsage tempSou ) {
 // calculating Weight for the various types of Ops --- FOR USE WITH LIVE SPIRAL ONLY
        
    for( int i = 0; i < tempSou.plusOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.plusOp.pointsAll.get( i );
      opsWt[ 0 ] += pt.value * pt.count;
    } // end for i for plusOp 
    
    for( int i = 0; i < tempSou.minusOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.minusOp.pointsAll.get( i );
      opsWt[ 1 ] += pt.value * pt.count;      
    } // end for i for minusOp
    
    for( int i = 0; i < tempSou.timesOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.timesOp.pointsAll.get( i );
      opsWt[ 2 ] += pt.value * pt.count;      
    } // end for i for timesOp
    
    for( int i = 0; i < tempSou.dividesOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.dividesOp.pointsAll.get( i );
      opsWt[ 3 ] += pt.value * pt.count;      
    } // end for i for dividesOp
    
    for( int i = 0; i < tempSou.squareOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.squareOp.pointsAll.get( i );
      opsWt[ 4 ] += pt.value * pt.count;      
    } // end for i for squareOp
    
    for( int i = 0; i < tempSou.negativeOp.pointsAll.size(); i++ ){
      DistribPt pt = ( DistribPt ) tempSou.negativeOp.pointsAll.get( i );
      opsWt[ 5 ] += pt.value * pt.count;
    } // end for i for negativeOp
    
    // FORMULA FOR CALCULATING WEIGHTS: WeightforOperandtypeX = Sum of totalnumberofHitOperands across all types of Operands / totalnumberofHitOperandsforOperandtypeX
    int grandTotalNumOps = 0;
    for( int i = 0; i < opsWt.length; i++ ) {
     grandTotalNumOps += opsWt[ i ];
    }
    plusWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 0 ] ), 2 );
      if( opsWt[ 0 ] == 0 )         // Be careful of DIVISION BY ZERO!
        plusWt = 0;
    minusWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 1 ] ), 2 );
      if( opsWt[ 1 ] == 0 ) 
        minusWt = 0;
    timesWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 2 ] ), 2 );
      if( opsWt[ 2 ] == 0 ) 
        timesWt = 0;
    dividesWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 3 ] ), 2 );
      if( opsWt[ 3 ] == 0 ) 
        dividesWt = 0;
    squareWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 4 ] ), 2 );
      if( opsWt[ 4 ] == 0 ) 
        squareWt = 0;
    negativeWt = myRound( float( grandTotalNumOps ) / float( opsWt [ 5 ] ), 2 );
      if( opsWt[ 5 ] == 0 ) 
        negativeWt = 0;
    
    // end of calculating Weight for the various types of Ops
} // end calculateWeightsForLiveSpiral()



  
} // end class Stats


// ========================================
// Contribution Metrics Class
// Models the "Syringe" Bar Graph

class Syringe {

  // Fields

  float maxLength, maxHeight, cylLength, cylFill, xS, yS;
  int valAll, valNoHit, valHit, scaleBase;
  boolean isMouseOver, showLabel;
  String label;
  color colFill, colNoFill, colSlot;
  int[] countOpHit, countOpNoHit, countOpAll;
  OpDistrib distribHit, distribNoHit, distribAll;
  
  ArrayList pointsHit, pointsNoHit, pointsAll;



  
  // Constructor

  Syringe( float _xS, float _yS,  String _label, boolean _showLabel, ArrayList _pointsHit, ArrayList _pointsNoHit, ArrayList _pointsAll, int _scaleBase, color _colNoFill, color _colFill ) {
    colNoFill = _colNoFill;
    colFill = _colFill;
    colSlot = color( 230, 230, 230 , 255 );
    maxLength = 300;
    maxHeight = 15;
    xS = _xS;
    yS = _yS;
    label = _label;
    showLabel = _showLabel;
    isMouseOver = false;   
    scaleBase = _scaleBase;
    pointsHit = _pointsHit;
    pointsNoHit = _pointsNoHit;
    pointsAll = _pointsAll;
    
    // computing cylFill and cylLength
    valHit = 0;
    for( int i = 0; i < _pointsHit.size(); i++ ) {
      DistribPt pt = ( DistribPt ) _pointsHit.get( i );
      valHit += ( pt.value * pt.count );
    } // end for i
    cylFill = float( valHit);
    
    valNoHit = 0;
    for( int i = 0; i < _pointsNoHit.size(); i++ ) {
      DistribPt pt = ( DistribPt ) _pointsNoHit.get( i );
      valNoHit += ( pt.value * pt.count );
    } // end for i
    valAll = valHit + valNoHit;
    cylLength = float( valAll );

  } // end constructor



  
  // overloaded Constructor

  Syringe( float _xS, float _yS, String _label, boolean _showLabel, int _valHit, int _valAll, int _scaleBase, color _colNoFill, color _colFill, int[] _distribVals, int[] _distribCounts ) {
    colFill = _colFill;
    colNoFill = _colNoFill;
    colSlot = color( 230, 230, 230 , 255 );
    maxLength = 300;
    maxHeight = 15;
    xS = _xS;
    yS = _yS;
    valHit = _valHit;
    valAll = _valAll;
    label = _label;
    showLabel = _showLabel;
    isMouseOver = false;    
    cylFill = float( _valHit );
    cylLength = float( _valAll );
    scaleBase = _scaleBase;
  } // end constructor



  
  // Methods

  void drawSyringe() {
    stroke( colSlot );
    fill( colSlot );
    rect( xS, yS, xS + maxLength, yS + maxHeight );
    stroke( colNoFill );
    fill( colNoFill );
    if( cylLength > 0 )     // draw only if value of cylLength is > 0
      rect( xS, yS, xS + map( cylLength, 0, scaleBase, 0, maxLength ) - 1, yS + maxHeight );
    stroke( colFill );
    fill( colFill );
    if( cylFill > 0 )     // draw only if value of cylFill is  > 0
      rect( xS, yS, xS + map( cylFill, 0, scaleBase, 0, maxLength ) - 1, yS + maxHeight );
    
    if( showLabel ) {
      fill( 0 );
      stroke( 0 );
      textSize( 8 );
      text( label, xS - 30, yS + 12);
    } // end if showLabel
      
    if( isMouseOver ) {
      drawMouseOver();
    }
  } // end drawSyringe()



  
  void drawMouseOver() {
    if( mouseX < xS ) { // show composition of the counts for the Hit and No-Hit functions
      fill( colSlot );
      stroke( colSlot );
      rect( xS, yS, xS + ( 1 * maxLength ), yS + maxHeight );
          
      // display composition:
      int v, c, k, startNH;
      fill( colFill );
      stroke( colFill );
      k = 0;
      startNH = 0;
      for( int i = 0; i < pointsHit.size(); i++ ) {
        DistribPt pt = ( DistribPt ) pointsHit.get( i );
        v = pt.value;
        c = pt.count;
        if( v > 0 ) {     // only draw if value > 0
          for( int j = 0; j < c; j++ ) {
            rect( xS + k, yS, xS + k + v - 1, yS + maxHeight );
            k += v + 1;
            startNH = k;
          } // end for j
        } // end if v > 0
      } // end for i
      
      
      // show composition for the No-Hit Ops
      v = 0;
      c = 0;
      k = 0;
      fill( colNoFill );
      stroke( colNoFill );
      k = 0;
      for( int i = 0; i < pointsNoHit.size(); i++ ) {
        DistribPt pt = ( DistribPt ) pointsNoHit.get( i );
        v = pt.value;
        c = pt.count;
        if( v > 0 ) {     // only draw for values  > 0
          for( int j = 0; j < c; j++ ) {
            rect( xS + startNH + k, yS, xS + startNH + k + v - 1, yS + maxHeight );
            k += v + 1;
          } // end for j
       } // end if v > 0
      } // end for i
    } else { // show count numbers for the Hit and No-Hit functions ( mouseX > xS )
      fill( 0 );
      textSize( 12 );
      text( "Count: " + ( valHit ) + " / " + ( valAll ), xS + ( 1 * maxLength ) - 120 + 10, yS + maxHeight - 3 );
    } // end show count numbers

  } // end drawMouseOver()


  
  
} // end class Syringe

// ========================================
// Contribution Metrics Class
// Holds data on a group of Syringe objects

class SyringeSet {

  // Fields

  Syringe plusSyr, minusSyr, timesSyr, dividesSyr, squareSyr, negativeSyr;
  int maxRange;



  
  // Constructor

  SyringeSet( OpsUsage _ou, String setType, int _maxRange ) {
    int[] yPoses = new int[ 6 ];
    boolean showLabel;
    color colFill, colNoFill;
    if( setType.equals( "cls" ) == true ) { // set yPoses, showLabel, and colors for clsSyringes
      showLabel = true;
      colNoFill = color( 61, 178, 112 );
      colFill = color( 0, 64, 28 );
      for( int y = 0; y < 6; y++ ) {
        yPoses[ y ] = 345 + ( y * 35 );
      } // end for y
    } else { // settings for schSyringes
    showLabel = false;
      colNoFill = color( 117, 232, 166 );
      colFill = color( 21, 137, 70 );
      for( int y = 0; y < 6; y++ ) {
        yPoses[ y ] = 360 + ( y * 35 );
      } // end for y
    } // end else ( settings )
    maxRange = _maxRange;
    
    plusSyr = new Syringe( 30, yPoses[ 0 ], _ou.plusOp.label, showLabel, _ou.plusOp.pointsHit, _ou.plusOp.pointsNoHit, _ou.plusOp.pointsAll, maxRange, colNoFill, colFill );
    minusSyr = new Syringe( 30, yPoses[ 1 ], _ou.minusOp.label, showLabel,  _ou.minusOp.pointsHit, _ou.minusOp.pointsNoHit, _ou.minusOp.pointsAll, maxRange, colNoFill, colFill );
    timesSyr = new Syringe( 30, yPoses[ 2 ], _ou.timesOp.label, showLabel,  _ou.timesOp.pointsHit, _ou.timesOp.pointsNoHit, _ou.timesOp.pointsAll, maxRange, colNoFill, colFill );
    dividesSyr = new Syringe( 30, yPoses[ 3 ], _ou.dividesOp.label, showLabel,  _ou.dividesOp.pointsHit, _ou.dividesOp.pointsNoHit, _ou.dividesOp.pointsAll, maxRange, colNoFill, colFill );
    squareSyr = new Syringe( 30, yPoses[ 4 ], _ou.squareOp.label, showLabel,  _ou.squareOp.pointsHit, _ou.squareOp.pointsNoHit, _ou.squareOp.pointsAll, maxRange, colNoFill, colFill );
    negativeSyr = new Syringe( 30, yPoses[ 5 ], _ou.negativeOp.label, showLabel,  _ou.negativeOp.pointsHit, _ou.negativeOp.pointsNoHit, _ou.negativeOp.pointsAll, maxRange, colNoFill, colFill );
 
  } // end constructor



  
  // Methods




} // end class SyringeSet

// ========================================
// Data Modelling Class
// Main data class which holds data in a tabular format. 
// Used by both the Wave and the Spiral viz
// This is a modified version of Fry's Table class.
// Added features are as follows (as@ 15/10/2012):
// 1. Now works with ProcessingJS
// 2. Now can get columnCount - added columnCount field
// 3. Now can read TAB delimited file with " as the separation char - added .trim() method to the various "get" methods
// 4. Now can also take in data in the form of an array of rows

class Table {

  // Fields

  String[][] data;
  int rowCount;
  int columnCount;
  



  // Constructor
  
  Table() {
    data = new String[10][10];
  }




  // Overloaded constructor to handle data in an array of String

  Table( String[] dataInRows ) {
    String[] rows = dataInRows;
    data = new String[rows.length] [];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      
      // split the row on the tabs
      // String[] pieces = split(rows[i], "\t");
      String[] pieces = fixedSplitToken( rows[ i ], "\t", 9  );
      columnCount = pieces.length; // number of columns - value starts from 1 and not 0.
      // copy to the table array
      data[rowCount] = pieces;
      rowCount++;
      
      // this could be done in one fell swoop via:
      //data[rowCount++] = split(rows[i], TAB);
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  } // end overloaded constructor



  /*
  Table(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      
      // split the row on the tabs
      String[] pieces = split(rows[i], "\t");
      columnCount = pieces.length; // number of columns - value starts from 1 and not 0.
      // copy to the table array
      data[rowCount] = pieces;
      rowCount++;
      
      // this could be done in one fell swoop via:
      //data[rowCount++] = split(rows[i], TAB);
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  } // end constructor
  */



  // Methods
  
  int getColumnCount() {
    return columnCount; 
  }




  int getRowCount() {
    return rowCount;
  }
  


  
  // find a row by its name, returns -1 if no row found
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (data[i][0].equals(name)) {
        return i;
      }
    }
    return -1;
  }


  
  
  String getRowName(int row) {
    return getString(row, 0).trim();
  }




  String getString(int rowIndex, int column) {
    return data[rowIndex][column].trim();
  }



  /*
  String getString(String rowName, int column) {
    return getString(getRowIndex(rowName), column);
  }
  */
  /*
  int getInt(String rowName, int column) {
    return parseInt(getString(rowName, column).trim());
  }
  */


  
  int getInt(int rowIndex, int column) {
    return (int) parseFloat(getString(rowIndex, column).trim());
  }



  /*
  float getFloat(String rowName, int column) {
    return parseFloat(getString(rowName, column).trim());
  }
  */


  
  float getFloat(int rowIndex, int column) {
    return parseFloat(getString(rowIndex, column).trim());
  }
  
    
  

  void setRowName(int row, String what) {
    data[row][0] = what;
  }




  void setString(int rowIndex, int column, String what) {
    data[rowIndex][column] = what;
  }



  
  void setString(String rowName, int column, String what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = what;
  }



  
  void setInt(int rowIndex, int column, int what) {
    data[rowIndex][column] = str(what);
  }



  
  void setInt(String rowName, int column, int what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }



  
  void setFloat(int rowIndex, int column, float what) {
    data[rowIndex][column] = str(what);
  }


  void setFloat(String rowName, int column, float what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }


  
  
  // Write this table as a TSV file
  void write(PrintWriter writer) {
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < data[i].length; j++) {
        if (j != 0) {
          writer.print("\t");
        }
        if (data[i][j] != null) {
          writer.print(data[i][j]);
        }
      }
      writer.println();
    }
    writer.flush();
  } // end write()




  String[] fixedSplitToken( String row, String tkn, int targetCol ) {
    String input = row;
    String token = tkn;
    int colCount = targetCol;
    String[] ret = new String[ colCount ];

    int i = 0;
    int j = input.indexOf( token, i+1 );
    for( int index = 0; index < colCount - 1; index++ ) {
      String nextpiece = input.substring( i, j );
      ret[ index ] = nextpiece;
      i = j+1;
      j = input.indexOf( token, i );
    }
    ret[ colCount-1 ] = input.substring( i );
  return ret;
} // end fixedSplitToken()



} // end class Table

// ========================================
// GUI Component Class
// Models a viewing area that has two scrollbars

class View {
  
  // Fields

  float x1, y1, x2, y2;              // edge to edge coordinate ( including scroll bars )
  float x1a, y1a, x2a, y2a;          // viewing area edge coordinates ( excluding scroll bars )
  float borderN, borderS, borderE, borderW; // the north south east west border of the view ( white space )
  float x1sbv, y1sbv, x2sbv, y2sbv;  // scroll bar Vertical - coordinates
  float x1sbh, y1sbh, x2sbh, y2sbh;  // scroll bar Horizontal - coordinates
  float viewWidth, viewHeight;       
  float xScrollPos1, yScrollPos1, xScrollPos2, yScrollPos2;      // scroller position for determining rendering offsets
  int viewTextSize;
  PFont viewFont;
  PImage img;
  float contentHeight, contentWidth;
  color bgColor;
  AButton sbUp, sbDown, sbLeft, sbRight; // the four scrollbar buttons
  ScrollPosButton sbVer, sbHor;         // the two draggable scrollbars
  float step;  
  float xOffsetRender, yOffsetRender;
  boolean scrollableVer, scrollableHor;
  boolean mouseWithin;  // true if mouse pointer is within the view area




  // Constructor

  View( float x1v, float y1v, float x2v, float y2v ) {
    if( x2v - x1v >= 40 || y2v - y1v >= 40 ) {   // minimum size for a View object is 40x40
      x1 = x1v;
      y1 = y1v;
      x2 = x2v;
      y2 = y2v;
      x1a = x1;
      y1a = y1;
      x2a = x2 - 20;
      y2a = y2 - 20;
      x1sbv = x2a;
      y1sbv = y1a;
      x2sbv = x2;
      y2sbv = y2a;
      x1sbh = x1a;
      y1sbh = y2a;
      x2sbh = x2a;
      y2sbh = y2;
    } else {
      x1 = 0;
      y1 = 0;
      x2 = 0;
      y2 = 0;
      x1a = 0;
      y1a = 0;
      x2a = 0;
      y2a = 0;
      x1sbv = 0;
      y1sbv = 0;
      x2sbv = 0;
      y2sbv = 0;
      x1sbh = 0;
      y1sbh = 0;
      x2sbh = 0;
      y2sbh = 0;
    }
    
    viewWidth = x2a - x1a;
    viewHeight = y2a - y1a;
    borderN = 0;
    borderS = 0;
    borderE = 0;	
    borderW = 0;
    
    xScrollPos1 = 0;
    yScrollPos1 = 0;
    xScrollPos2 = xScrollPos1 + ( x2a - x1a );
    yScrollPos2 = yScrollPos1 + ( y2a - y1a );
    
    sbUp    = new AButton(       x2a,       y1,      x2, y1 + 20, 0 );
    sbDown  = new AButton(       x2a, y2a - 20,      x2,     y2a, 1 );
    sbLeft  = new AButton(       x1,       y2a, x1 + 20,      y2, 2 );
    sbRight = new AButton( x2a - 20,       y2a,     x2a,      y2, 3 );
    
    sbVer = new ScrollPosButton( this, x2a, y1a + 20, x2, y2a - 20, 4, "VERTICAL" );
    sbHor = new ScrollPosButton( this, x1a + 20, y2a, x2a - 20, y2, 5, "HORIZONTAL");
    step = 30;
    scrollableVer = determineScrollable( sbVer );
    scrollableHor = determineScrollable( sbHor );
    
    img = null;
    // BiG : scrollbars will be drawn incorrectly when contentWidth is less than viewWidth & ditto heith
    //contentHeight = 0+borderN+borderS;
    //contentWidth = 0+borderE+borderW;
    contentHeight = viewHeight;
    contentWidth = viewWidth;

    bgColor = color( 255, 255, 255 ); // setting white as the default color
    updateMouseWithin();
    updateOffsetRenders();
    
  } // end constructor  




  // Methods

  float getX1() {
    return x1;
  }




  float getY1() {
    return y1;
  }




  float getX2() {
    return x2;
  }




  float getY2() {
    return y2;
  }
  
  
  
  
  float getX1A() {
   return x1a; 
  }

  
  
  
  float getY1A() {
   return y1a; 
  }
  

  
  
  float getX2A() {
   return x2a; 
  }
  



  float getY2A() {
   return y2a; 
  }
  



  float getXScrollPos1() {
   return xScrollPos1; 
  }
  

  
  
  float getYScrollPos1() {
   return yScrollPos1; 
  }
  

  
  
  float getXScrollPos2() {
   return xScrollPos2; 
  }
  

  
  
  float getYScrollPos2() {
   return yScrollPos2; 
  }
  
  
  
  
  void updateContentDimension( float xCheck, float yCheck ) {
    if( contentWidth < xCheck +borderE+borderW ) {
      contentWidth = xCheck +borderE+borderW;
      sbHor.reposition( getScrollPos() ); 
    }
    if( contentHeight < yCheck +borderN+borderS ) {
      contentHeight = yCheck +borderN+borderS;
      sbVer.reposition( getScrollPos() );
    }
  } // end updateContentDimension()




  float calcX( float val ) {
    return xOffsetRender + val;
  }




  float calcY( float val ) {
    return yOffsetRender + val;
  } // end calcY()
  
  
  
  void clearBackground() {
    fill( bgColor );
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
    noFill();
  } // end clearBackground()




  void putRect( float tx1, float ty1, float tx2, float ty2 ) {
    rectMode( CORNERS );
    
    updateContentDimension( tx1, ty1 );
    updateContentDimension( tx2, ty2 );
    
    rect( calcX( tx1 ), calcY( ty1 ), calcX( tx2 ), calcY( ty2 ) );
  }



  
  void putImage() {
  // this version of putImage() puts an image at a fixed position, starting from 0,0
  // there's no need to updateContentDimension, that's done when the image was set
  // typically used for displaying background image
    if( img != null )
      image( img, calcX( 0 ), calcY( 0 ) ); 
  } // end putImage()
  
  
  
  
  void putImage( float tx, float ty ) {
  // this version of putImage may put the image at arbitrary position, so need to upate content dimension
  // typically used with small images for animation purposes
    if( img != null ) {
      updateContentDimension( tx, ty );
      image( img, calcX( tx ), calcY( ty ) ); 
    }
  } // end putImage()
  
  


  void putLine( float tx1, float ty1, float tx2, float ty2 ) {
    updateContentDimension( tx1, ty1 );
    updateContentDimension( tx2, ty2 );    
    line( calcX( tx1 ), calcY( ty1 ), calcX( tx2 ), calcY( ty2 ) );
  } // end putLine()




  void putEllipse( float tx, float ty, float txdiam, float tydiam  ) {
    ellipseMode( CENTER );    
    updateContentDimension( tx + 0.5 * txdiam, ty + 0.5 * tydiam );
    ellipse( calcX( tx ), calcY( ty ), txdiam, tydiam );
  } // end putEllipse()




  void putText( String s, float tx, float ty ) {
    textFont( viewFont, viewTextSize );
    updateContentDimension( tx, ty - viewTextSize );
    updateContentDimension( tx + textWidth( s ), ty + ( viewTextSize / 2 ) );
    text( s, calcX( tx ), calcY( ty ) );
  } // end putText()




  void setImage( PImage pimg ) {
    img = pimg;
    setContentHeight( pimg.height +borderN+borderS );
    setContentWidth( pimg.width +borderE+borderW );
  } // end setImage()
  

  
  
  void setContentHeight( int h ) {
    contentHeight = float( h );
  } // end setContentHeight()
  

  
  
  void setContentHeight( float h ) {
    contentHeight = h;
  } // end setContentHeight()
  

  
  
  void setContentWidth( int w ) {
    contentWidth = float( w );
  } // end setContentWidth()
  

  
  
  void setContentWidth( float w ) {
    contentWidth = w;
  } // end setContentWidth()



  
  void putTextFont( PFont f ) {
    viewFont = f;
    textFont( f );
  } // end putTextfont()




  void putTextFont( PFont f, int size ) {
    viewFont = f;
    viewTextSize = size;
    textFont( f, size );
  } // end putTextFont()




  void putTextSize( int size ) {
    viewTextSize = size;
    textSize( size );
  } // end putTextSize()




  void putBgColor( color c ) {
    bgColor = c;
  } // end putBgColor()




  float calculateXOffsetRender() {
    return ( x1a - xScrollPos1 );
  }




  float calculateYOffsetRender() {
    return ( y1a - yScrollPos1 );
  } 




  void updateOffsetRenders() {
    xOffsetRender = calculateXOffsetRender();
    yOffsetRender = calculateYOffsetRender();
  } // end updateOffsets()



  
  void updateMouseWithin() {
    if( mouseX >= x1a && mouseX <= x2a && mouseY >= y1a && mouseY <= y2a )
      mouseWithin = true;
    else
      mouseWithin = false;
  } // end updateMouseWithin()




  void display() {
    updateMouseWithin();
    stroke( 0 );
    noFill();
    rectMode( CORNERS );
    rect( x1, y1, x2, y2 );
    fill( 60, 60, 60 );
    rect( x1sbv, y1sbv, x2sbv, y2sbv );
    rect( x1sbh, y1sbh, x2sbh, y2sbh );
    rect( x1sbv,y1sbh, x2sbv,y2sbh );
    
    sbUp.update();
    sbDown.update();
    sbLeft.update();
    sbRight.update();
    sbVer.update();
    sbHor.update();
    
    sbUp.display();
    sbDown.display();
    sbLeft.display();
    sbRight.display();
    sbVer.display();
    sbHor.display();
    
    stroke( 0 );
    fill( 0 );
    triangle( sbUp.x1 + 5, sbUp.y2 - 5, sbUp.x1 + 10, sbUp.y1 + 5, sbUp.x2 - 5, sbUp.y2 - 5 );
    triangle( sbDown.x1 + 5, sbDown.y1 + 5, sbDown.x1 + 10, sbDown.y2 - 5, sbDown.x2 - 5, sbDown.y1 + 5 );
    triangle( sbLeft.x2 - 5, sbLeft.y2 - 5, sbLeft.x1 + 5, sbLeft.y1 +10, sbLeft.x2 - 5, sbLeft.y1 + 5 );
    triangle( sbRight.x1 + 5, sbRight.y2 - 5, sbRight.x2 - 5, sbRight.y1 + 10, sbRight.x1 + 5, sbRight.y1 + 5 );


  } // end display()
  
  
  
  
  void drawDebugInfo() {
    fill( 128 );
    textSize( 10 );
    text( "view Width x view Height: " + ( x2a-x1a ) + " " + (y2a-y1a), x1, y1 + 10 );
    text( "contentWidth x contentHeight: " + contentWidth + " " + contentHeight, x1, y1 + 20 );
    text( "sbHor.x1 sbHor.x2: " + sbHor.x1 + " " + sbHor.x2, x1, y1 + 30 );
    text( "sbVer.y1 sbVer.y2: " + sbVer.y1 + " " + sbVer.y2, x1, y1 + 40 );
    text( "xScrollPos2, yScrollPos2: " + xScrollPos2 + " " + yScrollPos2, x1, y1 + 50 );

  } // end drawDebugInfo()
  
  
  
  void releaseAllButtons() {
    sbUp.release();
    sbDown.release();
    sbLeft.release();
    sbRight.release();
    sbVer.release();
    sbHor.release();
  } // end release All Buttons()
 



  void repositionScrollPosBtns() {
  // calculates new position for the two scrollPosBtns, call this method after every change
  // in the xScrollPoses or yScrollPoses
    sbVer.y1 = map( yScrollPos1, 0, contentHeight, y1+20, y2a - 20 );
    if( yScrollPos2 < contentHeight )
      sbVer.y2 = map( yScrollPos2, 0, contentHeight, y1+20, y2a - 20 );
    else
      sbVer.y2 = y2a - 20;
    sbHor.x1 = map( xScrollPos1, 0, contentWidth, x1a + 20, x2a - 20 );
    if( xScrollPos2 < contentWidth )
      sbHor.x2 = map( xScrollPos2, 0, contentWidth, x1a + 20, x2a - 20 );
    else
      sbHor.x2 = x2a - 20;
    updateScrollables();
  } // end repositionScrollPosBtns()
  
  
  
  
  void updateScrollables() {
    scrollableVer = determineScrollable( sbVer );
    scrollableHor = determineScrollable( sbHor );
  } // end updateScrollables()
  
  
  
  
  boolean determineScrollable( ScrollPosButton scpos ) {
    boolean ret = true;
    if( scpos.equals( sbVer ) )
      if( scpos.y1 == y1+20 && scpos.y2 == y2a-20 ) // can't scroll if scrollposbutton occupies the whole scrollbar
        ret = false;
    else if( scpos.equals( sbHor ) )
      if( scpos.x1 == x1a+20 && scpos.x2 == x2a-20 )
        ret = false;
    return ret;
  } // end determineScrollable()




  void stepUp() {
    int yScrollPosInSteps = ceil( yScrollPos1 / step );
    yScrollPosInSteps--;
    if( yScrollPosInSteps < 0 )
      yScrollPosInSteps = 0;
    yScrollPos1 = yScrollPosInSteps * step;
    yScrollPos2 = yScrollPos1 + viewHeight;
    sbVer.reposition( getScrollPos() );
  } // end stepUp()




  void stepDown() {
    int yScrollPosInSteps = ceil( yScrollPos2 / step ); 
    yScrollPosInSteps++;
    if( yScrollPosInSteps > ceil( contentHeight / step ) )
      yScrollPosInSteps = ceil( contentHeight / step );
    yScrollPos2 = yScrollPosInSteps * step;
    if( yScrollPos2 > contentHeight )
      yScrollPos2 = contentHeight;
    yScrollPos1 = yScrollPos2 - viewHeight;
    sbVer.reposition( getScrollPos() );
  } // end stepDown()




  void stepLeft() {
    int xScrollPosInSteps = ceil( xScrollPos1 / step );
    xScrollPosInSteps--;
    if( xScrollPosInSteps < 0 )
      xScrollPosInSteps = 0;
    xScrollPos1 = xScrollPosInSteps * step;
    xScrollPos2 = xScrollPos1 + viewWidth;
    sbHor.reposition( getScrollPos() );
  } // end stepLeft()



  
  void stepRight() {
    int xScrollPosInSteps = floor( xScrollPos2 / step ); 
    xScrollPosInSteps++;
    if( xScrollPosInSteps > ceil( contentWidth / step ) )
      xScrollPosInSteps = ceil( contentWidth / step );
    xScrollPos2 = xScrollPosInSteps * step;
    if( xScrollPos2 > contentWidth )
      xScrollPos2 = contentWidth;
    xScrollPos1 = xScrollPos2 - viewWidth;  
    sbHor.reposition( getScrollPos() );
  } // end stepRight()




  float[] getScrollPos() {
    float[] sp = new float[ 4 ];
    sp[ 0 ] = getXScrollPos1();
    sp[ 1 ] = getYScrollPos1();
    sp[ 2 ] = getXScrollPos2();
    sp[ 3 ] = getYScrollPos2();
    return sp;
  } // end getScrollPos();




  void reposition() {
    sbVer.reposition( getScrollPos() );
    sbHor.reposition( getScrollPos() );
  } // end reposition()




  void updateDrag() {
    if( sbVer.over && scrollableVer )
        sbVer.onDrag = true;
    else if( sbHor.over && scrollableHor )
      sbHor.onDrag = true;
      
    if( sbVer.onDrag ) {
      float mouseYAnchor = pmouseY;
      float yGap = mouseY - mouseYAnchor;
      yScrollPos1 = map( sbVer.y1 + yGap, y1+20, y2a - 20, 0, contentHeight );
      yScrollPos1 = constrain( yScrollPos1, 0, contentHeight - viewHeight );
      yScrollPos2 = yScrollPos1 + viewHeight;
      reposition();
    } 

    if( sbHor.onDrag ) {
      float mouseXAnchor = pmouseX;
      float xGap = mouseX - mouseXAnchor;
      xScrollPos1 = map( sbHor.x1 + xGap, x1a + 20, x2a - 20, 0, contentWidth );
      xScrollPos1 = constrain( xScrollPos1, 0, contentWidth - viewWidth );
      xScrollPos2 = xScrollPos1 + viewWidth;
      reposition();
    } 

  } // end updateDrag()
  
  
  
  
} // end class View

