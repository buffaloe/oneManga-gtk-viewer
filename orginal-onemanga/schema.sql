PRAGMA auto_vacuum = 1;
PRAGMA encoding = "UTF-8";
PRAGMA user_version = 4;

-- The oneManga table for holding all of the records assoricated with a single
-- manga
CREATE TABLE manga (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	title TEXT NOT NULL,
	ranking INTEGER NOT NULL,
	aka TEXT,
--	aka_id INTEGER  --- Ideally would like to link all of the alts to the same record or something
	status_id INTEGER, --NOT NULL,
	status TEXT NOT NULL,
	title_url TEXT,
	max_chapters INTEGER,
	last_update TEXT NOT NULL,
--	last_update DATE NOT NULL
	author TEXT,
	artist TEXT,
	summary TEXT,
--	cover BLOB

	CONSTRAINT status_id_fk FOREIGN KEY(status_id) 
	    REFERENCES status_type(id) 
	    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- The Categories table that assorcates the manga with its categories
CREATE TABLE categories (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	manga_id INTEGER NOT NULL,
	categories_type_id INTEGER NOT NULL,

	CONSTRAINT manga_id_fk FOREIGN KEY(manga_id) 
	    REFERENCES manga(id) 
	    ON UPDATE CASCADE ON DELETE RESTRICT,
	
	CONSTRAINT categories_type_id_fk FOREIGN KEY(categories_type_id) 
	    REFERENCES categories_type(id) 
	    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- the types of categories that there are such as action, love, etc..
CREATE TABLE categories_type (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	categories TEXT NOT NULL
);

-- The types of status
CREATE TABLE status_type (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	status TEXT NOT NULL
);

-- The oneManga table for holding all of the chapters record
CREATE TABLE chapters (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	manga_id INTEGER NOT NULL,
	chapter_name TEXT NOT NULL,
	chapter_url TEXT NOT NULL,
--	first_page_url TEXT,
	scans_by TEXT NOT NULL,
	date_added DATE NOT NULL,

	CONSTRAINT manga_id_fk FOREIGN KEY(manga_id) 
	    REFERENCES manga(id) 
	    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- The oneManga table for holding all of the pages record
CREATE TABLE pages (
	id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	manga_id INTEGER NOT NULL,
	chapter_id INTEGER NOT NULL,
	page_number INTEGER NOT NULL,
	page_url TEXT NOT NULL,

	CONSTRAINT manga_id_fk FOREIGN KEY(manga_id) 
	    REFERENCES manga(id) 
	    ON UPDATE CASCADE ON DELETE RESTRICT,

	CONSTRAINT chapter_id_fk FOREIGN KEY(chapter_id)
	    REFERENCES chapters(id)
	    ON UPDATE CASCADE ON DELETE RESTRICT
);
