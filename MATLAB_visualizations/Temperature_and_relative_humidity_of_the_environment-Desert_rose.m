% Configurações do canal:
channelID = ---; % Número de identificação do canal.
readAPIKey = '---'; % Chave de leitura no canal, para aquisição de dados.

% Variáveis para armazenar valores de leituras inválidos caso não se encontrem leituras
% ok na pesquisa das leituras mais recentes:
leitura_ok_1 = 0;
leitura_ok_2 = 0;

% Verifica os últimos 10 valores dos field 2 e 3 e retorna os mais recentes que são válidos:
data_1 = thingSpeakRead(channelID, 'Fields', 2, 'NumPoints', 10, 'ReadKey', readAPIKey);
data_2 = thingSpeakRead(channelID, 'Fields', 3, 'NumPoints', 10, 'ReadKey', readAPIKey);
for i = length(data_1):-1:1
    if ~isnan(data_1(i)) && data_1(i) ~= 0 && data_1(i) ~= -1
        ultimo_valor_valido_1 = data_1(i);
        leitura_ok_1 = 1;
        break;
    end
end
for i = length(data_2):-1:1
    if ~isnan(data_2(i)) && data_2(i) ~= 0 && data_2(i) ~= -1
        ultimo_valor_valido_2 = data_2(i);
        leitura_ok_2 = 1;
        break;
    end
end

% Teste:
% leitura_ok_1 = 0;
% leitura_ok_2 = 0;

% Associa leituras não ok, caso não se encontrem valores válidos:
if leitura_ok_1 == 0
    ultimo_valor_valido_1 = NaN;
end
if leitura_ok_2 == 0
    ultimo_valor_valido_2 = NaN;
end

% Abaixo se realiza as leituras dos últimos valores dos fields 2 e 3 (correspondentes a temperatura e a umidade do ambiente) 
% e as salva nas variáveis temperatura e umidade:
temperatura = ultimo_valor_valido_1;
umidade = ultimo_valor_valido_2;

% Valores de teste:
% Temperatura na faixa ideal:
% temperatura = 20;
% Temperatura fora da faixa ideal:
% temperatura = 45;
% Temperatura fora da faixa ideal:
% temperatura = 9;
% Temperatura de leitura inválida:
% temperatura = NaN;
% Valor de umidade:
% umidade = 50;

% Caso a temperatura atual esteja na faixa ideal, logo:
if temperatura >= 10 && temperatura <= 35
    % Se define a variável cor como verde (R=0,G=1,B=0) e a mensagem associada:
    cor = [0 1 0];
    mensagem = "Temperatura ideal";
% Caso a temperatura atual esteja fora da faixa ideal, logo:
elseif temperatura < 10 || temperatura > 35
    % Se define a variável cor como vermelho (R=1,G=0,B=0) e a mensagem associada:
    cor = [1 0 0];
    mensagem = "Temperatura não ideal";
% Caso a leitura seja inválida (NaN):
else
    % Se define a variável cor como branco (R=1,G=1,B=1) e a mensagem associada:
    cor = [1 1 1];
    mensagem = "Última leitura inválida";
end

% Abaixo se cria o gráfico utilizado como indicador visual:
figure('Color', 'w'); % Se define uma figura em branco.
hold on; % Mantém a exibição da figura criada.
axis off; % Desativa a exibição dos eixos.
axis equal; % Mantém as mesmas dimensões nos eixos.

% A seguir se desenha o retângulo indicador:
rectangle('Position',[0 0 10 5],'FaceColor',cor,'EdgeColor','black');

% Por fim, se adiciona o texto centralizado com a mensagem
texto = sprintf('Temperatura: %.1f °C\nUmidade: %.1f %%\n%s', temperatura, umidade, mensagem);
text(5, 2.5, texto, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

hold off; % E se desfixa a figura final exibida.
