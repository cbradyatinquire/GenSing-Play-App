// Fields
 String[] aDetails = new String[ 3 ];
  PFont font; 
  // to match applet params
  String hostip, school, teacher, cnameandcyear, cname, cyear, actid, starttimeFull, starttimeTrimmed, functioncall;



void setup() {
  font = loadFont( "SansSerif.plain-12.vlw" );
  textFont( font, 12 );
  size( 600, 300 );
  
  hostip = param( "hostip" );
  school = param( "school" );
  teacher = param( "teacher" );
  cnameandcyear = param( "cnameandcyear" );
  //String[] cpieces = splitTokens( cnameandcyear, ":" );
  //cname = cpieces[ 0 ];
  //cyear = cpieces[ 1 ];
  actid = param( "actid" );
  starttimeFull = param( "starttime" );
  //starttimeTrimmed = starttimeFull.substring( starttimeFull.length()-17, starttimeFull.length()-9 );
  functioncall = param( "functioncall" );
  
  //aDetails[ 0 ] = "http://" + hostip + "/" + functioncall + "?aid=" + actid + "&ind=0"; // NOTE: must double check this to make sure its correct
  //aDetails[ 0 ] = starttimeTrimmed;  
  //aDetails[ 0 ] = actid + " " + cnameandcyear + " " + school + " " + teacher;  

} // end setup()



void draw() {
  fill( 0 );
  text( "This is a test", 50, 30 );
text( hostip, 50, 50 );
  text( school, 50, 70 );
  text( teacher, 50, 90 );
} // end display()
