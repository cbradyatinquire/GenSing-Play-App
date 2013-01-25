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
      // expected string is: "ANNOTATE;serialNum:9|funcString:sin(x)|...|annotation:onelongannotationstring|codes:ASMD,R,BN;Math:VASM,Math:R1,...,Social:BN"
        
      popUpWindow = window.open( fileName, windowTitle, optionString );
    }
  } // end popAnnotate()
  




} // end class WaveUI