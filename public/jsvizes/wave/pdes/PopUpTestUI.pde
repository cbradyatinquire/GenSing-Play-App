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
        println( arrTextBoxes.get( 0 ).actualText );
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