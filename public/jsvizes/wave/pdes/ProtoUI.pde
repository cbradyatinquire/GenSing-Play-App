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