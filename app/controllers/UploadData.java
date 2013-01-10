package controllers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Vector;


import models.Classroom;
import models.CodeCategory;
import models.CodeDescriptor;
import models.Coding;
import models.Contribution;
import models.ContributionType;
import models.School;
import models.Session;
import models.StudentUser;
import models.Teacher;
import models.Utilities;

import play.mvc.*;

public class UploadData extends Controller {

    public static void index() {
        render();
    }
    
    
    public static void getForm() {
    	render();
    }
    
    public static void fileUpload( File attachment, String sessiondate, boolean istest, String schoolname, String teachername, String classname, int startyear ) {
    	if (istest)
    	{
    		Vector<String> feedback = processTestUpload( attachment, sessiondate, schoolname, teachername, classname, startyear);
    		System.err.println("vector has " + feedback.size() + " elements");
    		testUpload( feedback );
    	}
    	
    	Vector<String> lines = new Vector<String>();
    	Vector<String> contribErrors = new Vector<String>();
    	Vector<Contribution> contributions = new Vector<Contribution>();
    	Vector<StudentUser> newstudents = new Vector<StudentUser>();
    	
    	if ( attachment.canRead() )
    	{
    		//read
    		try {
    			BufferedReader in = new BufferedReader(new FileReader(attachment));
    			String str;
    			String firstLine = in.readLine();
    			if (firstLine == null ) { error( "First Line Null"); }
    			
    			
    			Date thedate = Utilities.dateFromString(sessiondate);
    			if (thedate == null) { error("ERROR: Parsing " + sessiondate + " as Date object failed... " ); }
    			
    			School s = School.connect(schoolname);
    			if (s == null) { error("No school with name " + schoolname + " in database."); }
    			Teacher t= Teacher.connect(teachername, s);
    			if (t==null) { error("No teacher with name " + teachername + " at school " + schoolname + " in database."); }
    			Classroom croom = Classroom.connect(s, t, classname, startyear);
    			if (croom == null){ error("No classroom with School=" + s.toString() + ", Teacher=" + t.toString() + ", Classname="+classname+" and Start Year="+startyear); }
    			
    			Session sess = Session.connect(croom, thedate);
    			if (sess != null){ error("Session already exists with start time of " + sessiondate + "! Possible duplication" ); }
    			
    			Session nsess = new Session(croom, "file: " + attachment.getName() + " uploaded on " + thedate);
    			nsess.startTime = thedate;
    			nsess.save();

    			while ((str = in.readLine()) != null) {
    				lines.add(str);
    				Contribution c = parseForContribution( newstudents, ContributionType.EQUATION, croom, nsess, thedate, str );
    				if (c == null )
    				{
    					contribErrors.add(str);
    				}
    				else
    				{
    					contributions.add( c );
    				}
    			}
    			in.close();
    		} catch (IOException e) {
    			error("Problem reading file");
    		}
    		render(contributions, contribErrors, newstudents );
    	}
    }
    
    public static void testUpload( Vector<String> feedback )
    {
    	render(feedback);
    }
    
    
    public static Vector<String> processTestUpload( File attachment, String sessiondate, String schoolname, String teachername, String classname, int startyear ) {
    	Vector<String> feedback = new Vector<String>();
    	List<StudentUser> studentUsersIn = new ArrayList<StudentUser>();
    	Vector<String> studentsIn = new Vector<String>();
    	final String expectedHeader = "NAME,TIME,Y=,FUNCTION,MATH1,MATH2,MATH3,SOCIAL1,SOCIAL2,SOCIAL3,HIT/NO-HIT,STATUS";
    	final String expectedPointHeader = "NAME,TIME,TYPE,XVAL,YVAL";
    	if ( attachment.canRead() )
    	{
    		//read
    		try {
    			BufferedReader in = new BufferedReader(new FileReader(attachment));
    			String str;
    			String firstLine = in.readLine();
    			if (firstLine == null ) { feedback.add( "First Line Null"); }
    			else 
    			{
    				feedback.add("Header Line of File:");
    				feedback.add("-->>" + firstLine);
    				feedback.add("=====================");
    			}
    			Date thedate = Utilities.dateFromString(sessiondate);
    			if (thedate == null) { feedback.add("ERROR: Parsing " +sessiondate + " as Date object failed... " ); }
    			
    			School s = School.connect(schoolname);
    			if (s == null) { feedback.add("ERROR: No school with name " + schoolname + " in database."); }
    			Teacher t= Teacher.connect(teachername, s);
    			if (t==null) { feedback.add("ERROR: No teacher with name " + teachername + " at school " + schoolname + " in database."); }
    			Classroom croom = Classroom.connect(s, t, classname, startyear);
    			if (croom == null)
    			{ feedback.add("ERROR: No classroom with School=" + schoolname + ", Teacher=" + teachername + ", Classname="+classname+" and Start Year="+startyear); }
    			else  
    			{ 
    				studentUsersIn = croom.students; 
    				for ( StudentUser su : studentUsersIn )
    				{
    					studentsIn.add( su.username );
    				}
    			}
    			
    			Session sess = Session.connect(croom, thedate);
    			if (sess != null){ feedback.add("WARNING: Session already exists with start time of " + sessiondate + "! Possible duplication" ); }
    			
    			String headline = in.readLine();
    			
    			String headfeed = ( "Header line = " + headline);
    			if ( headline.equalsIgnoreCase(expectedHeader) || headline.equalsIgnoreCase(expectedPointHeader) )
    			{
    				headfeed += "  (This matches expected format)";
    				feedback.add(headfeed);
    			}
    			else
    			{
    				feedback.add(headfeed);
    				feedback.add("ERROR: This does NOT match expected format:" + expectedHeader);
    			}
    			feedback.add("+ + + + + + + + + +");
    			int news = 0;
    			int errs = 0;
    			while ((str = in.readLine()) != null) {
    			    String nsuName = getStudentNameFromLine(str);
    			    if ( nsuName == null ) 
    			    { 
    			    	errs++;
    			    	System.err.println("---> Possible issue with line: " + str); 
    			    }
    			    else
    			    {
    			    	if (!studentsIn.contains(nsuName))
    			    	{
    			    		news++;
    			    		studentsIn.add(nsuName);
    			    		System.err.println("New student would be added - username:" + nsuName);
    			    	}
    			    }
    			}
    			feedback.add( errs + " lines not parseable as contributions were found");
    			feedback.add("+ + + + + + + + + +");
    			feedback.add("Students:");
    			feedback.add( news + " new students would be created with this upload");
    			in.close();
    		} catch (IOException e) {
    			feedback.add("Problem reading file");
    		}
    	}    	
    	return(feedback);
    }
   
