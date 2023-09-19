----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 
-- 
-- Create Date:    10:14:31 11/08/2016 
-- Design Name: 
-- Module Name:    Register_File - Behavioral 
-- Project Name:   ARM Processor
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
	generic (data_size : natural := 32;
			 addr_size : natural := 4 );
	port (clk, WE3   : in  std_logic;
		  A1, A2, A3 : in  std_logic_vector(addr_size-1 downto 0);
		  WD3, R15   : in  std_logic_vector(data_size-1 downto 0);
		  RD1, RD2   : out std_logic_vector(data_size-1 downto 0));
end Register_File;

architecture Behavioral of Register_File is

	type RegFile_type is array (0 to 2**addr_size-1) of
  						             std_logic_vector (data_size-1 downto 0);
	signal RegFile : RegFile_type := (others => (others => '0'));

begin

	-- Write synchronously to the RegFile on Port 3
    process(clk)
    begin 
        if (WE3 = '1') and (rising_edge(clk)) then 
            RegFile(to_integer(unsigned(A3))) <= WD3;
        end if;
    end process;


	-- Read from RegFile on Port 1
	-- When the address = 15, use data from the R15 input
	--   else use data from the RegFile array
	process(A1, R15)
	begin
	   if A1 = "1111" then
	       RD1 <= R15;
	   else 
           RD1 <= RegFile(to_integer(unsigned(A1)));
       end if;
    end process;


	-- Read from RegFile on Port 2
	-- When the address = 15, use data from the R15 input
	--   else use data from the RegFile array
    process(A2, R15)
    begin
        if A2 = "1111" then
            RD2 <= R15;
        else
            RD2 <= RegFile(to_integer(unsigned(A2)));
        end if;
    end process;

end Behavioral;

