package models;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.Lob;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

import play.data.validation.Required;
import play.db.jpa.Model;

@Entity
public class Coding extends Model {
	
	@Required
	@ManyToOne
	public Contribution codedContrib;
	
	
	public String descrip;
	public String categ;
	
	//@ManyToMany(cascade=CascadeType.PERSIST)
	public CodeDescriptor descriptor;
	
	//public CodeCategory category;
	
	public String note;
	
	
	public Coding(Contribution c, String cat, String des ) {
		this.codedContrib = c;
		//this.desc = cd;
		//this.note = "hi there";
		this.categ = cat;
		this.descrip = des; 
//		CodeCategory category = CodeCategory.findByName(cat);
//		System.err.println("Category is " + category + " string value = " + cat);
//		List<CodeDescriptor> possibles = category.descriptors;
//		for ( CodeDescriptor p : possibles )
//		{
//			if ( des.equals(p.desc) )
//			{
//				CodeDescriptor descriptor = p;
//				System.err.println(descriptor);
//			}
//		}
		
	}
	
//	public Coding(Contribution c, CodeDescriptor cd) {
//		//CodeDescriptor descrip = CodeDescriptor.findByName(descrip);
//		this.codedContrib = c;
//		this.descriptor = cd;
//	}
	
	public String toString() {
		if (descrip != null)
			return "Cat: " + categ + " Desc: " + descrip + "- Coding for Contribution " + codedContrib.toString(); 
		else
			return "Note: " + note + "- Coding for Contribution " + codedContrib.toString(); 
	}


}
