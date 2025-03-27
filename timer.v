/*
  Módulo: timer

  Descrição:
  Este módulo implementa um temporizador simples que utiliza um contador de 16 bits.
  O contador é incrementado a cada ciclo de clock quando o sinal de habilitação (t_en) está ativo.
  O módulo também fornece um sinal de validade (t_valid) para indicar se a saída do contador (t_out) é válida.

  Entradas:
  - rst: Sinal de reset ativo alto. Quando ativo, reseta o contador e os sinais de saída.
  - clk: Sinal de clock rápido de 10 Hz.
  - t_en: Sinal de habilitação do contador. Quando ativo, permite que o contador incremente.

  Saídas:
  - t_valid: Sinal indicando se a saída (t_out) é válida. Ativo quando t_en está habilitado.
  - t_out: Saída de 16 bits que contém o valor atual do contador.

  Funcionamento:
  - Quando o sinal de reset (rst) está ativo, o contador (count), o sinal de validade (t_valid) e a saída (t_out) são resetados para 0.
  - Quando o sinal de habilitação (t_en) está ativo, o contador é incrementado a cada ciclo de clock, e a saída (t_out) é atualizada com o valor do contador. O sinal t_valid é ativado para indicar que a saída é válida.
  - Quando o sinal de habilitação (t_en) está desativado, o valor da saída (t_out) é mantido, e o sinal t_valid é desativado para indicar que a saída não é válida.
*/


module timer (
    input rst,           // Sinal de reset ativo alto
    input clk,           // Clock rápido de 10 Hz
    input t_en,          // Enable do contador
    output reg t_valid,  // Sinal indicando se a saída é válida
    output reg [15:0] t_out // Saída de 16 bits com o valor do contador
);

reg [15:0] count;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 16'b0;      // Reseta o contador para 0
        t_valid <= 1'b0;     // Reseta t_valid para 0
        t_out <= 16'b0;      // Reseta a saída para 0
    end else if (t_en) begin
        count <= count + 16'b1; // Incrementa o contador
        t_valid <= 1'b1;        // Indica que o valor da saída é válido
        t_out <= count;         // Atualiza t_out com o valor do contador
    end else begin
        t_valid <= 1'b0;        // Indica que a saída não é válida quando t_en está desativado
        t_out <= t_out;         // Mantém o valor atual de t_out
    end
end

endmodule