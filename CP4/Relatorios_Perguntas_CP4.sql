-- 1. Procedure para gerar relatório de volume de vendas segmentado
CREATE OR REPLACE PROCEDURE CP4_RELATORIO_VOLUME_VENDAS(
    p_ano           IN NUMBER DEFAULT NULL,
    p_mes           IN NUMBER DEFAULT NULL,
    p_estado        IN VARCHAR2 DEFAULT NULL,
    p_cod_vendedor  IN NUMBER DEFAULT NULL,
    p_cod_cliente   IN NUMBER DEFAULT NULL
) IS
    -- Cursor para relatório por estado e ano/mês
    CURSOR c_estado_periodo IS
        SELECT 
            l.COD_ESTADO,
            l.NOM_ESTADO,
            t.ANO,
            t.MES,
            t.NOM_MES,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            SUM(f.QTD_ITEM) AS QTD_ITENS,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            COUNT(DISTINCT f.SK_CLIENTE) AS QTD_CLIENTES
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_LOCALIZACAO l ON f.SK_LOCALIZACAO = l.SK_LOCALIZACAO
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            l.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
            AND (p_mes IS NULL OR t.MES = p_mes)
            AND (p_estado IS NULL OR l.COD_ESTADO = p_estado)
        GROUP BY 
            l.COD_ESTADO, l.NOM_ESTADO, t.ANO, t.MES, t.NOM_MES
        ORDER BY 
            l.NOM_ESTADO, t.ANO, t.MES;
            
    -- Cursor para relatório por vendedor
    CURSOR c_vendedor IS
        SELECT 
            v.COD_VENDEDOR,
            v.NOM_VENDEDOR,
            t.ANO,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            COUNT(DISTINCT f.SK_CLIENTE) AS QTD_CLIENTES,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / COUNT(DISTINCT f.COD_PEDIDO), 2) AS TICKET_MEDIO
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_VENDEDOR v ON f.SK_VENDEDOR = v.SK_VENDEDOR
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            v.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
            AND (p_mes IS NULL OR t.MES = p_mes)
            AND (p_cod_vendedor IS NULL OR v.COD_VENDEDOR = p_cod_vendedor)
        GROUP BY 
            v.COD_VENDEDOR, v.NOM_VENDEDOR, t.ANO
        ORDER BY 
            t.ANO, VALOR_TOTAL DESC;
            
    -- Cursor para relatório por cliente
    CURSOR c_cliente IS
        SELECT 
            c.COD_CLIENTE,
            c.NOM_CLIENTE,
            c.TIP_PESSOA,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            MIN(t.DATA) AS PRIMEIRA_COMPRA,
            MAX(t.DATA) AS ULTIMA_COMPRA,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / COUNT(DISTINCT f.COD_PEDIDO), 2) AS TICKET_MEDIO
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_CLIENTE c ON f.SK_CLIENTE = c.SK_CLIENTE
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            c.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
            AND (p_mes IS NULL OR t.MES = p_mes)
            AND (p_cod_cliente IS NULL OR c.COD_CLIENTE = p_cod_cliente)
        GROUP BY 
            c.COD_CLIENTE, c.NOM_CLIENTE, c.TIP_PESSOA
        ORDER BY 
            VALOR_TOTAL DESC;
            
    -- Variáveis para detalhes do relatório
    v_titulo VARCHAR2(100);
    v_filtros VARCHAR2(200) := 'Filtros aplicados: ';
    v_tem_filtro BOOLEAN := FALSE;