    private static String getStudentNameFromLine( String aline )
    {
    	String[] fields = aline.split(",");
    	if (fields.length < 4) { return null; }
    	String uname = null;
    	if ( fields[0].startsWith("[") && fields[0].endsWith("]"))
		{
    		uname = fields[0].substring(1,fields[0].length()-1);
		}
    	return uname;
    }
    
    
    
    
//    public static Vector<String> testParseContribution( String aline, Classroom croom )
//    {
//    	Vector<String> feedback = new Vector<String>();
//    	String[] fields = aline.split(",");
//    	if (fields.length < 4) { return feedback; }
//    	
//    	try {
//    		StudentUser su = null;
//    		
//    		if ( fields[1].startsWith("[") && fields[1].endsWith("]"))
//    		{
//    			String uname = fields[1].substring(1,fields[1].length()-1);
//    			if ( croom == null)
//    				feedback.add("NULL CLASSROOM ");
//    			else
//    				su = StudentUser.connect(uname, croom);
//    		}
//    		
//    	
//    	if ( su == null ) { 
//    		String feed = ("NO SUCH STUDENT: " + fields[1] );
//    		if ( fields[1].startsWith("[") && fields[1].endsWith("]"))
//    		{
//    			feed += ("  WOULD CREATE ONE..." );
//    			feedback.add(feed);
//    		}
//    		else
//    		{
//    			feed += ("  STUDENT USERNAME MUST BE ENCLOSED IN Square Brackets - \"[  ]\"");
//    			feedback.add(feed);
//    			return feedback;
//    		}
//    	}
//    	double secsin = Double.parseDouble(fields[2]);
//    	String contribid = fields[3];
//    	String contribbody = fields[4];
//    	
//    	feedback.add("Contribution: id=" + contribid + " body=" + contribbody);
//    	feedback.add("CODINGS:");
//    	
//    	CodeCategory c1 = CodeCategory.findByName("Math"); //replace with menu read
//    	String mcodings = "MATH CODINGS: ";
//    	for (int i=5; i<8; i++)
//    	{
//    		if (fields[i].length() > 0 )
//    		{
//    			mcodings += ( "  field " + i + ":" + fields[i]);    			
//    		}
//    	}
//    	feedback.add(mcodings);
//    	String scodings = "SOCIAL CODINGS: ";
//    	for (int i=8; i<11; i++)
//    	{
//    		if (fields[i].length() > 0 )
//    		{
//    			scodings += ( "  field " + i + ":" + fields[i]);    			
//    		}
//    	}
//    	feedback.add(scodings);
//    	
//    	String ccoding = "CORRECTNESS CODING: ";
//    	if (fields[11].equals("1"))
//    	{
//    		ccoding += "CORRECT";
//    		feedback.add(ccoding);
//    	}
//    	else
//    	{
//    		ccoding += "NO correct coding";
//    	}
//    	return feedback;
//    	}
//    	catch (Exception e)
//    	{
//    		e.printStackTrace();
//    		feedback.add("ERROR IN PROCESSING LINE");
//    		return feedback;
//    	}
//    }
    
    
    
