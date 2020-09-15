/*
  fablabway.com
  file:        youdir.sql
  project:     oracle directories performances
  description:  oracle
  author:       Mauro Rossolato
  licence:      Creative Commons BY-NC-ND
  when        who   what
  -----------------------------------
  19.05.2018  mr    creates
*/

SET LINESIZE 200
SET SERVEROUTPUT ON SIZE 1000000

DECLARE
    V_FILE      UTL_FILE.FILE_TYPE;
    VTIME number; 
    VTIME2 number; 
    WMIADIR varchar2(40);
    WTHISONE varchar2(30) := 'YOUDIR';
    wmiopath varchar2(80);
    wmsgsentence varchar2(100);
    wmsgrow varchar2(4000);
    wmsgrowbytes number;
    whowmany number;
    wnumloop number;
BEGIN
  whowmany := 50;
  wnumloop := 4000;
  wmsgrow := rpad(wmsgsentence,whowmany*LENGTH(wmsgsentence),wmsgsentence);
  select vsize(wmsgrow)*wnumloop into wmsgrowbytes from dual;
  dbms_output.put_line(WTHISONE ||' - https://github.com/fablabway/acheloo');
  dbms_output.put_line('==> Oracle Dire performances');
  dbms_output.put_line('==> write a file '||to_char(wmsgrowbytes)||' bytes long');
  dbms_output.put_line(rpad('-',50,'-'));
  FOR WDIR IN (SELECT DIRECTORY_NAME,DIRECTORY_PATH FROM ALL_DIRECTORIES 
)
  LOOP
  begin
    VTIME := DBMS_UTILITY.GET_TIME();
    WMIADIR := WDIR.DIRECTORY_NAME;
    wmiopath := WDIR.DIRECTORY_PATH;
    V_FILE := UTL_FILE.FOPEN(wmiadir, 'testmr.txt', 'W');
    for WNDX in 0..wnumloop LOOP
      UTL_FILE.PUT_LINE (v_file, 'Line '||to_char(wndx)||' '||wmsgrow);
    end loop;
    UTL_FILE.FFLUSH (V_FILE);
    UTL_FILE.FCLOSE (V_FILE);
    VTIME2 := DBMS_UTILITY.GET_TIME();
    DBMS_OUTPUT.PUT_LINE('writing on '||WMIADIR||' ('||wmiopath||') in '||TO_CHAR(((VTIME2-VTIME)*10))||'(ms)');
    EXCEPTION
   when others then
   dbms_output.put_line('*** ERROR ON LOOP '||rtrim(wmiadir)||'('||wmiopath||') - ORA'||SQLCODE);  
    end;
  end loop;
  dbms_output.put_line(rpad('-',50,'-'));
end;
/

