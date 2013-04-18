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

public class JSONCodeDictionary extends Controller {

    public static void annotate() {
	render();
    }

	public static void getJSONCodeDictionary( String echo ) {
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
               
                ArrayList<String> clist = new ArrayList<String>();
                for( CodeCategory cc : ccs ) {
		    clist.add( cc.category );
                } 
                dict.put( "codeCategories", clist );
		
		ArrayList<String> funentry = new ArrayList<String>();
		funentry.add("function() { alert('hello there.  this alert function definition came from the server'); }");
		dict.put("testfn", funentry );

                ArrayList<String> funGetCategory = new ArrayList<String>();
                funGetCategory.add("function( citem ) { var dself = mydict; for( var member in dself ) { var tempArr = eval( 'dself.' + member + '.valueOf()' ); if( tempArr instanceof Array && tempArr.indexOf( citem ) > -1 ) { return member; } } return 'ERR- No matching Code Category found'; }");
		dict.put( "getCategory", funGetCategory );                
            
		
      

    	com.google.gson.Gson gson = new Gson();
    	String json = gson.toJson(dict);
    	renderJSON( json );
    }
}
