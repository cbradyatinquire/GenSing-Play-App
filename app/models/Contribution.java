package models;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Contribution extends Model {

	
	@Required
	@ManyToOne
	public StudentUser student;
	
	@Required
	public String context;
	
	@Required
	public Date timestamp;
	
	@Required
	public String contents;
	
	public static final String DATE_FORMAT_NOW = "yyyy-MM-dd_HH-mm-ss";
	public static final SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);

	public static String getStringForDate( Date d ) {
	    return sdf.format(d);
	  }

	
	public static Date getTstamp() {
		Calendar cal = Calendar.getInstance();
	    return cal.getTime();
	}
	
	public Contribution( StudentUser stud, String ctxt, String content )
	{
		this.student = stud;
		this.context = ctxt;
		this.timestamp = getTstamp();
		this.contents = content;
	}
	
	public String toString()
	{
		return getStringForDate(timestamp) + " :: " + student.toString() + " :: " + contents + " :: in context " + context;
	}
}
