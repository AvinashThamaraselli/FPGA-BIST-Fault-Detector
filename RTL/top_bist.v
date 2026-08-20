module top_bist (
    input  wire       clk,
    input  wire       btn0,
    input  wire [15:0] sw,

    output reg        lcd_rs,
    output reg        lcd_e,
    output reg [7:0]  data
);

wire [7:0] switch_data = sw[7:0];
wire [2:0] operation   = sw[12:10];
wire       sa0_en      = sw[2];
wire       sa1_en      = sw[3];

reg btn_ff1  = 1'b0;
reg btn_ff2  = 1'b0;
reg btn_last = 1'b0;

always @(posedge clk) begin
    btn_ff1  <= btn0;
    btn_ff2  <= btn_ff1;
    btn_last <= btn_ff2;
end

wire btn_rising = btn_ff2 & ~btn_last;

reg [7:0] golden_result;

always @(*) begin
    case (operation)
        3'b000:  golden_result = A_reg & B_reg;
        3'b001:  golden_result = A_reg | B_reg;
        3'b010:  golden_result = A_reg ^ B_reg;
        3'b011:  golden_result = A_reg + B_reg;
        3'b100:  golden_result = A_reg - B_reg;
        3'b101:  golden_result = A_reg << 1;
        3'b110:  golden_result = A_reg >> 1;
        3'b111:  golden_result = ~(A_reg & B_reg);
        default: golden_result = 8'h00;
    endcase
end

reg [7:0] faulty_result;

always @(*) begin
    case ({sa0_en, sa1_en})
        2'b00:   faulty_result = golden_result;
        2'b10:   faulty_result = golden_result & 8'b11111110;
        2'b01:   faulty_result = golden_result | 8'b00000001;
        2'b11:   faulty_result = golden_result ^ 8'b00000001;
        default: faulty_result = golden_result;
    endcase
end

wire fault_detected = (golden_result != faulty_result);

reg [1:0] mode  = 2'd0;
reg [7:0] A_reg = 8'h00;
reg [7:0] B_reg = 8'h00;

always @(posedge clk) begin
    if (btn_rising) begin
        case (mode)
            2'd0: begin
                A_reg <= switch_data;
                mode  <= 2'd1;
            end
            2'd1: begin
                B_reg <= switch_data;
                mode  <= 2'd2;
            end
            2'd2: begin
                mode  <= 2'd0;
            end
            default: mode <= 2'd0;
        endcase
    end
end

function [7:0] hex_ascii;
    input [3:0] val;
    begin
        case(val)
            4'h0: hex_ascii = "0"; 4'h1: hex_ascii = "1";
            4'h2: hex_ascii = "2"; 4'h3: hex_ascii = "3";
            4'h4: hex_ascii = "4"; 4'h5: hex_ascii = "5";
            4'h6: hex_ascii = "6"; 4'h7: hex_ascii = "7";
            4'h8: hex_ascii = "8"; 4'h9: hex_ascii = "9";
            4'hA: hex_ascii = "A"; 4'hB: hex_ascii = "B";
            4'hC: hex_ascii = "C"; 4'hD: hex_ascii = "D";
            4'hE: hex_ascii = "E"; 4'hF: hex_ascii = "F";
            default: hex_ascii = "0";
        endcase
    end
endfunction

function [23:0] get_op_name;
    input [2:0] op;
    begin
        case(op)
            3'b000:  get_op_name = "AND";
            3'b001:  get_op_name = "OR ";
            3'b010:  get_op_name = "XOR";
            3'b011:  get_op_name = "ADD";
            3'b100:  get_op_name = "SUB";
            3'b101:  get_op_name = "LSH";
            3'b110:  get_op_name = "RSH";
            3'b111:  get_op_name = "NAND";
            default: get_op_name = "   ";
        endcase
    end
endfunction

