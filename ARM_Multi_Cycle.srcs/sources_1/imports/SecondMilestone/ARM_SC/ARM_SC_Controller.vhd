----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer(s):    Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity controller is -- single cycle control decoder
  port(clk, reset:        in  STD_LOGIC;
       Instr:             in  STD_LOGIC_VECTOR(31 downto 12);
       ALUFlags:          in  STD_LOGIC_VECTOR(3 downto 0);
       RegSrc:            out STD_LOGIC_VECTOR(1 downto 0);
       RegWrite:          out STD_LOGIC;
       ImmSrc:            out STD_LOGIC_VECTOR(1 downto 0);
       ALUSrcA:           out STD_LOGIC;
       ALUSrcB:           out STD_LOGIC_VECTOR(1 downto 0);
       ALUControl:        out STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:          out STD_LOGIC;
       AdrSrc       : out  STD_LOGIC;
       IRWrite      : out std_logic;
       PCWrite      : out std_logic;
       ResultSrc    : out  STD_LOGIC_vector (1 downto 0);
       en_ARM : in std_logic
       );
end;

architecture Behavioral of Controller is

	COMPONENT Decoder
	PORT(
		clk : in STD_LOGIC;
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
	END COMPONENT;

	COMPONENT Cond_Logic
	PORT(
		clk : std_logic;
		reset : std_logic;
		Cond : IN std_logic_vector(3 downto 0);
		ALUFlags : IN std_logic_vector(3 downto 0);
		FlagW : IN std_logic_vector(1 downto 0);
		PCS : IN std_logic;
		RegW : IN std_logic;
		MemW : IN std_logic;
		NextPC : in std_Logic;
		RegWrite : OUT std_logic;
		MemWrite : OUT std_logic;
		PCWrite  : out std_logic
		);
	END COMPONENT;
	
	signal FlagW : std_logic_vector(1 downto 0);
	signal PCS  : std_logic;
	signal RegW : std_logic;
	signal MemW : std_logic;
	signal NextPC : std_logic;

begin

	-- Instantiate the Decoder Function of the Controller
	i_Decoder: Decoder PORT MAP(
	    clk => clk,
	    reset => reset,
	    en_ARM => en_ARM,
		Op => Instr(27 downto 26),
		Funct => Instr(25 downto 20),
		Rd => Instr(15 downto 12),
		FlagW => FlagW,
		PCS => PCS,
		RegW => RegW,
		MemW => MemW,
		ALUSrcA => ALUSrcA,
		ALUSrcB => ALUSrcB,
		ImmSrc => ImmSrc,
		RegSrc => RegSrc,
		ALUControl => ALUControl,
		AdrSrc    => AdrSrc,
        IRWrite  => IRWrite,
        ResultSrc  => ResultSrc,
        NextPC => NextPC
	);

	-- Instantiate the Conditional Logic Function of the Controller
	i_Cond_Logic: Cond_Logic PORT MAP(
		clk => clk,
		reset => reset,
		Cond => Instr(31 downto 28),
		ALUFlags => ALUFlags,
		FlagW => FlagW,
		PCS => PCS,
		RegW => RegW,
		MemW => MemW,
		RegWrite => RegWrite,
		MemWrite => MemWrite, 
		NextPC => NextPC,
		PCWrite => PCWrite
	);

end Behavioral;

