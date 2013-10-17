// ========================================
// This is the main class (top-level class) for the Live Wave visualizer


// Globally define a class to handle Ajax tasks
// ----------------------//
// START JavaScript code //
// --------------------- //

function AjaxGETObject() {
  var dataAjax = "someinitialdata";
  var dataBuffered = false;
  var dataDelivered = false;
  this.request = new ajaxRequest();

  this.makeAjaxGet = function( urlAddress ) {
    this.request.open( "GET", urlAddress, true );
    this.request.send( null );
  } // end method makeAjaxGet()

  this.request.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {
        if (this.responseText != null) {
          dataBuffered = true;          
          dataAjax = this.responseText; 
        } else 
          alert("Ajax GET error: No data received");
      } else     
        alert( "Ajax GET error: \n status code: " + status + "\n" + this.statusText);
    }
  } // end function onreadystatechange()    
        
  this.grabData = function() {
    if( dataDelivered === true )
      return "";
    else { 
      if( dataBuffered === false )
        return "";
      else {
        dataDelivered = true;
        return dataAjax;
      }
    }
  } // end grabData()




} // end constructor for AjaxGETObject




function AjaxPOSTObject() {
//  var dataPairs = new Array();
  this.request = new ajaxRequest();

  this.makeAjaxPost = function( urlAddress, dataPairs ) {
    this.request.open( "POST", urlAddress, true );
    this.request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    this.request.setRequestHeader("Content-length", dataPairs.length)
    this.request.setRequestHeader("Connection", "close")

    this.request.onreadystatechange = function()
    {
      if (this.readyState == 4)
      {
        if (this.status == 200)
        {
          if (this.responseText != null)
          {
            processServerResponse( this.responseText );
          }
          else alert("Ajax POST error: No data received");
        }
        else alert( "Ajax POST error:\n" + "status code: " + this.status + "\n" + this.statusText);
      }
    }

    this.request.send( dataPairs );
  } // end method makeAjaxPost()




  function processServerResponse( resp ) {
    var pieces = resp.split( ":" );

    if( pieces.length > 1 ) {
      var p = Processing.getInstanceById( "LiveWave" );
      
      // anticipate reply to "Save State" --> look for state id
      if( p.getWva().getWave().expectNewID || p.getWva().getWave().stateID == -1) {
        var innerpcs = pieces[ 1 ].split( " ="  );
        innerpcs[ 1 ] = parseInt( innerpcs[ 1 ] );
        // ensure prereqs are met
        if( innerpcs.length > 1 && innerpcs[ 0 ] === " state id" )
          p.getWva().getWave().setStateID( innerpcs[ 1 ] );
        p.getWva().getWave().expectNewID = false;
      }
    }
  } // end processServerResponse()




} // end constructor for AjaxPOSTObject




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




  // <0 - this first
  // =0 - same
  // >0 - s first
  function compareTo( s ) {
    var len1 = this.length;
    var len2 = s.length;
    var n = ( len1 < len2 ? len1 : len2 );

    for( i = 0 ; i < n ; i++ ){
      var a = this.charCodeAt( i );
      var b = s.charCodeAt( i );
      if( a != b ) {
        if( ( a - b ) < 0 )
          return( -1 ); 
        else
          return( 1 );
      }
    }
    var discrep = len1 - len2;
    if( discrep < 0 )
      return( -1 );
    else if( discrep > 0 )
      return( 1 );
    else
      return( 0 );
  }
 
  String.prototype.compareTo = compareTo;

// ------------------- //
// END JavaScript Code //
// ------------------- //




// --------------------= //
// START Processing Code //
// --------------------- //

// Fields

WavePt anchoredWpMO;

WaveActivity wva;

color hitColor, noHitColor, hitColorScatter, noHitColorScatter;
color popUpBkgrd, popUpTxt, butOv, butPress;
PFont waveFont;
Divider[] dividers;

  String[] aDetails = new String[ 3 ];

  // applet params
  String hostip, school, teacher, cnameandcyear, cname, cyear, actid, starttimeFull, starttimeTrimmed, functioncall;




void setup() {
  setupDisplayElements(); 
  //
  //readParams(); // comment to debug, uncomment before deploying

  //new == javascript versions of applet param reading
  loadParams();

  // use these for deployment 
  buildADetails();
 
/*
  //use these for debugging
  hostip = "localhost:9000";
  school = "SST";
  teacher = "Johari";
  cnameandcyear = "test2012"; // << NOTE: need to check the value
  cname = "test";
  cyear = "2012";
  actid = "1";
  starttimeFull = "00:00:00"; 
  starttimeTrimmed = "00:00:00"; 
  functioncall = "getAllContributionsAfterVerbose";
 
  //aDetails[ 0 ] = "http://203.116.116.34:80/getAllContributionsAfter?aid=8&ind=0";
  aDetails[ 0 ] = "http://localhost:9000/getAllContributionsAfterVerbose?aid=1&ind=0";
  aDetails[ 1 ] = "15:00:00";
  aDetails[ 2 ]  = "Testing";
*/
  
  wva = new WaveActivity( this );
  wva.startWave( aDetails, parseInt( actid ), hostip );

  gotActivePopUp = false;
  anchoredWpMO = null;  
} // end setup()




void draw() {
  wva.display();
} // end draw()




void executeChosenCodes( String[] pcs ) {
  ArrayList<String> newSelCodes = new ArrayList<String>();
  for( int i = 0; i < pcs.length; i++ )
    newSelCodes.add( pcs[ i ] );

  wva.wave.selCodes = newSelCodes;
  wva.wave.markForDisplay( wva.wave.selCodes, wva.wave.selValds );
  wva.wave.sortBy( wva.wave.selEqs, wva.wave.selValds );
} // end executeChosenCodes()




void executeNewSelEqs( String[] pcs ) {
  //println( "pcs.length is: " + pcs.length );
  ArrayList<String> newSelEqs = new ArrayList<String>();
  //println( "newSelEqs.size is: " + newSelEqs.size() );
  for( int i = 0; i < pcs.length; i++ ) {
    //println( pcs[ i ] );
    newSelEqs.add( pcs[ i ] );
  }
  
  wva.wave.selEqs = newSelEqs;
} // end executeNewSelEqs()




void executeAnnotation( String[] pcs ) {
  //println( "annotation executed." );
} // end executeAnnotation()




void executeSetValidity( int newCode ) {
  wva.wave.setValidity( newCode, wva.getWvactivityUI() );
} // end executeSetValidity()




void setSchool( String s ) {
  school = s;
} // end setSchool()




void setTeacher( String s ) {
  teacher = s;
} // end setTeacher()




void setCNameAndCYear( String s ) {
  cnameandcyear = s;
} // end setCNameAndCYear()




void setCName( String s ) {
  cname = s;
} // end setCName()




void setCYear( String s ) {
  cyear = s;
} // end setCYear()




void setActid( String s ) {
  actid = s;
} // end setActid()




void setStartTimeFull( String s ) {
  starttimeFull = s;
} // end setStartTimeFull()




void setStartTimeTrimmed( String s ) {
  startTimeTrimmed = s;
} // end setStartTimeTrimmed()




void buildNewWva() {
  wva = new WaveActivity( this );
  wva.startWave( aDetails, parseInt( actid ), hostip );
  //println( "calling display for the first time..." );
  wva.display();
  //println( "end first display" );

  // waveUI display to reflect loading
  //int count=0;
  //fill( 0, 0, 255 );
  //while( wva.dataWholeChunk.contains( "MATCHING" ) == false ) {
  //  println( "not yet matching" + wva.dataWholeChunk );
  //  if( count >= wva.wvaUI.view.xScrollPos2 - 100 )
  //    count--;
  //  else
  //    count ++;
  //  
  //  stroke( 0, 0, 255 );
  //  fill( 0, 0, 255 );
  //  wva.wvaUI.view.clearBackground();
  //  wva.wvaUI.view.putRect( 20+count, 20, 130+count, 120 ); 
  //  fill( 255, 255, 0 );
  //  wva.wvaUI.view.putText( "LOADING ... ", 40+count, 60 );
  //  println( "end while not yet matching" );        
  //}
  //println( "end buildNewWva" );
} // end buildNewWva()






void mousePressed() {
  if( wva.activePopUp != null ){
    wva.activePopUp.protoUI.executeMousePressed();
  } else { 
    wva.activityUI.executeMousePressed(); 
  }
} // end mousePressed()




void mouseDragged() {
  if( wva.activePopUp != null )
    wva.activePopUp.protoUI.executeMouseDragged();
  else 
    wva.activityUI.executeMouseDragged();
} // end mouseDragged()




void mouseReleased() {
  if( wva.activePopUp != null )
    wva.activePopUp.protoUI.executeMouseReleased();
  else
    wva.activityUI.executeMouseReleased();
} // end mouseReleased()



void keyPressed() {
  if( wva.activePopUp != null )
    wva.activePopUp.protoUI.executeKeyPressed();
  else
    wva.activityUI.executeKeyPressed();
} // end keyPressed()




