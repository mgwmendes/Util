CREATE OR REPLACE PROCEDURE PR_LOG(PI_MENSAGEM IN VARCHAR2 DEFAULT NULL) AS

  L_ERROS PLS_INTEGER;
  vs_NOME_OBJETO VARCHAR2(50); 
  VS_DESCRICAO VARCHAR2(2000); 
  VS_USUARIO VARCHAR2(50); 
  VC_STATUS CHAR(1);
 
BEGIN

  L_ERROS := UTL_CALL_STACK.DYNAMIC_DEPTH;

  IF PI_MENSAGEM IS NOT NULL THEN
    
     if upper(PI_MENSAGEM) = 'I' then
        VS_DESCRICAO:= 'INICIO';
     elsif upper(PI_MENSAGEM) = 'F' then
        VS_DESCRICAO:= 'FIM';
     elsif upper(PI_MENSAGEM) = 'T' then
         VS_DESCRICAO:= 'TRACE';
     else
        VS_DESCRICAO := PI_MENSAGEM;        
     end if;
       

  --  DBMS_OUTPUT.PUT_LINE('Linha do Erro: ' || RPAD(TO_CHAR(UTL_CALL_STACK.UNIT_LINE(2), '99'), 12));
    VS_DESCRICAO := VS_DESCRICAO || ' LINHA ' || trim(RPAD(TO_CHAR(UTL_CALL_STACK.UNIT_LINE(2), '99999'), 12));
    vs_NOME_OBJETO:= UTL_CALL_STACK.CONCATENATE_SUBPROGRAM(UTL_CALL_STACK.SUBPROGRAM(2));
    VS_USUARIO:= RPAD(NVL(UTL_CALL_STACK.OWNER(2), ' '), 10);
    VC_STATUS := 'N';
    
    INSERT INTO LOG
      (ID_LOG,
       NM_OBJETO,
       DESCRICAO,
       USUARIO,
       STATUS,
       DATA)
    VALUES
      (SEQ_LOG.NEXTVAL,
       VS_NOME_OBJETO,
       VS_DESCRICAO,
       VS_USUARIO,
       VC_STATUS,
       To_CHAR(SYSDATE , 'DD/MM/RRRR HH24:MI:SS'));
    commit;
    
  ELSE
  
    FOR I IN 2 .. L_ERROS LOOP
    
     --INICIO ERRO ORACLE 
      
      VS_DESCRICAO:= trim(RPAD(TO_CHAR(UTL_CALL_STACK.UNIT_LINE(I), '99999'), 10));
      VS_DESCRICAO :=   (UTL_CALL_STACK.ERROR_MSG(UTL_CALL_STACK.BACKTRACE_DEPTH)) ||' LINHA '|| VS_DESCRICAO; 
      vs_NOME_OBJETO:= UTL_CALL_STACK.CONCATENATE_SUBPROGRAM(UTL_CALL_STACK.SUBPROGRAM(I));
      VS_USUARIO := RPAD(NVL(UTL_CALL_STACK.OWNER(I), ' '), 10);
      
      VC_STATUS := 'E';
      
          INSERT INTO LOG
      (ID_LOG,
       NM_OBJETO,
       DESCRICAO,
       USUARIO,
       STATUS,
       DATA)
    VALUES
      (SEQ_LOG.NEXTVAL,
       VS_NOME_OBJETO,
       VS_DESCRICAO,
       VS_USUARIO,
       VC_STATUS,
       To_CHAR(SYSDATE , 'DD/MM/RRRR HH24:MI:SS'));
commit;
      
    END LOOP;
    
    
 
--    VS_DESCRICAO :=   (UTL_CALL_STACK.ERROR_MSG(UTL_CALL_STACK.BACKTRACE_DEPTH)) ||' LINHA '|| VS_DESCRICAO; 
     
  END IF;
  
     COMMIT;

  /* dbms_output.put_line('Line: ' || TO_CHAR(utl_call_stack.backtrace_line(utl_call_stack.backtrace_depth)));
  dbms_output.put_line('procedure: ' || \*REGEXP_SUBSTR(*\utl_call_stack.backtrace_unit(utl_call_stack.backtrace_depth) \*,'[^#]+',7)*\);
  dbms_output.put_line('Error Message: ' || utl_call_stack.error_msg(utl_call_stack.error_depth));*/

  -- dbms_output.put_line('procedure: ' || UTL_CALL_STACK.SUBPROGRAM(UTL_CALL_STACK.BACKTRACE_DEPTH ));
  -- dbms_output.put_line( 'SUBPROGRAM: ' ||  UTL_CALL_STACK.SUBPROGRAM(UTL_CALL_STACK.BACKTRACE_DEPTH ));

END PR_LOG;
