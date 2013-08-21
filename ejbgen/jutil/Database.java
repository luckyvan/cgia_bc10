// Database.java
package jutil;

import java.sql.*;
import java.util.*;
import jutil.RowCallback;
// uses Struts connection pooling 
import org.apache.struts.util.*;

/**
 * Simple wrapper for JDBC.
 */
public class Database {
  private static GenericDataSource dataSource = null;

  static {
    try {
      dataSource = new GenericDataSource();
      dataSource.setAutoCommit(true);
      dataSource.setDriverClass("org.postgresql.Driver");
      dataSource.setMaxCount(4);
      dataSource.setMinCount(1);
      dataSource.setUrl("jdbc:postgresql://localhost/test");
      dataSource.setUser("dwarf");
      dataSource.open();
    }catch(Exception e){
      throw new RuntimeException("ERROR in Database init: " + e.getMessage());
    }
  }

  static public Collection runSql(String sql, RowCallback rowCallback) {
    return runSql(sql, rowCallback, null);
  }

  /**
   *  Exceutes SQL statement, binding parameters if specified, and returns
   *  Collection result.
   *  @param sql         SQL statement.
   *  @param rowCallback A class with a "process" method which copies ResultSet into
   *                     chosen return Object.
   *  @param params      Optional List of Objects which will be bound as query 
   *                     parameters.
   *  @return            Collection of chosen return Objects.
   */
  static public Collection runSql(String sql, RowCallback rowCallback, 
    List params) 
  {
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try{
      conn = dataSource.getConnection();
      stmt = conn.prepareStatement(sql);  
      stmt.clearParameters();

      if(params != null){
        int index = 1;

        for(Iterator i = params.iterator(); i.hasNext(); )
          stmt.setObject(index++,i.next());
      }
        
      if(!stmt.execute())
        return null;

      rs = stmt.getResultSet();
      java.util.Collection res = new java.util.LinkedList();

      while(rs.next()){
        res.add(rowCallback.process(rs));
      }

      rs.close();
      stmt.close();
      return res;
    } catch(java.sql.SQLException e){
      throw new RuntimeException("SQL Failure: " + e.getMessage());
    }finally{
      try {
        if(conn != null) conn.close();
      }catch(java.sql.SQLException e){
        throw new RuntimeException("SQL Failure: " + e.getMessage());
      }
    }
  }

  /**
   *  Returns first row from Collection
   */
  public static Object firstRow(Collection coll){
    if(coll == null) return null;
    return ((java.util.LinkedList)coll).getFirst();
  }
}
