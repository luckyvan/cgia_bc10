// Sequence.java
package jutil;

import java.sql.*;
import jutil.Database;

/**
  * Access Postgresql sequence generators
  */
public class Sequence {
  /**
   * Returns next value in sequence 
   */
  public static Integer next(String sequenceName) {
    Integer res = null;
    String sql = "select nextval('" + sequenceName + "')";
    
    res = (Integer)Database.firstRow(Database.runSql(sql,
      new RowCallback(){
        public Object process(ResultSet rs) throws SQLException { 
          return new Integer(rs.getInt(1));
        }
      }
    ));

    if(res == null){
      throw new RuntimeException("Postgresql sequence " + sequenceName + 
        " failed");
    }

    return res;
  }
}

