--10. Write a SQL queries to get the List of genres with the highest number of titles. 
insert into genres(genre_name,title_id)
values ('Documentaries',15),('Documentaries',16);

insert into titles(title,duration)
values ('Nobody Speak: Trials of the Free Press','96 min'),
('What the Health','92 min');

select g.genre_name, COUNT(t.title_id) AS highest_titles
FROM genres g inner join titles t ON g.title_id = t.title_id
GROUP BY g.genre_name
ORDER BY highest_titles desc;

--9.	Write a SQL queries to get the Average duration of movies. 
SELECT AVG(CONVERT(INT, LEFT(t.duration, PATINDEX('% [^0-9]%', t.duration ) - 1))) AS average_duration
FROM shows s
JOIN show_type st ON s.type_id = st.type_id
JOIN titles t ON s.title_id = t.title_id
WHERE st.type_name = 'Movie' ;

--8.Write a SQL queries to List of directors and the number of movies/TV shows they have directed. 
insert into Shows(show_id,title_id,type_id,country,date_added,release_year,rating,description)
values ('s6447',14,1,'United Kingdom and United States','2020-01-01','2005','PG','The eccentric Willy Wonka opens the doors of his candy factory to five lucky kids who learn the secrets behind his amazing confections.');

insert into titles(title,duration)
values ('Charlie and the Chocolate Factory','115 min');

insert into directors(director_name,title_id)
values ('Tim Burton',14);

SELECT d.director_name, COUNT(d.title_id) AS number_of_shows
FROM directors d
JOIN titles t ON d.title_id = t.title_id
GROUP BY d.director_name;

--7.Write a SQL queries to find Number of movies released in a specific year.

select COUNT(*) AS num_of_movies from shows
 join show_type ON shows.type_id = show_type.type_id
where show_type.type_name = 'Movie' AND shows.release_year = 2020;

--6.	Write a SQL queries to extract Total number of TV shows

select * from shows join show_type on shows.type_id=show_type.type_id;

SELECT COUNT(*) AS total_tv_shows
FROM shows
JOIN show_type ON shows.type_id = show_type.type_id
WHERE show_type.type_name = 'TV Show';

--5.Create a View named LongestMovies that displays the top 10 longest movies from the Titles table, including the title and duration in minutes

create view longestMovies as
select top 10
  title, 
  CAST(SUBSTRING(duration, 1, LEN(duration) - 4) AS INT) AS duration_in_minutes
from  titles where duration LIKE '% min' 
order by duration_in_minutes desc;

select * from longestMovies;

insert into Shows(show_id,title_id,type_id,country,date_added,release_year,rating,description)
values('s8765',13,1,'United States','2020-01-01',1994,'PG-13','Legendary lawman Wyatt Earp is continually at odds with a gang of renegade cowboys, culminating in a fiery showdown with the outlaws at the OK Corral.');

insert into titles(title,duration)
values 
('Hum Aapke Hain Koun','193 min'),
('English Babu Desi Mem','163 min'),
('Barsaat','166 min'),
('Pardes','187 min'),
('Raja Hindustani','177 min'),
('Trimurti','173 min'),
('Wyatt Earp','191 min');

--4.	Write a SQL query to delete all records from the Movies table where the release_year is before 2000. 

Delete from Shows
where release_year < 2000
and show_id in (
    select show_id
    from show_type st
    where st.type_name = 'Movie'
);

select * from Shows;
select * from titles;
insert into Shows(show_id,title_id,type_id,country,date_added,release_year,rating,description)
values('s162',5,1,'United States','2021-09-01',1996,'PG-13','As flying saucers head for Earth, the president of the United States prepares to welcome alien visitors but soon learns theyre not coming in peace.');

insert into show_type(type_id,type_name)
values(1,'Movie'),
(2,'TV Show');

insert into titles(title,duration)
values ('Mars Attacks!','106 min');
delete from titles where title_id=6;


insert into directors(director_name,title_id)
values ('Tim Burton',5);

insert into actors(actor_name,title_id)
values ('Jack Nicholson',5);

insert into genres(genre_name,title_id)
values ('Comedies',5),
('Cult Movies',5),
('Sci-Fi & Fantasy',5);


--3.	Write a SQL query to update the duration of the movie with show_id 12345 in the Movies table to 120 minutes. 
select * from shows;
select * from show_type;
select * from titles;
insert into Shows(show_id,title_id,type_id,country,date_added,release_year,rating,description)
values ('12345',18,1,null,null,null,null,null);
insert into titles(title,duration)
values ('NA','NA');

update titles
set duration = '120 min'
where title_id = (
    select title_id
    from Shows
    where show_id = '12345');
--2 
select s.show_id,t.title,st.type_name,t.duration,s.country,s.date_added,s.release_year,s.rating,s.description
from  shows s
inner join titles t on s.title_id = t.title_id
inner join show_type st on s.type_id = st.type_id
where  s.release_year = 2020 and st.type_name = 'Movie';


--1.--Write a SQL query to add a new record to the Movies table for a movie titled
--"The Great Adventure" directed by "John Smith" with a release year of 2023 
--and a duration of 150 minutes. 
 insert into titles (title, duration)
    values ('The Great Adventure', '150 min');
	select * from titles;
insert into directors (director_name, title_id)
    values ('John Smith', 1);
	insert into show_type (type_name)
    values ( 'Movie');
	insert into genres ( genre_name, title_id)
    values ('Adventure', 1);
	insert into Shows (show_id, title_id,type_id,country, date_added, release_year, rating, description)
    values ('s8810', 1,1, null, null, '2023', null, null);

select  t.title, d.director_name, s.release_year, t.duration from Shows s
join titles t on s.title_id = t.title_id
join directors d ON s.title_id = d.title_id
where t.title = 'The Great Adventure'
    and d.director_name = 'John Smith'
    and s.release_year = 2023
    and t.duration = '150 min';