# Controle de Tortinhas

Sistema desktop em **Delphi + SQLite** para controlar custos, produção, estoque, vendas, perdas e fiado de uma pequena produção artesanal de tortinhas vendidas a pronta-entrega.

Ele substitui uma planilha do Excel e roda **só com o executável**: não tem instalador, servidor nem DLL. O banco de dados é criado sozinho na primeira execução.

> Projeto desenvolvido como Trabalho de Conclusão de Curso do curso de Tecnologia em Análise e Desenvolvimento de Sistemas da Fatec Taquaritinga.

## Funcionalidades

- **Ingredientes e receitas.** Calcula o custo por tortinha de cada sabor, com base no rendimento da receita.
- **Compras e estoque.** O estoque é feito por movimentações:
  - a compra soma;
  - a produção dá baixa nos ingredientes da receita;
  - o inventário ajusta o saldo.
- **Produção.** Avisa quando falta ingrediente e controla as tortinhas prontas disponíveis.
- **Vendas.** Cada venda grava o custo do momento, então um reajuste de preço não altera o lucro de meses anteriores.
- **Perdas.** Registra as tortinhas que estragaram, venceram ou caíram, e desconta esse custo do lucro.
- **Fiado.**
  - Saldo por cliente, com pagamento parcial.
  - O pagamento abate primeiro as compras mais antigas.
  - Extrato com o saldo linha a linha.
  - Mensagem de cobrança pronta para o WhatsApp.
- **Despesas.** Lança os gastos fora da receita, como gás e entrega.
- **Dashboard.** Mostra, por período:
  - faturamento, CPV, lucro bruto e lucro líquido, margem e perdas;
  - vendido fiado, recebido e total a receber;
  - vendas por sabor e uma tabela mês a mês.
- **Backup.** Faz uma cópia do banco com um clique (`VACUUM INTO`).

## Tecnologias

| | |
|---|---|
| Linguagem / IDE | Delphi 13 Community Edition (VCL) |
| Banco | SQLite com link estático (`FireDAC.Phys.SQLiteWrapper.Stat`) |
