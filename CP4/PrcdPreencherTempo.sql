CREATE OR REPLACE PROCEDURE PREENCHER_CP4_DIM_TEMPO(
    p_data_inicio IN DATE,
    p_data_fim IN DATE
) IS
    v_data DATE;
    v_dia NUMBER(2);
    v_mes NUMBER(2);
    v_ano NUMBER(4);
    v_trimestre NUMBER(1);
    v_semestre NUMBER(1);
    v_nom_mes VARCHAR2(20);
    v_nom_mes_abrev VARCHAR2(3);
    v_nom_trimestre VARCHAR2(20);
    v_nom_semestre VARCHAR2(20);
    v_fl_fim_semana CHAR(1);
    v_num_dia_semana NUMBER(1);
    v_count NUMBER;
    v_sk_tempo NUMBER;
BEGIN
    -- Validações básicas
    IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data inicial e data final são obrigatórias');
    END IF;
    
    IF p_data_inicio > p_data_fim THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data inicial deve ser menor ou igual à data final');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Iniciando preenchimento da CP4_DIMensão tempo de ' || 
                         TO_CHAR(p_data_inicio, 'DD/MM/YYYY') || ' até ' || 
                         TO_CHAR(p_data_fim, 'DD/MM/YYYY'));
    
    -- Loop pelas datas
    v_data := p_data_inicio;
    
    WHILE v_data <= p_data_fim LOOP
        -- Verifica se a data já existe
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_TEMPO
        WHERE DATA = v_data;
        
        IF v_count = 0 THEN
            -- Extrai componentes da data
            v_dia := EXTRACT(DAY FROM v_data);
            v_mes := EXTRACT(MONTH FROM v_data);
            v_ano := EXTRACT(YEAR FROM v_data);
            
            -- Determina trimestre e semestre
            v_trimestre := CASE
                WHEN v_mes BETWEEN 1 AND 3 THEN 1
                WHEN v_mes BETWEEN 4 AND 6 THEN 2
                WHEN v_mes BETWEEN 7 AND 9 THEN 3
                ELSE 4
            END;
            
            v_semestre := CASE WHEN v_mes <= 6 THEN 1 ELSE 2 END;
            
            -- Determina nomes
            v_nom_mes := TO_CHAR(v_data, 'FMMONTH');
            v_nom_mes_abrev := TO_CHAR(v_data, 'MON');
            v_nom_trimestre := 'Trimestre ' || v_trimestre;
            v_nom_semestre := 'Semestre ' || v_semestre;
            
            -- Determina dia da semana e se é fim de semana
            v_num_dia_semana := TO_NUMBER(TO_CHAR(v_data, 'D'));
            v_fl_fim_semana := CASE WHEN v_num_dia_semana IN (1, 7) THEN 'S' ELSE 'N' END;
            
            -- Insere na CP4_DIMensão tempo usando a procedure CRUD
            CRUD_CP4_DIM_TEMPO(
                v_operacao => 'INSERT',
                v_data => v_data,
                v_dia => v_dia,
                v_mes => v_mes,
                v_ano => v_ano,
                v_trimestre => v_trimestre,
                v_semestre => v_semestre,
                v_nom_mes => v_nom_mes,
                v_nom_mes_abrev => v_nom_mes_abrev,
                v_nom_trimestre => v_nom_trimestre,
                v_nom_semestre => v_nom_semestre,
                v_fl_feriado => 'N',
                v_fl_fim_semana => v_fl_fim_semana,
                v_num_dia_semana => v_num_dia_semana
            );
        END IF;
        
        -- Avança para o próximo dia
        v_data := v_data + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('CP4_DIMensão tempo preenchida com sucesso.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao preencher CP4_DIMensão tempo: ' || SQLERRM);
        ROLLBACK;
END PREENCHER_CP4_DIM_TEMPO;
/