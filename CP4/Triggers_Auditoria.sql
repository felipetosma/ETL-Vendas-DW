CREATE TABLE CP4_AUDITORIA (
    ID_AUDITORIA NUMBER PRIMARY KEY,
    NOME_TABELA VARCHAR2(30) NOT NULL,
    TIPO_OPERACAO VARCHAR2(10) NOT NULL,
    SK_REGISTRO NUMBER,       
    CHAVE_NATURAL VARCHAR2(100),
    DATA_OPERACAO TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    USUARIO VARCHAR2(30) DEFAULT USER NOT NULL,
    VALORES_ANTIGOS CLOB,    
    VALORES_NOVOS CLOB,     
    DETALHES VARCHAR2(4000) 
);


CREATE SEQUENCE CP4_SEQ_AUDITORIA START WITH 1 INCREMENT BY 1;


COMMENT ON TABLE CP4_AUDITORIA IS 'Tabela de auditoria para registrar operações nas dimensões e fatos do Data Warehouse';
COMMENT ON COLUMN CP4_AUDITORIA.ID_AUDITORIA IS 'ID único da operação de auditoria';
COMMENT ON COLUMN CP4_AUDITORIA.NOME_TABELA IS 'Nome da tabela que sofreu a operação';
COMMENT ON COLUMN CP4_AUDITORIA.TIPO_OPERACAO IS 'Tipo de operação (INSERT, UPDATE, DELETE)';
COMMENT ON COLUMN CP4_AUDITORIA.SK_REGISTRO IS 'Chave surrogate do registro afetado';
COMMENT ON COLUMN CP4_AUDITORIA.CHAVE_NATURAL IS 'Chave natural que identifica o registro';
COMMENT ON COLUMN CP4_AUDITORIA.DATA_OPERACAO IS 'Data e hora da operação';
COMMENT ON COLUMN CP4_AUDITORIA.USUARIO IS 'Usuário que realizou a operação';
COMMENT ON COLUMN CP4_AUDITORIA.VALORES_ANTIGOS IS 'Valores dos campos antes da alteração (formato JSON)';
COMMENT ON COLUMN CP4_AUDITORIA.VALORES_NOVOS IS 'Valores dos campos após a alteração (formato JSON)';
COMMENT ON COLUMN CP4_AUDITORIA.DETALHES IS 'Detalhes adicionais sobre a operação';


CREATE INDEX IDX_AUDITORIA_TABELA ON CP4_AUDITORIA(NOME_TABELA);
CREATE INDEX IDX_AUDITORIA_OPERACAO ON CP4_AUDITORIA(TIPO_OPERACAO);
CREATE INDEX IDX_AUDITORIA_DATA ON CP4_AUDITORIA(DATA_OPERACAO);
CREATE INDEX IDX_AUDITORIA_USUARIO ON CP4_AUDITORIA(USUARIO);
CREATE INDEX IDX_AUDITORIA_SK ON CP4_AUDITORIA(SK_REGISTRO);


CREATE OR REPLACE FUNCTION CP4_ROW_TO_JSON(
    p_table_name IN VARCHAR2, 
    p_rowid IN ROWID
) RETURN CLOB IS
    v_json CLOB;
    v_colunas_json CLOB := '{';
    v_count NUMBER := 0;
    v_columns SYS_REFCURSOR;
    v_column_name VARCHAR2(30);
    v_column_value VARCHAR2(4000);
    v_sql VARCHAR2(4000);
BEGIN
    FOR col_rec IN (
        SELECT column_name 
        FROM user_tab_columns 
        WHERE table_name = UPPER(p_table_name)
        ORDER BY column_id
    ) LOOP
        v_sql := 'SELECT ' || col_rec.column_name || ' FROM ' || p_table_name || 
                 ' WHERE ROWID = :1';
        
        BEGIN
            EXECUTE IMMEDIATE v_sql INTO v_column_value USING p_rowid;
            
            IF v_count > 0 THEN
                v_colunas_json := v_colunas_json || ', ';
            END IF;
            
            v_colunas_json := v_colunas_json || '"' || col_rec.column_name || '": ';
            
            IF v_column_value IS NULL THEN
                v_colunas_json := v_colunas_json || 'null';
            ELSIF col_rec.column_name LIKE '%DAT%' THEN
                v_colunas_json := v_colunas_json || '"' || v_column_value || '"';
            ELSE
            
                BEGIN
                    DECLARE
                        v_num NUMBER := TO_NUMBER(v_column_value);
                    BEGIN
                        v_colunas_json := v_colunas_json || v_column_value;
                    END;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_colunas_json := v_colunas_json || '"' || REPLACE(v_column_value, '"', '\"') || '"';
                END;
            END IF;
            
            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                v_colunas_json := v_colunas_json || '"' || col_rec.column_name || '": "ERRO"';
                IF v_count > 0 THEN
                    v_colunas_json := v_colunas_json || ', ';
                END IF;
                v_count := v_count + 1;
        END;
    END LOOP;
    
    v_colunas_json := v_colunas_json || '}';
    v_json := v_colunas_json;
    
    RETURN v_json;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '{"error": "' || SQLERRM || '"}';
END CP4_ROW_TO_JSON;
/

