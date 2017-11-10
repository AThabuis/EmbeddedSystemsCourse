library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testBench is
end testBench;

architecture tb of testBench is

component PWMPort is 
	PORT(	
		Clk : IN std_logic;
		nReset : IN std_logic;
		Address : IN std_logic_vector (2 DOWNTO 0);
		ChipSelect: IN std_logic;
		Read : IN std_logic;
		Write : IN std_logic;
		ReadData : OUT std_logic_vector (7 DOWNTO 0);
		WriteData : IN std_logic_vector (7 DOWNTO 0);

	--   PWM external interface
		PWMOut : OUT std_logic
   );
end component;

	constant CLK_PERIOD : TIME := 20 ns;	-- 50 MHz
	
	signal Clk : std_logic := '0';
	signal nReset : std_logic := '1';
	signal Address : std_logic_vector (2 DOWNTO 0) := "000";
	signal ChipSelect: std_logic := '0';
	signal Read : std_logic := '0';
	signal Write : std_logic := '0';
	signal ReadData : std_logic_vector (7 DOWNTO 0) := X"00";
	signal WriteData : std_logic_vector (7 DOWNTO 0) := X"00";
	signal PWMOut : std_logic := '0';

begin

	dut : PWMPort
		port map(
			Clk => Clk,
			nReset => nReset,
			Address => Address,
			ChipSelect => ChipSelect,
			Read => Read,
			Write => Write,
			ReadData => ReadData,
			WriteData => WriteData,
			PWMOut => PWMOut
		);
	
	-- Generate CLK signal
	clk_generation : 
	process
	begin
		CLK <= '1';
		wait for CLK_PERIOD / 2;
		CLK <= '0'; 
		wait for CLK_PERIOD / 2;
	end process clk_generation;
	
	test:
	process
		procedure reset_comp is
		begin
			wait until rising_edge(Clk);
			nReset <= '0';
			
			wait until rising_edge(Clk);
			nReset <= '1';
		end procedure reset_comp;
		
		--procedure write_register(write_address : std_logic_vector)
	begin
	end process test;
	
end architecture tb;





