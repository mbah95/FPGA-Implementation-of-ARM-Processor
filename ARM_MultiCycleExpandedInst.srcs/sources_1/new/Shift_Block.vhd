library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Shift_Block is
    Generic ( shamt : positive := 1);
    Port(
        Input : in STD_LOGIC_VECTOR (31 downto 0);
        ShOp : in STD_LOGIC_VECTOR (1 downto 0);
        sh : in STD_LOGIC; --
        Output : out STD_LOGIC_VECTOR (31 downto 0);
        Cout : out STD_LOGIC;
        Cin  : in STD_LOGIC
    );
end Shift_Block;

architecture Behavioral of Shift_Block is
begin

process(ShOp, sh, Input, Cin) -- Vector slices are performed based on generic value shamt (shift amount)
begin
if sh = '1' then -- If sh = '1', then perform the shift. Else do not shift.
    case(ShOp) is
        when "00" => --LSL
            Output(31 downto shamt) <=  Input(31-shamt downto 0); -- Vector slices are used to swap sides of vectors
            Output(shamt-1 downto 0) <= std_logic_vector(to_unsigned(0, shamt));
            Cout <= Input(32 - shamt); --Unknown whether all shifts can set Carry, or just LSL   
        when "01" => --LSR
            Output(31-shamt downto 0) <= Input(31 downto shamt); 
            Output(31 downto 32-shamt) <= (others => '0'); 
            Cout <= '0'; --Input(shamt-1);
        when "10" => --ASR
            Output(31-shamt downto 0) <= Input(31 downto shamt);
            Output(31 downto 32-shamt) <= (others => Input(31)); 
            Cout <= '0'; --Input(shamt-1);
        when "11" => --
            Output <= Input(shamt-1 downto 0) & Input(31 downto shamt);  
            Cout <= '0'; -- Input(shamt-1);           
        when others =>
            Output <= Input;
            Cout  <= Cin;
    end case;                                     
elsif sh = '0' then
    Output <= Input;
    Cout  <= Cin;
end if;
end process;

end Behavioral;