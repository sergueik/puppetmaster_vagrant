USE TEST;
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
DECLARE V_COUNT TINYINT DEFAULT 0;
DECLARE V_STATUS TINYINT DEFAULT 0;

INS: LOOP
  IF V_COUNT > 10 THEN
    LEAVE INS;
  END IF ;
  SET V_COUNT =  V_COUNT + 1 ;
  SET V_EVENT_DATE = DATE_ADD(V_EVENT_DATE0, INTERVAL V_COUNT SECOND);
  SET V_STATUS = MOD(V_COUNT, 5);
  INSERT INTO events (EVENT_DATE, APP, STATUS)
  VALUES (V_EVENT_DATE, 'A1', V_STATUS );
  SELECT V_COUNT;
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
IF(STATUS <> 0, 1, 0) ERROR_STATUS
FROM 
-- events USE INDEX(events_idx)
events
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
SUM(IF(STATUS <> 0, 1, 0)) AS  ERROR_STATUS_COUNT 
FROM
events USE INDEX(events_idx)
WHERE 
APP =  origin.APP
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
APP =  @origin_app
AND
EVENT_DATE >= @origin_event_date
ORDER BY APP, EVENT_DATE LIMIT 5;
SELECT
CASE STATUS WHEN  0 THEN 0 ELSE 1 END AS  ERROR_STATUS, APP, EVENT_DATE
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
APP =  @origin_app
AND
EVENT_DATE >= @origin_event_date
ORDER BY APP, EVENT_DATE LIMIT 5;



--- ignored the LIMIT statement