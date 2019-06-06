-- based on https://stackoverflow.com/questions/37305135/oracle-convert-unix-epoch-time-to-date
-- tested through https://livesql.oracle.com/apex/f?p=590:1:100554990584212::NO:RP::#
-- SELECT TO_TIMESTAMP('1970-01-01 00:00:00.0' ,'YYYY-MM-DD HH24:MI:SS.FF') + NUMTODSINTERVAL(1493963084212/1000, 'SECOND') FROM dual;


CREATE OR REPLACE FUNCTION unix_to_date3(unix_sec NUMBER)
RETURN timestamp
IS
ret_date timestamp;
BEGIN
  ret_date:= TO_TIMESTAMP('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'
       ) + NUMTODSINTERVAL( unix_sec, 'SECOND');
    RETURN ret_date;

END;
/
SELECT unix_to_date3(1559830206) FROM dual;

-- 06-JUN-19 02.10.06.000000 PM