BEGIN
    -- Montar informações do título e filtros
    v_titulo := 'RELATÓRIO DE VOLUME DE VENDAS SEGMENTADO';
    
    IF p_ano IS NOT NULL THEN
        v_filtros := v_filtros || 'Ano=' || p_ano || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_mes IS NOT NULL THEN
        v_filtros := v_filtros || 'Mês=' || p_mes || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_estado IS NOT NULL THEN
        v_filtros := v_filtros || 'Estado=' || p_estado || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_cod_vendedor IS NOT NULL THEN
        v_filtros := v_filtros || 'Vendedor=' || p_cod_vendedor || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_cod_cliente IS NOT NULL THEN
        v_filtros := v_filtros || 'Cliente=' || p_cod_cliente || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF NOT v_tem_filtro THEN
        v_filtros := v_filtros || 'Nenhum filtro aplicado.';
    END IF;
    
    -- Imprimir cabeçalho
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_titulo);
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_filtros);
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    
    -- Relatório por Estado e Período
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('1. VENDAS POR ESTADO E PERÍODO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('ESTADO     | ANO  | MÊS  | PERÍODO      | PEDIDOS | ITENS   | VALOR TOTAL   | CLIENTES');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');
    
    FOR r_ep IN c_estado_periodo LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_ep.COD_ESTADO || '-' || SUBSTR(r_ep.NOM_ESTADO, 1, 8), 12) || '| ' ||
            RPAD(r_ep.ANO, 6) || '| ' ||
            RPAD(r_ep.MES, 6) || '| ' ||
            RPAD(r_ep.NOM_MES, 14) || '| ' ||
            RPAD(r_ep.QTD_PEDIDOS, 9) || '| ' ||
            RPAD(r_ep.QTD_ITENS, 9) || '| ' ||
            RPAD(TO_CHAR(r_ep.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
            r_ep.QTD_CLIENTES
        );
    END LOOP;
    
    -- Relatório por Vendedor
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. DESEMPENHO POR VENDEDOR');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | VENDEDOR       | ANO  | VALOR TOTAL   | PEDIDOS | CLIENTES | TICKET MÉDIO');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------');
    
    FOR r_v IN c_vendedor LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_v.COD_VENDEDOR, 7) || '| ' ||
            RPAD(SUBSTR(r_v.NOM_VENDEDOR, 1, 15), 16) || '| ' ||
            RPAD(r_v.ANO, 6) || '| ' ||
            RPAD(TO_CHAR(r_v.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
            RPAD(r_v.QTD_PEDIDOS, 9) || '| ' ||
            RPAD(r_v.QTD_CLIENTES, 10) || '| ' ||
            TO_CHAR(r_v.TICKET_MEDIO, '999,990.99')
        );
    END LOOP;
    
    -- Relatório por Cliente (Top 10)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. TOP CLIENTES POR VOLUME DE COMPRAS');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | NOME CLIENTE     | TIPO | PEDIDOS | VALOR TOTAL   | PRIMEIRA COMPRA | ÚLTIMA COMPRA  | TICKET MÉDIO');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------------------------------------------');
    
    DECLARE
        i NUMBER := 0;
    BEGIN
        FOR r_c IN c_cliente LOOP
            i := i + 1;
            EXIT WHEN i > 10 AND p_cod_cliente IS NULL; -- Limite de 10 registros se não houver filtro específico
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r_c.COD_CLIENTE, 7) || '| ' ||
                RPAD(SUBSTR(r_c.NOM_CLIENTE, 1, 17), 18) || '| ' ||
                RPAD(r_c.TIP_PESSOA, 6) || '| ' ||
                RPAD(r_c.QTD_PEDIDOS, 9) || '| ' ||
                RPAD(TO_CHAR(r_c.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
                RPAD(TO_CHAR(r_c.PRIMEIRA_COMPRA, 'DD/MM/YYYY'), 16) || '| ' ||
                RPAD(TO_CHAR(r_c.ULTIMA_COMPRA, 'DD/MM/YYYY'), 16) || '| ' ||
                TO_CHAR(r_c.TICKET_MEDIO, '999,990.99')
            );
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE('FIM DO RELATÓRIO');
    DBMS_OUTPUT.PUT_LINE('Data de geração: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=========================================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório de volume de vendas: ' || SQLERRM);
END CP4_RELATORIO_VOLUME_VENDAS;
/

-- 2. Procedure para gerar relatório de produtos mais rentáveis
CREATE OR REPLACE PROCEDURE CP4_RELATORIO_PRODUTOS_RENTAVEIS(
    p_ano           IN NUMBER DEFAULT NULL,
    p_top_n         IN NUMBER DEFAULT 20,
    p_cod_produto   IN NUMBER DEFAULT NULL
) IS
    -- Cursor para relatório de rentabilidade de produtos
    CURSOR c_produtos IS
        SELECT 
            pv.COD_PRODUTO,
            pv.NOM_PRODUTO,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            SUM(f.QTD_ITEM) AS QTD_ITENS,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            SUM(f.VAL_UNITARIO_ITEM * f.QTD_ITEM) AS VALOR_BRUTO,
            SUM(f.VAL_DESCONTO_ITEM) AS VALOR_DESCONTO,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / SUM(f.QTD_ITEM), 2) AS PRECO_MEDIO,
            COUNT(DISTINCT f.SK_CLIENTE) AS QTD_CLIENTES
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_VENDAS pv ON f.SK_VENDAS = pv.SK_VENDAS
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            pv.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
            AND (p_cod_produto IS NULL OR pv.COD_PRODUTO = p_cod_produto)
        GROUP BY 
            pv.COD_PRODUTO, pv.NOM_PRODUTO
        ORDER BY 
            VALOR_TOTAL DESC;
            
    -- Cursor para tendência anual de produtos (top N)
    CURSOR c_tendencia_produtos(cp_produto NUMBER) IS
        SELECT 
            t.ANO,
            SUM(f.QTD_ITEM) AS QTD_ITENS,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / SUM(f.QTD_ITEM), 2) AS PRECO_MEDIO
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_VENDAS pv ON f.SK_VENDAS = pv.SK_VENDAS
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            pv.FL_CORRENTE = 'S'
            AND pv.COD_PRODUTO = cp_produto
        GROUP BY 
            t.ANO
        ORDER BY 
            t.ANO;
            
    -- Variáveis para detalhes do relatório
    v_titulo VARCHAR2(100);
    v_filtros VARCHAR2(200) := 'Filtros aplicados: ';
    v_tem_filtro BOOLEAN := FALSE;
    v_total_geral NUMBER := 0;
