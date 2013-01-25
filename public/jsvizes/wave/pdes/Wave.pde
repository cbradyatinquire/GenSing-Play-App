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
    println( "Applying Datastream to Wave ... " );
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
    println( stateID );
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