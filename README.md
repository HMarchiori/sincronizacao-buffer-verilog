# Sincronização e Uso de Buffers com Verilog

Este projeto implementa um sistema modular com comunicação entre diferentes módulos, incluindo um gerador de Fibonacci, um contador de Timer, um controlador baseado em uma máquina de estados, e um módulo wrapper com buffer circular. O sistema é implementado em Verilog e simulado através de um Testbench.

## Módulos do Projeto

### 1. **Timer**
O módulo `timer` é responsável por gerar números crescentes, implementando um contador de 16 bits. Ele é habilitado com o sinal `t_en`, e a cada ciclo de clock, o contador é incrementado. Quando `rst` é ativado, o contador é resetado.

#### Entradas:
- `rst`: Sinal de reset ativo alto.
- `clk`: Clock de referência.
- `t_en`: Enable do contador.

#### Saídas:
- `t_out`: Saída de 16 bits com o valor atual do contador.
- `t_valid`: Sinal que indica se o valor de `t_out` é válido.

### 2. **Fibonacci**
O módulo `fibonacci` gera números de Fibonacci, com um comportamento semelhante ao do `timer`, mas com a sequência de Fibonacci.

#### Entradas:
- `rst`: Sinal de reset ativo alto.
- `clk`: Clock de referência.
- `f_en`: Enable para iniciar o cálculo da sequência de Fibonacci.

#### Saídas:
- `f_out`: Saída de 16 bits com o valor atual da sequência de Fibonacci.
- `f_valid`: Sinal que indica se o valor de `f_out` é válido.

### 3. **Módulo Wrapper**
O módulo `wrapper` gerencia um buffer circular de 8 posições e controla a comunicação entre o gerador de Fibonacci e o contador Timer, escrevendo dados no buffer e realizando a leitura dos dados com uma frequência mais baixa.

#### Entradas:
- `rst`: Sinal de reset ativo alto.
- `clk_1`: Clock rápido de 10 Hz.
- `clk_2`: Clock lento configurável.
- `data_1_en`: Sinal que indica que o dado de entrada é válido.
- `data_1`: Dado de entrada proveniente do gerador de Fibonacci ou Timer.

#### Saídas:
- `buffer_full`: Indica se o buffer está cheio.
- `buffer_empty`: Indica se o buffer está vazio.
- `data_valid_2`: Indica se o dado da saída `data_2` é válido.
- `data_2`: Dado de 16 bits da saída.

### 4. **Máquina de Estados**
O módulo `top` controla a comunicação entre os módulos de Fibonacci e Timer utilizando uma máquina de estados. Ele alterna entre diferentes estados, como comunicação com o gerador de Fibonacci (`S_COMM_F`), comunicação com o Timer (`S_COMM_T`), espera (`S_WAIT_F`, `S_WAIT_T`), e buffer vazio (`S_BUF_EMPTY`).

#### Entradas:
- `rst`: Sinal de reset ativo alto.
- `clk`: Clock de referência.
- `start_f`: Sinal para iniciar a comunicação com o gerador de Fibonacci.
- `start_t`: Sinal para iniciar a comunicação com o Timer.
- `stop_f_t`: Sinal para parar a comunicação.
- `update`: Sinal de atualização para o divisor do clock.
- `prog[2:0]`: Seleção do divisor do clock.

#### Saídas:
- `led[5:0]`: LEDs que mostram o estado atual do sistema.
- `an`: Sinal de controle dos displays.
- `dec_ddp`: Dado a ser exibido nos displays.
- `parity`: Paridade do dado de saída.

## Testbench

O Testbench foi implementado para simular o comportamento do módulo `timer`. Ele gera o sinal de clock e controla o reset e o habilitador do contador.

### Testbench `timer_tb`

#### Entradas:
- `rst`: Sinal de reset ativo alto.
- `clk`: Clock de referência.
- `t_en`: Enable do contador.

#### Saídas:
- `t_valid`: Indica se a saída do contador é válida.
- `t_out`: Saída de 16 bits com o valor do contador.

## Estrutura do Projeto

A estrutura do projeto é a seguinte:

/src
|– timer.v         // Módulo Timer
|– fibonacci.v     // Módulo Fibonacci
|– wrapper.v       // Módulo Wrapper
|– top.v           // Módulo Top com Máquina de Estados
|– edge_detector.v // Módulo de Detecção de Bordas
|– dcm.v           // Módulo de Controle de Clock (DCM)
|– dm.v            // Módulo de Controlador de Displays
|– testbench.v     // Testbench do Timer

## Como Rodar

1. Clone o repositório ou faça o download dos arquivos Verilog.
2. Compile os arquivos Verilog utilizando uma ferramenta de simulação como o ModelSim, Vivado, ou outra de sua preferência.
3. Execute a simulação do Testbench `timer_tb` para verificar o comportamento do módulo `timer`.
4. Ajuste os parâmetros e os módulos conforme necessário para seu ambiente.

