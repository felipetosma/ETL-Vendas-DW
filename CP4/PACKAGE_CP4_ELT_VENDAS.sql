CREATE OR REPLACE PACKAGE CP4_ETL_PACKAGE IS

    C_INSERT CONSTANT VARCHAR2(10) := 'INSERT';
    C_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';
    C_DELETE CONSTANT VARCHAR2(10) := 'DELETE';
    C_SELECT CONSTANT VARCHAR2(10) := 'SELECT';
    
    C_SIM CONSTANT CHAR(1) := 'S';
    C_NAO CONSTANT CHAR(1) := 'N';
    C_ATIVO CONSTANT CHAR(1) := 'S';
    C_INATIVO CONSTANT CHAR(1) := 'N';
    
    PROCEDURE CRUD_CP4_DIM_CLIENTE(
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
    );
    
    PROCEDURE CRUD_CP4_DIM_VENDAS(
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
    );
    
    PROCEDURE CRUD_CP4_DIM_VENDEDOR(
        v_operacao         IN VARCHAR2,
        v_sk_vendedor      IN CP4_DIM_VENDEDOR.SK_VENDEDOR%TYPE DEFAULT NULL,
        v_cod_vendedor     IN CP4_DIM_VENDEDOR.COD_VENDEDOR%TYPE DEFAULT NULL,
        v_nom_vendedor     IN CP4_DIM_VENDEDOR.NOM_VENDEDOR%TYPE DEFAULT NULL,
        v_sta_ativo        IN CP4_DIM_VENDEDOR.STA_ATIVO%TYPE DEFAULT NULL,
        v_dat_inicio       IN CP4_DIM_VENDEDOR.DAT_INICIO%TYPE DEFAULT SYSDATE,
        v_dat_fim          IN CP4_DIM_VENDEDOR.DAT_FIM%TYPE DEFAULT NULL,
        v_fl_corrente      IN CP4_DIM_VENDEDOR.FL_CORRENTE%TYPE DEFAULT 'S'
    );
    
    PROCEDURE CRUD_CP4_DIM_LOCALIZACAO(
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
    );
    
    PROCEDURE CRUD_CP4_DIM_TEMPO(
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
    );
    
    PROCEDURE CRUD_CP4_FATO_VENDAS(
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
    );
    
    PROCEDURE PREENCHER_CP4_DIM_TEMPO(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    );
    
    FUNCTION OBTER_SK_CLIENTE(p_cod_cliente IN NUMBER) RETURN NUMBER;
    FUNCTION OBTER_SK_VENDAS(p_cod_produto IN NUMBER, p_cod_pedido IN NUMBER) RETURN NUMBER;
    FUNCTION OBTER_SK_VENDEDOR(p_cod_vendedor IN NUMBER) RETURN NUMBER;
    FUNCTION OBTER_SK_TEMPO(p_data IN DATE) RETURN NUMBER;
    FUNCTION OBTER_SK_LOCALIZACAO(p_cod_cidade IN NUMBER) RETURN NUMBER;
    
    PROCEDURE EXECUTAR_ETL_COMPLETO(
        p_limpar_modelo IN BOOLEAN DEFAULT TRUE,
        p_data_inicio IN DATE DEFAULT NULL,
        p_data_fim IN DATE DEFAULT NULL
    );
    
    PROCEDURE GERAR_RELATORIO_VENDAS_PERIODO(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    );
    
    PROCEDURE GERAR_RELATORIO_DESEMPENHO_VENDEDORES(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    );
    
END CP4_ETL_PACKAGE;
/