BEGIN
    -- Montar informações do título e filtros
    v_titulo := 'RELATÓRIO DE PRODUTOS MAIS RENTÁVEIS';
    
    IF p_ano IS NOT NULL THEN
        v_filtros := v_filtros || 'Ano=' || p_ano || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_cod_produto IS NOT NULL THEN
        v_filtros := v_filtros || 'Produto=' || p_cod_produto || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF NOT v_tem_filtro THEN
        v_filtros := v_filtros || 'Nenhum filtro aplicado.';
    END IF;
    
    -- Imprimir cabeçalho
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_titulo);
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_filtros);
    DBMS_OUTPUT.PUT_LINE('Top ' || p_top_n || ' produtos apresentados (se disponíveis)');
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    
    -- Calcular total geral
    SELECT SUM(f.VAL_TOTAL_ITEM) INTO v_total_geral
    FROM CP4_FATO_VENDAS f
    JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
    WHERE (p_ano IS NULL OR t.ANO = p_ano);
    
    -- Relatório de produtos rentáveis
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('1. PRODUTOS MAIS RENTÁVEIS');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | PRODUTO         | PEDIDOS | ITENS   | VALOR TOTAL   | % TOTAL | PREÇO MÉDIO | CLIENTES');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------');
    
    DECLARE
        i NUMBER := 0;
        v_porcentagem NUMBER;
    BEGIN
        FOR r_p IN c_produtos LOOP
            i := i + 1;
            EXIT WHEN i > p_top_n AND p_cod_produto IS NULL; -- Limite pelo parâmetro p_top_n
            
            -- Calcular porcentagem do faturamento total
            v_porcentagem := ROUND((r_p.VALOR_TOTAL / v_total_geral) * 100, 2);
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r_p.COD_PRODUTO, 7) || '| ' ||
                RPAD(SUBSTR(r_p.NOM_PRODUTO, 1, 16), 17) || '| ' ||
                RPAD(r_p.QTD_PEDIDOS, 9) || '| ' ||
                RPAD(r_p.QTD_ITENS, 9) || '| ' ||
                RPAD(TO_CHAR(r_p.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
                RPAD(TO_CHAR(v_porcentagem, '990.99') || '%', 9) || '| ' ||
                RPAD(TO_CHAR(r_p.PRECO_MEDIO, '999,990.99'), 12) || '| ' ||
                r_p.QTD_CLIENTES
            );
            
            -- Mostrar tendência anual para os top 5 produtos ou produto específico
            IF (i <= 5 OR p_cod_produto IS NOT NULL) THEN
                DBMS_OUTPUT.PUT_LINE('  TENDÊNCIA ANUAL:');
                DBMS_OUTPUT.PUT_LINE('  -------------------------------------------------');
                DBMS_OUTPUT.PUT_LINE('  ANO  | QTDE VENDIDA | VALOR TOTAL   | PREÇO MÉDIO');
                DBMS_OUTPUT.PUT_LINE('  -------------------------------------------------');
                
                FOR r_t IN c_tendencia_produtos(r_p.COD_PRODUTO) LOOP
                    DBMS_OUTPUT.PUT_LINE(
                        '  ' || RPAD(r_t.ANO, 6) || '| ' ||
                        RPAD(r_t.QTD_ITENS, 14) || '| ' ||
                        RPAD(TO_CHAR(r_t.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
                        TO_CHAR(r_t.PRECO_MEDIO, '999,990.99')
                    );
                END LOOP;
                
                DBMS_OUTPUT.PUT_LINE('');
            END IF;
        END LOOP;
    END;
    
    -- Análise de margens e descontos
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. ANÁLISE DE DESCONTOS POR PRODUTO');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | PRODUTO         | VALOR BRUTO    | DESCONTO      | % DESC | VALOR LÍQUIDO  | MARGEM');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------');
    
    DECLARE
        i NUMBER := 0;
        v_perc_desconto NUMBER;
        v_margem NUMBER;
    BEGIN
        FOR r_p IN c_produtos LOOP
            i := i + 1;
            EXIT WHEN i > p_top_n AND p_cod_produto IS NULL; -- Limite pelo parâmetro p_top_n
            
            -- Calcular métricas
            v_perc_desconto := CASE 
                                WHEN r_p.VALOR_BRUTO > 0 THEN ROUND((r_p.VALOR_DESCONTO / r_p.VALOR_BRUTO) * 100, 2)
                                ELSE 0
                               END;
            
            -- Supondo que margem seja a diferença entre valor bruto e valor total
            -- Em um cenário real, seria necessário considerar o custo do produto
            v_margem := ROUND(((r_p.VALOR_TOTAL - (r_p.VALOR_BRUTO * 0.7)) / r_p.VALOR_TOTAL) * 100, 2);
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r_p.COD_PRODUTO, 7) || '| ' ||
                RPAD(SUBSTR(r_p.NOM_PRODUTO, 1, 16), 17) || '| ' ||
                RPAD(TO_CHAR(r_p.VALOR_BRUTO, '999,999,990.99'), 16) || '| ' ||
                RPAD(TO_CHAR(r_p.VALOR_DESCONTO, '999,999,990.99'), 15) || '| ' ||
                RPAD(TO_CHAR(v_perc_desconto, '990.99') || '%', 8) || '| ' ||
                RPAD(TO_CHAR(r_p.VALOR_TOTAL, '999,999,990.99'), 16) || '| ' ||
                TO_CHAR(v_margem, '990.99') || '%'
            );
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE('FIM DO RELATÓRIO');
    DBMS_OUTPUT.PUT_LINE('Data de geração: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=========================================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório de produtos rentáveis: ' || SQLERRM);
