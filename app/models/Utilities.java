package models;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import play.db.jpa.Model;

public class Utilities extends Model {
	
	public static final String DATE_FORMAT_NOW = "yyyy-MM-dd_HH-mm-ss";
	public static final SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);

	public static String getStringForDate( Date d ) {
	    return sdf.format(d);
	  }

	
	public static Date getTstamp() {
		Calendar cal = Calendar.getInstance();
	    return cal.getTime();
	}

	public static List<Object> executeQuery( String dbquery )
	{
		return find(dbquery).fetch();
	}
}
