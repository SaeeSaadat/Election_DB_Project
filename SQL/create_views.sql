create view people as
select *
from (
        person as p
        join user_person up on p.id = up.person_id
         ) as pp
where (pp.username = (select user)) ;
grant SELECT on people to simpleton;