function [7:0] line1_char;
    input [4:0] index;
    reg [23:0] op_str;
    begin
        op_str = get_op_name(operation);
        if (mode != 2'd2) begin
            case(index)
                5'd0: line1_char = "A";
                5'd1: line1_char = "=";
                5'd2: line1_char = hex_ascii(A_reg[7:4]);
                5'd3: line1_char = hex_ascii(A_reg[3:0]);
                default: line1_char = " ";
            endcase
        end else begin
            case(index)
                5'd0: line1_char = "R";
                5'd1: line1_char = "=";
                5'd2: line1_char = hex_ascii(faulty_result[7:4]);
                5'd3: line1_char = hex_ascii(faulty_result[3:0]);
                5'd4: line1_char = " ";
                5'd5: line1_char = op_str[23:16];
                5'd6: line1_char = op_str[15:8];
                5'd7: line1_char = op_str[7:0];
                default: line1_char = " ";
            endcase
        end
    end
endfunction

function [7:0] line2_char;
    input [4:0] index;
    begin
        if (mode == 2'd0) begin
            case(index)
                5'd0: line2_char = "P"; 5'd1: line2_char = "R";
                5'd2: line2_char = "E"; 5'd3: line2_char = "S";
                5'd4: line2_char = "S"; 5'd5: line2_char = " ";
                5'd6: line2_char = "B"; 5'd7: line2_char = "T";
                5'd8: line2_char = "N"; 5'd9: line2_char = "0";
                default: line2_char = " ";
            endcase
        end else if (mode == 2'd1) begin
            case(index)
                5'd0: line2_char = "B";
                5'd1: line2_char = "=";
                5'd2: line2_char = hex_ascii(switch_data[7:4]);
                5'd3: line2_char = hex_ascii(switch_data[3:0]);
                default: line2_char = " ";
            endcase
        end else begin
            if (fault_detected) begin
                case(index)
                    5'd0: line2_char = "E"; 5'd1: line2_char = "R";
                    5'd2: line2_char = "R"; 5'd3: line2_char = "O";
                    5'd4: line2_char = "R";
                    default: line2_char = " ";
                endcase
            end else begin
                case(index)
                    5'd0: line2_char = "P"; 5'd1: line2_char = "A";
                    5'd2: line2_char = "S"; 5'd3: line2_char = "S";
                    default: line2_char = " ";
                endcase
            end
        end
    end
endfunction

reg [5:0] us_counter = 6'd0;
reg       us_tick    = 1'b0;

always @(posedge clk) begin
    if (us_counter == 6'd49) begin
        us_counter <= 6'd0;
        us_tick    <= 1'b1;
    end else begin
        us_counter <= us_counter + 1'b1;
        us_tick    <= 1'b0;
    end
end

localparam ST_POWERUP      = 6'd0,
           ST_INIT1        = 6'd1,
           ST_INIT1_H      = 6'd2,
           ST_INIT2        = 6'd3,
           ST_INIT2_H      = 6'd4,
           ST_INIT3        = 6'd5,
           ST_INIT3_H      = 6'd6,
           ST_DISPLAY      = 6'd7,
           ST_DISPLAY_H    = 6'd8,
           ST_CLEAR        = 6'd9,
           ST_CLEAR_H      = 6'd10,
           ST_ENTRY        = 6'd11,
           ST_ENTRY_H      = 6'd12,
           ST_SET_LINE1    = 6'd13,
           ST_SET_LINE1_H  = 6'd14,
           ST_LINE1        = 6'd15,
           ST_LINE1_H      = 6'd16,
           ST_SET_LINE2    = 6'd17,
           ST_SET_LINE2_H  = 6'd18,
           ST_LINE2        = 6'd19,
           ST_LINE2_H      = 6'd20,
           ST_REFRESH_WAIT = 6'd21;

reg [5:0]  lcd_state     = ST_POWERUP;
reg [15:0] delay_counter = 16'd0;
reg [4:0]  char_counter  = 5'd0;

always @(posedge clk) begin
    if (us_tick) begin
        case (lcd_state)
            ST_POWERUP: begin
                lcd_rs <= 1'b0;
                lcd_e  <= 1'b0;
                if (delay_counter >= 16'd20000) begin
                    delay_counter <= 16'd0;
                    data          <= 8'h38;
                    lcd_state     <= ST_INIT1;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_INIT1: begin
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_INIT1_H;
            end

            ST_INIT1_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd5000) begin
                    delay_counter <= 16'd0;
                    data          <= 8'h38;
                    lcd_state     <= ST_INIT2;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_INIT2: begin
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_INIT2_H;
            end

            ST_INIT2_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd200) begin
                    delay_counter <= 16'd0;
                    data          <= 8'h38;
                    lcd_state     <= ST_INIT3;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_INIT3: begin
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_INIT3_H;
            end

            ST_INIT3_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    lcd_state     <= ST_DISPLAY;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_DISPLAY: begin
                data      <= 8'h0C;
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_DISPLAY_H;
            end

            ST_DISPLAY_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    lcd_state     <= ST_CLEAR;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_CLEAR: begin
                data      <= 8'h01;
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_CLEAR_H;
            end

            ST_CLEAR_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd2000) begin
                    delay_counter <= 16'd0;
                    lcd_state     <= ST_ENTRY;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_ENTRY: begin
                data      <= 8'h06;
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_ENTRY_H;
            end

            ST_ENTRY_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    char_counter  <= 5'd0;
                    lcd_state     <= ST_SET_LINE1;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_SET_LINE1: begin
                data      <= 8'h80;
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_SET_LINE1_H;
            end

            ST_SET_LINE1_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    char_counter  <= 5'd0;
                    lcd_state     <= ST_LINE1;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_LINE1: begin
                data      <= line1_char(char_counter);
                lcd_rs    <= 1'b1;
                lcd_e     <= 1'b1;
                lcd_state <= ST_LINE1_H;
            end

            ST_LINE1_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    if (char_counter == 5'd15) begin
                        char_counter <= 5'd0;
                        lcd_state    <= ST_SET_LINE2;
                    end else begin
                        char_counter <= char_counter + 1'b1;
                        lcd_state    <= ST_LINE1;
                    end
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_SET_LINE2: begin
                data      <= 8'hC0;
                lcd_rs    <= 1'b0;
                lcd_e     <= 1'b1;
                lcd_state <= ST_SET_LINE2_H;
            end

            ST_SET_LINE2_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    char_counter  <= 5'd0;
                    lcd_state     <= ST_LINE2;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_LINE2: begin
                data      <= line2_char(char_counter);
                lcd_rs    <= 1'b1;
                lcd_e     <= 1'b1;
                lcd_state <= ST_LINE2_H;
            end

            ST_LINE2_H: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50) begin
                    delay_counter <= 16'd0;
                    if (char_counter == 5'd15) begin
                        char_counter <= 5'd0;
                        lcd_state    <= ST_REFRESH_WAIT;
                    end else begin
                        char_counter <= char_counter + 1'b1;
                        lcd_state    <= ST_LINE2;
                    end
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            ST_REFRESH_WAIT: begin
                lcd_e <= 1'b0;
                if (delay_counter >= 16'd50000) begin
                    delay_counter <= 16'd0;
                    lcd_state     <= ST_SET_LINE1;
                end else begin
                    delay_counter <= delay_counter + 1'b1;
                end
            end

            default: begin
                lcd_rs        <= 1'b0;
                lcd_e         <= 1'b0;
                data          <= 8'h00;
                delay_counter <= 16'd0;
                char_counter  <= 5'd0;
                lcd_state     <= ST_POWERUP;
            end
        endcase
    end
end

endmodule
