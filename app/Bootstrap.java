import play.*;
import play.jobs.*;
import play.test.*;
 
import models.*;
 
@OnApplicationStart
public class Bootstrap extends Job {
 
    public void doJob() {
        //Check if the database is empty
        if(School.count() == 0) {
        	Fixtures.deleteDatabase();
            //Fixtures.loadModels("seeddata.yml");
            School s = new School("SST");
            s.save();
            Teacher t = new Teacher("Johari", s);
            t.save();
            String ubase = "S";
            Classroom c = new Classroom(s, t, "Test Class", 2012);
            c.save();
            for (int i = 1; i<31; i++ )
            {
            	String uid = String.valueOf(i);
            	if (i<10)
            		uid = "0"+uid;
            	StudentUser su = new StudentUser(ubase+uid, c);
            	su.save();
            }
        }
    }
 
}