program conferencia;

uses
  SysUtils;

var
  identificacaoLote: string;
  referenciaPeca: string;
  quantidadePrevista: integer;
  quantidadeAprovada: integer;
  quantidadeRejeitada: integer;
  loteCadastrado: boolean;
  opcao: integer;

procedure exibirMenu;
begin
  writeln;
  writeln('=== Conferencia de lotes ===');
  writeln('1. Informar ou substituir o lote atual');
  writeln('2. Exibir o resumo da conferencia');
  writeln('3. Salvar o resumo em arquivo de texto');
  writeln('0. Sair');
  writeln;
end;

function confirmar(mensagem: string): boolean;
var
  resposta: string;
  valida: boolean;
begin
  valida := false;
  confirmar := false;
  repeat
    write(mensagem);
    readln(resposta);
    resposta := Trim(resposta);
    if (resposta = 'S') or (resposta = 's') then
    begin
      confirmar := true;
      valida := true;
    end
    else if (resposta = 'N') or (resposta = 'n') then
    begin
      confirmar := false;
      valida := true;
    end
    else
      writeln('Digite S ou N.');
  until valida;
end;

function lerTextoObrigatorio(mensagem: string): string;
var
  texto: string;
begin
  repeat
    write(mensagem);
    readln(texto);
    { Trim tira espacos das pontas; assim "   " tambem fica vazio. }
    texto := Trim(texto);
    if texto = '' then
      writeln('Este campo nao pode ficar vazio.');
  until texto <> '';
  lerTextoObrigatorio := texto;
end;

function lerInteiro(mensagem: string): integer;
var
  entrada: string;
  valor, codigoErro: integer;
begin
  repeat
    write(mensagem);
    readln(entrada);
    entrada := Trim(entrada);
    { Val converte o texto em inteiro. Se nao for numero valido, codigoErro <> 0. }
    val(entrada, valor, codigoErro);
    if codigoErro <> 0 then
      writeln('Digite um numero inteiro.');
  until codigoErro = 0;
  lerInteiro := valor;
end;

function lerOpcao: integer;
var
  entrada: string;
  valor, codigoErro: integer;
begin
  write('Escolha uma opcao: ');
  readln(entrada);
  entrada := Trim(entrada);
  val(entrada, valor, codigoErro);
  if codigoErro <> 0 then
    lerOpcao := -1
  else
    lerOpcao := valor;
end;

procedure informarLote;
var
  identificacao: string;
  referencia: string;
  prevista: integer;
  aprovada: integer;
  rejeitada: integer;
  podeCadastrar: boolean;
begin
  podeCadastrar := true;

  if loteCadastrado then
  begin
    writeln('Ja existe um lote cadastrado: ', identificacaoLote);
    podeCadastrar := confirmar('Deseja substituir o lote atual? (S/N): ');
    if not podeCadastrar then
      writeln('O lote atual foi mantido.');
  end;

  if podeCadastrar then
  begin
    identificacao := lerTextoObrigatorio('Identificacao do lote: ');
    referencia := lerTextoObrigatorio('Referencia da peca: ');

    repeat
      prevista := lerInteiro('Quantidade prevista: ');
      if prevista <= 0 then
        writeln('A quantidade prevista deve ser maior que zero.');
    until prevista > 0;

    repeat
      aprovada := lerInteiro('Quantidade aprovada: ');
      if aprovada < 0 then
        writeln('A quantidade aprovada nao pode ser negativa.');
      if aprovada > prevista then
        writeln('A quantidade aprovada nao pode ser maior que a prevista.');
    until (aprovada >= 0) and (aprovada <= prevista);

    repeat
      rejeitada := lerInteiro('Quantidade rejeitada: ');
      if rejeitada < 0 then
        writeln('A quantidade rejeitada nao pode ser negativa.');
      { O teto e o que ainda pode ser conferido, sem somar aprovada + rejeitada. }
      if rejeitada > prevista - aprovada then
        writeln('A quantidade rejeitada nao pode ser maior que ', prevista - aprovada, '.');
    until (rejeitada >= 0) and (rejeitada <= prevista - aprovada);

    identificacaoLote := identificacao;
    referenciaPeca := referencia;
    quantidadePrevista := prevista;
    quantidadeAprovada := aprovada;
    quantidadeRejeitada := rejeitada;
    loteCadastrado := true;
    writeln('Lote cadastrado.');
  end;
end;

