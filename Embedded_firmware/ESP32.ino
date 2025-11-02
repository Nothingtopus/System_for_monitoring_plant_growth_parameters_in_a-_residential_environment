// Inclusão de bibliotecas:
#include <WiFi.h> // Importa as funções da biblioteca WiFi.h, permitindo a utilização de recursos para comunicação Wifi com o ESP32.
#include <HTTPClient.h> // Importa as funções da biblioteca HTTPClient.h, permitindo a utilização de recursos para estabelecer requisições HTTP com o ESP32.
#include <DHT.h> // Importa as funções da biblioteca DHT.h, permitindo a utilização de recursos que facilitam a utilização de sensores DHT11 ou DHT22, ao já considerarem
// a estrutura do protocolo de comunicação com esses dispositivos, facilitando a aquisição dos dados.
#include "driver/rtc_io.h" // Importa funções de entrada e saída que permitem gerenciar recursos do SoC, como para realização do modo deep sleep.

#define rede_wifi "Nome_da_rede" // Define o nome da rede Wifi com a qual o ESP32 irá se conectar.
#define senha_da_rede_wifi "Senha_da_rede" // Define a senha da rede Wifi com a qual o ESP32 irá se conectar.

// Define os pinos do ESP32 aos quais cada sensor se encontra conectado:
#define pino_do_DHT22 26 // Define o pino 26 como o associado ao de leitura do DHT22.
#define tipo_do_DHT DHT22 // Define o tipo de DHT utilizado, para realização correta da inicialização da comunicação.
#define pino_do_sensor_de_luminosidade 36 // Define o pino 36 como o associado ao de leitura do divisor de tensão com o LDR.
#define pino_do_sensor_de_umidade_do_solo 39 // Define o pino 39 como o associado ao de leitura do sensor de umidade do solo.

// Abaixo se realiza configurações para comunicação com a plataforma ThingSpeak:
const char* chave_api_de_escrita = "Chave_de_escrita"; // Define a chave para escrita no canal.
const char* servidor_ThingSpeak = "https://api.thingspeak.com/update"; // Define o servidor da plataforma.

// Define o tempo de espera para a utilização do modo de deep sleep, capaz de hibernar a placa durante o tempo informado,
// desativando recursos de Wifi, dentre outros:
#define tempo_de_espera  1800000000 // Define um tempo de espera de 30 minutos = 3600000000/2 us = 1800000000 us entre as leituras, para a duração de cada hibernação.
//#define tempo_de_espera 60000000 // Define um tempo de espera de 1 minuto entre as capturas, para a duração de cada hibernação.

// Define valores reais que corresponderão as leituras de cada sensor, as quais são tidas como variáveis globais,
// que serão repassadas para o ThingSpeak:
float temperatura_do_ambiente = 0;
float umidade_do_ar = 0;   
float luminosidade = 0;
float umidade_do_solo = 0;

int tentativas = 0; // Define uma variável a qual representará o número de tentativas de requisição HTTP para enviar dados ao ThingSpeak.

DHT dht(pino_do_DHT22, tipo_do_DHT); // Configura os parâmetros para a comunicação com o sensor DHT22.

void setup() { // Função sem retorno, a qual é executada uma única vez para a realização de configurações iniciais
// (correspondentes ao estabelecimento da conexão com a rede Wifi e inicialização do DHT22):
  WiFi.begin(rede_wifi, senha_da_rede_wifi); // Inicia a conexão do ESP32 com os parâmetros passados.
  // Laço que aguarda o estabelecimento da comunicação com a rede.
  while (WiFi.status() != WL_CONNECTED) { 
    delay(500);
  }
  dht.begin(); // Inicia a comunicação com o sensor DHT22.
  obtem_leituras(); // Realiza a leitura dos sensores utilizados.
  updateThingSpeak(temperatura_do_ambiente,umidade_do_ar,luminosidade,umidade_do_solo); // Passa as últimas leituras realizadas como argumentos, para
  // terem seus valores repassados para os fields associados no canal da plataforma ThingSpeak.

  tentativas = 0; // Reseta o número de tentativas realizadas.

  // Desconecta da rede Wifi, liberando recursos:
  WiFi.disconnect();
  WiFi.mode(WIFI_OFF);

  esp_deep_sleep(tempo_de_espera); // Coloca o ESP32 no modo de deep sleep durante 30 minutos, e depois o reinicia.
}

void obtem_leituras() {  // Laço sem retorno, no qual se realiza a leitura dos valores dos sensores de luminosidade, de umidade relativa do solo
// e de umidade relativa e temperatura do ambiente:

  temperatura_do_ambiente = dht.readTemperature(); // Realiza a leitura da temperatura do ambiente (em graus Celcius) pelo DHT22 e a salva na respectiva variável.
  umidade_do_ar = dht.readHumidity(); // Realiza a leitura de umidade relativa do ar pelo DHT22 e a salva na respectiva variável.
  luminosidade = analogRead(pino_do_sensor_de_luminosidade); // Realiza a leitura do sensor de luminosidade e a salva.
  umidade_do_solo = analogRead(pino_do_sensor_de_umidade_do_solo); // Obtém a leitura do sensor de umidade do solo e a armazena.

}

// Função que repassa as últimas leituras realizadas para os fields associados no canal da plataforma ThingSpeak:
void updateThingSpeak(float temperatura_do_ambiente, float umidade_do_ar, float luminosidade, float umidade_do_solo){
  
  HTTPClient ThingSpeak; // Cria o objeto ThingSpeak com classe de cliente HTTP.
  
  String url = String(servidor_ThingSpeak) + "?api_key=" + chave_api_de_escrita + "&field2=" + temperatura_do_ambiente + "&field3=" + umidade_do_ar + "&field4=" + luminosidade + "&field5=" + umidade_do_solo; // Define o endereço URL
  // dos fields associados a cada leitura, assim como do valor de cada (correspondentes as últimas leituras).
  
  ThingSpeak.begin(url); // Configura o objeto ThingSpeak com o URL do serviço a se acessar.
  ThingSpeak.setTimeout(10000); // Configura um tempo de retorno de no máximo 10 segundos para processar a requisição.
  
  int codigo_HTTP = ThingSpeak.GET(); // Realiza a requisição de escrita nos fields do ThingSpeak (informado pelo URL).

  if ((codigo_HTTP != 200) && (tentativas < 10)) { // Caso a solicitação tenha falhado e ainda não tenham ocorrido dez tentativas de envio:
    ThingSpeak.end(); // Finaliza a requisição HTTP atual.
    delay(5000); // Aguarda 5 segundos antes de nova tentativa (poderia ser substituído por um temporizador caso houvessem outras tarefas).
    tentativas=tentativas+1; // Atualiza o número de tentativas.
    updateThingSpeak(temperatura_do_ambiente,umidade_do_ar,luminosidade,umidade_do_solo); // Realiza uma nova requisição para escrever os valores das leituras
    // na plataforma ThingSpeak.
  }

  ThingSpeak.end(); // Finaliza a requisição HTTP.
}

void loop(){ // Função sem retorno de repetição continua:
  // Nada ocorre nesta função devido a utilização do modo de deep sleep.
}
