CREATE OR REPLACE PROCEDURE CRUD_CP4_DIM_CLIENTE(
    v_operacao         IN VARCHAR2,
    v_sk_cliente       IN CP4_DIM_CLIENTE.SK_CLIENTE%TYPE DEFAULT NULL,
    v_cod_cliente      IN CP4_DIM_CLIENTE.COD_CLIENTE%TYPE DEFAULT NULL,
    v_nom_cliente      IN CP4_DIM_CLIENTE.NOM_CLIENTE%TYPE DEFAULT NULL,
    v_razao_social     IN CP4_DIM_CLIENTE.DES_RAZAO_SOCIAL%TYPE DEFAULT NULL,
    v_tip_pessoa       IN CP4_DIM_CLIENTE.TIP_PESSOA%TYPE DEFAULT NULL,
    v_cpf_cnpj         IN CP4_DIM_CLIENTE.NUM_CPF_CNPJ%TYPE DEFAULT NULL,
    v_sta_ativo        IN CP4_DIM_CLIENTE.STA_ATIVO%TYPE DEFAULT NULL,
    v_dat_inicio       IN CP4_DIM_CLIENTE.DAT_INICIO%TYPE DEFAULT SYSDATE,
    v_dat_fim          IN CP4_DIM_CLIENTE.DAT_FIM%TYPE DEFAULT NULL,
    v_fl_corrente      IN CP4_DIM_CLIENTE.FL_CORRENTE%TYPE DEFAULT 'S'
) IS
    v_mensagem VARCHAR2(255);
    v_count NUMBER;
    v_existe_cliente BOOLEAN := FALSE;
    v_sk_novo NUMBER;
    
    -- Variáveis para o SELECT
    v_result_cod_cliente      CP4_DIM_CLIENTE.COD_CLIENTE%TYPE;
    v_result_nom_cliente      CP4_DIM_CLIENTE.NOM_CLIENTE%TYPE;
    v_result_razao_social     CP4_DIM_CLIENTE.DES_RAZAO_SOCIAL%TYPE;
    v_result_tip_pessoa       CP4_DIM_CLIENTE.TIP_PESSOA%TYPE;
    v_result_cpf_cnpj         CP4_DIM_CLIENTE.NUM_CPF_CNPJ%TYPE;
    v_result_sta_ativo        CP4_DIM_CLIENTE.STA_ATIVO%TYPE;
