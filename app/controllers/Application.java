package controllers;

import play.*;
import play.mvc.*;

import java.util.*;

import com.sun.org.apache.bcel.internal.generic.Select;

import models.*;

public class Application extends Controller {

    public static void index() {
        render();
    }
        
    
    public static void startActivity( String classname, int classyear, String activityname, String atype ) {
    	String ret = "FAIL";
    	Classroom c = Classroom.connect(classname, classyear);
    	ActivityType at = ActivityType.FUNCTION_ACTIVITY;
    	if ( atype.equals("POINT") )
    		at = ActivityType.POINT;
    	else if ( atype.equals("EQUATION"))
    		at = ActivityType.EQUATION;
    	Activity a = new Activity( c, at );
    	c.setCurrentActivity(a);
    	a.sessionMessage = activityname;
    	a.save();
    	c.save();
    	if ( a != null)
    		ret = "SUCCESS";
    	renderJSON(ret);
    }
    
    public static void nameActivity( String classname, int classyear, String activityname )
    {
    	Classroom c = Classroom.connect(classname, classyear);
    	Activity a = c.getCurrentActivity();
    	//Activity a = Activity.connectCurrent(c);
    	a.sessionMessage = activityname;
    	a.save();
	renderJSON( "Renamed Activity To: " + activityname );
    }
    