function textoComVirgula(valor: real): string;
var
  texto: string;
  i: integer;
begin
  str(valor:0:2, texto);
  for i := 1 to Length(texto) do
    if texto[i] = '.' then
      texto[i] := ',';
  textoComVirgula := texto;
end;

procedure escreverLinhasDoResumo(var destino: Text);
var
  conferidas: integer;
  faltando: integer;
  percentual: real;
  situacao: string;
begin
  conferidas := quantidadeAprovada + quantidadeRejeitada;
  faltando := quantidadePrevista - conferidas;

  if conferidas = 0 then
    situacao := 'nao iniciado'
  else if conferidas = quantidadePrevista then
    situacao := 'conferencia concluida'
  else
    situacao := 'em conferencia';

  { A verificacao de I/O vale aqui, onde o WriteLn e compilado, nao na chamada. }
  {$I-}
  writeln(destino, '--- Resumo da conferencia ---');
  writeln(destino, 'Identificacao: ', identificacaoLote);
  writeln(destino, 'Referencia: ', referenciaPeca);
  writeln(destino, 'Quantidade prevista: ', quantidadePrevista);
  writeln(destino, 'Quantidade aprovada: ', quantidadeAprovada);
  writeln(destino, 'Quantidade rejeitada: ', quantidadeRejeitada);
  writeln(destino, 'Total conferido: ', conferidas);
  if faltando = 0 then
    writeln(destino, 'Faltam conferir: nenhuma peca')
  else
    writeln(destino, 'Faltam conferir: ', faltando);

  if conferidas = 0 then
    writeln(destino, 'Percentual de rejeicao: nao se aplica')
  else
  begin
    { 100.0 faz a multiplicacao em ponto flutuante. Em Pascal, / ja resulta em real; a divisao inteira usa div. }
    percentual := (quantidadeRejeitada * 100.0) / conferidas;
    writeln(destino, 'Percentual de rejeicao: ', textoComVirgula(percentual), '%');
  end;

  writeln(destino, 'Situacao: ', situacao);
  {$I+}
end;

procedure exibirResumo;
var
  codigoErro: integer;
begin
  if not loteCadastrado then
    writeln('Cadastre um lote antes de consultar o resumo.')
  else
  begin
    writeln;
    escreverLinhasDoResumo(Output);
    { Le IOResult para limpar o estado e nao deixar erro pendente na proxima gravacao. }
    codigoErro := IOResult;
  end;
end;

procedure salvarResumo;
var
  nomeArquivo: string;
  arquivo: Text;
  podeGravar: boolean;
  codigoAbertura: integer;
  codigoEscrita: integer;
  codigoFechamento: integer;
begin
  if not loteCadastrado then
    writeln('Cadastre um lote antes de salvar o resumo.')
  else
  begin
    nomeArquivo := lerTextoObrigatorio('Nome do arquivo (exemplo: resumo.txt): ');
    podeGravar := true;

    { FileExists evita Rewrite apagar um arquivo sem perguntar. }
    if FileExists(nomeArquivo) then
    begin
      podeGravar := confirmar('O arquivo ja existe. Deseja sobrescrever? (S/N): ');
      if not podeGravar then
        writeln('O arquivo nao foi alterado.');
    end;

    if podeGravar then
    begin
      assign(arquivo, nomeArquivo);
      {$I-}
      rewrite(arquivo);
      codigoAbertura := IOResult;
      {$I+}
      if codigoAbertura <> 0 then
        writeln('Nao foi possivel gravar o arquivo. Verifique o nome e a pasta.')
      else
      begin
        escreverLinhasDoResumo(arquivo);
        codigoEscrita := IOResult;

        {$I-}
        close(arquivo);
        codigoFechamento := IOResult;
        {$I+}

        if (codigoEscrita = 0) and (codigoFechamento = 0) then
          writeln('Resumo salvo em ', nomeArquivo, '.')
        else
          writeln('A exportacao nao foi concluida. O arquivo pode estar incompleto.');
      end;
    end;
  end;
end;

begin
  loteCadastrado := false;
  opcao := -1;

  while opcao <> 0 do
  begin
    exibirMenu;
    opcao := lerOpcao;

    case opcao of
      1:
        informarLote;
      2:
        exibirResumo;
      3:
        salvarResumo;
      0:
        writeln('Encerrando o programa.');
    else
      writeln('Opcao invalida. Escolha 1, 2, 3 ou 0.');
    end;
  end;
end.