void setupDisplayElements() {
  size( 1180, 700 );
  smooth();
  waveFont = loadFont( "SansSerif.plain-12.vlw" ); // set as global to make changing easier
  textFont( waveFont );
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


//new -- this loads from javascript functions, rather than applet tags (readParams() below)
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



void buildADetails() {
//  aDetails[ 0 ] = "http://" + hostip + "/" + functioncall + "?aid=" + actid + "&ind=0";
  //new -- omit http and host ip.
  aDetails[ 0 ] = "/" + functioncall + "?aid=" + actid + "&ind=0";

  aDetails[ 1 ] = starttimeTrimmed;  
  aDetails[ 2 ] = actid + " " + cnameandcyear + " " + school + " " + teacher; 
} // end buildADetails()




float myRound( float val, int dp ) {
  return int( val * pow( 10, dp ) ) / pow( 10, dp );
} // end myRound()




String toString() {
  return( "LiveWave - current state:\n" +
          "=========================\n" +
          "\tschool: " + school + "\n" +
          "\tteacher: " + teacher + "\n" +
          "..."
  );
} // end toString()




WaveActivity getWva() {
  return wva;
} // end getWva()




void setAnchoredWpMO( WavePt wp ){
// set an 'anchor point' so the message from popup window can quickly refer back to
// the WavePt being opened for annotation
  anchoredWpMO = wp;
} // end setAnchoredWpMO()




void setNewAnnotationAncWpMO( String newAnnot ) {
  if( anchoredWpMO != null ) {
    anchoredWpMO.setAnnotation( newAnnot );
    anchoredWpMO.postAnnotation();
  }
} // end setNewAnnotationAncWpMO()




void setNewCodesAncWpMO( String chainedCodes ) {
  if( anchoredWpMO != null ) {
    anchoredWpMO.setCodes( chainedCodes );
    anchoredWpMO.postCodes();
  }
} // end setNewCodesAncWpMO()




void executeSaveState( String aID, String sID, String sName, String sComments, boolean moveSID ) {
  if( moveSID )
    wva.wave.expectNewID = true;
  else {
    wva.wave.expectNewID = false;
  }

  // update state details in memory
  wva.wave.stateName = sName;
  wva.wave.comments = sComments;

  String packedSelCodes = wva.wave.consolidateCodesToString( wva.wave.selCodes );
  String packedSelEqs = wva.wave.consolidateToString( wva.wave.selEqs );
  int validityCode = wva.wave.getValidityCode();

  var postData = "";
  if( moveSID == false ) { 
    postData += "id=" + sID + "&";
  }
 
  postData += "selcodes=" + packedSelCodes + "&";
  postData += "name=" + sName + "&";
  postData += "sid=" + aID + "&"; // sid should be aid here need to change play sode
  postData += "selstring=" + packedSelEqs + "&";
  postData += "comments=" + sComments + "&";
  postData += "whatshowing=" +validityCode;

  if( moveSID == true ) {
    postAjaxObject = new AjaxPOSTObject();
   	//postAjaxObject.makeAjaxPost( "http://" + hostip + "/saveWaveState", postData );
    //new: remove http & hostip
    postAjaxObject.makeAjaxPost(  "/saveWaveState", postData );

  } else { 
    postAjaxObject = new AjaxPOSTObject();
    //postAjaxObject.makeAjaxPost( "http://" + hostip + "/updateWaveState", postData );
 	//new: remove http & hostip
    postAjaxObject.makeAjaxPost( "/updateWaveState", postData );

  }

} // end executeSaveState()



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
// Wave Activity Class ( a child class of LVActivity )
// The main class for the Live Wave visualizer
// see also: class WaveUI

class WaveActivity extends LVActivity {

  // Fields

  WaveUI wvactivityUI;
  Wave wave;




  // Constructor

  WaveActivity( LiveWave o ) {
    super( o );
    bgColor = color( 0, 0, 0 );
    wvactivityUI = new WaveUI( this );
    activityUI = wvactivityUI;

    wave = new Wave();
  } // end constructor




  // Methods
  
  void display() {
    super.display();
  } // end display()




  void prerender() {
    super.prerender();
    View renderer = activityUI.view;
    wave.drawWave( renderer );
  } // end prerender()
  
  
  
  
  void render() {
    super.render();
    if( hasNewValidDatastream )
      processDatastream( databaseStream );
    prepForNextDatastream();
    View renderer = activityUI.view;
    renderer.updateOffsetRenders();
    wave.display( renderer );
    wave.ribbon.drawThreadInView( renderer );
  } // end render()




  void startWave( String[] aDetails, long actid, String hostip ) {
  // aDetails [0] [1] [2] is url, startTime and title
  //
    super.startLV( aDetails );

    // create a new wave and put in activity details into it
    wave.sproutWave( aDetails[ 1 ], aDetails[ 2 ], actid,  codeCabinet ); // pass codeCabinet to Wave
    hasNewValidDatastream = false;
    wave.hostip = hostip;
  } // end startWave()




  void processDatastream( Table databaseStream ) {
    //println( "processing Databasestream for Wave ... " );
    wave.growWave( databaseStream );
    wave.lastCountForFuncs = wave.funcs.size();
  } // end processDatastream()



  Wave getWave() {
    return wave;  
  } // end getWave()




  WaveUI getWvactivityUI() {
    return wvactivityUI;
  } // end getWvactivityUI()




  void openPopUpInput() {
    
  } // end openPopUpInput()

  
  
  
  String toString() { 
    return( "This is WaveActivity." );
  } // end toString()




} // end class WaveActivity
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
  boolean onDatastream;   // true for continuous database polling, false for pausing
  
  ArrayList<CodeItem> codeItemsList;
  ArrayList<CodeCateogry> codeCategoriesList;
  Map<String, CodeItem> codeItemsDictionary;
  Map<String, CodeCategory> codeCategoriesDictionary;
  Map<CodeItem, CodeCategory> codeBook;
  
  CodeCabinet codeCabinet; 




  // Constructor  
  
  LVActivity( LiveWave o ) {
    super( o, 0, 0, o.width, o.height ); // maximize window area
    bgColor = color( 255, 255, 255 );    // default bgColor is white

    // does not have a concrete member that extends ActivityUI, 
    // those will be done at the children classes of SpiralActivity and WaveActivity

    dataWholeChunk  ="";
    prevDataWholeChunk = dataWholeChunk;
    lastRequestTime = millis();
    lastIndexReceived = 0;
    baseURLAddress = "";
    hasNewValidDatastream = false;
    onDatastream = true;
    
    codeItemsList = new ArrayList<CodeItem>();
    codeCategoriesList = new ArrayList<CodeCategory>();
    codeItemsDictionary = new HashMap<String, CodeItem>();
    codeCategoriesDictionary = new HashMap<String, CodeCategory>();
    codeBook = new HashMap<CodeItem, CodeCategory>();
    
    codeCabinet = new CodeCabinet();
  } // end constructor
  



  // Methods

  void startLV( String[] aDetails ) {
  // NOTE: aDetails [0] [1] [2] is the database url, startTime and title

    buildCodeCabinet();
    myAjaxObject = new AjaxGETObject();
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
    //dataWholeChunk = myAjaxObject.request.responseText;
    dataWholeChunk = myAjaxObject.grabData();
    if( dataWholeChunk.equals( "" ) == false &&
        dataWholeChunk.equals( prevDataWholeChunk ) == false ) {
      //println( "\t\t\t >>> dataWholeChunk is: " + dataWholeChunk + " . " );
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

    // the polling every 5 seconds:
    int now = millis();
    if( now - lastRequestTime > 5000 ) {
      if( onDatastream ) {
        String s = makeNextURLAddress( baseURLAddress );
        //if( myAjaxObject == null ) {
        //  println( "     >>>>>> Creating new AjaxGETOvbject" );
          myAjaxObject = new AjaxGETObject();
        //}
        connectDB( s );
        lastRequestTime = millis();
      }
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
      //println( "baseURLAddress is now: " + ret );
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
    //println( "BUILDING CODECABINET : " );
    String[] dbGetCodeD = loadStrings( "/getCodeDictionary" );
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
            //println( "\tAdded " + stampObject );
            codeCabinet.codeCategoriesList.add( stampObject );
            codeCabinet.codeCategoriesDictionary.put( codeCatStamp, stampObject );
          }

        } else if( tempPiece.equals( "DESCRIPTOR:" ) ) {
          codeItemStamp = dbCodeDPieces[ i ] [ 1 ];
          //println( dbCodeDPieces[ i ] [1] );
          CodeItem ctemp = null;
          if( codeCatStamp.equals( "UNCATEGORIZED" ) == false ) { // if category is concrete
            ctemp = new CodeItem( stampObject, codeItemStamp );
            //println( "\t\tAdded: " + ctemp );
            codeCabinet.codeBook.put( ctemp, stampObject );
            stampObject.addCodeItem( ctemp );
          } else {
            // dont put in codeBook HashMap coz ctemp's owner is null, 
            // the owner is  NOT an instance of CodeCategory with dispName="UNCATEGORIZED"
            ctemp = new CodeItem( codeItemStamp );
            //println( "\tAdded: " + ctemp ); 
          }
          codeCabinet.codeItemsList.add( ctemp );
          codeCabinet.codeItemsDictionary.put( codeItemStamp, ctemp );
            
        } // end else "DESCRIPTOR:"
      } // end for i
    } // end if got valid data
  
  } // end buildCodeCabinet()



  
  void connectDB( String s ) {
    lastRequestTime = millis();
    //myAjaxObject.request.open( "GET", s + makeNoCache(), true );
    //myAjaxObject.request.send( null );
    myAjaxObject.makeAjaxGet( s + makeNoCache() );
    //println( "connecting to DB @ " + s + makeNoCache() );
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
      //println( "tbCleaned[ " + i + " ] is :"  + tbCleaned[ i ] );
      String[] cells = splitTokens( tbCleaned[ i ], "\t" ); 
      //println( "# cells?:" + cells.length + " * " + 
      //         cells[ 0 ] + " * " +
      //          cells[ 1 ] + " * " +
      //         cells[ 2 ] + " * " +
      //         cells[ 3 ] + " * " +
      //         cells[ 4 ] + " * " +
      //         cells[ 5 ] + " * " +
      //         cells[ 6 ] + " * " +
      //         cells[ 7 ] + " * " +
      //         cells[ 8 ] + ". "
      //       );
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
        String[] cells = splitFixedColumns( tbCleaned[ z ], "\t", 9 );
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

    return cleaned; 
  }  // end cleanRows()
  


  
  String[] splitFixedColumns( String row, String tkn, int colCount ) {
  // returns an array with count of elements equal to colCount
  // any extras will be dropped, any deficiencies will be topped up with epty string
    String[] ret = new String[ colCount ];
    String pcs = splitTokens( row, tkn );
    if( pcs.length >= colCount ) {
      for( int i = 0; i < pcs.length; i ++ )
        ret[ i ] = pcs[ i ];
    } else {
      int toTopUp = colCount - pcs.length;
      int topUpFrom = pcs.length;
      for( int i = 0; i < pcs.length; i++ ) {
        ret[ i ] = pcs[ i ];
      }
      for( int i = 0; i < toTopUp; i++ ) {
        ret[ topUpFrom + i ] = "";
      }
    }
    return ret;
  } // end splitFixedColumns()




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

  


  String chainCodeItems() {
    String ret = "";
      for( int i = 0; i < codeCabinet.codeCategoriesList.size(); i++ ) {
        CodeCategory cc = codeCabinet.codeCategoriesList.get( i );
        for( int j = 0; j < cc.codeItems.size(); j++ ) {
        ret += "," + cc.dispName + ":" + cc.codeItems.get( j ).dispName;
      }
    }
    if( ret.length > 0 ) 
      ret = ret.substring( 1, ret.length );
    return ret;
  } // end chainCodeItems()




  void toggleDatastream( ActivityUI theUI, int indexB ) {
    if( onDatastream ) {
      theUI.arrSpButtons.get( indexB ).label = "PAUSED";
      onDatastream = false;      
    } else {
      theUI.arrSpButtons.get( indexB ).label = "  LIVE  ";
      onDatastream = true;
    }
  } // end toggleDatastream()




  String toString() {
   return( "This is LVActivity, an object of class Activity which is the ancestor for both the Live Spiral and Live Wave viz" ); 
  }

  

  
} // end class LVActivity
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




  CodeCategory getOwner() {
    return owner;
  } // end getOwner()




  String toString() {
    String ret = "CodeItem: " + dispName + "\t" + fullName + "\n";
    return ret;
  } // end toString()




} // end class CodeItem
// Wave Activity's User Interface Class (Extends Class ActivityUI )
// an extension of the ActivityUI class which holds the code for all user
// interactions for the Live Wave Visualizer
// See also: WaveActivity.pde

