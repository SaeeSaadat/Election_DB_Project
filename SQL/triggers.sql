CREATE OR REPLACE FUNCTION voting_trigger_func() RETURNS TRIGGER AS
$voting_trigger_func$
BEGIN

    IF NOT EXISTS(
            select * from person where new.person_id = person.id
        ) THEN
        RAISE EXCEPTION 'NO SUCH PERSON';
    END IF;


    IF NOT EXISTS(
            select * from candidate where new.candidate_id = candidate.candidate_id
        ) THEN
        RAISE EXCEPTION 'NO SUCH CANDIDATE';
    END IF;


    IF NOT EXISTS(
            select *
            from election
            where election.type = new.election_type
              and election.year = new.election_year
        ) THEN
        RAISE EXCEPTION 'NO SUCH ELECTION';
    END IF;


    IF NOT EXISTS(
            SELECT *
            FROM branch
            WHERE branch.branch_no = NEW.branch_no
              and branch.region_id = (
                select distinct p.region_id
                from person p
                         join branch b on p.region_id = b.region_id
                where p.id = NEW.person_id
            )
        ) THEN
        RAISE EXCEPTION 'NO SUCH BRANCH';
    END IF;

    IF (SELECT qualification FROM candidate WHERE candidate.candidate_id = NEW.candidate_id) = FALSE THEN
        RAISE EXCEPTION 'CHOSEN CANDIDATE IS NOT QUALIFIED';
    END IF;

    IF ((SELECT religion_minority FROM person WHERE id = NEW.person_id) IS NULL) AND
       ((SELECT region_id FROM person WHERE id = NEW.person_id) !=
        (SELECT region_id
         FROM candidate c
                  INNER JOIN person p ON p.id = c.person_id
         WHERE c.candidate_id = NEW.candidate_id)) THEN
        RAISE EXCEPTION 'VOTER AND CHOSEN CANDIDATE ARE NOT IN THE SAME REGION';
    END IF;


    IF (SELECT religion_minority from person where id = new.person_id) !=
       (select p.religion_minority
        from person p
                 join candidate c on p.id = c.person_id)
    THEN
        raise exception 'minorities with minorities, birds with birds!';
    END IF;


    IF (SELECT count(*) FROM vote WHERE person_id = NEW.person_id) >=
       (SELECT total_agents - current_agents
        FROM region
        WHERE id = (SELECT region_id FROM person WHERE id = NEW.person_id)) THEN
        RAISE EXCEPTION 'VIOLATING MAXIMUM NUMBER OF VOTES';
    END IF;

    IF (SELECT rank FROM person WHERE id = NEW.person_id) NOT BETWEEN
        (SELECT voter_min_rank FROM election WHERE year = NEW.election_year AND type = NEW.election_type) AND
        (SELECT voter_max_rank FROM election WHERE year = NEW.election_year AND type = NEW.election_type) THEN
        RAISE EXCEPTION 'RANK NOT IN VOTING RANGE';
    END IF;

    RETURN NEW;
END
$voting_trigger_func$
    LANGUAGE 'plpgsql';

drop trigger if exists voting_trigger on vote;

CREATE TRIGGER voting_trigger
    BEFORE INSERT
    ON vote
    FOR EACH ROW
EXECUTE PROCEDURE voting_trigger_func();


------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION create_judge_func() RETURNS TRIGGER AS
$create_judge_func$
BEGIN
    IF NOT EXISTS(SELECT * FROM election WHERE judge_rank = (SELECT rank FROM person WHERE id = NEW.person_id)) THEN
        RAISE EXCEPTION 'NOT QUALIFIED AS JUDGE DUE TO PROBLEMS WITH RANK';
    END IF;
    RETURN NEW;
END
$create_judge_func$
    LANGUAGE 'plpgsql';

drop trigger if exists create_judge on judge;

CREATE TRIGGER create_judge
    BEFORE INSERT
    ON judge
    FOR EACH ROW
EXECUTE PROCEDURE create_judge_func();


------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION qualify_vote_func() RETURNS TRIGGER AS
$qualify_vote_func$
BEGIN
    IF (SELECT rank
        FROM judge_user_info j
        WHERE j.judge_id = NEW.judge_id) !=
       (SELECT judge_rank FROM election WHERE type = NEW.election_type AND year = NEW.election_year) THEN
        RAISE EXCEPTION 'JUDGE CANNOT QUALIFY ANYONE IN THIS ELECTION DUE TO RANK PROBLEMS';
    END IF;
    RETURN NEW;
END
$qualify_vote_func$
    LANGUAGE 'plpgsql';

drop trigger if exists qualify_vote on qualification;

CREATE TRIGGER qualify_vote
    BEFORE INSERT OR UPDATE
    ON qualification
    FOR EACH ROW
EXECUTE PROCEDURE qualify_vote_func();



CREATE OR REPLACE FUNCTION qualify_candidate_func() RETURNS TRIGGER AS
$qualify_candidate_func$
BEGIN
    IF (SELECT COUNT(*)
        FROM qualification
        WHERE candidate_id = NEW.candidate_id
          AND election_type = NEW.election_type
          AND election_year = NEW.election_year) =
       (SELECT COUNT(*)
        FROM judge
            join person on judge.person_id = person.id
           where person.rank = (select judge_rank from election
                                where election.type = new.election_type
                                and election.year = new.election_year)
        ) THEN
        IF (SELECT COUNT(*)
            FROM qualification
            WHERE election_year = NEW.election_year
              AND election_type = NEW.election_type
              AND candidate_id = NEW.candidate_id
              AND vote = TRUE) > (SELECT COUNT(*)
                                  FROM qualification
                                  WHERE election_year = NEW.election_year
                                    AND election_type = NEW.election_type
                                    AND candidate_id = NEW.candidate_id
                                    AND vote = FALSE) THEN
            UPDATE candidate SET qualification = TRUE WHERE candidate_id = NEW.candidate_id;
        ELSE
            UPDATE candidate SET qualification = FALSE WHERE candidate_id = NEW.candidate_id;
        END IF;

        IF (SELECT qualification FROM candidate WHERE candidate.candidate_id = NEW.candidate_id) = FALSE THEN
            DELETE FROM vote WHERE vote.candidate_id = NEW.candidate_id;
        END IF;

    END IF;
    RETURN NEW;
END
$qualify_candidate_func$
    LANGUAGE 'plpgsql';

drop trigger if exists qualify_candidate on qualification;

CREATE TRIGGER qualify_candidate
    AFTER INSERT OR UPDATE
    ON qualification
    FOR EACH ROW
EXECUTE PROCEDURE qualify_candidate_func();

