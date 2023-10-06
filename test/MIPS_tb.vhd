library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	
entity MIPS_tb is
	generic (
		dataWidth 			: integer := 32;
		addressWidth 		: integer := 30;
		fileName			: string := "C:/daneshgah/fpga/Project_1/constaint/asembly.txt"
	);
end entity;

architecture Behavioral of MIPS_tb is

---------------------------------------------
--component
---------------------------------------------
component MIPS is
	generic (
		dataWidth 			: integer;
		addressWidth 		: integer;
		fileName			: string
	);
	Port ( 
		clk 					: in std_logic;
		rst 					: in std_logic
	);  
end component;

---------------------------------------------
--Signals
---------------------------------------------
constant period					: time := 20 ns;
signal clk 						: std_logic;
signal rst 						: std_logic;

begin
	MIPS_Inst : MIPS
		generic map(
			dataWidth 				=> dataWidth,	
			addressWidth 			=> addressWidth,
			fileName				=> fileName
		)
		port map(
			clk						=> clk,
			rst						=> rst
		);
		
	process 
	begin
		rst					<= '1' after period/8;
		for i in 1 to 10 loop
			clk 			<= '0';
			wait for period/2;
			clk 			<= '1';
			wait for period/2;
		end loop;
		rst					<= '0'after period/8;
		
		for i in 1 to 500 loop
			clk 			<= '0';
			wait for period/2;
			clk 			<= '1';
			wait for period/2;
		end loop;
	
	wait;	
	end process;
end architecture;

