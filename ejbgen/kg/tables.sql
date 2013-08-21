-- ==================================================================
--
--  WARNING : Do not edit this file by hand.  This file was created
--  by ejbgen.  Edit the definition files and re-generate to make
--  modifications.  Making modifications to this file directly will
--  result in loss of work when the file is re-generated.
--
--  ==================================================================


  drop table Book;

  create table Book ( 
    bookID integer not null primary key 
    ,title varchar(80) not null 
    ,ISBN varchar(80) not null unique 
    ,authorID integer not null 
    ,publisherID integer not null 
    ,status integer not null 
    ,numCopies integer not null 
  );

  grant all on Book to public;

  drop sequence Book_bookID_seq;

  create sequence Book_bookID_seq start 100;

  grant all on Book_bookID_seq to public;

  drop table Author;

  create table Author ( 
    authorID integer not null primary key 
    ,name varchar(80) not null unique 
    ,penName varchar(80) 
  );

  grant all on Author to public;

  drop sequence Author_authorID_seq;

  create sequence Author_authorID_seq start 100;

  grant all on Author_authorID_seq to public;

  drop table Publisher;

  create table Publisher ( 
    publisherID integer not null primary key 
    ,name varchar(80) not null unique 
  );

  grant all on Publisher to public;

  drop sequence Publisher_publisherID_seq;

  create sequence Publisher_publisherID_seq start 100;

  grant all on Publisher_publisherID_seq to public;

  alter table Book 
    add constraint Book_authorID
    foreign key (authorID)
    references Author (authorID);


  alter table Book 
    add constraint Book_publisherID
    foreign key (publisherID)
    references Publisher (publisherID);



-- ==================================================================
--
--  WARNING : Do not edit this file by hand.  This file was created
--  by ejbgen.  Edit the definition files and re-generate to make
--  modifications.  Making modifications to this file directly will
--  result in loss of work when the file is re-generated.
--
--  ==================================================================