    ///parse line for contributions...
    public static Contribution parseForContribution( Vector<StudentUser>newstudents, ContributionType ct, Classroom croom, Session sess, Date sessstart, String aline )
    {
    	//NAME,TIME,Y=,FUNCTION,MATH1,MATH2,MATH3,SOCIAL1,SOCIAL2,SOCIAL3,HIT/NO-HIT,STATUS
    	int N = 0; //namefield N
    	int T = 1; //timefield T
    	int L = 2; //labelfield L 
    	int F = 3; //functionfield F
    	int M = 4; //mathfield M
    	int S = 7; //socialfields S
    	int C = 10; //correctness 
    	//then "status" is just dropped.
    	String[] fields = aline.split(",");
    	if (fields.length < 4) { return null; }
    	
    	try {
    		StudentUser su = null;
    		
    		if ( fields[N].startsWith("[") && fields[N].endsWith("]"))
    		{
    			String uname = fields[N].substring(1,fields[N].length()-1);
    			su = StudentUser.connect(uname, croom);
    		}
    	
    	if ( su == null ) { 
    		System.err.println("NO SUCH STUDENT: " + fields[N] );
    		if ( fields[N].startsWith("[") && fields[N].endsWith("]"))
    		{
    			System.err.println("CREATING..." );
    			String uname = fields[N].substring(1,fields[N].length()-1);
    			su = new StudentUser(uname, croom);
    			su.save();
    			newstudents.add(su);
    		}
    		else
    		{
    			System.err.println("STUDENT USERNAME MUST BE ENCLOSED IN Square Brackets - \"[  ]\"");
    			return null;
    		}
    	}
    	
    	if ( fields.length < 5 || fields[L].equalsIgnoreCase("Y0") ) { return null; }  //then this was just a "logged in" line and not a contrib
    	
    	if (fields.length == 5 && "POINT".equalsIgnoreCase(fields[2]) )
    		return parseForPointContribution(   su,  sess,  sessstart,  fields );
    	
    	double secsin = Double.parseDouble(fields[T]);
    	String contribid = fields[L];
    	String contribbody = fields[F];
    	
    	Contribution toreturn = new Contribution(ct, su, sess, contribid, contribbody );
    	toreturn.secondsIn = secsin;
    	toreturn.timestamp = new Date(sessstart.getTime() + (int)(secsin * 1000));
    	//add to database. == maybe don't do this --> maybe wait till we are cleared by user.
    	toreturn.save();
    	//side effects -- annotations
    	CodeCategory c1 = CodeCategory.findByName("Math"); //replace with menu read
    	for (int i=M; i<M+3; i++)
    	{
    		if (fields[i].length() > 0 )
    		{
    			System.err.println( "Processing field " + i + " of " + aline + ".  Field = " + fields[i]);
    			CodeDescriptor cd = CodeDescriptor.findByCategoryAndName(c1,fields[i]);
    			cd.save();
    			Coding c = new Coding(toreturn, c1.category, cd.descri);
    			c.save();
    		}
    	}
    	CodeCategory c2 = CodeCategory.findByName("Social"); //replace with menu read
    	for (int i=S; i<S+3; i++)
    	{
    		if (fields[i].length() > 0 )
    		{
    			System.err.println( "Processing field " + i + " of " + aline + ".  Field = " + fields[i]);
    			CodeDescriptor cd = CodeDescriptor.findByCategoryAndName(c2,fields[i]);
    			cd.save();
    			Coding c = new Coding(toreturn, c2.category, cd.descri);
    			c.save();
    		}
    	}
    	CodeCategory c3 = CodeCategory.findByName("Correctness"); //replace
    	if (fields[C].equals("1"))
    	{
    		System.err.println( "Processing field " + 11 + " of " + aline + ".  Field = " + fields[11]);
    		CodeDescriptor cd = CodeDescriptor.findByCategoryAndName( c3, "CORRECT");
    		cd.save();
    		Coding c = new Coding( toreturn, c3.category, cd.descri );
    		c.save();
    	}
    	return toreturn;
    	}
    	catch (Exception e)
    	{
    		e.printStackTrace();
    		return null;
    	}
    }
    
    public  static Contribution parseForPointContribution(  StudentUser su, Session sess, Date sessstart, String[] fields) {
    	final ContributionType  ct = ContributionType.POINT;
    	//final String expectedPointHeader = "NAME,TIME,TYPE,XVAL,YVAL";
    	final int N = 0;
    	final int TI = 1;
    	final int TY = 2;
    	final int XV = 3;
    	final int YV = 4;
    	
    	double secsin = Double.parseDouble(fields[TI]);
    	String contribid = "POINT";
    	String contribbody = "(" + fields[XV] + "," + fields[YV] + ")";
    	
    	Contribution toreturn = new Contribution(ct, su, sess, contribid, contribbody );
    	toreturn.secondsIn = secsin;
    	toreturn.timestamp = new Date(sessstart.getTime() + (int)(secsin * 1000));
    	//add to database. == maybe don't do this --> maybe wait till we are cleared by user.
    	toreturn.save();
    	return toreturn;
    }
    
    public static void error( String message )
    {
    	flash.error("ERROR in processing uploaded file");
    	render(message);
    }
    
    /*
     * public static void create(String comment, File attachment) {
    String s3Key = S3.post(attachment);
    Document doc = new Document(comment, s3Key);
    doc.save();
    show(doc.id);
}
     */

}