class WaveUI extends ActivityUI {

  // Fields

  var popUpWindow;



  // Constructor
  WaveUI( WaveActivity o ) {
    super( o, 300, 200, 1150, 650 );
    view.putBgColor( color( 255, 220, 200 ) );
          
    createSpButton( o.x2 - 120, o.y1 + 50, o.x2 - 20, o.y1 + 90, getNextIndexArrSpButtons(), "Choose Code(s)", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createSpButton( o.x1 + 500, o.y1 + 660, o.x1 + 600, o.y1 + 690, getNextIndexArrSpButtons(), "SORT", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createSpButton( o.x1 + 700, o.y1 + 660, o.x1 + 800, o.y1 + 690, getNextIndexArrSpButtons(), "LOAD", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createSpButton( o.x1 + 850, o.y1 + 660, o.x1 + 950, o.y1 + 690, getNextIndexArrSpButtons(), "SAVE", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createSpButton( o.x1 + 200, o.y1 + 660, o.x1 + 300, o.y1 + 690, getNextIndexArrSpButtons(), "VALID EQs", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createSpButton( o.x1 + 350, o.y1 + 660, o.x1 + 450, o.y1 + 690, getNextIndexArrSpButtons(), "  LIVE  ", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

  } // end constructor




  // Methods

  //@Override
    void executeMousePressed() {

    WaveActivity downcasted = ( WaveActivity ) owner;
    Wave currentWave = downcasted.wave;
    if ( mouseButton == LEFT ) {     
      int whichOne = getPressedArrSpButton();
      
      if( whichOne == 0 ) { // "CHOOSE CODES"
//new:url change
        popChooseCode( "/public/jsvizes/wave/choosecode.html", "Choose Codes" );

      } else if( whichOne == 1 ) { // "SORT"
        currentWave.loadSelectedEqs( currentWave.selEqs, currentWave.selValds );
        currentWave.sortBy( currentWave.selEqs, currentWave.selValds );

      } else if( whichOne == 2 )  { // "LOAD"
//new:url change
        popLoadState( "/public/jsvizes/wave/loadstate.html", "Load State" );

      } else if( whichOne == 3 ) { // "SAVE"
//new:url change
        popSaveState( "/public/jsvizes/wave/savestate.html", "Save State" );

      } else if( whichOne == 4 ) { // VALIDITY TOGGLE SWITCH
        currentWave.toggleValidity( this );

      } else if( whichOne == 5 ) { // LIVE-PAUSED TOGGLE SWITCH
        owner.toggleDatastream( this, 5 );
      }
      
           
      processClickedView();
      processClickedWavePoint();
      processClickedDropdown();

    } else if( mouseButton == RIGHT ) {
      WavePt wpMO = owner.wave.getWavePointMouseOver();
//new:url change
      popAnnotate( "/public/jsvizes/wave/annotate.html", "Annotate A Wave Point", wpMO );

    }
  } // end executeMousePressed()




  //@Override
  void executeMouseDragged() {
    processDraggedView();
  } // end executeMouseDragged()




  //@Override
  void update() {
    super.update();
  } // end update()




  //@Override
  void display() {
    super.display();
  } // end display()




  void processClickedWavePoint() {
    WaveActivity downcasted = (WaveActivity) owner;
    String fString = "";

    for(  WavePt wp : downcasted.wave.wavePoints ) {
     if( wp.mouseOver ) {
        fString = wp.funcString;
        ArrayList<String> sel = downcasted.wave.selEqs;
        if( sel.contains( fString ) == false )
          sel.add( fString );
        else
          sel.remove( fString );
        break;
      }
    }

    for( WavePt wp : downcasted.wave.wavePoints ) {
      if( wp.funcString.equals( fString ) )
        wp.isSelected = !wp.isSelected;
     } // end for
 
  } // end processClickedWavePoint()




  void popChooseCode( String fileName, String windowTitle ) {    
    String optionString = "width=300,height=500, menubar=no, toolbar=no,scrollbar=no,location=no,resizable=no";            
    popUpMsg = "CODECHOOSER|" + owner.wave.chainSelCodes();
    popUpWindow = window.open( fileName, windowTitle, optionString );
  } // end popChooseCode()




  void popLoadState( String fileName, String windowTitle ) {
    String optionString = "width=850,height=350, menubar=no, toolbar=no,scrollbar=no,location=no,resizable=no";

	//String retrievedStatesFromDB = loadStrings( "http://" + owner.wave.hostip + "/getWaveStates" ).join( "|" ); 
	//new: remove http and host ip
    String retrievedStatesFromDB = loadStrings( "/getWaveStates" ).join( "|" ); 

    popUpMsg = "LOADSTATE|" + retrievedStatesFromDB;      
    popUpWindow = window.open( fileName, windowTitle, optionString );
  } // end popLoadState()    




  void popSaveState( String fileName, String windowTitle ) {
    String optionString = "width=600,height=350, menubar=no, toolbar=no,scrollbar=no,location=no,resizable=no";
    
    popUpMsg = "SAVESTATE|";
    popUpMsg += owner.wave.actid + "|";
    popUpMsg += owner.wave.stateID + "|";
    popUpMsg += owner.wave.stateName + "|"; 
    popUpMsg += owner.wave.comments;

    popUpWindow = window.open( fileName, windowTitle, optionString );
  } // end popSaveState()




  void popAnnotate( String fileName, String windowTitle, WavePt w ) {
    String optionString = "width=600,height=600, menubar=no, toolbar=no,scrollbar=no,location=no,resizable=no";
    if( w != null ) {
      owner.owner.setAnchoredWpMO( w );
      popUpMsg = "ANNOTATE;" + w.toString() + ";" + owner.chainCodeItems();
      // expected string is: "ANNOTATE;serialNum:9|funcString:sin(x)|...|annotation:onelongannotationstring|codes:VASM,R1,BN;Math:VASM,Math:R1,...,Social:BN"
        
      popUpWindow = window.open( fileName, windowTitle, optionString );
    }
  } // end popAnnotate()
  




} // end class WaveUI
abstract class ActivityUI extends ProtoUI {

  // Fields
  Activity owner;




  // Constructor

  ActivityUI( Activity a ) {
    super();
    owner = a;
  } // end constructor




  ActivityUI( Activity o, float x1v, float y1v, float x2v, float y2v ) {
    super( x1v, y1v, x2v, y2v );
    owner = o;

  } // end constructor



  // Methods




} // end class ActivityUI
// ========================================
// GUI Component Class
// Ancestor class of all ...UI classes 
// ActivityUI stands for "Activity UI". An object of this class is a member of an 
// object of class Activity (or ...Activity). This class is where all the 
// interaction-related code is defined. ( e.g. what happens whe "button A" 
// is clicked ).
// see also: class Activity

abstract class ProtoUI {

  // Fields

  ArrayList<AButton> arrButtons;
  ArrayList<SpButton> arrSpButtons;
  ArrayList<Dropdown> arrDropdowns;
  ArrayList<CheckBox> arrCheckBoxes;
  ArrayList<TextBox> arrTextBoxes;
  int activeTextBox;
  View view;


  

  // Constructor

  ProtoUI () {  // this version of the constructor does NOT have a View object
    arrButtons = new ArrayList();
    arrSpButtons = new ArrayList();
    arrDropdowns = new ArrayList();
    arrCheckBoxes = new ArrayList();
    arrTextBoxes = new ArrayList();
    activeTextBox = -1;
  } // end constructor



  
  ProtoUI( float x1v, float y1v, float x2v, float y2v ) {  // this version of the constructor has a View object
    arrButtons = new ArrayList();
    arrSpButtons = new ArrayList();
    arrDropdowns = new ArrayList();
    arrCheckBoxes = new ArrayList();
    arrTextBoxes = new ArrayList();
    int activeTextBox = -1;
    view = new View( x1v, y1v, x2v, y2v ); 
  } // end constructor



  
  // Methods

  // --------------- //
  // TextBox Methods //
  // --------------- //

  void createTextBox( float x1t, float y1t, float x2t, float y2t, String initString ) {
    arrTextBoxes.add( new TextBox( x1t, y1t, x2t, y2t, initString ) );
  } // end createTextBox()




  void updateActiveTextBox() {
    activeTextBox = getClickedTextBox();  
    if( activeTextBox != -1 ) {
      TextBox tb = arrTextBoxes.get( activeTextBox );
      tb.onFocus = true;
    }
  } // end updateActiveTextBox()




  int getClickedTextBox() {
    int ret = -1;
    if( arrTextBoxes != null )
      for( int i = 0; i < arrTextBoxes.size(); i++ ) {
        TextBox tb = arrTextBoxes.get( i );
        if( tb.over )
          ret = i;
      }
    return ret;
  } // end getClickedTextBox()
  



  // ------------ //
  // View Methods //
  // ------------ //
  
  float[] getViewCoords() {
    float[] vc = new float[ 4 ];
    for( int i = 0; i < vc.length; i++ ) {
      //if( view == null )
      //  vc[ i ] = 0;
      //else {
        if( i == 0 )
          vc[ i ] = view.x1a;
        else if( i == 1 )
          vc[ i ] = view.y1a;
	else if( i == 2 )
	  vc[ i ] = view.x2a;
	else if( i == 3 )
	  vc[ i ] = view.y2a;
      //}
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




  // ---------------- //
  // CheckBox Methods //
  // ---------------- //

  void createCheckBox( float x1c, float y1c, float x2c, float y2c, String caption ) {
    arrCheckBoxes.add( new CheckBox( x1c, y1c, x2c, y2c, caption ) );
  } // end createCheckBox()




  int getNextIndexArrCheckBoxes() {
    if( arrCheckBoxes == null )
      return( 0 );
    else
      return( arrCheckBoxes.size() );
  } // end getNextIndexArrCheckBoxes()




  void toggleClickedCheckBox() {
    if( arrCheckBoxes != null )
      for( CheckBox cb : arrCheckBoxes ) {
        if( cb.over )
          cb.toggle();
      }
  } // end toggleClickedCheckBox()




  int getPressedArrCheckBox() {
    // Returns the index number of an arrCheckBoxes whose status is on pressed
    // Returns -1 if no CheckBoxes are pressed
    int ret = -1;
    if( arrCheckBoxes != null ) {
      for( int i = 0; i < arrCheckBoxes.size(); i++ ) {
        CheckBox cb = arrCheckBoxes.get( i );
        if( cb.toggle() )
          ret = i;
      } // end for
      return ret;
    } else
    return ret;
  } // end getPressedArrCheckBox()

  
  

  
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

      // for CheckBoxes
      if( arrCheckBoxes != null )
        for( CheckBox cb : arrCheckBoxes )
          cb.update();
  
    // For TextBoxes
    if( arrTextBoxes != null )
      for( TextBox tb : arrTextBoxes )
        tb.update();
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

      // For CheckBoxes
      
      if( arrCheckBoxes != null )
        for( CheckBox cb : arrCheckBoxes ) {
          cb.display();
        }
        
    // For TextBoxes
    if( arrTextBoxes != null )
      for( TextBox tb : arrTextBoxes )
        tb.display();

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
    toggleClickedCheckBox();
  } // end executeMouseReleased()




  void executeKeyPressed() {
    if( activeTextBox != -1 && activeTextBox != null )
      arrTextBoxes.get( activeTextBox ).doPressed( key );
  } // end executeKeyPressed()




  abstract String toString();




} // end class ProtoUI
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




} // end class SpButton
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




} // end class AButton
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




} // end class ScrollPosButton// ========================================
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

class Wave extends Section {

  // Fields
  
  ArrayList <Student> students;
  ArrayList <WavePt> wavePoints;
  Ribbon ribbon;





  // The following fields also exist in class Spiral, consider
  // moving them upclass to become members of class Section instead
  Post_Time cExerciseStart, cMaxPostTime, cMinPostTime, cDuration;
  //int maxPostTime, minPostTime;
  String title;
  
  float x, y;
  float maxRad;

  int maxLevel, stepUpWindow, stepDownWindow, resetWindow;
  float rgbPropRate, rgbSmoothRate;

  CodeCabinet codeCabinet;
  ArrayList<String> selCodes;
  String selCodesDisp, selCodesDispPrev;

  ArrayList<String> selEqs;  // to hold selected equations
  ArrayList<Boolean> selValds; // to hold selected validity values

  long actid;
  String hostip; // value is set in WaveActivity.startWave()
  
  String comments;
  String stateName;
  boolean expectNewID;
  long stateID;
  int countValids, countInValids;




  // Constructor

  Wave() {
    super();
    students = new ArrayList();
    wavePoints = new ArrayList();
    
    maxPostTime = 0;
    minPostTime = 10000;
    x = 150;
    y = 400;
    maxRad = 125;

    // properties of the Intensity and Wave coloring
    maxLevel = 20;
    stepUpWindow = 5;
    resetWindow = 15;
    rgbPropRate = 12;
    rgbSmoothRate = rgbPropRate;
    stepDownWindow = resetWindow - stepUpWindow;
    rgbPropRate = ( 255 - 15 ) / maxLevel;
    
    ribbon = new Ribbon( this );
    
    comments = "";
    stateName = "";
    stateID = -1; // -1 means NOT referring to oany states on the database
    expectNewID = true;
    countValids = updateCountValids();
    countInValids = updateCountInValids();
  } // end constructor




  // Methods

  void sproutWave( String tempExerciseStart, String tempExerciseTitle, long id, CodeCabinet cc ) {
  // when run, data is plugged-in and the wave is started / sprouted
    setStartTime( tempExerciseStart );
    setTitle( tempExerciseTitle );
    pdfName = tempExerciseStart + ".pdf";
    cExerciseStart = new Post_Time( 0, tempExerciseStart );
    cMaxPostTime = new Post_Time( 0, tempExerciseStart );
    cMinPostTime = new Post_Time( 0, tempExerciseStart );
    title = tempExerciseTitle;
    actid = id;
    codeCabinet = cc;
    for( CodeItem ci : codeCabinet.codeItemsList )
    selCodes = new ArrayList<String>();
    for( CodeItem ci : codeCabinet.codeItemsList )
      selCodes.add( ci.dispName );
      CodeCategory ccg = codeCabinet.codeCategoriesDictionary.get( "Math" );
      for( CodeItem ci : ccg.codeItems )
        
    selCodesDisp = setSelCodesDisp( selCodes );
    selEqs = new ArrayList<String>();
    selValds = new ArrayList<Boolean>();
    selValds.add( true ); // sets default to show only valid ( true ) equations
  } // end sproutWave()




  void growWave( Table t ) {
  // Needs to be commented and reworked
    int wpCountBefore = wavePoints.size();
    super.populateFuncs( t );
    //println( "Applying Datastream to Wave ... " );
    addStudents( funcs, lastCountForFuncs, minPostTime, maxPostTime, t );
    addWavePoints( funcs, lastCountForFuncs, t );
    int wpCountAfter = wavePoints.size(); 
    updateHasData();
    processWavePoints( wpCountBefore, wpCountAfter );
    ribbon.updateMinsCount();
    markForDisplay( selCodes, selValds );

    loadSelectedEqs( selEqs,selValds );

    sortBy( selEqs, selValds );
  } // end growWave()




  void processWavePoints( int indexPrev, int indexNow ) {
  // Needs to do the following:
  // calculate intensity score for each wavePoint
  // calculate radius distance for each wavePoint
  // link wavePoints to students
  // 
    for( int i = indexPrev; i < indexNow; i++ ) {
      if( i == 0 ) { // processing for the first wavePoint
        WavePt wpNow = wavePoints.get( i );
	wpNow.intensityScore = 1;
        wpNow.updateWaveRad();
        wpNow.updateWaveRadC();
        Student sNow = getStudent( wpNow.student.studentID );
        sNow.wavePoints.add( wpNow );

      } else { // for subsequent wavePoints

        WavePt wpPrev = wavePoints.get( i-1 );
        WavePt wpNow  = wavePoints.get( i );
	int lag = wpNow.postTime - wpPrev.postTime;

	if( lag <= stepUpWindow ) {

	  wpNow.intensityScore = wpPrev.intensityScore + 1; // step it up
	  wpNow.intensityScore = constrain( wpNow.intensityScore, 1, maxLevel ); // make sure its within the range
	  wpNow.updateWaveRad();
          wpNow.updateWaveRadC();
          Student sNow = getStudent( wpNow.student.studentID );
          sNow.wavePoints.add( wpNow );

	} else if( lag > resetWindow ) {

	  wpNow.intensityScore = 1; // if lag too long, reset back to 1
	  wpNow.updateWaveRad();
	  wpNow.updateWaveRadC();
          Student sNow = getStudent( wpNow.student.studentID );
          sNow.wavePoints.add( wpNow );

	} else {

	  wpNow.intensityScore = floor( ( lag - stepUpWindow ) * ( maxLevel / stepDownWindow ) );
	  wpNow.intensityScore = constrain( wpNow.intensityScore, 1, maxLevel );
	  wpNow.updateWaveRad();
          wpNow.waveRadc =color( floor( wpNow.intensityScore * rgbSmoothRate ) + 15 ); // uses rgbSmoothRate instead of rgbPropRate (different from WavePt.updateWaveRadC() )
	  Student sNow = getStudent( wpNow.student.studentID );
          sNow.wavePoints.add( wpNow );
        }
      }	
    } // end for i
  
    for( int j = 0; j < indexPrev; j++ ) {
      WavePt wp = wavePoints.get( j );
      wp.updateWaveRad();
    }
  } // end processWavePoints()




  void addWavePoints( ArrayList <Function> tempFuncs, int tempLastCountForFuncs, Table tempTable ) {
    for( int i = tempLastCountForFuncs; i < tempFuncs.size(); i++ ) {
      Function tf = tempFuncs.get( i );
      wavePoints.add( new WavePt( this, tempTable, i - tempLastCountForFuncs + 1, tf.serialNum ) );
    } // end for i
  } // end addWavePoints()




  void addStudents( ArrayList <Function> tempFuncs, int tempLastCountForFuncs, int tempMinPostTime, int tempMaxPostTime, Table tempTable ) {
  // This will add Student objects to the students ArrayList, using the input of an ArrayList of Function objects
  //
    // go through tempFuncs, check for duplication  
    for( int i = tempLastCountForFuncs; i < tempFuncs.size(); i++ ) {

      Function tf = tempFuncs.get( i );
      int dup = 0;
      int sumDup = 0;
      if( students.size() == 0 ) { // first entry of the students list
        students.add( new Student( tempTable, i + 1, students.size() ) );
      } else {
        for( int j = 0; j < students.size(); j++ ) { // subsequent entry to the spokes list, need to check fo duplication
	  Student std = ( Student ) students.get( j );
	  if( tf.studentID.equals( std.studentID ) ) {
	    dup ++;
	  }
	  sumDup += dup;
	} // end for j
	if( sumDup == 0 ) { // no duplicates found in the current ArrayList of j Student objects
	  students.add( new Student( tempTable, 0 - tempLastCountForFuncs +i + 1, students.size() ) );
	}
      } // end else
    } // end for i

  } // end addStudents()




  void updateHasData() {
    if( wavePoints.size() > 0 )
      hasData = true;
    else
      hasData = false;
    countValids = updateCountValids();
    countInValids = updateCountInValids();
  } // end updateHasData()




  void display( View r ) {
    r.clearBackground();
    r.putTextFont( waveFont, 12 );
    stroke( 0 );
    fill( 90 );
    if( hasData )
      printFunctions( r, selCodes );
    else 
      drawLabel( "No Data For This Class", 30, r, "CENTER" );
    r.repositionScrollPosBtns();
  } // end display()
  
  

  
  void printFunctions( View r, ArrayList<String> sc ) {
  // prints the Function equations which has at least one Code in the 
  // Selected Codes list  on to the View. Hides the rest of the equations.
  // 


  // NOTE : MUST THINK TRHOUGH THE STEPS - SHOULD JUST PUT MARKFORDISPLAY() AND SORTBY() HERE ? IF NOT, HOW WOULD NEW INCOMING DATA BE DISPLAYED WHEN THERE'S A NEW DATASTREAM COMING IN?

    for( Student s : students ) { // bottom layer for drawing contents
      if( s.onShow ) {
        s.display( r, s.dispOrder );
        for( WavePt wp : s.wavePoints ) {
          if( wp.onShow ) {
            wp.display( r, wp.dispOrder );
          }
        }
      }
    }
    for( Student s : students ) { // second layer for drawing mouseOvers
      if( s.onShow )
        if( s.mouseOver )
          s.drawMouseOver( r );
      for( WavePt wp : s.wavePoints ) {
        if( wp.onShow )
          if( wp.mouseOver )
            wp.drawMouseOver( r );
      }
    }
  } // end printFunctions()




  void markForDisplay( ArrayList<String> sc, ArrayList<Boolean> sv ) {
  // this should be called everytime there's a change in the
  // selected Code(s) / Validity(ies) to display, or immediately following
  // incoming of new dataStream()
  
      //println( " >>> selCodes is : " + sc );
      //println( " >>> selValds is : " + sv );
      
      for( Student s : students ) {
        if( s.hasWpSelCodes( selCodes ) || s.hasWpNoCodes() || s.hasWpSelVals( sv ) ) {
          s.onShow = true;
        } else
          s.onShow = false;
         
        // for WavePts, first set all wavePoitns to not onShow, then
        // loop through all wavePoints, looking for valid wavePoints and set onShow
        // then loop through all wavePoints one more time, looking for invalid ones
        
        for( WavePt wp: s.wavePoints )
          wp.onShow = false;       

        if( sv.contains( true ) ) {
          for( WavePt wp : s.wavePoints ) {
            if( wp.isValid && (wp.hasSelCodes( selCodes ) || wp.hasNoCodes()) ) {
              wp.onShow = true;
            }
          } // end for
        } // end if contains true
     
        if( sv.contains( false ) ) {
          for( WavePt wp : s.wavePoints ) {
            if( wp.isValid == false ) {
              wp.onShow = true;
            }
          } // end for wp
        } // end if contains false
      } // end for s 
    //} // end else   
  } // end markForDisplay()




  void sortBy( ArrayList<String> eqs, ArrayList<Boolean> selvals ) {
  // This must be run ONLY AFTER markForDisplay()
  // and following that, AFTER loadSelectedEqs()
  //
    students = sSort( students, new StudentComparator( eqs ) );
    int dispOrder = 1;
    for( int is = 0; is < students.size(); is++ ) {
      Student s = students.get( is );
      if( s.onShow ) {
        s.dispOrder = dispOrder;
        dispOrder++;
      } else
        s.dispOrder = -1;
 
      s.wavePoints = sSort( s.wavePoints, new WavePtComparator( eqs ) );

      for( WavePt wp : s.wavePoints )  // set all eqs not onShow to have dispOrder of -1
        if( wp.onShow == false )
          wp.dispOrder = -1;

      for( int iw = 0; iw < s.wavePoints.size(); iw++ ) { // look for Valid eqs
        WavePt wp = s.wavePoints.get( iw );
        if( wp.isValid && wp.onShow ) {
          wp.dispOrder = dispOrder;
          dispOrder++;
        }  
      } // end for iw

      for( int iw = 0; iw < s.wavePoints.size(); iw++ ) { // look for Invalid eqs
        WavePt wp = s.wavePoints.get( iw );
        if( wp.isValid == false && wp.onShow ) {
          wp.dispOrder = dispOrder;
          dispOrder++;
        }
      } // end for iw

    } // end for is
  } // end sortBy()



  
  void loadSelectedEqs( ArrayList<String> sels, ArrayList<Boolean> selvals ) {
  // this should be called ONLY AFTER markForDisplay()
  // and it should be caled BEFORE sortBy()
    if( selvals.contains( true ) ) { // this only makes sense if we're interested with valid eqs
      if( sels.isEmpty() == false )
        for( WavePt wp: wavePoints ) {
          if( wp.onShow )
            if( sels.contains( wp.funcString ) )
              wp.isSelected = true;
            else
              wp.isSelected = false;
        } // end for 
    } 
  } // end loadSelectedEqs()




  void drawWave( View r ) {
  // draws the Wave plot and the Ribbon / timeline plot
  //
    // draw title
    textSize( 20 );
    float x1Title = ( ( ( width - 300 ) - ( textWidth( exerciseTitle ) ) ) / 2 ) + 300;
    float x2Title = x1Title + textWidth( exerciseTitle );
    float y1Title = 5;
    float y2Title = 30;
    stroke( 0, 255, 0 );
    noFill();
    rect( x1Title - 5, y1Title - 5, x2Title + 5, y2Title + 5 );
        fill( 0, 255, 0 );
    text( exerciseTitle, x1Title, y2Title );
    
    // draw waveplot label
    fill( 0, 255, 0 );
    textSize( 10 );
    text( "Wave Plot:", x - maxRad - 3, y - maxRad - 3 );
    
    if( hasData ) {
      for( WavePt wp : wavePoints ) {
        
        // draw Wave
        
        noFill();
        stroke( wp.waveRadc );
	ellipseMode( RADIUS );
	ellipse( x, y, wp.waveRad, wp.waveRad );
	
        /* draw end of contribution
        if( wp.serialNum == wavePoints.size() - 1 ) {	      
          stroke( 1255, 90, 50 ); // orangey color
          strokeWeight( 1 );
            ellipse( x, y, wp.waveRad + 1, wp.waveRad + 1 );

            line( xOnRibbon + 1, yRibbon - 20, xOnRibbon + 1, yRibbon );
            strokeWeight( 1 );
        }
        */
      } // end for wavePoints
      ribbon.display( r );
      printSelCodesDisp();
      displayCountBox(50, 660);
    }
  } // end drawWave()


  

  void drawLabel( String s, int tSize, View v, String orientation  ) {
  // displays a textbox containing a text in the middle of the View
  // 
      stroke( popUpTxt );
      fill( popUpBkgrd );
      v.putTextSize( tSize );
      
      float lx1 = 0;
      float  lx2 = 0;
      float ly1 = lx1 + textWidth( s );
      float ly2 = ly1 + v.viewTextSize;
      float whiteSpace = 0;

      // right now only have three types of orientation: CENTER / MOUSE and default (all others )
      if( orientation.equals( "CENTER" ) ) {
        whiteSpace = 10;
        lx1 = ( ( ( v.x2-v.x1 ) - textWidth( s ) ) / 2 ) - whiteSpace;
	lx2 = lx1 + textWidth( s ) + 2*whiteSpace;
        ly1 = ( ((v.y2-v.y1) - v.viewTextSize ) / 2) - whiteSpace;      
	ly2 = ly1 + v.viewTextSize + 2*whiteSpace;
	
      } else if( orientation.equals( "MOUSE" ) ) {
        whiteSpace = 5;
        lx1 = (mouseX - v.x1a) - ( textWidth( s ) / 2 ) - whiteSpace;
        lx2 = lx1 + textWidth(s) + 2*whiteSpace;
        ly1 = ( ((mouseY - v.y1a) - v.viewTextSize )) - 5 - whiteSpace;      
        ly2 = ly1 + v.viewTextSize + 2*whiteSpace;
      }
      rectMode( CORNERS );
      v.putRect( lx1, ly1, lx2, ly2 );
      fill( popUpTxt );
      v.putText( s, lx1 + whiteSpace, ly2 - whiteSpace );
  } // end drawLabel()




  Student getStudent( String sID ) {
  // returns a reference to object of class Student which has sID as
  // its studentID
  //
    Student ret = null;
    for( Student sdt : students )
      if( sdt.studentID.equals(sID) ) {
        ret = sdt;
        break;
      }
    return ret;
  } // end getStudent()



  WavePt getWavePointMouseOver() {
  // returns WavePt object on top of which the mouse pointer is at
  // returns null if no such WavePt exists
    WavePt ret = null;
    for( WavePt wp : wavePoints ) {
      if( wp.mouseOver ) {
        ret = wp;
	break;
      }
    }
    return ret;
  } // end getWavePointMouseOver()




  String setSelCodesDisp( ArrayList<String> input ) {
    String ret = "";
    for( String s : input )
      ret += s + "   ";
    return ret;
  } // end setSelCodesDisp()




  void printSelCodesDisp() {
    fill( popUpTxt );
    textSize( 12 );
    text( "Showing :      " + setSelCodesDisp( selCodes ), 300, 80  );
  } // end printSelCodesDisp()
  
  
  
  
  int updateCountValids() {
    int ret = 0;
    for( WavePt wp : wavePoints )
      if( wp.isValid == true )
        ret++;
    return ret;
  } // end updateCountValids()
  
  
  
  
  int updateCountInValids() {
    int ret = 0;
    for( WavePt wp : wavePoints )
      if( wp.isValid == false )
        ret++;
    return ret;  
  } // end updateCountInValids()



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
      
    
    
    

  ArrayList sSort( ArrayList sList, SComparator compr ) {
    ArrayList ret = new ArrayList();
    if( sList.size() == 0 ) {
      ret = sList;
      return ret;
    } else {
      Object piv = sList.get( 0 );
      sList.remove( 0 );
      ArrayList lowerPart = sSort( divideSList( 0, piv, sList, compr ), compr );
      ArrayList upperPart = sSort( divideSList( 1, piv, sList, compr ), compr );
      for( Object slp : lowerPart )
        ret.add( slp ); 
      ret.add( piv );
      for( Object sup : upperPart )
        ret.add( sup );
      return ret;
    }
  } // end sSort()




  ArrayList divideSList( int direction, Object comp1, ArrayList someList, Comparator comparator ) {
    ArrayList ret2 = new ArrayList();
    if( someList.size() != 0 ) {
      if( direction == 0 ) {
        for( Object comp2 : someList ) {
          //println( comp2.toString() + "compared to " + comp1.toString() + " yields : " + comparator.compare( comp2, comp1 ) );
          if( comparator.compare( comp2, comp1 ) <= 0 )
            ret2.add( comp2 );
        }
      } else {
        for( Object comp2 : someList ) {
          //println( comp2.toString() + "compared to " + comp1.toString() + " yields : " + comparator.compare( comp2, comp1 ) );
          if( comparator.compare( comp2, comp1 ) > 0 )
            ret2.add( comp2 );
        }
      }
    return ret2;
    }
    return ret2;
  } // end divideSList()




  String chainSelCodes() {
    String ret = "";
    for( CodeCategory ccat : codeCabinet.codeCategoriesList ) {
      for( CodeItem ci : ccat.codeItems ) {
        ret += "|";
        String aLine = ccat.dispName + "," + ci.dispName + ",";
        if( selCodes.contains( ci.dispName ) )
          aLine += "selected";
        else
          aLine += "notSelected";
        ret += aLine;
      }
    }
    if( ret.length > 0 )
      ret = ret.substring( 1, ret.length );
    return ret;
  } // end chainSelCodes()




  String consolidateCodesToString( ArrayList<String> sc ) {
    String ret = "";
    for( String s : sc ) {
      if( s === "" )
        alert( "We got a blank element in the selCodes ArrayList!" );
      else {
        ret += prepCode( s ) + "|";
      }
    }
    ret = ret.substring( 0, ret.length - 1 );
    return ret;
  } // end consolidateWpCodes()




  String prepCode( String citem ) {
    CodeItem tempCI = codeCabinet.codeItemsDictionary.get( citem );
    return( tempCI.owner.dispName + ":" + citem  );
  } // end prepCode()




  String consolidateToString( ArrayList<String> ss ) {
    String ret = "";
    for( String s : ss ) {
      ret += s + "|";  
    }
    ret = ret.substring( 0, ret.length - 1 );
    return ret;
  } // end consolidateToString()




  void setStateID( long newID ) {
    this.stateID = newID;
    //println( stateID );
  } // end setStateID()




  void setStateName( String s ) {
    stateName = s;
  } // end setStateName()




  void setComments( String s ) {
    comments = s;
  } // end setComments()




  long getStateID() {
    return this.stateID  ;
  } // end getStateID()




  String getHostip() {
    return hostip;
  } // end getHostip()




  void toggleValidity( WaveUI theUI ) {
    if( selValds.contains( true ) && selValds.contains( false ) ) {
      selValds.remove( false );
      theUI.arrSpButtons.get( 4 ).label = "VALID EQs";
    } else if( selValds.contains( true ) && selValds.size() == 1 ) {
      selValds.remove( true );
      selValds.add( false );
      theUI.arrSpButtons.get( 4 ).label = "INVALID EQs";
    } else if( selValds.contains( false ) && selValds.size() == 1 ) {
      selValds.add( true );
      theUI.arrSpButtons.get( 4 ).label = "Vs & IVs";
    }
    theUI.arrSpButtons.get( 4 ).display();
    updateValidity( selEqs, selValds );
  } // end toggleValidity()



  void setValidity( int validityCode, WaveUI theUI ) {
    ArrayList<Boolean> newValds = new ArrayList<Boolean>();
    if( validityCode == 1 ) {
      newValds.add( true );
      theUI.arrSpButtons.get( 4 ).label = "VALID EQs";
    } else if( validityCode == 2 ) {
      newValds.add( false );
      theUI.arrSpButtons.get( 4 ).label = "INVALID EQs";
    } else if( validityCode == 3 ) {
      newValds.add( true );
      newValds.add( false );
      theUI.arrSpButtons.get( 4 ).label = "Vs & IVs";;
    }
    if( newValds.size() > 0 ) {
      selValds = newValds;
      theUI.arrSpButtons.get( 4 ).display();
    }
    updateValidity( selEqs, selValds );
  } // end setValidity()




  void updateValidity( ArrayList<String> sEqs, ArrayList<String> sValds ) {
    markForDisplay( sEqs, sValds );
    loadSelectedEqs( sEqs, sValds );
    sortBy( sEqs, sValds );
  } // end updateValidity()




  int getValidityCode() {
    if( selValds.contains( true ) && selValds.contains( false ) )
      return 3;
    else if( selValds.contains( true ) && selValds.size() == 1 )
      return 1;
    else if( selValds.contains( false ) && selValds.size() == 1 )
      return 2; 
  } // end getValidityCode()



    
} // end class Wave
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
    //print( "populating funcs with Datastream ... " );
    for( int i = 1; i < t.getRowCount(); i++ )
      funcs.add( new Function ( t, i, getFuncsCount() ) );
    updateHasData();
    updateMinMaxPostTime();
    //println( "funcs count is now: " + funcs.size() + " maxPostTime is now: " + maxPostTime + " [ DONE ]..." );

    //println( "\t \t PRINTING FUNCTIONS: " );
    //for( int i = 0; i < funcs.size(); i++ ) {
    //  Function f = (Function) funcs.get( i );
    //  println( "\t \t " + f.serialNum + " " + f.funcString );
    //} 
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
class WavePt extends Function {

  // Fields

  int dispOrder;
  float intensityScore, waveRad, x, y;
  color waveRadc;
  Student student;
  Wave owner;
  String annotation;
  ArrayList <CodeItem> codes;
  float x1InView, y1InView, x2InView, y2InView;  // the "Screen" x and y values when it is being rendered inside a scrollable View
  boolean isSelected;
  boolean mouseOver;
  boolean onShow;
  int sortingIndex;




  // Constructor
  WavePt( Wave o, Table t, int row, int tempSN ) {
    // WavePoints are created after Wave is created
    // example OUTPUT:      -- NOTE: May change following implementation of "assessor"
  // 103 [student20]   Y1  2x+3x+2x+3x-x-x   UNASSESSED   VASM|MT   annotation1|ann2
    //
    super( t, row, tempSN );
    owner = o;
    //println( "codes and annots are: " + t.getString( row, 7 ) + " " +  t.getString( row, 8 ) );
    readCodes( t, row, 7);
    readAnnotation( t, row, 8 );
    student = owner.getStudent( studentID );
    isSelected = false;
    mouseOver = false;
    //annotation = "";
    intensityScore = 0;
    x = o.x;
    y = o.y;
    onShow = true;
  } // end constructor



  // Methods

  void readCodes( Table t, int r, int c ) {
    codes = new ArrayList <CodeItem>();
    String[] largePieces = splitTokens( t.getString( r, c ), "|" );
    if( largePieces.length > 0 ) 
      for( String p : largePieces ){
        String[] smallPieces = splitTokens( p, ":" );
        CodeItem ci = owner.codeCabinet.codeItemsDictionary.get( smallPieces[ 1 ] );
        if ( ci )
        { codes.add( ci ); }
      } 
  } // end readCodes()




  void readAnnotation( Table t, int r, int c ) {
      annotation = "";
      String[] pieces = splitTokens( t.getString( r, c ), "|" );
      if( pieces.length > 0 )
        annotation = pieces[ 0 ];
        if( pieces.length > 1 )
          for( int i = 1; i < pieces.length; i++ ) {
            annotation += ( "\n" + pieces[ i ] );
          }
  } // end readAnnotation()




  void updateWaveRad() {
    // calculates the radius for this wavePoint, by mapping
    // its postTime from range of owner.minPostTime ~ owner.maxPostTime
    // to range of 0 ~ owner.maxRad  
    // 
    waveRad = map( postTime, 0, owner.maxPostTime, 0, owner.maxRad );
  } // end updateWaveRad()




  void updateWaveRadC() {
    waveRadc = color( floor( intensityScore * owner.rgbPropRate ) + 15 ); // color range is from 15 to 255 NEED TO CONFIRM
  } // end updateWaveRadC()




  void display( View v, float printPos ) {
    if( dispOrder != -1 ) {
      fill( 0 );
      v.putTextFont( waveFont, 12 );
      float x2Scr = map( postTime, 0, owner.ribbon.maxMins*60, owner.ribbon.x, owner.ribbon.x+owner.ribbon.maxMins*owner.ribbon.oneMinLength ) - owner.ribbon.x + owner.ribbon.viewPrintOffset;
      float x1Scr = x2Scr - textWidth( funcString ) - 4;
      float y2Scr = printPos * 15;
      float y1Scr = y2Scr - v.viewTextSize;
      stroke( 255, 90, 50 ); // orangey color for Live mode, can't assess for Hit/No-Hit
      strokeWeight( 3 );

      v.putLine( x2Scr, y1Scr, x2Scr, y2Scr );

      strokeWeight( 1 );

      if( isValid == false ) {
        stroke( 255, 80, 80, 150 );
        fill( 255, 80, 80, 150 );
        rectMode(CORNERS);
        v.putRect( x1Scr, y1Scr, x2Scr, y2Scr );
      }
 
      stroke( 0, 0, 0 );
      fill( 0, 0, 0 );
      v.putText( funcString, x1Scr, y2Scr );
      setCoordsInView( x1Scr, y1Scr, x2Scr, y2Scr );
      updateMouseOver( v );
      if( isSelected )
        drawSelected( v, funcString );
    }
  } // end display()




  void hide( View v ) {
    setCoordsInView( -1, -1, -1, -1 );
    updateMouseOver( v );
  } // end hide()




  void setCoordsInView( float x1Val, float y1Val, float x2Val, float y2Val ) {
    // This will set the InView coordinate values
    // 
    x1InView = x1Val;
    y1InView = y1Val;
    x2InView = x2Val;
    y2InView = y2Val;
  } // end updateCoordsInView()




  void updateMouseOver( View v ) {
    if ( v.mouseWithin && mouseX > x1InView + v.x1a - v.xScrollPos1 && mouseX < x2InView + v.x1a - v.xScrollPos1 && mouseY > y1InView + v.y1a - v.yScrollPos1 && mouseY < y2InView + v.y1a - v.yScrollPos1) {
      mouseOver = true;
      //fill( 0, 0,0, 128 );
      //rect( x1InView + v.x1a - v.xScrollPos1, y1InView + v.y1a - v.yScrollPos1,x2InView + v.x1a - v.xScrollPos1, y2InView + v.y1a - v.yScrollPos1);
    }
    else
      mouseOver = false;
  }  // end updateMouseOver()




  void drawSelected( View v, String s ) {
    int depth = 120;
    float stepWidth = textWidth( s ) / 12;
    // put gradually changing transparent color on the background of the equation  
    for( int i = 0; i <= 10; i++ ) { // there are 10 steps
      fill( 255, 90, 50, depth ); // orangey
      stroke( 255, 90, 50, depth );
      v.putRect( x2InView-4-( i*stepWidth ), y1InView, x2InView-4-( (i+1)*stepWidth )+1, y2InView );
      depth = depth - 12;
    }      
  } // end drawSelected()




  void drawMouseOver( View v ) {
    String dispCodes = "          ";
    for( CodeItem ci : codes ){
      if( ci != null && ci.dispName != null )
        dispCodes = dispCodes + ci.dispName + "     ";
    }
    String s1 = funcString + dispCodes;
    String s2 = student.studentID + "    @ " + cPostTime;
    String s3 = annotation;
    v.putTextSize( 20 );
    float[] textWidths = new float[ 3 ];
    textWidths[ 0 ] = textWidth( s1 );
    textWidths[ 1 ] = textWidth( s2 );
    textWidths[ 2 ] = textWidth( s3 );
    float maxText = max( textWidths );
    stroke( popUpTxt );
    fill( popUpBkgrd );
    float whiteSpace = 5;
    float rowCount = 3;
    float lx1 = ( (mouseX - v.x1a) - (maxText/2) - whiteSpace ) +v.xScrollPos1;
    float lx2 = lx1 + maxText + 2*whiteSpace;
    float ly1 = ( (mouseY-v.y1a) - (rowCount*v.viewTextSize) - whiteSpace - 5 ) + v.yScrollPos1;
    float ly2 = ly1 + rowCount*v.viewTextSize + 3*whiteSpace;

    // make sure mouseOver box will be displayd inside the View
    if( lx1 < v.xScrollPos1 ) {
      float lWidth = lx2 - lx1;
      lx1 = v.xScrollPos1 + 20;
      lx2 = lx1 + lWidth; 
    } else if( lx2 > v.xScrollPos2 ) {
      float lWidth = lx2 - lx1;
      lx2 = v.xScrollPos2 - 20;
      lx1 = lx2 - lWidth;
    }
    if( ly1 < v.yScrollPos1 ) {
      float lHeight = ly2 - ly1;
      ly1 = v.yScrollPos1 + 20;
      ly2 = ly1 + lHeight;
    } else if( ly2 > v.yScrollPos2 ) {
      float lHeight = ly2 - ly1;
      ly2 = v.yScrollPos2 - 20;
      ly1 = ly2 - lHeight;
    }

    rectMode( CORNERS );
    v.putRect( lx1, ly1, lx2, ly2 );
    fill( popUpTxt );
    v.putText( s1, lx1+whiteSpace, (ly1+v.viewTextSize) );
    v.putTextSize( 12 );
    v.putText( student.studentID + "    @ " + cPostTime, lx1+whiteSpace, ly1+4*v.viewTextSize );
    v.putTextSize( 20 );
    v.putText( annotation, lx1+whiteSpace, ly2-whiteSpace );
  } // end drawMouseOver()
  

  

  boolean hasSelCodes( ArrayList<String> input ) {
    boolean ret = false;
    if( codes.isEmpty() ) {
      return ret;
    } else {
      for( CodeItem ci : codes ) {
        if( input.contains( ci.dispName ) )
          ret = true;
      }
      return ret;
    }
  } // end hasSelCodes()



  boolean hasNoCodes() {
    if( codes.isEmpty() ) {
      return true;
    } else {
      return false;
    }  
  } // end hasNoCodes()



  String chainWavePtCodes(){
    String ret = "";
    if( codes.size() > 0 ) {
      for( CodeItem ci : codes )
        ret += "," + ci.dispName;
      ret = ret.substring( 1, ret.length );
    }
    return ret;
  } // end chainWavePtCodes()




  void setAnnotation( String msg ) {
    annotation = msg;
  } // end setAnnotation()




  void postAnnotation() {
    // These are Javascript code enclosed in a Processing function
    var postData = "sessionId=" + owner.actid + "&";
    postData += "sequence=" + serialNum + "&";
    postData += "annotations=" + annotation;

    postAjaxObject = new AjaxPOSTObject();
    
	//new: remove http and host ip
	postAjaxObject.makeAjaxPost( "/setAnnotationsForContribution", postData );
	//postAjaxObject.makeAjaxPost( "http://" + owner.hostip + "/setAnnotationsForContribution", postData );

  } // end postAnnotation()




  void setCodes( String chainedCodeItems ) {
    String[] tempCodes = splitTokens( chainedCodeItems, "," );
    codes = new ArrayList<CodeItem>();
    for( String s : tempCodes ) {
      CodeItem ci = owner.codeCabinet.codeItemsDictionary.get( s );

//new -- null check.
     if ( ci )
     { codes.add( ci ); }
    }
  } // end setCodes()




  void postCodes() {
    String packedCodes = "";
    for( CodeItem ci : codes ) {
      if( ci.dispName != "" ) {
        packedCodes += ci.owner.dispName + ":" + ci.dispName + "|";
      }
    }
    packedCodes = packedCodes.substring( 0, packedCodes.length - 1 );
    
    var postData = "sessionId=" + owner.actid + "&";
    postData += "sequence=" + serialNum + "&";
    postData += "codings=" + packedCodes;
    postAjaxObject = new AjaxPOSTObject();
    //postAjaxObject.makeAjaxPost( "http://" + owner.hostip + "/setCodingsForContribution", postData );
	//new: remove http and host ip
	postAjaxObject.makeAjaxPost( "/setCodingsForContribution", postData );
  } // end postCodes()




  String toString(){
    return super.toString() + "annotation:" + annotation + "|codes:" + chainWavePtCodes();
  } // end toString()



  
} // end class WavePt
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
    ret += "serialNum:" + serialNum + "|";
    ret += "cPostTime:" + cPostTime.getPost_Time_Mins() + "|";
    ret += "studentID:" + studentID + "|";
    ret += "funcString:" + funcString + "|";
    ret += "isValid:" + isValid + "|";
    return ret; 
  } // end toString method




} // end class Function
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
      String[] pieces = splitFixedColumns( rows[ i ], "\t", 9  );
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




  String[] splitFixedColumns( String row, String tkn, int colCount ) {
  // returns an array with count of elements equal to colCount
  // any extras will be dropped, any deficiencies will be topped up with epty string
    String[] ret = new String[ colCount ];
    String pcs = splitTokens( row, tkn );
    if( pcs.length >= colCount ) {
      for( int i = 0; i < pcs.length; i ++ )
        ret[ i ] = pcs[ i ];
    } else {
      int toTopUp = colCount - pcs.length;
      int topUpFrom = pcs.length;
      for( int i = 0; i < pcs.length; i++ ) {
        ret[ i ] = pcs[ i ];
      }
      for( int i = 0; i < toTopUp; i++ ) {
        ret[ topUpFrom + i ] = "";
      }
    }
    return ret;
  } // end splitFixedColumns()




} // end class Table
// belongs to Wave Visualizer

class Ribbon {

