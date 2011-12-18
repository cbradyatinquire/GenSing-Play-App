package controllers;

import play.*;
import play.mvc.*;

import java.util.*;

import models.*;

public class Application extends Controller {

    public static void index() {
        render();
    }
    
    
    public static void login(String username, String classname ) {
    	
		System.err.println("Received login request for user: " + username + "\n      attempting to enter class: " + classname );

		Classroom croom = Classroom.connect( classname );
		if ( croom == null )
		{
			renderJSON("FAILURE-CLASSROOM -- no classroom: '" + classname + "'");
		}
		else
		{
	    	StudentUser theGuy = StudentUser.connect(username, croom);
	    	if ( theGuy == null )
	    	{
	    		renderJSON("FAILURE-STUDENT -- no student '" + username + "' in class '" + classname + "'");
	    	}
	    	else
	    	{
	    		renderJSON("SUCCESS");
	    	}
		}	
    }
    
    
    public static void logContribution(String username, String classname, String contribution ) {
    	Classroom croom = Classroom.connect( classname );
		if ( croom == null )
		{
			renderJSON("FAILURE-CLASSROOM -- no classroom: '" + classname + "'");
		}
		else
		{
	    	StudentUser theGuy = StudentUser.connect(username, croom);
	    	if ( theGuy == null )
	    	{
	    		renderJSON("FAILURE-STUDENT -- no student '" + username + "' in class '" + classname + "'");
	    	}
	    	else
	    	{
	    		Contribution c = new Contribution(theGuy, "Test Context", contribution );
	    		c.save();
	    		renderJSON("Received contribution from user: " + username + ":" + classname +  "\nContents: " + contribution + 
	    				"\nNOTE:  THIS IS NOW SAVED IN THE DATABASE!");
	    	}
		}	 
    }
    
    public static void getAllContributions( )
    {
    	List<Contribution> allcontribs = Contribution.find("select c from Contribution c order by c.timestamp").fetch();
    	String reply = "Contributions:\n";
    	if (allcontribs.isEmpty())
    		reply = "NO CONTRIBUTIONS";
    	for ( Contribution c : allcontribs )
    	{
    		reply += c.toString() + "\n";
    	}
    	renderJSON(reply);
    }
    
    public static void execute( String sql )
    {
    	renderJSON( "would send you the result of executing " + sql );
    }

}