create table region (
    id serial primary key ,
    current_agents int,
    total_agents int
);
grant select on region to simpleton;
create domain religious_minority as
    varchar(10) check ( value in ('christian', 'jewish', 'zardosht', 'None'));

create domain party_domain as
    varchar(10) check ( value in ('left', 'right'));


create domain election_type_domain as
    varchar check ( value in ('presidential', 'chair', 'khobregan', 'city_council'));
-- btw chair is majles LOL

create domain election_year_domain as
    int check (value between 1357 and 1457);

create table Person (
    id serial primary key ,
    name varchar(20),
    age int,
    rank int,
    religion_minority religious_minority,
    region_id int,

    foreign key (region_id) references region(id) ON UPDATE CASCADE ON DELETE CASCADE ,
    check (age between 18 and 100),
    check (age between 1 and 100)

);
grant select on person to candidates, judges;

create table candidate (
    candidate_id serial primary key ,
    person_id int,
    resume varchar(50),
    documents varchar(50),
    party party_domain,
    qualification bool default false,
    foreign key (person_id) references person(id) ON UPDATE CASCADE ON DELETE CASCADE
);
grant select, update on candidate to judges;


create table judge (
    judge_id serial primary key ,
    person_id int,
    foreign key (person_id) references person(id) ON UPDATE CASCADE ON DELETE CASCADE
);
grant select on judge to judges;

create table election (
    type election_type_domain,
    year election_year_domain,
    voter_max_rank int,
    voter_min_rank int,
    judge_rank int,

    primary key (type, year)
);
grant select on election to simpleton;

create table branch (
    branch_no serial,
    region_id int,

    primary key (branch_no, region_id),
    foreign key (region_id) references region(id) ON UPDATE CASCADE ON DELETE CASCADE
);
grant select on branch to candidates, judges;

create table qualification (
    election_type election_type_domain,
    election_year election_year_domain,
    judge_id int,
    candidate_id int,
    vote bool,

    primary key (election_type, election_year, judge_id, candidate_id),
    foreign key (election_type, election_year) references election(type, year),
    foreign key (judge_id) references judge(judge_id) ON UPDATE CASCADE ON DELETE CASCADE ,
    foreign key (candidate_id) references candidate(candidate_id) ON UPDATE CASCADE ON DELETE CASCADE
);
grant select, insert, update on qualification to judges;


create table vote (
    election_type election_type_domain,
    election_year election_year_domain,
    person_id int,
    candidate_id int,
    branch_no int,
    primary key (election_year, election_type, person_id, candidate_id),
    foreign key (election_type, election_year) references election(type, year) ON UPDATE CASCADE ON DELETE CASCADE ,
    foreign key (person_id) references person(id) ON UPDATE CASCADE ON DELETE CASCADE ,
    foreign key (candidate_id) references candidate(candidate_id) ON UPDATE CASCADE ON DELETE CASCADE
);
grant select on vote to judges;


create table user_person (
    username varchar primary key ,
    person_id int,
    foreign key (person_id) references person(id)
);



select region_id from candidate c inner join person p on p.id = c.person_id where candidate_id = 6;



select id from person where region_id = 30;


update candidate set qualification = true where candidate_id = 6;