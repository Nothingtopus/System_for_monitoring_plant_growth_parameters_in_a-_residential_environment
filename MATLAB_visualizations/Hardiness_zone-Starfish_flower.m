% Configurações do canal:
channelID = ---; % Número de identificação do canal.
readAPIKey = '---'; % Chave de leitura no canal, para aquisição de dados.

% Variável para armazenar um valor de leitura inválido caso não se encontre uma leitura
% ok na pesquisa das leituras mais recentes:
leitura_ok = 0;

% Verifica os últimos 10 valores do field 2 e retorna o mais recente que é válido:
data = thingSpeakRead(channelID, 'Fields', 2, 'NumPoints', 10, 'ReadKey', readAPIKey);
for i = length(data):-1:1
    if ~isnan(data(i)) && data(i) ~= 0 && data(i) ~= -1
        ultimo_valor_valido = data(i);
        leitura_ok = 1;
        break;
    end
end

% Teste:
% leitura_ok = 0;

% Associa uma leitura não ok:
if leitura_ok == 0
    ultimo_valor_valido = NaN;
end

% Abaixo se realiza a leitura do último valor do field 2 (correspondente a temperatura) 
% e a salva na variável temperatura:
temperatura = ultimo_valor_valido;

% Nesta seção seguinte se utilizou diferentes valores de temperatura com o intuito de averiguar o
% funcionamento do widget:
% Valores de teste:
% Temperatura fora da zona de resistência:
% temperatura = 22;
% Temperatura na zona de resistência:
% temperatura = 15;
% Temperatura abaixo da zona de resistência:
% temperatura = -10;
% Temperatura de leitura inválida:
% temperatura = NaN;

% Caso a temperatura atual esteja na zona de resistência, logo:
if temperatura >= -1.1 && temperatura <= 21.1
    % Se define a variável cor como ciano (R=0,G=1,B=1) e a mensagem associada:
    cor = [0 1 1];
    mensagem = "Em zona de resistência";
% Caso a temperatura se encontre fora da zona de resistência:
elseif temperatura > 21.1
    % Se define a variável cor como verde (R=0,G=1,B=0) e a mensagem associada:
    cor = [0 1 0];
    mensagem = "Fora da zona de resistência";
% Caso a temperatura seja abaixo do valor mínimo da zona de resistência:
elseif temperatura < -1.1
    % Se define a variável cor como vermelho (R=1,G=0,B=0) e a mensagem associada:
    cor = [1 0 0];
    mensagem = "Abaixo da zona de resistência";
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
texto = sprintf('Temperatura: %.1f °C\n%s', temperatura, mensagem);
text(5, 2.5, texto, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

hold off; % E se desfixa a figura final exibida.
