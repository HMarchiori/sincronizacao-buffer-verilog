/*
  Módulo: top

  Descrição:
  Este módulo implementa uma máquina de estados finita (FSM) para controlar a comunicação
  entre diferentes componentes, incluindo um gerador de Fibonacci, um temporizador (timer),
  e um buffer de dados. Ele também gerencia a geração de sinais de relógio (clock) e a
  exibição de estados através de LEDs.

  Entradas:
    - rst: Sinal de reset.
    - clk: Sinal de clock principal.
    - start_f: Sinal para iniciar a comunicação com o gerador de Fibonacci.
    - start_t: Sinal para iniciar a comunicação com o gerador de Timer.
    - stop_f_t: Sinal para interromper a comunicação.
    - update: Sinal para atualizar a configuração do clock.
    - prog: Configuração de programação para o módulo DCM.

  Saídas:
    - led: Indicação do estado atual da FSM através de LEDs.
    - an: Controle dos displays de 7 segmentos.
    - dec_ddp: Dados decodificados para os displays de 7 segmentos.
    - parity: Paridade calculada dos dados do buffer.

  Componentes Internos:
    - Máquina de Estados:
      - `S_IDLE`: Estado inicial.
      - `S_COMM_F`: Comunicação com o gerador de Fibonacci.
      - `S_WAIT_F`: Espera para comunicação com o gerador de Fibonacci.
      - `S_COMM_T`: Comunicação com o gerador de Timer.
      - `S_WAIT_T`: Espera para comunicação com o gerador de Timer.
      - `S_BUF_EMPTY`: Buffer vazio, aguardando novo ciclo de comunicação.

    - Detecção de borda:
      - start_f_rising: Detecção de borda de subida para o sinal start_f.
      - start_t_rising: Detecção de borda de subida para o sinal start_t.
      - stop_rising: Detecção de borda de subida para o sinal stop_f_t.
      - update_rising: Detecção de borda de subida para o sinal update.

    - Módulos Instanciados:
      - fibonacci: Gerador de números de Fibonacci.
      - timer: Temporizador.
      - dcm: Gerador de clocks com configuração programável.
      - dm: Módulo de exibição de dados.
      - wrapper: Gerenciador de buffer de dados.

  Funcionamento:
  A FSM controla os estados de comunicação com os módulos de Fibonacci e Timer, gerenciando
  o fluxo de dados para o buffer. Os LEDs indicam o estado atual da FSM, enquanto os displays
  de 7 segmentos exibem os dados processados. O módulo DCM ajusta os clocks conforme a
  configuração fornecida.

  Observação:
  Este módulo utiliza definições de estados (`define) para facilitar a leitura e manutenção
  do código.
*/


`define S_IDLE      3'b000
`define S_COMM_F    3'b001
`define S_WAIT_F    3'b010
`define S_COMM_T    3'b011
`define S_WAIT_T    3'b100
`define S_BUF_EMPTY 3'b101

