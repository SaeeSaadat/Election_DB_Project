create view people as
select *
from (
        person as p
        join user_person up on p.id = up.person_id
         ) as pp
where (pp.username = (select user)) ;

grant SELECT on people to simpleton;


select * from people;

select * from person;


create view my_votes as
select *
from ( select v.*, up.username from
     vote as v
     join user_person as up on v.person_id = up.person_id
         ) as t
where t.username = (select user) ;

select * from my_votes;

drop view my_votes;

grant select on my_votes to simpleton;