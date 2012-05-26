package models;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Visualizers {
	
	public static String spiralHTML = "<SPIRAL HTML WOULD GO HERE>";
	public static String waveHTML = "<WAVE HTML WOULD GO HERE>";
	
	public static ArrayList<String> names = new ArrayList<String>();
	public static HashMap<String,String> vizMap = new HashMap<String,String>();
	static
	{
		names.add("Spiral");
		names.add("Wave");
		vizMap.put("Spiral", spiralHTML);
		vizMap.put("Wave", waveHTML);
	}

	public static List<String>  getNames() {
		return names;
	}
	
	public static String getHTMLFor( String viz )
	{
		return vizMap.get(viz);
	}

}