END CP4_RELATORIO_PRODUTOS_RENTAVEIS;
/

-- Continuação da procedure CP4_RELATORIO_PERFIL_CONSUMO
-- Cursor para análise de frequência de compra (continuação)
CREATE OR REPLACE PROCEDURE CP4_RELATORIO_PERFIL_CONSUMO(
    p_ano           IN NUMBER DEFAULT NULL,
    p_tipo_pessoa   IN CHAR DEFAULT NULL,  -- 'F' ou 'J'
    p_cod_cliente   IN NUMBER DEFAULT NULL,
    p_segmentacao   IN VARCHAR2 DEFAULT 'RFM' -- RFM (Recency, Frequency, Monetary) ou ABC
) IS
    -- Cursor para análise RFM (Recency, Frequency, Monetary)
    CURSOR c_rfm_clientes IS
        WITH 
        cliente_dados AS (
            SELECT 
                c.SK_CLIENTE,
                c.COD_CLIENTE,
                c.NOM_CLIENTE,
                c.TIP_PESSOA,
                ROUND(SYSDATE - MAX(t.DATA)) AS RECENCIA_DIAS,
                COUNT(DISTINCT f.COD_PEDIDO) AS FREQUENCIA,
                SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL
            FROM 
                CP4_FATO_VENDAS f
                JOIN CP4_DIM_CLIENTE c ON f.SK_CLIENTE = c.SK_CLIENTE
                JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
            WHERE 
                c.FL_CORRENTE = 'S'
                AND (p_ano IS NULL OR t.ANO = p_ano)
                AND (p_tipo_pessoa IS NULL OR c.TIP_PESSOA = p_tipo_pessoa)
                AND (p_cod_cliente IS NULL OR c.COD_CLIENTE = p_cod_cliente)
            GROUP BY 
                c.SK_CLIENTE, c.COD_CLIENTE, c.NOM_CLIENTE, c.TIP_PESSOA
        ),
        recencia_quartis AS (
            SELECT 
                SK_CLIENTE,
                NTILE(4) OVER (ORDER BY RECENCIA_DIAS DESC) AS R_SCORE -- Menor recência (mais recente) = maior score
            FROM cliente_dados
        ),
        frequencia_quartis AS (
            SELECT 
                SK_CLIENTE,
                NTILE(4) OVER (ORDER BY FREQUENCIA) AS F_SCORE
            FROM cliente_dados
        ),
        valor_quartis AS (
            SELECT 
                SK_CLIENTE,
                NTILE(4) OVER (ORDER BY VALOR_TOTAL) AS M_SCORE
            FROM cliente_dados
        )
        SELECT 
            cd.COD_CLIENTE,
            cd.NOM_CLIENTE,
            cd.TIP_PESSOA,
            cd.RECENCIA_DIAS,
            cd.FREQUENCIA,
            cd.VALOR_TOTAL,
            r.R_SCORE,
            f.F_SCORE,
            m.M_SCORE,
            r.R_SCORE + f.F_SCORE + m.M_SCORE AS RFM_SCORE,
            CASE 
                WHEN r.R_SCORE + f.F_SCORE + m.M_SCORE >= 10 THEN 'A - CLIENTE VIP'
                WHEN r.R_SCORE + f.F_SCORE + m.M_SCORE BETWEEN 6 AND 9 THEN 'B - CLIENTE BOM'
                WHEN r.R_SCORE + f.F_SCORE + m.M_SCORE BETWEEN 4 AND 5 THEN 'C - CLIENTE MÉDIO'
                ELSE 'D - CLIENTE OCASIONAL'
            END AS SEGMENTO_CLIENTE
        FROM 
            cliente_dados cd
            JOIN recencia_quartis r ON cd.SK_CLIENTE = r.SK_CLIENTE
            JOIN frequencia_quartis f ON cd.SK_CLIENTE = f.SK_CLIENTE
            JOIN valor_quartis m ON cd.SK_CLIENTE = m.SK_CLIENTE
        ORDER BY 
            RFM_SCORE DESC, VALOR_TOTAL DESC;
            
    -- Cursor para análise de produtos comprados por segmento de cliente
    CURSOR c_produtos_por_segmento IS
        WITH 
        cliente_segmento AS (
            SELECT 
                c.SK_CLIENTE,
                CASE 
                    WHEN ROUND(SYSDATE - MAX(t.DATA)) <= 90 
                         AND COUNT(DISTINCT f.COD_PEDIDO) >= 3 
                         AND SUM(f.VAL_TOTAL_ITEM) > 1000 THEN 'A - CLIENTE VIP'
                    WHEN ROUND(SYSDATE - MAX(t.DATA)) <= 180 
                         AND COUNT(DISTINCT f.COD_PEDIDO) >= 2 
                         AND SUM(f.VAL_TOTAL_ITEM) > 500 THEN 'B - CLIENTE BOM'
                    WHEN ROUND(SYSDATE - MAX(t.DATA)) <= 365 THEN 'C - CLIENTE MÉDIO'
                    ELSE 'D - CLIENTE OCASIONAL'
                END AS SEGMENTO
            FROM 
                CP4_FATO_VENDAS f
                JOIN CP4_DIM_CLIENTE c ON f.SK_CLIENTE = c.SK_CLIENTE
                JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
            WHERE 
                c.FL_CORRENTE = 'S'
                AND (p_ano IS NULL OR t.ANO = p_ano)
                AND (p_tipo_pessoa IS NULL OR c.TIP_PESSOA = p_tipo_pessoa)
            GROUP BY 
                c.SK_CLIENTE
        )
        SELECT 
            cs.SEGMENTO,
            pv.COD_PRODUTO,
            pv.NOM_PRODUTO,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            SUM(f.QTD_ITEM) AS QTD_ITENS,
            SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL,
            COUNT(DISTINCT f.SK_CLIENTE) AS QTD_CLIENTES,
            ROUND(COUNT(DISTINCT f.COD_PEDIDO) / COUNT(DISTINCT f.SK_CLIENTE), 2) AS PEDIDOS_POR_CLIENTE
        FROM 
            CP4_FATO_VENDAS f
            JOIN cliente_segmento cs ON f.SK_CLIENTE = cs.SK_CLIENTE
            JOIN CP4_DIM_VENDAS pv ON f.SK_VENDAS = pv.SK_VENDAS
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            pv.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
        GROUP BY 
            cs.SEGMENTO, pv.COD_PRODUTO, pv.NOM_PRODUTO
        ORDER BY 
            cs.SEGMENTO, VALOR_TOTAL DESC;
            
    -- Cursor para análise de frequência de compra
    CURSOR c_frequencia_compra IS
        SELECT 
            CASE 
                WHEN c.TIP_PESSOA = 'F' THEN 'PESSOA FÍSICA'
                WHEN c.TIP_PESSOA = 'J' THEN 'PESSOA JURÍDICA'
                ELSE 'OUTROS'
            END AS TIPO_CLIENTE,
            COUNT(DISTINCT c.SK_CLIENTE) AS QTD_CLIENTES,
            COUNT(DISTINCT f.COD_PEDIDO) AS QTD_PEDIDOS,
            ROUND(COUNT(DISTINCT f.COD_PEDIDO) / COUNT(DISTINCT c.SK_CLIENTE), 2) AS PEDIDOS_POR_CLIENTE,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / COUNT(DISTINCT c.SK_CLIENTE), 2) AS VALOR_MEDIO_POR_CLIENTE,
            ROUND(SUM(f.VAL_TOTAL_ITEM) / COUNT(DISTINCT f.COD_PEDIDO), 2) AS TICKET_MEDIO,
            MIN(t.DATA) AS PRIMEIRA_COMPRA,
            MAX(t.DATA) AS ULTIMA_COMPRA
        FROM 
            CP4_FATO_VENDAS f
            JOIN CP4_DIM_CLIENTE c ON f.SK_CLIENTE = c.SK_CLIENTE
            JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
        WHERE 
            c.FL_CORRENTE = 'S'
            AND (p_ano IS NULL OR t.ANO = p_ano)
            AND (p_tipo_pessoa IS NULL OR c.TIP_PESSOA = p_tipo_pessoa)
        GROUP BY 
            CASE 
                WHEN c.TIP_PESSOA = 'F' THEN 'PESSOA FÍSICA'
                WHEN c.TIP_PESSOA = 'J' THEN 'PESSOA JURÍDICA'
                ELSE 'OUTROS'
            END;
    
    -- Cursor para análise de ciclo de vida do cliente
    CURSOR c_ciclo_vida IS
        WITH 
        cliente_historico AS (
            SELECT 
                c.SK_CLIENTE,
                c.COD_CLIENTE,
                c.NOM_CLIENTE,
                c.TIP_PESSOA,
                MIN(t.DATA) AS PRIMEIRA_COMPRA,
                MAX(t.DATA) AS ULTIMA_COMPRA,
                ROUND(SYSDATE - MAX(t.DATA)) AS DIAS_DESDE_ULTIMA_COMPRA,
                ROUND(MAX(t.DATA) - MIN(t.DATA)) AS TEMPO_RELACIONAMENTO_DIAS,
                COUNT(DISTINCT f.COD_PEDIDO) AS TOTAL_PEDIDOS,
                SUM(f.VAL_TOTAL_ITEM) AS VALOR_TOTAL
            FROM 
                CP4_FATO_VENDAS f
                JOIN CP4_DIM_CLIENTE c ON f.SK_CLIENTE = c.SK_CLIENTE
                JOIN CP4_DIM_TEMPO t ON f.SK_TEMPO = t.SK_TEMPO
            WHERE 
                c.FL_CORRENTE = 'S'
                AND (p_tipo_pessoa IS NULL OR c.TIP_PESSOA = p_tipo_pessoa)
                AND (p_cod_cliente IS NULL OR c.COD_CLIENTE = p_cod_cliente)
            GROUP BY 
                c.SK_CLIENTE, c.COD_CLIENTE, c.NOM_CLIENTE, c.TIP_PESSOA
        )
        SELECT 
            COD_CLIENTE,
            NOM_CLIENTE,
            TIP_PESSOA,
            PRIMEIRA_COMPRA,
            ULTIMA_COMPRA,
            DIAS_DESDE_ULTIMA_COMPRA,
            TEMPO_RELACIONAMENTO_DIAS,
            CASE 
                WHEN TEMPO_RELACIONAMENTO_DIAS <= 0 THEN 1 -- Para evitar divisão por zero
                ELSE TEMPO_RELACIONAMENTO_DIAS
            END AS DIAS_AJUSTADOS,
            TOTAL_PEDIDOS,
            VALOR_TOTAL,
            CASE 
                WHEN DIAS_DESDE_ULTIMA_COMPRA > 365 THEN 'INATIVO'
                WHEN DIAS_DESDE_ULTIMA_COMPRA > 180 THEN 'EM RISCO'
                WHEN TEMPO_RELACIONAMENTO_DIAS < 90 THEN 'NOVO'
                WHEN TEMPO_RELACIONAMENTO_DIAS >= 365 AND TOTAL_PEDIDOS > 5 THEN 'LEAL'
                ELSE 'ATIVO'
            END AS STATUS_CLIENTE,
            ROUND(TOTAL_PEDIDOS / 
                 (CASE 
                    WHEN TEMPO_RELACIONAMENTO_DIAS <= 0 THEN 1 -- Para evitar divisão por zero
                    ELSE TEMPO_RELACIONAMENTO_DIAS
                  END) * 30, 2) AS PEDIDOS_POR_MES,
            ROUND(VALOR_TOTAL / TOTAL_PEDIDOS, 2) AS TICKET_MEDIO
        FROM 
            cliente_historico
        ORDER BY 
            DIAS_DESDE_ULTIMA_COMPRA, VALOR_TOTAL DESC;
    
    -- Variáveis para detalhes do relatório
    v_titulo VARCHAR2(100);
    v_filtros VARCHAR2(200) := 'Filtros aplicados: ';
    v_tem_filtro BOOLEAN := FALSE;
    
    -- Contadores para estatísticas
    v_contagem_segmentos NUMBER(5) := 0;
    v_qtd_segmento_a NUMBER(5) := 0;
    v_qtd_segmento_b NUMBER(5) := 0;
    v_qtd_segmento_c NUMBER(5) := 0;
    v_qtd_segmento_d NUMBER(5) := 0;
    v_valor_segmento_a NUMBER := 0;
    v_valor_segmento_b NUMBER := 0;
    v_valor_segmento_c NUMBER := 0;
    v_valor_segmento_d NUMBER := 0;
