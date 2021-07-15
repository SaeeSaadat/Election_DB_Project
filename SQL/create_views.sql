create view people as
select *
from (
        person as p
        join user_person up on p.id = up.person_id
         ) as pp
where (pp.username = (select user)) ;
grant SELECT on people to simpleton;

create view user_votes as select election_type , election_year , candidate_id , branch_no
from vote v inner join user_person up on v.person_id = up.person_id
where up.username = (select user);
grant SELECT on user_votes to simpleton;


create view visible_candidates as select candidate_id , p.name , resume , documents , party
from candidate c inner join person p on p.id = c.person_id
where c.qualification = true;
grant SELECT on visible_candidates to simpleton;



create view region_info as select r.id , total_agents , current_agents , branch_no from
branch b inner join region r on r.id = b.region_id
where r.id = (select region_id
from person p inner join user_person up on p.id = up.person_id where username =(select user));
grant SELECT on region_info to simpleton;



create view election_result as select v.candidate_id ,p.name , count(v.candidate_id)
from vote v inner join candidate c on c.candidate_id = v.candidate_id
inner join person p on p.id = c.person_id
group by v.candidate_id
order by count(v.candidate_id)
limit 1;
grant SELECT on election_result to simpleton;
---------------------------------------

create view candidate_users_info as select p.id , p.name , p.age , p.rank , p.religion_minority , p.region_id  ,
                                           c. candidate_id , resume , documents , party , qualification
from user_person up inner join candidate c on c.person_id = up.person_id
inner join person p on p.id = c.person_id where username = (select  user);
grant SELECT on candidate_users_info to candidates;



create view other_candidates_info as select candidate_id , resume , documents , party , qualification
from candidate c inner join user_person up on c.person_id = up.person_id where username !=(select user);
grant SELECT on visible_candidates to candidates;
grant SELECT on other_candidates_info to candidates;




create view judges_info as select judge_id , name from judge j inner join person p on p.id = j.person_id;
grant select on judges_info to candidates;


create view qualification_votes as select election_type , election_year , judge_id , vote
from qualification q inner join candidate c on c.candidate_id = q.candidate_id
inner join user_person up on c.person_id = up.person_id where username = (select user);
grant select on qualification_votes to candidates;


create view all_region_info as select region_id , total_agents , current_agents , branch_no from
region r inner join branch b on r.id = b.region_id;
grant select on all_region_info to candidates;

create view total_election_res as select candidate_id , count(candidate_id) , (count(candidate_id) / count(*)) ratio
from vote group by candidate_id
order by count(candidate_id);
grant select on total_election_res to candidates;
grant select on total_election_res to judges;


create view detailed_region_res as select region_id , candidate_id , count(candidate_id) from
vote v inner join branch b on v.branch_no = b.branch_no
group by region_id, candidate_id;



----------------------------------

create view judge_user_info as select p.id , p.name , p.age , p.rank , p.religion_minority , p.region_id , j.judge_id
from judge j inner join person p on p.id = j.person_id inner join user_person up on p.id = up.person_id where
username = (select user);
grant select on judge_user_info to judges;

create view all_candidates_info as select p.name , p.age , p.rank , p.religion_minority , p.region_id,
    c.candidate_id , c.resume , c.documents , c.party , c.qualification from candidate c
        inner join person p on p.id = c.person_id;
grant select on all_candidates_info to judges;


create view all_judges_info as select p.id , p.name , p.age , p.rank , p.religion_minority , p.region_id , j.judge_id
from judge j inner join person p on p.id = j.person_id;
grant select on all_judges_info to judges;


grant select on qualification to judges;



