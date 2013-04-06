package controllers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import models.CodeCategory;
import models.CodeDescriptor;
import models.Contribution;
import models.School;

import com.google.gson.Gson;

import play.db.jpa.JPABase;
import play.mvc.*;

public class TestJSON extends Controller {

	public static void setupForTest() {
		render();
	}
	
	
	public static void testJSON( String echo ) {

//		HashMap<String, String> hm = new HashMap<String, String>();
//		List<Contribution> contribs = Contribution.findAll();
//    	for (Contribution c : contribs)
//    	{
//    		hm.put( "id"+c.getId(), c.body );
//    	}
		HashMap<String,List<String>> dict = new HashMap<String,List<String>>();
		List<CodeCategory> ccs = CodeCategory.findAll();
		for (CodeCategory cc : ccs )
		{
			ArrayList<String> dlist = new ArrayList<String>();
			for (CodeDescriptor cd :  cc.descriptors )
			{
				dlist.add( cd.descri );
			}
			dict.put(cc.category, dlist);
		}
    	com.google.gson.Gson gson = new Gson();
    	String json = gson.toJson(dict);
    	renderJSON( json );
    }
}
