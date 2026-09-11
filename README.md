# Conferência de lotes

Programa de terminal em Pascal para conferir um lote do setor de corte de uma confecção. A ideia é comparar a quantidade prevista com as peças aprovadas e rejeitadas e ver quantas ainda faltam conferir.

Desenvolvi este projeto a partir da minha experiência no setor de corte de uma indústria têxtil, para representar uma conferência de quantidades por lote.

## Como compilar e executar

É preciso ter o Free Pascal instalado. No Windows, no PowerShell, no diretório do projeto:

```text
fpc conferencia.pas
.\conferencia.exe
```

O código está em um único arquivo: `conferencia.pas`.

## Uso

O menu tem quatro opções:

- 1. Informar ou substituir o lote atual
- 2. Exibir o resumo da conferência
- 3. Salvar o resumo em arquivo de texto
- 0. Sair

Só existe um lote por vez. Se já houver lote cadastrado, a opção 1 pede confirmação antes de substituir. Consulta e exportação só funcionam depois do cadastro. Ao encerrar o programa, os dados do lote são perdidos.

Exemplo (dados fictícios):

- Identificação: Lote 14
- Referência: Camiseta 001
- Previstas: 200
- Aprovadas: 170
- Rejeitadas: 10

O resumo esperado:

- Total conferido: 180
- Faltam conferir: 20
- Percentual de rejeição: 5,56%
- Situação: em conferência

O percentual é calculado sobre as peças já conferidas, não sobre a quantidade prevista. Peças que ainda não foram vistas não entram como rejeitadas. Se nenhuma peça foi conferida, o percentual aparece como “não se aplica”.

Na opção 3, um nome simples como `resumo.txt` grava o relatório na pasta de onde o programa foi executado. Se você informar um caminho, o arquivo vai para esse destino, desde que seja válido e acessível. Se o arquivo já existir, o programa pergunta antes de sobrescrever. O `.txt` exportado não pode ser importado de volta para o programa.

## Limitações

- Não há banco de dados nem histórico de lotes.
- Não há tela gráfica; tudo acontece no terminal.
- O relatório é um arquivo `.txt` simples, não uma planilha.
- O programa foi escrito para estudo de lógica em Pascal, não para uso em produção.
