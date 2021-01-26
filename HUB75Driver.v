module HUB75Driver(output [7:0] JB, JC, output [15:0] led, input clk);

  reg A0, A1, A2, A3, A4, BL, CK, LA, R0, G0, B0, R1, G1, B1, X0, X1;

  assign A0 = address[0];
  assign A1 = address[1];
  assign A2 = address[2];
  assign A3 = 0;
  assign A4 = 0;

  assign JB = {R0, G0, B0, X0, R1, G1, B1, X1};
  assign JC = {A0, A1, A2, A3, BL, LA, CK, A4};


  reg [29:0] clockDivider = 0;
  reg clock = 0;

  always @(posedge clk)
  begin
    clockDivider <= clockDivider + 1;
    if(clockDivider == 500000)
    begin
      clock <= ~clock;
      clockDivider <= 0;
    end
  end

  reg [9:0] clockCounter;
  assign led = clockDivider[29:14];
  reg [2:0] address = 3'b111;
  wire [3:0] addressHigh;
  assign addressHigh = { 1'b1, address[2:0] }; // Will always move lock-step with the other
  reg [4:0] columnCounter;
  reg draw = 0;

  wire pixelClock;
  
  // NOT PERMANENT DATA. TEST DATA WHILE TIMING BUILT
  reg [31:0]red[15:0];
  reg [31:0]grn[15:0];
  reg [31:0]blu[15:0];
  assign red[0] = 32'b01010101_01010101_01010101_01010101;
  assign red[1] = 32'b01010101_01010101_01010101_01010101;
  assign red[2] = 32'b01010101_01010101_01010101_01010101;
  assign red[3] = 32'b01010101_01010101_01010101_01010101;
  assign red[4] = 32'b00110011_00110011_00110011_00110011;
  assign red[5] = 32'b00110011_00110011_00110011_00110011;
  assign red[6] = 32'b00110011_00110011_00110011_00110011;
  assign red[7] = 32'b00110011_00110011_00110011_00110011;
  assign red[8] = 32'b10001111_00001111_00001111_00001111;
  assign red[9] = 32'b00001111_00001111_00001111_00001111;
  assign red[10] = 32'b00001111_00001111_00001111_00001111;
  assign red[11] = 32'b00001111_00001111_00001111_00001111;
  assign red[12] = 32'b00000000_11111111_00000000_11111111;
  assign red[13] = 32'b00000000_11111111_00000000_11111111;
  assign red[14] = 32'b00000000_11111111_00000000_11111111;
  assign red[15] = 32'b00000000_11111111_00000000_11111111;
  assign grn[0] = 32'b00110011_00110011_00110011_00110011;
  assign grn[1] = 32'b00110011_00110011_00110011_00110011;
  assign grn[2] = 32'b00110011_00110011_00110011_00110011;
  assign grn[3] = 32'b00110011_00110011_00110011_00110011;
  assign grn[4] = 32'b00001111_00001111_00001111_00001111;
  assign grn[5] = 32'b00001111_00001111_00001111_00001111;
  assign grn[6] = 32'b00001111_00001111_00001111_00001111;
  assign grn[7] = 32'b00001111_00001111_00001111_00001111;
  assign grn[8] = 32'b00000000_11111111_00000000_11111111;
  assign grn[9] = 32'b00000000_11111111_00000000_11111111;
  assign grn[10] = 32'b00000000_11111111_00000000_11111111;
  assign grn[11] = 32'b00000000_11111111_00000000_11111111;
  assign grn[12] = 32'b01010101_01010101_01010101_01010101;
  assign grn[13] = 32'b01010101_01010101_01010101_01010101;
  assign grn[14] = 32'b01010101_01010101_01010101_01010101;
  assign grn[15] = 32'b01010101_01010101_01010101_01010101;
  assign blu[0] = 32'b00001111_00001111_00001111_00001111;
  assign blu[1] = 32'b00001111_00001111_00001111_00001111;
  assign blu[2] = 32'b00001111_00001111_00001111_00001111;
  assign blu[3] = 32'b00001111_00001111_00001111_00001111;
  assign blu[4] = 32'b00000000_11111111_00000000_11111111;
  assign blu[5] = 32'b00000000_11111111_00000000_11111111;
  assign blu[6] = 32'b00000000_11111111_00000000_11111111;
  assign blu[7] = 32'b00000000_11111111_00000000_11111111;
  assign blu[8] = 32'b01010101_01010101_01010101_01010101;
  assign blu[9] = 32'b01010101_01010101_01010101_01010101;
  assign blu[10] = 32'b01010101_01010101_01010101_01010101;
  assign blu[11] = 32'b01010101_01010101_01010101_01010101;
  assign blu[12] = 32'b00110011_00110011_00110011_00110011;
  assign blu[13] = 32'b00110011_00110011_00110011_00110011;
  assign blu[14] = 32'b00110011_00110011_00110011_00110011;
  assign blu[15] = 32'b00110011_00110011_00110011_00110011;
  

  initial
  begin
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

  // States
  // Blank High
  // increment address
  // Shifting out data loop
  // Latch high
  // Latch low
  // Blank Low
  // Wait for reset

  reg [4:0] pixelCount;

  always @(posedge clock)
  begin
    clockCounter <= clockCounter + 1;
  end

  always @(clockCounter)
  begin
    case(clockCounter)
      0: BL <= 1;
      1: address <= address + 1;
      2:
      begin
        draw <= 1;
        pixelCount <= 31;
      end
      35: draw <= 0;
      40: LA <= 1;
      41: LA <= 0;
      42: BL <= 0;
    endcase
  end

  always @(posedge clock)
  begin
    if(draw)
    begin
      CK <= 0;
      R0 <= red[address][pixelCount];
      R1 <= red[addressHigh][pixelCount];
      G0 <= red[address][pixelCount];
      G1 <= red[addressHigh][pixelCount];
      B0 <= red[address][pixelCount];
      B1 <= red[addressHigh][pixelCount];
    end
  end

  always @(negedge clock)
  begin
    if(draw)
    begin
      CK <= 1;
      pixelCount <= pixelCount - 1;
    end
  end

endmodule