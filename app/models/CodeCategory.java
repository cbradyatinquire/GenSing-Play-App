package models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class CodeCategory extends Model {

	@Required
	public String category;
	
	@OneToMany (mappedBy="ccategory", cascade=CascadeType.ALL)
	public List<CodeDescriptor>descriptors;

	public static CodeCategory findByName(String cat) {
		//String qu = "select c from CodeCategory c WHERE c.category = "+cat;
		//CodeCategory cc = CodeCategory.find(qu).first();
		//return cc;
		return find("byCategory", cat).first();
	}

	public CodeCategory( String cat )
	{
		this.category = cat;
	}
	
	public String toString() {
		return category;
	}
	
	
}
