create table Shows(
show_id varchar(10) primary key,
title_id int,
type_id int,
country varchar(50),
date_added date,
release_year smallint,
rating varchar(10),
description text,
FOREIGN KEY (title_id) REFERENCES titles(title_id),
FOREIGN KEY (type_id) REFERENCES show_type(type_id));

create table show_type(
type_id int primary key identity (1,1),
type_name varchar(10));

create table directors(
director_id int primary key identity (1,1),
director_name varchar(50),
title_id int not null,
FOREIGN KEY (title_id) REFERENCES titles(title_id));

create table actors(
actor_id int primary key identity (1,1),
actor_name varchar(50),
title_id int not null,
FOREIGN KEY (title_id) REFERENCES titles(title_id));

create table titles(
title_id int primary key identity(1,1),
title varchar(250) not null,
duration varchar(20),
);
create table genres(
genre_id int primary key identity(1,1),
genre_name varchar(250),
title_id int not null,
FOREIGN KEY (title_id) REFERENCES titles(title_id)
);

select * from shows;
select * from show_type;
select * from genres;
select * from directors;
select * from actors;
select * from titles;
