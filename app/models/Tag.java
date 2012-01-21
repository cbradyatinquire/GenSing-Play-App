package models;

import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Tag extends Model {
	
	@Required
	@ManyToOne
	public Contribution taggedContrib;
	
	@Required
	public TagType type;
	
	@Lob
    public String annotation;
	
	public String moreInfo = "";

	public String toString() { return type.name() + " " + moreInfo; }
}
