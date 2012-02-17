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
            Fixtures.loadModels("seeddata.yml");
        }
    }
 
}