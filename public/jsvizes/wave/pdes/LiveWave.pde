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
  println( "pcs.length is: " + pcs.length );
  ArrayList<String> newSelEqs = new ArrayList<String>();
  println( "newSelEqs.size is: " + newSelEqs.size() );
  for( int i = 0; i < pcs.length; i++ ) {
    println( pcs[ i ] );
    newSelEqs.add( pcs[ i ] );
  }
  
  wva.wave.selEqs = newSelEqs;
} // end executeNewSelEqs()




void executeAnnotation( String[] pcs ) {
  println( "annotation executed." );
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
  println( "calling display for the first time..." );
  wva.display();
  println( "end first display" );

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
  println( "end buildNewWva" );
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