  // Fields
  
  Wave owner;
  View view;
  float x, y, x1OnShow, x2OnShow, oneMinLength, maxMins, maxLength, depthOffset, viewPrintOffset;
  int minsCount;
  float x1TArea, y1TArea, x2TArea, y2TArea, xTPos; // the coordinates of the Thread positioner 



  // Constructor
  Ribbon( Wave o ) {
    owner = o;
    oneMinLength = 60;
    maxMins = 11;
    maxLength = 720;
    depthOffset = 50;
    viewPrintOffset = 100; // needed so contribs plotted and ribbon points correctly allign. This is basically the value of the "Western Border" of the View
    x = 300 + depthOffset + viewPrintOffset ;
    y = 150;
    minsCount = ceil( owner.maxPostTime / 60 );
    
    x1TArea = x;
    y1TArea = y - 50;
    x2TArea = x1TArea + maxLength;
    y2TArea = y;
    updateTPos(); // xTPos is set within this method
  } // end constructor




  // Methods

  void display( View view ) {
    updateMinsCount();
    drawAxes( view );
    drawRibbon( view );
    drawTArea( view );
  } // end display()




  void updateMinsCount() {
    minsCount = ceil( owner.maxPostTime / 60 );
    if( minsCount > maxMins ) {
      maxMins = minsCount;
      oneMinLength = ( 720 - 60 ) / maxMins; // one min ( 60 secs is for decorative purpose only 
    }
  } // end updateMinsCount()




