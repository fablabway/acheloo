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
    wrelcode    VARCHAR2(30) := 'WE';
    woperator   VARCHAR2(30) := 'mauro';
    wobjowne    VARCHAR2(30) := 'MYOWNER';     					-- OWNER
    wcolsep     VARCHAR2(1) := ';';            					-- COLUMN SEPARATOR
    wclobtmp    CLOB;
    wlenlob     NUMBER;                          					-- CLOB SIZE
    wnumline    NUMBER;                          					-- LINE COUNTER
    woffset     PLS_INTEGER := 1;                   					-- SINCE LAST CR
    wonerow     VARCHAR2(32767);           					-- EXTRACTED FROM CLOB
    wrowlen     NUMBER;
    wsearch     VARCHAR2(30) := '\''[1UPDJ297]'; 					-- LOOKING FOR...
--  WSEARCH   VARCHAR2(100) := 'TABLE1|VIEW1|OTHEROBJ|ANDSOON'; -- LOOKING FOR...
-- WSEARCH   VARCHAR2(100) := ' TABLE1|VIEW1|^NEGOZI'; 			-- LOOKING FOR...
-- WSEARCH   VARCHAR2(100) := 'mystring'; 					-- LOOKING FOR...
BEGIN
    FOR wrec IN (
        SELECT
            owner,
            view_name,
            text
        FROM
            dba_views
        WHERE
            1 = 1
            AND   REGEXP_LIKE ( owner,
            wobjowne,
            'i' )
    ) LOOP
        IF
            regexp_like(wrec.text,wsearch,'i')
        THEN
      -- START DDL-METADATA AND EXTRACTS THE INVOLVED ROWS
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'EMIT_SCHEMA',false);
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_CREATION',false);
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);
            SELECT
                dbms_metadata.get_ddl('VIEW',wrec.view_name,wrec.owner) myrow
            INTO
                wclobtmp
            FROM
                dual;

            wlenlob := dbms_lob.getlength(wclobtmp);
            wnumline := 1;
            WHILE woffset <= wlenlob LOOP
                wrowlen := instr(wclobtmp,chr(10),woffset) - woffset;
                IF
                    wrowlen < 0
                THEN
                    wrowlen := wlenlob + 1 - woffset;
                END IF;
                wonerow := substr(wclobtmp,woffset,wrowlen);
                IF
                    regexp_like(wonerow,wsearch,'i')
                THEN
                    dbms_output.put_line(wrec.view_name
                    || wcolsep
                    || wrec.owner
                    || wcolsep
                    || 'VIEW'
                    || wcolsep
                    || TO_CHAR(wnumline)
                    || wcolsep
                    || ltrim(rtrim(wonerow) ) );
                END IF;

                woffset := woffset + wrowlen + 1;
                wnumline := wnumline + 1;
            END LOOP;

        END IF;
    END LOOP;
  --**********************

    FOR wrec IN (
        SELECT
            owner,
            mview_name,
            query
        FROM
            dba_mviews
        WHERE
            1 = 1
            AND   REGEXP_LIKE ( owner,
            wobjowne,
            'i' )
    ) LOOP
        IF
            regexp_like(wrec.query,wsearch,'i')
        THEN
      -- START DDL-METADATA AND EXTRACTS THE INVOLVED ROWS
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'EMIT_SCHEMA',false);		-- CURRENT SCHEMA
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_CREATION',false);-- NO PHYSICAL INFO
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);			-- BEAUTYFIER
            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);			-- NO PHYSICAL INFO
            SELECT
                dbms_metadata.get_ddl('MATERIALIZED_VIEW',wrec.mview_name,wrec.owner) myrow
            INTO
                wclobtmp
            FROM
                dual;

            wlenlob := dbms_lob.getlength(wclobtmp);
            wnumline := 1;
            WHILE woffset <= wlenlob LOOP
                wrowlen := instr(wclobtmp,chr(10),woffset) - woffset;
                IF
                    wrowlen < 0
                THEN
                    wrowlen := wlenlob + 1 - woffset;
                END IF;
                wonerow := substr(wclobtmp,woffset,wrowlen);
                IF
                    regexp_like(wonerow,wsearch,'i')
                THEN
                    dbms_output.put_line(wrec.mview_name
                    || wcolsep
                    || wrec.owner
                    || wcolsep
                    || 'MATERIALIZED VIEW'
                    || wcolsep
                    || TO_CHAR(wnumline)
                    || wcolsep
                    || ltrim(rtrim(wonerow) ) );
                END IF;

                woffset := woffset + wrowlen + 1;
                wnumline := wnumline + 1;
            END LOOP;

        END IF;

        woffset := 1;
    END LOOP;
      --**********************

    FOR wrec IN (
        SELECT
            name,
            owner,
            type,
            text,
            line
        FROM
            dba_source
        WHERE
            1 = 1
            AND   REGEXP_LIKE ( owner,
            wobjowne,
            'i' )
            AND   REGEXP_LIKE ( text,
            wsearch,
            'i' )
-- OTHER CONDITIONS TO AVOID "NOISE"  					
--   AND NOT REGEXP_LIKE (TEXT,'demodocument','i')						-- CHECK HERE!
    ) LOOP
        dbms_output.put_line(wrec.name
        || wcolsep
        || wrec.owner
        || wcolsep
        || wrec.type
        || wcolsep
        || TO_CHAR(wrec.line)
        || wcolsep
        || ltrim(rtrim(replace(wrec.text,chr(10),'') ) ) );
    END LOOP;      
  --**********************      

END;
/