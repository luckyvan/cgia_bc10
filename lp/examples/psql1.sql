-- table : book
--
-- Stores information about each book
CREATE TABLE book (
	book_id integer UNIQUE,
	name text NOT NULL,
	author integer NOT NULL,
	CONSTRAINT book_id_pkey PRIMARY KEY (book_id)
	);

-- table : authors
--
-- Stores information about each author
CREATE TABLE author (
	author_id integer UNIQUE,
	name text NOT NULL,
	CONSTRAINT author_id_pkey PRIMARY KEY (author_id)
	);

