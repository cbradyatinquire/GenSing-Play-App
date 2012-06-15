package models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Classroom extends Model {
	
	@Required
	public String classname;
	
	@Required
	@ManyToOne
	public School school;
	
	@Required
	@ManyToOne
	public Teacher teacher;
	
	@Required
	public int startYear;

	@Required
	@OneToMany (mappedBy="classroom", cascade=CascadeType.ALL)
	public List<StudentUser>students;
	
	@Required
	@OneToMany (mappedBy="classroom", cascade=CascadeType.ALL)
	public List<Session>sessions;

	@Lob
    public String note;
	
//	@Required
//	@OneToOne // (mappedBy="classroom", cascade=CascadeType.ALL)
//	public Session current = null;
	

	public Classroom( School aschool, Teacher ateacher, String name, int start )
	{
		this.classname = name;
		this.startYear = start;
		this.school = aschool;
		this.teacher = ateacher;
		students = new ArrayList<StudentUser>();
	}
	
//	public void setCurrentActivity( Session curr )
//	{
//		current = curr;
//	}
//	public Session getCurrentActivity()
//	{
//		return current;
//	}

	public  void setSchool( School s ) { school = s; }
	public  boolean isSchool( School s ) { return ( s.equals( school )); }

	
	public static Classroom connect( School s, Teacher t, String cname, int year )
	{
		return find( "bySchoolAndTeacherAndClassnameAndStartyear", s, t, cname, year).first();
	}

	@Override
	public String toString() { return classname + ":" + startYear;  }

	//public String getName() { return classname; }
	
}
