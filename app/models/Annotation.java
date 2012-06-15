package models;

import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Annotation extends Model {
	
	@Required
	@ManyToOne
	public Contribution annotatedContrib;
	
	@Required
	public String theAnnotation;
	
	public String meta = "";

	public Annotation(Contribution c, String annot ) {
		this.theAnnotation = annot;
		this.annotatedContrib = c;
	}

	public String toString() { 
		if (meta.length() == 0) 
			return theAnnotation; 
		else
			return theAnnotation + " (" + meta +")"; 
		}
}
