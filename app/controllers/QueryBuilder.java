package controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import models.Classroom;
import models.CodeCategory;
import models.CodeDescriptor;
import models.Coding;
import models.Contribution;
import models.School;
import models.Session;
import models.StudentUser;
import models.Teacher;

import play.mvc.*;

public class QueryBuilder extends Controller {

    public static void index() {
        render();
    }
    
    public static void qBuilder( ) {
    	render(  );
    }
    
    public static void doQueryPretest( String search ) {
    	System.err.println("Got to query pretest:  arg = " + search);
    	
    	String result = "teacher";
    	ArrayList<String> params = new ArrayList<String>();
    	params.add( result );
    	params.add("hi");
    	addInfo( result );
    }
    
    public static void choose() {
    	renderJSON("hi");
    }
    
    
    public static String jsObjectStuff() {
    	
    	return "[ {title:'SST',	children:[{ title:'JOHARI',children:[{title:'Test'}]  },{ title:'Teacher2', children:[{title:'Test class2'}]  }, "+
    			" { title:'Teacher3', children:[{title:'Test class 3'}]  } ] } ]";
    					
    }
    
    public static String schoolObjectArray() {
    	String str = "[ ";
    	List<School> schools = School.findAll();
    	
    	for (School school : schools )
    	{
    		str += "{isFolder:true, expand:true, title:'" + school.schoolName + "', key:'" + school.schoolName + "', children:[ " + teacherObjectArray( school.teachers ) + "] },";
    	}
    	if (schools.size() > 0)
    		str = str.substring(0,str.length()-1); //remove last comma.
    	str += "]";
    	return str;
    }

    public static String teacherObjectArray( List<Teacher> teachers ) {	
    	String ts = "";
    	for (Teacher teacher : teachers )
    	{
    		ts += "{ title: '" + teacher.username + "', key:'" + teacher.username + "|" + teacher.school.schoolName + "', children:[ " + classroomObjectArray( teacher.classrooms ) + "] },";
    	}
    	if (teachers.size() > 0)
    		ts = ts.substring(0,ts.length()-1); //remove final comma.
    	
    	return ts; 
    }
    
    public static String classroomObjectArray( List<Classroom> classrooms ) {	
    	String cs = "";
    	for (Classroom classroom : classrooms )
    	{
    		cs += "{ title: '" + classroom.toString() + "',  " +
    				"key:'" + classroom.toString() +"|" + classroom.teacher.username +"|" + classroom.school.schoolName+ "', " +
    						"children:[ { title:'sessions', children:[ " + sessionObjectArray( classroom.sessions ) + " ]}, { title:'students', children:[ " + studentObjectArray( classroom.students ) + " ] } ]   },";
    	}
    	if ( classrooms.size() > 0 )
    		cs = cs.substring(0,cs.length()-1); //remove final comma.
    	
    	return cs; //" {title:'test'}, {title:'test2'} ";
    }
    
    
    public static String sessionObjectArray( List<Session> sessions )
    {
    	String ss = "";
    	for ( Session session : sessions )
    	{
    		ss += "{ title: '" + session.toAltString() + "', key:'" + session.id + "' },";
    	}
    	
    	if ( sessions.size() > 0 )
    		ss = ss.substring(0,ss.length()-1); //remove final comma.
    	//System.err.println( "Session objectarray--" + ss);
    	return ss; //"{ title:'fakesession' "   //ss;
    }
    
    public static String studentObjectArray( List<StudentUser> students )
    {
    	String ss = "";
    	for ( StudentUser student : students )
    	{
    		ss += "{ title:'" + student.username + "', key:'" + student.id + "' },";
    	}
    	
    	if ( students.size() > 0 )
    		ss = ss.substring(0,ss.length()-1); //remove final comma.
    	return ss;
    }
    
    
    public static void basicSelector() {
    	renderArgs.put("kiddos", schoolObjectArray() );
    	render();
    }

    public static void graphicVisualizer() {
    	renderArgs.put("kiddos", schoolObjectArray() );
    	render();
    }
    
    
    public static void testGet( String name, String value )
    {
    	String resp = "Received name=" + name + ", and value=" + value ;
    	
    	System.err.println(resp);
    	renderJSON(resp);
    }
    
