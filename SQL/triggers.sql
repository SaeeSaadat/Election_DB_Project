CREATE OR REPLACE FUNCTION voting_trigger_func() RETURNS TRIGGER AS
$voting_trigger_func$
    BEGIN
	    IF NOT EXISTS(SELECT * FROM branch WHERE branch.branch_no = NEW.branch_no) THEN
            RAISE EXCEPTION  'NO SUCH BRANCH';
        END IF;

        IF (SELECT qualification FROM candidate WHERE candidate.candidate_id = NEW.candidate_id) = FALSE THEN
            RAISE EXCEPTION 'CHOSEN CANDIDATE IS NOT QUALIFIED';
        END IF;

        IF ( (SELECT religion_minority FROM person WHERE id = NEW.person_id) = 'None' ) AND
           ( (SELECT region_id FROM person WHERE id = NEW.person_id) !=
           (SELECT region_id FROM candidate c INNER JOIN person p ON p.id = c.person_id
           WHERE c.candidate_id = NEW.candidate_id) ) THEN
            RAISE EXCEPTION 'VOTER AND CHOSEN CANDIDATE ARE NOT IN THE SAME REGION';
        END IF;

	    IF (SELECT region_id FROM branch WHERE branch.branch_no = NEW.branch_no) !=
	       (SELECT region_id FROM person WHERE id = NEW.person_id) THEN
            RAISE EXCEPTION 'VOTER AND CHOSEN BRANCH ARE NOT IN THE SAME REGION';
        END IF;

	    IF (SELECT count(*) FROM vote WHERE person_id = NEW.person_id) >=
	       (SELECT total_agents-current_agents FROM region
	       WHERE id =(SELECT region_id FROM person WHERE id = NEW.person_id)) THEN
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

CREATE TRIGGER voting_trigger BEFORE INSERT ON vote
    FOR EACH ROW EXECUTE PROCEDURE voting_trigger_func();
update election set type = 'chair' where true;
insert into vote values('chair', 1400, 12342, 1, 1);

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

CREATE TRIGGER create_judge BEFORE INSERT ON judge
    FOR EACH ROW EXECUTE PROCEDURE create_judge_func();


------------------------------------------------------------------------------------------------------------------------





CREATE OR REPLACE FUNCTION qualify_vote_func() RETURNS TRIGGER AS
$qualify_vote_func$
    BEGIN
        IF (SELECT rank FROM judge j INNER JOIN person p on p.id = j.person_id WHERE j.judge_id = NEW.judge_id) !=
           (SELECT judge_rank FROM election WHERE type = NEW.election_type AND year = NEW.election_year) THEN
            RAISE EXCEPTION 'JUDGE CANNOT QUALIFY ANYONE IN THIS ELECTION DUE TO RANK PROBLEMS';
        END IF;
        RETURN NEW;
    END
$qualify_vote_func$
LANGUAGE 'plpgsql';

CREATE TRIGGER qualify_vote BEFORE INSERT OR UPDATE ON qualification
    FOR EACH ROW EXECUTE PROCEDURE qualify_vote_func();






CREATE OR REPLACE FUNCTION qualify_candidate_func() RETURNS TRIGGER AS
$qualify_candidate_func$
    BEGIN
        IF (SELECT COUNT(*) FROM qualification WHERE candidate_id = NEW.candidate_id
                AND election_type = NEW.election_type AND election_year = NEW.election_year) =
           (SELECT COUNT(*) FROM judge) THEN
            IF (SELECT COUNT(*) FROM qualification
                WHERE election_year = NEW.election_year
                AND election_type = NEW.election_type
                AND candidate_id = NEW.candidate_id
                AND vote = TRUE) > (SELECT COUNT(*) FROM qualification
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


CREATE TRIGGER qualify_candidate AFTER INSERT OR UPDATE ON qualification
    FOR EACH ROW EXECUTE PROCEDURE qualify_candidate_func();

