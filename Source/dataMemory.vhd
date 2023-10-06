library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	use std.textio.all;
	
entity dataMemory is
	generic (
		dataWidth 			: integer := 32;
		addressWidth 		: integer := 10;
		fileName			: string := "C:/daneshgah/fpga/Project_1/constaint/asembly.txt"
	);
	Port ( 
		clk 					: in std_logic;

		rdEn				: in std_logic;
		wrEn 				: in std_logic;

		dataIn				: in std_logic_vector(dataWidth - 1 downto 0) := (others => '0');
		addr				: in unsigned(dataWidth - 1 downto 0);

		dataOut			: out std_logic_vector(dataWidth - 1 downto 0)
	);  
end entity;

architecture Behavioral of dataMemory is

type stdLogicVectorArray is array(natural range <>) of  std_logic_vector;

---------------------------------------------
--Functions
---------------------------------------------
	impure function loadBinaryFile(fileName : string; dataWidth : natural; m : natural) return stdLogicVectorArray is
		file init			: text;
		variable Dbit 	: bit_vector(dataWidth - 1 downto 0);
		variable L		: line;
		variable R		: stdLogicVectorArray(0 to m - 1)(dataWidth - 1 downto 0) := (others => (others => '0'));
	begin 
		if fileName /=  "" then
			file_open (init, fileName, read_mode);
			for i in 0 to m - 1 loop
				if not endfile (init) then 
					readline(init, L);
					read (L, Dbit);
					r (i) := to_stdlogicvector(Dbit);
				end if;
			end loop;
		end if;
		return r;
	end function;
	
---------------------------------------------
--Signals
---------------------------------------------
signal ram					: stdLogicVectorArray(0 to 2**10 - 1)(dataWidth - 1 downto 0) := (loadBinaryFile(fileName, dataWidth, addressWidth), others => (others => '0')) ;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rdEn = '1' then 
				dataOut 					<= ram(to_integer(addr));
			end if;
			if wrEn = '1' then
				ram(to_integer(addr))		<= dataIn;
			end if;
		end if;
	end process;
end architecture;

