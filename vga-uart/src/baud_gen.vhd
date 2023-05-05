library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_gen is
    generic (
        constant N : integer := 11
    );
    port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dvsr : in STD_LOGIC_VECTOR ((N-1) downto 0);
           ticks : out STD_LOGIC);
end baud_gen;

architecture Behavioral of baud_gen is
    signal r_reg : unsigned(N-1 downto 0);
    signal r_next : unsigned(N-1 downto 0);

begin

    process(clk, rst)
    begin
        if(rst = '1') then
            r_reg<=(others =>  '0');
        elsif rising_edge(clk) then
            r_reg <= r_next;
        end if;
    end process;

    r_next <= (others=> '0') when r_reg = unsigned(dvsr) else r_reg + 1;

    ticks <= '1' when r_reg = 1 else '0';
    
end Behavioral;