BEGIN
    -- Validações básicas
    IF v_operacao IN ('INSERT', 'UPDATE') AND v_cod_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Código do cliente é obrigatório');
    END IF;

    IF v_operacao = 'INSERT' THEN
        -- Verifica se já existe o cliente com o mesmo código
        SELECT COUNT(*) INTO v_count
        FROM CP4_DIM_CLIENTE
        WHERE COD_CLIENTE = v_cod_cliente AND FL_CORRENTE = 'S';
        
        IF v_count > 0 THEN
            -- Se já existe, marca o registro atual como não corrente
            UPDATE CP4_DIM_CLIENTE
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CLIENTE = v_cod_cliente AND FL_CORRENTE = 'S';
            
            v_existe_cliente := TRUE;
        END IF;
        
        -- Insere novo registro
        v_sk_novo := SEQ_SK_CLIENTE.NEXTVAL;
        
        INSERT INTO CP4_DIM_CLIENTE (
            SK_CLIENTE,
            COD_CLIENTE,
            NOM_CLIENTE,
            DES_RAZAO_SOCIAL,
            TIP_PESSOA,
            NUM_CPF_CNPJ,
            STA_ATIVO,
            DAT_INICIO,
            DAT_FIM,
            FL_CORRENTE
        ) VALUES (
            v_sk_novo,
            v_cod_cliente,
            v_nom_cliente,
            v_razao_social,
            v_tip_pessoa,
            v_cpf_cnpj,
            v_sta_ativo,
            v_dat_inicio,
            v_dat_fim,
            v_fl_corrente
        );
        
        IF v_existe_cliente THEN
            v_mensagem := 'Cliente atualizado com nova versão.';
        ELSE
            v_mensagem := 'Cliente inserido com sucesso.';
        END IF;
        
    ELSIF v_operacao = 'UPDATE' THEN
        -- Atualiza registro existente por SK
        IF v_sk_cliente IS NOT NULL THEN
            UPDATE CP4_DIM_CLIENTE
            SET NOM_CLIENTE = v_nom_cliente,
                DES_RAZAO_SOCIAL = v_razao_social,
                TIP_PESSOA = v_tip_pessoa,
                NUM_CPF_CNPJ = v_cpf_cnpj,
                STA_ATIVO = v_sta_ativo,
                DAT_FIM = v_dat_fim,
                FL_CORRENTE = v_fl_corrente
            WHERE SK_CLIENTE = v_sk_cliente;
            
            v_mensagem := 'Cliente atualizado com sucesso por SK.';
        ELSE
            -- Marca registro atual como não corrente
            UPDATE CP4_DIM_CLIENTE
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CLIENTE = v_cod_cliente AND FL_CORRENTE = 'S';
            
            -- Insere novo registro (versão atualizada)
            v_sk_novo := SEQ_SK_CLIENTE.NEXTVAL;
            
            INSERT INTO CP4_DIM_CLIENTE (
                SK_CLIENTE,
                COD_CLIENTE,
                NOM_CLIENTE,
                DES_RAZAO_SOCIAL,
                TIP_PESSOA,
                NUM_CPF_CNPJ,
                STA_ATIVO,
                DAT_INICIO,
                DAT_FIM,
                FL_CORRENTE
            ) VALUES (
                v_sk_novo,
                v_cod_cliente,
                v_nom_cliente,
                v_razao_social,
                v_tip_pessoa,
                v_cpf_cnpj,
                v_sta_ativo,
                SYSDATE,
                v_dat_fim,
                'S'
            );
            
            v_mensagem := 'Cliente atualizado com nova versão por código.';
        END IF;
        
    ELSIF v_operacao = 'DELETE' THEN
        -- Exclusão lógica - marca como não corrente
        IF v_sk_cliente IS NOT NULL THEN
            UPDATE CP4_DIM_CLIENTE
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE SK_CLIENTE = v_sk_cliente;
            
            v_mensagem := 'Cliente marcado como inativo por SK.';
        ELSE
            UPDATE CP4_DIM_CLIENTE
            SET FL_CORRENTE = 'N',
                DAT_FIM = SYSDATE
            WHERE COD_CLIENTE = v_cod_cliente AND FL_CORRENTE = 'S';
            
            v_mensagem := 'Cliente marcado como inativo por código.';
        END IF;
        
    ELSIF v_operacao = 'SELECT' THEN
        BEGIN
            SELECT COD_CLIENTE, NOM_CLIENTE, DES_RAZAO_SOCIAL, TIP_PESSOA, NUM_CPF_CNPJ, STA_ATIVO
            INTO v_result_cod_cliente, v_result_nom_cliente, v_result_razao_social, 
                 v_result_tip_pessoa, v_result_cpf_cnpj, v_result_sta_ativo
            FROM CP4_DIM_CLIENTE
            WHERE (v_sk_cliente IS NULL OR SK_CLIENTE = v_sk_cliente)
              AND (v_cod_cliente IS NULL OR COD_CLIENTE = v_cod_cliente)
              AND FL_CORRENTE = 'S';
              
            DBMS_OUTPUT.PUT_LINE('Código: ' || v_result_cod_cliente);
            DBMS_OUTPUT.PUT_LINE('Nome: ' || v_result_nom_cliente);
            DBMS_OUTPUT.PUT_LINE('Razão Social: ' || v_result_razao_social);
            DBMS_OUTPUT.PUT_LINE('Tipo Pessoa: ' || v_result_tip_pessoa);
            DBMS_OUTPUT.PUT_LINE('CPF/CNPJ: ' || v_result_cpf_cnpj);
            DBMS_OUTPUT.PUT_LINE('Status: ' || v_result_sta_ativo);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Cliente não encontrado.');
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
END CRUD_CP4_DIM_CLIENTE;
/

---------------------------------------------------------------------------------------------------------------------------------------



