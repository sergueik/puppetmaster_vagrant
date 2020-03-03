USE test;


DROP TABLE IF EXISTS report_filler;
CREATE TABLE IF NOT EXISTS report_filler (
--  app VARCHAR(10) NOT NULL,
--  status TINYINT DEFAULT 0,
--  event_id INTEGER NOT NULL DEFAULT 0,
  row_id INTEGER NOT NULL DEFAULT 0,
  event_date DATE NOT NULL
);

DROP PROCEDURE `fill_table`;


DELIMITER //
CREATE PROCEDURE `fill_table`(IN verbose TINYINT, IN date_begin DATETIME, IN date_end DATETIME )
BEGIN
DECLARE v_conseq_count INTEGER DEFAULT 0;
DECLARE v_row_id INTEGER DEFAULT 0;
DECLARE v_count INTEGER DEFAULT 0;
DECLARE v_event_date DATETIME DEFAULT DATE_SUB(CURDATE(), INTERVAL 10 DAY);

set v_conseq_count = DATEDIFF(date_end, date_begin);
DELETE FROM report_filler;
INS: LOOP
  IF v_count >= v_conseq_count THEN
    LEAVE INS;
  END IF;
  SET v_count =  v_count + 1;
  SET v_event_date = DATE(DATE_ADD(date_begin, INTERVAL v_count DAY));
  INSERT INTO report_filler (row_id, event_date) VALUES (v_row_id, v_event_date );
  IF verbose <> 0 THEN
    SELECT v_row_id, v_event_date;
  END IF;
END LOOP;
END
//
DELIMITER ;

set @query_param2 = CURDATE();
set @query_param1 = DATE_SUB(CURDATE(), INTERVAL 10 DAY);
CALL `fill_table`(1, @query_param1, @query_param2);

DROP TABLE IF EXISTS report_data;

CREATE TABLE IF NOT EXISTS report_data (
  app VARCHAR(10) NOT NULL,
  status TINYINT DEFAULT 0,
  event_date DATE NOT NULL
);
INSERT INTO report_data (app, status, event_date) VALUES ('foo', 1, curdate() );
INSERT INTO report_data (app, status, event_date) VALUES ('bar', 1, DATE_SUB(CURDATE(), INTERVAL 4 DAY) );
SELECT * FROM (
SELECT
  event_date,
  app,
  status
FROM report_data
UNION
SELECT
  event_date,
  '' AS app,
  0 AS status
FROM
  report_filler
WHERE
  NOT EXISTS (
    SELECT
      1, event_date
    FROM
      report_data
    HAVING
      report_data.event_date = report_filler.event_date
  )
) X ORDER BY event_date;
