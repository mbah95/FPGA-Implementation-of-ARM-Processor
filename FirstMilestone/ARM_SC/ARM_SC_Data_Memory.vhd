----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer: 	   Carl Betcher
-- 
-- Create Date:    10:14:31 11/08/2016 
-- Design Name: 
-- Module Name:    Data_Memory - Behavioral 
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

entity Data_Memory is

   Generic ( data_width : positive := 32; 
             addr_width : positive := 9);

   Port ( clk : in STD_LOGIC; 
          WE  : in STD_LOGIC;
          A   : in  STD_LOGIC_VECTOR (addr_width-1 downto 0);
          WD  : in  STD_LOGIC_VECTOR (data_width-1 downto 0);
          RD  : out  STD_LOGIC_VECTOR (data_width-1 downto 0));

end Data_Memory;

architecture Behavioral of Data_Memory is

   type Data_Mem_type is array(0 to 2**addr_width-1) 
		     	   of std_logic_vector(data_width-1 downto 0); 
   signal Data_Mem : Data_Mem_type;

begin

   -- Synchronous Write to Data Memory
   process (clk)                                                
   begin
      if rising_edge(clk) then 
         if WE = '1' then
            Data_Mem(to_integer(unsigned(A))) <= WD; 
         end if;
      end if;                                                       
   end process; 

   -- Asynchronous Read from Data Memory
	RD <= Data_Mem(to_integer(unsigned(A)));	
	
end Behavioral;
