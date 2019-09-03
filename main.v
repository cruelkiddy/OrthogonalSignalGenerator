module pllTest(
    clkin,
    key3,
    key2,
    clkout,
    clkoutl,
    datar,
    datal,
    nullr,
    nulll,
    test,
    led1,
    led2,
    led3
);
    input clkin;                                                  ///< Clkin 50 MHz
    input key3;                                                   ///< Low Valid
    input key2;
    output reg led1;
    output reg led2;
    output reg led3;
    output reg clkout;                                            ///< Clk for DAC
    output clkoutl;                                               ///< Clk for DACl
    output test;                                                  ///< Test Port
    output[11:0] datar;                                           ///< data right
    output[11:0] datal;                                           ///< data left

    output reg nullr;                                              ///< Unknow Pin
    output reg nulll;                                              ///< Unknow Pin

    reg[15:0] originCounter;
    reg[31:0] globalCounter;
    reg[25:0] key3Counter;
    reg[25:0] key2Counter;

    reg[11:0] romr_addr;                                           ///< ROM input address right
    reg[11:0] roml_addr;

    reg[11:0] sweep;
    reg sweepMode;

    wire internal_clk;                                            ///< 500MHz clk
    reg romclk;

    pll pll_inst(
        .c0(internal_clk),
        .inclk0(clkin),
        //.c1(clk100M)
    );

    rom1_ip rom_ip_inst(
        .clock(romclk),
        .address(romr_addr),
        .q(datar)
    );

    LeftRomIp romLeft_ip_inst(
        .clock(romclk),
        .address(roml_addr),
        .q(datal)
    );

    initial begin
        nullr <= 0;
        nulll <= 0;
        originCounter <= 0;
        romr_addr <= 0;
        roml_addr <= 0;
        sweep <= 12'd99;
        romclk <= 1'b0;
        sweepMode <= 1'b0;
    end

    always @(posedge internal_clk) begin                           ///< Extreme Configuration , Update Rate = 100MHz

        if(originCounter == 16'd0) begin

            if(romr_addr == sweep)
                romr_addr <= sweep - 12'd99;
            else
                romr_addr <= romr_addr + 1'b1;

            if(roml_addr == sweep)
                roml_addr <= sweep - 12'd99;
            else
                roml_addr <= roml_addr + 1'b1;

            // if(romr_addr == 12'd999)
            //     romr_addr <= 12'd900;
            // else
            //     romr_addr <= romr_addr + 1'b1;

            // if(roml_addr == 12'd999)
            //     roml_addr <= 12'd900;
            // else
            //     roml_addr <= roml_addr + 1'b1;

            originCounter <= originCounter + 1'b1;
        end

        else if(originCounter == 16'd1) begin
            romclk <= 1'b1;
            originCounter <= originCounter + 1'b1;
        end

        else if(originCounter == 16'd2) begin
            clkout <= 1'b1;
            originCounter <= originCounter + 1'b1;
        end

        else if(originCounter == 16'd4) begin
            clkout <= 1'b0;
            originCounter <= 0;      
            romclk <= 1'b0;    
        end

        else
            originCounter <= originCounter + 1'b1;
    end



    ///< I wrote down follwing code, then the code above works. So strange.
    always @(posedge clkin) begin
        globalCounter <= globalCounter + 1'b1;
        if(globalCounter == 32'd25000000) begin
            led1 <= !led1;
            if(sweepMode) 
                if(sweep == 12'd3999)
                    sweep <= 12'd99;
                else
                    sweep <= sweep + 12'd100;
            else
                if(!key3) begin                             ///< Key 3, Frequency ++
                    led3 <= !led3;
                    if(sweep == 12'd3999)
                        sweep <= 12'd99;
                    else
                        sweep <= sweep + 12'd100;
                end

            globalCounter <= 0;
        end
    end

///<         Key2 Sweep Mode 
    always @(posedge clkin) begin
        if(key2Counter == 25'd25000000) begin
            key2Counter <= 25'd0;
            if(!key2) begin                                      ///< Low Valid
                led2 <= !led2;
                sweepMode <= !sweepMode;
            end
        end
        else
            key2Counter <= key2Counter + 25'b1;
    end

    assign test = clkout;
    assign clkoutl = clkout;

endmodule // 

