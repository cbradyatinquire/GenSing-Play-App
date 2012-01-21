package models;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Contribution extends Model {

	@Required
	public ContributionType type;
	
	@Required
	@ManyToOne
	public StudentUser student;
	
	@Required
	@ManyToOne
	public Activity activity;
	
	@Required
	public Date timestamp;
	
	@Required
	public String objectID;
	
	@Required
	public String body;
	
	@Required
	public String separator = ";";
	
	
	@OneToMany(mappedBy="taggedContrib", cascade=CascadeType.ALL)
	public List<Tag> tags;
	
	@Lob
    public String annotation;
	
	
	public Contribution( ContributionType type, StudentUser stud, Activity act, String id, String body )
	{
		this.type = type;
		this.student = stud;
		this.activity = act;
		this.timestamp = Utilities.getTstamp();
		this.objectID = id;
		this.body = body;
	}
	
	public String toString()
	{
		return Utilities.getStringForDate(timestamp) + " :: " + student.toString() + " :: " + body + " :: in activity " + activity.toString();
	}
}
