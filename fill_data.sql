USE test;

DROP TABLE IF EXISTS events;
CREATE TABLE IF NOT EXISTS events (
  APP VARCHAR(10) NOT NULL,
  STATUS TINYINT DEFAULT 0,
  EVENT_DATE DATETIME NOT NULL
);
-- TODO: IGNORE ERROR 1091 (42000): CAN'T DROP 'events_idx'; CHECK THAT COLUMN/KEY EXISTS
DROP INDEX events_idx ON events;
CREATE INDEX events_idx ON events(APP, EVENT_DATE);

DROP PROCEDURE IF EXISTS `fill_table` ;
DELIMITER //
CREATE PROCEDURE `fill_table`()
BEGIN
DECLARE V_EVENT_DATE0 DATETIME DEFAULT CURDATE();
DECLARE V_EVENT_DATE DATETIME DEFAULT DATE_SUB(CURDATE(), INTERVAL 10 DAY);
DECLARE V_VERBOSE TINYINT DEFAULT 0;
DECLARE V_APP VARCHAR(10);
DECLARE V_COUNT TINYINT DEFAULT 0;
DECLARE V_STATUS TINYINT DEFAULT 0;

INS: LOOP
  IF V_COUNT > 100 THEN
    LEAVE INS;
  END IF ;
  SET V_COUNT =  V_COUNT + 1 ;
  SET V_EVENT_DATE = DATE_ADD(V_EVENT_DATE0, INTERVAL V_COUNT SECOND);
  SET V_STATUS = MOD(V_COUNT, 5);
  SET V_APP = 'A1';
  INSERT INTO events (EVENT_DATE, APP, STATUS) 
  VALUES (V_EVENT_DATE, V_APP, V_STATUS );
  SELECT V_APP, V_EVENT_DATE, V_STATUS , V_COUNT;
END LOOP;
END
//
DELIMITER ;

CALL `fill_table`();



SELECT COUNT(1) FROM events;

SELECT
origin.APP, origin.EVENT_DATE, origin.STATUS
FROM
events origin
WHERE
STATUS <> 0
AND
(
SELECT
SUM(follower.ERROR_STATUS)
FROM (
SELECT
IF(STATUS <> 0, 1, 0) AS ERROR_STATUS
FROM
events USE INDEX(events_idx)
WHERE
APP =  origin.APP
AND
EVENT_DATE >= origin.EVENT_DATE
ORDER BY APP, EVENT_DATE LIMIT 5
) follower
) > 4
ORDER BY APP, EVENT_DATE;
-- https://stackoverflow.com/questions/47466221/mysql-how-to-make-a-table-visible-in-a-sub-query
-- the "make a outer table visible in an correlated table tablspace" solutions suggested are quite complex:
-- * create view,
-- * add an outer join bringing count
-- NOTE: since limit applies to the number of rows from the result and SUM only returns one row
-- a subquery is non-optional

-- NOTE: Unknown column 'origin.APP' in 'where clause'

SELECT APP, EVENT_DATE, STATUS FROM events origin
WHERE
STATUS <> 0
AND
(
SELECT
SUM(IF(STATUS <> 0, 1, 0)) AS ERROR_STATUS_COUNT
FROM
events USE INDEX(events_idx)
WHERE
APP = origin.APP
AND
EVENT_DATE >= origin.EVENT_DATE
ORDER BY APP, EVENT_DATE LIMIT 5
) > 10
ORDER BY APP, EVENT_DATE;

-- since limit applies to the number of rows from the result and SUM only returns one row
-- a subquery is non-optional

SET @origin_event_date = '2019-10-12 00:00:01';
set @origin_app = 'A1';

SELECT
SUM(IF(STATUS <> 0, 1, 0)) AS  ERROR_STATUS_COUNT
FROM
-- events USE INDEX(events_idx)
events
WHERE
APP = @origin_app
AND
EVENT_DATE >= @origin_event_date
ORDER BY APP, EVENT_DATE LIMIT 5;
SELECT
CASE STATUS WHEN 0 THEN 0 ELSE 1 END AS ERROR_STATUS, APP, EVENT_DATE
FROM
events USE INDEX(events_idx)
WHERE
APP = @origin_app
AND
EVENT_DATE >= @origin_event_date
ORDER BY APP, EVENT_DATE LIMIT 5;



