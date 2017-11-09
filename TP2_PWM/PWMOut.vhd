-- Authors : Antoine Laurens, Adrien Thabuis, Hugo Viard
--
-- PWM with programmable period, duty cycle and polarity
--
-- ~ address :
-- 0x00 Enabling of the PWM
-- 0x01 Period
-- 0x02 Duty Cycle
-- 0x03 Polarity
-- 0x04 Clock divider upper counter limit (on 2 adresses)

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY PWMPort IS
    PORT(
        nReset	: IN std_logic;							-- nReset input
        Clk		: IN std_logic;							-- clock input
        Addr	: IN std_logic_vector (2 DOWNTO 0);		-- address bus
        Read		: IN std_logic;							-- read enabler
        Write		: IN std_logic;							-- write enabler
        ReadData	: OUT std_logic_vector (7 DOWNTO 0);	-- data bus (read)
        WriteData	: IN std_logic_vector (7 DOWNTO 0);		-- data bus (write)
        PWMOut	: OUT std_logic							-- PWM output
    );
END PWMPort;

ARCHITECTURE comp OF PWMPort IS
-- signals of our PWM module
    signal sCounter: std_logic_vector (15 DOWNTO 0) := '0';
    -- set the clock didiver initial value to 1000
    signal sUpperClockDivider: std_logic_vector (15 DOWNTO 0) := X"03_E8";
    signal sSlowClock: std_logic;

BEGIN
    -- process for the clock divider
    ClkDivider:
    process(Clk,nReset)
    begin
        if nReset = '0' then
            sCounter <= (others => '0');      -- reset counter when pressing reset
        elsif rising_edge(Clk) then
            if sCounter < sUpperClockDivider then
                sCounter <= std_logic_vector( unsigned(sCounter) + 1 );
                sSlowClock <= '0';
            elsif sCounter = sUpperClockDivider then
                sSlowClock <= '1';
                sCounter <= (others => '0');
            elsif sCounter > sUpperClockDivider then
                sCounter <= (others => '0');
            end if;
        end if;
    end process ClkDivider;