  void drawAxes( View view ) {
  // draw ribbon axes
    fill( 0, 255, 0 );
    textSize( 10 );
    text( "Timeline (mins) :", x, y - 40 - 3 );
   
    // the three axes
    stroke( 0, 255, 0 );
    line( x, y, x + maxLength, y );
    line( x, y, x, y-50 );
    line( x, y, x - depthOffset, y + depthOffset );
    
    // draw notches
    int notch = 1;
    float xnotch = x;
    while( notch < ceil( maxLength / oneMinLength ) ) {
      xnotch = ( notch * oneMinLength ) + x;
      float notchHeight = 15;
      if( notch != 0 && notch %5 == 0 )
        notchHeight = 30;
      stroke( 0, 255, 0 );
      line( xnotch, y, xnotch, y-notchHeight );
      fill( 0, 255, 0 );
      textSize( 10 );
      text( notch, xnotch - 3, y - 3 - notchHeight   );
      notch++;
    }
  } // end drawAxes()




  void drawRibbon( View view ) {
    for( WavePt rwp : owner.wavePoints ) {
        stroke( rwp.waveRadc );
        float pointOnRibbon = map( rwp.postTime, 0, maxMins*60, x, x+maxMins*oneMinLength );
	line( pointOnRibbon, y, pointOnRibbon-depthOffset, y+depthOffset );
    }
    // draw ending line
      stroke( 255, 90, 50 ); // orangey color
      float endingPointOnRibbon = map( owner.maxPostTime, 0, maxMins*60, x,x + maxMins*oneMinLength  ) + 1;
      line( endingPointOnRibbon, y, endingPointOnRibbon - depthOffset, y + depthOffset );
      line( endingPointOnRibbon, y, endingPointOnRibbon, y - 37 );
      fill( 255, 90, 50 );
      textSize( 10 );
      text( "end", endingPointOnRibbon - 10, y - 40 );
  } // end drawRibbon()


  
  
