  drop table Book;

  -- Book contains information about each book, the title, the author, the publisher, etc.
  --
  -- @field bookID The primary key id
  -- @field title The title of the book
  -- @field ISBN The ISBN number of the book
  -- @field authorID The author (as a foreign key relation)
  -- @field publisherID The publisher (as a foreign key relation)
  -- @field status The active or inactive state of the record
  -- @field numCompies The number of copies in the library
  -- @relates_to Author
  -- @relates_to Publisher
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

  -- Author contains information about the author of a set of books
  --
  -- @field authorID The primary key id
  -- @field name The name of the author
  -- @field penName The pen name of the author
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

  -- Publisher contains information about the author of a set of books
  --
  -- @field publisherID The primary key id
  -- @field name The name of the publisher
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