module top (
  input rst, clk, start_f, start_t, stop_f_t, update,
  input [2:0] prog,
  output [5:0] led,
  output [7:0] an, dec_ddp,
  output parity
);

  reg [2:0] EA, PE;

  // Edge Detectors
  wire start_f_rising, start_t_rising, stop_rising, update_rising;
  edge_detector start_f_ed (.clock(clk), .reset(rst), .din(start_f), .rising(start_f_rising));
  edge_detector start_t_ed (.clock(clk), .reset(rst), .din(start_t), .rising(start_t_rising));
  edge_detector stop_f_t_ed (.clock(clk), .reset(rst), .din(stop_f_t), .rising(stop_rising));
  edge_detector update_ed (.clock(clk), .reset(rst), .din(update), .rising(update_rising));


      // Wires do Clock
  wire clk1, clk2;
  wire [2:0] prog_out;
  wire [1:0] modulee;

  // Wires do Fibonacci e Timer
  wire f_en, t_en, f_valid, t_valid;
  wire [15:0] f_out, t_out;

  // Wires do Wrapper
  wire buffer_full, buffer_empty, data_valid_2, data_1_en;
  wire [15:0] data_2, data_1;

  // Assigns dos Wires Lógicos
  assign f_en = (EA == `S_COMM_F && !buffer_full);
  assign t_en = (EA == `S_COMM_T && !buffer_full);
  assign modulee = (EA == `S_COMM_F || EA == `S_WAIT_F) ? 2'b01 : 
                   (EA == `S_COMM_T || EA == `S_WAIT_T) ? 2'b10 : 2'b00;
  assign data_1 = (EA == `S_COMM_F) ? f_out : (EA == `S_COMM_T) ? t_out : 16'd0;
  assign data_1_en = (f_en || t_en);
  assign parity = ^data_2; 

  // Máquina de Estados
  always @(posedge clk or posedge rst) begin  
    if (rst) begin
      EA <= `S_IDLE;
    end else begin
      EA <= PE;
    end
  end


/*

  >> MÁQUINA DE ESTADOS <<

    Estados:
        `S_IDLE: Estado inicial
        `S_COMM_F: Comunicação com o gerador de Fibonacci
        `S_WAIT_F: Espera para comunicação com o gerador de Fibonacci
        `S_COMM_T: Comunicação com o gerador de Timer
        `S_WAIT_T: Espera para comunicação com o gerador de Timer
        `S_BUF_EMPTY: Buffer vazio, aguardando novo ciclo de comunicação
*/

  always @(*) begin
    case (EA)
      `S_IDLE: begin
        if (start_f_rising) PE = `S_COMM_F;
        else if (start_t_rising) PE = `S_COMM_T;
        else PE = `S_IDLE;
      end

      `S_COMM_F: begin
        if (buffer_full) PE = `S_WAIT_F;
        else if (stop_rising) PE = `S_BUF_EMPTY;
        else PE = `S_COMM_F;
      end

      `S_WAIT_F: begin
        if (!buffer_full) PE = `S_COMM_F;
        else if (stop_rising) PE = `S_BUF_EMPTY;
        else PE = `S_WAIT_F;
      end

      `S_COMM_T: begin
        if (buffer_full) PE = `S_WAIT_T;
        else if (stop_rising) PE = `S_BUF_EMPTY;
        else PE = `S_COMM_T;
      end

      `S_WAIT_T: begin
        if (!buffer_full) PE = `S_COMM_T;
        else if (stop_rising) PE = `S_BUF_EMPTY;
        else PE = `S_WAIT_T;
      end

      `S_BUF_EMPTY: begin
        if (buffer_empty && !data_valid_2) PE = `S_IDLE;
        else PE = `S_BUF_EMPTY;
      end
      
      default: PE = `S_IDLE;
    endcase
  end

  // LEDs de Estado
  assign led = (EA == `S_IDLE)      ? 6'b000001 :
               (EA == `S_COMM_F)    ? 6'b000010 :
               (EA == `S_WAIT_F)    ? 6'b000100 :
               (EA == `S_COMM_T)    ? 6'b001000 :
               (EA == `S_WAIT_T)    ? 6'b010000 :
               (EA == `S_BUF_EMPTY) ? 6'b100000 : 6'b000000;


  // Instanciação dos Módulos
  fibonacci f1 (.rst(rst), .clk(clk1), .f_en(f_en), .f_valid(f_valid), .f_out(f_out));
  timer t1 (.rst(rst), .clk(clk1), .t_en(t_en), .t_valid(t_valid), .t_out(t_out));
  dcm d1 (.rst(rst), .clk(clk), .prog_in(prog), .update(update_rising), .clk_1(clk1), .clk_2(clk2), .prog_out(prog_out));
  dm m1 (.rst(rst), .clk(clk), .prog(prog_out), .modulo(modulee), .data_2(data_2), .an(an), .dec_ddp(dec_ddp));
  wrapper w1 (.rst(rst), .clk_1(clk1), .clk_2(clk2), .data_1_en(data_1_en), .data_1(data_1), 
              .buffer_full(buffer_full), .buffer_empty(buffer_empty), .data_valid_2(data_valid_2), .data_2(data_2));

endmodule
