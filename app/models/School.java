package models;

import javax.persistence.Entity;
import javax.persistence.Lob;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class School extends Model {


	@Required
	public String schoolName = "SST";
	
	@Lob
    public String annotation;
	
	 public static School connect(String name) {
		return find("bySchoolname", name).first();
	 }

	public String toString() { return schoolName; }
}
