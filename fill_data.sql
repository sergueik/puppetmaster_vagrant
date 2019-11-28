USE test;
-- setup
-- some realistic data , generating events, doing some querying afterwards

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
DELIMITER //
CREATE PROCEDURE `fill_table`()
BEGIN
DECLARE v_event_date0 DATETIME DEFAULT CURDATE();
DECLARE v_event_date DATETIME DEFAULT DATE_SUB(CURDATE(), INTERVAL 10 DAY);
DECLARE V_VERBOSE TINYINT DEFAULT 0;
DECLARE V_APP VARCHAR(10);
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_conseq_count INTEGER DEFAULT 0;
DECLARE v_event_id INTEGER DEFAULT 0;
DECLARE v_status TINYINT DEFAULT 0;

set v_conseq_count = RAND() * 10;
INS: LOOP
  IF v_count > 100 THEN
    LEAVE INS;
  END IF ;
  SET v_count =  v_count + 1;
  SET v_event_id =  v_event_id + 1;
  SET v_event_date = DATE_ADD(v_event_date0, INTERVAL v_count SECOND);
  IF v_conseq_count = 0 THEN
    SET  v_conseq_count = RAND() * 10;
    -- SET v_status =  1 -v_status ;
  ELSE
    SET v_conseq_count = v_conseq_count - 1;
  END IF;
  IF v_conseq_count < 4 THEN
    SET v_status = 1;
  ELSE
    SET v_status = MOD(v_count, 2);
  END IF;
  SET V_APP = 'A1';
  INSERT INTO events (event_date, event_id, app, status)
  VALUES (v_event_date, v_event_id, v_app, v_status );
  -- SELECT v_app, v_event_date, v_status , v_count;
END LOOP;
END
//
DELIMITER ;

CALL `fill_table`();

DROP PROCEDURE `find_subsequent_errors` ;

DELIMITER //
CREATE PROCEDURE `find_subsequent_errors`()

BEGIN

DECLARE v_event_date DATETIME DEFAULT CURDATE();
DECLARE v_count INTEGER DEFAULT 0;
DECLARE V_APP VARCHAR(10);
DECLARE V_FOLLOWING_STATUS TINYINT DEFAULT 0;

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
  FETCH NEXT FROM data_cursor INTO V_APP,v_event_date;
  IF v_count > 100 THEN
    LEAVE INS;
  END IF;
  SET v_count =  v_count + 1;
END LOOP;
END
//
DELIMITER ;

CALL `find_subsequent_errors`();


DROP PROCEDURE `flat_status` ;

-- https://wiki.ispirer.com/sqlways/mysql/techniques/return-value-from-procedure
-- TODO

DROP TABLE IF EXISTS results;
CREATE TABLE IF NOT EXISTS results (
  status_string VARCHAR(1024) NOT NULL
);

DELIMITER //
CREATE PROCEDURE `flat_status`(INOUT status_string VARCHAR(1024))
RET:

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
  SELECT 'Loop: '  ,  v_status_string;
  SET status_string = v_status_string;
  UPDATE results SET results.status_string = v_status_string;
  SELECT 'Status_string (inout) '  ,  status_string;
    
END LOOP;

CLOSE data_cursor;
-- LEAVE RET;
END;
//
DELIMITER ;


@status_string = '' ;
CALL `flat_status`(@status_string);
SELECT @status_string;
-- null
SELECT status_string FROM results INTO @status_string;
SELECT @status_string;
