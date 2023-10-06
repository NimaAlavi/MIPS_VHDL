library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	
entity MIPS is
	generic (
		dataWidth 			: integer := 32;
		addressWidth 		: integer := 20;
		fileName			: string := "C:/daneshgah/fpga/Project_1/constaint/asembly.txt"
	);
	Port ( 
		clk 					: in std_logic;
		rst 					: in std_logic;
		
		ENDERROR             : out std_logic
	);  
end entity;

architecture Behavioral of MIPS is

---------------------------------------------
--component
---------------------------------------------

component dataMemory is 
	generic (
		dataWidth 			: integer;
		addressWidth 		: integer;
		fileName			: string
	);
	Port ( 
		clk 					: in std_logic;

		rdEn				: in std_logic;
		wrEn 				: in std_logic;

		dataIn				: in std_logic_vector(dataWidth - 1 downto 0) := (others => '0');
		addr				: in unsigned(dataWidth - 1 downto 0);

		dataOut			: out std_logic_vector(dataWidth - 1 downto 0)
	);  
end component;

component ALU_main is 
	generic (
		dataWidth 			: integer := 32
	);
	Port ( 
		srcA				: in std_logic_vector(dataWidth - 1 downto 0);
		srcB				: in std_logic_vector(dataWidth - 1 downto 0);

		op					: in std_logic_vector(2 downto 0);
	
		zero				: out std_logic;
		nzero				: out std_logic;
		HI					: out std_logic_vector(dataWidth - 1 downto 0);
		LO					: out std_logic_vector(dataWidth - 1 downto 0);
		ALU_result			: out std_logic_vector(dataWidth - 1 downto 0)
	);  
end component;

component registerFile is
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
end component;

component ALU_control is
	Port ( 
		op					: in std_logic_vector(1 downto 0);
		func				: in std_logic_vector(5 downto 0);
		opcode				: in std_logic_vector(5 downto 0);
	
		ALU_result			: out std_logic_vector(2 downto 0)
	);  
end component;

component controlUnit is
	Port ( 
		clk 					: in std_logic;
		rst 					: in std_logic;
		
		opIn				: in std_logic_vector(5 downto 0);
		func				: in std_logic_vector(5 downto 0);
		jump				: in std_logic;
		
		mem2Reg			: out std_logic;
		regDst				: out std_logic_vector(1 downto 0);
		IorD				: out std_logic;
		IorDEn				: out std_logic;
		mulEn				: out std_logic;
		ALU_srcA			: out std_logic;
		pcSrc				: out std_logic_vector(1 downto 0); 
		ALU_srcB			: out std_logic_vector(1 downto 0);
		
		opOut				: out std_logic_vector(1 downto 0);
		
		memWrite			: out std_logic;
		pcWrite			: out std_logic;
		ENDERROR			: out std_logic;
		branch				: out std_logic;
		regWrite			: out std_logic;
		HIEn				: out std_logic;
		LOEn				: out std_logic
	);  
end component;

---------------------------------------------
--Signals
---------------------------------------------

-- PC --
signal pcEn 					: std_logic;
signal pcIn 						: std_logic_vector(dataWidth - 1 downto 0);
signal pcOut 					: std_logic_vector(dataWidth - 1 downto 0);

-- dataMemory --
-- signal dataMemoryRdEn			: std_logic;
signal dataMemoryAddrIn		: unsigned(dataWidth - 1 downto 0);
signal dataMemoryDataIn		: std_logic_vector(dataWidth - 1 downto 0);
signal dataMemoryDataOut	: std_logic_vector(dataWidth - 1 downto 0);

-- registerFile --
signal writeRegRF				: std_logic_vector(4 downto 0);
signal writeDataRF				: std_logic_vector(dataWidth - 1 downto 0);
signal readData1RF				: std_logic_vector(dataWidth - 1 downto 0);
signal readData2RF				: std_logic_vector(dataWidth - 1 downto 0);

-- AluMain --
signal srcA						: std_logic_vector(dataWidth - 1 downto 0);
signal srcB						: std_logic_vector(dataWidth - 1 downto 0);
signal aluMainControl			: std_logic_vector(2 downto 0);
signal aluZeros					: std_logic;
signal aluNzero					: std_logic;
signal aluResult					: std_logic_vector(dataWidth - 1 downto 0) := (others => '0');
signal mulHI					: std_logic_vector(dataWidth - 1 downto 0) := (others => '0');
signal mulLO					: std_logic_vector(dataWidth - 1 downto 0) := (others => '0');

-- ALU_control -- 
signal opAluControl			: std_logic_vector(1 downto 0);						
signal funcAluControl			: std_logic_vector(5 downto 0);						
signal aluControlResult			: std_logic_vector(2 downto 0);						

-- control_unit -- 
signal mem2Reg				: std_logic;
signal regDst					: std_logic_vector(1 downto 0);
signal IorD			 			: std_logic;
signal IorDEn		 			: std_logic;
signal IorDEn_r		 			: std_logic;
signal mulEn		 			: std_logic;
signal ALU_srcA		 			: std_logic;
signal pcSrc			 		: std_logic_vector(1 downto 0);
signal ALU_srcB		 			: std_logic_vector(1 downto 0);		
signal memWriteEn				: std_logic;
signal pcWrite					: std_logic;
signal branch					: std_logic;
signal jump						: std_logic;
signal regWriteEn				: std_logic;
signal HIEn						: std_logic;
signal LOEn						: std_logic;

