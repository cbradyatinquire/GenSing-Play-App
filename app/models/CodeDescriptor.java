package models;


import java.util.List;

import javax.persistence.Entity;
import javax.persistence.ManyToOne;

import play.data.validation.Required;
import play.db.jpa.Model;


@Entity
public class CodeDescriptor extends Model {
	
	@Required
	public String descri;

        public String details;
	
	@Required
	@ManyToOne
	public CodeCategory ccategory;
	
	
	public CodeDescriptor( CodeCategory ca, String d)
	{
		this.descri = d;
		this.ccategory = ca;
	}
	
	public static CodeDescriptor connect(CodeCategory cc, String desc) {
		desc = desc.trim();
		return CodeDescriptor.find("byCcategoryAndDescri", cc, desc).first();
	}
	
	public String toString() {
		return ( ccategory.category + " " + descri );
	}
	
	public static  CodeDescriptor findByCategoryAndName(CodeCategory cc,
			String descri) {
		descri = descri.trim();
//		String qu = "select c from CodeDescriptor c WHERE c.ccategory = "+cc+" and c.descri = "+descri;
//		CodeDescriptor cd = CodeDescriptor.find(qu).first();
//		return cd;
		return find("byCcategoryAndDescri", cc, descri).first();
	}

	 public static  List<CodeDescriptor> findByCategory( CodeCategory cc ) {
         //String qu = "select c from CodeDescriptor c WHERE c.ccategory = " + cc;
         return find("byCcategory", cc).fetch();
        // return cds;
     }

	
}
