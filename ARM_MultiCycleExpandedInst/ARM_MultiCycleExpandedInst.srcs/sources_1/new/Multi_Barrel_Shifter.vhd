library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multi_Barrel_Shifter is
    Port ( BarrelShiftIn : in STD_LOGIC_VECTOR (31 downto 0);
           BarrelShiftOut : out STD_LOGIC_VECTOR (31 downto 0);
           ShOp : in STD_LOGIC_VECTOR (1 downto 0);
           shamt5 : in STD_LOGIC_VECTOR (4 downto 0);
           co_shift : out STD_LOGIC
          );
end Multi_Barrel_Shifter;

architecture Behavioral of Multi_Barrel_Shifter is

	COMPONENT Shift_Block -- Each shift block performs the selected operation by a parameterized amount.
	Generic ( shamt : positive := 1);
	PORT(
        Input : in STD_LOGIC_VECTOR (31 downto 0);
        ShOp : in STD_LOGIC_VECTOR (1 downto 0);
        sh : in STD_LOGIC;
        Output : out STD_LOGIC_VECTOR (31 downto 0);
        Cout : out STD_LOGIC;
        Cin  : in STD_LOGIC
		);
	END COMPONENT;
	
signal BarrelShift2 : STD_LOGIC_VECTOR(31 downto 0);
signal BarrelShift4 : STD_LOGIC_VECTOR(31 downto 0);
signal BarrelShift8 : STD_LOGIC_VECTOR(31 downto 0);
signal BarrelShift16 : STD_LOGIC_VECTOR(31 downto 0);

signal co2 : STD_LOGIC; 
signal co4 : STD_LOGIC;
signal co8 : STD_LOGIC;
signal co16 : STD_LOGIC;

begin

    i_Shift_Block1: Shift_Block 
    GENERIC MAP(shamt => 1)
    PORT MAP(
            Input => BarrelShift2,
            ShOp => ShOp,
            sh => shamt5(0),
            Output => BarrelShiftOut,
            Cout => co_shift,
            Cin => co2
	        );  
    
    i_Shift_Block2: Shift_Block
    GENERIC MAP(shamt => 2)
    PORT MAP(
            Input => BarrelShift4,
            ShOp => ShOp,
            sh => shamt5(1),
            Output => BarrelShift2,
            Cout => co2,
            Cin => co4
	        );    
	          
    i_Shift_Block4: Shift_Block
    GENERIC MAP(shamt => 4)
    PORT MAP(
            Input => BarrelShift8,
            ShOp => ShOp,
            sh => shamt5(2),
            Output => BarrelShift4,
            Cout => co4,
            Cin => co8
	        );  
	        
    i_Shift_Block8: Shift_Block
    GENERIC MAP(shamt => 8)
    PORT MAP(
            Input => BarrelShift16,
            ShOp => ShOp,
            sh => shamt5(3),
            Output => BarrelShift8,
            Cout => co8,
            Cin => co16
	        );  

    i_Shift_Block16: Shift_Block
    GENERIC MAP(shamt => 16)
    PORT MAP(
            Input => BarrelShiftIn,
            ShOp => ShOp,
            sh => shamt5(4),
            Output => BarrelShift16,
            Cout => co16,
            Cin => '0'
	        );  
	        	        
end Behavioral;