-- External --
signal aluOut					: std_logic_vector(dataWidth - 1 downto 0);
signal instructionData			: std_logic_vector(dataWidth - 1 downto 0);
signal signExtendReg			: std_logic_vector(dataWidth - 1 downto 0);
signal dataMemoryDataOut_r	: std_logic_vector(dataWidth - 1 downto 0);


begin
	instructionData				<= dataMemoryDataOut when (pcWrite and IorDEn_r) = '1';
	dataMemoryDataIn			<= readData2RF;
	aluOut						<= aluResult;
	jump						<= (branch and aluZeros);
	
	controlUnit_Inst : controlUnit
		port map(
			clk 					=> clk,	
			rst 					=> rst,
			
			opIn				=> instructionData(31 downto 26),
			func				=> instructionData(5 downto 0),
			
			mem2Reg			=> mem2Reg,
			regDst				=> regDst,
			IorD				=> IorD,
			IorDEn				=> IorDEn,
			mulEn				=> mulEn,	 
			ALU_srcA			=> ALU_srcA,
			pcSrc				=> pcSrc,
			ALU_srcB			=> ALU_srcB,
			
			opOut				=> opAluControl,
			
			memWrite			=> memWriteEn,
			pcWrite			=> pcWrite,
			branch				=> branch,	
			ENDERROR			=> ENDERROR,
			jump				=> jump,	
			regWrite			=> regWriteEn,
			HIEn				=> HIEn,
			LOEn				=> LOEn
		);
	
	ALU_control_Inst : ALU_control
		port  map( 
			op					=> opAluControl,
			func				=> instructionData(5 downto 0),
			opcode				=> instructionData(31 downto 26),
		
			ALU_result			=> aluControlResult
		);  
		
	process(clk, rst)
	begin
		if rising_edge(clk) then
			pcOut			<= pcIn;
			IorDEn_r		<= IorDEn;
		end if;
		if rst = '1' then
			pcOut 			<= (others => '0');
		end if;
	end process;
	
	process(IorDEn)
	begin
		if IorD = '1' then
			dataMemoryAddrIn		<= unsigned(aluOut);
		else
			dataMemoryAddrIn		<= unsigned(pcOut);
		end if;
	end process;
	
	dataMemory_Inst : dataMemory
		generic map(
			dataWidth 			=> dataWidth,	
			addressWidth 		=> addressWidth,
			fileName			=> fileName
		)
		port map(
			clk 					=> clk,		

			rdEn				=> not(memWriteEn),
			wrEn 				=> memWriteEn,

			dataIn				=> dataMemoryDataIn,
			addr				=> dataMemoryAddrIn,

			dataOut			=> dataMemoryDataOut
		);
		
	process(clk)
	begin
		case regDst is
			when "00" => 
				writeRegRF				<= instructionData(20 downto 16);
			when "01" =>
				writeRegRF				<= instructionData(15 downto 11);
			when "10" => 
				writeRegRF				<= (others => '1');
			when others =>
				writeRegRF				<= (others => '0');
		end case;
		
		if mem2Reg = '1' then
			writeDataRF				<= dataMemoryDataOut;
		else
			writeDataRF				<= aluOut;
		end if;
	end process;
		
	registerFile_Inst : registerFile
		generic map(
			dataWidth			=> dataWidth
		)
		port map(
			clk 					=> clk,					
			
			wrEn				=> regWriteEn,
			HIEn				=> HIEn,
			LOEn				=> LOEn,

			readReg1			=> instructionData(25 downto 21), 
			readReg2			=> instructionData(20 downto 16),
			writeReg			=> writeRegRF,
	
			writeData			=> writeDataRF,
	
			mulEn				=> mulEn,	 
			HI			 		=> mulHI,
			LO			  		=> mulLO,

			readData1			=> readData1RF,
			readData2			=> readData2RF
		);

	process(ALU_srcA, ALU_srcB)
	begin
		if ALU_srcA = '1' then
			srcA					<= readData1RF;
		else
			srcA					<= pcOut;
		end if;
		
		case ALU_srcB is
			when "00" =>
				srcB				<= readData2RF;
			when "01" => 
				srcB				<= std_logic_vector(to_unsigned(1, dataWidth));
			when "10" =>
				srcB				<= std_logic_vector(resize(unsigned(instructionData(15 downto 0)), dataWidth));
			when "11" =>
				srcB				<= instructionData(15 downto 0) & x"0000";
			when others =>
				srcB				<= (others => '0');
		end case;
	end process;
	
	AluMain_Inst : ALU_main
		generic map(
			dataWidth			=> dataWidth
		)
		port map(
			srcA				=> srcA,
			srcB				=> srcB,
			
			op					=> aluControlResult,
			
			zero				=> aluZeros,
			nzero				=> aluNzero,
			HI					=> mulHI,
			LO					=> mulLO,
			ALU_result			=> aluResult
		);
			
	process(pcWrite, jump, rst)
	begin
		if (pcWrite or jump) = '1' then
			case pcSrc is
				when "00" => 
					pcIn					<= aluResult;
				when "01" => 
					pcIn					<= aluOut;
				when "10" => 	
					pcIn					<= "000000" & instructionData(25 downto 0);
				when others =>
					pcIn					<= (others => '0');
			end case;
		end if;
		
		if rst = '1' then
			pcIn					<= (others => '0');
		end if;
	end process;
end architecture;

