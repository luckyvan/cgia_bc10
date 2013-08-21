book:
  book_id - integer - unique
  name - text - not null
  author - integer - not null
  CONSTRAINT - book_id_pkey - 
Comment:
-- table : book
--
-- Stores information about each book

author:
  author_id - integer - unique
  name - text - not null
  CONSTRAINT - author_id_pkey - 
Comment:
-- table : authors
--
-- Stores information about each author

