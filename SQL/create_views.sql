create group god;
create group simpleton;
create group candidates;
create group judges;


create role asghar login encrypted password 'golabi';
create role gholam login encrypted password 'golabi';

create view people as
select *
from (
        person as p
        join user_person up on p.id = up.person_id
         ) as pp
where (pp.username = (select user)) ;


grant SELECT on people to simpleton;


insert into region values (1, 0, 10);
insert into region values (2, 0, 3);
insert into person values (1234, 'asghar', 20, 10, NULL, 1);
insert into person values (12342, 'gholam', 20, 1, NULL, 2);

insert into user_person values ('asghar', 1234);
insert into user_person values ('gholam', 12342);

grant simpleton to asghar;
grant simpleton to gholam;

select * from people;