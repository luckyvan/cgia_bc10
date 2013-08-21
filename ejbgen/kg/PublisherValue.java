// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
//
// PublisherValue.java

package gen;

import java.sql.ResultSet;
import java.sql.SQLException;

public class PublisherValue implements java.io.Serializable {
  // private member variables
  private Integer publisherID;
  private String name;

  // empty constructor
  public PublisherValue(){
    publisherID = null; 
    name = null; 
  }

  // ResultSet constructor
  public PublisherValue(ResultSet rs) throws SQLException {

    if(rs.getObject(1) != null)
      publisherID = new Integer(rs.getInt(1));
    else
      publisherID = null;

    name = rs.getString(2);
  }

  // member variable getters and setters
  
  public Integer getPublisherID() { return publisherID; }
  public void setPublisherID(Integer publisherID){ this.publisherID = publisherID; }
  
  public String getName() { return name; }
  public void setName(String name){ this.name = name; }
}

//
// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
