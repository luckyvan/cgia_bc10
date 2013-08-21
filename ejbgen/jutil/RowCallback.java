// RowCallback.java
package jutil;

import java.sql.*;

/**
 * Copy row from ResultSet into new Object
 */
public interface RowCallback {
  public Object process(ResultSet rs) throws SQLException;
}

