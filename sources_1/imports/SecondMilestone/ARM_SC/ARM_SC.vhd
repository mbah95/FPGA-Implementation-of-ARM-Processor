----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer(s):    Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name: 
-- Module Name:    ARM - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity ARM is -- single cycle processor
  generic(IM_addr_width : positive := 9;
          DM_addr_width : positive := 9);
  port(clk, reset, en_ARM : in  STD_LOGIC;
                 Switch   : in STD_LOGIC_VECTOR(7 downto 0);
                 PC       : out STD_LOGIC_VECTOR(7 downto 0);
                 Instr    : out STD_LOGIC_VECTOR(31 downto 0);
                 ReadData : out STD_LOGIC_VECTOR(7 downto 0));
  end ARM;

architecture Behavioral of ARM is

	COMPONENT controller
	PORT(clk, reset:        in  STD_LOGIC;
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
	END COMPONENT;

	COMPONENT datapath
    GENERIC(IM_addr_width : positive := 9;
            DM_addr_width : positive := 9);
	PORT(clk, reset, en_ARM : in  STD_LOGIC;
       RegSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
       RegWrite     : in  STD_LOGIC;
       ImmSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
       ALUSrcA      : in  STD_LOGIC;
       ALUSrcB      : in  STD_LOGIC_Vector(1 downto 0);
       ALUControl   : in  STD_LOGIC_VECTOR(1 downto 0);
       AdrSrc       : in  STD_LOGIC;
       DM_WE        : in  STD_LOGIC;
       IRWrite      : in std_logic;
       PCWrite      : in std_logic;
       ResultSrc    : in  STD_LOGIC_vector (1 downto 0);
       DM_Addr      : in  STD_LOGIC_VECTOR(DM_addr_width-1 downto 0);
       ALUFlags     : out STD_LOGIC_VECTOR(3 downto 0);
       PC           : out STD_LOGIC_VECTOR(31 downto 0);
       Instr        : out STD_LOGIC_VECTOR(31 downto 0);
       ALUResult    : inout STD_LOGIC_VECTOR(31 downto 0); 
       ReadData     : out STD_LOGIC_VECTOR(7 downto 0)
         );
	END COMPONENT;

	-- Signals needed to make connections between the datapath and controller
	signal ALUFlags : std_logic_vector(3 downto 0);
	signal RegSrc : std_logic_vector(1 downto 0);
	signal RegWrite : std_logic; 
	signal ImmSrc : std_logic_vector(1 downto 0);
	signal ALUSrcA : std_logic;
	signal ALUSrcB : std_logic_vector (1 downto 0);
	signal ALUControl : std_logic_vector(1 downto 0);
	signal MemWrite  : std_logic;
	signal InstrSig : std_logic_vector(31 downto 0);
	signal DM_WE : std_logic;
	signal DM_Addr : std_logic_vector(DM_addr_width-1 downto 0);
	signal DataAddr : std_logic_vector(31 downto 0);
	signal PCsig : std_logic_vector(31 downto 0);
	signal AdrSrc   :  STD_LOGIC;
    signal IRWrite      : std_logic;
    signal PCWrite      : std_logic;
    signal ResultSrc  : std_logic_vector(1 downto 0);
    signal ALUResult : std_logic_vector (31 downto 0);

begin

	-- Instantiate the Controller for the ARM Processor
	i_controller: controller PORT MAP(
		clk => clk,
		reset => reset,
		Instr => InstrSig(31 downto 12),
		ALUFlags => ALUFlags,
		RegSrc => RegSrc,
		RegWrite => RegWrite,
		ImmSrc => ImmSrc,
		ALUSrcA => ALUSrcA,
		ALUSrcB => ALUSrcB,
		ALUControl => ALUControl,
		MemWrite => MemWrite,
		AdrSrc => AdrSrc,
        IRWrite => IRWrite,
        PCWrite => PCWrite,
        ResultSrc => ResultSrc,
        en_ARM => en_ARM
	);

	-- Instantiate the Datapath for the ARM Processor
	i_datapath: datapath PORT MAP(
		clk => clk,
		reset => reset,
		en_ARM => en_ARM,
		RegSrc  => RegSrc,
        RegWrite  => RegWrite,
        ImmSrc => ImmSrc, 
        ALUSrcA  => ALUSrcA,
        ALUSrcB  => ALUSrcB,
        ALUControl  => ALUControl,
        AdrSrc   => AdrSrc,
        DM_WE    => DM_We,
        IRWrite  => IRWrite,
        PCWrite  => PCWrite,
        ResultSrc => ResultSrc,
        DM_Addr   => DM_Addr,
        ALUFlags => ALUFLags,
        PC  => PCSig,
        Instr => InstrSig,
        ALUResult  => ALUResult,
        ReadData  => ReadData
	);

    -- Outputs to top level module
    Instr <= InstrSig;
    PC <= PCsig(7 downto 0);

	-- When the ARM is stopped, Switch input is used to address data memory
	-- Data Memory Address
	DM_Addr <= DataAddr(DM_addr_width+1 downto 2) when en_ARM = '1' 
						else std_logic_vector(resize(unsigned(Switch),DM_Addr'length));
	-- Data Memory Write Enable					
	DM_WE <= en_ARM and MemWrite;					

end Behavioral;

