package models;

import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class StudentUser extends Model {


	@Required
	public String username;

	@Required
	@ManyToOne
	public Classroom classroom;
	
	public String firstnames;
	public String lastnames;

	@Lob
    public String note;

	public StudentUser( String uname, Classroom croom )
	{
		this.username = uname;
		this.classroom = croom;
	}
	
	public Long getId( ) { return this.id; }
	
	public static StudentUser getStudentById( Long studid ){
		return StudentUser.findById(studid);
	}
	
	public String getUserName()
	{
		return "[" + username + "]";
	}

	public static StudentUser connect(String uname, Classroom croom) {
		return find("byUsernameAndClassroom", uname, croom).first();
	}


	public String toString()
	{
		return username+", in "+classroom.toString() + " with teacher "+classroom.teacher+" in school "+classroom.school+".";
	}

	

}