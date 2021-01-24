module HUB75Driver_tb();
  reg clk_t;
  wire [7:0] JB_t, JC_t;

  HUB75Driver HUB75Driver01(
    .JB(JB_t),
    .JC(JC_t),
    .clk(clk_t)
  );

  initial
  begin
    $dumpfile("HUB75Driver_tb.vcd");
    $dumpvars(0, HUB75Driver_tb);
    clk_t <= 0;
  end

  always #5 clk_t <= ~clk_t;

  always #1000 $finish;

endmodule