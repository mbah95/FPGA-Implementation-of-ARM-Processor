----------------------------------------------------------------------------------
-- Company: 	   Binghamton University
-- Engineer: 	   
-- 
-- Create Date:     
-- Design Name:	   ARM Processor ALU 
-- Module Name:    ALU - Behavioral 
-- Project Name:   ARM_Processor
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
	Generic ( data_size : positive := 32 );
    Port ( A, B : in  STD_LOGIC_VECTOR (data_size-1 downto 0);
		   ALUControl : in STD_LOGIC_VECTOR (1 downto 0);
           Result : out  STD_LOGIC_VECTOR (data_size-1 downto 0);
           ALUFlags : out  STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
	signal result_sig : unsigned(data_size downto 0);
	signal sum_out : std_logic_vector(data_size-1 downto 0);
	signal b_out : std_logic_vector(data_size-1 downto 0);
	signal co : std_logic;
	signal N: std_logic_vector(data_size-1 downto 0);
	
	begin
	--Adder Logic
	process(ALUControl, b_out, A)
	begin
	   if ALUControl(0) = '1' then
	       result_sig <= resize(unsigned(A),data_size+1) + resize(unsigned(b_out),data_size+1) + 1;
	   elsif ALUControl(0) = '0' then
	       result_sig <= resize(unsigned(A),data_size+1) + resize(unsigned(b_out),data_size+1);
	end if; 
	end process;
	
	sum_out <= std_logic_vector(result_sig(data_size-1 downto 0));
	co <= result_sig(data_size);
	
	--B Multiplexer
	process(ALUControl(0), B)
	begin
		case ALUControl(0) is
			when '0' =>
				b_out <= B;
			when '1' =>
				b_out <= not B;
		    when others =>
		        b_out <= b_out;
		end case;
	end process;
	
	--Main Multiplexer
	process(ALUControl, sum_out, A, B)
	begin
		case ALUControl is
			when "00" =>
				N <= sum_out;
			when "01" => 
				N <= sum_out;
			when "10" =>
				N <= (A and B);
			when "11" =>
				N <= (A or B);
		    when others =>
		        N <= N;
		end case;
	end process;
	
	--N Flag
	ALUFlags(3) <= N(data_size-1);
	
	--Z Flag
	process(N)
	begin
	if N = x"00000000" then
	   ALUFlags(2) <= '1';
	else
	   ALUFlags(2) <= '0';
	end if;
	end process;
	
	--C Flag
	ALUFlags(1) <= (co and (not ALUControl(1)));
	
	--V Flag
	ALUFlags(0) <= ( (not ALUControl(1)) and (sum_out(data_size-1) xor A(data_size-1)) and (not(ALUControl(0) xor A(data_size-1) xor B(data_size-1))) );
  
    Result <= N;
end Behavioral;