    public static void appendAnnotationToActivity( String classname, int classyear, String annotation )
    {
    	Classroom c = Classroom.connect(classname, classyear);
    	Activity a = c.getCurrentActivity();
    	//Activity a = Activity.connectCurrent(c);
    	a.annotation += "\n" + annotation;
    	a.save();
	renderJSON( "Added Annotation: '" + annotation + "' to this activity." );
    }
    
    
    //login with username, classname AND classyear.  COULD have an "open classroom" that allows us to return the classroom object's ID in the JSON...
    public static void login(String username, String classname, int classyear ) {
    	
		System.err.println("Received login request for user: " + username + "\n      attempting to enter class: " + classname + " with classyear = " + classyear);

		 
		Classroom croom = Classroom.connect( classname, classyear );
		
		if ( croom == null )
		{
			renderJSON("FAILURE-CLASSROOM -- no classroom: '" + classname + "' -- or MORE than one (implement classyear");
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
    
    
    public static void logContribution(String stype, String username, String classname, int classyear, String id, String contribution ) {
    	Classroom croom = Classroom.connect( classname, classyear );
		if ( croom == null )
		{
			renderJSON("FAILURE-CLASSROOM -- no classroom: '" + classname + "'");
		}
		else
		{
			//Activity act = Activity.connectCurrent(croom);
			Activity act = croom.getCurrentActivity();
			//THIS COULD BE OPTIMIZED TO CACHE THE CURRENT ACTIVITY (NO DB QUERY)
			if (act == null )
			{
				renderJSON("FAILURE-no current activity");
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
		    		ContributionType ct = ContributionType.POINT;
		    		if ( stype.equals("EQUATION") )
		    			ct = ContributionType.EQUATION;
		    			
		    		Contribution c = new Contribution(ct, theGuy, act, id, contribution );
		    		c.save();
		    		renderJSON("Received contribution from user: " + username + ":" + classname +  "\nContents: " + contribution + 
		    				"\nNOTE:  THIS IS NOW SAVED IN THE DATABASE!");
		    	}
			}
		}	 
    }
    
    //test methods...
    public static void getAllTeachers()
    {
    	List<Teacher> teachers = Teacher.find("select t from Teacher t").fetch();
    	String reply = "Teachers:\n";
    	if (teachers.isEmpty())
    		reply = "NO TEACHERS";
    	for ( Teacher t: teachers)
    	{
    		reply += t.toString() + "\n";
    	}
    	renderJSON( reply );
    }
    
    public static void getAllSchools()
    {
    	List<School> schools = School.find("select s from School s").fetch();
    	String reply = "Schools:\n";
    	if (schools.isEmpty())
    		reply = "NO Schools";
    	for ( School s: schools)
    	{
    		reply += s.toString() + "\n";
    	}
    	renderJSON( reply );
    }
    
    public static void getAllStudents()
    {
    	List<StudentUser> ss = StudentUser.find("select s from StudentUser s").fetch();
    	String reply = "Students:\n";
    	if (ss.isEmpty())
    		reply = "NO Students";
    	for ( StudentUser s: ss)
    	{
    		reply += s.toString() + "\n";
    	}
    	renderJSON( reply );
    }
    
    //with null name argument, this one returns a list
    public static void getAllClassroomsMatching( String cname  )
    {
    	String reply = "NO Matching Classrooms Found";
    	List<Classroom> cs = null;
    	if (cname == null)
    	{
    		cs = Classroom.find( "select c from Classroom c" ).fetch();
    	}
    	else
    	{
    		cs = Classroom.find("select c from Classroom c where c.classname like '"+cname+"' order by c.startYear").fetch();
    	}
    	
    	if (cs != null && cs.size() > 0)
    	{
    		reply = "Matching Classrooms:\n";
    		for ( Classroom c : cs )
    		{
    		
    			reply += "Name=" + c.classname + "; Teacher=" + c.teacher + "; Starting Year=" + c.startYear + "\n";
    		}
    	}
    	renderJSON( reply );
    }
    
    //with null name argument this one puts in "firstperiodmath" -- for testing.
    public static void getAllClassroomsDummy( String cname )
    {
    	if ( cname == null )
    	{
    		cname = "FirstPeriodMath";
    	}
    	String reply = "NO Matching Classrooms Found";
    	List<Classroom> cs = Classroom.find("select c from Classroom c where c.classname like '"+cname+"' order by c.startYear").fetch();
    	if ( cs != null && cs.size() > 0)
    	{
    		reply = "Matching Classroom(s):\n";
	    	for ( Classroom c : cs )
			{
					reply += "Name=" + c.classname + "; Teacher=" + c.teacher + "; Starting Year=" + c.startYear + "\n";
			}
    	}
    	
    	renderJSON( reply );
    }
    
    public static void getAllStudentsInClassroom( String cname, int year )
    {
    	String reply = "NO Matching Classrooms Found";
    	List<Classroom> cs = Classroom.find("select c from Classroom c where c.classname like '"+cname+"'").fetch();
    	for ( Classroom c : cs )
		{
			if ( c.startYear == year )
			{
				int i = 0;
				reply = "Classroom Found:  Name=" + c.classname + "; Year=" + c.startYear + "\n";
				for ( StudentUser s : c.students)
				{
					i++;
					reply += "#" + i + "Username: " + s.username + "\n";
				}
			}
		}
    	renderJSON( reply );
    }
    
    
    /*stupid method -- need to specify classsroom , then get current activity, etc.*/
    public static void getAllContributions( )
    {
    	List<Contribution> allcontribs = Contribution.find("select c from Contribution c order by c.timestamp").fetch();
    	String reply = "Contributions:\n";
    	if (allcontribs.isEmpty())
    		reply = "NO CONTRIBUTIONS";
    	for ( Contribution c : allcontribs )
    	{
    		//reply += c.toString() + "\n";
    		reply += c.toTSVLine() + "\n";
    	}
    	renderJSON(reply);
    }
    
    public static void getContributionsAfterSequenceNumber( String cname, int year, int ind )
    {
    	String reply = "OOPS";
    	Classroom cs = null;
    	cs = Classroom.find("select c from Classroom c where c.classname like '"+cname+"' and c.startYear = "+year).first();
    	if (cs == null)
    		reply = "NO MATCH ON CLASS NAME + YEAR";
    	else
    	{
	    	//Activity a = Activity.connectCurrent(cs);
	    	Activity a = cs.getCurrentActivity();
	    	List<Contribution> afteri = a.getContributionsAfterNumber(ind);
	    	reply = "Contributions:\n";
	    	if (afteri.isEmpty())
	    		reply = "NO CONTRIBUTIONS MATCHING CONDITION";
	    	for ( Contribution c : afteri )
	    	{
	    		//reply += c.toString() + "\n";
	    		reply += c.toTSVLine() + "\n";
	    	}
    	}
    	renderJSON(reply);
    }
    
    public static void execute( String sql )
    {
    	try
    	{
    		List<Object> results = Utilities.executeQuery(sql);
    		String retn = "";
    		for (Object result : results )
    			retn += result.toString();
    		renderJSON( retn );
    	}
    	catch (Exception e )
    	{
    		String reply =  "ERROR in executing query: " + sql + "\n" + e.getMessage();
    		renderJSON( reply);
    	}
    }
    
    
//  public static void login(String username, String classname ) {
//	
//	System.err.println("Received login request for user: " + username + "\n      attempting to enter class: " + classname );
//
//	 
//	Classroom croom = Classroom.connect( classname );
//	
//	if ( croom == null )
//	{
//		renderJSON("FAILURE-CLASSROOM -- no classroom: '" + classname + "' -- or MORE than one (implement classyear");
//	}
//	else
//	{
//    	StudentUser theGuy = StudentUser.connect(username, croom);
//    	if ( theGuy == null )
//    	{
//    		renderJSON("FAILURE-STUDENT -- no student '" + username + "' in class '" + classname + "'");
//    	}
//    	else
//    	{
//    		renderJSON("SUCCESS");
//    	}
//	}	
//}

}
