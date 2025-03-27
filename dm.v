/*
  Módulo: dm

  Descrição:
  Este módulo implementa a lógica para exibição de dados em um display de 7 segmentos,
  utilizando um driver de display (dspl_drv_NexysA7). Ele recebe entradas de controle,
  dados e configurações, e gera as saídas necessárias para controlar o display.

  Entradas:
  - rst (input): Sinal de reset para reinicializar o sistema.
  - clk (input): Sinal de clock para sincronização.
  - prog (input[2:0]): Dados de 3 bits representando o programa ou estado atual.
  - modulo (input[1:0]): Dados de 2 bits representando o módulo atual.
  - data_2 (input[15:0]): Dados de 16 bits a serem exibidos no display.

  Saídas:
  - an (output[7:0]): Controle de ativação dos displays de 7 segmentos.
  - dec_ddp (output[7:0]): Dados decodificados para exibição nos displays.

  Lógica Interna:
  - O módulo divide os 16 bits de entrada (data_2) em 4 grupos de 4 bits (d5 a d8),
    adicionando bits de controle para indicar se o display está ligado e se os dois
    pontos adjacentes devem ser exibidos.
  - Os sinais d1 e d3 são configurados para exibir os valores de "prog" e "modulo",
    respectivamente, com bits adicionais de controle.
  - Os sinais d2 e d4 são configurados como 0, indicando que esses displays não
    exibirão dados.

  Instanciação:
  - O módulo instancia o driver de display (dspl_drv_NexysA7), conectando os sinais
    configurados (d1 a d8) às entradas do driver, além dos sinais de clock e reset.

  Observações:
  - A lógica de 6 bits para cada display segue o formato:
    [bit de ligado][4 bits de dado][bit de dois pontos].
  - Este módulo é projetado para ser utilizado em uma placa Nexys A7.
*/


module dm 
(
  input rst, clk,
  input[2:0] prog, 
  input[1:0] modulo,
  input[15:0] data_2,
  output[7:0] an, dec_ddp
);

  wire[5:0] d1, d2, d3, d4, d5, d6, d7, d8;

  /*
    >> LÓGICA DE 6 BITS DO DISPLAY <<
    Primeiro bit do display sinaliza que ele está ligado
    Os quatro bits intermediários são o dado a ser exibido
    O último bit são os dois pontos adjacentes ao display

    Exemplo:
    d1: ligado, 4 bits de dado, sem dois pontos
  */

  assign d8 = {1'b1, data_2[3:0], 1'b0};
  assign d7 = {1'b1, data_2[7:4], 1'b0};
  assign d6 = {1'b1, data_2[11:8], 1'b0};
  assign d5 = {1'b1, data_2[15:12], 1'b0};

  assign d4 = 6'b0;

  // Módulo
  assign d3 = {1'b1, 2'b0, modulo, 1'b0};

  assign d2 = 6'b0;

  // Prog
  assign d1 = {1'b1, 1'b0, prog, 1'b0};

  // Istanciação do Display Driver
  dspl_drv_NexysA7 display_driver (
    .clock(clk),
    .reset(rst),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .d4(d4),
    .d5(d5),
    .d6(d6),
    .d7(d7),
    .d8(d8),
    .an(an),
    .dec_cat(dec_ddp)
  );

endmodule

