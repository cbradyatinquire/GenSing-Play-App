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