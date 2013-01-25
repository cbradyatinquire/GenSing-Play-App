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
    println( "processing Databasestream for Wave ... " );
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