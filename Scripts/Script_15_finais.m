echo on
clear

fid = fopen('saida.txt','w');
variacoes_Neuronios = [6,2,2,6,2,2,6,2,2,6,2,2,6,2,2];
variacoes_Aprendizagem=[ 0.1 ,0.1,0.001,0.1 ,0.1,0.001,0.1 ,0.1,0.001,0.1 ,0.1,0.001,0.1 ,0.1,0.001];
variacoes_Func = {'tansig','tansig','tansig','logsig','logsig','logsig','tansig','tansig','tansig','logsig','logsig','logsig','tansig','tansig','tansig'};
variacoes_Algoritmo = {'traingdm','traingdm','traingdm','trainoss','trainoss','trainoss','trainoss','trainoss','trainoss','trainlm','trainlm','trainlm','trainlm','trainlm','trainlm'};
rng('default');
experimento = 9;
versao = 0;
for p1 = 1:15;   % sao 15 experimentos
    experimento = experimento+1;
    numEscondidos = variacoes_Neuronios(p1) ;
    fprintf(fid,'Experimento: %6.5f \n',experimento);
    fprintf(fid,'numEscondidos: %6.5f \n',numEscondidos);

    %    Informacoes sobre a rede e os dados
    numEntradas   = 6;     % Numero de nodos de entrada
   % numEscondidos = 6;     % Numero de nodos escondidos
    numSaidas     = 1;     % Numero de nodos de saida
    numTr         = 260;   % Numero de padroes de treinamento
    numVal        = 130;    % Numero de padroes de validacao
    numTeste      = 130;    % Numero de padroes de teste
    echo off

    %    Abrindo arquivos 
    arquivoTreinamento = fopen('treinamento.txt','r');  
    arquivoValidacao   = fopen('validacao.txt','r');    
    arquivoTeste       = fopen('teste.txt','r');        

    %    Lendo arquivos e armazenando dados em matrizes
    dadosTreinamento    = fscanf(arquivoTreinamento,'%f',[(numEntradas + 1), numTr]);   % Lendo arquivo de treinamento
    entradasTreinamento = dadosTreinamento(1:numEntradas, 1:numTr);
    saidasTreinamento   = dadosTreinamento((numEntradas + 1):(numEntradas + 1), 1:numTr);

   % novaSaidasTr        = abs(saidasTreinamento - 1);
    %saidasTreinamento   = [novaSaidasTr; saidasTreinamento];

    dadosValidacao      = fscanf(arquivoValidacao,'%f',[(numEntradas + 1), numVal]);    % Mesmo processo para validacao
    entradasValidacao   = dadosValidacao(1:numEntradas, 1:numVal);
    saidasValidacao     = dadosValidacao((numEntradas + 1):(numEntradas + 1), 1:numVal);

    %novaSaidasVal       = abs(saidasValidacao - 1);
    %saidasValidacao     = [novaSaidasVal; saidasValidacao];

    dadosTeste          = fscanf(arquivoTeste,'%f',[(numEntradas + 1), numTeste]);      % Mesmo processo para teste
    entradasTeste       = dadosTeste(1:numEntradas, 1:numTeste);
    saidasTeste         = dadosTeste((numEntradas + 1):(numEntradas + 1), 1:numTeste);

    %novaSaidasTest      = abs(saidasTeste - 1);
    %saidasTeste         = [novaSaidasTest; saidasTeste];

    %    Fechando arquivos
    fclose(arquivoTreinamento);
    fclose(arquivoValidacao);
    fclose(arquivoTeste);

    %   Adicionando ultima coluna (linha)


    %   Criando a rede (para ajuda, digite 'help newff')

    for entrada = 1 : numEntradas;  % Cria 'matrizFaixa', que possui 'numEntradas' linhas, cada uma sendo igual a [0 1].
         matrizFaixa(entrada,:) = [0 1];  
    end
    
    funcaodeativacao = variacoes_Func{p1};
    fprintf(fid,'funcaodeativacao: %s \n',funcaodeativacao);
    algoritmoaprendizagem =  variacoes_Algoritmo{p1};
    fprintf(fid,'algoritmoaprendizagem: %s\n',algoritmoaprendizagem);
    rede = newff(matrizFaixa,[numEscondidos numSaidas],{funcaodeativacao,funcaodeativacao},algoritmoaprendizagem,'learngdm','mse');
    % matrizFaixa                    : indica que todas as entradas possuem valores na faixa entre 0 e 1
    % [numEscondidos numSaidas]      : indica a quantidade de nodos escondidos e de saida da rede
    % {'logsig','logsig'}            : indica que os nodos das camadas escondida e de saida terao funcao de ativacao sigmoide logistica
    % 'traingdm','learngdm'          : indica que o treinamento vai ser feito com gradiente descendente (backpropagation)
    % 'sse'                          : indica que o erro a ser utilizado vai ser SSE (soma dos erros quadraticos)

    % Inicializa os pesos da rede criada (para ajuda, digite 'help init')
    rede = init(rede);
    echo on
    %   Parametros do treinamento (para ajuda, digite 'help traingd')
    rede.trainParam.epochs   = 10000;    % Maximo numero de iteracoes
    rede.trainParam.lr       = variacoes_Aprendizagem(p1);
    fprintf('rede.trainParam.lr : %6.5f \n',rede.trainParam.lr );
    rede.trainParam.goal     = 0;      % Criterio de minimo erro de treinamento
    rede.trainParam.max_fail = 20;      % Criterio de quantidade maxima de falhas na validacao
    rede.trainParam.min_grad = 0;      % Criterio de gradiente minimo
    rede.trainParam.show     = 10;     % Iteracoes entre exibicoes na tela (preenchendo com 'NaN', nao exibe na tela)
    rede.trainParam.time     = inf;    % Tempo maximo (em segundos) para o treinamento
    echo off
    fprintf('\nTreinando ...\n')

    conjuntoValidacao.P = entradasValidacao; % Entradas da validacao
    conjuntoValidacao.T = saidasValidacao;   % Saidas desejadas da validacao

    %   Treinando a rede
    [redeNova,desempenho,saidasRede,erros] = train(rede,entradasTreinamento,saidasTreinamento,[],[],conjuntoValidacao);
    % redeNova   : rede apos treinamento
    % desempenho : apresenta os seguintes resultados
    %              desempenho.perf  - vetor com os erros de treinamento de todas as iteracoes (neste exemplo, escolheu-se erro SSE)
    %              desempenho.vperf - vetor com os erros de validacao de todas as iteracoes (idem)
    %              desempenho.epoch - vetor com as iteracoes efetuadas
    % saidasRede : matriz contendo as saidas da rede para cada padrao de treinamento
    % erros      : matriz contendo os erros para cada padrao de treinamento
    %             (para cada padrao: erro = saida desejada - saida da rede)
    % Obs.       : Os dois argumentos de 'train' preenchidos com [] apenas sao utilizados quando se usam delays
    %             (para ajuda, digitar 'help train')

    fprintf('\nTestando ...\n');

    %    Testando a rede
    [saidasRedeTeste,Pf,Af,errosTeste,desempenhoTeste] = privatesim(redeNova,entradasTeste,[],[],saidasTeste);
    % saidasRedeTeste : matriz contendo as saidas da rede para cada padrao de teste
    % Pf,Af           : matrizes nao usadas neste exemplo (apenas quando se usam delays)
    % errosTeste      : matriz contendo os erros para cada padrao de teste
    %                  (para cada padrao: erro = saida desejada - saida da rede)
    % desempenhoTeste : erro de teste (neste exemplo, escolheu-se erro SSE)

    fprintf(fid,'MSE para o conjunto de treinamento: %6.5f \n',desempenho.perf(length(desempenho.perf)));
    fprintf(fid,'MSE para o conjunto de validacao: %6.5f \n',desempenho.vperf(length(desempenho.vperf)));
    fprintf(fid,'MSE para o conjunto de teste: %6.5f \n',desempenhoTeste);

    %     Calculando o erro de classificacao para o conjunto de teste
    %     (A regra de classificacao e' winner-takes-all, ou seja, o nodo de saida que gerar o maior valor de saida
    %      corresponde a classe do padrao).
    %     Obs.: Esse erro so' faz sentido se o problema for de classificacao. Para problemas que nao sao de classificacao,
    %           esse trecho do script deve ser eliminado.

    [maiorSaidaRede, nodoVencedorRede] = max (saidasRedeTeste);
    [maiorSaidaDesejada, nodoVencedorDesejado] = max (saidasTeste);

    %      Obs.: O comando 'max' aplicado a uma matriz gera dois vetores: um contendo os maiores elementos de cada coluna
    %            e outro contendo as linhas onde ocorreram os maiores elementos de cada coluna.

    %classificacoesErradas = 0;

    %for padrao = 1 : numTeste;
    %    if nodoVencedorRede(padrao) ~= nodoVencedorDesejado(padrao),
