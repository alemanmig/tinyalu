## Especificaciones

Este ejercicio pertenece al libro UVM primer, que corresponde a una ALU. 

## Testbench

EL archivo del testbench contiene tres partes:
    - Estimulos 
    - Self-checking 
    - coverage

Por su parte, la organizacion de los archivos es la siguiente:
    - vif_if.sv 
        - Aqui se escriben las señales internas utilizadas para el dut
    - test.sv
        - Aqui se encuentran las funciones que realizara la simulacion (tasks)
    - tb.sv
        - Aqui se encuentra la instanciacion del DUT y el bind con el archivo de sva
    