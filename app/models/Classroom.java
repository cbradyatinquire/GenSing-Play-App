package models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Classroom extends Model {
	
	@Required
	public String classname;
	
	@Required
	@ManyToOne
	public Teacher teacher;
	
	@Required
	public int startYear;

	@OneToMany (mappedBy="classroom", cascade=CascadeType.ALL)
	public List<StudentUser>students;

	@Lob
    public String annotation;
	
	@Required
	@OneToOne // (mappedBy="classroom", cascade=CascadeType.ALL)
	public Activity current = null;
	

	public Classroom( String name )
	{
		this.classname = name;
		students = new ArrayList<StudentUser>();
	}
	
	public void setCurrentActivity( Activity curr )
	{
		current = curr;
	}
	public Activity getCurrentActivity()
	{
		return current;
	}


	public static Classroom connect( String cname )
	{
		List<Classroom> classes = find( "byClassname", cname ).fetch();
		if (classes.size() == 1)
			return classes.get(0);
		else
			return null;
	}
	
	public static Classroom connect( String cname, int year )
	{
		return find( "byClassnameAndStartyear", cname, year).first();
	}

	@Override
	public String toString() { return classname;  }

	public String getName() { return classname; }
	
}
