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
  04.07.2020  MR     CLOB DRILL ADDED
*/

-- ALTER SESSION SET CURRENT_SCHEMA = MYOWNER;
SET SERVEROUTPUT ON SIZE 1000000

DECLARE
    wrelcode    VARCHAR2(30) := 'WE';                       --  ??
    woperator   VARCHAR2(30) := 'mauro';                    -- ??
    wobjowne    VARCHAR2(30) := 'MYAPEX';     					-- OWNER
    wcolsep     VARCHAR2(1) := ';';            					-- COLUMN SEPARATOR
    wclobtmp    CLOB;
    wlenlob     NUMBER;                          					-- CLOB SIZE
    wnumline    NUMBER;                          					-- LINE COUNTER
    woffset     NUMBER := 1;                   					-- SINCE LAST CR
    WRECLOB     DBA_TAB_COLUMNS%ROWTYPE;
    WCOLNAME    VARCHAR2(30);
    WSTMTEXE VARCHAR2(32500);
    wonerow     VARCHAR2(32767);           					-- EXTRACTED FROM CLOB
    wrowlen     NUMBER;
    wsearch     VARCHAR2(30) := 'ARCA'; 					-- LOOKING FOR...

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
-- 12            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_CREATION',false);
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
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
-- 12            dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_CREATION',false);-- NO PHYSICAL INFO
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
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
  -- checks into clob

/* 11.08.2020 */
    FOR wrec IN (
  SELECT TABLE_NAME,COLUMN_NAME FROM DBA_TAB_COLUMNS
  WHERE 1=1
  AND OWNER=wobjowne
  AND DATA_TYPE='CLOB'
    ) LOOP

       WSTMTEXE := 
'declare  
wlenlob NUMBER;  
woffset NUMBER; 
WNUMLINE NUMBER; 
WROWLEN NUMBER; 
WONEROW VARCHAR2(300); 
WCLOBTMP CLOB; 
wcolsep    VARCHAR2(1) := '';'';
BEGIN 
    woffset := 1;   
    wnumline := 1; 
FOR WREC2 IN (SELECT '||WREC.COLUMN_NAME||' FROM '||WREC.TABLE_NAME||
    ' WHERE INSTR('||WREC.COLUMN_NAME||','''||WSEARCH||''''||')>0 ) LOOP ' ||CHR(10)||
    'wlenlob := dbms_lob.getlength(WREC2.'||WREC.COLUMN_NAME||'); '||CHR(10)||
      ' --   dbms_output.put_line(WSTMTEXE); '||CHR(10)||
           '  wnumline := 1; '||CHR(10)||
           ' wclobtmp := WREC2.'||WREC.COLUMN_NAME||'; '||CHR(10)||
           '  WHILE woffset <= wlenlob LOOP '||CHR(10)||
            '    wrowlen := instr(wclobtmp,chr(10),woffset) - woffset; '||CHR(10)||
            '    IF '||CHR(10)||
            '        wrowlen < 0 '||CHR(10)||
            '    THEN '||CHR(10)||
            '       wrowlen := wlenlob + 1 - woffset; '||CHR(10)||
            '    END IF; '||CHR(10)||
            '    wonerow := substr(wclobtmp,'||woffset||',wrowlen); '||CHR(10)||
            '    IF '||CHR(10)||
            '        regexp_like(wonerow,'||''''||wsearch||''''||',''i'') '||CHR(10)||
            '    THEN '||CHR(10)||
            '        dbms_output.put_line( '''||wrec.TABLE_NAME ||    -- wip
           ''' ' ||
            ' || wcolsep '||CHR(10)||
            '        || ''CLOB'''||CHR(10)||
            '        || wcolsep '||CHR(10)||
            '        || TO_CHAR(wnumline)'||CHR(10)||
            '        || wcolsep' ||CHR(10)||
            '        || ltrim(rtrim(wonerow) ) ); '||CHR(10)||
            '    END IF; ' ||CHR(10)||
            ' wnumline := wnumline + 1; '||CHR(10)||
            '    woffset := woffset + wrowlen + 1; '||CHR(10)||
            ' END LOOP; '||CHR(10)||
            '--    woffset := woffset + wrowlen + 1; '||CHR(10)||
            '    ' ||CHR(10)||
            'END LOOP; '||CHR(10)||
            ' END;';

    EXECUTE IMMEDIATE WSTMTEXE; -- INTO wclobtmp;

    END LOOP;
    
END;
/

