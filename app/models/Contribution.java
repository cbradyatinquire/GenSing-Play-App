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
	public Session session;
	
	@Required
	public Date timestamp;
	
	@Required
	public double secondsIn;
	
	@Required
	public String objectID;
	
	@Required
	public String body;


	public String separator = ";";
	
	
	@OneToMany(mappedBy="annotatedContrib", cascade=CascadeType.ALL)
	public List<Annotation> annotations;
	
	@OneToMany(mappedBy="codedContrib", cascade=CascadeType.ALL)
	public List<Coding> codings;
	
	
	@Required
	public int sequenceNumber;
	
	
	public Contribution( ContributionType type, StudentUser stud, Session act, String id, String body )
	{
		this.type = type;
		this.student = stud;
		this.session = act;
		this.timestamp = Utilities.getTstamp();
		this.secondsIn = (this.timestamp.getTime() - act.startTime.getTime()) / 1000.0;
		this.objectID = id;
		this.body = body;
		//System.err.println("Session's current sequence number is " + act.sequenceCounter );
		this.sequenceNumber = act.getNextSequenceNumber();
		//System.err.println( "mine is now " + sequenceNumber );
		this.separator = ";";
		
	}
	
	
	public String toString()
	{
		//return timestamp.toString() +  " : seq# : " + sequenceNumber + " : by : " + student.toString() + " : with contents : " + body + " : in session : " + session.toString();
		return String.valueOf(sequenceNumber) + "|" + type + "|" + secondsIn + "|" + student.getUserName() + "|" + objectID + "|" + body;
		
	}
	
	
	public String toTSVLine()
	{
		String line = String.valueOf(sequenceNumber) + "\t" + type + "\t" + secondsIn + "\t" + student.getUserName() + "\t" + objectID + "\t" + body;
		
		line += "\t";
		for (Annotation a : annotations )
		{
			line += "|" + a.theAnnotation;
		}
		line += "\t";
		
		for (Coding c: codings)
		{
			if ( c.descrip != null )
			{
				line += "|" + c.categ + ":";
				line += c.descrip;
			}
		}
		//add codings too.
		
		return line;
	}
}
