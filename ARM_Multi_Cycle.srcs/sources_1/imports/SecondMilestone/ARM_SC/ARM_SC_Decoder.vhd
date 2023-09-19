----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer: 	   Carl Betcher
-- 
-- Create Date:    22:20:32 11/16/2016 
-- Design Name:	   ARM Processor Decoder 
-- Module Name:    Decoder - Behavioral 
-- Project Name:   ARM_SingleCycle Processor
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity Decoder is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_ARM : in STD_LOGIC;
           Op : in  STD_LOGIC_VECTOR (1 downto 0);
           Funct : in  STD_LOGIC_VECTOR (5 downto 0);
           Rd : in  STD_LOGIC_VECTOR (3 downto 0); 
           PCS : out  STD_LOGIC; 
           RegW : out  STD_LOGIC;
           MemW : out  STD_LOGIC;
           IRWrite : out  STD_LOGIC;
           NextPC : out  STD_LOGIC;
           AdrSrc : out  STD_LOGIC;
           ResultSrc : out  STD_LOGIC_VECTOR (1 downto 0);
           ALUSrcA : out  STD_LOGIC;
           ALUSrcB : out  STD_LOGIC_vector(1 downto 0);
           ALUControl : out  STD_LOGIC_VECTOR (1 downto 0);
           FlagW : out  STD_LOGIC_VECTOR (1 downto 0);
           ImmSrc : out  STD_LOGIC_VECTOR (1 downto 0);
           RegSrc : out  STD_LOGIC_VECTOR (1 downto 0)
           );
     end;

architecture Behavioral of Decoder is
	signal ALUDecOp : std_logic_vector(5 downto 0);
	signal RegWsig : std_logic;
	signal BranchS : std_logic;
	signal ALUOp : std_logic;	

    type state_type is (Fetch, Decode, MemAdr, MemRead, MemWB, MemWriteS, ExecuteR, ExecuteI, ALUWB, Branch);
    signal state, next_state : state_type;
    
begin

    -- PC LOGIC
	-- PCS = 1 if PC is written by an instruction or branch (B)
	PCS <= '1' when (Rd = x"F" and RegWsig = '1') or BranchS = '1' else '0';
	
	RegW <= RegWsig;
	
    process(clk)
    begin
        if rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    process (Op, Funct, en_ARM, state)
    begin
        next_state <= state;
        RegWsig <= '0';
        MemW <= '0';
        IRWrite <= '0';
        NextPC <= '0';
        ADRSrc <= '0';
        ResultSrc <= "00";
        ALUSrcA <= '0';
        ALUSrcB <= "00";
        BranchS <= '0';
        ALUOp <= '0';
        
        case state is
            when Fetch =>
                AdrSrc <= '0';
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= '0';
                ResultSrc <= "10";
                IRWrite <= '1';
                NextPC <= '1';
                next_state <= Decode;
            when Decode => 
                ResultSrc <= "10";
                if en_ARM = '0' then
                    next_state <= state;
				elsif Op = "01" then
					next_state <= MemAdr;
				elsif Op = "00" and Funct(5) = '0' then
					 next_state <= ExecuteR;
				elsif Op = "00" and Funct(5) = '1' then
					next_state <= ExecuteI;
				elsif Op = "10" then 
					next_state <= Branch;
				end if;
				
				ALUSrcA <= '1';
                ALUSrcB <= "10";
                ALUOp <= '0';
                
            when MemAdr => 
				ALUSrcA <= '0';
                ALUSrcB <= "01";
                ALUOp <= '0';
            	if Funct(0) = '1' then
					next_state <= MemRead;
				elsif Funct(0) = '0' then 
					next_state <= MemWriteS;
				end if;
			when ExecuteR =>
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				ALUOp <= '1';
				next_state <= ALUWB;
			when ExecuteI =>
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= '1';
				next_state <= ALUWB;
			when Branch =>
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				ALUOp <= '0';
				ResultSrc <= "10";
				BranchS <= '1';
				next_state <= Fetch;
			when MemRead =>
				ResultSrc <= "00";
				AdrSrc <= '1';
				next_state <= MemWB;
			when MemWriteS =>
				ResultSrc <= "00";
				AdrSrc <= '1';
				MemW <= '1';
				next_state <= Fetch;
			when ALUWB =>
				ResultSrc <= "00";
				RegWsig <= '1';
				next_state <= Fetch;
			when MemWB =>
				ResultSrc <= "01";
				RegWsig <= '1';
				next_state <= Fetch;
        end case;
    end process;

	--INSTRUCTION DECODER
	RegSrc(0) <= '1' when Op = "10" else
	             '0';
	
	RegSrc(1) <= '1' when Op = "01" else
	             '0';
    
    ImmSrc <= Op;
                  
	-- ALU DECODER
	ALUDecOp <= ALUOp & Funct(4 downto 1) & Funct(0);
	
	-- ALUControl sets the operation to be performed by ALU
	with ALUDecOp select
	ALUControl <=   "00" when "101000" | "101001",  -- ADD
					"01" when "100100" | "100101",  -- SUB
					"10" when "100000" | "100001",  -- AND
					"11" when "111000" | "111001",  -- ORR
					"00" when others;               -- Not DP

	-- FlagW: Flag Write Signal
	-- Asserted when ALUFlags should be saved
	-- FlagW(1) = '1' --> save NZ flags (ALUFlags(3:2))
	-- FlagW(0) = '1' --> save CV flags (ALUFlags(1:0))
	with ALUDecOp select								
	FlagW <=  "00" when "101000",  -- ADD     
			  "11" when "101001",  -- ADDS     
			  "00" when "100100",  -- SUB     
			  "11" when "100101",  -- SUBS
			  "00" when "100000",  -- AND
			  "10" when "100001",  -- ANDS
			  "00" when "111000",  -- ORR
			  "10" when "111001",  -- ORRS
			  "00" when others;    -- Not DP

end Behavioral;

