// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
//
// BookSS.java

package gen;

import javax.ejb.EJBObject;
import java.rmi.RemoteException;
import java.util.Collection;
import gen.*;

public interface BookSS extends EJBObject {
  public BookValue getBookValue(
    Integer bookID
    ) throws RemoteException;

  /**  
    * returns Collection of BookValue  
    */  
  public java.util.Collection getAllBookValue(
    ) throws RemoteException;

  public Integer add(
    BookValue value
    ) throws RemoteException;

  public void update(
    BookValue value
    ) throws RemoteException;

  public void delete(
    Integer bookID
    ) throws RemoteException;

  public BookWithNamesValue getBookWithNamesValue(
    Integer bookID
    ) throws RemoteException;

  /**  
    * returns Collection of BookWithNamesValue  
    */  
  public java.util.Collection getAllBookWithNamesValue(
    ) throws RemoteException;

  /**  
    * returns Collection of BookWithNamesValue  
    */  
  public java.util.Collection getAllByTitle(
    String title
    ) throws RemoteException;

  /**  
    * returns Collection of BookWithNamesValue  
    */  
  public java.util.Collection getAllByAuthorName(
    String authorName
    ) throws RemoteException;

  public void updateStatusByPublisher(
    Integer publisherID
    ,Integer newStatus
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