  void drawTArea( View v ) {
    updateTPos();
    if( xTPos  != -1 ) {
      stroke( 255, 0, 255 ); // purple color
      strokeWeight( 1 );
      line( x + xTPos, y1TArea, x + xTPos, y );
      line( x + xTPos - depthOffset, y+ depthOffset, x + xTPos, y ); 
    }
  } // end drawTArea()
  
  
  
  
  void drawThreadInView( View v ) {
  // draws the portion of the thread that's inside the View
  // This can not be combined into drawTArea because it belongs to
  // drawing that should be done WITHIN the view ( and which is called from
  // Activity.render() instead of Activity.prerender() ). This is due to the 
  // MASKING step done before render()
  //
    stroke( 255, 0, 255 ); // purple
    if( xTPos != -1 ) {
      strokeWeight( 1 );
      v.putLine( viewPrintOffset + xTPos, 0, viewPrintOffset + xTPos, v.contentHeight );
    }
  } // end drawThreadInView()
  
  
  
  
  void updateTPos() {
  // updates the position of the Thread Indicator (along the timeline)
  // sets xTPos to -1 if mouse pointer is outside of the Thread Area
  //
    if( mouseX >= x1TArea && mouseX <= x2TArea && mouseY >= y1TArea && mouseY <= y2TArea )
      xTPos = mouseX - x;
    else if( mouseX >= x1TArea-(mouseY-y2TArea) && 
             mouseX <= x2TArea-(mouseY-y2TArea) && 
             mouseY > y2TArea && mouseY <= y2TArea + depthOffset ) {
      xTPos = mouseX - x + ( mouseY-y2TArea );
    } else 
      xTPos = -1;
  } // end updateTPos()

} // end class Ribbon
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
class Student {

