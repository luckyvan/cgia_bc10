-- This is an example PostgreSQL file

CREATE TABLE books (
   book_id integer UNIQUE,
   name text NOT NULL,
   author text NOT NULL,
   CONSTRAINT book_id_pkey PRIMARY KEY (book_id)
   );

CREATE FUNCTION find_book( text ) RETURNS integer AS '
  DECLARE
    id integer;
  BEGIN
    SELECT INTO id book_id FROM books WHERE name = text;
    RETURN id;
  END;
  LANGUAGE 'plpgsql';