%            classificacoesErradas = classificacoesErradas + 1;
   %     end
   % end

   % erroClassifTeste = 100 * (classificacoesErradas/numTeste);

   % fprintf(fid,'Erro de classificacao para o conjunto de teste: %6.5f%% \n',erroClassifTeste);
    figure; plotconfusion(saidasTeste,saidasRedeTeste); % Matriz de confusao
    nomeMatriz =  'matriz';
    addMatriz = int2str(experimento);
    addMatriz_Versao = int2str(versao);
    nomeMatrizFinal = strcat(nomeMatriz,addMatriz);
    nomeMatrizFinal = strcat(nomeMatrizFinal,'_');
    nomeMatrizFinal = strcat(nomeMatrizFinal,addMatriz_Versao);
    print(nomeMatrizFinal, '-dpng')

    %    Curva ROC com valores padrÃƒÂµes
    [x, y, t, auc] = perfcurve(saidasTeste, saidasRedeTeste, 1);
    fprintf(fid,'Area under ROC curve %6.5f \n',auc);
    figure; plotroc (saidasTeste,saidasRedeTeste); title('Roc Curve'); xlabel('True Positive'); ylabel('False Positive');
    nomeRoc=  'roc';
    addRoc = int2str(experimento);
    nomeRoc = strcat(nomeRoc,addRoc);
    addRoc_Versao = int2str(versao);
    nomeRoc = strcat(nomeRoc,'_'); 
    nomeRoc = strcat(nomeRoc,addRoc_Versao); 
    print(nomeRoc,'-dpng');
    delete(findall(0,'Type','figure'))
    %    Provavelmente salva o que tÃ¡ no console em um .txt
    %diary('teste')
end;
fid = fclose(fid);