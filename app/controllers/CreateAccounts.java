package controllers;

import java.util.ArrayList;
import java.util.List;

import models.Classroom;
import models.School;
import models.StudentUser;
import models.Teacher;
import play.data.validation.Required;
import play.mvc.Controller;

public class CreateAccounts extends Controller {

	
	public static void addSchool( @Required String schoolname )
	{
		if(validation.hasErrors()) {
            flash.error("ERROR: Please fill in school name");
            schoolaccount();
        }
		School s = School.connect(schoolname);
		if ( s != null ) {
			flash.error("ERROR: the school " + s.schoolName + " already exists.");
            schoolaccount();
		}
		School ns = new School(schoolname);
		ns.save();
		flash.error("SUCCESS: the school " + schoolname + " has been created.");
        schoolaccount();
	}
	
	public static void addTeacher( @Required String uname, @Required String schoolname)
	{
		if(validation.hasErrors()) {
            flash.error("ERROR: Please enter all fields:  Username, and School Name");
            teacheraccount();
        }
		uname = uname.trim();
		schoolname = schoolname.trim();
		School s = School.connect(schoolname);
		if ( s == null ) {
			flash.error("ERROR: the school " +schoolname + " does not exist.");
			teacheraccount();
		}
		List<Teacher> teachers = Teacher.findAll();
    	String conflict = "";
    	for (Teacher t : teachers)
    	{
    		if ( t.school.equals(s) )
    		{
	    		if (t.username.equalsIgnoreCase(uname))
	    			conflict = t.username;
    		}
    	}
    	if ( conflict.length() > 0 )
    	{
    		flash.error("ERROR: A teacher account with username, '" + conflict + "' already exists in school " + schoolname + ".  Please try another username.");
    		teacheraccount();
    	}
		
		Teacher t = new Teacher(uname, s);
		//Add Practice classroom, with start year 2012.
		Classroom practice = new Classroom( "Practice Class", 2012 );
		practice.teacher = t;
		practice.school = t.school;
		StudentUser aaa = new StudentUser("aaa", practice);
		StudentUser bbb = new StudentUser("bbb", practice);
		StudentUser ccc = new StudentUser("ccc", practice);
		StudentUser ddd = new StudentUser("ddd", practice);
		t.save();
		practice.save();
		aaa.save();
		bbb.save();
		ccc.save();
		ddd.save();
		
		
		flash.error("SUCCESS: the teacher " + uname + " has been created in school " + schoolname + ".");
		teacheraccount();
	}
	
	public static void addClassroom( String classroom, String classname, String startyear) {
		//safe( classroom, classname, startyear );
		if (classroom != null &&  classroom.length()>0)
		{
			String[] cinfo = classroom.split(", ");
			if ( cinfo.length == 2)
			{
				String name = cinfo[0];
				int year = Integer.valueOf(cinfo[1].trim());
				Classroom c = Classroom.connect(name, year);
				if ( c == null )
				{
					flash.error( "ERROR:  no classroom in system with name:year = " + classname + ":" + startyear);
					Application.index();
				}
				Controller.session.put("classroomid", c.getId().toString());
				List<StudentUser>students = c.students;
				ArrayList<String> studentnames = new ArrayList<String>();
				for (StudentUser su : students )
				{
					studentnames.add(su.username);
				}
				editclassroom(c.classname + ", " + c.startYear, studentnames );
			}
			else 
			{
				flash.error("ERROR: error in parsing");
		         Application.index();
			}
		}
		else if ( classname != null && classname.trim().length() > 0  && startyear != null && startyear.trim().length() > 0)
		{
			int year = 2012;
			try {
				year = Integer.valueOf(startyear.trim());
			}
			catch (Exception e)
			{
				e.printStackTrace();
			}
			Classroom c = new Classroom( classname, year);
			String teachid = Controller.session.get("teacherid");
			if ( teachid == null )
			{
				flash.error("ERROR: invalid state -- no teacher session object");
		         Application.index();
			}
			Long tid = Long.valueOf( teachid  );
			Teacher t = Teacher.findById(tid);
			
			if ( t == null )
			{
				flash.error("ERROR: invalid state -- no teacher session object");
		         Application.index();
			}
			School s = t.school;
			c.school = s;
			c.teacher = t;
			c.save();
			Controller.session.put("classroomid", c.getId().toString());
		
			editclassroom( c.classname + c.startYear, null  );
		}
		else
		{
			 flash.error("ERROR: You did not specify a classroom. Please log in and try again");
	         Application.index();
		}
	}
	
