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
	public double secondsIn;
	
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
	
	@Required
	public int sequenceNumber;
	
	
	public Contribution( ContributionType type, StudentUser stud, Activity act, String id, String body )
	{
		this.type = type;
		this.student = stud;
		this.activity = act;
		this.timestamp = Utilities.getTstamp();
		this.secondsIn = (this.timestamp.getTime() - act.startTime.getTime()) / 1000;
		this.objectID = id;
		this.body = body;
		//System.err.println("Activity's current sequence number is " + act.sequenceCounter );
		this.sequenceNumber = act.getNextSequenceNumber();
		//System.err.println( "mine is now " + sequenceNumber );
		
	}
	
	
	public String toString()
	{
		//return timestamp.toString() +  " : seq# : " + sequenceNumber + " : by : " + student.toString() + " : with contents : " + body + " : in activity : " + activity.toString();
		return String.valueOf(sequenceNumber) + "|" + type + "|" + secondsIn + "|" + student.getUserName() + "|" + objectID + "|" + body;
		
	}
	
	public String toTSVLine()
	{
		String line = String.valueOf(sequenceNumber) + "\t" + type + "\t" + secondsIn + "\t" + student.getUserName() + "\t" + objectID + "\t" + body;
		for (Tag t : tags )
		{
			line += t + "\t";
		}
		if (annotation != null)
			line += annotation;
		return line;
	}
}
