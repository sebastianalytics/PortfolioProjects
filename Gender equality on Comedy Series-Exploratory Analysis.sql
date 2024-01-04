-- Counting total number of men and women, indistinct if director or writer
SELECT gender.name, COUNT (*) 
FROM people 
JOIN gender ON people.gender_id = gender.id
WHERE gender.name IN ('Male', 'Female')
GROUP BY gender.name

-- Counting number of men and women directors
SELECT
	gender.name AS director_gender,
	COUNT (*) AS count
FROM director
JOIN people ON director.people_id = people.id
JOIN gender ON people.gender_id = gender.id
WHERE gender.name IN ('Male', 'Female')
GROUP BY gender.name

-- Counting number of men and women writers
SELECT
	gender.name AS writer_gender,
	COUNT (*) AS count
FROM writer
JOIN people ON writer.people_id = people.id
JOIN gender ON people.gender_id = gender.id
WHERE gender.name IN ('Male', 'Female')
GROUP BY gender.name

-- Counting number of episodes directed by each gender
SELECT
    gender.name AS Gender,
    COUNT(*) AS episodes_directed_by
FROM episodes
JOIN director ON episodes.director_id = director.id
JOIN people ON director.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY gender.name;
	
-- Counting number of episodes written by each gender
SELECT
    gender.name AS Gender,
    COUNT(*) AS episodes_written_by
FROM episodes
JOIN writer ON episodes.writer_id = writer.id
JOIN people ON writer.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY gender.name;

-- Counting number of episodes directed by each gender per year
SELECT
    gender.name AS Gender,
    COUNT(*) AS episodes_directed_by,
	year
FROM episodes
JOIN director ON episodes.director_id = director.id
JOIN people ON director.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY year, gender.name
ORDER BY episodes_directed_by desc;

-- Counting number of episodes written by each gender per year
SELECT
    gender.name AS Gender,
    COUNT(*) AS episodes_written_by,
	year
FROM episodes
JOIN writer ON episodes.writer_id = writer.id
JOIN people ON writer.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY gender.name, year
ORDER BY episodes_written_by desc;

-- Most common directors
SELECT 
	director.name AS director,
	COUNT (*) AS episodes_directed,
	gender.name AS gender
FROM episodes
JOIN director ON episodes.director_id = director.id
JOIN people ON director.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY director.name, gender.name
ORDER BY episodes_directed desc;

-- Most common writers
SELECT 
	writer.name AS writer,
	COUNT (*) AS episodes_written,
	gender.name AS gender
FROM episodes
JOIN writer ON episodes.writer_id = writer.id
JOIN people ON writer.people_id = people.id
JOIN gender ON people.gender_id = gender.id
GROUP BY writer.name, gender.name
ORDER BY episodes_written desc;

-- Compare IMDB rating vs Director Gender
SELECT
    s.title AS Series,
    COUNT(CASE WHEN g.name = 'Male' THEN 1 END) AS Male_Director,
	COUNT(CASE WHEN g.name = 'Female' THEN 1 END) AS Female_Director,
    s.imdb_rating
FROM
    series s
JOIN episodes e ON s.id = e.series_id
JOIN director d ON e.director_id = d.id
JOIN people p ON d.people_id = p.id
JOIN gender g ON p.gender_id = g.id
GROUP BY s.title, s.imdb_rating
ORDER BY imdb_rating desc;

-- Compare IMDB rating vs Writer Gender
SELECT
    s.title AS Series,
    COUNT(CASE WHEN g.name = 'Male' THEN 1 END) AS Male_Writer,
	COUNT(CASE WHEN g.name = 'Female' THEN 1 END) AS Female_Writer,
    s.imdb_rating
FROM
    series s
JOIN episodes e ON s.id = e.series_id
JOIN writer w ON e.director_id = w.id
JOIN people p ON w.people_id = p.id
JOIN gender g ON p.gender_id = g.id
GROUP BY s.title, s.imdb_rating
ORDER BY imdb_rating desc;