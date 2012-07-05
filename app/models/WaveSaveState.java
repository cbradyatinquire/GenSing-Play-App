package models;

import javax.persistence.Entity;
import javax.persistence.Lob;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class WaveSaveState extends Model {
	
	
	@Required
	public String selectedCodes;
	
	@Required
	public Date timestamp;
	
	@Required
	public String name;
	
	@Lob
	public String comments="";
	
	@Required
	public Long sessionId;
	
	//@Required
	//public Session session;
	
	@Required
	public String currentSelectionString;
	
	
	public WaveSaveState( String selcodes, String nam, Long sid, String selstring )
	{
		this.selectedCodes = selcodes;
		this.timestamp = Utilities.getTstamp();
		this.name = nam;
		this.sessionId = sid;
		this.currentSelectionString = selstring;
		Session check = Session.getActivitySession(sid);
		if (check == null )
		{
			System.err.println("session id was bogus");
		}
		else
		{
			System.err.println( check.toString()  );
		}
		comments = "";
	}
	
	public void setComments( String com )
	{
		this.comments = com;
	}
	
	public String toString()
	{
		return (this.id.toString() + "\t" + name + "\t" + timestamp.toString() );
	}
	
	public static WaveSaveState connect(String name, Date thedate ) {
		return find( "byNameAndDate", name, thedate).first();
	}
	
	public static WaveSaveState findWaveSaveState( Long id )
	{
		return WaveSaveState.findById(id);
	}

}
