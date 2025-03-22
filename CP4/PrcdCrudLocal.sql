CREATE OR REPLACE PROCEDURE CRUD_CP4_DIM_LOCALIZACAO(
    v_operacao         IN VARCHAR2,
    v_sk_localizacao   IN CP4_DIM_LOCALIZACAO.SK_LOCALIZACAO%TYPE DEFAULT NULL,
    v_cod_cidade       IN CP4_DIM_LOCALIZACAO.COD_CIDADE%TYPE DEFAULT NULL,
    v_nom_cidade       IN CP4_DIM_LOCALIZACAO.NOM_CIDADE%TYPE DEFAULT NULL,
    v_cod_estado       IN CP4_DIM_LOCALIZACAO.COD_ESTADO%TYPE DEFAULT NULL,
    v_nom_estado       IN CP4_DIM_LOCALIZACAO.NOM_ESTADO%TYPE DEFAULT NULL,
    v_cod_pais         IN CP4_DIM_LOCALIZACAO.COD_PAIS%TYPE DEFAULT NULL,
    v_nom_pais         IN CP4_DIM_LOCALIZACAO.NOM_PAIS%TYPE DEFAULT NULL,
    v_dat_inicio       IN CP4_DIM_LOCALIZACAO.DAT_INICIO%TYPE DEFAULT SYSDATE,
    v_dat_fim          IN CP4_DIM_LOCALIZACAO.DAT_FIM%TYPE DEFAULT NULL,
    v_fl_corrente      IN CP4_DIM_LOCALIZACAO.FL_CORRENTE%TYPE DEFAULT 'S'
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_existe_localizacao BOOLEAN := FALSE;
    v_sk_novo NUMBER;
    
    -- Variáveis para o SELECT
    v_result_cod_cidade      CP4_DIM_LOCALIZACAO.COD_CIDADE%TYPE;
    v_result_nom_cidade      CP4_DIM_LOCALIZACAO.NOM_CIDADE%TYPE;
    v_result_cod_estado      CP4_DIM_LOCALIZACAO.COD_ESTADO%TYPE;
    v_result_nom_estado      CP4_DIM_LOCALIZACAO.NOM_ESTADO%TYPE;
    v_result_cod_pais        CP4_DIM_LOCALIZACAO.COD_PAIS%TYPE;
    v_result_nom_pais        CP4_DIM_LOCALIZACAO.NOM_PAIS%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') AND v_cod_cidade IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Código da cidade é obrigatório');
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe a localização com o mesmo código de cidade
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_LOCALIZACAO
        WHERE COD_CIDADE = v_cod_cidade AND FL_CORRENTE = 'S';
        
        IF v_count > 0 THEN
            -- Se já existe, marca o registro atual como não corrente
            UPDATE CP4_DIM_LOCALIZACAO
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CIDADE = v_cod_cidade AND FL_CORRENTE = 'S';
            
            v_existe_localizacao := TRUE;
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_LOCALIZACAO.NEXTVAL;
        
        INSERT INTO CP4_DIM_LOCALIZACAO (
            SK_LOCALIZACAO,
            COD_CIDADE,
            NOM_CIDADE,
            COD_ESTADO,
            NOM_ESTADO,
            COD_PAIS,
            NOM_PAIS,
            DAT_INICIO,
            DAT_FIM,
            FL_CORRENTE
        ) VALUES (
            v_sk_novo,
            v_cod_cidade,
            v_nom_cidade,
            v_cod_estado,
            v_nom_estado,
            v_cod_pais,
            v_nom_pais,
            v_dat_inicio,
            v_dat_fim,
            v_fl_corrente
        );
        
        IF v_existe_localizacao THEN
            v_mensagem := 'Localização atualizada com nova versão.';
        ELSE
            v_mensagem := 'Localização inserida com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK
        IF v_sk_localizacao IS NOT NULL THEN
            UPDATE CP4_DIM_LOCALIZACAO
            SET NOM_CIDADE = v_nom_cidade,
                COD_ESTADO = v_cod_estado,
                NOM_ESTADO = v_nom_estado,
                COD_PAIS = v_cod_pais,
                NOM_PAIS = v_nom_pais,
                DAT_FIM = v_dat_fim,
                FL_CORRENTE = v_fl_corrente
            WHERE SK_LOCALIZACAO = v_sk_localizacao;
            
            v_mensagem := 'Localização atualizada com sucesso por SK.';
        ELSE
            -- Marca registro atual como não corrente
            UPDATE CP4_DIM_LOCALIZACAO
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CIDADE = v_cod_cidade AND FL_CORRENTE = 'S';
            
            -- Insere novo registro (versão atualizada)
            v_sk_novo := SEQ_SK_LOCALIZACAO.NEXTVAL;
            
            INSERT INTO CP4_DIM_LOCALIZACAO (
                SK_LOCALIZACAO,
                COD_CIDADE,
                NOM_CIDADE,
                COD_ESTADO,
                NOM_ESTADO,
                COD_PAIS,
                NOM_PAIS,
                DAT_INICIO,
                DAT_FIM,
                FL_CORRENTE
            ) VALUES (
                v_sk_novo,
                v_cod_cidade,
                v_nom_cidade,
                v_cod_estado,
                v_nom_estado,
                v_cod_pais,
                v_nom_pais,
                SYSDATE,
                v_dat_fim,
                'S'
            );
            
            v_mensagem := 'Localização atualizada com nova versão por código.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão lógica - marca como não corrente
        IF v_sk_localizacao IS NOT NULL THEN
            UPDATE CP4_DIM_LOCALIZACAO
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE SK_LOCALIZACAO = v_sk_localizacao;
            
            v_mensagem := 'Localização marcada como inativa por SK.';
        ELSE
            UPDATE CP4_DIM_LOCALIZACAO
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CIDADE = v_cod_cidade AND FL_CORRENTE = 'S';
            
            v_mensagem := 'Localização marcada como inativa por código.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT COD_CIDADE, NOM_CIDADE, COD_ESTADO, NOM_ESTADO, COD_PAIS, NOM_PAIS
            INTO v_result_cod_cidade, v_result_nom_cidade, 
                 v_result_cod_estado, v_result_nom_estado, 
                 v_result_cod_pais, v_result_nom_pais
            FROM CP4_DIM_LOCALIZACAO
            WHERE (v_sk_localizacao IS NULL OR SK_LOCALIZACAO = v_sk_localizacao)
              AND (v_cod_cidade IS NULL OR COD_CIDADE = v_cod_cidade)
              AND FL_CORRENTE = 'S';
              
            DBMS_OUTPUT.PUT_LINE('Código Cidade: ' || v_result_cod_cidade);
            DBMS_OUTPUT.PUT_LINE('Nome Cidade: ' || v_result_nom_cidade);
            DBMS_OUTPUT.PUT_LINE('Código Estado: ' || v_result_cod_estado);
            DBMS_OUTPUT.PUT_LINE('Nome Estado: ' || v_result_nom_estado);
            DBMS_OUTPUT.PUT_LINE('Código País: ' || v_result_cod_pais);
            DBMS_OUTPUT.PUT_LINE('Nome País: ' || v_result_nom_pais);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Localização não encontrada.');
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
END CRUD_CP4_DIM_LOCALIZACAO;
/


---------------------------------------------------------------------------------------------------------------------------------------



