CREATE OR REPLACE PROCEDURE PR_CARREGA_FERIADO(PI_QNT_ANOS IN INTEGER) IS

  VALOR_X INTEGER := 24;
  VALOR_Y INTEGER := 5;
  MOD_19  INTEGER := 19;
  MOD_4   INTEGER := 4;
  MOD_7   INTEGER := 7;
  MOD_30  INTEGER := 30;

  VN_A        INTEGER;
  VN_B        NUMBER;
  VN_C        NUMBER;
  VN_D        NUMBER;
  VN_E        NUMBER;
  VD_PASCOA   DATE;
  VD_CARNAVAL DATE;
  VD_CORPUS   DATE;
  VD_ANO      INTEGER;
  VI_CONTANO  INTEGER := 0;
  VC_DIA      CHAR(4);

BEGIN

  FOR I IN 1 .. PI_QNT_ANOS LOOP
  
    VD_ANO := TO_CHAR(SYSDATE + NUMTOYMINTERVAL(VI_CONTANO, 'YEAR'), 'RRRR');
    /*Para anos entre 1901 e 2099:
    X=24
    Y=5
    a = ANO MOD 19
    b= ANO MOD 4
    c = ANO MOD 7
    d = (19 * a + X) MOD 30
    e = (2 * b + 4 * c + 6 * d + Y) MOD 7
    Se (d + e) > 9 então DIA = (d + e - 9) e MES = Abril
    senão DIA = (d + e + 22) e MES = Março
    
    
    Para calcular a Terça-feira de Carnaval, basta subtrair 47 dias do Domingo de Páscoa.
    Para calcular a Quinta-feira de Corpus Christi, soma-se 60 dias ao Domingo de Páscoa.*/
  
    VN_A := MOD(VD_ANO, MOD_19);
    VN_B := MOD(VD_ANO, MOD_4);
    VN_C := MOD(VD_ANO, MOD_7);
    VN_D := MOD((19 * VN_A + VALOR_X), MOD_30);
    VN_E := MOD((2 * VN_B + 4 * VN_C + 6 * VN_D + VALOR_Y), MOD_7);
  
    IF (VN_D + VN_E) > 9 THEN
    
      IF LENGTH(TRIM((VN_D + VN_E - 9))) = 1 THEN
      
        VC_DIA := '0' || (VN_D + VN_E - 9);
      ELSE
        VC_DIA := (VN_D + VN_E - 9);
      
      END IF;
    
      VD_PASCOA := TO_DATE(((VC_DIA) || '04' || VD_ANO), 'DD/MM/RRRR');
    
    ELSE
    
      VD_PASCOA := TO_DATE(((VN_D + VN_E + 22) || '03' || VD_ANO), 'DD/MM/RRRR');
    
    END IF;
  
    VD_CARNAVAL := TO_DATE(VD_PASCOA - 47, 'DD/MM/RRRR');
  
    VD_CORPUS := TO_DATE(VD_PASCOA + 60, 'DD/MM/RRRR');
  
    FOR C_DATAS IN (SELECT VS_DIAS
                      FROM DEF_SIST_DIAS_FERI) LOOP
    
      INSERT INTO DEF_SIST_FERIADO
        (D_DATA,
         S_TIPO)
      VALUES
        (TO_DATE(C_DATAS.VS_DIAS || VD_ANO, 'DD/MM/RRRR'),
         'NA');
    
    END LOOP;
  
    INSERT INTO DEF_SIST_FERIADO
      (D_DATA,
       S_TIPO)
    VALUES
      (VD_CARNAVAL,
       'NA');
  
    INSERT INTO DEF_SIST_FERIADO
      (D_DATA,
       S_TIPO)
    VALUES
      (VD_CORPUS,
       'NA');
  
    INSERT INTO DEF_SIST_FERIADO
      (D_DATA,
       S_TIPO)
    VALUES
      (VD_PASCOA,
       'NA');
  
    COMMIT;
  
    VI_CONTANO := VI_CONTANO + 1;
  
  END LOOP;

END PR_CARREGA_FERIADO;