--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY CP4_ETL_PACKAGE IS

    PROCEDURE CRUD_CP4_DIM_CLIENTE(
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
    BEGIN

        CRUD_CP4_DIM_CLIENTE(
            v_operacao,
            v_sk_cliente,
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
    END CRUD_CP4_DIM_CLIENTE;

    PROCEDURE CRUD_CP4_DIM_VENDAS(
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
    BEGIN

        CRUD_CP4_DIM_VENDAS(
            v_operacao,
            v_sk_vendas,
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
    END CRUD_CP4_DIM_VENDAS;


    PROCEDURE CRUD_CP4_DIM_VENDEDOR(
        v_operacao         IN VARCHAR2,
        v_sk_vendedor      IN CP4_DIM_VENDEDOR.SK_VENDEDOR%TYPE DEFAULT NULL,
        v_cod_vendedor     IN CP4_DIM_VENDEDOR.COD_VENDEDOR%TYPE DEFAULT NULL,
        v_nom_vendedor     IN CP4_DIM_VENDEDOR.NOM_VENDEDOR%TYPE DEFAULT NULL,
        v_sta_ativo        IN CP4_DIM_VENDEDOR.STA_ATIVO%TYPE DEFAULT NULL,
        v_dat_inicio       IN CP4_DIM_VENDEDOR.DAT_INICIO%TYPE DEFAULT SYSDATE,
        v_dat_fim          IN CP4_DIM_VENDEDOR.DAT_FIM%TYPE DEFAULT NULL,
        v_fl_corrente      IN CP4_DIM_VENDEDOR.FL_CORRENTE%TYPE DEFAULT 'S'
    ) IS
    BEGIN

        CRUD_CP4_DIM_VENDEDOR(
            v_operacao,
            v_sk_vendedor,
            v_cod_vendedor,
            v_nom_vendedor,
            v_sta_ativo,
            v_dat_inicio,
            v_dat_fim,
            v_fl_corrente
        );
    END CRUD_CP4_DIM_VENDEDOR;


    PROCEDURE CRUD_CP4_DIM_LOCALIZACAO(
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
    BEGIN

        CRUD_CP4_DIM_LOCALIZACAO(
            v_operacao,
            v_sk_localizacao,
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
    END CRUD_CP4_DIM_LOCALIZACAO;


    PROCEDURE CRUD_CP4_DIM_TEMPO(
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
    BEGIN

        CRUD_CP4_DIM_TEMPO(
            v_operacao,
            v_sk_tempo,
            v_data,
            v_dia,
            v_mes,
            v_ano,
            v_trimestre,
            v_semestre,
            v_nom_mes,
            v_nom_mes_abrev,
            v_nom_trimestre,
            v_nom_semestre,
            v_fl_feriado,
            v_fl_fim_semana,
            v_num_dia_semana
        );
    END CRUD_CP4_DIM_TEMPO;

    PROCEDURE CRUD_CP4_FATO_VENDAS(
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
    BEGIN

        CRUD_CP4_FATO_VENDAS(
            v_operacao,
            v_sk_venda,
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
            v_val_total
        );
    END CRUD_CP4_FATO_VENDAS;


    PROCEDURE PREENCHER_CP4_DIM_TEMPO(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    ) IS
        v_data_atual DATE;
    BEGIN

        IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Datas de início e fim são obrigatórias');
        END IF;
        
        IF p_data_inicio > p_data_fim THEN
            RAISE_APPLICATION_ERROR(-20002, 'Data de início não pode ser posterior à data fim');
        END IF;
        

        v_data_atual := p_data_inicio;
        
        WHILE v_data_atual <= p_data_fim LOOP
            BEGIN

                CRUD_CP4_DIM_TEMPO(
                    v_operacao => 'INSERT',
                    v_data => v_data_atual
                );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            
            v_data_atual := v_data_atual + 1;
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('CP4_DIMensão tempo preenchida de ' || 
                             TO_CHAR(p_data_inicio, 'DD/MM/YYYY') || ' a ' || 
                             TO_CHAR(p_data_fim, 'DD/MM/YYYY'));
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erro ao preencher CP4_DIMensão tempo: ' || SQLERRM);
    END PREENCHER_CP4_DIM_TEMPO;
    
    
    FUNCTION OBTER_SK_CLIENTE(p_cod_cliente IN NUMBER) RETURN NUMBER IS
        v_sk_cliente CP4_DIM_CLIENTE.SK_CLIENTE%TYPE;
    BEGIN
        SELECT SK_CLIENTE INTO v_sk_cliente
        FROM CP4_DIM_CLIENTE
        WHERE COD_CLIENTE = p_cod_cliente AND FL_CORRENTE = 'S';
        
        RETURN v_sk_cliente;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END OBTER_SK_CLIENTE;
    
    FUNCTION OBTER_SK_VENDAS(p_cod_produto IN NUMBER, p_cod_pedido IN NUMBER) RETURN NUMBER IS
        v_sk_vendas CP4_DIM_VENDAS.SK_VENDAS%TYPE;
    BEGIN
        SELECT SK_VENDAS INTO v_sk_vendas
        FROM CP4_DIM_VENDAS
        WHERE COD_PRODUTO = p_cod_produto 
          AND COD_PEDIDO = p_cod_pedido 
          AND FL_CORRENTE = 'S';
        
        RETURN v_sk_vendas;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END OBTER_SK_VENDAS;
    
    FUNCTION OBTER_SK_VENDEDOR(p_cod_vendedor IN NUMBER) RETURN NUMBER IS
        v_sk_vendedor CP4_DIM_VENDEDOR.SK_VENDEDOR%TYPE;
    BEGIN
        SELECT SK_VENDEDOR INTO v_sk_vendedor
        FROM CP4_DIM_VENDEDOR
        WHERE COD_VENDEDOR = p_cod_vendedor AND FL_CORRENTE = 'S';
        
        RETURN v_sk_vendedor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END OBTER_SK_VENDEDOR;
    
    FUNCTION OBTER_SK_TEMPO(p_data IN DATE) RETURN NUMBER IS
        v_sk_tempo CP4_DIM_TEMPO.SK_TEMPO%TYPE;
    BEGIN
        SELECT SK_TEMPO INTO v_sk_tempo
        FROM CP4_DIM_TEMPO
        WHERE DATA = p_data;
        
        RETURN v_sk_tempo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END OBTER_SK_TEMPO;
    
    FUNCTION OBTER_SK_LOCALIZACAO(p_cod_cidade IN NUMBER) RETURN NUMBER IS
        v_sk_localizacao CP4_DIM_LOCALIZACAO.SK_LOCALIZACAO%TYPE;
    BEGIN
        SELECT SK_LOCALIZACAO INTO v_sk_localizacao
        FROM CP4_DIM_LOCALIZACAO
        WHERE COD_CIDADE = p_cod_cidade AND FL_CORRENTE = 'S';
        
        RETURN v_sk_localizacao;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END OBTER_SK_LOCALIZACAO;

    PROCEDURE EXECUTAR_ETL_COMPLETO(
        p_limpar_modelo IN BOOLEAN DEFAULT TRUE,
        p_data_inicio IN DATE DEFAULT NULL,
        p_data_fim IN DATE DEFAULT NULL
    ) IS
        v_data_inicio DATE;
        v_data_fim DATE;
    BEGIN

        v_data_inicio := NVL(p_data_inicio, TRUNC(ADD_MONTHS(SYSDATE, -36), 'YYYY')); -- 3 anos antes
        v_data_fim := NVL(p_data_fim, ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), 12)); -- Até fim do próximo ano
        
        IF p_limpar_modelo THEN
            BEGIN
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_FATO_VENDAS';
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_DIM_CLIENTE';
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_DIM_VENDAS';
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_DIM_VENDEDOR';
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_DIM_TEMPO';
                EXECUTE IMMEDIATE 'TRUNCATE TABLE CP4_DIM_LOCALIZACAO';
                
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_CLIENTE RESTART';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_VENDAS RESTART';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_VENDEDOR RESTART';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_TEMPO RESTART';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_LOCALIZACAO RESTART';
                EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_SK_VENDA RESTART';
                
                DBMS_OUTPUT.PUT_LINE('Modelo estrela limpo com sucesso');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erro ao limpar modelo estrela: ' || SQLERRM);
                    RAISE;
            END;
        END IF;
        
        PREENCHER_CP4_DIM_TEMPO(v_data_inicio, v_data_fim);

        DBMS_OUTPUT.PUT_LINE('ETL completo executado com sucesso');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao executar ETL completo: ' || SQLERRM);
            ROLLBACK;
    END EXECUTAR_ETL_COMPLETO;

    PROCEDURE GERAR_RELATORIO_VENDAS_PERIODO(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    ) IS
        CURSOR c_vendas IS
            SELECT 
                t.ANO,
                t.NOM_MES,
                SUM(f.VAL_TOTAL_ITEM) AS TOTAL_VENDAS,
                COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
                SUM(f.QTD_ITEM) AS QTD_ITENS
            FROM CP4_FATO_VENDAS f
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
            WHERE t.DATA BETWEEN p_data_inicio AND p_data_fim
            GROUP BY t.ANO, t.MES, t.NOM_MES
            ORDER BY t.ANO, t.MES;
        
        v_ano CP4_DIM_TEMPO.ANO%TYPE;
        v_mes CP4_DIM_TEMPO.NOM_MES%TYPE;
        v_total NUMBER;
        v_qtd_pedidos NUMBER;
        v_qtd_itens NUMBER;
    BEGIN
        IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Datas de início e fim são obrigatórias');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('======== RELATÓRIO DE VENDAS POR PERÍODO ========');
        DBMS_OUTPUT.PUT_LINE('Período: ' || TO_CHAR(p_data_inicio, 'DD/MM/YYYY') || 
                           ' a ' || TO_CHAR(p_data_fim, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('================================================');
        DBMS_OUTPUT.PUT_LINE('ANO   | MÊS        | TOTAL VENDAS | QTD PEDIDOS | QTD ITENS');
        DBMS_OUTPUT.PUT_LINE('------+------------+--------------+-------------+----------');
        
        OPEN c_vendas;
        LOOP
            FETCH c_vendas INTO v_ano, v_mes, v_total, v_qtd_pedidos, v_qtd_itens;
            EXIT WHEN c_vendas%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_ano, 6) || '| ' || 
                RPAD(v_mes, 12) || '| ' || 
                RPAD(TO_CHAR(v_total, '999,999,999.99'), 14) || '| ' || 
                RPAD(v_qtd_pedidos, 13) || '| ' || 
                v_qtd_itens
            );
        END LOOP;
        CLOSE c_vendas;
        
        DBMS_OUTPUT.PUT_LINE('================================================');
    EXCEPTION
        WHEN OTHERS THEN
            IF c_vendas%ISOPEN THEN
                CLOSE c_vendas;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório: ' || SQLERRM);
    END GERAR_RELATORIO_VENDAS_PERIODO;
    
    PROCEDURE GERAR_RELATORIO_DESEMPENHO_VENDEDORES(
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    ) IS
        CURSOR c_vendedores IS
            SELECT 
                v.COD_VENDEDOR,
                v.NOM_VENDEDOR,
                COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
                SUM(f.VAL_TOTAL_ITEM) AS TOTAL_VENDAS,
                COUNT(DISTINCT f.SK_CLIENTE) AS QTD_CLIENTES,
                ROUND(SUM(f.VAL_TOTAL_ITEM) / COUNT(DISTINCT f.COD_PEDIDO), 2) AS TICKET_MEDIO
            FROM CP4_FATO_VENDAS f
            JOIN CP4_DIM_VENDEDOR v ON f.SK_VENDEDOR = v.SK_VENDEDOR
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
            WHERE t.DATA BETWEEN p_data_inicio AND p_data_fim
              AND v.FL_CORRENTE = 'S'
            GROUP BY v.COD_VENDEDOR, v.NOM_VENDEDOR
            ORDER BY TOTAL_VENDAS DESC;
        
        v_cod_vendedor CP4_DIM_VENDEDOR.COD_VENDEDOR%TYPE;
        v_nom_vendedor CP4_DIM_VENDEDOR.NOM_VENDEDOR%TYPE;
        v_qtd_pedidos NUMBER;
        v_total_vendas NUMBER;
        v_qtd_clientes NUMBER;
        v_ticket_medio NUMBER;
    BEGIN

        IF p_data_inicio IS NULL OR p_data_fim IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Datas de início e fim são obrigatórias');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('======== RELATÓRIO DE DESEMPENHO DE VENDEDORES ========');
        DBMS_OUTPUT.PUT_LINE('Período: ' || TO_CHAR(p_data_inicio, 'DD/MM/YYYY') || 
                           ' a ' || TO_CHAR(p_data_fim, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('================================================================');
        DBMS_OUTPUT.PUT_LINE('CÓD  | NOME          | PEDIDOS | TOTAL VENDAS    | CLIENTES | TICKET MÉDIO');
        DBMS_OUTPUT.PUT_LINE('-----+---------------+---------+-----------------+----------+-------------');
        
        OPEN c_vendedores;
        LOOP
            FETCH c_vendedores INTO v_cod_vendedor, v_nom_vendedor, v_qtd_pedidos, v_total_vendas, v_qtd_clientes, v_ticket_medio;
            EXIT WHEN c_vendedores%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_cod_vendedor, 5) || '| ' || 
                RPAD(v_nom_vendedor, 15) || '| ' || 
                RPAD(v_qtd_pedidos, 9) || '| ' || 
                RPAD(TO_CHAR(v_total_vendas, '999,999,999.99'), 17) || '| ' || 
                RPAD(v_qtd_clientes, 10) || '| ' || 
                TO_CHAR(v_ticket_medio, '999,999.99')
            );
        END LOOP;
        CLOSE c_vendedores;
        
        DBMS_OUTPUT.PUT_LINE('================================================================');
    EXCEPTION
        WHEN OTHERS THEN
            IF c_vendedores%ISOPEN THEN
                CLOSE c_vendedores;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório de desempenho de vendedores: ' || SQLERRM);
    END GERAR_RELATORIO_DESEMPENHO_VENDEDORES;
    
END CP4_ETL_PACKAGE;
/