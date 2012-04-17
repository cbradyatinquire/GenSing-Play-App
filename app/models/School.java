package models;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class School extends Model {


	@Required
	public String schoolName = "SST"; //default
	
	@OneToMany (mappedBy="school", cascade=CascadeType.ALL)
	public List<Teacher>teachers;
	
	@OneToMany (mappedBy="school", cascade=CascadeType.ALL)
	public List<Classroom>classrooms;
	
	
	@Lob
    public String annotation;
	
	public String getAnnotation() { return annotation; }
	
	public School( String sname ) {
		schoolName = sname;
	}
	 public static School connect(String name) {
		return find("bySchoolname", name).first();
	 }

	public String toString() { return schoolName; }
}