  // Fields

  String studentID;
  ArrayList <WavePt> wavePoints;
  int serialNum, dispOrder;
  float x1InView, y1InView, x2InView, y2InView;
  boolean mouseOver;
  boolean onShow;
  int sortingIndex;


;



  // Constructor

  Student( Table t, int row, int sn ) {
    serialNum = sn;
    dispOrder = serialNum;
    studentID = t.getString( row, 3 );
    wavePoints = new ArrayList(); 
    // wavePoints are NOT added here, 
    // but via Wave.addWavePoints() instead.
    x1InView = -1;
    y1InView = -1;
    x2InView = -1;
    y2InView = -1;
    mouseOver = false;
    onShow = true;
    sortingIndex = dispOrder;
  } // end constructor


  
  // Methods

  void display( View v, int printPos ) {
    if( dispOrder != -1 ) {
      float whiteSpace = 10;
      v.putTextFont( waveFont, 15 );
      x1InView = whiteSpace;
      x2InView = x1InView + textWidth( studentID );
      y2InView = printPos * 15; // NOTE: assuming row height is 15 pixels per row
      y1InView = y2InView - v.viewTextSize;
      fill( 0 );
      v.putText( studentID, x1InView, y2InView );

      updateMouseOver( v );
    }
  } // end display()




