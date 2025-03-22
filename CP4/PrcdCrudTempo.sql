CREATE OR REPLACE PROCEDURE CRUD_CP4_DIM_TEMPO(
    v_operacao         IN VARCHAR2,
    v_sk_tempo         IN CP4_DIM_TEMPO.SK_TEMPO%TYPE DEFAULT NULL,
    v_data             IN CP4_DIM_TEMPO.DATA%TYPE DEFAULT NULL,
    v_dia              IN CP4_DIM_TEMPO.DIA%TYPE DEFAULT NULL,
    v_mes              IN CP4_DIM_TEMPO.MES%TYPE DEFAULT NULL,
    v_ano              IN CP4_DIM_TEMPO.ANO%TYPE DEFAULT NULL,
    v_trimestre        IN CP4_DIM_TEMPO.TRIMESTRE%TYPE DEFAULT NULL,
    v_semestre         IN CP4_DIM_TEMPO.SEMESTRE%TYPE DEFAULT NULL,
    v_nom_mes          IN CP4_DIM_TEMPO.NOM_MES%TYPE DEFAULT NULL,
    v_nom_mes_abrev    IN CP4_DIM_TEMPO.NOM_MES_ABREV%TYPE DEFAULT NULL,
    v_nom_trimestre    IN CP4_DIM_TEMPO.NOM_TRIMESTRE%TYPE DEFAULT NULL,
    v_nom_semestre     IN CP4_DIM_TEMPO.NOM_SEMESTRE%TYPE DEFAULT NULL,
    v_fl_feriado       IN CP4_DIM_TEMPO.FL_FERIADO%TYPE DEFAULT 'N',
    v_fl_fim_semana    IN CP4_DIM_TEMPO.FL_FIM_SEMANA%TYPE DEFAULT 'N',
    v_num_dia_semana   IN CP4_DIM_TEMPO.NUM_DIA_SEMANA%TYPE DEFAULT NULL
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_sk_novo NUMBER;
    
    -- Variáveis locais para cálculos
    v_dia_local CP4_DIM_TEMPO.DIA%TYPE;
    v_mes_local CP4_DIM_TEMPO.MES%TYPE;
    v_ano_local CP4_DIM_TEMPO.ANO%TYPE;
    v_trimestre_local CP4_DIM_TEMPO.TRIMESTRE%TYPE;
    v_semestre_local CP4_DIM_TEMPO.SEMESTRE%TYPE;
    v_nom_mes_local CP4_DIM_TEMPO.NOM_MES%TYPE;
    v_nom_mes_abrev_local CP4_DIM_TEMPO.NOM_MES_ABREV%TYPE;
    v_nom_trimestre_local CP4_DIM_TEMPO.NOM_TRIMESTRE%TYPE;
    v_nom_semestre_local CP4_DIM_TEMPO.NOM_SEMESTRE%TYPE;
    v_fl_fim_semana_local CP4_DIM_TEMPO.FL_FIM_SEMANA%TYPE;
    v_num_dia_semana_local CP4_DIM_TEMPO.NUM_DIA_SEMANA%TYPE;
    
    -- Variáveis para o SELECT
    v_result_data           CP4_DIM_TEMPO.DATA%TYPE;
    v_result_dia            CP4_DIM_TEMPO.DIA%TYPE;
    v_result_mes            CP4_DIM_TEMPO.MES%TYPE;
    v_result_ano            CP4_DIM_TEMPO.ANO%TYPE;
    v_result_trimestre      CP4_DIM_TEMPO.TRIMESTRE%TYPE;
    v_result_nom_mes        CP4_DIM_TEMPO.NOM_MES%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') AND v_data IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data é obrigatória');
    END IF;

    -- Para INSERT e UPDATE, preencher automaticamente informações baseadas na data
    IF v_operacao IN ('INSERT', 'UPDATE') AND v_data IS NOT NULL THEN
        -- Extrair componentes da data para variáveis locais
        v_dia_local := EXTRACT(DAY FROM v_data);
        v_mes_local := EXTRACT(MONTH FROM v_data);
        v_ano_local := EXTRACT(YEAR FROM v_data);
        
        -- Determinar trimestre com base no mês
        IF v_mes_local BETWEEN 1 AND 3 THEN
            v_trimestre_local := 1;
        ELSIF v_mes_local BETWEEN 4 AND 6 THEN
            v_trimestre_local := 2;
        ELSIF v_mes_local BETWEEN 7 AND 9 THEN
            v_trimestre_local := 3;
        ELSE
            v_trimestre_local := 4;
        END IF;
        
        -- Determinar semestre
        IF v_mes_local <= 6 THEN
            v_semestre_local := 1;
        ELSE
            v_semestre_local := 2;
        END IF;
        
        -- Obter nomes
        v_nom_mes_local := TO_CHAR(v_data, 'MONTH');
        v_nom_mes_abrev_local := TO_CHAR(v_data, 'MON');
        v_nom_trimestre_local := 'Trimestre ' || v_trimestre_local;
        v_nom_semestre_local := 'Semestre ' || v_semestre_local;
        
        -- Determinar dia da semana e fim de semana
        v_num_dia_semana_local := TO_NUMBER(TO_CHAR(v_data, 'D'));
        IF v_num_dia_semana_local IN (1, 7) THEN
            v_fl_fim_semana_local := 'S';
        ELSE
            v_fl_fim_semana_local := 'N';
        END IF;
        
        -- Usar os valores informados ou calculados
        v_dia_local := NVL(v_dia, v_dia_local);
        v_mes_local := NVL(v_mes, v_mes_local);
        v_ano_local := NVL(v_ano, v_ano_local);
        v_trimestre_local := NVL(v_trimestre, v_trimestre_local);
        v_semestre_local := NVL(v_semestre, v_semestre_local);
        v_nom_mes_local := NVL(v_nom_mes, v_nom_mes_local);
        v_nom_mes_abrev_local := NVL(v_nom_mes_abrev, v_nom_mes_abrev_local);
        v_nom_trimestre_local := NVL(v_nom_trimestre, v_nom_trimestre_local);
        v_nom_semestre_local := NVL(v_nom_semestre, v_nom_semestre_local);
        v_num_dia_semana_local := NVL(v_num_dia_semana, v_num_dia_semana_local);
        v_fl_fim_semana_local := NVL(v_fl_fim_semana, v_fl_fim_semana_local);
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe a data
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_TEMPO
        WHERE DATA = v_data;
        
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Data já existe na CP4_DIMensão tempo');
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_TEMPO.NEXTVAL;
        
        INSERT INTO CP4_DIM_TEMPO (
            SK_TEMPO,
            DATA,
            DIA,
            MES,
            ANO,
            TRIMESTRE,
            SEMESTRE,
            NOM_MES,
            NOM_MES_ABREV,
            NOM_TRIMESTRE,
            NOM_SEMESTRE,
            FL_FERIADO,
            FL_FIM_SEMANA,
            NUM_DIA_SEMANA
        ) VALUES (
            v_sk_novo,
            v_data,
            v_dia_local,
            v_mes_local,
            v_ano_local,
            v_trimestre_local,
            v_semestre_local,
            v_nom_mes_local,
            v_nom_mes_abrev_local,
            v_nom_trimestre_local,
            v_nom_semestre_local,
            v_fl_feriado,
            v_fl_fim_semana_local,
            v_num_dia_semana_local
        );
        
        v_mensagem := 'Data inserida com sucesso na CP4_DIMensão tempo.';
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK ou data
        IF v_sk_tempo IS NOT NULL THEN
            UPDATE CP4_DIM_TEMPO
            SET DATA = v_data,
                DIA = v_dia_local,
                MES = v_mes_local,
                ANO = v_ano_local,
                TRIMESTRE = v_trimestre_local,
                SEMESTRE = v_semestre_local,
                NOM_MES = v_nom_mes_local,
                NOM_MES_ABREV = v_nom_mes_abrev_local,
                NOM_TRIMESTRE = v_nom_trimestre_local,
                NOM_SEMESTRE = v_nom_semestre_local,
                FL_FERIADO = v_fl_feriado,
                FL_FIM_SEMANA = v_fl_fim_semana_local,
                NUM_DIA_SEMANA = v_num_dia_semana_local
            WHERE SK_TEMPO = v_sk_tempo;
            
            v_mensagem := 'Data atualizada com sucesso por SK.';
        ELSE
            UPDATE CP4_DIM_TEMPO
            SET DIA = v_dia_local,
                MES = v_mes_local,
                ANO = v_ano_local,
                TRIMESTRE = v_trimestre_local,
                SEMESTRE = v_semestre_local,
                NOM_MES = v_nom_mes_local,
                NOM_MES_ABREV = v_nom_mes_abrev_local,
                NOM_TRIMESTRE = v_nom_trimestre_local,
                NOM_SEMESTRE = v_nom_semestre_local,
                FL_FERIADO = v_fl_feriado,
                FL_FIM_SEMANA = v_fl_fim_semana_local,
                NUM_DIA_SEMANA = v_num_dia_semana_local
            WHERE DATA = v_data;
            
            v_mensagem := 'Data atualizada com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão física
        IF v_sk_tempo IS NOT NULL THEN
            DELETE FROM CP4_DIM_TEMPO
            WHERE SK_TEMPO = v_sk_tempo;
            
            v_mensagem := 'Data removida com sucesso por SK.';
        ELSE
            DELETE FROM CP4_DIM_TEMPO
            WHERE DATA = v_data;
            
            v_mensagem := 'Data removida com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT DATA, DIA, MES, ANO, TRIMESTRE, NOM_MES
            INTO v_result_data, v_result_dia, v_result_mes, 
                 v_result_ano, v_result_trimestre, v_result_nom_mes
            FROM CP4_DIM_TEMPO
            WHERE (v_sk_tempo IS NULL OR SK_TEMPO = v_sk_tempo)
              AND (v_data IS NULL OR DATA = v_data);
              
            DBMS_OUTPUT.PUT_LINE('Data: ' || TO_CHAR(v_result_data, 'DD/MM/YYYY'));
            DBMS_OUTPUT.PUT_LINE('Dia: ' || v_result_dia);
            DBMS_OUTPUT.PUT_LINE('Mês: ' || v_result_mes);
            DBMS_OUTPUT.PUT_LINE('Ano: ' || v_result_ano);
            DBMS_OUTPUT.PUT_LINE('Trimestre: ' || v_result_trimestre);
            DBMS_OUTPUT.PUT_LINE('Nome Mês: ' || v_result_nom_mes);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Data não encontrada.');
        END;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Operação inválida. Utilize INSERT, UPDATE, DELETE ou SELECT.');
    END IF;
    
    IF v_operacao != 'SELECT' THEN
        DBMS_OUTPUT.PUT_LINE(v_mensagem);
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a operação: ' || SQLERRM);
        ROLLBACK;
END CRUD_CP4_DIM_TEMPO;
/