SELECT
SUM(CASE STATUS WHEN  0 THEN 0 ELSE 1 END) AS  ERROR_STATUS_COUNT
FROM
events USE INDEX(events_idx)
WHERE
APP = @origin_app
AND
EVENT_DATE >= @origin_event_date
ORDER BY APP, EVENT_DATE LIMIT 5;



--- ignored the LIMIT statement


-- NOTE: unfinished.
-- NOTE: 
-- see also: https://stackoverflow.com/questions/2281890/can-i-create-view-with-parameter-in-mysql
-- NOTE: apparently one can not use view anyways:
CREATE VIEW following_events(v_app, v_event_date) AS
(
SELECT
IF(STATUS <> 0, 1, 0) AS effective_status
FROM
events USE INDEX(events_idx)
WHERE
APP = v_app
AND
EVENT_DATE >= v_event_date
ORDER BY APP, EVENT_DATE LIMIT 5
)

-- ERROR 1349 (HY000): View's SELECT contains a subquery in the from clause
-- see also: https://stackoverflow.com/questions/8428641/views-select-contains-a-subquery-in-the-from-clause
CREATE VIEW following_event_count (v_app, v_event_date) AS
(
SELECT SUM(effective_status) FROM
(
SELECT
IF(STATUS <> 0, 1, 0) AS effective_status
FROM
events USE INDEX(events_idx)
WHERE
APP = v_app
AND
EVENT_DATE >= v_event_date
ORDER BY APP, EVENT_DATE LIMIT 5
) following_events
)

--  http://sqlfiddle.com/#!9/6fc2962/1/0

	   DROP TABLE IF EXISTS error_events;
CREATE TABLE IF NOT EXISTS error_events (
  APP VARCHAR(10) NOT NULL,
  STATUS TINYINT DEFAULT 0,
  EVENT_DATE DATETIME NOT NULL
);



DROP PROCEDURE IF EXISTS `find_subsequent_errors` ;
DELIMITER //
CREATE PROCEDURE `find_subsequent_errors`()
BEGIN
DECLARE V_EVENT_DATE DATETIME DEFAULT CURDATE();
DECLARE V_COUNT TINYINT DEFAULT 0;
DECLARE V_APP VARCHAR(10);
DECLARE V_FOLLOWING_STATUS TINYINT DEFAULT 0;
DECLARE data_cursor CURSOR FOR SELECT APP, EVENT_DATE FROM events
  WHERE STATUS <> 0 ORDER BY APP, EVENT_DATE;
  OPEN data_cursor ;
INS: LOOP
  FETCH NEXT FROM data_cursor INTO V_APP,V_EVENT_DATE;  
  SELECT
    SUM(FOLLOWING_STATUS) INTO V_FOLLOWING_STATUS FROM
    ( SELECT  IF(STATUS <> 0, 1, 0 ) AS FOLLOWING_STATUS FROM
	  events USE INDEX(events_idx)
	  WHERE
	  APP = V_APP
	  AND
	  EVENT_DATE >= V_EVENT_DATE
	  ORDER BY V_APP, EVENT_DATE
	  LIMIT 5
	) X ;
  IF V_COUNT > 1000 THEN
    LEAVE INS;
  END IF ;
  SET V_COUNT =  V_COUNT + 1 ;
  SELECT V_APP,V_EVENT_DATE , V_FOLLOWING_STATUS, V_COUNT;
  INSERT INTO error_events (EVENT_DATE, APP, STATUS) 
  VALUES (V_EVENT_DATE, V_APP, V_FOLLOWING_STATUS );

  
END LOOP;
END
//
DELIMITER ;

CALL `find_subsequent_errors`();