BEGIN
    -- Montar informações do título e filtros
    v_titulo := 'RELATÓRIO DE PERFIL DE CONSUMO DOS CLIENTES';
    
    IF p_ano IS NOT NULL THEN
        v_filtros := v_filtros || 'Ano=' || p_ano || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_tipo_pessoa IS NOT NULL THEN
        v_filtros := v_filtros || 'Tipo Pessoa=' || p_tipo_pessoa || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF p_cod_cliente IS NOT NULL THEN
        v_filtros := v_filtros || 'Cliente=' || p_cod_cliente || ' ';
        v_tem_filtro := TRUE;
    END IF;
    
    IF NOT v_tem_filtro THEN
        v_filtros := v_filtros || 'Nenhum filtro aplicado.';
    END IF;
    
    -- Imprimir cabeçalho
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_titulo);
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE(v_filtros);
    DBMS_OUTPUT.PUT_LINE('Método de Segmentação: ' || p_segmentacao);
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    
    -- Relatório de Frequência de Compra por Tipo de Cliente
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('1. PERFIL DE CONSUMO POR TIPO DE CLIENTE');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TIPO         | CLIENTES | PEDIDOS | PED/CLIENTE | VALOR MÉDIO/CLIENTE | TICKET MÉDIO | PRIMEIRA COMPRA | ÚLTIMA COMPRA');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------------------------------------------------------');
    
    FOR r_fc IN c_frequencia_compra LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_fc.TIPO_CLIENTE, 13) || '| ' ||
            RPAD(r_fc.QTD_CLIENTES, 10) || '| ' ||
            RPAD(r_fc.QTD_PEDIDOS, 9) || '| ' ||
            RPAD(r_fc.PEDIDOS_POR_CLIENTE, 13) || '| ' ||
            RPAD(TO_CHAR(r_fc.VALOR_MEDIO_POR_CLIENTE, '999,999,990.99'), 21) || '| ' ||
            RPAD(TO_CHAR(r_fc.TICKET_MEDIO, '999,990.99'), 14) || '| ' ||
            RPAD(TO_CHAR(r_fc.PRIMEIRA_COMPRA, 'DD/MM/YYYY'), 16) || '| ' ||
            TO_CHAR(r_fc.ULTIMA_COMPRA, 'DD/MM/YYYY')
        );
    END LOOP;
    
    -- Relatório de Segmentação RFM dos Clientes
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. SEGMENTAÇÃO DE CLIENTES (RFM - Recency, Frequency, Monetary)');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | NOME CLIENTE     | TIPO | RECÊNCIA | FREQ | VALOR TOTAL   | R | F | M | RFM | SEGMENTO');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------');
    
    FOR r_rfm IN c_rfm_clientes LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(r_rfm.COD_CLIENTE, 7) || '| ' ||
            RPAD(SUBSTR(r_rfm.NOM_CLIENTE, 1, 17), 18) || '| ' ||
            RPAD(r_rfm.TIP_PESSOA, 6) || '| ' ||
            RPAD(r_rfm.RECENCIA_DIAS || 'd', 10) || '| ' ||
            RPAD(r_rfm.FREQUENCIA, 6) || '| ' ||
            RPAD(TO_CHAR(r_rfm.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
            RPAD(r_rfm.R_SCORE, 3) || '| ' ||
            RPAD(r_rfm.F_SCORE, 3) || '| ' ||
            RPAD(r_rfm.M_SCORE, 3) || '| ' ||
            RPAD(r_rfm.RFM_SCORE, 5) || '| ' ||
            r_rfm.SEGMENTO_CLIENTE
        );
        
        -- Contagem e soma por segmento
        v_contagem_segmentos := v_contagem_segmentos + 1;
        CASE 
            WHEN r_rfm.SEGMENTO_CLIENTE LIKE 'A%' THEN
                v_qtd_segmento_a := v_qtd_segmento_a + 1;
                v_valor_segmento_a := v_valor_segmento_a + r_rfm.VALOR_TOTAL;
            WHEN r_rfm.SEGMENTO_CLIENTE LIKE 'B%' THEN
                v_qtd_segmento_b := v_qtd_segmento_b + 1;
                v_valor_segmento_b := v_valor_segmento_b + r_rfm.VALOR_TOTAL;
            WHEN r_rfm.SEGMENTO_CLIENTE LIKE 'C%' THEN
                v_qtd_segmento_c := v_qtd_segmento_c + 1;
                v_valor_segmento_c := v_valor_segmento_c + r_rfm.VALOR_TOTAL;
            ELSE
                v_qtd_segmento_d := v_qtd_segmento_d + 1;
                v_valor_segmento_d := v_valor_segmento_d + r_rfm.VALOR_TOTAL;
        END CASE;
        
        -- Limitar a 20 registros se não houver filtro específico
        EXIT WHEN v_contagem_segmentos >= 20 AND p_cod_cliente IS NULL;
    END LOOP;
    
    -- Resumo da segmentação
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. RESUMO DA SEGMENTAÇÃO DE CLIENTES');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('SEGMENTO      | QTDE CLIENTES | % CLIENTES | VALOR TOTAL   | % VALOR');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------------');
    
    DECLARE
        v_total_clientes NUMBER := v_qtd_segmento_a + v_qtd_segmento_b + v_qtd_segmento_c + v_qtd_segmento_d;
        v_total_valor NUMBER := v_valor_segmento_a + v_valor_segmento_b + v_valor_segmento_c + v_valor_segmento_d;
        v_perc_clientes_a NUMBER := CASE WHEN v_total_clientes > 0 THEN ROUND((v_qtd_segmento_a / v_total_clientes) * 100, 2) ELSE 0 END;
        v_perc_clientes_b NUMBER := CASE WHEN v_total_clientes > 0 THEN ROUND((v_qtd_segmento_b / v_total_clientes) * 100, 2) ELSE 0 END;
        v_perc_clientes_c NUMBER := CASE WHEN v_total_clientes > 0 THEN ROUND((v_qtd_segmento_c / v_total_clientes) * 100, 2) ELSE 0 END;
        v_perc_clientes_d NUMBER := CASE WHEN v_total_clientes > 0 THEN ROUND((v_qtd_segmento_d / v_total_clientes) * 100, 2) ELSE 0 END;
        v_perc_valor_a NUMBER := CASE WHEN v_total_valor > 0 THEN ROUND((v_valor_segmento_a / v_total_valor) * 100, 2) ELSE 0 END;
        v_perc_valor_b NUMBER := CASE WHEN v_total_valor > 0 THEN ROUND((v_valor_segmento_b / v_total_valor) * 100, 2) ELSE 0 END;
        v_perc_valor_c NUMBER := CASE WHEN v_total_valor > 0 THEN ROUND((v_valor_segmento_c / v_total_valor) * 100, 2) ELSE 0 END;
        v_perc_valor_d NUMBER := CASE WHEN v_total_valor > 0 THEN ROUND((v_valor_segmento_d / v_total_valor) * 100, 2) ELSE 0 END;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(
            RPAD('A - CLIENTE VIP', 15) || '| ' ||
            RPAD(v_qtd_segmento_a, 15) || '| ' ||
            RPAD(TO_CHAR(v_perc_clientes_a, '990.99') || '%', 12) || '| ' ||
            RPAD(TO_CHAR(v_valor_segmento_a, '999,999,990.99'), 15) || '| ' ||
            TO_CHAR(v_perc_valor_a, '990.99') || '%'
        );
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD('B - CLIENTE BOM', 15) || '| ' ||
            RPAD(v_qtd_segmento_b, 15) || '| ' ||
            RPAD(TO_CHAR(v_perc_clientes_b, '990.99') || '%', 12) || '| ' ||
            RPAD(TO_CHAR(v_valor_segmento_b, '999,999,990.99'), 15) || '| ' ||
            TO_CHAR(v_perc_valor_b, '990.99') || '%'
        );
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD('C - CLIENTE MÉDIO', 15) || '| ' ||
            RPAD(v_qtd_segmento_c, 15) || '| ' ||
            RPAD(TO_CHAR(v_perc_clientes_c, '990.99') || '%', 12) || '| ' ||
            RPAD(TO_CHAR(v_valor_segmento_c, '999,999,990.99'), 15) || '| ' ||
            TO_CHAR(v_perc_valor_c, '990.99') || '%'
        );
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD('D - CLIENTE OCASL', 15) || '| ' ||
            RPAD(v_qtd_segmento_d, 15) || '| ' ||
            RPAD(TO_CHAR(v_perc_clientes_d, '990.99') || '%', 12) || '| ' ||
            RPAD(TO_CHAR(v_valor_segmento_d, '999,999,990.99'), 15) || '| ' ||
            TO_CHAR(v_perc_valor_d, '990.99') || '%'
        );
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD('TOTAL', 15) || '| ' ||
            RPAD(v_total_clientes, 15) || '| ' ||
            RPAD('100.00%', 12) || '| ' ||
            RPAD(TO_CHAR(v_total_valor, '999,999,990.99'), 15) || '| ' ||
            '100.00%'
        );
    END;
    
    -- Relatório de Ciclo de Vida dos Clientes
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. ANÁLISE DE CICLO DE VIDA DOS CLIENTES');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('CÓD   | NOME CLIENTE     | STATUS    | ÚLTIMA COMPRA | TEMPO RELAC. | PEDIDOS | VALOR TOTAL   | PED/MÊS');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------------------------------');
    
    DECLARE
        i NUMBER := 0;
    BEGIN
        FOR r_cv IN c_ciclo_vida LOOP
            i := i + 1;
            EXIT WHEN i > 20 AND p_cod_cliente IS NULL; -- Limite de 20 registros se não houver filtro específico
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r_cv.COD_CLIENTE, 7) || '| ' ||
                RPAD(SUBSTR(r_cv.NOM_CLIENTE, 1, 17), 18) || '| ' ||
                RPAD(r_cv.STATUS_CLIENTE, 11) || '| ' ||
                RPAD(TO_CHAR(r_cv.ULTIMA_COMPRA, 'DD/MM/YYYY'), 15) || '| ' ||
                RPAD(r_cv.TEMPO_RELACIONAMENTO_DIAS || 'd', 14) || '| ' ||
                RPAD(r_cv.TOTAL_PEDIDOS, 9) || '| ' ||
                RPAD(TO_CHAR(r_cv.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
                TO_CHAR(r_cv.PEDIDOS_POR_MES, '990.99')
            );
        END LOOP;
    END;
    
    -- Relatório de Produtos por Segmento de Cliente (Top 5 por segmento)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('5. PRODUTOS PREFERIDOS POR SEGMENTO DE CLIENTE (Top 5 por segmento)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('SEGMENTO      | CÓD   | PRODUTO         | VALOR TOTAL   | CLIENTES | PED/CLIENTE');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------------');
    
    DECLARE
        v_segmento_atual VARCHAR2(20) := '';
        i NUMBER := 0;
    BEGIN
        FOR r_ps IN c_produtos_por_segmento LOOP
            -- Reset contador quando mudar de segmento
            IF v_segmento_atual != r_ps.SEGMENTO THEN
                v_segmento_atual := r_ps.SEGMENTO;
                i := 1;
            ELSE
                i := i + 1;
            END IF;
            
            -- Limitar a 5 produtos por segmento
            IF i <= 5 THEN
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(r_ps.SEGMENTO, 15) || '| ' ||
                    RPAD(r_ps.COD_PRODUTO, 7) || '| ' ||
                    RPAD(SUBSTR(r_ps.NOM_PRODUTO, 1, 16), 17) || '| ' ||
                    RPAD(TO_CHAR(r_ps.VALOR_TOTAL, '999,999,990.99'), 15) || '| ' ||
                    RPAD(r_ps.QTD_CLIENTES, 10) || '| ' ||
                    TO_CHAR(r_ps.PEDIDOS_POR_CLIENTE, '990.99')
                );
            END IF;
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('=========================================================');
    DBMS_OUTPUT.PUT_LINE('FIM DO RELATÓRIO');
    DBMS_OUTPUT.PUT_LINE('Data de geração: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('=========================================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório de perfil de consumo: ' || SQLERRM);
END CP4_RELATORIO_PERFIL_CONSUMO;
/