    public static void testQuery( String sessionIDs, String studentIDs )
    {
    	String resp = "There are ";
    	String onse = " matching contributions.";
    	ArrayList<Contribution> contribs = new ArrayList<Contribution>();
    	String[] studentIDsa = studentIDs.split(",");
    	String[] sessionIDsa = sessionIDs.split(",");
    	
    	for ( String sid : sessionIDsa )
    	{
    		if ( sid.length() > 0 )
    		{
	    		Long sessionID = Long.decode(sid);
	    		Session s = Session.findById(sessionID);
	    		if (s == null) { System.err.println("NULL SESSION FOR ID = " + sid ); }
	    		//else { contribs.addAll( s.getContributionsAfterNumber(0) ); }
	    		else {
	    			List<Contribution> candidates = s.getContributionsAfterNumber(0);
	    			for ( String stu : studentIDsa )
	    			{
	    				if (stu.length() > 0 )
	    				{
	    					Long studentID = Long.decode(stu);
	    					StudentUser su = StudentUser.findById(studentID);
	    					if (su == null ) { System.err.println("NULL STUDENT FOR ID = " + stu ); }
	    					else {
	    						contribs.addAll( Contribution.getBySessionAndStudent( s, su ) );
	    					}
	    				}
	    			}
	    		}
    		}
    	}
    	String response = resp + contribs.size() + onse;
    	renderJSON(response);
    }
    
    public static void executeQuery( String sessionIDs, String studentIDs )
    {
    	String resp = " Contributions:</b><ul>";
    	String onse = "</ul>";
    	ArrayList<Contribution> contribs = new ArrayList<Contribution>();
    	
    	String[] studentIDsa = studentIDs.split(",");
    	String[] sessionIDsa = sessionIDs.split(",");
    	
    	for ( String sid : sessionIDsa )
    	{
    		if ( sid.length() > 0 )
    		{
	    		Long sessionID = Long.decode(sid);
	    		Session s = Session.findById(sessionID);
	    		if (s == null) { System.err.println("NULL SESSION FOR ID = " + sid ); }
	    		//else { contribs.addAll( s.getContributionsAfterNumber(0) ); }
	    		else {
	    			List<Contribution> candidates = s.getContributionsAfterNumber(0);
	    			for ( String stu : studentIDsa )
	    			{
	    				if (stu.length() > 0 )
	    				{
	    					Long studentID = Long.decode(stu);
	    					StudentUser su = StudentUser.findById(studentID);
	    					if (su == null ) { System.err.println("NULL STUDENT FOR ID = " + stu ); }
	    					else {
	    						contribs.addAll( Contribution.getBySessionAndStudent( s, su ) );
	    					}
	    				}
	    			}
	    		}
    		}
    	}
    	String body = "";
    	for ( Contribution c : contribs )
    	{
    		body += "<li>" + c.toTSVLineVerbose().replace('\t', '|') + "</li>";
    	}
    	String response = "<b>" + contribs.size() + resp + body + onse;
    	renderJSON(response);
    }
    
    public static void geoRouter( String sessionIDs, String studentIDs  )
    {
    	//TODO: copied from above - refactor to all use the same guts.
    	ArrayList<Contribution> contribs = new ArrayList<Contribution>();
    	
    	String[] studentIDsa = studentIDs.split(",");
    	String[] sessionIDsa = sessionIDs.split(",");
    	
    	for ( String sid : sessionIDsa )
    	{
    		if ( sid.length() > 0 )
    		{
	    		Long sessionID = Long.decode(sid);
	    		Session s = Session.findById(sessionID);
	    		if (s == null) { System.err.println("NULL SESSION FOR ID = " + sid ); }
	    		//else { contribs.addAll( s.getContributionsAfterNumber(0) ); }
	    		else {
	    			List<Contribution> candidates = s.getContributionsAfterNumber(0);
	    			for ( String stu : studentIDsa )
	    			{
	    				if (stu.length() > 0 )
	    				{
	    					Long studentID = Long.decode(stu);
	    					StudentUser su = StudentUser.findById(studentID);
	    					if (su == null ) { System.err.println("NULL STUDENT FOR ID = " + stu ); }
	    					else {
	    						contribs.addAll( Contribution.getBySessionAndStudent( s, su ) );
	    					}
	    				}
	    			}
	    		}
    		}
    	}
    	
    	render( contribs );
    }
    