-- Versão simplificada da Trigger para DIM_VENDAS
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_DIM_VENDAS
AFTER INSERT OR UPDATE OR DELETE ON CP4_DIM_VENDAS
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_VENDAS;
        v_chave_natural := TO_CHAR(:NEW.COD_PRODUTO) || '|' || TO_CHAR(:NEW.COD_PEDIDO);
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_VENDAS;
        v_chave_natural := TO_CHAR(:OLD.COD_PRODUTO) || '|' || TO_CHAR(:OLD.COD_PEDIDO);
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_VENDAS;
        v_chave_natural := TO_CHAR(:OLD.COD_PRODUTO) || '|' || TO_CHAR(:OLD.COD_PEDIDO);
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_DIM_VENDAS', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na dimensão Vendas');
EXCEPTION
    WHEN OTHERS THEN
        -- Simplificando também o tratamento de erro
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

-- Versão simplificada da Trigger para DIM_CLIENTE
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_DIM_CLIENTE
AFTER INSERT OR UPDATE OR DELETE ON CP4_DIM_CLIENTE
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_CLIENTE;
        v_chave_natural := TO_CHAR(:NEW.COD_CLIENTE);
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_CLIENTE;
        v_chave_natural := TO_CHAR(:OLD.COD_CLIENTE);
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_CLIENTE;
        v_chave_natural := TO_CHAR(:OLD.COD_CLIENTE);
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_DIM_CLIENTE', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na dimensão Cliente');
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

-- Versão simplificada da Trigger para DIM_VENDEDOR
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_DIM_VENDEDOR
AFTER INSERT OR UPDATE OR DELETE ON CP4_DIM_VENDEDOR
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_VENDEDOR;
        v_chave_natural := TO_CHAR(:NEW.COD_VENDEDOR);
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_VENDEDOR;
        v_chave_natural := TO_CHAR(:OLD.COD_VENDEDOR);
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_VENDEDOR;
        v_chave_natural := TO_CHAR(:OLD.COD_VENDEDOR);
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_DIM_VENDEDOR', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na dimensão Vendedor');
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

-- Versão simplificada da Trigger para DIM_LOCALIZACAO
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_DIM_LOCALIZACAO
AFTER INSERT OR UPDATE OR DELETE ON CP4_DIM_LOCALIZACAO
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_LOCALIZACAO;
        v_chave_natural := TO_CHAR(:NEW.COD_CIDADE);
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_LOCALIZACAO;
        v_chave_natural := TO_CHAR(:OLD.COD_CIDADE);
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_LOCALIZACAO;
        v_chave_natural := TO_CHAR(:OLD.COD_CIDADE);
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_DIM_LOCALIZACAO', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na dimensão Localização');
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

-- Versão simplificada da Trigger para DIM_TEMPO
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_DIM_TEMPO
AFTER INSERT OR UPDATE OR DELETE ON CP4_DIM_TEMPO
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_TEMPO;
        v_chave_natural := TO_CHAR(:NEW.DATA, 'YYYY-MM-DD');
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_TEMPO;
        v_chave_natural := TO_CHAR(:OLD.DATA, 'YYYY-MM-DD');
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_TEMPO;
        v_chave_natural := TO_CHAR(:OLD.DATA, 'YYYY-MM-DD');
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_DIM_TEMPO', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na dimensão Tempo');
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

-- Versão simplificada da Trigger para FATO_VENDAS
CREATE OR REPLACE TRIGGER TRG_CP4_AUD_FATO_VENDAS
AFTER INSERT OR UPDATE OR DELETE ON CP4_FATO_VENDAS
FOR EACH ROW
DECLARE
    v_chave_natural VARCHAR2(100);
    v_tipo_operacao VARCHAR2(10);
    v_sk_registro NUMBER;
BEGIN
    -- Determinar o tipo de operação
    IF INSERTING THEN
        v_tipo_operacao := 'INSERT';
        v_sk_registro := :NEW.SK_VENDA;
        v_chave_natural := TO_CHAR(:NEW.COD_PEDIDO) || '|' || TO_CHAR(:NEW.COD_ITEM_PEDIDO);
    ELSIF UPDATING THEN
        v_tipo_operacao := 'UPDATE';
        v_sk_registro := :OLD.SK_VENDA;
        v_chave_natural := TO_CHAR(:OLD.COD_PEDIDO) || '|' || TO_CHAR(:OLD.COD_ITEM_PEDIDO);
    ELSIF DELETING THEN
        v_tipo_operacao := 'DELETE';
        v_sk_registro := :OLD.SK_VENDA;
        v_chave_natural := TO_CHAR(:OLD.COD_PEDIDO) || '|' || TO_CHAR(:OLD.COD_ITEM_PEDIDO);
    END IF;
    
    -- Registra a operação na tabela de auditoria de forma simplificada
    INSERT INTO CP4_AUDITORIA 
    (ID_AUDITORIA, NOME_TABELA, TIPO_OPERACAO, SK_REGISTRO, CHAVE_NATURAL, DETALHES)
    VALUES 
    (CP4_SEQ_AUDITORIA.NEXTVAL, 'CP4_FATO_VENDAS', v_tipo_operacao, v_sk_registro, v_chave_natural, 
     'Auditoria simplificada na tabela Fato Vendas');
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Apenas ignora o erro para não interferir na operação principal
END;
/

