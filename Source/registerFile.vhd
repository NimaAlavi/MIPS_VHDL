library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	
entity registerFile is
	generic (
		dataWidth 			: integer := 32
	);
	Port ( 
		clk 					: in std_logic;

		wrEn				: in std_logic;
		HIEn				: in std_logic;
		LOEn				: in std_logic;
	
		readReg1			: in std_logic_vector(4 downto 0);
		readReg2			: in std_logic_vector(4 downto 0);
		writeReg			: in std_logic_vector(4 downto 0);

		writeData			: in std_logic_vector(dataWidth - 1 downto 0);
		
		mulEn				: in std_logic;
		HI					: in std_logic_vector(dataWidth - 1 downto 0);
		LO					: in std_logic_vector(dataWidth - 1 downto 0);
	
		readData1			: out std_logic_vector(dataWidth - 1 downto 0);
		readData2			: out std_logic_vector(dataWidth - 1 downto 0)
	);  
end entity;

architecture Behavioral of registerFile is

type stdLogicVectorArray is array(natural range <>) of  std_logic_vector;

---------------------------------------------
--Signals
---------------------------------------------
signal ram			: stdLogicVectorArray(0 to 33)(dataWidth - 1 downto 0) := (others => (others => '0'));

begin
	process(clk)
	begin
		ram(0)				<= (others => '0');
		ram(32)			<= HI when mulEn = '1';
		ram(33)			<= LO when mulEn = '1';
		if rising_edge(clk) then
			if wrEn = '1' then
				ram(to_integer(unsigned(writeReg)))			<= writeData;
			end if;
			if HIEn = '1' then
				ram(to_integer(unsigned(writeReg)))		<= ram(32);
			end if; 
			if LOEn = '1' then
				ram(to_integer(unsigned(writeReg)))	<= ram(33);
			end if;
			readData1				<= ram(to_integer(unsigned(readReg1)));
			readData2				<= ram(to_integer(unsigned(readReg2)));
		end if;
	end process;
end architecture;

