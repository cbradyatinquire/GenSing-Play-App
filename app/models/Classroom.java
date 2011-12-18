package models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Classroom extends Model {
	
	@Required
	public String classname;

	@OneToMany
	public List<StudentUser>students;


	public Classroom( String name )
	{
		this.classname = name;
		students = new ArrayList<StudentUser>();
	}

	public static Classroom connect( String cname )
	{
		return find( "byClassname", cname).first();
	}

	@Override
	public String toString() { return classname;  }

	public String getName() { return classname; }
	
}
