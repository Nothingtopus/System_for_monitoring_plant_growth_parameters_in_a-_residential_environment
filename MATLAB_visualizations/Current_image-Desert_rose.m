% Abaixo se define o endereço do servidor Flask, hospedado no Render, e do nome da planta associada 
% que irá compor o caminho para a imagem armazenada:
endereco_url_do_servidor_flask = '---';
planta = 'rosa_deserto';

try % Executa o código principal na inexistência de erros:

    % Realiza a determinação do endereço URL em que a última imagem da planta será armazenada:
    URL = [endereco_url_do_servidor_flask '/slideshow/' planta];
    
    % Realiza requisição HTTP para obter do servidor Flask informações das imagens existentes 
    % (com 30 segundos de timeout):
    dados_das_imagens = webread(URL, weboptions('Timeout', 30));

    if dados_das_imagens.total_images > 0 % Caso existam imagens disponíveis:
        % Obtém a imagem associada a última captura (foto da última hora):
        ultima_imagem = dados_das_imagens.images(1);
        
        % Define o endereço URL da imagem selecionada:
        URL_da_ultima_imagem = ['https://' ultima_imagem.url];
        
        % Cria um arquivo de imagem temporário para exibir a foto da planta:
        imagem_temporaria = 'imagem_temporaria.jpg';
        
        % Realiza requisição HTTP para obter o conteúdo da imagem no servidor Flask, e o salva na imagem
        % temporária (com 30 segundos de timeout):
        websave(imagem_temporaria, URL_da_ultima_imagem, weboptions('Timeout', 30));
        
        % Por fim, se exibe a imagem e se exclui o arquivo temporário:
        imagem = imread(imagem_temporaria);
        imshow(imagem);
        delete(tempFile);
  
    end
    
catch ME % Executa código auxiliar para diagnóstico de erros, caso algum ocorra:
    fprintf('Erro: %s\n', ME.message); % Apresenta a mensagem de erro no terminal.
    text(0.2, 0.5, sprintf('Erro: %s', ME.message), 'FontSize', 10); % Apresenta a mensagem de erro
    % através de uma figura.
end
