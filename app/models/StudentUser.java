package models;

import javax.persistence.Entity;
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


	public StudentUser( String uname, Classroom croom )
	{
		this.username = uname;
		this.classroom = croom;
	}

	public static StudentUser connect(String uname, Classroom croom) {
		return find("byUsernameAndClassroom", uname, croom).first();
	}


	public String toString()
	{
		return username+":"+classroom.getName();
	}

}