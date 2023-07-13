// Shourya Trikha (210994)
// Prashant Kumar (210750)

`include"Processor+ALU.v"

module Pro_tb;
reg clk;
integer k;

pro_alu mips (clk);

initial
begin

//printing input array
#10
$display("\n\n-----------------------------INPUT DATA(Unsorted array)------------------------------------\n\n");
for (k=40; k<50; k++)
$display("Mem[%1d] - %1d", k,mips.Mem[k]);

//giving clock inputs
clk = 0;
repeat (1000)
begin
#100 clk = 1; #100 clk = 0;
end

//printing sorted array
$display("\n\n------------------------------OUTPUT DATA(sorted array)----------------------------------\n\n");
for (k=40; k<50; k++)
$display("Mem[%1d] - %1d", k,mips.Mem[k]);

end
endmodule