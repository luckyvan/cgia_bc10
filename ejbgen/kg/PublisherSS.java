// ==================================================================
//
// WARNING : Do not edit this file by hand.  This file was created
// by ejbgen.  Edit the definition files and re-generate to make
// modifications.  Making modifications to this file directly will
// result in loss of work when the file is re-generated.
//
// ==================================================================
//
// PublisherSS.java

package gen;

import javax.ejb.EJBObject;
import java.rmi.RemoteException;
import java.util.Collection;
import gen.*;

public interface PublisherSS extends EJBObject {
  public PublisherValue getPublisherValue(
    Integer publisherID
    ) throws RemoteException;

  /**  
    * returns Collection of PublisherValue  
    */  
  public java.util.Collection getAllPublisherValue(
    ) throws RemoteException;

  public Integer add(
    PublisherValue value
    ) throws RemoteException;

  public void update(
    PublisherValue value
    ) throws RemoteException;

  public void delete(
    Integer publisherID
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
