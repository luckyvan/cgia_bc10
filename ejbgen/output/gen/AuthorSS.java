// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
//
// AuthorSS.java

package gen;

import javax.ejb.EJBObject;
import java.rmi.RemoteException;
import java.util.Collection;
import gen.*;

public interface AuthorSS extends EJBObject {
  public AuthorValue getAuthorValue(
    Integer authorID
    ) throws RemoteException;

  /**  
    * returns Collection of AuthorValue  
    */  
  public java.util.Collection getAllAuthorValue(
    ) throws RemoteException;

  public Integer add(
    AuthorValue value
    ) throws RemoteException;

  public void update(
    AuthorValue value
    ) throws RemoteException;

  public void delete(
    Integer authorID
    ) throws RemoteException;


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
