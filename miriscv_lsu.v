module miriscv_lsu (
                    input         clk_i,
                    input         arstn_i, // reset of internal registers

                    // core protocol
                    input [31:0]  lsu_addr_i, //
                    input         lsu_we_i, //flag, 1 -- need to write
                    input [2:0]   lsu_size_i, // size of data to proccess
                    input [31:0]  lsu_data_i, // data
                    input         lsu_req_i, // flag, 1 -- need to read
                    output        lsu_stall_req_o, // used as !enable PC
                    output [31:0] lsu_data_o, // data out of memory =

                    // memory protocol
                    input [31:0]  data_rdata_i, // requested data
                    output        data_req_o, // flag, 1 -- apply to memoty
                    output        data_we_o, // flag, request to write
                    output [3:0]  data_be_o, // to what bytes to apply
                    output [31:0] data_addr_o, // adress to apply
                    output [31:0] data_wdata_o // data that will be writed
                    );
