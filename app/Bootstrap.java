import controllers.Application;
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
            School s2 = new School("ANOTHER");
            s2.save();
            Teacher t = new Teacher("Johari", s);
            t.save();
            Teacher t2 = new Teacher("Another", s);
            t2.save();
            String ubase = "S";
            Classroom c = new Classroom(s, t, "Test Class", 2012);
            c.save();
            Classroom c2 = new Classroom(s, t, "A Second Class", 2012);
            c2.save();
            for (int i = 1; i<31; i++ )
            {
            	String uid = String.valueOf(i);
            	if (i<10)
            		uid = "0"+uid;
            	StudentUser su = new StudentUser(ubase+uid, c);
            	su.save();
            }
            
            //create a fake session
            //Application.startActivity(t.username, t.school.schoolName, c.classname, c.startYear, "Test Activity", "Dummy Loader");
            //Application.startActivity("Johari", "SST", "Test Class", 2012, "Test Activity", "Dummy Loader");
            Session se = new Session(c, "Fake Source");
            se.save();
            
            StudentUser csu = new StudentUser("contributor", c);
            csu.save();
            
            for (int i=1; i<100; i++)
            {
            	double co = i / 10.0;
            	String fn = String.valueOf(co) + "sin(x)";
            	Contribution con;
            	if ( i % 10 == 0 )
            	{
            		con = new Contribution(ContributionType.EQUATION, csu, se, "Y"+i, "h" + fn + "g", false );
            	}
            	else
            	{
            		 con = new Contribution(ContributionType.EQUATION, csu, se, "Y"+i, fn, true );
            	}
	    		con.save();
            }
            
            CodeCategory cca = new CodeCategory("Math");
            CodeCategory ccb = new CodeCategory("Social");
            CodeCategory ccc = new CodeCategory("Correctness");
            CodeDescriptor cda = new CodeDescriptor(cca, "ASMD");
            CodeDescriptor cdb = new CodeDescriptor(cca, "R1");
            CodeDescriptor cdb0 = new CodeDescriptor(cca, "R");
            CodeDescriptor cdb1 = new CodeDescriptor(cca, "M1");
            CodeDescriptor cdc = new CodeDescriptor(cca, "VASM");
            CodeDescriptor cde = new CodeDescriptor(cca, "A0");
            CodeDescriptor cdf = new CodeDescriptor(cca, "SNO");
            CodeDescriptor cdf1 = new CodeDescriptor(cca, "S");
            CodeDescriptor cdf2 = new CodeDescriptor(cca, "I");
            CodeDescriptor cdf3 = new CodeDescriptor(cca, "O");
            
            
            CodeDescriptor cdg = new CodeDescriptor(ccb, "BN");
            CodeDescriptor cdh = new CodeDescriptor(ccb, "MT");
            CodeDescriptor cdh1 = new CodeDescriptor(ccb, "N");
            CodeDescriptor cdh2 = new CodeDescriptor(ccb, "U");
            
            CodeDescriptor cdi = new CodeDescriptor(ccc, "CORRECT");
            CodeDescriptor cdj = new CodeDescriptor(ccc, "INCORRECT");
            
            cca.save();
            ccb.save();
            ccc.save();
            cda.save();
            cdb.save();
            cdb0.save();
            cdb1.save();
            cdc.save();
            cde.save();
            cdf.save();
            cdf1.save();
            cdf2.save();
            cdf3.save();
            
            cdg.save();
            cdh.save();
            cdh1.save();
            cdh2.save();
            cdi.save();
            cdj.save();
            
            CodeCategory cctest = CodeCategory.findByName("Math");
            CodeDescriptor cdtest = CodeDescriptor.findByCategoryAndName(cctest, "VASM");
            System.err.println("TEST - codedescriptor " + cdtest);
            System.err.println("TEST - codecategory: " + cctest);
            
            
        }
        
    }
 
}