module HUB75Driver(output [7:0] JB, JC, input clk);

  reg A0, A1, A2, A3, A4, BL, CK, LA, R0, G0, B0, R1, G1, B1, X0, X1;

  assign JB = {R0, G0, B0, X0, R1, G1, B1, X1};
  assign JC = {A0, A1, A2, A3, BL, LA, CK, A4};

  reg [10:0] clockCounter;

  wire pixelClock;
  
  initial
  begin
    A0 <= 0;
    A1 <= 0;
    A2 <= 0;
    A3 <= 0;
    A4 <= 0;
    BL <= 0;
    LA <= 0;
    CK <= 0;

    R0 <= 0;
    R1 <= 1;
    G0 <= 0;
    G1 <= 1;
    B0 <= 0;
    B1 <= 1;
    X0 <= 0;
    X1 <= 0;
    clockCounter <= 0;
  end

  always @(posedge clk)
  begin
    // clockCounter <= clockCounter + 1;
    // if (clockCounter == 31)
    // begin
    //   LA <= 1;
    //   clockCounter <= 0;
    // end
    // else
    // begin
    //   LA <= 0;
    // end
  end

endmodule