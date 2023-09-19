----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer(s):    Carl Betcher
-- 
-- Create Date:    23:13:36 11/13/2016 
-- Design Name:    ARM Processor Datapath
-- Module Name:    Datapath - Behavioral 
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

entity datapath is  
  generic(IM_addr_width : positive := 9;
          DM_addr_width : positive := 9);
  port(clk, reset, en_ARM : in  STD_LOGIC;
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
       ALUResult    : out STD_LOGIC_VECTOR(31 downto 0); 
       ReadData     : out STD_LOGIC_VECTOR(7 downto 0)
       );
end;

architecture Behavioral of Datapath is
 
	component Instruction_Memory
    generic ( data_width : positive := 32; 
			  addr_width : positive := 9);
	port(A  : in  STD_LOGIC_VECTOR(addr_width-1 downto 0);
         clk : in STD_LOGIC; 
         WE  : in STD_LOGIC;
         WD  : in  STD_LOGIC_VECTOR (data_width-1 downto 0);
		 RD : out STD_LOGIC_VECTOR(data_width-1 downto 0));
	end component;
	
	COMPONENT Register_File
	GENERIC (data_size : natural := 32;
			 addr_size : natural := 4 );
	PORT(
		clk : IN std_logic;
		WE3 : IN std_logic;
		A1  : IN std_logic_vector(3 downto 0);
		A2  : IN std_logic_vector(3 downto 0);
		A3  : IN std_logic_vector(3 downto 0);
		WD3 : IN std_logic_vector(31 downto 0);
		R15 : IN std_logic_vector(31 downto 0);          
		RD1 : OUT std_logic_vector(31 downto 0);
		RD2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	COMPONENT ALU
	PORT(
		A : IN std_logic_vector(31 downto 0);
		B : IN std_logic_vector(31 downto 0);
		ALUControl : IN std_logic_vector(1 downto 0);          
		Result : OUT std_logic_vector(31 downto 0);
		ALUFlags : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	signal InstrSig : std_logic_vector(31 downto 0);
	signal PCmux : std_logic_vector(31 downto 0);
	signal PCsig : std_logic_vector(31 downto 0) := (others => '0');
	signal ExtImm : std_logic_vector(31 downto 0);
	signal ShiftedImm24 : signed(31 downto 0);
	signal RA1mux : std_logic_vector(3 downto 0);
	signal RA2mux : std_logic_vector(3 downto 0);
	signal SrcA : std_logic_vector(31 downto 0);
	signal SrcB : std_logic_vector(31 downto 0);
	signal ALUResultSig : std_logic_vector(31 downto 0);
	signal ReadDataSig : std_logic_vector(31 downto 0);
	signal WriteDataSig : std_logic_vector(31 downto 0);
	signal Result : std_logic_vector(31 downto 0);	
	
	signal RF_WE3 : std_logic;
	
	signal RD1 : std_logic_vector(31 downto 0);
	signal RD2 : std_logic_vector(31 downto 0);
	signal ASig : std_logic_vector(31 downto 0);
	
	--Mux at end
	signal DataSig : std_logic_vector(31 downto 0);
	signal ALUOut : std_logic_vector(31 downto 0);
begin

	-- Instantiate the Instruction Memory
	i_imem: Instruction_Memory 
	generic map (data_width => 32, 
	             addr_width => IM_addr_width)
	port map(A  => PCmux(IM_addr_width+1 downto 2),
	         clk => Clk,
	         WE => DM_WE,
	         WD => WriteDataSig,
	         RD => ReadDataSig);
	         
    -- Output the instruction
    Instr <= InstrSig;
			 
	-- Data Memory ReadData(7:0) to the toplevel for display
	ReadData <= ReadDataSig(7 downto 0); 		 
									       
	-- Output the Program Counter
	PC <= PCsig;
	-- Output the ALUResult for the Data Memory Address
	ALUResult <= ALUResultSig;
	
	-- This Mux provides the data loaded into the PC
	-- When PCSrc = '1', the source of the PC in output of ALU or Data Memory
	--     Used for branching
	-- When PCSrc = '0', the source of the PC is PCPlus4
	--     Used when accessing the next consecutive instruction
	PCmux <= Result when AdrSrc = '1' else PCsig;
	
	-- Program Counter
	-- reset clears it to 0
	-- en_ARM allows PC to be loaded from PCmux
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				PCsig <= (others => '0');
			elsif PCWrite = '1' then	
				PCsig <= Result;
			else
				PCsig <= PCsig;
			end if;
		end if; 
	end process;
	
	--Takes Read Data out and waits for a clock cycle for Instruction
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				InstrSig <= (others => '0');
			elsif IRWrite = '1' then	
				 InstrSig <= ReadDataSig;
			else
				InstrSig <= InstrSig;
			end if;
		end if; 
	end process;
	
	--Read Data to Data clock 
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				DataSig <= (others => '0');
		    elsif en_ARM = '1' then	
				 DataSig <= ReadDataSig;
			else
				 DataSig <= DataSig;
			end if; 
		end if; 
	end process;
	
	-- Mux selects address for Port 1 of the Register File
	RA1mux <= InstrSig(19 downto 16) when RegSrc(0) = '0' else x"F";
	
	-- Mux selects address for Port 2 of the Register File
	RA2mux <= InstrSig(3 downto 0) when RegSrc(1) = '0' else InstrSig(15 downto 12);
	
	-- Write enable for Register File is gated by en_ARM
	RF_WE3 <= RegWrite and en_ARM;
	
	-- Instantiate Register File (16 registers x 32 bits)
	i_Register_File: Register_File PORT MAP(
		clk => clk,
		WE3 => RF_WE3,
		A1 => RA1mux,
		A2 => RA2mux,
		A3 => InstrSig(15 downto 12),
		WD3 => Result,
		R15 => Result,
		RD1 => RD1,
		RD2 => RD2 
	);
	
	--RD1 Output of RegFile Clock wait to A
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				Asig <= (others => '0');
		    elsif en_ARM = '1' then	
				 ASig <= RD1;
			else
				 Asig <= Asig;
			end if; 
		end if; 
	end process;
	
	--RD2 Ouptut of RegFile Clock cycle to WriteData
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				WriteDataSig <= (others => '0');
		    elsif en_ARM = '1' then	
				 WriteDataSig <= RD2;
			else
				 WriteDataSig <= WriteDataSig;
			end if; 
		end if; 
	end process;
	
	--SrcA Mux for ALU
	SrcA <= ASig when ALUSrcA = '0' else PCsig;
	
	--SrcB Mux for ALU
	SrcB <=  WriteDataSig when ALUSrcB = "00" else
	         ExtImm when ALUSrcB = "01" else
	         "00000000000000000000000000000100" when ALUSrcB = "10" else
	         SrcB;
	
	-- 24-bit Immediate Field sign extended and shifted left twice
	ShiftedImm24 <= resize(signed(InstrSig(23 downto 0)),30) & "00";
	
	-- Extend function for Immediate data
	with ImmSrc select
	ExtImm <= std_logic_vector(resize(unsigned(InstrSig(7 downto 0)),ExtImm'length))  when "00",
			  std_logic_vector(resize(unsigned(InstrSig(11 downto 0)),ExtImm'length)) when "01",
			  std_logic_vector(ShiftedImm24) when others;
	
	-- Instantiate the ALU
	i_ALU: ALU PORT MAP(
		A => SrcA,
		B => SrcB,
		ALUControl => ALUControl,
		Result => ALUResultSig,
		ALUFlags => ALUFlags
	);	
	
	--ALUOut Clock cycle
	Process(clk) 
	begin 
		if rising_edge(clk) then
			if reset = '1' then
				ALUOut <= (others => '0');
		    elsif en_ARM = '1' then	
				 ALUOut <= ALUResultSig;
			else
				 ALUOut <= ALUOut;
			end if; 
		end if; 
	end process;
	
	--Result Mux
	Result <=  ALUOut when ResultSrc = "00" else
	         DataSig when ResultSrc = "01" else
	         ALUResultSig when ResultSrc = "10" else
	         Result;
	
end Behavioral;