    public static void googleTable( String sessionIDs, String studentIDs  ) {
    	//TODO: copied from above - refactor to all use the same guts.
    	ArrayList<Contribution> contribs = new ArrayList<Contribution>();
    	int numcontributions = 0;
    	int numstudents = 0;
    	int numvalids = 0;
    	int numinvalids = 0;
    	List<CodeCategory> cats = CodeCategory.findAll();
    	ArrayList<String>categories= new ArrayList<String>();
    	ArrayList<Integer>counts = new ArrayList<Integer>();
    	HashMap<String, Integer> catcounts = new HashMap<String, Integer>();
    	for ( CodeCategory cat : cats )
    	{
    		List<CodeDescriptor>descs = cat.descriptors;
    		for ( CodeDescriptor d : descs)
    		{
	    		String key = cat.toString() + ":" + d.descri;
	    		catcounts.put(key, 0);
	    		categories.add(key);
	    		counts.add(0);
    		}
    	}
    		
    	String[] studentIDsa = studentIDs.split(",");
    	String[] sessionIDsa = sessionIDs.split(",");
    	
    	for ( String sid : sessionIDsa )
    	{
    		if ( sid.length() > 0 )
    		{
	    		Long sessionID = Long.decode(sid);
	    		Session s = Session.findById(sessionID);
	    		if (s == null) { System.err.println("NULL SESSION FOR ID = " + sid ); }
	    		//else { contribs.addAll( s.getContributionsAfterNumber(0) ); }
	    		else {
	    			//List<Contribution> candidates = s.getContributionsAfterNumber(0);
	    			for ( String stu : studentIDsa )
	    			{
	    				if (stu.length() > 0 )
	    				{
	    					Long studentID = Long.decode(stu);
	    					StudentUser su = StudentUser.findById(studentID);
	    					if (su == null ) { System.err.println("NULL STUDENT FOR ID = " + stu ); }
	    					else {
	    						contribs.addAll( Contribution.getBySessionAndStudent( s, su ) );
	    						numstudents++;
	    					}
	    				}
	    			}
	    		}
    		}
    	}
    	numcontributions = contribs.size();
    	for (Contribution c : contribs)
    	{
    		if (c.isValid) {
    			numvalids++;
    			List<Coding> codings = c.codings;
    			//if (c.codings.isEmpty() ) { System.err.println( "Contribution with id " + c.id + " has no codings"); }
    			for (Coding cod : codings)
    			{
    				//System.err.println( "Checking for coding " + c.toString() + " in contribution " + c.id);
    				String thekey = cod.categ + ":" + cod.descrip;
    				if ( categories.contains(thekey) )  //;catcounts.keySet().contains(thekey) )
    				{
    					//int val = catcounts.get(thekey);
    					//catcounts.put(thekey, val + 1);
    					int inde = categories.indexOf( thekey );
    					int val = counts.get( inde );
    					counts.set(inde, val + 1);
    				}
    				else
    				{
    					System.err.println("No match for " + thekey);
    				}
    			}
    		}
    		else {
    			numinvalids++;
    		}
    	}
    	//System.err.println("Cat COUNTS ARE ");
    	//for (String categorystring : categories )
    	//	System.err.print(categorystring + "\t");
    	//System.err.println(" ");
    	//for (Integer i : counts)
    	//	System.err.print(i + "\t");
    	//System.err.println(" ");
    	
    	render( contribs, numcontributions, numstudents, numvalids, numinvalids, categories, counts );
    }
    
    public static void addCodes( Long sessionId, int sequence, String codings ) {
    	Application.setCodingsForContribution(sessionId, sequence, codings);
    	graphicVisualizer();
    }
    
    public static void doQuery( String str ) {
    	System.err.println("Got to do-query");

    	renderJSON("oops");
    }
    
    public static void addInfo( String  aparam ) { //ArrayList<String> params ) {
    	render( aparam );
    }
    
    public static void playWithGeoGebra() {
    	render();
    }

    public static void manageCodes() {
        render();
    }

    public static void assessContributionsFD() {
        render();
    }
}
