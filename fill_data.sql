  USE test;
-- setup
-- some realistic data , generating events, doing some querying afterwards
-- https://www.saashub.com/mysql-workbench-alternatives
DROP TABLE IF EXISTS events;
CREATE TABLE IF NOT EXISTS events (
  app VARCHAR(10) NOT NULL,
  status TINYINT DEFAULT 0,
  event_id INTEGER NOT NULL DEFAULT 0,
  event_date DATETIME NOT NULL
);

DROP INDEX events_idx ON events;
CREATE INDEX events_idx ON events(app, event_date);

DROP PROCEDURE `fill_table` ;
-- NOTE: "CREATE OR REPLACE PROCEDURE" is sensiive to the presence of the procedure

DELIMITER //
CREATE PROCEDURE `fill_table`(IN verbose TINYINT)
BEGIN
DECLARE v_event_date0 DATETIME DEFAULT CURDATE();
DECLARE v_event_date DATETIME DEFAULT DATE_SUB(CURDATE(), INTERVAL 10 DAY);
DECLARE v_app VARCHAR(10);
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_conseq_count INTEGER DEFAULT 0;
DECLARE v_event_id INTEGER DEFAULT 0;
DECLARE v_status TINYINT DEFAULT 0;

set v_conseq_count = RAND() * 10;
DELETE FROM events;
INS: LOOP
  IF v_count > 100 THEN
    LEAVE INS;
  END IF;
  SET v_count =  v_count + 1;
  SET v_event_id =  v_event_id + 1;
  SET v_event_date = DATE_ADD(v_event_date0, INTERVAL v_count SECOND);
  IF v_conseq_count = 0 THEN
    SET v_conseq_count = RAND() * 10;
    SET v_status = 1 -v_status ;
  ELSE
    SET v_conseq_count = v_conseq_count - 1;
  END IF;
  SET v_app = 'A1';
  INSERT INTO events (event_date, event_id, app, status)
  VALUES (v_event_date, v_event_id, v_app, v_status );
  IF verbose <> 0 THEN
    SELECT v_app, v_event_date, v_status , v_count;
  END IF;  
END LOOP;
END
//
DELIMITER ;

CALL `fill_table`(1);

DROP PROCEDURE `find_subsequent_errors` ;

DELIMITER //
CREATE PROCEDURE `find_subsequent_errors`()

BEGIN

DECLARE v_event_date DATETIME DEFAULT CURDATE();
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_app VARCHAR(10);
DECLARE v_following_status TINYINT DEFAULT 0;

DECLARE data_cursor CURSOR FOR SELECT APP, EVENT_DATE FROM events
  WHERE STATUS <> 0 ORDER BY APP, EVENT_DATE;

-- (un)commenting the next block expooses the stored pcedure to throwing / suppresses the
-- ERROR 1329 (02000):
-- No data - zero rows fetched, selected, or processed

DECLARE CONTINUE HANDLER FOR NOT FOUND
BEGIN
  SELECT 1 INTO @handler_invoked FROM (SELECT 1) AS t;
END;
-- based on: https://stackoverflow.com/questions/3463283/how-to-get-rid-of-error-1329-no-data-zero-rows-fetched-selected-or-process
OPEN data_cursor;
INS: LOOP
  FETCH NEXT FROM data_cursor INTO v_app,v_event_date;
  IF v_count > 100 THEN
    LEAVE INS;
  END IF;
  SET v_count = v_count + 1;
END LOOP;
END
//
DELIMITER ;

SHOW CREATE PROCEDURE find_subsequent_errors;
SELECT
routine_schema, routine_name, routine_definition
FROM
information_schema.routines
WHERE
routine_type = 'PROCEDURE'
AND
routine_name = 'find_subsequent_errors';

CALL `find_subsequent_errors`();

DROP TABLE IF EXISTS results;
CREATE TABLE IF NOT EXISTS results (
  status_string VARCHAR(1024) NOT NULL
);

-- https://wiki.ispirer.com/sqlways/mysql/techniques/return-value-from-procedure
-- TODO: inout parameter not working
-- OR UPDATE PROCEDURE 

DROP PROCEDURE `flat_status`;
DELIMITER //
CREATE PROCEDURE `flat_status`()

BEGIN
DECLARE v_event_date DATETIME DEFAULT CURDATE();
DECLARE v_event_id INTEGER DEFAULT 0;
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_app VARCHAR(10);
DECLARE v_status TINYINT DEFAULT 0;
DECLARE v_status_string VARCHAR(1024) default '';

