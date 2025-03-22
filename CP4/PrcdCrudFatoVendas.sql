CREATE OR REPLACE PROCEDURE CRUD_CP4_FATO_VENDAS(
    v_operacao         IN VARCHAR2,
    v_sk_venda         IN CP4_FATO_VENDAS.SK_VENDA%TYPE DEFAULT NULL,
    v_sk_cliente       IN CP4_FATO_VENDAS.SK_CLIENTE%TYPE DEFAULT NULL,
    v_sk_vendas        IN CP4_FATO_VENDAS.SK_VENDAS%TYPE DEFAULT NULL,  
    v_sk_vendedor      IN CP4_FATO_VENDAS.SK_VENDEDOR%TYPE DEFAULT NULL,
    v_sk_tempo         IN CP4_FATO_VENDAS.SK_TEMPO%TYPE DEFAULT NULL,
    v_sk_localizacao   IN CP4_FATO_VENDAS.SK_LOCALIZACAO%TYPE DEFAULT NULL,
    v_cod_pedido       IN CP4_FATO_VENDAS.COD_PEDIDO%TYPE DEFAULT NULL,
    v_cod_item_pedido  IN CP4_FATO_VENDAS.COD_ITEM_PEDIDO%TYPE DEFAULT NULL,
    v_qtd_item         IN CP4_FATO_VENDAS.QTD_ITEM%TYPE DEFAULT NULL,
    v_val_unitario     IN CP4_FATO_VENDAS.VAL_UNITARIO_ITEM%TYPE DEFAULT NULL,
    v_val_desconto     IN CP4_FATO_VENDAS.VAL_DESCONTO_ITEM%TYPE DEFAULT NULL,
    v_val_total        IN CP4_FATO_VENDAS.VAL_TOTAL_ITEM%TYPE DEFAULT NULL
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_sk_novo NUMBER;
    v_val_total_local CP4_FATO_VENDAS.VAL_TOTAL_ITEM%TYPE;
    
    -- Variáveis para o SELECT
    v_result_cod_pedido      CP4_FATO_VENDAS.COD_PEDIDO%TYPE;
    v_result_cod_item        CP4_FATO_VENDAS.COD_ITEM_PEDIDO%TYPE;
    v_result_qtd             CP4_FATO_VENDAS.QTD_ITEM%TYPE;
    v_result_val_unitario    CP4_FATO_VENDAS.VAL_UNITARIO_ITEM%TYPE;
    v_result_val_desconto    CP4_FATO_VENDAS.VAL_DESCONTO_ITEM%TYPE;
    v_result_val_total       CP4_FATO_VENDAS.VAL_TOTAL_ITEM%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') THEN
        IF v_cod_pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Código do pedido é obrigatório');
        END IF;
        
        IF v_cod_item_pedido IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Código do item do pedido é obrigatório');
        END IF;
        
        -- Calcula valor total se não informado
        v_val_total_local := v_val_total;
        IF v_val_total IS NULL AND v_qtd_item IS NOT NULL AND v_val_unitario IS NOT NULL THEN
            v_val_total_local := (v_qtd_item * v_val_unitario) - NVL(v_val_desconto, 0);
        END IF;
        
        -- Validações de chaves estrangeiras
        IF v_sk_cliente IS NULL THEN
            RAISE_APPLICATION_ERROR(-20003, 'Chave surrogate do cliente é obrigatória');
        END IF;
        
        IF v_sk_vendas IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Chave surrogate de vendas é obrigatória');
        END IF;
        
        IF v_sk_vendedor IS NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'Chave surrogate do vendedor é obrigatória');
        END IF;
        
        IF v_sk_tempo IS NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Chave surrogate do tempo é obrigatória');
        END IF;
        
        IF v_sk_localizacao IS NULL THEN
            RAISE_APPLICATION_ERROR(-20007, 'Chave surrogate da localização é obrigatória');
        END IF;
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe o registro
        SELECT COUNT(*) INTO v_count
        FROM CP4_FATO_VENDAS
        WHERE COD_PEDIDO = v_cod_pedido AND COD_ITEM_PEDIDO = v_cod_item_pedido;
        
        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Item de pedido já existe na tabela CP4_FATO');
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_VENDA.NEXTVAL;
        
        INSERT INTO CP4_FATO_VENDAS (
            SK_VENDA,
            SK_CLIENTE,
            SK_VENDAS,  
            SK_VENDEDOR,
            SK_TEMPO,
            SK_LOCALIZACAO,
            COD_PEDIDO,
            COD_ITEM_PEDIDO,
            QTD_ITEM,
            VAL_UNITARIO_ITEM,
            VAL_DESCONTO_ITEM,
            VAL_TOTAL_ITEM
        ) VALUES (
            v_sk_novo,
            v_sk_cliente,
            v_sk_vendas,  
            v_sk_vendedor,
            v_sk_tempo,
            v_sk_localizacao,
            v_cod_pedido,
            v_cod_item_pedido,
            v_qtd_item,
            v_val_unitario,
            v_val_desconto,
            v_val_total_local
        );
        
        v_mensagem := 'Item de venda inserido com sucesso.';
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK ou chaves naturais
        IF v_sk_venda IS NOT NULL THEN
            UPDATE CP4_FATO_VENDAS
            SET SK_CLIENTE = v_sk_cliente,
                SK_VENDAS = v_sk_vendas,  
                SK_VENDEDOR = v_sk_vendedor,
                SK_TEMPO = v_sk_tempo,
                SK_LOCALIZACAO = v_sk_localizacao,
                QTD_ITEM = v_qtd_item,
                VAL_UNITARIO_ITEM = v_val_unitario,
                VAL_DESCONTO_ITEM = v_val_desconto,
                VAL_TOTAL_ITEM = v_val_total_local
            WHERE SK_VENDA = v_sk_venda;
            
            v_mensagem := 'Item de venda atualizado com sucesso por SK.';
        ELSE
            UPDATE CP4_FATO_VENDAS
            SET SK_CLIENTE = v_sk_cliente,
                SK_VENDAS = v_sk_vendas,  
                SK_VENDEDOR = v_sk_vendedor,
                SK_TEMPO = v_sk_tempo,
                SK_LOCALIZACAO = v_sk_localizacao,
                QTD_ITEM = v_qtd_item,
                VAL_UNITARIO_ITEM = v_val_unitario,
                VAL_DESCONTO_ITEM = v_val_desconto,
                VAL_TOTAL_ITEM = v_val_total_local
            WHERE COD_PEDIDO = v_cod_pedido 
              AND COD_ITEM_PEDIDO = v_cod_item_pedido;
            
            v_mensagem := 'Item de venda atualizado com sucesso por chaves naturais.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão física
        IF v_sk_venda IS NOT NULL THEN
            DELETE FROM CP4_FATO_VENDAS
            WHERE SK_VENDA = v_sk_venda;
            
            v_mensagem := 'Item de venda removido com sucesso por SK.';
        ELSE
            DELETE FROM CP4_FATO_VENDAS
            WHERE COD_PEDIDO = v_cod_pedido 
              AND COD_ITEM_PEDIDO = v_cod_item_pedido;
            
            v_mensagem := 'Item de venda removido com sucesso por chaves naturais.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT COD_PEDIDO, COD_ITEM_PEDIDO, QTD_ITEM, 
                   VAL_UNITARIO_ITEM, VAL_DESCONTO_ITEM, VAL_TOTAL_ITEM
            INTO v_result_cod_pedido, v_result_cod_item, v_result_qtd,
                 v_result_val_unitario, v_result_val_desconto, v_result_val_total
            FROM CP4_FATO_VENDAS
            WHERE (v_sk_venda IS NULL OR SK_VENDA = v_sk_venda)
              AND (v_cod_pedido IS NULL OR COD_PEDIDO = v_cod_pedido)
              AND (v_cod_item_pedido IS NULL OR COD_ITEM_PEDIDO = v_cod_item_pedido);
              
            DBMS_OUTPUT.PUT_LINE('Pedido: ' || v_result_cod_pedido);
            DBMS_OUTPUT.PUT_LINE('Item: ' || v_result_cod_item);
            DBMS_OUTPUT.PUT_LINE('Quantidade: ' || v_result_qtd);
            DBMS_OUTPUT.PUT_LINE('Valor Unitário: ' || v_result_val_unitario);
            DBMS_OUTPUT.PUT_LINE('Valor Desconto: ' || v_result_val_desconto);
            DBMS_OUTPUT.PUT_LINE('Valor Total: ' || v_result_val_total);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Item de venda não encontrado.');
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
END CRUD_CP4_FATO_VENDAS;
/