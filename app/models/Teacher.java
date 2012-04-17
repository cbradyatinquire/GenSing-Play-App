package models;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Teacher extends Model {
	

	@Required
	public String username;
	
	@Required
	@ManyToOne
	public School school;
	
	public String firstnames;
	public String lastnames;
	
	@OneToMany (mappedBy="teacher", cascade=CascadeType.ALL)
	public List<Classroom>classrooms;
	
	@Lob
    public String annotation;
	
	public Teacher( String uname, School aschool ) {
		username = uname;
		school = aschool;
	}
	
	public List<Classroom> getClassrooms( ) { return classrooms; }
	
	public static Teacher connect(String uname, School tschool) {
		return find("byUsernameAndSchool", uname, tschool).first();
	}
	
	public String toString() {
		String add = "[";
		if ( firstnames != null )
			add += firstnames;
		if ( lastnames != null )
			add += " " + lastnames;
		String toReturn = username;
		if (add.length() > 1)
			toReturn += add + "]";
		return toReturn;
	}

}