	public static void editclassroom( String classidentifier, ArrayList<String> studentnames )
	{
		render(classidentifier, studentnames );
	}
	
	private static Classroom getClassroomFromSessionObject() {
		String cids = Controller.session.get("classroomid");
		Classroom c = null;
		if ( cids != null )
        {
        	Long cid = Long.valueOf(cids);
        	c = Classroom.findById(cid);
        }
		return c;
	}
	private static ArrayList<String> getStudentNames( Classroom c ) {
		ArrayList<String> studentnames = new ArrayList<String>();
        for ( StudentUser su : c.students )
        	studentnames.add( su.username );
        return studentnames;
	}
	
	public static void addStudent( @Required String uname ) {
		Classroom c = getClassroomFromSessionObject();
		if (c == null)
		{
			flash.error("ERROR: Invalid state: no classroom object identified in session.");
        	Application.index();
		}
		ArrayList<String> studentnames = getStudentNames( c );
		if(validation.hasErrors()) {
            flash.error("ERROR: Enter a user name.");
            editclassroom( c.classname + ", " + c.startYear, studentnames );
        }
		String conflict = "";
		for (String s : studentnames )
		{
			if ( s.equalsIgnoreCase(uname ) )
				conflict = s;
		}
		if (conflict.length() > 0)
		{
			flash.error("ERROR: Username " + uname + " conflicts with existing username " + conflict + ". Try again.");
            editclassroom( c.classname + ", " + c.startYear, studentnames );
		}
		StudentUser su = new StudentUser(uname, c);
		c.students.add(su);
		su.save();
		c.save();
		studentnames = getStudentNames( c );
		flash.error("SUCCESS:  Student account created with username " + uname);
        editclassroom(c.classname + ", " + c.startYear, studentnames );
	}
	
	//	public static void safe( String classroom, String classname, String startyear )
//	{
//		render( classroom, classname, startyear );
//	}
	
	public static void schoolaccount() {
		render();
	}

	
	public static void teacheraccount() {
		List<School>schools = School.findAll();
		render( schools );
	}
	
	public static void teacherLogin( @Required String uname, @Required String schoolname )
	{	
		if(validation.hasErrors()) {
			flash.error("ERROR: Please provide information for both Username and School");
			teacheraccount();
		}

		School s = School.connect(schoolname);
		if ( s == null){
			flash.error("ERROR: No school named " + schoolname);
			teacheraccount();
		}

		Teacher teach = Teacher.connect(uname, s);
		if (teach == null)
		{
			flash.error("ERROR: There is no teacher account for " + uname + " in school " + schoolname);
			teacheraccount();
		}

		Controller.session.put("teacherid", teach.getId().toString());
		List<Classroom> classrooms = teach.classrooms;
		List<String>crnamesandyears = new ArrayList<String>();
		for (Classroom c : classrooms )
		{
			crnamesandyears.add( c.classname + ", " + c.startYear );
		}
		
		//safetest( teach.username, crnamesandyears ); //, classrooms );
		classroomaccount( teach.username, crnamesandyears ); //, classrooms );

	}
	
	public static void safetest(String teachername,  List<String>classrooms ) {
		render( teachername,  classrooms );
	}
	
	public static void classroomaccount(String teachername,  List<String>classrooms ) {
		
		render( teachername,  classrooms  );
	}
	
}
