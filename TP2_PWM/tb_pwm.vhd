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
		-- Procdure to reset the component
		procedure reset_comp is
		begin
			wait until rising_edge(Clk);
			nReset <= '0';

			wait until rising_edge(Clk);
			nReset <= '1';
		end procedure reset_comp;

		-- procedure to write to the registers
		procedure write_register(write_address : std_logic_vector;
								 write_data : std_logic_vector) is
		begin
			wait until rising_edge(Clk);
			ChipSelect <= '1';
			Write <= '1';
			Address <= write_address;
			WriteData <=  write_data;

			wait until rising_edge(Clk);
			ChipSelect <= '0';
			Write <= '0';
			Address <= "000";
			WriteData <=  X"00";
		end procedure write_register;

		--procedure to read from the registers
		procedure read_register(read_address : std_logic_vector) is
		begin
			wait until rising_edge(Clk);
			ChipSelect <= '1';
			Read <= '1';
			Address <= read_address;

			wait until rising_edge(Clk);
			ChipSelect <= '0';
			Read <= '0';
			Address <= "000";
		end procedure read_register;

	begin
		--reset the system
		reset_comp;
		
		write_register("000",X"01"); -- enable the PWM
		write_register("100",X"00"); -- set the divider to 1000
		write_register("101",X"0A");
		write_register("011",X"01"); -- set the polarity to 1

		write_register("001",X"14"); -- set the period to 20 slow clock ticks
		write_register("010",X"02"); -- set the duty cycle to 10%
		
		read_register("000");

		wait for 1000 * 20 * CLK_PERIOD; -- wait for 1 period of the PWM

		write_register("010",X"0A"); -- set the duty cycle to 50%

		wait for 1000 * 20 * CLK_PERIOD; -- wait for 1 period of the PWM

		write_register("010",X"0F"); -- set the duty cycle to 75%

		wait for 1000 * 20 * CLK_PERIOD; -- wait for 1 period of the PWM

		write_register("011",X"00"); -- set the polarity to 2

		wait for 1000 * 20 * CLK_PERIOD; -- wait for 1 period of the PWM

		-- reset_comp; -- reset
		wait;
	end process test;

end architecture tb;
