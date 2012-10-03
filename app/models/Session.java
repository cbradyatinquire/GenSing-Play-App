package models;

import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Session extends Model {

	public String activitytype = "";
	
	@Required
	public Date startTime;
	
	@Required
	@ManyToOne
	public Classroom classroom;
	
	@Required
	public String source = ""; //the software or model that created this.
	
	public String sessionMessage = "";

	@Lob
    public String note;
	
	public int sequenceCounter = 0;

	//public Session( Classroom c, ActivityType at )
	public Session( Classroom c, String src )
	{
		this.classroom = c;
		//this.type = at;
		this.source = src;
		this.startTime = Utilities.getTstamp();
		this.sequenceCounter = 0;
	}
	
	public Long getId( ) { return this.id; }
	
	public static Session getActivitySession( Long id )
	{
		return Session.findById(id);
		//return find("byId", id).first();
	}
	
	public static Session connect(Classroom croom, Date thedate ) {
		return find( "byClassroomAndStartTime", croom, thedate).first();
	}
	
	
	
	public String toString()
	{
		return classroom.teacher.school.toString() + "\t" + classroom.teacher.toString() + "\t" + classroom.toString() + "\t" + startTime.toString() + "\t" + id;
		//return  activitytype.name() + " " + classroom.toString() + " " + startTime.toString() + " msg:" + sessionMessage;
	}
	
	public String toAltString()
	{
		String s = this.toString();
		return s.replace('\t', ';'); //replaceAll("\t", ";");
	}
	
	public int getNextSequenceNumber( ) { 
		sequenceCounter++; 
		this.save();
		return sequenceCounter;
	}

//	public static Session connectLatest(Classroom croom) {
//		List<Session> acts = find("byClassroom", croom ).fetch();
//		if ( acts.isEmpty() )
//			return null;
//		Session latest = acts.get(0);
//		for (Session act : acts)
//		{
//			if (act.startTime.after( latest.startTime ) )
//				latest = act;
//		}
//		return latest;
//	}
//	
	
	public List<Contribution> getContributionsAfterNumber( int i )
	{
				
		String indx = String.valueOf(i);
		String qu = "select c from Contribution c WHERE c.sequenceNumber > "+indx+" and c.session = ? order by c.sequenceNumber";
		List<Contribution> recents = Contribution.find(qu, this).fetch();
		
		
		return recents;
	}

	public Contribution getContributionWithSequence(int sequence) {
		String qu = "select c from Contribution c WHERE c.sequenceNumber = "+sequence+" and c.session = ?";
		Contribution c = Contribution.find(qu, this).first();
		return c;
	}
	
}
