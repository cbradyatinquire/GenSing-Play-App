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