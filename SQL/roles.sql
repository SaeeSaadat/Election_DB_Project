create group god; --it's just for show! gods are already gods! (saee & postgres)
create group simpleton;
create group candidates;
create group judges;

create role saee superuser createdb createrole replication bypassrls  encrypted password 'god';
create role alireza superuser createdb createrole replication bypassrls  encrypted password 'god';
grant god to saee;
grant god to alireza;


create role asghar login encrypted password 'golabi';
create role gholam login encrypted password 'golabi';

insert into region values (1, 0, 10);
insert into region values (2, 0, 3);
insert into person values (1234, 'asghar', 20, 10, NULL, 1);
insert into person values (12342, 'gholam', 20, 1, NULL, 2);

insert into user_person values ('asghar', 1234);
insert into user_person values ('gholam', 12342);


grant simpleton to asghar;
grant simpleton to gholam;
