package models;

import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Activity extends Model {

	@Required
	public ActivityType type;
	
	@Required
	public Date startTime;
	
	@Required
	@ManyToOne
	public Classroom classroom;
	
	public String sessionMessage = "";

	@Lob
    public String annotation;
	
	public int sequenceCounter = 0;

	public Activity( Classroom c, ActivityType at )
	{
		this.classroom = c;
		this.type = at;
		this.startTime = Utilities.getTstamp();
		this.sequenceCounter = 0;
	}
	
	public static Activity connect(Classroom croom, Date thedate ) {
		return find( "byClassroomAndDate", croom, thedate).first();
	}
	
	public String toString()
	{
		
		return classroom.teacher.aschool.toString() + "\t" + classroom.teacher.toString() + "\t" + classroom.toString() + "\t" + startTime.toString();
		//return  type.name() + " " + classroom.toString() + " " + startTime.toString() + " msg:" + sessionMessage;
		
	}
	
	public int getNextSequenceNumber( ) { 
		sequenceCounter++; 
		this.save();
		return sequenceCounter;
	}

	public static Activity connectLatest(Classroom croom) {
		List<Activity> acts = find("byClassroom", croom ).fetch();
		if ( acts.isEmpty() )
			return null;
		Activity latest = acts.get(0);
		for (Activity act : acts)
		{
			if (act.startTime.after( latest.startTime ) )
				latest = act;
		}
		return latest;
	}
	
	
	public List<Contribution> getContributionsAfterNumber( int i )
	{
				
		String indx = String.valueOf(i);
		String qu = "select c from Contribution c WHERE c.sequenceNumber > "+indx+" and c.activity = ? order by c.sequenceNumber";
		List<Contribution> recents = Contribution.find(qu, this).fetch();
		
		
		return recents;
	}
	
}
