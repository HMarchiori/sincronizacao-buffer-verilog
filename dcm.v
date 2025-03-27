/*
  Módulo: dcm (Digital Clock Manager)

  Descrição:
  Este módulo implementa um gerador de clocks com duas saídas de clock configuráveis.
  Ele utiliza dois contadores para gerar clocks com frequências diferentes a partir de
  um clock de entrada. A frequência do clock lento pode ser configurada dinamicamente
  através do sinal `prog_in` e atualizada com o sinal `update`.

  Entradas:
    - rst (input): Sinal de reset. Quando em nível alto, reinicia os contadores e os sinais de saída.
    - clk (input): Clock de entrada principal utilizado para gerar os clocks de saída.
    - prog_in (input [2:0]): Sinal de 3 bits que define o divisor do clock lento.
    - update (input): Sinal que, quando em nível alto, atualiza o divisor do clock lento
                      com base no valor de `prog_in`.

  Saídas:
    - clk_1 (output reg): Clock rápido gerado com frequência fixa de 10 Hz.
    - clk_2 (output reg): Clock lento gerado com frequência configurável.
    - prog_out (output reg [2:0]): Valor atual do divisor configurado para o clock lento.

  Funcionamento:
    1. Geração do Clock Rápido (`clk_1`):
       - Utiliza um contador (`counter_fast`) para dividir o clock de entrada (`clk`) e gerar
         um clock com frequência fixa de 10 Hz.

    2. Configuração do Divisor do Clock Lento:
       - O divisor do clock lento é selecionado dinamicamente com base no valor de `prog_in`.
       - Os valores possíveis para o divisor correspondem a frequências de saída que variam
         de 10 Hz a 0.1 Hz.

    3. Geração do Clock Lento (`clk_2`):
       - Utiliza um contador (`counter_slow`) para dividir o clock de entrada (`clk`) com base
         no divisor configurado.
       - O divisor pode ser atualizado dinamicamente através do sinal `update`.

  Observações:
    - O módulo utiliza dois contadores independentes para gerar os clocks de saída.
    - O sinal `update` permite alterar a frequência do clock lento sem reiniciar o módulo.
    - O valor atual do divisor configurado é refletido na saída `prog_out`.

  Frequências do Clock Lento (baseadas em `prog_in`):
    - 3'b000: 10 Hz
    - 3'b001: 5 Hz
    - 3'b010: 2.5 Hz
    - 3'b011: 1.25 Hz
    - 3'b100: 0.8 Hz
    - 3'b101: 0.4 Hz
    - 3'b110: 0.2 Hz
    - 3'b111: 0.1 Hz
*/

module dcm (
  input rst,              
  input clk,             
  input [2:0] prog_in,    
  input update,           
  output reg clk_1,      
  output reg clk_2,      
  output reg [2:0] prog_out 
);

  reg [22:0] counter_fast;  
  reg [30:0] counter_slow;  
  reg [30:0] slow_divider;  

  // Geração do clock rápido (10 Hz)
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter_fast <= 0;
      clk_1 <= 0;
    end else begin
      if (counter_fast == 5000000 - 1) begin // Divisor para 10 Hz
        clk_1 <= ~clk_1;
        counter_fast <= 0;
      end else begin
        counter_fast <= counter_fast + 1;
      end
    end
  end

  // Seleção do divisor do clock lento com base em prog_in
  always @* begin
    case (prog_in)
      3'b000: slow_divider = 5000000;     // 10 Hz
      3'b001: slow_divider = 10000000;    // 5 Hz
      3'b010: slow_divider = 20000000;    // 2.5 Hz
      3'b011: slow_divider = 40000000;    // 1.25 Hz
      3'b100: slow_divider = 62500000;    // 0.8 Hz
      3'b101: slow_divider = 125000000;   // 0.4 Hz
      3'b110: slow_divider = 250000000;   // 0.2 Hz
      3'b111: slow_divider = 500000000;   // 0.1 Hz (78.125 mHz)
      default: slow_divider = 5000000;    // 10 Hz
    endcase
  end

  // Geração do clock lento configurável
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter_slow <= 0;
      clk_2 <= 0;
      prog_out <= 3'b000;
    end else if (update) begin
      prog_out <= prog_in;  
      counter_slow <= 0;
      clk_2 <= 0;

    end else if (counter_slow == slow_divider - 1) begin
      clk_2 <= ~clk_2;
      counter_slow <= 0;
    end else begin
      counter_slow <= counter_slow + 1;
    end
  end

endmodule
