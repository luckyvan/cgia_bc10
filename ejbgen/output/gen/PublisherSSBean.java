// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
//
// PublisherSSBean.java

package gen;

import javax.ejb.SessionBean;
import javax.ejb.EJBException;
import java.util.*;
import javax.naming.InitialContext;
import javax.ejb.SessionContext;
import jutil.Database;
import jutil.RowCallback;
import java.sql.ResultSet;
import java.sql.SQLException;
import gen.*;

public class PublisherSSBean implements SessionBean {
  public static PublisherSSHome getHome(){
    try {
      InitialContext jndiContext = new InitialContext();
      Object ref =
        jndiContext.lookup("gen/PublisherSS");
      PublisherSSHome home = (PublisherSSHome)ref;
      return home;
    }catch (Exception e){
      throw new EJBException( "PublisherSSBean.getHome() failed: " + e.getMessage());
    }
  }

  // ===================================================================
  // SQL selects for each value object
  private static String selectPublisherValue = "select Publisher.publisherID, Publisher.name from Publisher ";

  // ===================================================================
  // SSB methods
  
  //--------------------------------------------------------------------
  public PublisherValue getPublisherValue(
    Integer publisherID
    ) 
  {
    try {
      List params = new LinkedList();
      params.add(publisherID);
  
      return 
       (PublisherValue)Database.firstRow(
         Database.runSql(
          selectPublisherValue
           + " where "
           + " Publisher.publisherID = ? "
            ,new RowCallback(){
            public Object process(ResultSet rs) throws SQLException {
              return new PublisherValue(rs);
            }
          }
          , params
       )
      );
    } catch (Exception e) {
      throw new EJBException( "PublisherSSBean.getPublisherValue() failed: " + e.getMessage());
    }
  }
  
  //--------------------------------------------------------------------
  /**
    * returns Collection of PublisherValue
    */
  public java.util.Collection getAllPublisherValue(
    ) 
  {
    try {
  
      return 
         Database.runSql(
          selectPublisherValue
            ,new RowCallback(){
            public Object process(ResultSet rs) throws SQLException {
              return new PublisherValue(rs);
            }
          }
      );
    } catch (Exception e) {
      throw new EJBException( "PublisherSSBean.getAllPublisherValue() failed: " + e.getMessage());
    }
  }
  
  //--------------------------------------------------------------------
  public Integer add(
    PublisherValue value
    ) 
  {
    try {
      PublisherEntityHome entityHome = PublisherEntityBean.getHome(); 
      PublisherEntity entity = entityHome.create(
        value.getPublisherID()
        ,value.getName()
      );
      return entity.getPublisherID();
    } catch (Exception e) {
      throw new EJBException( "PublisherSSBean.add() failed: " + e.getMessage());
    }
  }
  
  //--------------------------------------------------------------------
  public void update(
    PublisherValue value
    ) 
  {
    try {
      PublisherEntityHome entityHome = PublisherEntityBean.getHome(); 
      PublisherEntity entity = entityHome.findByPrimaryKey(
        value.getPublisherID());
      entity.setName(value.getName());

    } catch (Exception e) {
      throw new EJBException( "PublisherSSBean.update() failed: " + e.getMessage());
    }
  }
  
  //--------------------------------------------------------------------
  public void delete(
    Integer publisherID
    ) 
  {
    try {
      PublisherEntityHome entityHome = PublisherEntityBean.getHome(); 
      entityHome.remove(publisherID);
    } catch (Exception e) {
      throw new EJBException( "PublisherSSBean.delete() failed: " + e.getMessage());
    }
  }

  public void ejbCreate() {} 
  public void ejbPostCreate() {} 
  public void ejbRemove() {} 
  public void ejbActivate() {} 
  public void ejbPassivate() {} 
  public void setSessionContext(SessionContext sc) {} 
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