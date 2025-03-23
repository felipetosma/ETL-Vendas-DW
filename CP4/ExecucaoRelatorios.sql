set SERVEROUTPUT on;
-- Relatório de volume de vendas para o ano de 2023
EXEC CP4_RELATORIO_VOLUME_VENDAS(p_ano => 2024);

-- Produtos mais rentáveis (top 10)
EXEC CP4_RELATORIO_PRODUTOS_RENTAVEIS(p_top_n => 10);

-- Perfil de consumo dos clientes pessoas jurídicas
EXEC CP4_RELATORIO_PERFIL_CONSUMO(p_tipo_pessoa => 'J');

-- Análise detalhada de um cliente específico
EXEC CP4_RELATORIO_PERFIL_CONSUMO(p_cod_cliente => 12345);