DECLARE data_cursor CURSOR FOR SELECT app, event_date, event_id, status FROM events
  ORDER BY app, event_date limit 100;
DELETE FROM results;
INSERT INTO results (status_string) VALUES ('');
OPEN data_cursor;
INS: LOOP
  FETCH NEXT FROM data_cursor INTO v_app,v_event_id,v_event_date,v_status;
  IF v_count > 100 THEN
    LEAVE INS;
  END IF;
  SET v_count = v_count + 1;
  IF v_status THEN
    set v_status_string = CONCAT(v_status_string , 'o');
  ELSE
    set v_status_string = CONCAT(v_status_string , 'x');
  END IF;
  UPDATE results SET results.status_string = v_status_string;
END LOOP;
CLOSE data_cursor;
END;
//
DELIMITER ;

CALL `flat_status`();
SELECT status_string FROM results INTO @status_string;
SELECT @status_string;
-- | xxooooooooooxxxxxxxxxooooxxooooooooxxxoooooooooooxxxxoooooxooxxxxxxooxxxxxxxxxxoooooxoxooxxxxooooxxx |
-- +--------------------------------+
-- | INSTR(@status_string, 'xxxxx') |
-- +--------------------------------+
-- |                             13 |
-- +--------------------------------+
-- +---------------------------------+
-- | LOCATE('xxxxx', @status_string) |
-- +---------------------------------+
-- |                              13 |
-- +---------------------------------+
-- +------------------------------------+
-- | LOCATE('xxxxx', @status_string,19) |
-- +------------------------------------+
-- |                                 62 |
-- +------------------------------------+
-- | LOCATE('xxxxx', @status_string,68) |
-- +------------------------------------+
-- |                                 70 |
-- +------------------------------------+
-- | LOCATE('xxxxx', @status_string,76) |
-- +------------------------------------+
-- |                                  0 |
-- +------------------------------------+

DELIMITER //
CREATE FUNCTION `dummy_calc_int`()
RETURNS INT
BEGIN
DECLARE v_count INTEGER DEFAULT 0;
SELECT COUNT(1) FROM events WHERE status <> 0 into v_count;
IF (v_count > 10 ) THEN
  RETURN 0;
ELSE
  RETURN 1;
END IF;
END;
//
DELIMITER ;

set @result =  `dummy_calc_int`();
select @result as result;
DROP FUNCTION `dummy_calc_int`;


DELIMITER //
CREATE FUNCTION `make_dummy_string`()
RETURNS VARCHAR(256)
BEGIN
DECLARE v_count INTEGER DEFAULT 0;
SELECT COUNT(1) FROM events WHERE status <> 0 into v_count;
IF (v_count > 10 ) THEN
  RETURN '0000000000';
END IF;
RETURN '1111111111';
END;
//
DELIMITER ;

set @result =  `make_dummy_string`();
select @result as result;
DROP FUNCTION `make_dummy_string`;




DELIMITER //
CREATE FUNCTION `make_dummy_string`()
RETURNS VARCHAR(256)
BEGIN
DECLARE v_count INTEGER DEFAULT 0;
INS: LOOP
  IF v_count > 100 THEN
    LEAVE INS;
  END IF;
  SET v_count = v_count + 1;
END LOOP;

IF (v_count > 10 ) THEN
  RETURN CONCAT('Result = ', v_count);
END IF;
RETURN '0';
END;
//
DELIMITER ;

set @result = `make_dummy_string`();
select @result as result;

-- +--------------+
-- | result       |
-- +--------------+
-- | Result = 101 |
-- +--------------+
DROP FUNCTION `make_dummy_string`;


--- following is broken


-- NOTE: cannot "CREATE OR UPDATE" with "FUNCTION"
DECLARE function_count TINYINT DEFAULT(0);
SELECT COUNT(1) FROM information_schema.routines WHERE routine_type = 'function' AND routine_name = 'construct_index_string' into @function_count ; 
-- IF function_count  <> 0 THEN
--   DROP FUNCTION `construct_index_string`;
-- END IF;

DROP PROCEDURE `construct_index_string_proc`;
-- NOTE: "or update" would lead to a failure initially
DELIMITER //

CREATE PROCEDURE `construct_index_string_proc`( INOUT status_string VARCHAR(1024))
BEGIN

DECLARE v_status_string VARCHAR(1024) default '';
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_status TINYINT DEFAULT 0;

DECLARE data_cursor CURSOR FOR SELECT status FROM events
  ORDER BY app, event_date limit 100;

DROP
TEMPORARY 
TABLE IF EXISTS results;
CREATE
TEMPORARY
TABLE IF NOT EXISTS results (

