/*
  Módulo: wrapper

  Descrição:
  Este módulo implementa um buffer circular para sincronização de dados entre dois domínios de clock diferentes (clk_1 e clk_2).
  Ele utiliza um buffer de tamanho fixo (8 posições) para armazenar dados de entrada e gerenciar a leitura e escrita de forma independente.

  Entradas:
    - rst: Sinal de reset assíncrono. Quando ativo, reinicia os registradores internos.
    - clk_1: Clock para o domínio de escrita.
    - clk_2: Clock para o domínio de leitura.
    - data_1_en: Habilita a escrita de dados no buffer.
    - data_1 [15:0]: Dados de entrada a serem escritos no buffer.

  Saídas:
    - buffer_full: Indica que o buffer está cheio e não pode aceitar mais dados.
    - buffer_empty: Indica que o buffer está vazio e não há dados para leitura.
    - data_valid_2: Indica que os dados de saída (data_2) são válidos.
    - data_2 [15:0]: Dados de saída lidos do buffer.

  Funcionamento:
    - Escrita (controlada por clk_1):
      Quando data_1_en está ativo e o buffer não está cheio, os dados de entrada (data_1) são escritos na posição atual do buffer
      indicada por buffer_write. O ponteiro buffer_write é incrementado circularmente.

    - Leitura (controlada por clk_2):
      Quando o buffer não está vazio, os dados na posição atual indicada por buffer_read são lidos para data_2, e o sinal
      data_valid_2 é ativado. O ponteiro buffer_read é incrementado circularmente.

  Observações:
    - O buffer utiliza aritmética modular para gerenciar os ponteiros de leitura e escrita, garantindo operação circular.
    - O sinal de reset (rst) reinicia os ponteiros e limpa os dados de saída.
*/


module wrapper (
  input rst,
  input clk_1,
  input clk_2,
  input data_1_en,
  input [15:0] data_1,
  output buffer_full,
  output buffer_empty,
  output reg data_valid_2,
  output reg [15:0] data_2
);

  reg [15:0] t_buffer [0:7]; 
  reg [2:0] buffer_write;    
  reg [2:0] buffer_read;     

  assign buffer_full = (buffer_write + 1) % 8 == buffer_read;
  assign buffer_empty = (buffer_write == buffer_read);

  // Processo de escrita, controlado por clk_1
  always @(posedge clk_1 or posedge rst) begin
    if (rst) begin
      buffer_write <= 3'b0;
    end else if (data_1_en && !buffer_full) begin
      t_buffer[buffer_write] <= data_1;
      buffer_write <= (buffer_write + 1) % 8; 
    end
  end

  // Processo de leitura, controlado por clk_2
  always @(posedge clk_2 or posedge rst) begin
    if (rst) begin
      buffer_read <= 3'b0;
      data_valid_2 <= 1'b0;
      data_2 <= 16'b0;
    end else if (!buffer_empty) begin
      data_2 <= t_buffer[buffer_read];
      data_valid_2 <= 1'b1;
      buffer_read <= (buffer_read + 1) % 8; 
    end else begin
      data_valid_2 <= 1'b0;
    end
  end

endmodule
