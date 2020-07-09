/*
  fablabway.com
  file:        oradrill.sql
  project:     db tools/acheloo
  description:  where is my string?
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2016  mr    creates
*/

-- ALTER SESSION SET CURRENT_SCHEMA = MYOWNER;
SET SERVEROUTPUT ON SIZE 1000000

DECLARE
  WRELCODE  VARCHAR2(30) := 'WE';
  WOPERATOR VARCHAR2(30) := 'mauro';
  WOBJOWNE  VARCHAR2(30) := 'MYOWNER';     -- OWNER
	WSEARCH   VARCHAR2(30) := '\''[1UPDJ297]'; -- LOOKING FOR...
--  WSEARCH   VARCHAR2(100) := 'TABLE1|VIEW1|OTHEROBJ|ANDSOON'; -- LOOKING FOR...
-- WSEARCH   VARCHAR2(100) := ' TABLE1|VIEW1|^NEGOZI'; -- LOOKING FOR...
-- WSEARCH   VARCHAR2(100) := 'TIPO_NEGOZI'; -- LOOKING FOR...

  WCOLSEP   VARCHAR2(1)  := ';';            -- COLUMN SEPARATOR
  WCLOBTMP CLOB;
  WLENLOB  NUMBER;                          -- CLOB SIZE
  WNUMLINE NUMBER;                          -- LINE COUNTER
  WOFFSET PLS_INTEGER:=1;                   -- SINCE LAST CR
  WONEROW        VARCHAR2(32767);           -- EXTRACTED FROM CLOB
  WROWLEN        NUMBER;
BEGIN
  FOR WREC IN
  (SELECT OWNER,
    VIEW_NAME ,
    TEXT
  FROM DBA_VIEWS
  WHERE 1=1
  AND REGEXP_LIKE(OWNER,WOBJOWNE,'i')
  )
  LOOP
    IF REGEXP_LIKE (WREC.TEXT,WSEARCH,'i') THEN
      -- START DDL-METADATA AND EXTRACTS THE INVOLVED ROWS
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'EMIT_SCHEMA',false);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_CREATION',false);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
      SELECT DBMS_METADATA.GET_DDL('VIEW',WREC.VIEW_NAME,WREC.OWNER) MYROW
      INTO WCLOBTMP
      FROM DUAL;
      WLENLOB      := DBMS_LOB.getLength(WCLOBTMP);
      WNUMLINE     :=1;
      WHILE WOFFSET<=WLENLOB
      LOOP
        WROWLEN  :=instr(WCLOBTMP,chr(10),WOFFSET)-WOFFSET;
        IF WROWLEN<0 THEN
          WROWLEN:=WLENLOB+1-WOFFSET;
        END IF;
        WONEROW:=SUBSTR(WCLOBTMP,WOFFSET,WROWLEN);
        IF REGEXP_LIKE(WONEROW,WSEARCH,'i') THEN
          dbms_output.put_line( WREC.VIEW_NAME||WCOLSEP||WREC.OWNER||WCOLSEP||'VIEW'||WCOLSEP|| TO_CHAR(WNUMLINE)||WCOLSEP||LTRIM(RTRIM(WONEROW)));
        END IF;
        WOFFSET  :=WOFFSET   +WROWLEN+1;
        WNUMLINE := WNUMLINE + 1;
      END LOOP;
    END IF;
  END LOOP;
  --**********************
  FOR WREC IN
  (SELECT OWNER,
    MVIEW_NAME ,
    QUERY
  FROM DBA_MVIEWS
  WHERE 1=1
  AND REGEXP_LIKE(OWNER,WOBJOWNE,'i')
  )
  LOOP
    IF REGEXP_LIKE (WREC.QUERY,WSEARCH,'i') THEN
      -- START DDL-METADATA AND EXTRACTS THE INVOLVED ROWS
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'EMIT_SCHEMA',false);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_CREATION',false);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
      DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
      SELECT DBMS_METADATA.GET_DDL('MATERIALIZED_VIEW',WREC.MVIEW_NAME,WREC.OWNER) MYROW
      INTO WCLOBTMP
      FROM DUAL;
      WLENLOB      := DBMS_LOB.getLength(WCLOBTMP);
      WNUMLINE     :=1;
      WHILE WOFFSET<=WLENLOB
      LOOP
        WROWLEN  :=instr(WCLOBTMP,chr(10),WOFFSET)-WOFFSET;
        IF WROWLEN<0 THEN
          WROWLEN:=WLENLOB+1-WOFFSET;
        END IF;
        WONEROW:=SUBSTR(WCLOBTMP,WOFFSET,WROWLEN);
        IF REGEXP_LIKE(WONEROW,WSEARCH,'i') THEN
          dbms_output.put_line( WREC.MVIEW_NAME||WCOLSEP||WREC.OWNER||WCOLSEP||'MATERIALIZED VIEW'||WCOLSEP|| TO_CHAR(WNUMLINE)||WCOLSEP||LTRIM(RTRIM(WONEROW)));
        END IF;
        WOFFSET  :=WOFFSET   +WROWLEN+1;
        WNUMLINE := WNUMLINE + 1;
      END LOOP;
      --**********************
  FOR WREC IN
  (SELECT NAME,OWNER,TYPE,TEXT
  FROM DBA_SOURCE
  WHERE 1=1
  AND REGEXP_LIKE(OWNER,WOBJOWNE,'i')
  AND REGEXP_LIKE (TEXT,WSEARCH,'i')
  AND NOT REGEXP_LIKE (TEXT,'demodocument','i')
  )
  LOOP
         dbms_output.put_line( WREC.NAME||WCOLSEP||WREC.OWNER||WCOLSEP||WREC.TYPE||WCOLSEP|| TO_CHAR(WNUMLINE)||WCOLSEP||LTRIM(RTRIM(
         REPLACE(WREC.TEXT,CHR(10),'')
         )));
  END LOOP;      
  --**********************      
  END IF;
    WOFFSET := 1;
  END LOOP;
END;
/
