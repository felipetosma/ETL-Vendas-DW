CREATE OR REPLACE PROCEDURE CRUD_CP4_DIM_VENDAS(
    v_operacao         IN VARCHAR2,
    v_sk_vendas        IN CP4_DIM_VENDAS.SK_VENDAS%TYPE DEFAULT NULL,
    v_cod_produto      IN CP4_DIM_VENDAS.COD_PRODUTO%TYPE DEFAULT NULL,
    v_cod_pedido       IN CP4_DIM_VENDAS.COD_PEDIDO%TYPE DEFAULT NULL,
    v_nom_produto      IN CP4_DIM_VENDAS.NOM_PRODUTO%TYPE DEFAULT NULL,
    v_cod_barra        IN CP4_DIM_VENDAS.COD_BARRA%TYPE DEFAULT NULL,
    v_dat_pedido       IN CP4_DIM_VENDAS.DAT_PEDIDO%TYPE DEFAULT NULL,
    v_dat_entrega      IN CP4_DIM_VENDAS.DAT_ENTREGA%TYPE DEFAULT NULL,
    v_dat_cancelamento IN CP4_DIM_VENDAS.DAT_CANCELAMENTO%TYPE DEFAULT NULL,
    v_sta_pedido       IN CP4_DIM_VENDAS.STA_PEDIDO%TYPE DEFAULT NULL,
    v_val_total_pedido IN CP4_DIM_VENDAS.VAL_TOTAL_PEDIDO%TYPE DEFAULT NULL,
    v_val_desconto     IN CP4_DIM_VENDAS.VAL_DESCONTO%TYPE DEFAULT NULL,
    v_dat_inicio       IN CP4_DIM_VENDAS.DAT_INICIO%TYPE DEFAULT SYSDATE,
    v_dat_fim          IN CP4_DIM_VENDAS.DAT_FIM%TYPE DEFAULT NULL,
    v_fl_corrente      IN CP4_DIM_VENDAS.FL_CORRENTE%TYPE DEFAULT 'S'
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_existe_vendas BOOLEAN := FALSE;
    v_sk_novo NUMBER;
    
    -- Variáveis para o SELECT
    v_result_cod_produto     CP4_DIM_VENDAS.COD_PRODUTO%TYPE;
    v_result_cod_pedido      CP4_DIM_VENDAS.COD_PEDIDO%TYPE;
    v_result_nom_produto     CP4_DIM_VENDAS.NOM_PRODUTO%TYPE;
    v_result_dat_pedido      CP4_DIM_VENDAS.DAT_PEDIDO%TYPE;
    v_result_sta_pedido      CP4_DIM_VENDAS.STA_PEDIDO%TYPE;
    v_result_val_total       CP4_DIM_VENDAS.VAL_TOTAL_PEDIDO%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') AND (v_cod_produto IS NULL OR v_cod_pedido IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Código do produto e código do pedido são obrigatórios');
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe o registro com o mesmo código de produto e pedido
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_VENDAS
        WHERE COD_PRODUTO = v_cod_produto 
          AND COD_PEDIDO = v_cod_pedido 
          AND FL_CORRENTE = 'S';
        
        IF v_count > 0 THEN
            -- Se já existe, marca o registro atual como não corrente
            UPDATE CP4_DIM_VENDAS
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_PRODUTO = v_cod_produto 
              AND COD_PEDIDO = v_cod_pedido 
              AND FL_CORRENTE = 'S';
            
            v_existe_vendas := TRUE;
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_VENDAS.NEXTVAL;
        
        INSERT INTO CP4_DIM_VENDAS (
            SK_VENDAS,
            COD_PRODUTO,
            COD_PEDIDO,
            NOM_PRODUTO,
            COD_BARRA,
            DAT_PEDIDO,
            DAT_ENTREGA,
            DAT_CANCELAMENTO,
            STA_PEDIDO,
            VAL_TOTAL_PEDIDO,
            VAL_DESCONTO,
            DAT_INICIO,
            DAT_FIM,
            FL_CORRENTE
        ) VALUES (
            v_sk_novo,
            v_cod_produto,
            v_cod_pedido,
            v_nom_produto,
            v_cod_barra,
            v_dat_pedido,
            v_dat_entrega,
            v_dat_cancelamento,
            v_sta_pedido,
            v_val_total_pedido,
            v_val_desconto,
            v_dat_inicio,
            v_dat_fim,
            v_fl_corrente
        );
        
        IF v_existe_vendas THEN
            v_mensagem := 'Registro de vendas atualizado com nova versão.';
        ELSE
            v_mensagem := 'Registro de vendas inserido com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK
        IF v_sk_vendas IS NOT NULL THEN
            UPDATE CP4_DIM_VENDAS
            SET NOM_PRODUTO = v_nom_produto,
                COD_BARRA = v_cod_barra,
                DAT_PEDIDO = v_dat_pedido,
                DAT_ENTREGA = v_dat_entrega,
                DAT_CANCELAMENTO = v_dat_cancelamento,
                STA_PEDIDO = v_sta_pedido,
                VAL_TOTAL_PEDIDO = v_val_total_pedido,
                VAL_DESCONTO = v_val_desconto,
                DAT_FIM = v_dat_fim,
                FL_CORRENTE = v_fl_corrente
            WHERE SK_VENDAS = v_sk_vendas;
            
            v_mensagem := 'Registro de vendas atualizado com sucesso por SK.';
        ELSE
            -- Marca registro atual como não corrente
            UPDATE CP4_DIM_VENDAS
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_PRODUTO = v_cod_produto 
              AND COD_PEDIDO = v_cod_pedido 
              AND FL_CORRENTE = 'S';
            
            -- Insere novo registro (versão atualizada)
            v_sk_novo := SEQ_SK_VENDAS.NEXTVAL;
            
            INSERT INTO CP4_DIM_VENDAS (
                SK_VENDAS,
                COD_PRODUTO,
                COD_PEDIDO,
                NOM_PRODUTO,
                COD_BARRA,
                DAT_PEDIDO,
                DAT_ENTREGA,
                DAT_CANCELAMENTO,
                STA_PEDIDO,
                VAL_TOTAL_PEDIDO,
                VAL_DESCONTO,
                DAT_INICIO,
                DAT_FIM,
                FL_CORRENTE
            ) VALUES (
                v_sk_novo,
                v_cod_produto,
                v_cod_pedido,
                v_nom_produto,
                v_cod_barra,
                v_dat_pedido,
                v_dat_entrega,
                v_dat_cancelamento,
                v_sta_pedido,
                v_val_total_pedido,
                v_val_desconto,
                SYSDATE,
                v_dat_fim,
                'S'
            );
            
            v_mensagem := 'Registro de vendas atualizado com nova versão por códigos.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão lógica - marca como não corrente
        IF v_sk_vendas IS NOT NULL THEN
            UPDATE CP4_DIM_VENDAS
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE SK_VENDAS = v_sk_vendas;
            
            v_mensagem := 'Registro de vendas marcado como inativo por SK.';
        ELSE
            UPDATE CP4_DIM_VENDAS
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_PRODUTO = v_cod_produto 
              AND COD_PEDIDO = v_cod_pedido 
              AND FL_CORRENTE = 'S';
            
            v_mensagem := 'Registro de vendas marcado como inativo por códigos.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT COD_PRODUTO, COD_PEDIDO, NOM_PRODUTO, DAT_PEDIDO, STA_PEDIDO, VAL_TOTAL_PEDIDO
            INTO v_result_cod_produto, v_result_cod_pedido, v_result_nom_produto, 
                 v_result_dat_pedido, v_result_sta_pedido, v_result_val_total
            FROM CP4_DIM_VENDAS
            WHERE (v_sk_vendas IS NULL OR SK_VENDAS = v_sk_vendas)
              AND (v_cod_produto IS NULL OR COD_PRODUTO = v_cod_produto)
              AND (v_cod_pedido IS NULL OR COD_PEDIDO = v_cod_pedido)
              AND FL_CORRENTE = 'S';
              
            DBMS_OUTPUT.PUT_LINE('Código Produto: ' || v_result_cod_produto);
            DBMS_OUTPUT.PUT_LINE('Código Pedido: ' || v_result_cod_pedido);
            DBMS_OUTPUT.PUT_LINE('Nome Produto: ' || v_result_nom_produto);
            DBMS_OUTPUT.PUT_LINE('Data Pedido: ' || TO_CHAR(v_result_dat_pedido, 'DD/MM/YYYY'));
            DBMS_OUTPUT.PUT_LINE('Status Pedido: ' || v_result_sta_pedido);
            DBMS_OUTPUT.PUT_LINE('Valor Total: ' || v_result_val_total);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Registro de vendas não encontrado.');
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
END CRUD_CP4_DIM_VENDAS;
/


