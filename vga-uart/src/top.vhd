library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    generic (
        N : integer := 11;
        DATA_WIDTH : integer := 8;
        FIFO_W : integer := 0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        led8 : out std_logic_vector(7 downto 0);
        tx : out std_logic;
        rx : in std_logic;

        VGA_HS_O : out  STD_LOGIC;
        VGA_VS_O : out  STD_LOGIC;
        VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
        VGA_G : out  STD_LOGIC_VECTOR (3 downto 0);
        VGA_B : out  STD_LOGIC_VECTOR (3 downto 0)
    );

end top;

architecture Behavioral of top is

    component clk_wiz_0
        port
        (-- Clock in ports
        CLK_IN1           : in     std_logic;
        -- Clock out ports
        CLK_OUT1          : out    std_logic
        );
        end component;

    -- UART
    constant dvsr : std_logic_vector((N-1) downto 0) := std_logic_vector(to_unsigned(68, 11));
    signal wr_en : std_logic;
    signal wr_uart : std_logic;
    signal rd_uart : std_logic;
    signal wr_dvsr : std_logic;
    signal tx_full : std_logic;
    signal rx_empty : std_logic;
    signal r_data : std_logic_vector((DATA_WIDTH-1) downto 0);
    signal w_data : std_logic_vector((DATA_WIDTH-1) downto 0) := x"56";
    signal dvsr_reg : std_logic_vector((N-1) downto 0);


    -- clk_wiz
    signal clk_vga : std_logic;

    --DISP CTRL
    constant BIT_WIDTH : integer := 20;
begin

-- Clk Wiz
clk_div_inst : clk_wiz_0
    port map
     (-- Clock in ports
      CLK_IN1 => clk,
      -- Clock out ports
      CLK_OUT1 => clk_vga);

-- VGA
vga_i : entity work.vga_ctrl
    generic map (
        BIT_WIDTH => BIT_WIDTH
    )
    port map (
        CLK_I => clk_vga,
        sel => r_data(3 downto 0),
        VGA_HS_O => VGA_HS_O,
        VGA_VS_O => VGA_VS_O,
        VGA_R => VGA_R,
        VGA_B => VGA_B,
        VGA_G => VGA_G
    );

-- UART
uart_i : entity work.uart
    generic map (
        DBIT => 8,
        SB_TICK => 16,
        FIFO_W => 0
    )
    port map (
        clk => clk,
        rst => rst,
        rd_uart => rd_uart,
        wr_uart => wr_uart,
        dvsr => dvsr,
        rx => rx,
        w_data => w_data,
        tx_full =>tx_full,
        rx_empty => rx_empty,
        r_data => r_data,
        tx => tx
    );

    led8 <= r_data;
    wr_uart <= '0';
    rd_uart <= '1';
    -- w_data -- Always on

end Behavioral;