CREATE OR REPLACE PROCEDURE CRUD_CP4_DIM_VENDEDOR(
    v_operacao         IN VARCHAR2,
    v_sk_vendedor      IN CP4_DIM_VENDEDOR.SK_VENDEDOR%TYPE DEFAULT NULL,
    v_cod_vendedor     IN CP4_DIM_VENDEDOR.COD_VENDEDOR%TYPE DEFAULT NULL,
    v_nom_vendedor     IN CP4_DIM_VENDEDOR.NOM_VENDEDOR%TYPE DEFAULT NULL,
    v_sta_ativo        IN CP4_DIM_VENDEDOR.STA_ATIVO%TYPE DEFAULT NULL,
    v_dat_inicio       IN CP4_DIM_VENDEDOR.DAT_INICIO%TYPE DEFAULT SYSDATE,
    v_dat_fim          IN CP4_DIM_VENDEDOR.DAT_FIM%TYPE DEFAULT NULL,
    v_fl_corrente      IN CP4_DIM_VENDEDOR.FL_CORRENTE%TYPE DEFAULT 'S'
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_existe_vendedor BOOLEAN := FALSE;
    v_sk_novo NUMBER;
    
    -- Variáveis para o SELECT
    v_result_cod_vendedor    CP4_DIM_VENDEDOR.COD_VENDEDOR%TYPE;
    v_result_nom_vendedor    CP4_DIM_VENDEDOR.NOM_VENDEDOR%TYPE;
    v_result_sta_ativo       CP4_DIM_VENDEDOR.STA_ATIVO%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') AND v_cod_vendedor IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Código do vendedor é obrigatório');
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe o vendedor com o mesmo código
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_VENDEDOR
        WHERE COD_VENDEDOR = v_cod_vendedor AND FL_CORRENTE = 'S';
        
        IF v_count > 0 THEN
            -- Se já existe, marca o registro atual como não corrente
            UPDATE CP4_DIM_VENDEDOR
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_VENDEDOR = v_cod_vendedor AND FL_CORRENTE = 'S';
            
            v_existe_vendedor := TRUE;
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_VENDEDOR.NEXTVAL;
        
        INSERT INTO CP4_DIM_VENDEDOR (
            SK_VENDEDOR,
            COD_VENDEDOR,
            NOM_VENDEDOR,
            STA_ATIVO,
            DAT_INICIO,
            DAT_FIM,
            FL_CORRENTE
        ) VALUES (
            v_sk_novo,
            v_cod_vendedor,
            v_nom_vendedor,
            v_sta_ativo,
            v_dat_inicio,
            v_dat_fim,
            v_fl_corrente
        );
        
        IF v_existe_vendedor THEN
            v_mensagem := 'Vendedor atualizado com nova versão.';
        ELSE
            v_mensagem := 'Vendedor inserido com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK
        IF v_sk_vendedor IS NOT NULL THEN
            UPDATE CP4_DIM_VENDEDOR
            SET NOM_VENDEDOR = v_nom_vendedor,
                STA_ATIVO = v_sta_ativo,
                DAT_FIM = v_dat_fim,
                FL_CORRENTE = v_fl_corrente
            WHERE SK_VENDEDOR = v_sk_vendedor;
            
            v_mensagem := 'Vendedor atualizado com sucesso por SK.';
        ELSE
            -- Marca registro atual como não corrente
            UPDATE CP4_DIM_VENDEDOR
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_VENDEDOR = v_cod_vendedor AND FL_CORRENTE = 'S';
            
            -- Insere novo registro (versão atualizada)
            v_sk_novo := SEQ_SK_VENDEDOR.NEXTVAL;
            
            INSERT INTO CP4_DIM_VENDEDOR (
                SK_VENDEDOR,
                COD_VENDEDOR,
                NOM_VENDEDOR,
                STA_ATIVO,
                DAT_INICIO,
                DAT_FIM,
                FL_CORRENTE
            ) VALUES (
                v_sk_novo,
                v_cod_vendedor,
                v_nom_vendedor,
                v_sta_ativo,
                SYSDATE,
                v_dat_fim,
                'S'
            );
            
            v_mensagem := 'Vendedor atualizado com nova versão por código.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão lógica - marca como não corrente
        IF v_sk_vendedor IS NOT NULL THEN
            UPDATE CP4_DIM_VENDEDOR
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE SK_VENDEDOR = v_sk_vendedor;
            
            v_mensagem := 'Vendedor marcado como inativo por SK.';
        ELSE
            UPDATE CP4_DIM_VENDEDOR
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_VENDEDOR = v_cod_vendedor AND FL_CORRENTE = 'S';
            
            v_mensagem := 'Vendedor marcado como inativo por código.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT COD_VENDEDOR, NOM_VENDEDOR, STA_ATIVO
            INTO v_result_cod_vendedor, v_result_nom_vendedor, v_result_sta_ativo
            FROM CP4_DIM_VENDEDOR
            WHERE (v_sk_vendedor IS NULL OR SK_VENDEDOR = v_sk_vendedor)
              AND (v_cod_vendedor IS NULL OR COD_VENDEDOR = v_cod_vendedor)
              AND FL_CORRENTE = 'S';
              
            DBMS_OUTPUT.PUT_LINE('Código: ' || v_result_cod_vendedor);
            DBMS_OUTPUT.PUT_LINE('Nome: ' || v_result_nom_vendedor);
            DBMS_OUTPUT.PUT_LINE('Status: ' || v_result_sta_ativo);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Vendedor não encontrado.');
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
END CRUD_CP4_DIM_VENDEDOR;
/


---------------------------------------------------------------------------------------------------------------------------------------



