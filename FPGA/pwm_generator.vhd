library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_generator is
    Port (
        clk_27m     : in  STD_LOGIC;
        reset_n     : in  STD_LOGIC;
        duty_value  : in  UNSIGNED(7 downto 0);
        pwm_out     : out STD_LOGIC
    );
end pwm_generator;

architecture RTL of pwm_generator is
constant clk_freq : integer := 27000000;
signal pwm_counter : unsigned(7 downto 0) := (others => '0'); 
signal prescaler_counter : integer range 0 to 4 := 0;
begin

process (clk_27m)
begin
 if rising_edge(clk_27m) then
   if reset_n = '0' then
      prescaler_counter <= 0;
      pwm_counter <= (others => '0');
   else 
      if prescaler_counter = 4 then
        prescaler_counter <= 0; 
        pwm_counter <= pwm_counter + 1;
      else
      prescaler_counter <= prescaler_counter + 1;
      end if;
   end if;
 end if;
end process;

pwm_out <= '1' when pwm_counter < duty_value else '0';

end RTL;
