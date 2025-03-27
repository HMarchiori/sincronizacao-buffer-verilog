/*
  Módulo: fibonacci
  Descrição: Este módulo implementa um gerador de números da sequência de Fibonacci.
             A cada ciclo de clock, se habilitado, ele calcula o próximo número da sequência
             e o disponibiliza na saída.

  Entradas:
    - rst (input): Sinal de reset. Quando ativo (nível alto), reinicia os valores da sequência.
    - clk (input): Sinal de clock. Sincroniza as operações do módulo.
    - f_en (input): Sinal de habilitação. Quando ativo (nível alto), permite o cálculo do próximo número.

  Saídas:
    - f_out (output reg [15:0]): Saída que contém o número atual da sequência de Fibonacci.
    - f_valid (output reg): Indica se o valor em `f_out` é válido (1) ou não (0).

  Registros internos:
    - fib1 (reg [15:0]): Armazena o número atual da sequência.
    - fib2 (reg [15:0]): Armazena o próximo número da sequência.
    - next_fib (reg [15:0]): Calcula o próximo número da sequência como a soma de `fib1` e `fib2`.

  Funcionamento:
    - Quando `rst` está ativo, os registros internos são inicializados:
      fib1 = 0, fib2 = 1, f_out = 0, f_valid = 0.
    - Quando `f_en` está ativo, o módulo calcula o próximo número da sequência:
      - `f_out` recebe o valor atual de `fib1`.
      - `f_valid` é ativado para indicar que `f_out` contém um valor válido.
      - `next_fib` é calculado como a soma de `fib1` e `fib2`.
      - Os valores de `fib1` e `fib2` são atualizados para os próximos números da sequência.
    - Quando `f_en` está inativo, `f_valid` é desativado para indicar que `f_out` não contém um valor válido.
*/

module fibonacci (
  input rst,               
  input clk,              
  input f_en,              
  output reg [15:0] f_out,
  output reg f_valid     
);

  reg [15:0] fib1, fib2;
  reg [15:0] next_fib;    

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      fib1 <= 16'd0;       
      fib2 <= 16'd1;         
      f_out <= 16'd0;    
      f_valid <= 1'b0;    
    end else if (f_en) begin
      f_out <= fib1;      
      f_valid <= 1'b1;      

      next_fib = fib1 + fib2; 
      fib1 <= fib2;          
      fib2 <= next_fib;      
    end else begin
      f_valid <= 1'b0;      
    end
  end

endmodule