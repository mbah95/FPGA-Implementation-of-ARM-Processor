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
    Port ( Op : in  STD_LOGIC_VECTOR (1 downto 0);
           Funct : in  STD_LOGIC_VECTOR (5 downto 0);
           Rd : in  STD_LOGIC_VECTOR (3 downto 0);
           FlagW : out  STD_LOGIC_VECTOR (1 downto 0);
           PCS : out  STD_LOGIC;
           RegW : out  STD_LOGIC;
           MemW : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           ImmSrc : out  STD_LOGIC_VECTOR (1 downto 0);
           RegSrc : out  STD_LOGIC_VECTOR (1 downto 0);
           ALUControl : out  STD_LOGIC_VECTOR (1 downto 0));
end Decoder;

architecture Behavioral of Decoder is

	alias cmd : std_logic_vector(3 downto 0) 
								   is Funct(4 downto 1); -- Instruction Command
														 -- ADD: cmd="0100"
														 -- SUB: cmd="0010"
	alias I   : std_logic is Funct(5); -- I-bit = '0' --> Src2 is a register
									   --       = '1' --> Src2 is an immediate
	alias S   : std_logic is Funct(0); -- S-bit = '1' --> set condition flags
	
	signal MainDecOp : std_logic_vector(3 downto 0);
	signal Controls  : std_logic_vector(9 downto 0);
	
	signal ALUDecOp : std_logic_vector(5 downto 0);

	signal RegWsig : std_logic;
	signal Branch : std_logic;
	signal ALUOp : std_logic;	

begin

	-- PC LOGIC
	-- PCS = 1 if PC is written by an instruction or branch (B)
	PCS <= '1' when (Rd = x"F" and RegWsig = '1') or Branch = '1' else '0';
	
	-- MAIN DECODER
	MainDecOp <= Op & Funct(5) & Funct(0);
	
	with MainDecOp select
	Controls <= "0000001001" when "0000" | "0001",  -- DP Reg
				"0001001001" when "0010" | "0011",  -- DP Imm
				"0011010100" when "0100" | "0110",  -- STR
				"0101011000" when "0101" | "0111",  -- LDR
				"1001100010" when others;			-- B
	
	Branch <= Controls(9);				-- Branch Instruction
	MemtoReg <= Controls(8);			-- LDR, Data Mem to RF
	MemW <= Controls(7);				-- STR, Data Mem WE
	ALUSrc <= Controls(6);				-- ExtImm to ALU SrcB
	ImmSrc <= Controls(5 downto 4);     -- Extend control
	RegWsig <= Controls(3);				-- To Condition Logic
	RegSrc <= Controls(2 downto 1);     -- RegSrc(0): RA1 Source
										-- RegSrc(1): RA2 Source
	ALUOp <= Controls(0);				-- DP Instruction
	
	RegW <= RegWsig; -- RegW output

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
	-- FlagW(0) = '1' --> save NZ flags (ALUFlags(3:2))
	-- FlagW(1) = '1' --> save CV flags (ALUFlags(1:0))
	with ALUDecOp select								
	FlagW <=  "00" when "101000",  -- ADD     
			  "11" when "101001",  -- ADD     
			  "00" when "100100",  -- SUB     
			  "11" when "100101",  -- SUB
			  "00" when "100000",  -- AND
			  "10" when "100001",  -- AND
			  "00" when "111000",  -- ORR
			  "10" when "111001",  -- ORR
			  "00" when others;    -- Not DP

end Behavioral;

