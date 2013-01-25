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
        println( "About to poll database on this address: " + s );
        if( myAjaxObject == null ) {
          myAjaxObject = new AjaxGETObject();
        }
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