----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2021 01:06:33 PM
-- Design Name: 
-- Module Name: Test_ARM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Test_ARM IS
END Test_ARM;
 
ARCHITECTURE behavior OF Test_ARM IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	COMPONENT ARM
    Port (clk, reset, en_ARM : in  STD_LOGIC;
                 Switch   : in STD_LOGIC_VECTOR(7 downto 0);
                 PC       : out STD_LOGIC_VECTOR(7 downto 0);
                 Instr    : out STD_LOGIC_VECTOR(31 downto 0);
                 ReadData : out STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;
    
    --Inputs
    signal clk   : STD_LOGIC := '0';
    signal en_ARM : STD_LOGIC := '1';
    signal reset : STD_LOGIC := '0';
    signal switch : STD_LOGIC_VECTOR(7 downto 0);
 
    --Outputs                              
    signal PC : STD_LOGIC_VECTOR (7 downto 0);
    signal Instr : STD_LOGIC_VECTOR (31 downto 0);
    signal ReadData : STD_LOGIC_VECTOR (7 downto 0);  

    -- Clock period definitions
    constant Clk_period : time := 10 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
    uut: ARM 
	PORT MAP(
		clk => clk,
		reset => reset,
		en_ARM => en_ARM,
        Switch => Switch,
        PC => PC,
        Instr => Instr,
        ReadData => ReadData
	);

    -- Clock process definitions
    Clk_process :process
    begin
		wait for Clk_period/2; Clk <= not Clk;
    end process;

END;
