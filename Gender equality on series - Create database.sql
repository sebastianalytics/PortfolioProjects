-- Create tables

CREATE TABLE series_raw (
    title VARCHAR(128) UNIQUE,
    year_released INTEGER,
    imdb_rating DECIMAL
);

CREATE TABLE series (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    year_released INTEGER,
    imdb_rating DECIMAL,
    PRIMARY KEY (id)
);

CREATE TABLE gender (
    id SERIAL,
    name VARCHAR(10) UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE people (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    gender VARCHAR (10) REFERENCES gender(name),
    gender_id INTEGER REFERENCES gender(id),
    PRIMARY KEY (id)
);

CREATE TABLE director (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    people_id INTEGER REFERENCES people(id),
    PRIMARY KEY (id)
);

CREATE TABLE writer (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    people_id INTEGER REFERENCES people(id),
    PRIMARY KEY (id)
);

CREATE TABLE episodes (
    id SERIAL,
    series VARCHAR(128),
    series_id INTEGER REFERENCES series(id) ON DELETE CASCADE,
    season INTEGER,
    season_episode INTEGER,
    episode INTEGER,
    director VARCHAR(128),
    director_id INTEGER REFERENCES director(id) ON DELETE CASCADE,
    d_gender VARCHAR(10),
    writer VARCHAR(128),
    writer_id INTEGER REFERENCES writer(id) ON DELETE CASCADE,
    w_gender VARCHAR(10),
    year INTEGER,
    PRIMARY KEY (id)
);
-- Copy data from csv files into tables
\copy episodes(series,season,season_episode,episode,director,d_gender,writer,w_gender,year) FROM 'C:\Users\Asus\Documents\Data Analytics\Projects\Comedy Writers gender since 2000.csv' WITH DELIMITER ';' CSV;

\copy series_raw(title,year_released,imdb_rating) FROM 'C:\Users\Asus\Documents\Data Analytics\Projects\series.csv' WITH DELIMITER ';' CSV;

-- Update director and writer columns for groups based on gender
UPDATE episodes
SET director = 
    CASE
        WHEN director = 'Group' AND d_gender = 'Male' THEN 'Male Group'
        WHEN director = 'Group' AND d_gender = 'Female' THEN 'Female Group'
        WHEN director = 'Group' AND d_gender = 'Both' THEN 'Both Group'
        ELSE director 
    END,
    writer = 
    CASE
        WHEN writer = 'Group' AND w_gender = 'Male' THEN 'Male Group'
        WHEN writer = 'Group' AND w_gender = 'Female' THEN 'Female Group'
        WHEN writer = 'Group' AND w_gender = 'Both' THEN 'Both Group'
        ELSE writer
    END;


-- Populate series, gender and people tables
INSERT INTO series (title,year_released,imdb_rating)
    SELECT * FROM series_raw
    ORDER BY title;

INSERT INTO gender(name)
    SELECT DISTINCT d_gender FROM episodes;

INSERT INTO people (name, gender)
SELECT name, gender
FROM (
    SELECT DISTINCT director AS name, d_gender AS gender
    FROM episodes
    WHERE director IS NOT NULL
    UNION
    SELECT DISTINCT writer AS name, w_gender AS gender
    FROM episodes
    WHERE writer IS NOT NULL
) AS unique_names
ORDER BY name
ON CONFLICT (name) DO NOTHING;

-- Add gender.id based on gender
UPDATE people SET gender_id = (SELECT gender.id FROM gender WHERE people.gender = gender.name);

-- Populate director and writer tables
INSERT INTO director (name)
SELECT DISTINCT director FROM episodes
ORDER BY director;

INSERT INTO writer (name)
SELECT DISTINCT writer FROM episodes
ORDER BY writer;

-- Asign people_id on director and writer tables
UPDATE director SET people_id = (SELECT people.id FROM people WHERE people.name = director.name);
UPDATE writer SET people_id = (SELECT people.id FROM people WHERE people.name = writer.name);

-- Update episodes table
UPDATE episodes 
SET 
    series = 
        CASE 
            WHEN series = '∩╗┐Rick and Morty' THEN 'Rick and Morty'
            WHEN series = 'How I Met your Mother' THEN 'How I Met Your Mother'
            WHEN series = 'The White lotus' THEN 'The White Lotus'
            ELSE series
        END,
    series_id = (SELECT series.id FROM series WHERE series.title = episodes.series),
    director_id = (SELECT id FROM director WHERE name = episodes.director),
    writer_id = (SELECT id FROM writer WHERE name = episodes.writer);

-- CLEANING DATA --
-- Look for errors on writer column
SELECT DISTINCT e1.writer, e1.w_gender
FROM episodes e1
WHERE EXISTS (
    SELECT 1
    FROM episodes e2
    WHERE e1.writer = e2.writer
      AND e1.w_gender <> e2.w_gender
);

SELECT * FROM people 
WHERE name IN 
('Daisy Gardner','Megan Amram','B. J. Novak', 'Daniel Palladino','Jennie Snyder','Alexandra Rushfield','J. J. Philbin','Amy Sherman-Palladino',);

-- Update data based on errors
UPDATE people 
    SET gender_id = 
        CASE
            WHEN id = 279 then 2
            WHEN id = 169 then 1
            WHEN id = 110 then 2
            WHEN id = 462 then 2
            ELSE gender_id
        END
;

-- Look for errors on director column
SELECT DISTINCT e1.director, e1.d_gender
FROM episodes e1
WHERE EXISTS (
    SELECT 1
    FROM episodes e2
    WHERE e1.director = e2.director
      AND e1.d_gender <> e2.d_gender
);

SELECT * FROM people 
WHERE name IN 
('Rob Greenberg','Kyounghee Lim','Jamie Babbit');

UPDATE people SET gender_id = 1 WHERE id = 912;

-- Delete redundant columns on episodes and people tables
ALTER TABLE episodes DROP COLUMN director;
ALTER TABLE episodes DROP COLUMN d_gender;
ALTER TABLE episodes DROP COLUMN writer;
ALTER TABLE episodes DROP COLUMN w_gender;
ALTER TABLE episodes DROP COLUMN series;
ALTER TABLE people DROP COLUMN gender;