package models;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collection;
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
	
	@Required
	public boolean isValid = true;


	public String fieldseparator = ";";
	
	
	@OneToMany(mappedBy="annotatedContrib", cascade=CascadeType.ALL)
	public List<Annotation> annotations;
	
	@OneToMany(mappedBy="codedContrib", cascade=CascadeType.ALL)
	public List<Coding> codings;
	
	
	@Required
	public int sequenceNumber;
	
	
	public Contribution( ContributionType type, StudentUser stud, Session act, String id, String body, boolean validity )
	{
		this.type = type;
		this.student = stud;
		this.session = act;
		this.timestamp = Utilities.getTstamp();
		this.secondsIn = (this.timestamp.getTime() - act.startTime.getTime()) / 1000.0;
		this.objectID = id;
		this.body = body;
		this.sequenceNumber = act.getNextSequenceNumber();
		this.fieldseparator = ";";
		this.isValid = validity;
	}
	
	//keeping old contribution constructor for backwards compatibility -- all contributions here will be "valid"
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
		this.fieldseparator = ";";
	}
	
	
	public String toString()
	{
		//return timestamp.toString() +  " : seq# : " + sequenceNumber + " : by : " + student.toString() + " : with contents : " + body + " : in session : " + session.toString();
		String s = String.valueOf(sequenceNumber);
		s +=  "|" + type + "|";
		s += secondsIn + "|" ;
		s += student.getUserName() + "|";
		s += objectID + "|";
		s += body;
		return s;
//		return String.valueOf(sequenceNumber) + "|" + type + "|" + secondsIn + "|" + student.getUserName() + "|" + objectID + "|" + body;
	}
	
	public String codingsShorthand()
	{
		
		String blurb="";
		for (Coding c: codings)
		{
			if ( c.descrip != null )
			{
				blurb += "|" + c.categ + ":";
				blurb += c.descrip;
			}
		}
		if (blurb.length()==0)
			blurb += "--";
		return blurb;
	}

	
	public String annotationsShorthand()
	{
		String blurb="";
		for (Annotation a : annotations )
		{
			blurb += "|" + a.theAnnotation;
		}
		if (blurb.length()==0)
			blurb += "--";
		return blurb;
	}

	
	public String toTSVLineVerbose()
	{
		
		String line = String.valueOf(sequenceNumber) + "\t" + String.valueOf(isValid) + "\t" + type + "\t" + secondsIn + "\t" + student.getUserName() + "\t" + objectID + "\t" + body;
		
		//now codings, if there are any
		line += "\t";
		for (Coding c: codings)
		{
			if ( c.descrip != null )
			{
				line += "|" + c.categ + ":";
				line += c.descrip;
			}
		}
		
		//now annotations if there are any
		line += "\t";
		for (Annotation a : annotations )
		{
			line += "|" + a.theAnnotation;
		}
		
		return line;
	}
	
	
	
	public String toTSVLine()
	{
		String line = String.valueOf(sequenceNumber) + "\t" + String.valueOf(isValid) + "\t" + type + "\t" + secondsIn + "\t" + student.getUserName() + "\t" + objectID + "\t" + body;
		//don't add any annotations or code information.
		return line;
	}

	public static Collection<? extends Contribution> getBySessionAndStudent(
			Session s, StudentUser su) {
		
		return find( "bySessionAndStudent", s, su).fetch();
	}
}