  void updateMouseOver( View v ) {
    if( v.mouseWithin && mouseX >= x1InView + v.x1a - v.xScrollPos1 && mouseX <= x2InView + v.x1a - v.xScrollPos1 && mouseY >= y1InView + v.y1a - v.yScrollPos1 && mouseY <= y2InView + v.y1a - v.yScrollPos1 )
      mouseOver = true;
    else
      mouseOver = false;
  } // end updateMouseOver()




  void drawMouseOver( View v ) {
    String s1 = studentID + "          Contributions:";
    String s2 = ( "Count   : " + wavePoints.size() );
    String s3 = ( "First @ : " + wavePoints.get( 0 ).cPostTime );
    String s4 = ( "Last @  : " + wavePoints.get( wavePoints.size() - 1 ).cPostTime );
    v.putTextSize( 20 );
    float[] tWidths = { textWidth(s1), textWidth(s2), textWidth(s3), textWidth(s4) };
    float tWidth = max( tWidths );
    float whiteSpace = 5;
    float lx1 = ( (mouseX-v.x1a) - (tWidth*0) - whiteSpace) + v.xScrollPos1;
    float lx2 = lx1 + tWidth + (2*whiteSpace);
    float ly1 = ( (mouseY-v.y1a) - (4*v.viewTextSize) - whiteSpace - 5 ) + v.yScrollPos1;
    float ly2 = ly1 + (4*v.viewTextSize) + (2*whiteSpace);
    
    // make sure mouseOver box will be displayd inside the View
    if( lx1 < v.xScrollPos1 ) {
      float lWidth = lx2 - lx1;
      lx1 = v.xScrollPos1 + 20;
      lx2 = lx1 + lWidth; 
    } else if( lx2 > v.xScrollPos2 ) {
      float lWidth = lx2 - lx1;
      lx2 = v.xScrollPos2 - 20;
      lx1 = lx2 - lWidth;
    }
    if( ly1 < v.yScrollPos1 ) {
      float lHeight = ly2 - ly1;
      ly1 = v.yScrollPos1 + 20;
      ly2 = ly1 + lHeight;
    } else if( ly2 > v.yScrollPos2 ) {
      float lHeight = ly2 - ly1;
      ly2 = v.yScrollPos2 - 20;
      ly1 = ly2 - lHeight;
    }
    
    rectMode( CORNERS );
    stroke( popUpTxt );
    v.putRect( lx1, ly1, lx2, ly2 );
    fill( popUpTxt );
    v.putText( s1, lx1 + whiteSpace, ly2-whiteSpace-(3*v.viewTextSize) );
    v.putText( s2, lx1 + whiteSpace, ly2-whiteSpace-(2*v.viewTextSize) );
    v.putText( s3, lx1 + whiteSpace, ly2-whiteSpace-(1*v.viewTextSize) );
    v.putText( s4, lx1 + whiteSpace, ly2-whiteSpace-(0*v.viewTextSize) );
  } // end drawMouseOver()




  String getStudentID() {
    return studentID;
  } // end getStudentID()




  Student callFor( String sid ) {
    if( sid.equals( studentID ) )
      return this;
    else
      return null;
  } // end callFor()



  boolean hasFunction( String fString ) {
    for( int i = 0; i < wavePoints.size(); i++ ) {
      WavePt w = wavePoints.get( i );
      if( w.funcString.equals( fString ) ) {
        return true;
      }
    }
    return false;
  } // end hasFunction()




  boolean hasFunction( ArrayList<String> fs ) {
    int numHit = 0;
    for( String fString : fs ) {
      if( hasFunction( fs ) )
        numHit++;  
    }
    if( numHit == 0 )
      return false;
    else
      return true;
  } // end hasFunction()




  int countDisplayedWps() {
    int num = 0;
    for( WavePt wp : wavePoints )
      if( wp.onShow )
        num++;
    return num;
  } // end countDisplayedWps()



  
  int getPostTimeFor( String eq ) {
    if( getWavePoint( eq ) == null )
      return -1;
    else
      return getWavePoint( eq ).postTime;
  } // end getPostTimeFor()



  int getPostTimeFor( ArrayList<String> eqs ) {
    int earliest = 30000;
    for( String eq : eqs )
      if( getPostTimeFor( eq ) <= earliest )
        earliest = getPostTimeFor( eq );
    return earliest;
  } // end getPostTimeFor()




  int getEarliestPostTime() {
    int earliest = 30000;
    if( wavePoints == null || countDisplayedWps() == 0 )
      return -1;
    else {
      for( WavePt wp : wavePoints )
        if( wp.onShow )
          if( wp.postTime <= earliest )
            earliest = wp.postTime;
    }
    return earliest;
  } // end getEarliestPostTime()




  int getEarliestPostTimeForSelEqs( ArrayList<String> sel ) {
    if( sel.isEmpty() == false ) {
      int earliest = 30000;
      for( WavePt wp : wavePoints )
        if( wp.onShow ) 
          if( sel.contains( wp.funcString ) && wp.postTime < earliest )
            earliest = wp.postTime;
      return earliest;
    } else
      return getEarliestPostTime();
  } // end getEarliestPosttimeForSelEqs()




  WavePt getWavePoint( String fString ) {
    for( int i = 0; i < wavePoints.size(); i++ ) {
      WavePt w = wavePoints.get( i );
      if( w.funcString.equals( fString ) ) {
        return w;
      }
    }
    return null;
  } // end getWavePoint()




  void resetOrder() {
    dispOrder = serialNum;
  } // end resetOrder()




  boolean hasWpSelCodes( ArrayList<String> input ) {
    boolean ret = false;
    for( WavePt wp : wavePoints )
      if( wp.hasSelCodes( input ) )
        ret = true;
    return ret;
  } // end hasWpSelCodes()




  boolean hasWpNoCodes() {
    boolean ret = false;
    for( WavePt wp : wavePoints )
      if( wp.hasNoCodes() )
        ret = true;
    return ret;
  } // end hasWpNoCodes()




  boolean hasWpSelVals( ArrayList<Boolean> selvals ) {
    if( selvals.contains( true ) && selvals.contains( false ) )
      return true;
    else if( selvals.contains( true ) && selvals.size() == 1 ) {
      boolean ret = false;
      for( WavePt wp : wavePoints ) {
        if( wp.isValid ) {
          ret = true;
          break;
        }
      }
      return ret;
    } else if( selvals.contains( false ) && selvals.size() == 1 ) {
      boolean ret = false;
      for( WavePt wp : wavePoints ) {
        if( wp.isValid == false ) {
          ret = true;
          break;
        }
      }
      return ret;
    } else 
      return false;
  } // end hasWpSelVals()




  String toString() {
    return( "StudentID : " + studentID + "\tonShow: " + onShow );
  } // end toString()




} // end class Student
class StudentComparator extends SComparator {

 // Fields

 ArrayList<String> eqs;  




  // Constructor

  StudentComparator( ArrayList<String> input ) {
    eqs = new ArrayList<String>();
    eqs = input;
  } // end constructor()



  
  // Methods
  
  int compare( Object o1, Object o2 ) {
    Student s1 = ( Student ) o1;
    Student s2 = ( Student ) o2;
    if( s1.onShow == true && s2.onShow == false )
      return -1;
    if( s2.onShow == true && s1.onShow == false )
      return +1;
    if( s2.countDisplayedWps() == 0 && s1.countDisplayedWps() > 0 )
      return -1;
    if( s2.countDisplayedWps() > 0 && s1.countDisplayedWps() == 0 )
      return +1;
    if( s1.getEarliestPostTimeForSelEqs( eqs ) < s2.getEarliestPostTimeForSelEqs( eqs ) ) {
      //println( s1.studentID + " earliest post time for selected eqs is: " + s1.getEarliestPostTimeForSelEqs(eqs) );
      //println( s2.studentID + " earliest post time for selected eqs is: " + s2.getEarliestPostTimeForSelEqs(eqs) );
      
      return -1;
    }
if( s1.getEarliestPostTimeForSelEqs( eqs ) > s2.getEarliestPostTimeForSelEqs( eqs ) )
      return +1;
    return s1.studentID.compareTo( s2.studentID );
  } // end compare()
} // end class StudentComparator




abstract class SComparator {

  // Fields

  // Constructor

  // Methods

  abstract int compare();
  // to be implemented by the child classes




} // end abstract class SComparator

class WavePtComparator implements Comparator{
  // fields
  ArrayList<String> eqs;

  WavePtComparator( ArrayList<String> input ) {
    super();
    eqs = new ArrayList<String>();
    eqs = input;
  } // end constructor

  int compare( Object o1, Object o2 ) {
    WavePt w1 = ( WavePt ) o1;
    WavePt w2 = ( WavePt ) o2;
    if( w1.onShow == true && w2.onShow == false )
      return -1;
    if( w2.onShow == true && w1.onShow == false )
      return +1;
    if( w1.postTime < w2.postTime )
      return -1;
    if( w1.postTime > w2.postTime )
      return +1;
    return w1.funcString.compareTo( w2.funcString );
  } // end compare()

} // end class WavePtComparator

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
class PopUpTestUI extends ProtoUI {

  // Fields

  PopUpTest owner;




  // Constructor

  PopUpTestUI( PopUpTest o ) {
    super();
    owner = o;

    createSpButton( o.x1 + 100, o.y2 - 40, o.x1 + 200, o.y2 - 10, getNextIndexArrSpButtons(), "Pop!", color( 0, 0, 0 ), color( 180, 180, 180 ), color( 250, 250, 250 ), butPress );

    createCheckBox( o.x1 + 10, o.y2 - 100, o.x1 + 110, o.y2 - 70, "Yeap" );

    createTextBox( o.x1 + 10, o.y1+30, o.x2-10, o.y1 + 200, "Here's some text" );
  }

  

  // Methods

  void executeMousePressed() {
    if( mouseButton == LEFT ) {

      // For SpButtons
      int whichOne = getPressedArrSpButton();

      if( whichOne == 0 ) { // Pop!
        //println( arrTextBoxes.get( 0 ).actualText );
        owner.selfDestruct();
      }

      // For CheckBoxes
      // CheckBoxes handled in the ProtoUI.executeMouseReleased() automatically

      // For TextBoxes
      updateActiveTextBox();
            
    }

  } // end executeMousePressed)(




  void executeMouseDragged() {

  } // end executeMouseDragged()




  void display() {
    super.display();
  } // end display()




} // end class PopUpTestUI



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
