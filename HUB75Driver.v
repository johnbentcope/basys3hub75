module HUB75Driver(output [7:0] JB, JC, output [15:0] led, input clk);

  reg BL, CK, LA, R0, G0, B0, R1, G1, B1, X0, X1;
  wire A0, A1, A2, A3, A4;

  assign JB = {X1, B1, G1, R1, X0, B0, G0, R0};
  assign JC = {A4, CK, LA, BL, A3, A2, A1, A0};


  reg [29:0] clockDivider = 0;
  reg clock = 0;

  always @(posedge clk)
  begin
    clockDivider <= clockDivider + 1;
    if(clockDivider == 50000)
    begin
      clock <= ~clock;
      clockDivider <= 0;
    end
  end

  reg [9:0] clockCounter;
  assign led[7:0] = JB;
  assign led[15:8] = JC;
  reg [2:0] address = 3'b111;
  wire [3:0] addressHigh;
  assign addressHigh = { 1'b1, address[2:0] }; // Will always move lock-step with the other
  reg [4:0] columnCounter;
  reg draw = 0;


  assign A0 = address[0];
  assign A1 = address[1];
  assign A2 = address[2];
  assign A3 = 0;
  assign A4 = 0;

  wire pixelClock;
  
  // NOT PERMANENT DATA. TEST DATA WHILE TIMING BUILT
  reg [31:0]red[15:0];
  reg [31:0]grn[15:0];
  reg [31:0]blu[15:0];
  
  

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
    red[0] <= 32'b01010101_01010101_01010101_01010101;
    red[1] <= 32'b01010101_01010101_01010101_01010101;
    red[2] <= 32'b01010101_01010101_01010101_01010101;
    red[3] <= 32'b01010101_01010101_01010101_01010101;
    red[4] <= 32'b00110011_00110011_00110011_00110011;
    red[5] <= 32'b00110011_00110011_00110011_00110011;
    red[6] <= 32'b00110011_00110011_00110011_00110011;
    red[7] <= 32'b00110011_00110011_00110011_00110011;
    red[8] <= 32'b10001111_00001111_00001111_00001111;
    red[9] <= 32'b00001111_00001111_00001111_00001111;
    red[10] <= 32'b00001111_00001111_00001111_00001111;
    red[11] <= 32'b00001111_00001111_00001111_00001111;
    red[12] <= 32'b00000000_11111111_00000000_11111111;
    red[13] <= 32'b00000000_11111111_00000000_11111111;
    red[14] <= 32'b00000000_11111111_00000000_11111111;
    red[15] <= 32'b00000000_11111111_00000000_11111111;
    grn[0] <= 32'b00110011_00110011_00110011_00110011;
    grn[1] <= 32'b00110011_00110011_00110011_00110011;
    grn[2] <= 32'b00110011_00110011_00110011_00110011;
    grn[3] <= 32'b00110011_00110011_00110011_00110011;
    grn[4] <= 32'b00001111_00001111_00001111_00001111;
    grn[5] <= 32'b00001111_00001111_00001111_00001111;
    grn[6] <= 32'b00001111_00001111_00001111_00001111;
    grn[7] <= 32'b00001111_00001111_00001111_00001111;
    grn[8] <= 32'b00000000_11111111_00000000_11111111;
    grn[9] <= 32'b00000000_11111111_00000000_11111111;
    grn[10] <= 32'b00000000_11111111_00000000_11111111;
    grn[11] <= 32'b00000000_11111111_00000000_11111111;
    grn[12] <= 32'b01010101_01010101_01010101_01010101;
    grn[13] <= 32'b01010101_01010101_01010101_01010101;
    grn[14] <= 32'b01010101_01010101_01010101_01010101;
    grn[15] <= 32'b01010101_01010101_01010101_01010101;
    blu[0] <= 32'b00001111_00001111_00001111_00001111;
    blu[1] <= 32'b00001111_00001111_00001111_00001111;
    blu[2] <= 32'b00001111_00001111_00001111_00001111;
    blu[3] <= 32'b00001111_00001111_00001111_00001111;
    blu[4] <= 32'b00000000_11111111_00000000_11111111;
    blu[5] <= 32'b00000000_11111111_00000000_11111111;
    blu[6] <= 32'b00000000_11111111_00000000_11111111;
    blu[7] <= 32'b00000000_11111111_00000000_11111111;
    blu[8] <= 32'b01010101_01010101_01010101_01010101;
    blu[9] <= 32'b01010101_01010101_01010101_01010101;
    blu[10] <= 32'b01010101_01010101_01010101_01010101;
    blu[11] <= 32'b01010101_01010101_01010101_01010101;
    blu[12] <= 32'b00110011_00110011_00110011_00110011;
    blu[13] <= 32'b00110011_00110011_00110011_00110011;
    blu[14] <= 32'b00110011_00110011_00110011_00110011;
    blu[15] <= 32'b00110011_00110011_00110011_00110011;
  end

  // States
  // 0: Wait for reset
  // 1: Blank High
  // 2: Increment address & Latch high
  // 3: Latch low
  // 4: Blank Low & begin data transmission

  // While screen is displaying data from address 0,
  //   shift out data for address 1
  // Then when needed, push new address, latch data,
  //   and start sending new data immediately

  localparam STATE_Initial = 3'd0;
             STATE_1 = 3'd1;
             STATE_2 = 3'd2;
             STATE_3 = 3'd3;
             STATE_4 = 3'd4;
             STATE_5_VOID = 3'd5;
             STATE_6_VOID = 3'd6;
             STATE_7_VOID = 3'd7;

  reg [2:0] CurrentState;

  reg [4:0] pixelCount;

  always @(posedge clock)
  begin
    clockCounter <= clockCounter + 1;
  end

  always @(clockCounter)
  begin
    case(clockCounter)
      0: BL <= 0;
      1: address <= address + 1;
      2:
      begin
        draw <= 1;
        pixelCount <= 31;
      end
      35: draw <= 0;
      40: LA <= 1;
      41: LA <= 0;
      42: BL <= 1;
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