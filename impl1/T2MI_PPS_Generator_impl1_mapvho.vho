
-- VHDL netlist produced by program ldbanno, Version Diamond (64-bit) 3.14.0.75.2

-- ldbanno -n VHDL -o T2MI_PPS_Generator_impl1_mapvho.vho -w -neg -gui T2MI_PPS_Generator_impl1_map.ncd 
-- Netlist created on Sun Jun 08 20:50:30 2025
-- Netlist written on Sun Jun 08 20:50:44 2025
-- Design is for device LFE5U-25F
-- Design is for package CABGA256
-- Design is for performance grade 6

-- entity sapiobuf
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity sapiobuf is
    port (I: in Std_logic; PAD: out Std_logic);

    ATTRIBUTE Vital_Level0 OF sapiobuf : ENTITY IS TRUE;

  end sapiobuf;

  architecture Structure of sapiobuf is
  begin
    INST5: OB
      port map (I=>I, O=>PAD);
  end Structure;

-- entity pps_outB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity pps_outB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "pps_outB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_ppsout	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; ppsout: out Std_logic);

    ATTRIBUTE Vital_Level0 OF pps_outB : ENTITY IS TRUE;

  end pps_outB;

  architecture Structure of pps_outB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal ppsout_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    pps_out_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>ppsout_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, ppsout_out)
    VARIABLE ppsout_zd         	: std_logic := 'X';
    VARIABLE ppsout_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    ppsout_zd 	:= ppsout_out;

    VitalPathDelay01 (
      OutSignal => ppsout, OutSignalName => "ppsout", OutTemp => ppsout_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_ppsout,
                           PathCondition => TRUE)),
      GlitchData => ppsout_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity sapiobuf0001
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity sapiobuf0001 is
    port (Z: out Std_logic; PAD: in Std_logic);

    ATTRIBUTE Vital_Level0 OF sapiobuf0001 : ENTITY IS TRUE;

  end sapiobuf0001;

  architecture Structure of sapiobuf0001 is
  begin
    INST1: IBPD
      port map (I=>PAD, O=>Z);
  end Structure;

-- entity clk_100mhzB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity clk_100mhzB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "clk_100mhzB";

      tipd_clk100mhz  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_clk100mhz_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_clk100mhz 	: VitalDelayType := 0 ns;
      tpw_clk100mhz_posedge	: VitalDelayType := 0 ns;
      tpw_clk100mhz_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; clk100mhz: in Std_logic);

    ATTRIBUTE Vital_Level0 OF clk_100mhzB : ENTITY IS TRUE;

  end clk_100mhzB;

  architecture Structure of clk_100mhzB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal clk100mhz_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    clk_100mhz_pad: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>clk100mhz_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(clk100mhz_ipd, clk100mhz, tipd_clk100mhz);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, clk100mhz_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_clk100mhz_clk100mhz          	: x01 := '0';
    VARIABLE periodcheckinfo_clk100mhz	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => clk100mhz_ipd,
        TestSignalName => "clk100mhz",
        Period => tperiod_clk100mhz,
        PulseWidthHigh => tpw_clk100mhz_posedge,
        PulseWidthLow => tpw_clk100mhz_negedge,
        PeriodData => periodcheckinfo_clk100mhz,
        Violation => tviol_clk100mhz_clk100mhz,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => clk100mhz_ipd'last_event,
                           PathDelay => tpd_clk100mhz_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity led_errorB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity led_errorB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "led_errorB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_lederror	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; lederror: out Std_logic);

    ATTRIBUTE Vital_Level0 OF led_errorB : ENTITY IS TRUE;

  end led_errorB;

  architecture Structure of led_errorB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal lederror_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    led_error_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>lederror_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, lederror_out)
    VARIABLE lederror_zd         	: std_logic := 'X';
    VARIABLE lederror_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    lederror_zd 	:= lederror_out;

    VitalPathDelay01 (
      OutSignal => lederror, OutSignalName => "lederror", OutTemp => lederror_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_lederror,
                           PathCondition => TRUE)),
      GlitchData => lederror_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity led_ppsB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity led_ppsB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "led_ppsB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_ledpps	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; ledpps: out Std_logic);

    ATTRIBUTE Vital_Level0 OF led_ppsB : ENTITY IS TRUE;

  end led_ppsB;

  architecture Structure of led_ppsB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal ledpps_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    led_pps_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>ledpps_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, ledpps_out)
    VARIABLE ledpps_zd         	: std_logic := 'X';
    VARIABLE ledpps_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    ledpps_zd 	:= ledpps_out;

    VitalPathDelay01 (
      OutSignal => ledpps, OutSignalName => "ledpps", OutTemp => ledpps_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_ledpps,
                           PathCondition => TRUE)),
      GlitchData => ledpps_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity led_syncB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity led_syncB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "led_syncB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_ledsync	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; ledsync: out Std_logic);

    ATTRIBUTE Vital_Level0 OF led_syncB : ENTITY IS TRUE;

  end led_syncB;

  architecture Structure of led_syncB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal ledsync_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    led_sync_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>ledsync_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, ledsync_out)
    VARIABLE ledsync_zd         	: std_logic := 'X';
    VARIABLE ledsync_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    ledsync_zd 	:= ledsync_out;

    VitalPathDelay01 (
      OutSignal => ledsync, OutSignalName => "ledsync", OutTemp => ledsync_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_ledsync,
                           PathCondition => TRUE)),
      GlitchData => ledsync_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity led_powerB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity led_powerB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "led_powerB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_ledpower	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; ledpower: out Std_logic);

    ATTRIBUTE Vital_Level0 OF led_powerB : ENTITY IS TRUE;

  end led_powerB;

  architecture Structure of led_powerB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal ledpower_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    led_power_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>ledpower_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, ledpower_out)
    VARIABLE ledpower_zd         	: std_logic := 'X';
    VARIABLE ledpower_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    ledpower_zd 	:= ledpower_out;

    VitalPathDelay01 (
      OutSignal => ledpower, OutSignalName => "ledpower", OutTemp => ledpower_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_ledpower,
                           PathCondition => TRUE)),
      GlitchData => ledpower_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_7_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_7_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_7_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus7	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus7: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_7_B : ENTITY IS TRUE;

  end debug_status_7_B;

  architecture Structure of debug_status_7_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus7_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_7: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus7_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus7_out)
    VARIABLE debugstatus7_zd         	: std_logic := 'X';
    VARIABLE debugstatus7_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus7_zd 	:= debugstatus7_out;

    VitalPathDelay01 (

        OutSignal => debugstatus7, OutSignalName => "debugstatus7", OutTemp => debugstatus7_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus7,
                           PathCondition => TRUE)),
      GlitchData => debugstatus7_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_6_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_6_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_6_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus6	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus6: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_6_B : ENTITY IS TRUE;

  end debug_status_6_B;

  architecture Structure of debug_status_6_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus6_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_6: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus6_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus6_out)
    VARIABLE debugstatus6_zd         	: std_logic := 'X';
    VARIABLE debugstatus6_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus6_zd 	:= debugstatus6_out;

    VitalPathDelay01 (

        OutSignal => debugstatus6, OutSignalName => "debugstatus6", OutTemp => debugstatus6_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus6,
                           PathCondition => TRUE)),
      GlitchData => debugstatus6_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_5_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_5_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_5_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus5	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus5: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_5_B : ENTITY IS TRUE;

  end debug_status_5_B;

  architecture Structure of debug_status_5_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus5_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_5: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus5_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus5_out)
    VARIABLE debugstatus5_zd         	: std_logic := 'X';
    VARIABLE debugstatus5_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus5_zd 	:= debugstatus5_out;

    VitalPathDelay01 (

        OutSignal => debugstatus5, OutSignalName => "debugstatus5", OutTemp => debugstatus5_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus5,
                           PathCondition => TRUE)),
      GlitchData => debugstatus5_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_4_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_4_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_4_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus4	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus4: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_4_B : ENTITY IS TRUE;

  end debug_status_4_B;

  architecture Structure of debug_status_4_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus4_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_4: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus4_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus4_out)
    VARIABLE debugstatus4_zd         	: std_logic := 'X';
    VARIABLE debugstatus4_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus4_zd 	:= debugstatus4_out;

    VitalPathDelay01 (

        OutSignal => debugstatus4, OutSignalName => "debugstatus4", OutTemp => debugstatus4_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus4,
                           PathCondition => TRUE)),
      GlitchData => debugstatus4_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_3_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_3_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_3_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus3	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus3: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_3_B : ENTITY IS TRUE;

  end debug_status_3_B;

  architecture Structure of debug_status_3_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus3_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_3: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus3_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus3_out)
    VARIABLE debugstatus3_zd         	: std_logic := 'X';
    VARIABLE debugstatus3_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus3_zd 	:= debugstatus3_out;

    VitalPathDelay01 (

        OutSignal => debugstatus3, OutSignalName => "debugstatus3", OutTemp => debugstatus3_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus3,
                           PathCondition => TRUE)),
      GlitchData => debugstatus3_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_2_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_2_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus2	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus2: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_2_B : ENTITY IS TRUE;

  end debug_status_2_B;

  architecture Structure of debug_status_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus2_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_2: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus2_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus2_out)
    VARIABLE debugstatus2_zd         	: std_logic := 'X';
    VARIABLE debugstatus2_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus2_zd 	:= debugstatus2_out;

    VitalPathDelay01 (

        OutSignal => debugstatus2, OutSignalName => "debugstatus2", OutTemp => debugstatus2_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus2,
                           PathCondition => TRUE)),
      GlitchData => debugstatus2_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_1_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_1_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus1	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_1_B : ENTITY IS TRUE;

  end debug_status_1_B;

  architecture Structure of debug_status_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus1_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_1: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus1_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus1_out)
    VARIABLE debugstatus1_zd         	: std_logic := 'X';
    VARIABLE debugstatus1_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus1_zd 	:= debugstatus1_out;

    VitalPathDelay01 (

        OutSignal => debugstatus1, OutSignalName => "debugstatus1", OutTemp => debugstatus1_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus1,
                           PathCondition => TRUE)),
      GlitchData => debugstatus1_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity debug_status_0_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity debug_status_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "debug_status_0_B";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_debugstatus0	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; debugstatus0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF debug_status_0_B : ENTITY IS TRUE;

  end debug_status_0_B;

  architecture Structure of debug_status_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal debugstatus0_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    debug_status_pad_0: sapiobuf
      port map (I=>PADDO_ipd, PAD=>debugstatus0_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, debugstatus0_out)
    VARIABLE debugstatus0_zd         	: std_logic := 'X';
    VARIABLE debugstatus0_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    debugstatus0_zd 	:= debugstatus0_out;

    VitalPathDelay01 (

        OutSignal => debugstatus0, OutSignalName => "debugstatus0", OutTemp => debugstatus0_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_debugstatus0,
                           PathCondition => TRUE)),
      GlitchData => debugstatus0_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity sync_lockedB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity sync_lockedB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "sync_lockedB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_synclocked	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; synclocked: out Std_logic);

    ATTRIBUTE Vital_Level0 OF sync_lockedB : ENTITY IS TRUE;

  end sync_lockedB;

  architecture Structure of sync_lockedB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal synclocked_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    sync_locked_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>synclocked_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, synclocked_out)
    VARIABLE synclocked_zd         	: std_logic := 'X';
    VARIABLE synclocked_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    synclocked_zd 	:= synclocked_out;

    VitalPathDelay01 (

        OutSignal => synclocked, OutSignalName => "synclocked", OutTemp => synclocked_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_synclocked,
                           PathCondition => TRUE)),
      GlitchData => synclocked_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity timestamp_validB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity timestamp_validB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "timestamp_validB";

      tipd_PADDO  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_PADDO_timestampvalid	 : VitalDelayType01 := (0 ns, 0 ns));

    port (PADDO: in Std_logic; timestampvalid: out Std_logic);

    ATTRIBUTE Vital_Level0 OF timestamp_validB : ENTITY IS TRUE;

  end timestamp_validB;

  architecture Structure of timestamp_validB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDO_ipd 	: std_logic := 'X';
    signal timestampvalid_out 	: std_logic := 'X';

    component sapiobuf
      port (I: in Std_logic; PAD: out Std_logic);
    end component;
  begin
    timestamp_valid_pad: sapiobuf
      port map (I=>PADDO_ipd, PAD=>timestampvalid_out);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(PADDO_ipd, PADDO, tipd_PADDO);
    END BLOCK;

    VitalBehavior : PROCESS (PADDO_ipd, timestampvalid_out)
    VARIABLE timestampvalid_zd         	: std_logic := 'X';
    VARIABLE timestampvalid_GlitchData 	: VitalGlitchDataType;


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;

    timestampvalid_zd 	:= timestampvalid_out;

    VitalPathDelay01 (

        OutSignal => timestampvalid, OutSignalName => "timestampvalid", OutTemp => timestampvalid_zd,
      Paths      => (0 => (InputChangeTime => PADDO_ipd'last_event,
                           PathDelay => tpd_PADDO_timestampvalid,
                           PathCondition => TRUE)),
      GlitchData => timestampvalid_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_7_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_7_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_7_B";

      tipd_t2midata7  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata7_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata7 	: VitalDelayType := 0 ns;
      tpw_t2midata7_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata7_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata7: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_7_B : ENTITY IS TRUE;

  end t2mi_data_7_B;

  architecture Structure of t2mi_data_7_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata7_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_7: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata7_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata7_ipd, t2midata7, tipd_t2midata7);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata7_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata7_t2midata7          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata7	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata7_ipd,
        TestSignalName => "t2midata7",
        Period => tperiod_t2midata7,
        PulseWidthHigh => tpw_t2midata7_posedge,
        PulseWidthLow => tpw_t2midata7_negedge,
        PeriodData => periodcheckinfo_t2midata7,
        Violation => tviol_t2midata7_t2midata7,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata7_ipd'last_event,
                           PathDelay => tpd_t2midata7_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity smuxlregsre
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity smuxlregsre is
    port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
          LSR: in Std_logic; Q: out Std_logic);

    ATTRIBUTE Vital_Level0 OF smuxlregsre : ENTITY IS TRUE;

  end smuxlregsre;

  architecture Structure of smuxlregsre is
  begin
    INST01: IFS1P3DX
      generic map (GSR => "ENABLED")
      port map (D=>D0, SP=>SP, SCLK=>CK, CD=>LSR, Q=>Q);
  end Structure;

-- entity vcc
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity vcc is
    port (PWR1: out Std_logic);

    ATTRIBUTE Vital_Level0 OF vcc : ENTITY IS TRUE;

  end vcc;

  architecture Structure of vcc is
  begin
    INST1: VHI
      port map (Z=>PWR1);
  end Structure;

-- entity gnd
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity gnd is
    port (PWR0: out Std_logic);

    ATTRIBUTE Vital_Level0 OF gnd : ENTITY IS TRUE;

  end gnd;

  architecture Structure of gnd is
  begin
    INST1: VLO
      port map (Z=>PWR0);
  end Structure;

-- entity t2mi_data_7_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_7_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_7_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_7_MGIOL : ENTITY IS TRUE;

  end t2mi_data_7_MGIOL;

  architecture Structure of t2mi_data_7_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_7: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_6_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_6_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_6_B";

      tipd_t2midata6  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata6_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata6 	: VitalDelayType := 0 ns;
      tpw_t2midata6_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata6_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata6: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_6_B : ENTITY IS TRUE;

  end t2mi_data_6_B;

  architecture Structure of t2mi_data_6_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata6_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_6: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata6_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata6_ipd, t2midata6, tipd_t2midata6);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata6_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata6_t2midata6          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata6	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata6_ipd,
        TestSignalName => "t2midata6",
        Period => tperiod_t2midata6,
        PulseWidthHigh => tpw_t2midata6_posedge,
        PulseWidthLow => tpw_t2midata6_negedge,
        PeriodData => periodcheckinfo_t2midata6,
        Violation => tviol_t2midata6_t2midata6,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata6_ipd'last_event,
                           PathDelay => tpd_t2midata6_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_6_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_6_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_6_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_6_MGIOL : ENTITY IS TRUE;

  end t2mi_data_6_MGIOL;

  architecture Structure of t2mi_data_6_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_6: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_5_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_5_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_5_B";

      tipd_t2midata5  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata5_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata5 	: VitalDelayType := 0 ns;
      tpw_t2midata5_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata5_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata5: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_5_B : ENTITY IS TRUE;

  end t2mi_data_5_B;

  architecture Structure of t2mi_data_5_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata5_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_5: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata5_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata5_ipd, t2midata5, tipd_t2midata5);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata5_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata5_t2midata5          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata5	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata5_ipd,
        TestSignalName => "t2midata5",
        Period => tperiod_t2midata5,
        PulseWidthHigh => tpw_t2midata5_posedge,
        PulseWidthLow => tpw_t2midata5_negedge,
        PeriodData => periodcheckinfo_t2midata5,
        Violation => tviol_t2midata5_t2midata5,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata5_ipd'last_event,
                           PathDelay => tpd_t2midata5_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_5_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_5_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_5_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_5_MGIOL : ENTITY IS TRUE;

  end t2mi_data_5_MGIOL;

  architecture Structure of t2mi_data_5_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_5: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_4_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_4_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_4_B";

      tipd_t2midata4  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata4_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata4 	: VitalDelayType := 0 ns;
      tpw_t2midata4_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata4_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata4: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_4_B : ENTITY IS TRUE;

  end t2mi_data_4_B;

  architecture Structure of t2mi_data_4_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata4_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_4: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata4_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata4_ipd, t2midata4, tipd_t2midata4);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata4_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata4_t2midata4          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata4	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata4_ipd,
        TestSignalName => "t2midata4",
        Period => tperiod_t2midata4,
        PulseWidthHigh => tpw_t2midata4_posedge,
        PulseWidthLow => tpw_t2midata4_negedge,
        PeriodData => periodcheckinfo_t2midata4,
        Violation => tviol_t2midata4_t2midata4,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata4_ipd'last_event,
                           PathDelay => tpd_t2midata4_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_4_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_4_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_4_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_4_MGIOL : ENTITY IS TRUE;

  end t2mi_data_4_MGIOL;

  architecture Structure of t2mi_data_4_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_4: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_3_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_3_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_3_B";

      tipd_t2midata3  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata3_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata3 	: VitalDelayType := 0 ns;
      tpw_t2midata3_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata3_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata3: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_3_B : ENTITY IS TRUE;

  end t2mi_data_3_B;

  architecture Structure of t2mi_data_3_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata3_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_3: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata3_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata3_ipd, t2midata3, tipd_t2midata3);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata3_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata3_t2midata3          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata3	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata3_ipd,
        TestSignalName => "t2midata3",
        Period => tperiod_t2midata3,
        PulseWidthHigh => tpw_t2midata3_posedge,
        PulseWidthLow => tpw_t2midata3_negedge,
        PeriodData => periodcheckinfo_t2midata3,
        Violation => tviol_t2midata3_t2midata3,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata3_ipd'last_event,
                           PathDelay => tpd_t2midata3_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_3_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_3_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_3_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_3_MGIOL : ENTITY IS TRUE;

  end t2mi_data_3_MGIOL;

  architecture Structure of t2mi_data_3_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_3: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_2_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_2_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_2_B";

      tipd_t2midata2  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata2_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata2 	: VitalDelayType := 0 ns;
      tpw_t2midata2_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata2_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata2: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_2_B : ENTITY IS TRUE;

  end t2mi_data_2_B;

  architecture Structure of t2mi_data_2_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata2_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_2: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata2_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata2_ipd, t2midata2, tipd_t2midata2);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata2_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata2_t2midata2          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata2	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata2_ipd,
        TestSignalName => "t2midata2",
        Period => tperiod_t2midata2,
        PulseWidthHigh => tpw_t2midata2_posedge,
        PulseWidthLow => tpw_t2midata2_negedge,
        PeriodData => periodcheckinfo_t2midata2,
        Violation => tviol_t2midata2_t2midata2,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata2_ipd'last_event,
                           PathDelay => tpd_t2midata2_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_2_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_2_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_2_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_2_MGIOL : ENTITY IS TRUE;

  end t2mi_data_2_MGIOL;

  architecture Structure of t2mi_data_2_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_2: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_1_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_1_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_1_B";

      tipd_t2midata1  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata1_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata1 	: VitalDelayType := 0 ns;
      tpw_t2midata1_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata1_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata1: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_1_B : ENTITY IS TRUE;

  end t2mi_data_1_B;

  architecture Structure of t2mi_data_1_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata1_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_1: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata1_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata1_ipd, t2midata1, tipd_t2midata1);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata1_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata1_t2midata1          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata1	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata1_ipd,
        TestSignalName => "t2midata1",
        Period => tperiod_t2midata1,
        PulseWidthHigh => tpw_t2midata1_posedge,
        PulseWidthLow => tpw_t2midata1_negedge,
        PeriodData => periodcheckinfo_t2midata1,
        Violation => tviol_t2midata1_t2midata1,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata1_ipd'last_event,
                           PathDelay => tpd_t2midata1_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_1_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_1_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_1_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_1_MGIOL : ENTITY IS TRUE;

  end t2mi_data_1_MGIOL;

  architecture Structure of t2mi_data_1_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_1: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_0_B
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_0_B is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_0_B";

      tipd_t2midata0  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2midata0_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2midata0 	: VitalDelayType := 0 ns;
      tpw_t2midata0_posedge	: VitalDelayType := 0 ns;
      tpw_t2midata0_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2midata0: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_0_B : ENTITY IS TRUE;

  end t2mi_data_0_B;

  architecture Structure of t2mi_data_0_B is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2midata0_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_data_pad_0: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2midata0_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2midata0_ipd, t2midata0, tipd_t2midata0);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2midata0_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2midata0_t2midata0          	: x01 := '0';
    VARIABLE periodcheckinfo_t2midata0	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2midata0_ipd,
        TestSignalName => "t2midata0",
        Period => tperiod_t2midata0,
        PulseWidthHigh => tpw_t2midata0_posedge,
        PulseWidthLow => tpw_t2midata0_negedge,
        PeriodData => periodcheckinfo_t2midata0,
        Violation => tviol_t2midata0_t2midata0,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2midata0_ipd'last_event,
                           PathDelay => tpd_t2midata0_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_data_0_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_data_0_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_data_0_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_data_0_MGIOL : ENTITY IS TRUE;

  end t2mi_data_0_MGIOL;

  architecture Structure of t2mi_data_0_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_data_syncio_0: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_validB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_validB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_validB";

      tipd_t2mivalid  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_t2mivalid_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_t2mivalid 	: VitalDelayType := 0 ns;
      tpw_t2mivalid_posedge	: VitalDelayType := 0 ns;
      tpw_t2mivalid_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; t2mivalid: in Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_validB : ENTITY IS TRUE;

  end t2mi_validB;

  architecture Structure of t2mi_validB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal t2mivalid_ipd 	: std_logic := 'X';

    component sapiobuf0001
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    t2mi_valid_pad: sapiobuf0001
      port map (Z=>PADDI_out, PAD=>t2mivalid_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(t2mivalid_ipd, t2mivalid, tipd_t2mivalid);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, t2mivalid_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_t2mivalid_t2mivalid          	: x01 := '0';
    VARIABLE periodcheckinfo_t2mivalid	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => t2mivalid_ipd,
        TestSignalName => "t2mivalid",
        Period => tperiod_t2mivalid,
        PulseWidthHigh => tpw_t2mivalid_posedge,
        PulseWidthLow => tpw_t2mivalid_negedge,
        PeriodData => periodcheckinfo_t2mivalid,
        Violation => tviol_t2mivalid_t2mivalid,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => t2mivalid_ipd'last_event,
                           PathDelay => tpd_t2mivalid_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity t2mi_valid_MGIOL
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_valid_MGIOL is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "t2mi_valid_MGIOL";

      tipd_DI  	: VitalDelayType01 := (0 ns, 0 ns);
      tipd_CLK  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_CLK_INFF	 : VitalDelayType01 := (0 ns, 0 ns);
      ticd_CLK	: VitalDelayType := 0 ns;
      tisd_DI_CLK	: VitalDelayType := 0 ns;
      tsetup_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      thold_DI_CLK_noedge_posedge	: VitalDelayType := 0 ns;
      tperiod_CLK 	: VitalDelayType := 0 ns;
      tpw_CLK_posedge	: VitalDelayType := 0 ns;
      tpw_CLK_negedge	: VitalDelayType := 0 ns);

    port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);

    ATTRIBUTE Vital_Level0 OF t2mi_valid_MGIOL : ENTITY IS TRUE;

  end t2mi_valid_MGIOL;

  architecture Structure of t2mi_valid_MGIOL is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal DI_ipd 	: std_logic := 'X';
    signal DI_dly 	: std_logic := 'X';
    signal CLK_ipd 	: std_logic := 'X';
    signal CLK_dly 	: std_logic := 'X';
    signal INFF_out 	: std_logic := 'X';

    signal VCCI: Std_logic;
    signal GNDI: Std_logic;
    component gnd
      port (PWR0: out Std_logic);
    end component;
    component smuxlregsre
      port (D0: in Std_logic; SP: in Std_logic; CK: in Std_logic; 
            LSR: in Std_logic; Q: out Std_logic);
    end component;
    component vcc
      port (PWR1: out Std_logic);
    end component;
  begin
    parser_inst_t2mi_valid_syncio: smuxlregsre
      port map (D0=>DI_dly, SP=>VCCI, CK=>CLK_dly, LSR=>GNDI, Q=>INFF_out);
    DRIVEVCC: vcc
      port map (PWR1=>VCCI);
    DRIVEGND: gnd
      port map (PWR0=>GNDI);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(DI_ipd, DI, tipd_DI);
      VitalWireDelay(CLK_ipd, CLK, tipd_CLK);
    END BLOCK;

    --  Setup and Hold DELAYs
    SignalDelay : BLOCK
    BEGIN
      VitalSignalDelay(DI_dly, DI_ipd, tisd_DI_CLK);
      VitalSignalDelay(CLK_dly, CLK_ipd, ticd_CLK);
    END BLOCK;

    VitalBehavior : PROCESS (DI_dly, CLK_dly, INFF_out)
    VARIABLE INFF_zd         	: std_logic := 'X';
    VARIABLE INFF_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_DI_CLK       	: x01 := '0';
    VARIABLE DI_CLK_TimingDatash	: VitalTimingDataType;
    VARIABLE tviol_CLK_CLK          	: x01 := '0';
    VARIABLE periodcheckinfo_CLK	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalSetupHoldCheck (
        TestSignal => DI_dly,
        TestSignalName => "DI",
        TestDelay => tisd_DI_CLK,
        RefSignal => CLK_dly,
        RefSignalName => "CLK",
        RefDelay => ticd_CLK,
        SetupHigh => tsetup_DI_CLK_noedge_posedge,
        SetupLow => tsetup_DI_CLK_noedge_posedge,
        HoldHigh => thold_DI_CLK_noedge_posedge,
        HoldLow => thold_DI_CLK_noedge_posedge,
        CheckEnabled => TRUE,
        RefTransition => '/',
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        TimingData => DI_CLK_TimingDatash,
        Violation => tviol_DI_CLK,
        MsgSeverity => warning);
      VitalPeriodPulseCheck (
        TestSignal => CLK_ipd,
        TestSignalName => "CLK",
        Period => tperiod_CLK,
        PulseWidthHigh => tpw_CLK_posedge,
        PulseWidthLow => tpw_CLK_negedge,
        PeriodData => periodcheckinfo_CLK,
        Violation => tviol_CLK_CLK,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    INFF_zd 	:= INFF_out;

    VitalPathDelay01 (
      OutSignal => INFF, OutSignalName => "INFF", OutTemp => INFF_zd,
      Paths      => (0 => (InputChangeTime => CLK_dly'last_event,
                           PathDelay => tpd_CLK_INFF,
                           PathCondition => TRUE)),
      GlitchData => INFF_GlitchData,
      Mode       => ondetect, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity sapiobuf0002
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity sapiobuf0002 is
    port (Z: out Std_logic; PAD: in Std_logic);

    ATTRIBUTE Vital_Level0 OF sapiobuf0002 : ENTITY IS TRUE;

  end sapiobuf0002;

  architecture Structure of sapiobuf0002 is
  begin
    INST1: IBPU
      port map (I=>PAD, O=>Z);
  end Structure;

-- entity rst_nB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity rst_nB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "rst_nB";

      tipd_rstn  	: VitalDelayType01 := (0 ns, 0 ns);
      tpd_rstn_PADDI	 : VitalDelayType01 := (0 ns, 0 ns);
      tperiod_rstn 	: VitalDelayType := 0 ns;
      tpw_rstn_posedge	: VitalDelayType := 0 ns;
      tpw_rstn_negedge	: VitalDelayType := 0 ns);

    port (PADDI: out Std_logic; rstn: in Std_logic);

    ATTRIBUTE Vital_Level0 OF rst_nB : ENTITY IS TRUE;

  end rst_nB;

  architecture Structure of rst_nB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal PADDI_out 	: std_logic := 'X';
    signal rstn_ipd 	: std_logic := 'X';

    component sapiobuf0002
      port (Z: out Std_logic; PAD: in Std_logic);
    end component;
  begin
    rst_n_pad: sapiobuf0002
      port map (Z=>PADDI_out, PAD=>rstn_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(rstn_ipd, rstn, tipd_rstn);
    END BLOCK;

    VitalBehavior : PROCESS (PADDI_out, rstn_ipd)
    VARIABLE PADDI_zd         	: std_logic := 'X';
    VARIABLE PADDI_GlitchData 	: VitalGlitchDataType;

    VARIABLE tviol_rstn_rstn          	: x01 := '0';
    VARIABLE periodcheckinfo_rstn	: VitalPeriodDataType;

    BEGIN

    IF (TimingChecksOn) THEN
      VitalPeriodPulseCheck (
        TestSignal => rstn_ipd,
        TestSignalName => "rstn",
        Period => tperiod_rstn,
        PulseWidthHigh => tpw_rstn_posedge,
        PulseWidthLow => tpw_rstn_negedge,
        PeriodData => periodcheckinfo_rstn,
        Violation => tviol_rstn_rstn,
        MsgOn => MsgOn, XOn => XOn,
        HeaderMsg => InstancePath,
        CheckEnabled => TRUE,
        MsgSeverity => warning);

    END IF;

    PADDI_zd 	:= PADDI_out;

    VitalPathDelay01 (
      OutSignal => PADDI, OutSignalName => "PADDI", OutTemp => PADDI_zd,
      Paths      => (0 => (InputChangeTime => rstn_ipd'last_event,
                           PathDelay => tpd_rstn_PADDI,
                           PathCondition => TRUE)),
      GlitchData => PADDI_GlitchData,
      Mode       => vitaltransport, XOn => XOn, MsgOn => MsgOn);

    END PROCESS;

  end Structure;

-- entity GSR5MODE
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity GSR5MODE is
    port (GSRP: in Std_logic);

    ATTRIBUTE Vital_Level0 OF GSR5MODE : ENTITY IS TRUE;

  end GSR5MODE;

  architecture Structure of GSR5MODE is
    signal GSRMODE: Std_logic;
  begin
    INST10: BUFBA
      port map (A=>GSRP, Z=>GSRMODE);
    INST20: GSR
      port map (GSR=>GSRMODE);
  end Structure;

-- entity GSR_INSTB
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity GSR_INSTB is
    -- miscellaneous vital GENERICs
    GENERIC (
      TimingChecksOn	: boolean := TRUE;
      XOn           	: boolean := FALSE;
      MsgOn         	: boolean := TRUE;
      InstancePath  	: string := "GSR_INSTB";

      tipd_GSRNET  	: VitalDelayType01 := (0 ns, 0 ns));

    port (GSRNET: in Std_logic);

    ATTRIBUTE Vital_Level0 OF GSR_INSTB : ENTITY IS TRUE;

  end GSR_INSTB;

  architecture Structure of GSR_INSTB is
    ATTRIBUTE Vital_Level0 OF Structure : ARCHITECTURE IS TRUE;

    signal GSRNET_ipd 	: std_logic := 'X';

    component GSR5MODE
      port (GSRP: in Std_logic);
    end component;
  begin
    GSR_INST_GSRMODE: GSR5MODE
      port map (GSRP=>GSRNET_ipd);

    --  INPUT PATH DELAYs
    WireDelay : BLOCK
    BEGIN
      VitalWireDelay(GSRNET_ipd, GSRNET, tipd_GSRNET);
    END BLOCK;

    VitalBehavior : PROCESS (GSRNET_ipd)


    BEGIN

    IF (TimingChecksOn) THEN

    END IF;



    END PROCESS;

  end Structure;

-- entity t2mi_pps_top
  library IEEE, vital2000, ECP5U;
  use IEEE.STD_LOGIC_1164.all;
  use vital2000.vital_timing.all;
  use ECP5U.COMPONENTS.ALL;

  entity t2mi_pps_top is
    port (clk_100mhz: in Std_logic; rst_n: in Std_logic; 
          t2mi_clk: in Std_logic; t2mi_valid: in Std_logic; 
          t2mi_data: in Std_logic_vector (7 downto 0); t2mi_sync: in Std_logic; 
          pps_out: out Std_logic; timestamp_valid: out Std_logic; 
          sync_locked: out Std_logic; 
          debug_status: out Std_logic_vector (7 downto 0); 
          led_power: out Std_logic; led_sync: out Std_logic; 
          led_pps: out Std_logic; led_error: out Std_logic);



  end t2mi_pps_top;

  architecture Structure of t2mi_pps_top is
    signal pps_inst_subsec_counter_0: Std_logic;
    signal subseconds_0: Std_logic;
    signal debug_status_c_3: Std_logic;
    signal pps_inst_time_valid: Std_logic;
    signal pps_inst_subsec_counter_6_cry_0: Std_logic;
    signal pps_inst_subsec_counter_6_axb_2: Std_logic;
    signal pps_inst_subsec_counter_6_axb_1: Std_logic;
    signal pps_inst_subsec_counter_6_2: Std_logic;
    signal pps_inst_subsec_counter_6_1: Std_logic;
    signal clk_100mhz_c: Std_logic;
    signal pps_inst_subsec_counter_1: Std_logic;
    signal pps_inst_subsec_counter_2: Std_logic;
    signal pps_inst_subsec_counter_6_cry_2: Std_logic;
    signal pps_inst_subsec_counter_6_axb_4: Std_logic;
    signal pps_inst_subsec_counter_6_cry_3_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_3: Std_logic;
    signal pps_inst_subsec_counter_6_4: Std_logic;
    signal pps_inst_subsec_counter_6_3: Std_logic;
    signal pps_inst_subsec_counter_4: Std_logic;
    signal pps_inst_subsec_counter_6_cry_4: Std_logic;
    signal pps_inst_subsec_counter_6_axb_6: Std_logic;
    signal pps_inst_subsec_counter_6_cry_5_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_5: Std_logic;
    signal pps_inst_subsec_counter_6_6: Std_logic;
    signal pps_inst_subsec_counter_6_5: Std_logic;
    signal pps_inst_subsec_counter_6: Std_logic;
    signal pps_inst_subsec_counter_6_cry_6: Std_logic;
    signal pps_inst_subsec_counter_6_axb_8: Std_logic;
    signal pps_inst_subsec_counter_6_axb_7: Std_logic;
    signal pps_inst_subsec_counter_6_8: Std_logic;
    signal pps_inst_subsec_counter_6_7: Std_logic;
    signal pps_inst_subsec_counter_7: Std_logic;
    signal pps_inst_subsec_counter_8: Std_logic;
    signal pps_inst_subsec_counter_6_cry_8: Std_logic;
    signal pps_inst_subsec_counter_6_cry_9_0_RNO_0: Std_logic;
    signal pps_inst_subsec_counter_10: Std_logic;
    signal pps_inst_subsec_counter_6_axb_9: Std_logic;
    signal pps_inst_subsec_counter_6_10: Std_logic;
    signal pps_inst_subsec_counter_6_9: Std_logic;
    signal pps_inst_subsec_counter_9: Std_logic;
    signal pps_inst_subsec_counter_6_cry_10: Std_logic;
    signal pps_inst_subsec_counter_6_cry_11_0_RNO_0: Std_logic;
    signal pps_inst_subsec_counter_12: Std_logic;
    signal pps_inst_subsec_counter_6_cry_11_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_11: Std_logic;
    signal pps_inst_subsec_counter_6_12: Std_logic;
    signal pps_inst_subsec_counter_6_11: Std_logic;
    signal pps_inst_subsec_counter_6_cry_12: Std_logic;
    signal pps_inst_subsec_counter_6_cry_13_0_RNO_0: Std_logic;
    signal pps_inst_subsec_counter_14: Std_logic;
    signal pps_inst_subsec_counter_6_axb_13: Std_logic;
    signal pps_inst_subsec_counter_6_14: Std_logic;
    signal pps_inst_subsec_counter_6_13: Std_logic;
    signal pps_inst_subsec_counter_13: Std_logic;
    signal pps_inst_subsec_counter_6_cry_14: Std_logic;
    signal pps_inst_subsec_counter_6_cry_15_0_RNO_0: Std_logic;
    signal pps_inst_subsec_counter_16: Std_logic;
    signal pps_inst_subsec_counter_6_axb_15: Std_logic;
    signal pps_inst_subsec_counter_6_16: Std_logic;
    signal pps_inst_subsec_counter_6_15: Std_logic;
    signal pps_inst_subsec_counter_15: Std_logic;
    signal pps_inst_subsec_counter_6_cry_16: Std_logic;
    signal pps_inst_subsec_counter_6_cry_17_0_RNO_0: Std_logic;
    signal pps_inst_subsec_counter_18: Std_logic;
    signal pps_inst_subsec_counter_6_cry_17_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_17: Std_logic;
    signal pps_inst_subsec_counter_6_18: Std_logic;
    signal pps_inst_subsec_counter_6_17: Std_logic;
    signal pps_inst_subsec_counter_6_cry_18: Std_logic;
    signal pps_inst_subsec_counter_6_axb_20: Std_logic;
    signal pps_inst_subsec_counter_6_cry_19_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_19: Std_logic;
    signal pps_inst_subsec_counter_6_20: Std_logic;
    signal pps_inst_subsec_counter_6_19: Std_logic;
    signal pps_inst_subsec_counter_20: Std_logic;
    signal pps_inst_subsec_counter_6_cry_20: Std_logic;
    signal pps_inst_subsec_counter_6_axb_22: Std_logic;
    signal pps_inst_subsec_counter_6_axb_21: Std_logic;
    signal pps_inst_subsec_counter_6_22: Std_logic;
    signal pps_inst_subsec_counter_6_21: Std_logic;
    signal pps_inst_subsec_counter_21: Std_logic;
    signal pps_inst_subsec_counter_22: Std_logic;
    signal pps_inst_subsec_counter_6_cry_22: Std_logic;
    signal pps_inst_subsec_counter_6_axb_24: Std_logic;
    signal pps_inst_subsec_counter_6_cry_23_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_23: Std_logic;
    signal pps_inst_subsec_counter_6_24: Std_logic;
    signal pps_inst_subsec_counter_6_23: Std_logic;
    signal pps_inst_subsec_counter_24: Std_logic;
    signal pps_inst_subsec_counter_6_cry_24: Std_logic;
    signal pps_inst_subsec_counter_6_axb_26: Std_logic;
    signal pps_inst_subsec_counter_6_cry_25_0_RNO: Std_logic;
    signal pps_inst_subsec_counter_25: Std_logic;
    signal pps_inst_subsec_counter_6_26: Std_logic;
    signal pps_inst_subsec_counter_6_25: Std_logic;
    signal pps_inst_subsec_counter_26: Std_logic;
    signal pps_inst_subsec_counter_6_cry_26: Std_logic;
    signal pps_inst_subsec_counter_6_axb_28: Std_logic;
    signal pps_inst_subsec_counter_6_axb_27: Std_logic;
    signal pps_inst_subsec_counter_6_28: Std_logic;
    signal pps_inst_subsec_counter_6_27: Std_logic;
    signal pps_inst_subsec_counter_27: Std_logic;
    signal pps_inst_subsec_counter_28: Std_logic;
    signal pps_inst_subsec_counter_6_cry_28: Std_logic;
    signal pps_inst_subsec_counter_6_axb_30: Std_logic;
    signal pps_inst_subsec_counter_6_axb_29: Std_logic;
    signal pps_inst_subsec_counter_6_30: Std_logic;
    signal pps_inst_subsec_counter_6_29: Std_logic;
    signal pps_inst_subsec_counter_29: Std_logic;
    signal pps_inst_subsec_counter_30: Std_logic;
    signal pps_inst_subsec_counter_6_cry_30: Std_logic;
    signal subseconds_31: Std_logic;
    signal pps_inst_subsec_counter_31: Std_logic;
    signal pps_inst_subsec_counter_6_31: Std_logic;
    signal pps_inst_current_subseconds_0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_0: Std_logic;
    signal pps_inst_current_subseconds_2: Std_logic;
    signal subseconds_2: Std_logic;
    signal pps_inst_current_subseconds_1: Std_logic;
    signal subseconds_1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_1_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_1_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_2: Std_logic;
    signal pps_inst_current_subseconds_4: Std_logic;
    signal subseconds_4: Std_logic;
    signal pps_inst_current_subseconds_3: Std_logic;
    signal subseconds_3: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_3_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_3_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_4: Std_logic;
    signal pps_inst_current_subseconds_6: Std_logic;
    signal subseconds_6: Std_logic;
    signal pps_inst_current_subseconds_5: Std_logic;
    signal subseconds_5: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_5_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_5_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_6: Std_logic;
    signal pps_inst_current_subseconds_8: Std_logic;
    signal subseconds_8: Std_logic;
    signal pps_inst_current_subseconds_7: Std_logic;
    signal subseconds_7: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_7_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_7_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_8: Std_logic;
    signal pps_inst_current_subseconds_10: Std_logic;
    signal subseconds_10: Std_logic;
    signal pps_inst_current_subseconds_9: Std_logic;
    signal subseconds_9: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_9_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_9_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_10: Std_logic;
    signal pps_inst_current_subseconds_12: Std_logic;
    signal subseconds_12: Std_logic;
    signal pps_inst_current_subseconds_11: Std_logic;
    signal subseconds_11: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_11_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_11_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_12: Std_logic;
    signal pps_inst_current_subseconds_14: Std_logic;
    signal subseconds_14: Std_logic;
    signal pps_inst_current_subseconds_13: Std_logic;
    signal subseconds_13: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_13_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_13_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_14: Std_logic;
    signal pps_inst_current_subseconds_16: Std_logic;
    signal subseconds_16: Std_logic;
    signal pps_inst_current_subseconds_15: Std_logic;
    signal subseconds_15: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_15_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_15_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_16: Std_logic;
    signal pps_inst_current_subseconds_18: Std_logic;
    signal subseconds_18: Std_logic;
    signal pps_inst_current_subseconds_17: Std_logic;
    signal subseconds_17: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_17_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_17_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_18: Std_logic;
    signal pps_inst_current_subseconds_20: Std_logic;
    signal subseconds_20: Std_logic;
    signal pps_inst_current_subseconds_19: Std_logic;
    signal subseconds_19: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_19_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_19_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_20: Std_logic;
    signal pps_inst_current_subseconds_22: Std_logic;
    signal subseconds_22: Std_logic;
    signal pps_inst_current_subseconds_21: Std_logic;
    signal subseconds_21: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_21_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_21_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_22: Std_logic;
    signal pps_inst_current_subseconds_24: Std_logic;
    signal subseconds_24: Std_logic;
    signal pps_inst_current_subseconds_23: Std_logic;
    signal subseconds_23: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_23_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_23_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_24: Std_logic;
    signal pps_inst_current_subseconds_26: Std_logic;
    signal subseconds_26: Std_logic;
    signal pps_inst_current_subseconds_25: Std_logic;
    signal subseconds_25: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_25_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_25_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_26: Std_logic;
    signal pps_inst_current_subseconds_28: Std_logic;
    signal subseconds_28: Std_logic;
    signal pps_inst_current_subseconds_27: Std_logic;
    signal subseconds_27: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_27_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_27_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_28: Std_logic;
    signal pps_inst_current_subseconds_30: Std_logic;
    signal subseconds_30: Std_logic;
    signal pps_inst_current_subseconds_29: Std_logic;
    signal subseconds_29: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_29_0_S0: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_29_0_S1: Std_logic;
    signal pps_inst_sync_error_5_0_0_cry_30: Std_logic;
    signal pps_inst_current_subseconds_31: Std_logic;
    signal pps_inst_sync_error_5_0_0_s_31_0_S0: Std_logic;
    signal pps_inst_pps_pulse_counter_0: Std_logic;
    signal pps_inst_N_166: Std_logic;
    signal pps_inst_pps_pulse_counter_s_0: Std_logic;
    signal pps_inst_pps_pulse_countere: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_0: Std_logic;
    signal pps_inst_pps_pulse_counter_2: Std_logic;
    signal pps_inst_pps_pulse_counter_1: Std_logic;
    signal pps_inst_pps_pulse_counter_s_2: Std_logic;
    signal pps_inst_pps_pulse_counter_s_1: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_2: Std_logic;
    signal pps_inst_pps_pulse_counter_4: Std_logic;
    signal pps_inst_pps_pulse_counter_3: Std_logic;
    signal pps_inst_pps_pulse_counter_s_4: Std_logic;
    signal pps_inst_pps_pulse_counter_s_3: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_4: Std_logic;
    signal pps_inst_pps_pulse_counter_6: Std_logic;
    signal pps_inst_pps_pulse_counter_5: Std_logic;
    signal pps_inst_pps_pulse_counter_s_6: Std_logic;
    signal pps_inst_pps_pulse_counter_s_5: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_6: Std_logic;
    signal pps_inst_pps_pulse_counter_8: Std_logic;
    signal pps_inst_pps_pulse_counter_7: Std_logic;
    signal pps_inst_pps_pulse_counter_s_8: Std_logic;
    signal pps_inst_pps_pulse_counter_s_7: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_8: Std_logic;
    signal pps_inst_pps_pulse_counter_10: Std_logic;
    signal pps_inst_pps_pulse_counter_9: Std_logic;
    signal pps_inst_pps_pulse_counter_s_10: Std_logic;
    signal pps_inst_pps_pulse_counter_s_9: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_10: Std_logic;
    signal pps_inst_pps_pulse_counter_12: Std_logic;
    signal pps_inst_pps_pulse_counter_11: Std_logic;
    signal pps_inst_pps_pulse_counter_s_12: Std_logic;
    signal pps_inst_pps_pulse_counter_s_11: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_12: Std_logic;
    signal pps_inst_pps_pulse_counter_14: Std_logic;
    signal pps_inst_pps_pulse_counter_13: Std_logic;
    signal pps_inst_pps_pulse_counter_s_14: Std_logic;
    signal pps_inst_pps_pulse_counter_s_13: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_14: Std_logic;
    signal pps_inst_pps_pulse_counter_16: Std_logic;
    signal pps_inst_pps_pulse_counter_15: Std_logic;
    signal pps_inst_pps_pulse_counter_s_16: Std_logic;
    signal pps_inst_pps_pulse_counter_s_15: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_16: Std_logic;
    signal pps_inst_pps_pulse_counter_18: Std_logic;
    signal pps_inst_pps_pulse_counter_17: Std_logic;
    signal pps_inst_pps_pulse_counter_s_18: Std_logic;
    signal pps_inst_pps_pulse_counter_s_17: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_18: Std_logic;
    signal pps_inst_pps_pulse_counter_20: Std_logic;
    signal pps_inst_pps_pulse_counter_19: Std_logic;
    signal pps_inst_pps_pulse_counter_s_20: Std_logic;
    signal pps_inst_pps_pulse_counter_s_19: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_20: Std_logic;
    signal pps_inst_pps_pulse_counter_22: Std_logic;
    signal pps_inst_pps_pulse_counter_21: Std_logic;
    signal pps_inst_pps_pulse_counter_s_22: Std_logic;
    signal pps_inst_pps_pulse_counter_s_21: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_22: Std_logic;
    signal pps_inst_pps_pulse_counter_24: Std_logic;
    signal pps_inst_pps_pulse_counter_23: Std_logic;
    signal pps_inst_pps_pulse_counter_s_24: Std_logic;
    signal pps_inst_pps_pulse_counter_s_23: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_24: Std_logic;
    signal pps_inst_pps_pulse_counter_26: Std_logic;
    signal pps_inst_pps_pulse_counter_25: Std_logic;
    signal pps_inst_pps_pulse_counter_s_26: Std_logic;
    signal pps_inst_pps_pulse_counter_s_25: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_26: Std_logic;
    signal pps_inst_pps_pulse_counter_28: Std_logic;
    signal pps_inst_pps_pulse_counter_27: Std_logic;
    signal pps_inst_pps_pulse_counter_s_28: Std_logic;
    signal pps_inst_pps_pulse_counter_s_27: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_28: Std_logic;
    signal pps_inst_pps_pulse_counter_30: Std_logic;
    signal pps_inst_pps_pulse_counter_29: Std_logic;
    signal pps_inst_pps_pulse_counter_s_30: Std_logic;
    signal pps_inst_pps_pulse_counter_s_29: Std_logic;
    signal pps_inst_pps_pulse_counter_cry_30: Std_logic;
    signal pps_inst_pps_pulse_counter_31: Std_logic;
    signal pps_inst_pps_pulse_counter_s_31: Std_logic;
    signal pps_inst_current_seconds_0: Std_logic;
    signal seconds_since_2000_0: Std_logic;
    signal pps_inst_current_seconds_s_0: Std_logic;
    signal pps_inst_current_secondse: Std_logic;
    signal pps_inst_current_seconds_cry_0: Std_logic;
    signal pps_inst_current_seconds_2: Std_logic;
    signal seconds_since_2000_2: Std_logic;
    signal pps_inst_current_seconds_1: Std_logic;
    signal seconds_since_2000_1: Std_logic;
    signal pps_inst_current_seconds_s_2: Std_logic;
    signal pps_inst_current_seconds_s_1: Std_logic;
    signal pps_inst_current_seconds_cry_2: Std_logic;
    signal pps_inst_current_seconds_4: Std_logic;
    signal seconds_since_2000_4: Std_logic;
    signal pps_inst_current_seconds_3: Std_logic;
    signal seconds_since_2000_3: Std_logic;
    signal pps_inst_current_seconds_s_4: Std_logic;
    signal pps_inst_current_seconds_s_3: Std_logic;
    signal pps_inst_current_seconds_cry_4: Std_logic;
    signal pps_inst_current_seconds_6: Std_logic;
    signal seconds_since_2000_6: Std_logic;
    signal pps_inst_current_seconds_5: Std_logic;
    signal seconds_since_2000_5: Std_logic;
    signal pps_inst_current_seconds_s_6: Std_logic;
    signal pps_inst_current_seconds_s_5: Std_logic;
    signal pps_inst_current_seconds_cry_6: Std_logic;
    signal pps_inst_current_seconds_8: Std_logic;
    signal seconds_since_2000_8: Std_logic;
    signal pps_inst_current_seconds_7: Std_logic;
    signal seconds_since_2000_7: Std_logic;
    signal pps_inst_current_seconds_s_8: Std_logic;
    signal pps_inst_current_seconds_s_7: Std_logic;
    signal pps_inst_current_seconds_cry_8: Std_logic;
    signal pps_inst_current_seconds_10: Std_logic;
    signal seconds_since_2000_10: Std_logic;
    signal pps_inst_current_seconds_9: Std_logic;
    signal seconds_since_2000_9: Std_logic;
    signal pps_inst_current_seconds_s_10: Std_logic;
    signal pps_inst_current_seconds_s_9: Std_logic;
    signal pps_inst_current_seconds_cry_10: Std_logic;
    signal pps_inst_current_seconds_12: Std_logic;
    signal seconds_since_2000_12: Std_logic;
    signal pps_inst_current_seconds_11: Std_logic;
    signal seconds_since_2000_11: Std_logic;
    signal pps_inst_current_seconds_s_12: Std_logic;
    signal pps_inst_current_seconds_s_11: Std_logic;
    signal pps_inst_current_seconds_cry_12: Std_logic;
    signal pps_inst_current_seconds_14: Std_logic;
    signal seconds_since_2000_14: Std_logic;
    signal pps_inst_current_seconds_13: Std_logic;
    signal seconds_since_2000_13: Std_logic;
    signal pps_inst_current_seconds_s_14: Std_logic;
    signal pps_inst_current_seconds_s_13: Std_logic;
    signal pps_inst_current_seconds_cry_14: Std_logic;
    signal pps_inst_current_seconds_16: Std_logic;
    signal seconds_since_2000_16: Std_logic;
    signal pps_inst_current_seconds_15: Std_logic;
    signal seconds_since_2000_15: Std_logic;
    signal pps_inst_current_seconds_s_16: Std_logic;
    signal pps_inst_current_seconds_s_15: Std_logic;
    signal pps_inst_current_seconds_cry_16: Std_logic;
    signal pps_inst_current_seconds_18: Std_logic;
    signal seconds_since_2000_18: Std_logic;
    signal pps_inst_current_seconds_17: Std_logic;
    signal seconds_since_2000_17: Std_logic;
    signal pps_inst_current_seconds_s_18: Std_logic;
    signal pps_inst_current_seconds_s_17: Std_logic;
    signal pps_inst_current_seconds_cry_18: Std_logic;
    signal pps_inst_current_seconds_20: Std_logic;
    signal seconds_since_2000_20: Std_logic;
    signal pps_inst_current_seconds_19: Std_logic;
    signal seconds_since_2000_19: Std_logic;
    signal pps_inst_current_seconds_s_20: Std_logic;
    signal pps_inst_current_seconds_s_19: Std_logic;
    signal pps_inst_current_seconds_cry_20: Std_logic;
    signal pps_inst_current_seconds_22: Std_logic;
    signal seconds_since_2000_22: Std_logic;
    signal pps_inst_current_seconds_21: Std_logic;
    signal seconds_since_2000_21: Std_logic;
    signal pps_inst_current_seconds_s_22: Std_logic;
    signal pps_inst_current_seconds_s_21: Std_logic;
    signal pps_inst_current_seconds_cry_22: Std_logic;
    signal pps_inst_current_seconds_24: Std_logic;
    signal seconds_since_2000_24: Std_logic;
    signal pps_inst_current_seconds_23: Std_logic;
    signal seconds_since_2000_23: Std_logic;
    signal pps_inst_current_seconds_s_24: Std_logic;
    signal pps_inst_current_seconds_s_23: Std_logic;
    signal pps_inst_current_seconds_cry_24: Std_logic;
    signal pps_inst_current_seconds_26: Std_logic;
    signal seconds_since_2000_26: Std_logic;
    signal pps_inst_current_seconds_25: Std_logic;
    signal seconds_since_2000_25: Std_logic;
    signal pps_inst_current_seconds_s_26: Std_logic;
    signal pps_inst_current_seconds_s_25: Std_logic;
    signal pps_inst_current_seconds_cry_26: Std_logic;
    signal pps_inst_current_seconds_28: Std_logic;
    signal seconds_since_2000_28: Std_logic;
    signal pps_inst_current_seconds_27: Std_logic;
    signal seconds_since_2000_27: Std_logic;
    signal pps_inst_current_seconds_s_28: Std_logic;
    signal pps_inst_current_seconds_s_27: Std_logic;
    signal pps_inst_current_seconds_cry_28: Std_logic;
    signal pps_inst_current_seconds_30: Std_logic;
    signal seconds_since_2000_30: Std_logic;
    signal pps_inst_current_seconds_29: Std_logic;
    signal seconds_since_2000_29: Std_logic;
    signal pps_inst_current_seconds_s_30: Std_logic;
    signal pps_inst_current_seconds_s_29: Std_logic;
    signal pps_inst_current_seconds_cry_30: Std_logic;
    signal pps_inst_current_seconds_32: Std_logic;
    signal seconds_since_2000_32: Std_logic;
    signal pps_inst_current_seconds_31: Std_logic;
    signal seconds_since_2000_31: Std_logic;
    signal pps_inst_current_seconds_s_32: Std_logic;
    signal pps_inst_current_seconds_s_31: Std_logic;
    signal pps_inst_current_seconds_cry_32: Std_logic;
    signal pps_inst_current_seconds_34: Std_logic;
    signal seconds_since_2000_34: Std_logic;
    signal pps_inst_current_seconds_33: Std_logic;
    signal seconds_since_2000_33: Std_logic;
    signal pps_inst_current_seconds_s_34: Std_logic;
    signal pps_inst_current_seconds_s_33: Std_logic;
    signal pps_inst_current_seconds_cry_34: Std_logic;
    signal pps_inst_current_seconds_36: Std_logic;
    signal seconds_since_2000_36: Std_logic;
    signal pps_inst_current_seconds_35: Std_logic;
    signal seconds_since_2000_35: Std_logic;
    signal pps_inst_current_seconds_s_36: Std_logic;
    signal pps_inst_current_seconds_s_35: Std_logic;
    signal pps_inst_current_seconds_cry_36: Std_logic;
    signal pps_inst_current_seconds_38: Std_logic;
    signal seconds_since_2000_38: Std_logic;
    signal pps_inst_current_seconds_37: Std_logic;
    signal seconds_since_2000_37: Std_logic;
    signal pps_inst_current_seconds_s_38: Std_logic;
    signal pps_inst_current_seconds_s_37: Std_logic;
    signal pps_inst_current_seconds_cry_38: Std_logic;
    signal pps_inst_current_seconds_39: Std_logic;
    signal seconds_since_2000_39: Std_logic;
    signal pps_inst_current_seconds_s_39: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_0: Std_logic;
    signal pps_inst_un1_current_subseconds_10_1: Std_logic;
    signal pps_inst_un1_current_subseconds_10_2: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_2: Std_logic;
    signal pps_inst_un1_current_subseconds_10_3: Std_logic;
    signal pps_inst_un1_current_subseconds_10_4: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_4: Std_logic;
    signal pps_inst_un1_current_subseconds_10_5: Std_logic;
    signal pps_inst_un1_current_subseconds_10_6: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_6: Std_logic;
    signal pps_inst_un1_current_subseconds_10_7: Std_logic;
    signal pps_inst_un1_current_subseconds_10_8: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_8: Std_logic;
    signal pps_inst_un1_current_subseconds_10_9: Std_logic;
    signal pps_inst_un1_current_subseconds_10_10: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_10: Std_logic;
    signal pps_inst_un1_current_subseconds_10_11: Std_logic;
    signal pps_inst_un1_current_subseconds_10_12: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_12: Std_logic;
    signal pps_inst_un1_current_subseconds_10_13: Std_logic;
    signal pps_inst_un1_current_subseconds_10_14: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_14: Std_logic;
    signal pps_inst_un1_current_subseconds_10_15: Std_logic;
    signal pps_inst_un1_current_subseconds_10_16: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_16: Std_logic;
    signal pps_inst_un1_current_subseconds_10_17: Std_logic;
    signal pps_inst_un1_current_subseconds_10_18: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_18: Std_logic;
    signal pps_inst_un1_current_subseconds_10_19: Std_logic;
    signal pps_inst_un1_current_subseconds_10_20: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_20: Std_logic;
    signal pps_inst_un1_current_subseconds_10_21: Std_logic;
    signal pps_inst_un1_current_subseconds_10_22: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_22: Std_logic;
    signal pps_inst_un1_current_subseconds_10_23: Std_logic;
    signal pps_inst_un1_current_subseconds_10_24: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_24: Std_logic;
    signal pps_inst_un1_current_subseconds_10_25: Std_logic;
    signal pps_inst_un1_current_subseconds_10_26: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_26: Std_logic;
    signal pps_inst_un1_current_subseconds_10_27: Std_logic;
    signal pps_inst_un1_current_subseconds_10_28: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_28: Std_logic;
    signal pps_inst_un1_current_subseconds_10_29: Std_logic;
    signal pps_inst_un1_current_subseconds_10_30: Std_logic;
    signal pps_inst_un1_current_subseconds_0_cry_30: Std_logic;
    signal pps_inst_un1_current_subseconds_10_31: Std_logic;
    signal pps_inst_sync_error12_cry_0: Std_logic;
    signal pps_inst_sync_error12_cry_2: Std_logic;
    signal pps_inst_sync_error12_cry_4: Std_logic;
    signal pps_inst_sync_error12_cry_6: Std_logic;
    signal pps_inst_sync_error12_cry_8: Std_logic;
    signal pps_inst_sync_error12_cry_10: Std_logic;
    signal pps_inst_sync_error12_cry_12: Std_logic;
    signal pps_inst_sync_error12_cry_14: Std_logic;
    signal pps_inst_sync_error12_cry_16: Std_logic;
    signal pps_inst_sync_error12_cry_18: Std_logic;
    signal pps_inst_sync_error12_cry_20: Std_logic;
    signal pps_inst_sync_error12_cry_22: Std_logic;
    signal pps_inst_sync_error12_cry_24: Std_logic;
    signal pps_inst_sync_error12_cry_26: Std_logic;
    signal pps_inst_sync_error12_cry_28: Std_logic;
    signal pps_inst_sync_error12_cry_30: Std_logic;
    signal pps_inst_sync_error12: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_0: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_2: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_4: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_6: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_8: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_10: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_12: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_14: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_16: Std_logic;
    signal pps_inst_sync_error18_0_data_tmp_18: Std_logic;
    signal pps_inst_sync_error18_i: Std_logic;
    signal parser_inst_un1_byte_counter_cry_16_cry: Std_logic;
    signal parser_inst_un1_byte_counter_cry_16: Std_logic;
    signal parser_inst_byte_counter_0: Std_logic;
    signal parser_inst_byte_counter: Std_logic;
    signal parser_inst_byte_counter_s_0: Std_logic;
    signal parser_inst_N_4_i: Std_logic;
    signal parser_inst_byte_counter_cry_0: Std_logic;
    signal parser_inst_byte_counter_2: Std_logic;
    signal parser_inst_byte_counter_1: Std_logic;
    signal parser_inst_byte_counter_s_2: Std_logic;
    signal parser_inst_byte_counter_s_1: Std_logic;
    signal parser_inst_byte_counter_cry_2: Std_logic;
    signal parser_inst_byte_counter_4: Std_logic;
    signal parser_inst_byte_counter_3: Std_logic;
    signal parser_inst_byte_counter_s_4: Std_logic;
    signal parser_inst_byte_counter_s_3: Std_logic;
    signal parser_inst_byte_counter_cry_4: Std_logic;
    signal parser_inst_byte_counter_6: Std_logic;
    signal parser_inst_byte_counter_5: Std_logic;
    signal parser_inst_byte_counter_s_6: Std_logic;
    signal parser_inst_byte_counter_s_5: Std_logic;
    signal parser_inst_byte_counter_cry_6: Std_logic;
    signal parser_inst_byte_counter_8: Std_logic;
    signal parser_inst_byte_counter_7: Std_logic;
    signal parser_inst_byte_counter_s_8: Std_logic;
    signal parser_inst_byte_counter_s_7: Std_logic;
    signal parser_inst_byte_counter_cry_8: Std_logic;
    signal parser_inst_byte_counter_10: Std_logic;
    signal parser_inst_byte_counter_9: Std_logic;
    signal parser_inst_byte_counter_s_10: Std_logic;
    signal parser_inst_byte_counter_s_9: Std_logic;
    signal parser_inst_byte_counter_cry_10: Std_logic;
    signal parser_inst_byte_counter_12: Std_logic;
    signal parser_inst_byte_counter_11: Std_logic;
    signal parser_inst_byte_counter_s_12: Std_logic;
    signal parser_inst_byte_counter_s_11: Std_logic;
    signal parser_inst_byte_counter_cry_12: Std_logic;
    signal parser_inst_byte_counter_14: Std_logic;
    signal parser_inst_byte_counter_13: Std_logic;
    signal parser_inst_byte_counter_s_14: Std_logic;
    signal parser_inst_byte_counter_s_13: Std_logic;
    signal parser_inst_byte_counter_cry_14: Std_logic;
    signal parser_inst_byte_counter_15: Std_logic;
    signal parser_inst_byte_counter_s_15: Std_logic;
    signal parser_inst_packet_length_reg_0: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_0: Std_logic;
    signal parser_inst_packet_length_reg_2: Std_logic;
    signal parser_inst_packet_length_reg_1: Std_logic;
    signal parser_inst_un1_byte_counter_1: Std_logic;
    signal parser_inst_un1_byte_counter_2: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_2: Std_logic;
    signal parser_inst_packet_length_reg_4: Std_logic;
    signal parser_inst_packet_length_reg_3: Std_logic;
    signal parser_inst_un1_byte_counter_3: Std_logic;
    signal parser_inst_un1_byte_counter_4: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_4: Std_logic;
    signal parser_inst_packet_length_reg_6: Std_logic;
    signal parser_inst_packet_length_reg_5: Std_logic;
    signal parser_inst_un1_byte_counter_5: Std_logic;
    signal parser_inst_un1_byte_counter_6: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_6: Std_logic;
    signal parser_inst_packet_length_reg_8: Std_logic;
    signal parser_inst_packet_length_reg_7: Std_logic;
    signal parser_inst_un1_byte_counter_7: Std_logic;
    signal parser_inst_un1_byte_counter_8: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_8: Std_logic;
    signal parser_inst_packet_length_reg_10: Std_logic;
    signal parser_inst_packet_length_reg_9: Std_logic;
    signal parser_inst_un1_byte_counter_9: Std_logic;
    signal parser_inst_un1_byte_counter_10: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_10: Std_logic;
    signal parser_inst_packet_length_reg_12: Std_logic;
    signal parser_inst_packet_length_reg_11: Std_logic;
    signal parser_inst_un1_byte_counter_11: Std_logic;
    signal parser_inst_un1_byte_counter_12: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_12: Std_logic;
    signal parser_inst_packet_length_reg_14: Std_logic;
    signal parser_inst_packet_length_reg_13: Std_logic;
    signal parser_inst_un1_byte_counter_13: Std_logic;
    signal parser_inst_un1_byte_counter_14: Std_logic;
    signal parser_inst_un1_packet_length_reg_0_cry_14: Std_logic;
    signal parser_inst_packet_length_reg_15: Std_logic;
    signal parser_inst_un1_byte_counter_15: Std_logic;
    signal parser_inst_un1_byte_counter_16: Std_logic;
    signal parser_inst_un1_byte_counter_cry_0: Std_logic;
    signal parser_inst_un1_byte_counter_cry_2: Std_logic;
    signal parser_inst_un1_byte_counter_cry_4: Std_logic;
    signal parser_inst_un1_byte_counter_cry_6: Std_logic;
    signal parser_inst_un1_byte_counter_cry_8: Std_logic;
    signal parser_inst_un1_byte_counter_cry_10: Std_logic;
    signal parser_inst_un1_byte_counter_cry_12: Std_logic;
    signal parser_inst_un1_byte_counter_cry_14: Std_logic;
    signal parser_inst_t2mi_valid_sync: Std_logic;
    signal parser_inst_N_85_i: Std_logic;
    signal extractor_inst_extract_state_4: Std_logic;
    signal debug_status_c_2: Std_logic;
    signal extractor_inst_extract_state_5: Std_logic;
    signal parser_inst_parser_state_5: Std_logic;
    signal debug_status_c_5: Std_logic;
    signal debug_status_c_6: Std_logic;
    signal extractor_inst_packet_active6: Std_logic;
    signal extractor_inst_byte_index_1: Std_logic;
    signal extractor_inst_byte_index_0: Std_logic;
    signal extractor_inst_N_13_i: Std_logic;
    signal extractor_inst_byte_index_n0_i_a4: Std_logic;
    signal extractor_inst_byte_indexe: Std_logic;
    signal extractor_inst_byte_index_3: Std_logic;
    signal extractor_inst_byte_index_2: Std_logic;
    signal extractor_inst_byte_index_n1_i_o2: Std_logic;
    signal extractor_inst_N_7_i: Std_logic;
    signal extractor_inst_N_9_i: Std_logic;
    signal extractor_inst_packet_active: Std_logic;
    signal packet_end: Std_logic;
    signal extractor_inst_packet_active7: Std_logic;
    signal extractor_inst_un1_packet_active8_i_0: Std_logic;
    signal extractor_inst_data_complete: Std_logic;
    signal extractor_inst_un1_packet_active8_i_o2: Std_logic;
    signal extractor_inst_extract_state_0: Std_logic;
    signal extractor_inst_extract_state_ns_1: Std_logic;
    signal extractor_inst_extract_state_ns_0: Std_logic;
    signal extractor_inst_extract_state_1: Std_logic;
    signal extractor_inst_extract_state_ns_2_3: Std_logic;
    signal extractor_inst_extract_state_tr8: Std_logic;
    signal extractor_inst_header_valid: Std_logic;
    signal extractor_inst_N_119_i: Std_logic;
    signal extractor_inst_extract_state_ns_2: Std_logic;
    signal extractor_inst_extract_state_2: Std_logic;
    signal extractor_inst_extract_state_3: Std_logic;
    signal extractor_inst_extract_state_tr8_37: Std_logic;
    signal extractor_inst_extract_state_tr8_36: Std_logic;
    signal extractor_inst_extract_state_tr8_30: Std_logic;
    signal extractor_inst_extract_state_tr8_29: Std_logic;
    signal extractor_inst_extract_state_ns_5: Std_logic;
    signal extractor_inst_timestamp_buffer_0_7: Std_logic;
    signal extractor_inst_timestamp_buffer_0_6: Std_logic;
    signal extractor_inst_timestamp_buffer_0_5: Std_logic;
    signal extractor_inst_timestamp_buffer_0_4: Std_logic;
    signal extractor_inst_header_valid_2: Std_logic;
    signal packet_type_6: Std_logic;
    signal packet_type_4: Std_logic;
    signal extractor_inst_packet_active6_5: Std_logic;
    signal extractor_inst_packet_active6_4: Std_logic;
    signal extractor_inst_N_62_i: Std_logic;
    signal extractor_inst_timestamp_buffer_7_1: Std_logic;
    signal extractor_inst_timestamp_buffer_7_0: Std_logic;
    signal extractor_inst_seconds_field_0: Std_logic;
    signal extractor_inst_seconds_field_1: Std_logic;
    signal extractor_inst_timestamp_buffer_7_3: Std_logic;
    signal extractor_inst_timestamp_buffer_7_2: Std_logic;
    signal extractor_inst_seconds_field_2: Std_logic;
    signal extractor_inst_seconds_field_3: Std_logic;
    signal extractor_inst_timestamp_buffer_7_5: Std_logic;
    signal extractor_inst_timestamp_buffer_7_4: Std_logic;
    signal extractor_inst_seconds_field_4: Std_logic;
    signal extractor_inst_seconds_field_5: Std_logic;
    signal extractor_inst_timestamp_buffer_7_7: Std_logic;
    signal extractor_inst_timestamp_buffer_7_6: Std_logic;
    signal extractor_inst_seconds_field_6: Std_logic;
    signal extractor_inst_seconds_field_7: Std_logic;
    signal extractor_inst_timestamp_buffer_6_1: Std_logic;
    signal extractor_inst_timestamp_buffer_6_0: Std_logic;
    signal extractor_inst_seconds_field_8: Std_logic;
    signal extractor_inst_seconds_field_9: Std_logic;
    signal extractor_inst_timestamp_buffer_6_3: Std_logic;
    signal extractor_inst_timestamp_buffer_6_2: Std_logic;
    signal extractor_inst_seconds_field_10: Std_logic;
    signal extractor_inst_seconds_field_11: Std_logic;
    signal extractor_inst_timestamp_buffer_6_5: Std_logic;
    signal extractor_inst_timestamp_buffer_6_4: Std_logic;
    signal extractor_inst_seconds_field_12: Std_logic;
    signal extractor_inst_seconds_field_13: Std_logic;
    signal extractor_inst_timestamp_buffer_6_7: Std_logic;
    signal extractor_inst_timestamp_buffer_6_6: Std_logic;
    signal extractor_inst_seconds_field_14: Std_logic;
    signal extractor_inst_seconds_field_15: Std_logic;
    signal extractor_inst_timestamp_buffer_5_1: Std_logic;
    signal extractor_inst_timestamp_buffer_5_0: Std_logic;
    signal extractor_inst_seconds_field_16: Std_logic;
    signal extractor_inst_seconds_field_17: Std_logic;
    signal extractor_inst_timestamp_buffer_5_3: Std_logic;
    signal extractor_inst_timestamp_buffer_5_2: Std_logic;
    signal extractor_inst_seconds_field_18: Std_logic;
    signal extractor_inst_seconds_field_19: Std_logic;
    signal extractor_inst_timestamp_buffer_5_5: Std_logic;
    signal extractor_inst_timestamp_buffer_5_4: Std_logic;
    signal extractor_inst_seconds_field_20: Std_logic;
    signal extractor_inst_seconds_field_21: Std_logic;
    signal extractor_inst_timestamp_buffer_5_7: Std_logic;
    signal extractor_inst_timestamp_buffer_5_6: Std_logic;
    signal extractor_inst_seconds_field_22: Std_logic;
    signal extractor_inst_seconds_field_23: Std_logic;
    signal extractor_inst_timestamp_buffer_4_1: Std_logic;
    signal extractor_inst_timestamp_buffer_4_0: Std_logic;
    signal extractor_inst_seconds_field_24: Std_logic;
    signal extractor_inst_seconds_field_25: Std_logic;
    signal extractor_inst_timestamp_buffer_4_3: Std_logic;
    signal extractor_inst_timestamp_buffer_4_2: Std_logic;
    signal extractor_inst_seconds_field_26: Std_logic;
    signal extractor_inst_seconds_field_27: Std_logic;
    signal extractor_inst_timestamp_buffer_4_5: Std_logic;
    signal extractor_inst_timestamp_buffer_4_4: Std_logic;
    signal extractor_inst_seconds_field_28: Std_logic;
    signal extractor_inst_seconds_field_29: Std_logic;
    signal extractor_inst_timestamp_buffer_4_7: Std_logic;
    signal extractor_inst_timestamp_buffer_4_6: Std_logic;
    signal extractor_inst_seconds_field_30: Std_logic;
    signal extractor_inst_seconds_field_31: Std_logic;
    signal extractor_inst_timestamp_buffer_3_1: Std_logic;
    signal extractor_inst_timestamp_buffer_3_0: Std_logic;
    signal extractor_inst_seconds_field_32: Std_logic;
    signal extractor_inst_seconds_field_33: Std_logic;
    signal extractor_inst_timestamp_buffer_3_3: Std_logic;
    signal extractor_inst_timestamp_buffer_3_2: Std_logic;
    signal extractor_inst_seconds_field_34: Std_logic;
    signal extractor_inst_seconds_field_35: Std_logic;
    signal extractor_inst_timestamp_buffer_3_5: Std_logic;
    signal extractor_inst_timestamp_buffer_3_4: Std_logic;
    signal extractor_inst_seconds_field_36: Std_logic;
    signal extractor_inst_seconds_field_37: Std_logic;
    signal extractor_inst_timestamp_buffer_3_7: Std_logic;
    signal extractor_inst_timestamp_buffer_3_6: Std_logic;
    signal extractor_inst_seconds_field_38: Std_logic;
    signal extractor_inst_seconds_field_39: Std_logic;
    signal extractor_inst_timestamp_buffer_11_1: Std_logic;
    signal extractor_inst_timestamp_buffer_11_0: Std_logic;
    signal extractor_inst_subsec_field_0: Std_logic;
    signal extractor_inst_subsec_field_1: Std_logic;
    signal extractor_inst_timestamp_buffer_11_3: Std_logic;
    signal extractor_inst_timestamp_buffer_11_2: Std_logic;
    signal extractor_inst_subsec_field_2: Std_logic;
    signal extractor_inst_subsec_field_3: Std_logic;
    signal extractor_inst_timestamp_buffer_11_5: Std_logic;
    signal extractor_inst_timestamp_buffer_11_4: Std_logic;
    signal extractor_inst_subsec_field_4: Std_logic;
    signal extractor_inst_subsec_field_5: Std_logic;
    signal extractor_inst_timestamp_buffer_11_7: Std_logic;
    signal extractor_inst_timestamp_buffer_11_6: Std_logic;
    signal extractor_inst_subsec_field_6: Std_logic;
    signal extractor_inst_subsec_field_7: Std_logic;
    signal extractor_inst_timestamp_buffer_10_1: Std_logic;
    signal extractor_inst_timestamp_buffer_10_0: Std_logic;
    signal extractor_inst_subsec_field_8: Std_logic;
    signal extractor_inst_subsec_field_9: Std_logic;
    signal extractor_inst_timestamp_buffer_10_3: Std_logic;
    signal extractor_inst_timestamp_buffer_10_2: Std_logic;
    signal extractor_inst_subsec_field_10: Std_logic;
    signal extractor_inst_subsec_field_11: Std_logic;
    signal extractor_inst_timestamp_buffer_10_5: Std_logic;
    signal extractor_inst_timestamp_buffer_10_4: Std_logic;
    signal extractor_inst_subsec_field_12: Std_logic;
    signal extractor_inst_subsec_field_13: Std_logic;
    signal extractor_inst_timestamp_buffer_10_7: Std_logic;
    signal extractor_inst_timestamp_buffer_10_6: Std_logic;
    signal extractor_inst_subsec_field_14: Std_logic;
    signal extractor_inst_subsec_field_15: Std_logic;
    signal extractor_inst_timestamp_buffer_9_1: Std_logic;
    signal extractor_inst_timestamp_buffer_9_0: Std_logic;
    signal extractor_inst_subsec_field_16: Std_logic;
    signal extractor_inst_subsec_field_17: Std_logic;
    signal extractor_inst_timestamp_buffer_9_3: Std_logic;
    signal extractor_inst_timestamp_buffer_9_2: Std_logic;
    signal extractor_inst_subsec_field_18: Std_logic;
    signal extractor_inst_subsec_field_19: Std_logic;
    signal extractor_inst_timestamp_buffer_9_5: Std_logic;
    signal extractor_inst_timestamp_buffer_9_4: Std_logic;
    signal extractor_inst_subsec_field_20: Std_logic;
    signal extractor_inst_subsec_field_21: Std_logic;
    signal extractor_inst_timestamp_buffer_9_7: Std_logic;
    signal extractor_inst_timestamp_buffer_9_6: Std_logic;
    signal extractor_inst_subsec_field_22: Std_logic;
    signal extractor_inst_subsec_field_23: Std_logic;
    signal extractor_inst_timestamp_buffer_8_1: Std_logic;
    signal extractor_inst_timestamp_buffer_8_0: Std_logic;
    signal extractor_inst_subsec_field_24: Std_logic;
    signal extractor_inst_subsec_field_25: Std_logic;
    signal extractor_inst_timestamp_buffer_8_3: Std_logic;
    signal extractor_inst_timestamp_buffer_8_2: Std_logic;
    signal extractor_inst_subsec_field_26: Std_logic;
    signal extractor_inst_subsec_field_27: Std_logic;
    signal extractor_inst_timestamp_buffer_8_5: Std_logic;
    signal extractor_inst_timestamp_buffer_8_4: Std_logic;
    signal extractor_inst_subsec_field_28: Std_logic;
    signal extractor_inst_subsec_field_29: Std_logic;
    signal extractor_inst_timestamp_buffer_8_7: Std_logic;
    signal extractor_inst_timestamp_buffer_8_6: Std_logic;
    signal extractor_inst_subsec_field_30: Std_logic;
    signal extractor_inst_subsec_field_31: Std_logic;
    signal packet_data_5: Std_logic;
    signal packet_data_4: Std_logic;
    signal extractor_inst_timestamp_buffer_0_0_sqmuxa: Std_logic;
    signal packet_data_7: Std_logic;
    signal packet_data_6: Std_logic;
    signal packet_data_1: Std_logic;
    signal packet_data_0: Std_logic;
    signal extractor_inst_timestamp_buffer_10_0_sqmuxa: Std_logic;
    signal packet_data_3: Std_logic;
    signal packet_data_2: Std_logic;
    signal extractor_inst_timestamp_buffer_11_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_3_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_4_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_5_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_6_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_7_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_8_0_sqmuxa: Std_logic;
    signal extractor_inst_timestamp_buffer_9_0_sqmuxa: Std_logic;
    signal pps_inst_pps_state_2: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa: Std_logic;
    signal pps_inst_pps_armed: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_20: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_16: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_15: Std_logic;
    signal pps_inst_N_360: Std_logic;
    signal led_pps_c: Std_logic;
    signal pps_inst_un1_next_pps_time_1_sqmuxa_i: Std_logic;
    signal parser_inst_un1_sync_counter_c2: Std_logic;
    signal parser_inst_un1_sync_counter14_2f_1: Std_logic;
    signal parser_inst_sync_counterf_2: Std_logic;
    signal led_sync_c: Std_logic;
    signal parser_inst_sync_counter_3: Std_logic;
    signal parser_inst_t2mi_data_sync_1: Std_logic;
    signal parser_inst_t2mi_data_sync_0: Std_logic;
    signal parser_inst_t2mi_data_sync_3: Std_logic;
    signal parser_inst_t2mi_data_sync_2: Std_logic;
    signal parser_inst_t2mi_data_sync_5: Std_logic;
    signal parser_inst_t2mi_data_sync_4: Std_logic;
    signal parser_inst_t2mi_data_sync_7: Std_logic;
    signal parser_inst_t2mi_data_sync_6: Std_logic;
    signal parser_inst_packet_end_0_sqmuxa: Std_logic;
    signal parser_inst_sync_found: Std_logic;
    signal parser_inst_parser_state_0: Std_logic;
    signal parser_inst_next_state_0_sqmuxa: Std_logic;
    signal packet_start: Std_logic;
    signal parser_inst_N_87_i: Std_logic;
    signal packet_type_0: Std_logic;
    signal packet_type_1: Std_logic;
    signal packet_type_2: Std_logic;
    signal packet_type_3: Std_logic;
    signal packet_type_5: Std_logic;
    signal packet_type_7: Std_logic;
    signal parser_inst_parser_state_3: Std_logic;
    signal parser_inst_g2_0: Std_logic;
    signal parser_inst_N_7: Std_logic;
    signal parser_inst_N_98_i: Std_logic;
    signal parser_inst_parser_state_RNI7DD56_2: Std_logic;
    signal parser_inst_packet_length_regce_8: Std_logic;
    signal parser_inst_parser_state_1: Std_logic;
    signal parser_inst_parser_state_ns_i_0_1_0: Std_logic;
    signal parser_inst_N_91_i_mb_mb_1_0: Std_logic;
    signal parser_inst_parser_state_ns_1: Std_logic;
    signal parser_inst_N_91_i: Std_logic;
    signal parser_inst_parser_state_2: Std_logic;
    signal parser_inst_parser_state_ns_0_a2_12_4_5: Std_logic;
    signal parser_inst_parser_state_ns_0_a2_12_3_5: Std_logic;
    signal parser_inst_parser_state_ns_0_a2_1_5: Std_logic;
    signal parser_inst_parser_state_ns_i_o3_0: Std_logic;
    signal parser_inst_N_101_12: Std_logic;
    signal parser_inst_parser_state_ns_5: Std_logic;
    signal parser_inst_sync_counter13_c2: Std_logic;
    signal parser_inst_sync_counter_2: Std_logic;
    signal parser_inst_sync_counter_1: Std_logic;
    signal parser_inst_sync_counter_0: Std_logic;
    signal parser_inst_N_96: Std_logic;
    signal parser_inst_un1_sync_counter14_i_0_o3_0: Std_logic;
    signal parser_inst_sync_counter_pipe: Std_logic;
    signal parser_inst_sync_counterf_1: Std_logic;
    signal parser_inst_sync_counterf_0: Std_logic;
    signal parser_inst_un1_sync_counter14_i_0_o3_4_0: Std_logic;
    signal parser_inst_un1_sync_counter14_i_0_o3_5_0: Std_logic;
    signal parser_inst_N_77_i: Std_logic;
    signal parser_inst_sync_counter_pipe_5_RNO: Std_logic;
    signal pps_inst_current_subseconds_4_1: Std_logic;
    signal pps_inst_current_subseconds_4_0: Std_logic;
    signal pps_inst_time_valid_2: Std_logic;
    signal pps_inst_current_subseconds_4_3: Std_logic;
    signal pps_inst_current_subseconds_4_2: Std_logic;
    signal pps_inst_current_subseconds_4_5: Std_logic;
    signal pps_inst_current_subseconds_4_4: Std_logic;
    signal pps_inst_current_subseconds_4_7: Std_logic;
    signal pps_inst_current_subseconds_4_6: Std_logic;
    signal pps_inst_current_subseconds_4_9: Std_logic;
    signal pps_inst_current_subseconds_4_8: Std_logic;
    signal pps_inst_current_subseconds_4_11: Std_logic;
    signal pps_inst_current_subseconds_4_10: Std_logic;
    signal pps_inst_current_subseconds_4_13: Std_logic;
    signal pps_inst_current_subseconds_4_12: Std_logic;
    signal pps_inst_current_subseconds_4_15: Std_logic;
    signal pps_inst_current_subseconds_4_14: Std_logic;
    signal pps_inst_current_subseconds_4_17: Std_logic;
    signal pps_inst_current_subseconds_4_16: Std_logic;
    signal pps_inst_current_subseconds_4_19: Std_logic;
    signal pps_inst_current_subseconds_4_18: Std_logic;
    signal pps_inst_current_subseconds_4_21: Std_logic;
    signal pps_inst_current_subseconds_4_20: Std_logic;
    signal pps_inst_current_subseconds_4_23: Std_logic;
    signal pps_inst_current_subseconds_4_22: Std_logic;
    signal pps_inst_current_subseconds_4_25: Std_logic;
    signal pps_inst_current_subseconds_4_24: Std_logic;
    signal pps_inst_current_subseconds_4_27: Std_logic;
    signal pps_inst_current_subseconds_4_26: Std_logic;
    signal pps_inst_current_subseconds_4_29: Std_logic;
    signal pps_inst_current_subseconds_4_28: Std_logic;
    signal pps_inst_current_subseconds_4_31: Std_logic;
    signal pps_inst_current_subseconds_4_30: Std_logic;
    signal pps_inst_pps_state_0: Std_logic;
    signal pps_inst_N_344: Std_logic;
    signal pps_inst_pps_state_4: Std_logic;
    signal pps_inst_pps_state_ns_1: Std_logic;
    signal pps_inst_pps_state_ns_0: Std_logic;
    signal pps_inst_pps_state_1: Std_logic;
    signal pps_inst_pps_state_3: Std_logic;
    signal pps_inst_N_346: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_1: Std_logic;
    signal pps_inst_N_299: Std_logic;
    signal pps_inst_N_280_i: Std_logic;
    signal pps_inst_pps_state_ns_2: Std_logic;
    signal pps_inst_N_370: Std_logic;
    signal pps_inst_N_379: Std_logic;
    signal pps_inst_N_288: Std_logic;
    signal pps_inst_N_282_i: Std_logic;
    signal pps_inst_subsec_counter_6_0: Std_logic;
    signal pps_inst_sync_error_5_1: Std_logic;
    signal pps_inst_sync_error_5_0: Std_logic;
    signal pps_inst_sync_error22: Std_logic;
    signal pps_inst_sync_error_0: Std_logic;
    signal pps_inst_sync_error_1: Std_logic;
    signal pps_inst_sync_error_5_3: Std_logic;
    signal pps_inst_sync_error_5_2: Std_logic;
    signal pps_inst_sync_error_2: Std_logic;
    signal pps_inst_sync_error_3: Std_logic;
    signal pps_inst_sync_error_5_5: Std_logic;
    signal pps_inst_sync_error_5_4: Std_logic;
    signal pps_inst_sync_error_4: Std_logic;
    signal pps_inst_sync_error_5: Std_logic;
    signal pps_inst_sync_error_5_7: Std_logic;
    signal pps_inst_sync_error_5_6: Std_logic;
    signal pps_inst_sync_error_6: Std_logic;
    signal pps_inst_sync_error_7: Std_logic;
    signal pps_inst_sync_error_5_9: Std_logic;
    signal pps_inst_sync_error_5_8: Std_logic;
    signal pps_inst_sync_error_8: Std_logic;
    signal pps_inst_sync_error_9: Std_logic;
    signal pps_inst_sync_error_5_11: Std_logic;
    signal pps_inst_sync_error_5_10: Std_logic;
    signal pps_inst_sync_error_10: Std_logic;
    signal pps_inst_sync_error_11: Std_logic;
    signal pps_inst_sync_error_5_13: Std_logic;
    signal pps_inst_sync_error_5_12: Std_logic;
    signal pps_inst_sync_error_12: Std_logic;
    signal pps_inst_sync_error_13: Std_logic;
    signal pps_inst_sync_error_5_15: Std_logic;
    signal pps_inst_sync_error_5_14: Std_logic;
    signal pps_inst_sync_error_14: Std_logic;
    signal pps_inst_sync_error_15: Std_logic;
    signal pps_inst_sync_error_5_17: Std_logic;
    signal pps_inst_sync_error_5_16: Std_logic;
    signal pps_inst_sync_error_16: Std_logic;
    signal pps_inst_sync_error_17: Std_logic;
    signal pps_inst_sync_error_5_19: Std_logic;
    signal pps_inst_sync_error_5_18: Std_logic;
    signal pps_inst_sync_error_18: Std_logic;
    signal pps_inst_sync_error_19: Std_logic;
    signal pps_inst_sync_error_5_21: Std_logic;
    signal pps_inst_sync_error_5_20: Std_logic;
    signal pps_inst_sync_error_20: Std_logic;
    signal pps_inst_sync_error_21: Std_logic;
    signal pps_inst_sync_error_5_23: Std_logic;
    signal pps_inst_sync_error_5_22: Std_logic;
    signal pps_inst_sync_error_22: Std_logic;
    signal pps_inst_sync_error_23: Std_logic;
    signal pps_inst_sync_error_5_25: Std_logic;
    signal pps_inst_sync_error_5_24: Std_logic;
    signal pps_inst_sync_error_24: Std_logic;
    signal pps_inst_sync_error_25: Std_logic;
    signal pps_inst_sync_error_5_27: Std_logic;
    signal pps_inst_sync_error_5_26: Std_logic;
    signal pps_inst_sync_error_26: Std_logic;
    signal pps_inst_sync_error_27: Std_logic;
    signal pps_inst_sync_error_5_29: Std_logic;
    signal pps_inst_sync_error_5_28: Std_logic;
    signal pps_inst_sync_error_28: Std_logic;
    signal pps_inst_sync_error_29: Std_logic;
    signal pps_inst_sync_error_5_31: Std_logic;
    signal pps_inst_sync_error_5_30: Std_logic;
    signal pps_inst_sync_error_30: Std_logic;
    signal pps_inst_sync_error_31: Std_logic;
    signal pps_inst_drift_accumulator8lto31_12: Std_logic;
    signal pps_inst_drift_accumulator8lto31_11: Std_logic;
    signal pps_inst_drift_accumulator8lto31_10: Std_logic;
    signal pps_inst_N_378_3: Std_logic;
    signal pps_inst_drift_accumulator8lto31_18: Std_logic;
    signal pps_inst_drift_accumulator8lto31_14: Std_logic;
    signal pps_inst_drift_accumulator8lto31_13: Std_logic;
    signal pps_inst_N_295: Std_logic;
    signal pps_inst_drift_accumulator8: Std_logic;
    signal pps_inst_sync_valid: Std_logic;
    signal pps_inst_N_5789_0: Std_logic;
    signal pps_inst_subsec_counter_RNIAM37H_16: Std_logic;
    signal reset_sync_inst_VCC: Std_logic;
    signal reset_sync_inst_reset_sync_reg_0: Std_logic;
    signal rst_n_c: Std_logic;
    signal reset_sync_inst_reset_sync_reg_1: Std_logic;
    signal reset_sync_inst_reset_sync_reg_2: Std_logic;
    signal led_power_c: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_1_1: Std_logic;
    signal pps_inst_pps_state_ns_i_o2_3_4: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_1: Std_logic;
    signal pps_inst_un1_m3_0_a3_2: Std_logic;
    signal pps_inst_subsec_counter_6_1_3: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_29: Std_logic;
    signal pps_inst_subsec_counter_6_1_5: Std_logic;
    signal pps_inst_subsec_counter_6_1_10: Std_logic;
    signal extractor_inst_un28_timestamp_buffer: Std_logic;
    signal extractor_inst_byte_index_n1_i_a2: Std_logic;
    signal extractor_inst_un1_packet_active8_i_a4_0: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_2_2: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_12_1: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_11_1: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_10_1: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_9_1: Std_logic;
    signal pps_inst_N_357: Std_logic;
    signal pps_inst_pps_state_ns_i_o2_2_4: Std_logic;
    signal pps_inst_pps_state_ns_i_a2_3_1_4: Std_logic;
    signal pps_inst_drift_accumulator8lt31_3: Std_logic;
    signal pps_inst_pps_state_ns_i_a2_4_4: Std_logic;
    signal pps_inst_un1_m3_0_a3_1: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_29_11: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_29_9: Std_logic;
    signal pps_inst_un1_N_4_0: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_29_10: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_29_8: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_3: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_14_2: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_9_2: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_19_2: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_18_2: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_27_5: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_27_4: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_23: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_1: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_17_2: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_11_2: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_14: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_13: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_12: Std_logic;
    signal pps_inst_pps_armed_1_sqmuxa_11: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_3_1_1: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_1_3_2: Std_logic;
    signal pps_inst_current_seconds_0_sqmuxa_1_a2_0_0: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_13_2: Std_logic;
    signal pps_inst_pps_state_ns_0_o2_0_3_2: Std_logic;
    signal pps_inst_pps_state_ns_0_a2_0_8_1: Std_logic;
    signal pps_inst_subsec_counter_RNIM577H_20: Std_logic;
    signal pps_inst_subsec_counter_RNI6M77H_24: Std_logic;
    signal pps_inst_subsec_counter_RNI4M97H_28: Std_logic;
    signal extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0: Std_logic;
    signal extractor_inst_timestamp_buffer_6_0_sqmuxa_0_a4_0: Std_logic;
    signal extractor_inst_timestamp_buffer_5_0_sqmuxa_0_a4_0: Std_logic;
    signal extractor_inst_extract_state_tr8_24: Std_logic;
    signal extractor_inst_extract_state_tr8_23: Std_logic;
    signal extractor_inst_extract_state_tr8_22: Std_logic;
    signal extractor_inst_extract_state_tr8_21: Std_logic;
    signal extractor_inst_extract_state_tr8_28: Std_logic;
    signal extractor_inst_extract_state_tr8_27: Std_logic;
    signal extractor_inst_extract_state_tr8_26: Std_logic;
    signal extractor_inst_extract_state_tr8_25: Std_logic;
    signal extractor_inst_extract_state_tr8_0: Std_logic;
    signal parser_inst_parser_state_RNIVVM5_2: Std_logic;
    signal parser_inst_N_101_10: Std_logic;
    signal parser_inst_parser_state_ns_i_0_o3_4: Std_logic;
    signal parser_inst_g2_0_9: Std_logic;
    signal parser_inst_g2_0_8: Std_logic;
    signal parser_inst_g2_0_7: Std_logic;
    signal parser_inst_g2_0_6: Std_logic;
    signal debug_status_c_7: Std_logic;
    signal led_error_c: Std_logic;
    signal t2mi_data_c_7: Std_logic;
    signal t2mi_data_c_6: Std_logic;
    signal t2mi_data_c_5: Std_logic;
    signal t2mi_data_c_4: Std_logic;
    signal t2mi_data_c_3: Std_logic;
    signal t2mi_data_c_2: Std_logic;
    signal t2mi_data_c_1: Std_logic;
    signal t2mi_data_c_0: Std_logic;
    signal t2mi_valid_c: Std_logic;
    signal VCCI: Std_logic;
    component pps_outB
      port (PADDO: in Std_logic; ppsout: out Std_logic);
    end component;
    component clk_100mhzB
      port (PADDI: out Std_logic; clk100mhz: in Std_logic);
    end component;
    component led_errorB
      port (PADDO: in Std_logic; lederror: out Std_logic);
    end component;
    component led_ppsB
      port (PADDO: in Std_logic; ledpps: out Std_logic);
    end component;
    component led_syncB
      port (PADDO: in Std_logic; ledsync: out Std_logic);
    end component;
    component led_powerB
      port (PADDO: in Std_logic; ledpower: out Std_logic);
    end component;
    component debug_status_7_B
      port (PADDO: in Std_logic; debugstatus7: out Std_logic);
    end component;
    component debug_status_6_B
      port (PADDO: in Std_logic; debugstatus6: out Std_logic);
    end component;
    component debug_status_5_B
      port (PADDO: in Std_logic; debugstatus5: out Std_logic);
    end component;
    component debug_status_4_B
      port (PADDO: in Std_logic; debugstatus4: out Std_logic);
    end component;
    component debug_status_3_B
      port (PADDO: in Std_logic; debugstatus3: out Std_logic);
    end component;
    component debug_status_2_B
      port (PADDO: in Std_logic; debugstatus2: out Std_logic);
    end component;
    component debug_status_1_B
      port (PADDO: in Std_logic; debugstatus1: out Std_logic);
    end component;
    component debug_status_0_B
      port (PADDO: in Std_logic; debugstatus0: out Std_logic);
    end component;
    component sync_lockedB
      port (PADDO: in Std_logic; synclocked: out Std_logic);
    end component;
    component timestamp_validB
      port (PADDO: in Std_logic; timestampvalid: out Std_logic);
    end component;
    component t2mi_data_7_B
      port (PADDI: out Std_logic; t2midata7: in Std_logic);
    end component;
    component t2mi_data_7_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_6_B
      port (PADDI: out Std_logic; t2midata6: in Std_logic);
    end component;
    component t2mi_data_6_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_5_B
      port (PADDI: out Std_logic; t2midata5: in Std_logic);
    end component;
    component t2mi_data_5_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_4_B
      port (PADDI: out Std_logic; t2midata4: in Std_logic);
    end component;
    component t2mi_data_4_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_3_B
      port (PADDI: out Std_logic; t2midata3: in Std_logic);
    end component;
    component t2mi_data_3_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_2_B
      port (PADDI: out Std_logic; t2midata2: in Std_logic);
    end component;
    component t2mi_data_2_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_1_B
      port (PADDI: out Std_logic; t2midata1: in Std_logic);
    end component;
    component t2mi_data_1_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_data_0_B
      port (PADDI: out Std_logic; t2midata0: in Std_logic);
    end component;
    component t2mi_data_0_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component t2mi_validB
      port (PADDI: out Std_logic; t2mivalid: in Std_logic);
    end component;
    component t2mi_valid_MGIOL
      port (DI: in Std_logic; CLK: in Std_logic; INFF: out Std_logic);
    end component;
    component rst_nB
      port (PADDI: out Std_logic; rstn: in Std_logic);
    end component;
    component GSR_INSTB
      port (GSRNET: in Std_logic);
    end component;
  begin
    pps_inst_SLICE_0I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"D1E2")
      port map (M1=>'X', A1=>pps_inst_time_valid, B1=>debug_status_c_3, 
                C1=>subseconds_0, D1=>pps_inst_subsec_counter_0, DI1=>'X', 
                DI0=>'X', A0=>'1', B0=>'1', C0=>'1', D0=>'1', FCI=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_0, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_1I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_2, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>pps_inst_subsec_counter_6_2, 
                DI0=>pps_inst_subsec_counter_6_1, 
                A0=>pps_inst_subsec_counter_6_axb_1, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_0, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_2, 
                F1=>pps_inst_subsec_counter_6_2, Q1=>pps_inst_subsec_counter_2, 
                F0=>pps_inst_subsec_counter_6_1, Q0=>pps_inst_subsec_counter_1);
    pps_inst_SLICE_2I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_4, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>pps_inst_subsec_counter_6_4, 
                DI0=>pps_inst_subsec_counter_6_3, 
                A0=>pps_inst_subsec_counter_3, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_3_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_2, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_4, 
                F1=>pps_inst_subsec_counter_6_4, Q1=>pps_inst_subsec_counter_4, 
                F0=>pps_inst_subsec_counter_6_3, Q0=>pps_inst_subsec_counter_3);
    pps_inst_SLICE_3I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_6, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>pps_inst_subsec_counter_6_6, 
                DI0=>pps_inst_subsec_counter_6_5, 
                A0=>pps_inst_subsec_counter_5, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_5_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_4, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_6, 
                F1=>pps_inst_subsec_counter_6_6, Q1=>pps_inst_subsec_counter_6, 
                F0=>pps_inst_subsec_counter_6_5, Q0=>pps_inst_subsec_counter_5);
    pps_inst_SLICE_4I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_8, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>pps_inst_subsec_counter_6_8, 
                DI0=>pps_inst_subsec_counter_6_7, 
                A0=>pps_inst_subsec_counter_6_axb_7, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_6, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_8, 
                F1=>pps_inst_subsec_counter_6_8, Q1=>pps_inst_subsec_counter_8, 
                F0=>pps_inst_subsec_counter_6_7, Q0=>pps_inst_subsec_counter_7);
    pps_inst_SLICE_5I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"D202", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_10, B1=>debug_status_c_3, 
                C1=>pps_inst_subsec_counter_6_cry_9_0_RNO_0, D1=>'1', 
                DI1=>pps_inst_subsec_counter_6_10, 
                DI0=>pps_inst_subsec_counter_6_9, 
                A0=>pps_inst_subsec_counter_6_axb_9, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_8, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_10, 
                F1=>pps_inst_subsec_counter_6_10, 
                Q1=>pps_inst_subsec_counter_10, 
                F0=>pps_inst_subsec_counter_6_9, Q0=>pps_inst_subsec_counter_9);
    pps_inst_SLICE_6I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"D202", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_12, B1=>debug_status_c_3, 
                C1=>pps_inst_subsec_counter_6_cry_11_0_RNO_0, D1=>'1', 
                DI1=>pps_inst_subsec_counter_6_12, 
                DI0=>pps_inst_subsec_counter_6_11, 
                A0=>pps_inst_subsec_counter_11, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_11_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_10, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_12, 
                F1=>pps_inst_subsec_counter_6_12, 
                Q1=>pps_inst_subsec_counter_12, 
                F0=>pps_inst_subsec_counter_6_11, 
                Q0=>pps_inst_subsec_counter_11);
    pps_inst_SLICE_7I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"D202", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_14, B1=>debug_status_c_3, 
                C1=>pps_inst_subsec_counter_6_cry_13_0_RNO_0, D1=>'1', 
                DI1=>pps_inst_subsec_counter_6_14, 
                DI0=>pps_inst_subsec_counter_6_13, 
                A0=>pps_inst_subsec_counter_6_axb_13, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>pps_inst_subsec_counter_6_cry_12, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_14, 
                F1=>pps_inst_subsec_counter_6_14, 
                Q1=>pps_inst_subsec_counter_14, 
                F0=>pps_inst_subsec_counter_6_13, 
                Q0=>pps_inst_subsec_counter_13);
    pps_inst_SLICE_8I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"D202", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_16, B1=>debug_status_c_3, 
                C1=>pps_inst_subsec_counter_6_cry_15_0_RNO_0, D1=>'1', 
                DI1=>pps_inst_subsec_counter_6_16, 
                DI0=>pps_inst_subsec_counter_6_15, 
                A0=>pps_inst_subsec_counter_6_axb_15, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>pps_inst_subsec_counter_6_cry_14, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_16, 
                F1=>pps_inst_subsec_counter_6_16, 
                Q1=>pps_inst_subsec_counter_16, 
                F0=>pps_inst_subsec_counter_6_15, 
                Q0=>pps_inst_subsec_counter_15);
    pps_inst_SLICE_9I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"D202", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_18, B1=>debug_status_c_3, 
                C1=>pps_inst_subsec_counter_6_cry_17_0_RNO_0, D1=>'1', 
                DI1=>pps_inst_subsec_counter_6_18, 
                DI0=>pps_inst_subsec_counter_6_17, 
                A0=>pps_inst_subsec_counter_17, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_17_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_16, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_18, 
                F1=>pps_inst_subsec_counter_6_18, 
                Q1=>pps_inst_subsec_counter_18, 
                F0=>pps_inst_subsec_counter_6_17, 
                Q0=>pps_inst_subsec_counter_17);
    pps_inst_SLICE_10I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_20, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_20, 
                DI0=>pps_inst_subsec_counter_6_19, 
                A0=>pps_inst_subsec_counter_19, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_19_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_18, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_20, 
                F1=>pps_inst_subsec_counter_6_20, 
                Q1=>pps_inst_subsec_counter_20, 
                F0=>pps_inst_subsec_counter_6_19, 
                Q0=>pps_inst_subsec_counter_19);
    pps_inst_SLICE_11I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_22, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_22, 
                DI0=>pps_inst_subsec_counter_6_21, 
                A0=>pps_inst_subsec_counter_6_axb_21, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>pps_inst_subsec_counter_6_cry_20, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_22, 
                F1=>pps_inst_subsec_counter_6_22, 
                Q1=>pps_inst_subsec_counter_22, 
                F0=>pps_inst_subsec_counter_6_21, 
                Q0=>pps_inst_subsec_counter_21);
    pps_inst_SLICE_12I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_24, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_24, 
                DI0=>pps_inst_subsec_counter_6_23, 
                A0=>pps_inst_subsec_counter_23, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_23_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_22, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_24, 
                F1=>pps_inst_subsec_counter_6_24, 
                Q1=>pps_inst_subsec_counter_24, 
                F0=>pps_inst_subsec_counter_6_23, 
                Q0=>pps_inst_subsec_counter_23);
    pps_inst_SLICE_13I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D202", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_26, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_26, 
                DI0=>pps_inst_subsec_counter_6_25, 
                A0=>pps_inst_subsec_counter_25, B0=>debug_status_c_3, 
                C0=>pps_inst_subsec_counter_6_cry_25_0_RNO, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_24, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_26, 
                F1=>pps_inst_subsec_counter_6_26, 
                Q1=>pps_inst_subsec_counter_26, 
                F0=>pps_inst_subsec_counter_6_25, 
                Q0=>pps_inst_subsec_counter_25);
    pps_inst_SLICE_14I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_28, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_28, 
                DI0=>pps_inst_subsec_counter_6_27, 
                A0=>pps_inst_subsec_counter_6_axb_27, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>pps_inst_subsec_counter_6_cry_26, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_28, 
                F1=>pps_inst_subsec_counter_6_28, 
                Q1=>pps_inst_subsec_counter_28, 
                F0=>pps_inst_subsec_counter_6_27, 
                Q0=>pps_inst_subsec_counter_27);
    pps_inst_SLICE_15I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"A003", INIT1_INITVAL=>X"A003", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>pps_inst_subsec_counter_6_axb_30, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>pps_inst_subsec_counter_6_30, 
                DI0=>pps_inst_subsec_counter_6_29, 
                A0=>pps_inst_subsec_counter_6_axb_29, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>pps_inst_subsec_counter_6_cry_28, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_subsec_counter_6_cry_30, 
                F1=>pps_inst_subsec_counter_6_30, 
                Q1=>pps_inst_subsec_counter_30, 
                F0=>pps_inst_subsec_counter_6_29, 
                Q0=>pps_inst_subsec_counter_29);
    pps_inst_SLICE_16I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"CA0A", INIT1_INITVAL=>X"5003", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>pps_inst_subsec_counter_6_31, 
                A0=>pps_inst_subsec_counter_31, B0=>subseconds_31, 
                C0=>debug_status_c_3, D0=>'1', 
                FCI=>pps_inst_subsec_counter_6_cry_30, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', FCO=>open, F1=>open, Q1=>open, 
                F0=>pps_inst_subsec_counter_6_31, 
                Q0=>pps_inst_subsec_counter_31);
    pps_inst_SLICE_17I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500C", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_0, B1=>pps_inst_current_subseconds_0, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>'1', B0=>'1', 
                C0=>'1', D0=>'1', FCI=>'X', M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_0, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_18I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_2, B1=>pps_inst_current_subseconds_2, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_1, 
                B0=>pps_inst_current_subseconds_1, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_0, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_2, 
                F1=>pps_inst_sync_error_5_0_0_cry_1_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_1_0_S0, Q0=>open);
    pps_inst_SLICE_19I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_4, B1=>pps_inst_current_subseconds_4, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_3, 
                B0=>pps_inst_current_subseconds_3, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_4, 
                F1=>pps_inst_sync_error_5_0_0_cry_3_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_3_0_S0, Q0=>open);
    pps_inst_SLICE_20I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_6, B1=>pps_inst_current_subseconds_6, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_5, 
                B0=>pps_inst_current_subseconds_5, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_4, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_6, 
                F1=>pps_inst_sync_error_5_0_0_cry_5_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_5_0_S0, Q0=>open);
    pps_inst_SLICE_21I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_8, B1=>pps_inst_current_subseconds_8, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_7, 
                B0=>pps_inst_current_subseconds_7, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_6, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_8, 
                F1=>pps_inst_sync_error_5_0_0_cry_7_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_7_0_S0, Q0=>open);
    pps_inst_SLICE_22I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_10, B1=>pps_inst_current_subseconds_10, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_9, 
                B0=>pps_inst_current_subseconds_9, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_8, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_10, 
                F1=>pps_inst_sync_error_5_0_0_cry_9_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_9_0_S0, Q0=>open);
    pps_inst_SLICE_23I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_12, B1=>pps_inst_current_subseconds_12, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_11, 
                B0=>pps_inst_current_subseconds_11, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_10, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_12, 
                F1=>pps_inst_sync_error_5_0_0_cry_11_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_11_0_S0, Q0=>open);
    pps_inst_SLICE_24I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_14, B1=>pps_inst_current_subseconds_14, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_13, 
                B0=>pps_inst_current_subseconds_13, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_12, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_14, 
                F1=>pps_inst_sync_error_5_0_0_cry_13_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_13_0_S0, Q0=>open);
    pps_inst_SLICE_25I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_16, B1=>pps_inst_current_subseconds_16, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_15, 
                B0=>pps_inst_current_subseconds_15, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_14, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_16, 
                F1=>pps_inst_sync_error_5_0_0_cry_15_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_15_0_S0, Q0=>open);
    pps_inst_SLICE_26I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_18, B1=>pps_inst_current_subseconds_18, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_17, 
                B0=>pps_inst_current_subseconds_17, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_16, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_18, 
                F1=>pps_inst_sync_error_5_0_0_cry_17_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_17_0_S0, Q0=>open);
    pps_inst_SLICE_27I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_20, B1=>pps_inst_current_subseconds_20, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_19, 
                B0=>pps_inst_current_subseconds_19, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_18, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_20, 
                F1=>pps_inst_sync_error_5_0_0_cry_19_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_19_0_S0, Q0=>open);
    pps_inst_SLICE_28I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_22, B1=>pps_inst_current_subseconds_22, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_21, 
                B0=>pps_inst_current_subseconds_21, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_20, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_22, 
                F1=>pps_inst_sync_error_5_0_0_cry_21_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_21_0_S0, Q0=>open);
    pps_inst_SLICE_29I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_24, B1=>pps_inst_current_subseconds_24, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_23, 
                B0=>pps_inst_current_subseconds_23, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_22, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_24, 
                F1=>pps_inst_sync_error_5_0_0_cry_23_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_23_0_S0, Q0=>open);
    pps_inst_SLICE_30I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_26, B1=>pps_inst_current_subseconds_26, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_25, 
                B0=>pps_inst_current_subseconds_25, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_24, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_26, 
                F1=>pps_inst_sync_error_5_0_0_cry_25_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_25_0_S0, Q0=>open);
    pps_inst_SLICE_31I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_28, B1=>pps_inst_current_subseconds_28, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_27, 
                B0=>pps_inst_current_subseconds_27, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_26, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_28, 
                F1=>pps_inst_sync_error_5_0_0_cry_27_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_27_0_S0, Q0=>open);
    pps_inst_SLICE_32I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_30, B1=>pps_inst_current_subseconds_30, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_29, 
                B0=>pps_inst_current_subseconds_29, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_28, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error_5_0_0_cry_30, 
                F1=>pps_inst_sync_error_5_0_0_cry_29_0_S1, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_cry_29_0_S0, Q0=>open);
    pps_inst_SLICE_33I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"5003")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>subseconds_31, 
                B0=>pps_inst_current_subseconds_31, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error_5_0_0_cry_30, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>open, F1=>open, Q1=>open, 
                F0=>pps_inst_sync_error_5_0_0_s_31_0_S0, Q0=>open);
    pps_inst_SLICE_34I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"500C", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", CHECK_DI1=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_0, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_0, 
                DI0=>'X', A0=>'1', B0=>pps_inst_N_166, C0=>'1', D0=>'1', 
                FCI=>'X', M0=>'X', CE=>pps_inst_pps_pulse_countere, 
                CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_0, 
                F1=>pps_inst_pps_pulse_counter_s_0, 
                Q1=>pps_inst_pps_pulse_counter_0, F0=>open, Q0=>open);
    pps_inst_SLICE_35I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_2, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_2, 
                DI0=>pps_inst_pps_pulse_counter_s_1, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_1, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_0, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_2, 
                F1=>pps_inst_pps_pulse_counter_s_2, 
                Q1=>pps_inst_pps_pulse_counter_2, 
                F0=>pps_inst_pps_pulse_counter_s_1, 
                Q0=>pps_inst_pps_pulse_counter_1);
    pps_inst_SLICE_36I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_4, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_4, 
                DI0=>pps_inst_pps_pulse_counter_s_3, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_3, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_2, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_4, 
                F1=>pps_inst_pps_pulse_counter_s_4, 
                Q1=>pps_inst_pps_pulse_counter_4, 
                F0=>pps_inst_pps_pulse_counter_s_3, 
                Q0=>pps_inst_pps_pulse_counter_3);
    pps_inst_SLICE_37I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_6, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_6, 
                DI0=>pps_inst_pps_pulse_counter_s_5, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_5, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_4, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_6, 
                F1=>pps_inst_pps_pulse_counter_s_6, 
                Q1=>pps_inst_pps_pulse_counter_6, 
                F0=>pps_inst_pps_pulse_counter_s_5, 
                Q0=>pps_inst_pps_pulse_counter_5);
    pps_inst_SLICE_38I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_8, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_8, 
                DI0=>pps_inst_pps_pulse_counter_s_7, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_7, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_6, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_8, 
                F1=>pps_inst_pps_pulse_counter_s_8, 
                Q1=>pps_inst_pps_pulse_counter_8, 
                F0=>pps_inst_pps_pulse_counter_s_7, 
                Q0=>pps_inst_pps_pulse_counter_7);
    pps_inst_SLICE_39I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_10, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_10, 
                DI0=>pps_inst_pps_pulse_counter_s_9, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_9, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_8, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_10, 
                F1=>pps_inst_pps_pulse_counter_s_10, 
                Q1=>pps_inst_pps_pulse_counter_10, 
                F0=>pps_inst_pps_pulse_counter_s_9, 
                Q0=>pps_inst_pps_pulse_counter_9);
    pps_inst_SLICE_40I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_12, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_12, 
                DI0=>pps_inst_pps_pulse_counter_s_11, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_11, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_10, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_12, 
                F1=>pps_inst_pps_pulse_counter_s_12, 
                Q1=>pps_inst_pps_pulse_counter_12, 
                F0=>pps_inst_pps_pulse_counter_s_11, 
                Q0=>pps_inst_pps_pulse_counter_11);
    pps_inst_SLICE_41I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_14, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_14, 
                DI0=>pps_inst_pps_pulse_counter_s_13, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_13, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_12, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_14, 
                F1=>pps_inst_pps_pulse_counter_s_14, 
                Q1=>pps_inst_pps_pulse_counter_14, 
                F0=>pps_inst_pps_pulse_counter_s_13, 
                Q0=>pps_inst_pps_pulse_counter_13);
    pps_inst_SLICE_42I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_16, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_16, 
                DI0=>pps_inst_pps_pulse_counter_s_15, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_15, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_14, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_16, 
                F1=>pps_inst_pps_pulse_counter_s_16, 
                Q1=>pps_inst_pps_pulse_counter_16, 
                F0=>pps_inst_pps_pulse_counter_s_15, 
                Q0=>pps_inst_pps_pulse_counter_15);
    pps_inst_SLICE_43I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_18, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_18, 
                DI0=>pps_inst_pps_pulse_counter_s_17, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_17, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_16, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_18, 
                F1=>pps_inst_pps_pulse_counter_s_18, 
                Q1=>pps_inst_pps_pulse_counter_18, 
                F0=>pps_inst_pps_pulse_counter_s_17, 
                Q0=>pps_inst_pps_pulse_counter_17);
    pps_inst_SLICE_44I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_20, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_20, 
                DI0=>pps_inst_pps_pulse_counter_s_19, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_19, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_18, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_20, 
                F1=>pps_inst_pps_pulse_counter_s_20, 
                Q1=>pps_inst_pps_pulse_counter_20, 
                F0=>pps_inst_pps_pulse_counter_s_19, 
                Q0=>pps_inst_pps_pulse_counter_19);
    pps_inst_SLICE_45I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_22, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_22, 
                DI0=>pps_inst_pps_pulse_counter_s_21, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_21, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_20, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_22, 
                F1=>pps_inst_pps_pulse_counter_s_22, 
                Q1=>pps_inst_pps_pulse_counter_22, 
                F0=>pps_inst_pps_pulse_counter_s_21, 
                Q0=>pps_inst_pps_pulse_counter_21);
    pps_inst_SLICE_46I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_24, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_24, 
                DI0=>pps_inst_pps_pulse_counter_s_23, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_23, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_22, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_24, 
                F1=>pps_inst_pps_pulse_counter_s_24, 
                Q1=>pps_inst_pps_pulse_counter_24, 
                F0=>pps_inst_pps_pulse_counter_s_23, 
                Q0=>pps_inst_pps_pulse_counter_23);
    pps_inst_SLICE_47I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_26, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_26, 
                DI0=>pps_inst_pps_pulse_counter_s_25, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_25, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_24, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_26, 
                F1=>pps_inst_pps_pulse_counter_s_26, 
                Q1=>pps_inst_pps_pulse_counter_26, 
                F0=>pps_inst_pps_pulse_counter_s_25, 
                Q0=>pps_inst_pps_pulse_counter_25);
    pps_inst_SLICE_48I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_28, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_28, 
                DI0=>pps_inst_pps_pulse_counter_s_27, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_27, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_26, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_28, 
                F1=>pps_inst_pps_pulse_counter_s_28, 
                Q1=>pps_inst_pps_pulse_counter_28, 
                F0=>pps_inst_pps_pulse_counter_s_27, 
                Q0=>pps_inst_pps_pulse_counter_27);
    pps_inst_SLICE_49I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>pps_inst_N_166, B1=>pps_inst_pps_pulse_counter_30, 
                C1=>'1', D1=>'1', DI1=>pps_inst_pps_pulse_counter_s_30, 
                DI0=>pps_inst_pps_pulse_counter_s_29, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_29, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_28, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_pps_pulse_counter_cry_30, 
                F1=>pps_inst_pps_pulse_counter_s_30, 
                Q1=>pps_inst_pps_pulse_counter_30, 
                F0=>pps_inst_pps_pulse_counter_s_29, 
                Q0=>pps_inst_pps_pulse_counter_29);
    pps_inst_SLICE_50I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"800A", INIT1_INITVAL=>X"5003", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>pps_inst_pps_pulse_counter_s_31, A0=>pps_inst_N_166, 
                B0=>pps_inst_pps_pulse_counter_31, C0=>'1', D0=>'1', 
                FCI=>pps_inst_pps_pulse_counter_cry_30, M0=>'X', 
                CE=>pps_inst_pps_pulse_countere, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>open, F1=>open, Q1=>open, 
                F0=>pps_inst_pps_pulse_counter_s_31, 
                Q0=>pps_inst_pps_pulse_counter_31);
    pps_inst_SLICE_51I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", CHECK_DI1=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_0, 
                C1=>pps_inst_current_seconds_0, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_0, DI0=>'X', A0=>'1', 
                B0=>debug_status_c_3, C0=>'1', D0=>'1', FCI=>'X', M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_0, 
                F1=>pps_inst_current_seconds_s_0, 
                Q1=>pps_inst_current_seconds_0, F0=>open, Q0=>open);
    pps_inst_SLICE_52I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_2, 
                C1=>pps_inst_current_seconds_2, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_2, 
                DI0=>pps_inst_current_seconds_s_1, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_1, C0=>pps_inst_current_seconds_1, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_0, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_2, 
                F1=>pps_inst_current_seconds_s_2, 
                Q1=>pps_inst_current_seconds_2, 
                F0=>pps_inst_current_seconds_s_1, 
                Q0=>pps_inst_current_seconds_1);
    pps_inst_SLICE_53I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_4, 
                C1=>pps_inst_current_seconds_4, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_4, 
                DI0=>pps_inst_current_seconds_s_3, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_3, C0=>pps_inst_current_seconds_3, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_2, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_4, 
                F1=>pps_inst_current_seconds_s_4, 
                Q1=>pps_inst_current_seconds_4, 
                F0=>pps_inst_current_seconds_s_3, 
                Q0=>pps_inst_current_seconds_3);
    pps_inst_SLICE_54I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_6, 
                C1=>pps_inst_current_seconds_6, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_6, 
                DI0=>pps_inst_current_seconds_s_5, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_5, C0=>pps_inst_current_seconds_5, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_4, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_6, 
                F1=>pps_inst_current_seconds_s_6, 
                Q1=>pps_inst_current_seconds_6, 
                F0=>pps_inst_current_seconds_s_5, 
                Q0=>pps_inst_current_seconds_5);
    pps_inst_SLICE_55I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_8, 
                C1=>pps_inst_current_seconds_8, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_8, 
                DI0=>pps_inst_current_seconds_s_7, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_7, C0=>pps_inst_current_seconds_7, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_6, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_8, 
                F1=>pps_inst_current_seconds_s_8, 
                Q1=>pps_inst_current_seconds_8, 
                F0=>pps_inst_current_seconds_s_7, 
                Q0=>pps_inst_current_seconds_7);
    pps_inst_SLICE_56I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_10, 
                C1=>pps_inst_current_seconds_10, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_10, 
                DI0=>pps_inst_current_seconds_s_9, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_9, C0=>pps_inst_current_seconds_9, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_8, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_10, 
                F1=>pps_inst_current_seconds_s_10, 
                Q1=>pps_inst_current_seconds_10, 
                F0=>pps_inst_current_seconds_s_9, 
                Q0=>pps_inst_current_seconds_9);
    pps_inst_SLICE_57I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_12, 
                C1=>pps_inst_current_seconds_12, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_12, 
                DI0=>pps_inst_current_seconds_s_11, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_11, C0=>pps_inst_current_seconds_11, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_10, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_12, 
                F1=>pps_inst_current_seconds_s_12, 
                Q1=>pps_inst_current_seconds_12, 
                F0=>pps_inst_current_seconds_s_11, 
                Q0=>pps_inst_current_seconds_11);
    pps_inst_SLICE_58I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_14, 
                C1=>pps_inst_current_seconds_14, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_14, 
                DI0=>pps_inst_current_seconds_s_13, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_13, C0=>pps_inst_current_seconds_13, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_12, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_14, 
                F1=>pps_inst_current_seconds_s_14, 
                Q1=>pps_inst_current_seconds_14, 
                F0=>pps_inst_current_seconds_s_13, 
                Q0=>pps_inst_current_seconds_13);
    pps_inst_SLICE_59I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_16, 
                C1=>pps_inst_current_seconds_16, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_16, 
                DI0=>pps_inst_current_seconds_s_15, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_15, C0=>pps_inst_current_seconds_15, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_14, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_16, 
                F1=>pps_inst_current_seconds_s_16, 
                Q1=>pps_inst_current_seconds_16, 
                F0=>pps_inst_current_seconds_s_15, 
                Q0=>pps_inst_current_seconds_15);
    pps_inst_SLICE_60I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_18, 
                C1=>pps_inst_current_seconds_18, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_18, 
                DI0=>pps_inst_current_seconds_s_17, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_17, C0=>pps_inst_current_seconds_17, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_16, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_18, 
                F1=>pps_inst_current_seconds_s_18, 
                Q1=>pps_inst_current_seconds_18, 
                F0=>pps_inst_current_seconds_s_17, 
                Q0=>pps_inst_current_seconds_17);
    pps_inst_SLICE_61I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_20, 
                C1=>pps_inst_current_seconds_20, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_20, 
                DI0=>pps_inst_current_seconds_s_19, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_19, C0=>pps_inst_current_seconds_19, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_18, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_20, 
                F1=>pps_inst_current_seconds_s_20, 
                Q1=>pps_inst_current_seconds_20, 
                F0=>pps_inst_current_seconds_s_19, 
                Q0=>pps_inst_current_seconds_19);
    pps_inst_SLICE_62I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_22, 
                C1=>pps_inst_current_seconds_22, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_22, 
                DI0=>pps_inst_current_seconds_s_21, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_21, C0=>pps_inst_current_seconds_21, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_20, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_22, 
                F1=>pps_inst_current_seconds_s_22, 
                Q1=>pps_inst_current_seconds_22, 
                F0=>pps_inst_current_seconds_s_21, 
                Q0=>pps_inst_current_seconds_21);
    pps_inst_SLICE_63I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_24, 
                C1=>pps_inst_current_seconds_24, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_24, 
                DI0=>pps_inst_current_seconds_s_23, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_23, C0=>pps_inst_current_seconds_23, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_22, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_24, 
                F1=>pps_inst_current_seconds_s_24, 
                Q1=>pps_inst_current_seconds_24, 
                F0=>pps_inst_current_seconds_s_23, 
                Q0=>pps_inst_current_seconds_23);
    pps_inst_SLICE_64I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_26, 
                C1=>pps_inst_current_seconds_26, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_26, 
                DI0=>pps_inst_current_seconds_s_25, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_25, C0=>pps_inst_current_seconds_25, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_24, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_26, 
                F1=>pps_inst_current_seconds_s_26, 
                Q1=>pps_inst_current_seconds_26, 
                F0=>pps_inst_current_seconds_s_25, 
                Q0=>pps_inst_current_seconds_25);
    pps_inst_SLICE_65I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_28, 
                C1=>pps_inst_current_seconds_28, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_28, 
                DI0=>pps_inst_current_seconds_s_27, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_27, C0=>pps_inst_current_seconds_27, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_26, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_28, 
                F1=>pps_inst_current_seconds_s_28, 
                Q1=>pps_inst_current_seconds_28, 
                F0=>pps_inst_current_seconds_s_27, 
                Q0=>pps_inst_current_seconds_27);
    pps_inst_SLICE_66I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_30, 
                C1=>pps_inst_current_seconds_30, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_30, 
                DI0=>pps_inst_current_seconds_s_29, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_29, C0=>pps_inst_current_seconds_29, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_28, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_30, 
                F1=>pps_inst_current_seconds_s_30, 
                Q1=>pps_inst_current_seconds_30, 
                F0=>pps_inst_current_seconds_s_29, 
                Q0=>pps_inst_current_seconds_29);
    pps_inst_SLICE_67I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_32, 
                C1=>pps_inst_current_seconds_32, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_32, 
                DI0=>pps_inst_current_seconds_s_31, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_31, C0=>pps_inst_current_seconds_31, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_30, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_32, 
                F1=>pps_inst_current_seconds_s_32, 
                Q1=>pps_inst_current_seconds_32, 
                F0=>pps_inst_current_seconds_s_31, 
                Q0=>pps_inst_current_seconds_31);
    pps_inst_SLICE_68I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_34, 
                C1=>pps_inst_current_seconds_34, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_34, 
                DI0=>pps_inst_current_seconds_s_33, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_33, C0=>pps_inst_current_seconds_33, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_32, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_34, 
                F1=>pps_inst_current_seconds_s_34, 
                Q1=>pps_inst_current_seconds_34, 
                F0=>pps_inst_current_seconds_s_33, 
                Q0=>pps_inst_current_seconds_33);
    pps_inst_SLICE_69I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_36, 
                C1=>pps_inst_current_seconds_36, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_36, 
                DI0=>pps_inst_current_seconds_s_35, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_35, C0=>pps_inst_current_seconds_35, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_34, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_36, 
                F1=>pps_inst_current_seconds_s_36, 
                Q1=>pps_inst_current_seconds_36, 
                F0=>pps_inst_current_seconds_s_35, 
                Q0=>pps_inst_current_seconds_35);
    pps_inst_SLICE_70I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D800", INIT1_INITVAL=>X"D800", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>debug_status_c_3, B1=>seconds_since_2000_38, 
                C1=>pps_inst_current_seconds_38, D1=>'1', 
                DI1=>pps_inst_current_seconds_s_38, 
                DI0=>pps_inst_current_seconds_s_37, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_37, C0=>pps_inst_current_seconds_37, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_36, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>pps_inst_current_seconds_cry_38, 
                F1=>pps_inst_current_seconds_s_38, 
                Q1=>pps_inst_current_seconds_38, 
                F0=>pps_inst_current_seconds_s_37, 
                Q0=>pps_inst_current_seconds_37);
    pps_inst_SLICE_71I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"D805", INIT1_INITVAL=>X"5003", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>pps_inst_current_seconds_s_39, A0=>debug_status_c_3, 
                B0=>seconds_since_2000_39, C0=>pps_inst_current_seconds_39, 
                D0=>'1', FCI=>pps_inst_current_seconds_cry_38, M0=>'X', 
                CE=>pps_inst_current_secondse, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>open, F1=>open, Q1=>open, 
                F0=>pps_inst_current_seconds_s_39, 
                Q0=>pps_inst_current_seconds_39);
    pps_inst_SLICE_72I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500C", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_0, B1=>subseconds_0, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>'1', B0=>'1', 
                C0=>'1', D0=>'1', FCI=>'X', M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_un1_current_subseconds_0_cry_0, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_73I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_2, B1=>subseconds_2, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_1, B0=>subseconds_1, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_2, 
                F1=>pps_inst_un1_current_subseconds_10_2, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_1, Q0=>open);
    pps_inst_SLICE_74I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_4, B1=>subseconds_4, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_3, B0=>subseconds_3, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_2, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_4, 
                F1=>pps_inst_un1_current_subseconds_10_4, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_3, Q0=>open);
    pps_inst_SLICE_75I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_6, B1=>subseconds_6, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_5, B0=>subseconds_5, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_4, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_6, 
                F1=>pps_inst_un1_current_subseconds_10_6, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_5, Q0=>open);
    pps_inst_SLICE_76I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_8, B1=>subseconds_8, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_7, B0=>subseconds_7, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_6, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_8, 
                F1=>pps_inst_un1_current_subseconds_10_8, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_7, Q0=>open);
    pps_inst_SLICE_77I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_10, B1=>subseconds_10, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_9, B0=>subseconds_9, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_8, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_10, 
                F1=>pps_inst_un1_current_subseconds_10_10, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_9, Q0=>open);
    pps_inst_SLICE_78I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_12, B1=>subseconds_12, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_11, B0=>subseconds_11, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_10, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_12, 
                F1=>pps_inst_un1_current_subseconds_10_12, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_11, Q0=>open);
    pps_inst_SLICE_79I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_14, B1=>subseconds_14, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_13, B0=>subseconds_13, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_12, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_14, 
                F1=>pps_inst_un1_current_subseconds_10_14, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_13, Q0=>open);
    pps_inst_SLICE_80I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_16, B1=>subseconds_16, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_15, B0=>subseconds_15, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_14, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_16, 
                F1=>pps_inst_un1_current_subseconds_10_16, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_15, Q0=>open);
    pps_inst_SLICE_81I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_18, B1=>subseconds_18, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_17, B0=>subseconds_17, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_16, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_18, 
                F1=>pps_inst_un1_current_subseconds_10_18, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_17, Q0=>open);
    pps_inst_SLICE_82I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_20, B1=>subseconds_20, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_19, B0=>subseconds_19, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_18, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_20, 
                F1=>pps_inst_un1_current_subseconds_10_20, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_19, Q0=>open);
    pps_inst_SLICE_83I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_22, B1=>subseconds_22, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_21, B0=>subseconds_21, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_20, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_22, 
                F1=>pps_inst_un1_current_subseconds_10_22, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_21, Q0=>open);
    pps_inst_SLICE_84I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_24, B1=>subseconds_24, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_23, B0=>subseconds_23, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_22, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_24, 
                F1=>pps_inst_un1_current_subseconds_10_24, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_23, Q0=>open);
    pps_inst_SLICE_85I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_26, B1=>subseconds_26, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_25, B0=>subseconds_25, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_24, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_26, 
                F1=>pps_inst_un1_current_subseconds_10_26, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_25, Q0=>open);
    pps_inst_SLICE_86I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_28, B1=>subseconds_28, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_27, B0=>subseconds_27, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_26, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_28, 
                F1=>pps_inst_un1_current_subseconds_10_28, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_27, Q0=>open);
    pps_inst_SLICE_87I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>pps_inst_current_subseconds_30, B1=>subseconds_30, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_subseconds_29, B0=>subseconds_29, C0=>'1', 
                D0=>'1', FCI=>pps_inst_un1_current_subseconds_0_cry_28, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>pps_inst_un1_current_subseconds_0_cry_30, 
                F1=>pps_inst_un1_current_subseconds_10_30, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_29, Q0=>open);
    pps_inst_SLICE_88I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"5003")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>pps_inst_current_subseconds_31, 
                B0=>subseconds_31, C0=>'1', D0=>'1', 
                FCI=>pps_inst_un1_current_subseconds_0_cry_30, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', FCO=>open, F1=>open, Q1=>open, 
                F0=>pps_inst_un1_current_subseconds_10_31, Q0=>open);
    pps_inst_SLICE_89I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_0, B1=>pps_inst_current_subseconds_0, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>'1', B0=>'1', 
                C0=>'1', D0=>'1', FCI=>'X', M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_0, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_90I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_2, B1=>pps_inst_current_subseconds_2, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_1, 
                B0=>pps_inst_current_subseconds_1, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_0, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_2, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_91I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_4, B1=>pps_inst_current_subseconds_4, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_3, 
                B0=>pps_inst_current_subseconds_3, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_2, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_4, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_92I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_6, B1=>pps_inst_current_subseconds_6, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_5, 
                B0=>pps_inst_current_subseconds_5, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_4, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_6, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_93I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_8, B1=>pps_inst_current_subseconds_8, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_7, 
                B0=>pps_inst_current_subseconds_7, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_6, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_8, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_94I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_10, B1=>pps_inst_current_subseconds_10, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_9, 
                B0=>pps_inst_current_subseconds_9, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_8, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_10, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_95I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_12, B1=>pps_inst_current_subseconds_12, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_11, 
                B0=>pps_inst_current_subseconds_11, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_10, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_12, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_96I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_14, B1=>pps_inst_current_subseconds_14, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_13, 
                B0=>pps_inst_current_subseconds_13, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_12, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_14, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_97I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_16, B1=>pps_inst_current_subseconds_16, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_15, 
                B0=>pps_inst_current_subseconds_15, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_14, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_16, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_98I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_18, B1=>pps_inst_current_subseconds_18, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_17, 
                B0=>pps_inst_current_subseconds_17, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_16, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_18, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_99I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_20, B1=>pps_inst_current_subseconds_20, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_19, 
                B0=>pps_inst_current_subseconds_19, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_18, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_20, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_100I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_22, B1=>pps_inst_current_subseconds_22, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_21, 
                B0=>pps_inst_current_subseconds_21, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_20, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_22, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_101I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_24, B1=>pps_inst_current_subseconds_24, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_23, 
                B0=>pps_inst_current_subseconds_23, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_22, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_24, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_102I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_26, B1=>pps_inst_current_subseconds_26, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_25, 
                B0=>pps_inst_current_subseconds_25, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_24, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_26, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_103I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_28, B1=>pps_inst_current_subseconds_28, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_27, 
                B0=>pps_inst_current_subseconds_27, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_26, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_28, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_104I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>subseconds_30, B1=>pps_inst_current_subseconds_30, 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', A0=>subseconds_29, 
                B0=>pps_inst_current_subseconds_29, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_28, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>pps_inst_sync_error12_cry_30, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_105I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"5003")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>subseconds_31, 
                B0=>pps_inst_current_subseconds_31, C0=>'1', D0=>'1', 
                FCI=>pps_inst_sync_error12_cry_30, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', FCO=>open, F1=>pps_inst_sync_error12, Q1=>open, 
                F0=>open, Q0=>open);
    pps_inst_SLICE_106I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", INIT0_INITVAL=>X"500C", 
                   INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_1, 
                B1=>pps_inst_current_seconds_1, C1=>seconds_since_2000_0, 
                D1=>pps_inst_current_seconds_0, DI1=>'X', DI0=>'X', A0=>'1', 
                B0=>'1', C0=>'1', D0=>'1', FCI=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_0, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_107I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_5, 
                B1=>pps_inst_current_seconds_5, C1=>seconds_since_2000_4, 
                D1=>pps_inst_current_seconds_4, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_3, B0=>pps_inst_current_seconds_3, 
                C0=>seconds_since_2000_2, D0=>pps_inst_current_seconds_2, 
                FCI=>pps_inst_sync_error18_0_data_tmp_0, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_2, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_108I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_9, 
                B1=>pps_inst_current_seconds_9, C1=>seconds_since_2000_8, 
                D1=>pps_inst_current_seconds_8, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_7, B0=>pps_inst_current_seconds_7, 
                C0=>seconds_since_2000_6, D0=>pps_inst_current_seconds_6, 
                FCI=>pps_inst_sync_error18_0_data_tmp_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_4, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_109I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_13, 
                B1=>pps_inst_current_seconds_13, C1=>seconds_since_2000_12, 
                D1=>pps_inst_current_seconds_12, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_11, B0=>pps_inst_current_seconds_11, 
                C0=>seconds_since_2000_10, D0=>pps_inst_current_seconds_10, 
                FCI=>pps_inst_sync_error18_0_data_tmp_4, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_6, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_110I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_17, 
                B1=>pps_inst_current_seconds_17, C1=>seconds_since_2000_16, 
                D1=>pps_inst_current_seconds_16, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_15, B0=>pps_inst_current_seconds_15, 
                C0=>seconds_since_2000_14, D0=>pps_inst_current_seconds_14, 
                FCI=>pps_inst_sync_error18_0_data_tmp_6, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_8, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_111I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_21, 
                B1=>pps_inst_current_seconds_21, C1=>seconds_since_2000_20, 
                D1=>pps_inst_current_seconds_20, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_19, B0=>pps_inst_current_seconds_19, 
                C0=>seconds_since_2000_18, D0=>pps_inst_current_seconds_18, 
                FCI=>pps_inst_sync_error18_0_data_tmp_8, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_10, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_112I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_25, 
                B1=>pps_inst_current_seconds_25, C1=>seconds_since_2000_24, 
                D1=>pps_inst_current_seconds_24, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_23, B0=>pps_inst_current_seconds_23, 
                C0=>seconds_since_2000_22, D0=>pps_inst_current_seconds_22, 
                FCI=>pps_inst_sync_error18_0_data_tmp_10, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_12, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_113I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_29, 
                B1=>pps_inst_current_seconds_29, C1=>seconds_since_2000_28, 
                D1=>pps_inst_current_seconds_28, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_27, B0=>pps_inst_current_seconds_27, 
                C0=>seconds_since_2000_26, D0=>pps_inst_current_seconds_26, 
                FCI=>pps_inst_sync_error18_0_data_tmp_12, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_14, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_114I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_33, 
                B1=>pps_inst_current_seconds_33, C1=>seconds_since_2000_32, 
                D1=>pps_inst_current_seconds_32, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_31, B0=>pps_inst_current_seconds_31, 
                C0=>seconds_since_2000_30, D0=>pps_inst_current_seconds_30, 
                FCI=>pps_inst_sync_error18_0_data_tmp_14, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_16, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_115I: SCCU2C
      generic map (INIT0_INITVAL=>X"9009", INIT1_INITVAL=>X"9009")
      port map (M1=>'X', A1=>seconds_since_2000_37, 
                B1=>pps_inst_current_seconds_37, C1=>seconds_since_2000_36, 
                D1=>pps_inst_current_seconds_36, DI1=>'X', DI0=>'X', 
                A0=>seconds_since_2000_35, B0=>pps_inst_current_seconds_35, 
                C0=>seconds_since_2000_34, D0=>pps_inst_current_seconds_34, 
                FCI=>pps_inst_sync_error18_0_data_tmp_16, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>pps_inst_sync_error18_0_data_tmp_18, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    pps_inst_SLICE_116I: SCCU2C
      generic map (CCU2_INJECT1_1=>"NO", INIT0_INITVAL=>X"9009", 
                   INIT1_INITVAL=>X"A003")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>seconds_since_2000_39, 
                B0=>pps_inst_current_seconds_39, C0=>seconds_since_2000_38, 
                D0=>pps_inst_current_seconds_38, 
                FCI=>pps_inst_sync_error18_0_data_tmp_18, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>open, F1=>pps_inst_sync_error18_i, 
                Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_117I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"0000")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>'1', B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_16_cry, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>open, F1=>open, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_cry_16, Q0=>open);
    parser_inst_SLICE_118I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"500C", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", CHECK_DI1=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_0, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_0, DI0=>'X', A0=>'1', 
                B0=>parser_inst_byte_counter, C0=>'1', D0=>'1', FCI=>'X', 
                M0=>'X', CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_0, 
                F1=>parser_inst_byte_counter_s_0, 
                Q1=>parser_inst_byte_counter_0, F0=>open, Q0=>open);
    parser_inst_SLICE_119I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_2, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_2, 
                DI0=>parser_inst_byte_counter_s_1, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_1, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_0, M0=>'X', 
                CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_2, 
                F1=>parser_inst_byte_counter_s_2, 
                Q1=>parser_inst_byte_counter_2, 
                F0=>parser_inst_byte_counter_s_1, 
                Q0=>parser_inst_byte_counter_1);
    parser_inst_SLICE_120I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_4, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_4, 
                DI0=>parser_inst_byte_counter_s_3, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_3, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_2, M0=>'X', 
                CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_4, 
                F1=>parser_inst_byte_counter_s_4, 
                Q1=>parser_inst_byte_counter_4, 
                F0=>parser_inst_byte_counter_s_3, 
                Q0=>parser_inst_byte_counter_3);
    parser_inst_SLICE_121I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_6, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_6, 
                DI0=>parser_inst_byte_counter_s_5, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_5, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_4, M0=>'X', 
                CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_6, 
                F1=>parser_inst_byte_counter_s_6, 
                Q1=>parser_inst_byte_counter_6, 
                F0=>parser_inst_byte_counter_s_5, 
                Q0=>parser_inst_byte_counter_5);
    parser_inst_SLICE_122I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_8, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_8, 
                DI0=>parser_inst_byte_counter_s_7, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_7, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_6, M0=>'X', 
                CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_8, 
                F1=>parser_inst_byte_counter_s_8, 
                Q1=>parser_inst_byte_counter_8, 
                F0=>parser_inst_byte_counter_s_7, 
                Q0=>parser_inst_byte_counter_7);
    parser_inst_SLICE_123I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_10, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_10, 
                DI0=>parser_inst_byte_counter_s_9, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_9, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_8, M0=>'X', 
                CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_10, 
                F1=>parser_inst_byte_counter_s_10, 
                Q1=>parser_inst_byte_counter_10, 
                F0=>parser_inst_byte_counter_s_9, 
                Q0=>parser_inst_byte_counter_9);
    parser_inst_SLICE_124I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_12, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_12, 
                DI0=>parser_inst_byte_counter_s_11, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_11, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_10, 
                M0=>'X', CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_12, 
                F1=>parser_inst_byte_counter_s_12, 
                Q1=>parser_inst_byte_counter_12, 
                F0=>parser_inst_byte_counter_s_11, 
                Q0=>parser_inst_byte_counter_11);
    parser_inst_SLICE_125I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"8000", INIT1_INITVAL=>X"8000", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_byte_counter_14, C1=>'1', D1=>'1', 
                DI1=>parser_inst_byte_counter_s_14, 
                DI0=>parser_inst_byte_counter_s_13, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_13, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_12, 
                M0=>'X', CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>parser_inst_byte_counter_cry_14, 
                F1=>parser_inst_byte_counter_s_14, 
                Q1=>parser_inst_byte_counter_14, 
                F0=>parser_inst_byte_counter_s_13, 
                Q0=>parser_inst_byte_counter_13);
    parser_inst_SLICE_126I: SCCU2C
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", CCU2_INJECT1_0=>"NO", 
                   CCU2_INJECT1_1=>"NO", SRMODE=>"ASYNC", 
                   INIT0_INITVAL=>X"800A", INIT1_INITVAL=>X"5003", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>parser_inst_byte_counter_s_15, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_byte_counter_15, 
                C0=>'1', D0=>'1', FCI=>parser_inst_byte_counter_cry_14, 
                M0=>'X', CE=>parser_inst_N_4_i, CLK=>clk_100mhz_c, LSR=>'X', 
                FCO=>open, F1=>open, Q1=>open, 
                F0=>parser_inst_byte_counter_s_15, 
                Q0=>parser_inst_byte_counter_15);
    parser_inst_SLICE_127I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_0, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', A0=>'1', B0=>'1', C0=>'1', 
                D0=>'1', FCI=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_0, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_128I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_2, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_1, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_2, 
                F1=>parser_inst_un1_byte_counter_2, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_1, Q0=>open);
    parser_inst_SLICE_129I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_4, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_3, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_2, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_4, 
                F1=>parser_inst_un1_byte_counter_4, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_3, Q0=>open);
    parser_inst_SLICE_130I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_6, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_5, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_4, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_6, 
                F1=>parser_inst_un1_byte_counter_6, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_5, Q0=>open);
    parser_inst_SLICE_131I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_8, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_7, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_6, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_8, 
                F1=>parser_inst_un1_byte_counter_8, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_7, Q0=>open);
    parser_inst_SLICE_132I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_10, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_9, B0=>'1', C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_8, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_10, 
                F1=>parser_inst_un1_byte_counter_10, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_9, Q0=>open);
    parser_inst_SLICE_133I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_12, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_11, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>parser_inst_un1_packet_length_reg_0_cry_10, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_12, 
                F1=>parser_inst_un1_byte_counter_12, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_11, Q0=>open);
    parser_inst_SLICE_134I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_14, B1=>'1', 
                C1=>'1', D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_13, B0=>'1', C0=>'1', 
                D0=>'1', FCI=>parser_inst_un1_packet_length_reg_0_cry_12, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_packet_length_reg_0_cry_14, 
                F1=>parser_inst_un1_byte_counter_14, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_13, Q0=>open);
    parser_inst_SLICE_135I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"500F", INIT1_INITVAL=>X"A003")
      port map (M1=>'X', A1=>'1', B1=>'1', C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_packet_length_reg_15, B0=>'1', 
                C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_packet_length_reg_0_cry_14, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', FCO=>open, 
                F1=>parser_inst_un1_byte_counter_16, Q1=>open, 
                F0=>parser_inst_un1_byte_counter_15, Q0=>open);
    parser_inst_SLICE_136I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"5003", INIT1_INITVAL=>X"3C05")
      port map (M1=>'X', A1=>parser_inst_packet_length_reg_0, 
                B1=>parser_inst_byte_counter_0, 
                C1=>parser_inst_packet_length_reg_0, D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>'1', B0=>'1', C0=>'1', D0=>'1', FCI=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_byte_counter_cry_0, F1=>open, Q1=>open, 
                F0=>open, Q0=>open);
    parser_inst_SLICE_137I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_2, 
                B1=>parser_inst_byte_counter_2, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_1, 
                B0=>parser_inst_byte_counter_1, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_0, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_2, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_138I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_4, 
                B1=>parser_inst_byte_counter_4, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_3, 
                B0=>parser_inst_byte_counter_3, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_4, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_139I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_6, 
                B1=>parser_inst_byte_counter_6, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_5, 
                B0=>parser_inst_byte_counter_5, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_4, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_6, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_140I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_8, 
                B1=>parser_inst_byte_counter_8, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_7, 
                B0=>parser_inst_byte_counter_7, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_6, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_8, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_141I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_10, 
                B1=>parser_inst_byte_counter_10, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_9, 
                B0=>parser_inst_byte_counter_9, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_8, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_10, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_142I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_12, 
                B1=>parser_inst_byte_counter_12, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_11, 
                B0=>parser_inst_byte_counter_11, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_10, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_12, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_143I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"900A")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_14, 
                B1=>parser_inst_byte_counter_14, C1=>'1', D1=>'1', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_un1_byte_counter_13, 
                B0=>parser_inst_byte_counter_13, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_12, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', FCO=>parser_inst_un1_byte_counter_cry_14, 
                F1=>open, Q1=>open, F0=>open, Q0=>open);
    parser_inst_SLICE_144I: SCCU2C
      generic map (CCU2_INJECT1_0=>"NO", CCU2_INJECT1_1=>"NO", 
                   INIT0_INITVAL=>X"900A", INIT1_INITVAL=>X"500F")
      port map (M1=>'X', A1=>parser_inst_un1_byte_counter_16, B1=>'1', C1=>'1', 
                D1=>'1', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_un1_byte_counter_15, 
                B0=>parser_inst_byte_counter_15, C0=>'1', D0=>'1', 
                FCI=>parser_inst_un1_byte_counter_cry_14, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', 
                FCO=>parser_inst_un1_byte_counter_cry_16_cry, F1=>open, 
                Q1=>open, F0=>open, Q0=>open);
    SLICE_145I: SLOGICB
      generic map (M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"8888", REG0_SD=>"VHI", CHECK_DI0=>TRUE, 
                   CHECK_M1=>TRUE)
      port map (M1=>extractor_inst_extract_state_4, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>parser_inst_N_85_i, A0=>parser_inst_byte_counter, 
                B0=>parser_inst_t2mi_valid_sync, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>debug_status_c_3, OFX0=>open, F0=>parser_inst_N_85_i, 
                Q0=>debug_status_c_2);
    SLICE_146I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE)
      port map (M1=>extractor_inst_extract_state_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>parser_inst_parser_state_5, CE=>'X', CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>debug_status_c_6, 
                OFX0=>open, F0=>open, Q0=>debug_status_c_5);
    extractor_inst_SLICE_148I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"1111", LUT1_INITVAL=>X"0606", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_0, 
                B1=>extractor_inst_byte_index_1, 
                C1=>extractor_inst_packet_active6, D1=>'X', 
                DI1=>extractor_inst_N_13_i, 
                DI0=>extractor_inst_byte_index_n0_i_a4, 
                A0=>extractor_inst_byte_index_0, 
                B0=>extractor_inst_packet_active6, C0=>'X', D0=>'X', M0=>'X', 
                CE=>extractor_inst_byte_indexe, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>extractor_inst_N_13_i, 
                Q1=>extractor_inst_byte_index_1, OFX0=>open, 
                F0=>extractor_inst_byte_index_n0_i_a4, 
                Q0=>extractor_inst_byte_index_0);
    extractor_inst_SLICE_149I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"1444", LUT1_INITVAL=>X"00B4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_byte_index_n1_i_o2, 
                B1=>extractor_inst_byte_index_2, 
                C1=>extractor_inst_byte_index_3, 
                D1=>extractor_inst_packet_active6, DI1=>extractor_inst_N_7_i, 
                DI0=>extractor_inst_N_9_i, A0=>extractor_inst_packet_active6, 
                B0=>extractor_inst_byte_index_2, 
                C0=>extractor_inst_byte_index_1, 
                D0=>extractor_inst_byte_index_0, M0=>'X', 
                CE=>extractor_inst_byte_indexe, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>extractor_inst_N_7_i, 
                Q1=>extractor_inst_byte_index_3, OFX0=>open, 
                F0=>extractor_inst_N_9_i, Q0=>extractor_inst_byte_index_2);
    extractor_inst_SLICE_150I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"4444", LUT1_INITVAL=>X"7777", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_2, 
                B1=>extractor_inst_packet_active, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>extractor_inst_packet_active7, 
                A0=>extractor_inst_packet_active6, B0=>packet_end, C0=>'X', 
                D0=>'X', M0=>'X', CE=>extractor_inst_un1_packet_active8_i_0, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_un1_packet_active8_i_o2, Q1=>open, 
                OFX0=>open, F0=>extractor_inst_packet_active7, 
                Q0=>extractor_inst_data_complete);
    extractor_inst_SLICE_151I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", REG0_REGSET=>"SET", 
                   SRMODE=>"ASYNC", LUT0_INITVAL=>X"FFF4", 
                   LUT1_INITVAL=>X"8888", REG1_SD=>"VHI", REG0_SD=>"VHI", 
                   CHECK_DI1=>TRUE, CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_data_complete, 
                B1=>extractor_inst_extract_state_0, C1=>'X', D1=>'X', 
                DI1=>extractor_inst_extract_state_ns_1, 
                DI0=>extractor_inst_extract_state_ns_0, 
                A0=>extractor_inst_data_complete, 
                B0=>extractor_inst_extract_state_0, 
                C0=>extractor_inst_extract_state_4, 
                D0=>extractor_inst_extract_state_5, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_ns_1, 
                Q1=>extractor_inst_extract_state_1, OFX0=>open, 
                F0=>extractor_inst_extract_state_ns_0, 
                Q0=>extractor_inst_extract_state_0);
    extractor_inst_SLICE_152I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"8888", LUT1_INITVAL=>X"0001", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_extract_state_tr8, 
                B1=>extractor_inst_extract_state_1, 
                C1=>extractor_inst_extract_state_5, 
                D1=>extractor_inst_extract_state_ns_2_3, 
                DI1=>extractor_inst_N_119_i, 
                DI0=>extractor_inst_extract_state_ns_2, 
                A0=>extractor_inst_extract_state_1, 
                B0=>extractor_inst_header_valid, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_N_119_i, Q1=>extractor_inst_extract_state_3, 
                OFX0=>open, F0=>extractor_inst_extract_state_ns_2, 
                Q0=>extractor_inst_extract_state_2);
    extractor_inst_SLICE_154I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"AEAE", LUT1_INITVAL=>X"8000", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_extract_state_tr8_29, 
                B1=>extractor_inst_extract_state_tr8_30, 
                C1=>extractor_inst_extract_state_tr8_36, 
                D1=>extractor_inst_extract_state_tr8_37, DI1=>'X', 
                DI0=>extractor_inst_extract_state_ns_5, 
                A0=>extractor_inst_extract_state_tr8, 
                B0=>extractor_inst_extract_state_1, 
                C0=>extractor_inst_header_valid, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_tr8, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_ns_5, 
                Q0=>extractor_inst_extract_state_5);
    extractor_inst_SLICE_155I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"0001", REG0_SD=>"VHI", CHECK_DI0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>extractor_inst_header_valid_2, 
                A0=>extractor_inst_timestamp_buffer_0_4, 
                B0=>extractor_inst_timestamp_buffer_0_5, 
                C0=>extractor_inst_timestamp_buffer_0_6, 
                D0=>extractor_inst_timestamp_buffer_0_7, M0=>'X', 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_header_valid_2, 
                Q0=>extractor_inst_header_valid);
    extractor_inst_SLICE_156I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"0008", LUT1_INITVAL=>X"EEEE", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_packet_active6, 
                B1=>packet_end, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>extractor_inst_packet_active6, 
                A0=>extractor_inst_packet_active6_4, 
                B0=>extractor_inst_packet_active6_5, C0=>packet_type_4, 
                D0=>packet_type_6, M0=>'X', CE=>extractor_inst_N_62_i, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_N_62_i, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_packet_active6, 
                Q0=>extractor_inst_packet_active);
    extractor_inst_SLICE_157I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_7_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_7_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_1, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_0);
    extractor_inst_SLICE_158I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_7_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_7_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_3, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_2);
    extractor_inst_SLICE_159I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_7_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_7_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_5, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_4);
    extractor_inst_SLICE_160I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_7_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_7_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_7, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_6);
    extractor_inst_SLICE_161I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_6_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_6_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_9, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_8);
    extractor_inst_SLICE_162I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_6_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_6_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_11, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_10);
    extractor_inst_SLICE_163I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_6_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_6_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_13, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_12);
    extractor_inst_SLICE_164I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_6_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_6_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_15, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_14);
    extractor_inst_SLICE_165I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_5_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_5_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_17, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_16);
    extractor_inst_SLICE_166I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_5_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_5_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_19, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_18);
    extractor_inst_SLICE_167I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_5_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_5_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_21, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_20);
    extractor_inst_SLICE_168I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_5_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_5_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_23, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_22);
    extractor_inst_SLICE_169I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_4_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_4_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_25, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_24);
    extractor_inst_SLICE_170I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_4_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_4_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_27, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_26);
    extractor_inst_SLICE_171I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_4_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_4_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_29, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_28);
    extractor_inst_SLICE_172I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_4_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_4_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_31, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_30);
    extractor_inst_SLICE_173I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_3_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_3_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_33, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_32);
    extractor_inst_SLICE_174I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_3_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_3_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_35, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_34);
    extractor_inst_SLICE_175I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_3_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_3_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_37, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_36);
    extractor_inst_SLICE_176I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_3_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_3_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_seconds_field_39, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_seconds_field_38);
    extractor_inst_SLICE_177I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_11_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_11_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_1, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_0);
    extractor_inst_SLICE_178I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_11_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_11_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_3, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_2);
    extractor_inst_SLICE_179I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_11_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_11_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_5, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_4);
    extractor_inst_SLICE_180I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_11_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_11_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_7, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_6);
    extractor_inst_SLICE_181I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_10_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_10_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_9, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_8);
    extractor_inst_SLICE_182I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_10_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_10_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_11, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_10);
    extractor_inst_SLICE_183I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_10_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_10_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_13, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_12);
    extractor_inst_SLICE_184I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_10_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_10_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_15, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_14);
    extractor_inst_SLICE_185I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_9_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_9_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_17, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_16);
    extractor_inst_SLICE_186I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_9_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_9_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_19, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_18);
    extractor_inst_SLICE_187I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_9_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_9_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_21, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_20);
    extractor_inst_SLICE_188I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_9_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_9_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_23, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_22);
    extractor_inst_SLICE_189I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_8_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_8_0, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_25, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_24);
    extractor_inst_SLICE_190I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_8_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_8_2, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_27, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_26);
    extractor_inst_SLICE_191I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_8_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_8_4, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_29, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_28);
    extractor_inst_SLICE_192I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_timestamp_buffer_8_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_timestamp_buffer_8_6, 
                CE=>extractor_inst_data_complete, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>extractor_inst_subsec_field_31, 
                OFX0=>open, F0=>open, Q0=>extractor_inst_subsec_field_30);
    extractor_inst_SLICE_193I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_0_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_0_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_0_4);
    extractor_inst_SLICE_194I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_0_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_0_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_0_6);
    extractor_inst_SLICE_195I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_10_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_10_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_10_0);
    extractor_inst_SLICE_196I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_10_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_10_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_10_2);
    extractor_inst_SLICE_197I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_10_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_10_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_10_4);
    extractor_inst_SLICE_198I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_10_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_10_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_10_6);
    extractor_inst_SLICE_199I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_11_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_11_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_11_0);
    extractor_inst_SLICE_200I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_11_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_11_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_11_2);
    extractor_inst_SLICE_201I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_11_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_11_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_11_4);
    extractor_inst_SLICE_202I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_11_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_11_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_11_6);
    extractor_inst_SLICE_203I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_3_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_3_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_3_0);
    extractor_inst_SLICE_204I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_3_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_3_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_3_2);
    extractor_inst_SLICE_205I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_3_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_3_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_3_4);
    extractor_inst_SLICE_206I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_3_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_3_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_3_6);
    extractor_inst_SLICE_207I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_4_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_4_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_4_0);
    extractor_inst_SLICE_208I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_4_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_4_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_4_2);
    extractor_inst_SLICE_209I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_4_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_4_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_4_4);
    extractor_inst_SLICE_210I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_4_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_4_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_4_6);
    extractor_inst_SLICE_211I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_5_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_5_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_5_0);
    extractor_inst_SLICE_212I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_5_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_5_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_5_2);
    extractor_inst_SLICE_213I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_5_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_5_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_5_4);
    extractor_inst_SLICE_214I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_5_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_5_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_5_6);
    extractor_inst_SLICE_215I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_6_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_6_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_6_0);
    extractor_inst_SLICE_216I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_6_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_6_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_6_2);
    extractor_inst_SLICE_217I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_6_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_6_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_6_4);
    extractor_inst_SLICE_218I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_6_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_6_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_6_6);
    extractor_inst_SLICE_219I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_7_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_7_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_7_0);
    extractor_inst_SLICE_220I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_7_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_7_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_7_2);
    extractor_inst_SLICE_221I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_7_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_7_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_7_4);
    extractor_inst_SLICE_222I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_7_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_7_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_7_6);
    extractor_inst_SLICE_223I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_8_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_8_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_8_0);
    extractor_inst_SLICE_224I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_8_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_8_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_8_2);
    extractor_inst_SLICE_225I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_8_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_8_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_8_4);
    extractor_inst_SLICE_226I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_8_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_8_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_8_6);
    extractor_inst_SLICE_227I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_1, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_0, 
                CE=>extractor_inst_timestamp_buffer_9_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_9_1, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_9_0);
    extractor_inst_SLICE_228I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_3, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_2, 
                CE=>extractor_inst_timestamp_buffer_9_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_9_3, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_9_2);
    extractor_inst_SLICE_229I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_5, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_4, 
                CE=>extractor_inst_timestamp_buffer_9_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_9_5, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_9_4);
    extractor_inst_SLICE_230I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>packet_data_7, FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', 
                C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', B0=>'X', 
                C0=>'X', D0=>'X', M0=>packet_data_6, 
                CE=>extractor_inst_timestamp_buffer_9_0_sqmuxa, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>extractor_inst_timestamp_buffer_9_7, OFX0=>open, F0=>open, 
                Q0=>extractor_inst_timestamp_buffer_9_6);
    pps_inst_SLICE_232I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"4000", LUT1_INITVAL=>X"1313", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_armed, 
                B1=>pps_inst_pps_armed_1_sqmuxa, C1=>pps_inst_pps_state_2, 
                D1=>'X', DI1=>'X', DI0=>pps_inst_pps_armed_1_sqmuxa, 
                A0=>pps_inst_N_360, B0=>pps_inst_pps_armed_1_sqmuxa_15, 
                C0=>pps_inst_pps_armed_1_sqmuxa_16, 
                D0=>pps_inst_pps_armed_1_sqmuxa_20, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>pps_inst_un1_next_pps_time_1_sqmuxa_i, Q1=>open, 
                OFX0=>open, F0=>pps_inst_pps_armed_1_sqmuxa, Q0=>led_pps_c);
    parser_inst_SLICE_233I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"A69A", REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>parser_inst_sync_counter_3, 
                A0=>led_sync_c, B0=>parser_inst_sync_counterf_2, 
                C0=>parser_inst_un1_sync_counter14_2f_1, 
                D0=>parser_inst_un1_sync_counter_c2, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>open, F0=>parser_inst_sync_counter_3, Q0=>led_sync_c);
    parser_inst_SLICE_234I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_1, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_0, 
                CE=>parser_inst_N_85_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_data_1, OFX0=>open, F0=>open, 
                Q0=>packet_data_0);
    parser_inst_SLICE_235I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_3, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_2, 
                CE=>parser_inst_N_85_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_data_3, OFX0=>open, F0=>open, 
                Q0=>packet_data_2);
    parser_inst_SLICE_236I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_5, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_4, 
                CE=>parser_inst_N_85_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_data_5, OFX0=>open, F0=>open, 
                Q0=>packet_data_4);
    parser_inst_SLICE_237I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_7, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_6, 
                CE=>parser_inst_N_85_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_data_7, OFX0=>open, F0=>open, 
                Q0=>packet_data_6);
    parser_inst_SLICE_238I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"0808", REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>parser_inst_packet_end_0_sqmuxa, 
                A0=>parser_inst_byte_counter, B0=>parser_inst_t2mi_valid_sync, 
                C0=>parser_inst_un1_byte_counter_cry_16, D0=>'X', M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>parser_inst_packet_end_0_sqmuxa, 
                Q0=>packet_end);
    parser_inst_SLICE_239I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"8000", REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>parser_inst_next_state_0_sqmuxa, 
                A0=>parser_inst_t2mi_valid_sync, 
                B0=>parser_inst_parser_state_0, C0=>parser_inst_sync_found, 
                D0=>led_sync_c, M0=>'X', CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>parser_inst_next_state_0_sqmuxa, Q0=>packet_start);
    parser_inst_SLICE_240I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_1, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_0, 
                CE=>parser_inst_N_87_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_type_1, OFX0=>open, F0=>open, 
                Q0=>packet_type_0);
    parser_inst_SLICE_241I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_3, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_2, 
                CE=>parser_inst_N_87_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_type_3, OFX0=>open, F0=>open, 
                Q0=>packet_type_2);
    parser_inst_SLICE_242I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_5, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_4, 
                CE=>parser_inst_N_87_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_type_5, OFX0=>open, F0=>open, 
                Q0=>packet_type_4);
    parser_inst_SLICE_243I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_7, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_6, 
                CE=>parser_inst_N_87_i, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>packet_type_7, OFX0=>open, F0=>open, 
                Q0=>packet_type_6);
    parser_inst_SLICE_244I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"5545", LUT1_INITVAL=>X"1555", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_byte_counter, 
                B1=>parser_inst_g2_0, C1=>parser_inst_parser_state_3, 
                D1=>parser_inst_t2mi_valid_sync, DI1=>'X', 
                DI0=>parser_inst_N_98_i, A0=>parser_inst_N_7, 
                B0=>parser_inst_parser_state_3, 
                C0=>parser_inst_t2mi_valid_sync, 
                D0=>parser_inst_un1_byte_counter_cry_16, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>parser_inst_N_7, 
                Q1=>open, OFX0=>open, F0=>parser_inst_N_98_i, 
                Q0=>parser_inst_byte_counter);
    parser_inst_SLICE_245I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_1, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_0, 
                CE=>parser_inst_parser_state_RNI7DD56_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_1, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_0);
    parser_inst_SLICE_246I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_3, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_2, 
                CE=>parser_inst_parser_state_RNI7DD56_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_3, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_2);
    parser_inst_SLICE_247I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_5, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_4, 
                CE=>parser_inst_parser_state_RNI7DD56_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_5, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_4);
    parser_inst_SLICE_248I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_7, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_6, 
                CE=>parser_inst_parser_state_RNI7DD56_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_7, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_6);
    parser_inst_SLICE_249I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_1, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_0, 
                CE=>parser_inst_packet_length_regce_8, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_9, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_8);
    parser_inst_SLICE_250I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_3, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_2, 
                CE=>parser_inst_packet_length_regce_8, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_11, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_10);
    parser_inst_SLICE_251I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_5, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_4, 
                CE=>parser_inst_packet_length_regce_8, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_13, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_12);
    parser_inst_SLICE_252I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_t2mi_data_sync_7, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_t2mi_data_sync_6, 
                CE=>parser_inst_packet_length_regce_8, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>parser_inst_packet_length_reg_15, OFX0=>open, F0=>open, 
                Q0=>parser_inst_packet_length_reg_14);
    parser_inst_SLICE_253I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", REG0_REGSET=>"SET", 
                   SRMODE=>"ASYNC", LUT0_INITVAL=>X"0105", 
                   LUT1_INITVAL=>X"AEAE", REG1_SD=>"VHI", REG0_SD=>"VHI", 
                   CHECK_DI1=>TRUE, CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_next_state_0_sqmuxa, 
                B1=>parser_inst_parser_state_1, 
                C1=>parser_inst_t2mi_valid_sync, D1=>'X', 
                DI1=>parser_inst_parser_state_ns_1, DI0=>parser_inst_N_91_i, 
                A0=>parser_inst_N_91_i_mb_mb_1_0, B0=>parser_inst_byte_counter, 
                C0=>parser_inst_parser_state_ns_i_0_1_0, 
                D0=>parser_inst_un1_byte_counter_cry_16, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_parser_state_ns_1, 
                Q1=>parser_inst_parser_state_1, OFX0=>open, 
                F0=>parser_inst_N_91_i, Q0=>parser_inst_parser_state_0);
    parser_inst_SLICE_254I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>parser_inst_parser_state_2, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>parser_inst_parser_state_1, 
                CE=>parser_inst_t2mi_valid_sync, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>parser_inst_parser_state_3, 
                OFX0=>open, F0=>open, Q0=>parser_inst_parser_state_2);
    parser_inst_SLICE_255I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"EAC0", LUT1_INITVAL=>X"1000", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_packet_length_reg_7, 
                B1=>parser_inst_packet_length_reg_10, 
                C1=>parser_inst_parser_state_ns_0_a2_12_3_5, 
                D1=>parser_inst_parser_state_ns_0_a2_12_4_5, DI1=>'X', 
                DI0=>parser_inst_parser_state_ns_5, A0=>parser_inst_N_101_12, 
                B0=>parser_inst_parser_state_ns_i_o3_0, 
                C0=>parser_inst_parser_state_5, 
                D0=>parser_inst_parser_state_ns_0_a2_1_5, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_N_101_12, Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_ns_5, 
                Q0=>parser_inst_parser_state_5);
    parser_inst_SLICE_256I: SLOGICB
      generic map (M0MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"0101", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_sync_counter_2, 
                B1=>parser_inst_sync_counter_3, 
                C1=>parser_inst_sync_counter13_c2, D1=>'X', DI1=>'X', 
                DI0=>parser_inst_N_96, A0=>parser_inst_sync_counter_0, 
                B0=>parser_inst_sync_counter_1, C0=>parser_inst_sync_counter_2, 
                D0=>parser_inst_sync_counter_3, 
                M0=>parser_inst_un1_sync_counter14_i_0_o3_0, CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>parser_inst_N_96, F0=>open, 
                Q0=>parser_inst_sync_counter_pipe);
    parser_inst_SLICE_257I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", REG0_REGSET=>"SET", 
                   SRMODE=>"ASYNC", LUT0_INITVAL=>X"9999", 
                   LUT1_INITVAL=>X"4BB4", REG1_SD=>"VHI", REG0_SD=>"VHI", 
                   CHECK_DI1=>TRUE, CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_sync_counter_pipe, 
                B1=>parser_inst_sync_counterf_0, 
                C1=>parser_inst_sync_counterf_1, 
                D1=>parser_inst_un1_sync_counter14_2f_1, 
                DI1=>parser_inst_sync_counter_1, 
                DI0=>parser_inst_sync_counter_0, 
                A0=>parser_inst_sync_counter_pipe, 
                B0=>parser_inst_sync_counterf_0, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_sync_counter_1, 
                Q1=>parser_inst_sync_counterf_1, OFX0=>open, 
                F0=>parser_inst_sync_counter_0, 
                Q0=>parser_inst_sync_counterf_0);
    parser_inst_SLICE_258I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"9696", LUT1_INITVAL=>X"F440", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_sync_counter_pipe, 
                B1=>parser_inst_sync_counterf_0, 
                C1=>parser_inst_sync_counterf_1, 
                D1=>parser_inst_un1_sync_counter14_2f_1, DI1=>'X', 
                DI0=>parser_inst_sync_counter_2, 
                A0=>parser_inst_sync_counterf_2, 
                B0=>parser_inst_un1_sync_counter14_2f_1, 
                C0=>parser_inst_un1_sync_counter_c2, D0=>'X', M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_un1_sync_counter_c2, Q1=>open, OFX0=>open, 
                F0=>parser_inst_sync_counter_2, 
                Q0=>parser_inst_sync_counterf_2);
    parser_inst_SLICE_259I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"1000", LUT1_INITVAL=>X"EFEF", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_t2mi_data_sync_3, 
                B1=>parser_inst_t2mi_data_sync_5, 
                C1=>parser_inst_t2mi_valid_sync, D1=>'X', DI1=>'X', 
                DI0=>parser_inst_N_77_i, 
                A0=>parser_inst_un1_sync_counter14_i_0_o3_5_0, 
                B0=>parser_inst_un1_sync_counter14_i_0_o3_4_0, 
                C0=>parser_inst_t2mi_data_sync_6, 
                D0=>parser_inst_t2mi_data_sync_1, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_un1_sync_counter14_i_0_o3_4_0, Q1=>open, 
                OFX0=>open, F0=>parser_inst_N_77_i, Q0=>parser_inst_sync_found);
    parser_inst_SLICE_260I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", REG0_REGSET=>"SET", 
                   SRMODE=>"ASYNC", LUT0_INITVAL=>X"AAA8", 
                   LUT1_INITVAL=>X"DBBD", REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_sync_counter_pipe, 
                B1=>parser_inst_sync_counterf_0, 
                C1=>parser_inst_sync_counterf_1, 
                D1=>parser_inst_un1_sync_counter14_2f_1, DI1=>'X', 
                DI0=>parser_inst_sync_counter_pipe_5_RNO, 
                A0=>parser_inst_un1_sync_counter14_i_0_o3_0, 
                B0=>parser_inst_sync_counter13_c2, 
                C0=>parser_inst_sync_counter_2, D0=>parser_inst_sync_counter_3, 
                M0=>'X', CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>parser_inst_sync_counter13_c2, Q1=>open, OFX0=>open, 
                F0=>parser_inst_sync_counter_pipe_5_RNO, 
                Q0=>parser_inst_un1_sync_counter14_2f_1);
    pps_inst_SLICE_261I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_1, C1=>subseconds_1, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_1, 
                DI0=>pps_inst_current_subseconds_4_0, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_0, C0=>subseconds_0, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_1, 
                Q1=>pps_inst_current_subseconds_1, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_0, 
                Q0=>pps_inst_current_subseconds_0);
    pps_inst_SLICE_262I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_3, C1=>subseconds_3, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_3, 
                DI0=>pps_inst_current_subseconds_4_2, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_2, C0=>subseconds_2, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_3, 
                Q1=>pps_inst_current_subseconds_3, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_2, 
                Q0=>pps_inst_current_subseconds_2);
    pps_inst_SLICE_263I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_5, C1=>subseconds_5, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_5, 
                DI0=>pps_inst_current_subseconds_4_4, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_4, C0=>subseconds_4, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_5, 
                Q1=>pps_inst_current_subseconds_5, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_4, 
                Q0=>pps_inst_current_subseconds_4);
    pps_inst_SLICE_264I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_7, C1=>subseconds_7, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_7, 
                DI0=>pps_inst_current_subseconds_4_6, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_6, C0=>subseconds_6, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_7, 
                Q1=>pps_inst_current_subseconds_7, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_6, 
                Q0=>pps_inst_current_subseconds_6);
    pps_inst_SLICE_265I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_9, C1=>subseconds_9, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_9, 
                DI0=>pps_inst_current_subseconds_4_8, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_8, C0=>subseconds_8, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_9, 
                Q1=>pps_inst_current_subseconds_9, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_8, 
                Q0=>pps_inst_current_subseconds_8);
    pps_inst_SLICE_266I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_11, C1=>subseconds_11, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_11, 
                DI0=>pps_inst_current_subseconds_4_10, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_10, C0=>subseconds_10, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_11, 
                Q1=>pps_inst_current_subseconds_11, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_10, 
                Q0=>pps_inst_current_subseconds_10);
    pps_inst_SLICE_267I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_13, C1=>subseconds_13, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_13, 
                DI0=>pps_inst_current_subseconds_4_12, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_12, C0=>subseconds_12, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_13, 
                Q1=>pps_inst_current_subseconds_13, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_12, 
                Q0=>pps_inst_current_subseconds_12);
    pps_inst_SLICE_268I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_15, C1=>subseconds_15, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_15, 
                DI0=>pps_inst_current_subseconds_4_14, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_14, C0=>subseconds_14, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_15, 
                Q1=>pps_inst_current_subseconds_15, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_14, 
                Q0=>pps_inst_current_subseconds_14);
    pps_inst_SLICE_269I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_17, C1=>subseconds_17, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_17, 
                DI0=>pps_inst_current_subseconds_4_16, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_16, C0=>subseconds_16, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_17, 
                Q1=>pps_inst_current_subseconds_17, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_16, 
                Q0=>pps_inst_current_subseconds_16);
    pps_inst_SLICE_270I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_19, C1=>subseconds_19, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_19, 
                DI0=>pps_inst_current_subseconds_4_18, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_18, C0=>subseconds_18, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_19, 
                Q1=>pps_inst_current_subseconds_19, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_18, 
                Q0=>pps_inst_current_subseconds_18);
    pps_inst_SLICE_271I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_21, C1=>subseconds_21, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_21, 
                DI0=>pps_inst_current_subseconds_4_20, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_20, C0=>subseconds_20, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_21, 
                Q1=>pps_inst_current_subseconds_21, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_20, 
                Q0=>pps_inst_current_subseconds_20);
    pps_inst_SLICE_272I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_23, C1=>subseconds_23, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_23, 
                DI0=>pps_inst_current_subseconds_4_22, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_22, C0=>subseconds_22, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_23, 
                Q1=>pps_inst_current_subseconds_23, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_22, 
                Q0=>pps_inst_current_subseconds_22);
    pps_inst_SLICE_273I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_25, C1=>subseconds_25, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_25, 
                DI0=>pps_inst_current_subseconds_4_24, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_24, C0=>subseconds_24, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_25, 
                Q1=>pps_inst_current_subseconds_25, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_24, 
                Q0=>pps_inst_current_subseconds_24);
    pps_inst_SLICE_274I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_27, C1=>subseconds_27, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_27, 
                DI0=>pps_inst_current_subseconds_4_26, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_26, C0=>subseconds_26, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_27, 
                Q1=>pps_inst_current_subseconds_27, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_26, 
                Q0=>pps_inst_current_subseconds_26);
    pps_inst_SLICE_275I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_29, C1=>subseconds_29, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_29, 
                DI0=>pps_inst_current_subseconds_4_28, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_28, C0=>subseconds_28, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_29, 
                Q1=>pps_inst_current_subseconds_29, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_28, 
                Q0=>pps_inst_current_subseconds_28);
    pps_inst_SLICE_276I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"E4E4", LUT1_INITVAL=>X"E4E4", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_31, C1=>subseconds_31, D1=>'X', 
                DI1=>pps_inst_current_subseconds_4_31, 
                DI0=>pps_inst_current_subseconds_4_30, A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_30, C0=>subseconds_30, D0=>'X', 
                M0=>'X', CE=>pps_inst_time_valid_2, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_current_subseconds_4_31, 
                Q1=>pps_inst_current_subseconds_31, OFX0=>open, 
                F0=>pps_inst_current_subseconds_4_30, 
                Q0=>pps_inst_current_subseconds_30);
    pps_inst_SLICE_278I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", REG0_REGSET=>"SET", 
                   SRMODE=>"ASYNC", LUT0_INITVAL=>X"A0EC", 
                   LUT1_INITVAL=>X"EAEA", REG1_SD=>"VHI", REG0_SD=>"VHI", 
                   CHECK_DI1=>TRUE, CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_N_344, 
                B1=>pps_inst_pps_state_0, C1=>pps_inst_time_valid, D1=>'X', 
                DI1=>pps_inst_pps_state_ns_1, DI0=>pps_inst_pps_state_ns_0, 
                A0=>debug_status_c_3, B0=>pps_inst_pps_state_0, 
                C0=>pps_inst_pps_state_4, D0=>pps_inst_time_valid, M0=>'X', 
                CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_1, Q1=>pps_inst_pps_state_1, 
                OFX0=>open, F0=>pps_inst_pps_state_ns_0, 
                Q0=>pps_inst_pps_state_0);
    pps_inst_SLICE_279I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"ECEC", LUT1_INITVAL=>X"5540", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_N_346, 
                B1=>pps_inst_pps_armed, C1=>pps_inst_pps_state_2, 
                D1=>pps_inst_pps_state_3, DI1=>pps_inst_N_280_i, 
                DI0=>pps_inst_pps_state_ns_2, A0=>pps_inst_N_299, 
                B0=>pps_inst_N_346, C0=>pps_inst_pps_state_ns_0_a2_0_1, 
                D0=>'X', M0=>'X', CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_N_280_i, Q1=>pps_inst_pps_state_3, 
                OFX0=>open, F0=>pps_inst_pps_state_ns_2, 
                Q0=>pps_inst_pps_state_2);
    pps_inst_SLICE_280I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"F070", LUT1_INITVAL=>X"FDFC", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_N_370, C1=>pps_inst_pps_state_1, 
                D1=>pps_inst_pps_state_4, DI1=>'X', DI0=>pps_inst_N_282_i, 
                A0=>pps_inst_N_288, B0=>pps_inst_pps_state_ns_0_a2_0_1, 
                C0=>pps_inst_N_379, D0=>pps_inst_pps_state_4, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>pps_inst_N_379, 
                Q1=>open, OFX0=>open, F0=>pps_inst_N_282_i, 
                Q0=>pps_inst_pps_state_4);
    pps_inst_SLICE_281I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"BE14", REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>pps_inst_subsec_counter_6_0, 
                A0=>debug_status_c_3, B0=>pps_inst_subsec_counter_0, 
                C0=>pps_inst_time_valid, D0=>subseconds_0, M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>open, F0=>pps_inst_subsec_counter_6_0, 
                Q0=>pps_inst_subsec_counter_0);
    pps_inst_SLICE_282I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"DEDE", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_1_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_1, 
                DI1=>pps_inst_sync_error_5_1, DI0=>pps_inst_sync_error_5_0, 
                A0=>pps_inst_current_subseconds_0, B0=>pps_inst_sync_error18_i, 
                C0=>subseconds_0, D0=>'X', M0=>'X', CE=>pps_inst_sync_error22, 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>pps_inst_sync_error_5_1, Q1=>pps_inst_sync_error_1, 
                OFX0=>open, F0=>pps_inst_sync_error_5_0, 
                Q0=>pps_inst_sync_error_0);
    pps_inst_SLICE_283I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_3_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_3, 
                DI1=>pps_inst_sync_error_5_3, DI0=>pps_inst_sync_error_5_2, 
                A0=>pps_inst_sync_error_5_0_0_cry_1_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_2, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_3, 
                Q1=>pps_inst_sync_error_3, OFX0=>open, 
                F0=>pps_inst_sync_error_5_2, Q0=>pps_inst_sync_error_2);
    pps_inst_SLICE_284I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_5_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_5, 
                DI1=>pps_inst_sync_error_5_5, DI0=>pps_inst_sync_error_5_4, 
                A0=>pps_inst_sync_error_5_0_0_cry_3_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_4, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_5, 
                Q1=>pps_inst_sync_error_5, OFX0=>open, 
                F0=>pps_inst_sync_error_5_4, Q0=>pps_inst_sync_error_4);
    pps_inst_SLICE_285I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_7_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_7, 
                DI1=>pps_inst_sync_error_5_7, DI0=>pps_inst_sync_error_5_6, 
                A0=>pps_inst_sync_error_5_0_0_cry_5_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_6, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_7, 
                Q1=>pps_inst_sync_error_7, OFX0=>open, 
                F0=>pps_inst_sync_error_5_6, Q0=>pps_inst_sync_error_6);
    pps_inst_SLICE_286I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_9_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_9, 
                DI1=>pps_inst_sync_error_5_9, DI0=>pps_inst_sync_error_5_8, 
                A0=>pps_inst_sync_error_5_0_0_cry_7_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_8, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_9, 
                Q1=>pps_inst_sync_error_9, OFX0=>open, 
                F0=>pps_inst_sync_error_5_8, Q0=>pps_inst_sync_error_8);
    pps_inst_SLICE_287I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_11_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_11, 
                DI1=>pps_inst_sync_error_5_11, DI0=>pps_inst_sync_error_5_10, 
                A0=>pps_inst_sync_error_5_0_0_cry_9_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_10, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_11, 
                Q1=>pps_inst_sync_error_11, OFX0=>open, 
                F0=>pps_inst_sync_error_5_10, Q0=>pps_inst_sync_error_10);
    pps_inst_SLICE_288I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_13_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_13, 
                DI1=>pps_inst_sync_error_5_13, DI0=>pps_inst_sync_error_5_12, 
                A0=>pps_inst_sync_error_5_0_0_cry_11_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_12, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_13, 
                Q1=>pps_inst_sync_error_13, OFX0=>open, 
                F0=>pps_inst_sync_error_5_12, Q0=>pps_inst_sync_error_12);
    pps_inst_SLICE_289I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_15_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_15, 
                DI1=>pps_inst_sync_error_5_15, DI0=>pps_inst_sync_error_5_14, 
                A0=>pps_inst_sync_error_5_0_0_cry_13_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_14, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_15, 
                Q1=>pps_inst_sync_error_15, OFX0=>open, 
                F0=>pps_inst_sync_error_5_14, Q0=>pps_inst_sync_error_14);
    pps_inst_SLICE_290I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_17_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_17, 
                DI1=>pps_inst_sync_error_5_17, DI0=>pps_inst_sync_error_5_16, 
                A0=>pps_inst_sync_error_5_0_0_cry_15_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_16, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_17, 
                Q1=>pps_inst_sync_error_17, OFX0=>open, 
                F0=>pps_inst_sync_error_5_16, Q0=>pps_inst_sync_error_16);
    pps_inst_SLICE_291I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_19_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_19, 
                DI1=>pps_inst_sync_error_5_19, DI0=>pps_inst_sync_error_5_18, 
                A0=>pps_inst_sync_error_5_0_0_cry_17_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_18, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_19, 
                Q1=>pps_inst_sync_error_19, OFX0=>open, 
                F0=>pps_inst_sync_error_5_18, Q0=>pps_inst_sync_error_18);
    pps_inst_SLICE_292I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_21_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_21, 
                DI1=>pps_inst_sync_error_5_21, DI0=>pps_inst_sync_error_5_20, 
                A0=>pps_inst_sync_error_5_0_0_cry_19_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_20, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_21, 
                Q1=>pps_inst_sync_error_21, OFX0=>open, 
                F0=>pps_inst_sync_error_5_20, Q0=>pps_inst_sync_error_20);
    pps_inst_SLICE_293I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_23_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_23, 
                DI1=>pps_inst_sync_error_5_23, DI0=>pps_inst_sync_error_5_22, 
                A0=>pps_inst_sync_error_5_0_0_cry_21_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_22, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_23, 
                Q1=>pps_inst_sync_error_23, OFX0=>open, 
                F0=>pps_inst_sync_error_5_22, Q0=>pps_inst_sync_error_22);
    pps_inst_SLICE_294I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_25_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_25, 
                DI1=>pps_inst_sync_error_5_25, DI0=>pps_inst_sync_error_5_24, 
                A0=>pps_inst_sync_error_5_0_0_cry_23_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_24, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_25, 
                Q1=>pps_inst_sync_error_25, OFX0=>open, 
                F0=>pps_inst_sync_error_5_24, Q0=>pps_inst_sync_error_24);
    pps_inst_SLICE_295I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_27_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_27, 
                DI1=>pps_inst_sync_error_5_27, DI0=>pps_inst_sync_error_5_26, 
                A0=>pps_inst_sync_error_5_0_0_cry_25_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_26, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_27, 
                Q1=>pps_inst_sync_error_27, OFX0=>open, 
                F0=>pps_inst_sync_error_5_26, Q0=>pps_inst_sync_error_26);
    pps_inst_SLICE_296I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_cry_29_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_29, 
                DI1=>pps_inst_sync_error_5_29, DI0=>pps_inst_sync_error_5_28, 
                A0=>pps_inst_sync_error_5_0_0_cry_27_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_28, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_29, 
                Q1=>pps_inst_sync_error_29, OFX0=>open, 
                F0=>pps_inst_sync_error_5_28, Q0=>pps_inst_sync_error_28);
    pps_inst_SLICE_297I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FBF8", LUT1_INITVAL=>X"FBF8", 
                   REG1_SD=>"VHI", REG0_SD=>"VHI", CHECK_DI1=>TRUE, 
                   CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_sync_error_5_0_0_s_31_0_S0, 
                B1=>pps_inst_sync_error12, C1=>pps_inst_sync_error18_i, 
                D1=>pps_inst_un1_current_subseconds_10_31, 
                DI1=>pps_inst_sync_error_5_31, DI0=>pps_inst_sync_error_5_30, 
                A0=>pps_inst_sync_error_5_0_0_cry_29_0_S1, 
                B0=>pps_inst_sync_error12, C0=>pps_inst_sync_error18_i, 
                D0=>pps_inst_un1_current_subseconds_10_30, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_sync_error_5_31, 
                Q1=>pps_inst_sync_error_31, OFX0=>open, 
                F0=>pps_inst_sync_error_5_30, Q0=>pps_inst_sync_error_30);
    pps_inst_SLICE_298I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_N_378_3, 
                B1=>pps_inst_drift_accumulator8lto31_10, 
                C1=>pps_inst_drift_accumulator8lto31_11, 
                D1=>pps_inst_drift_accumulator8lto31_12, DI1=>'X', 
                DI0=>pps_inst_drift_accumulator8, A0=>pps_inst_N_295, 
                B0=>pps_inst_drift_accumulator8lto31_13, 
                C0=>pps_inst_drift_accumulator8lto31_14, 
                D0=>pps_inst_drift_accumulator8lto31_18, M0=>'X', 
                CE=>pps_inst_sync_error22, CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>pps_inst_drift_accumulator8lto31_18, Q1=>open, 
                OFX0=>open, F0=>pps_inst_drift_accumulator8, 
                Q0=>pps_inst_sync_valid);
    pps_inst_SLICE_299I: SLOGICB
      generic map (CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"EEEE", LUT1_INITVAL=>X"7FFF", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_16, 
                B1=>pps_inst_subsec_counter_17, C1=>pps_inst_subsec_counter_18, 
                D1=>pps_inst_subsec_counter_19, DI1=>'X', 
                DI0=>pps_inst_N_5789_0, A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>'X', D0=>'X', M0=>'X', CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_RNIAM37H_16, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_5789_0, Q0=>pps_inst_time_valid);
    reset_sync_inst_SLICE_300I: SLOGICB
      generic map (M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", LSRMUX=>"INV", 
                   GSR=>"DISABLED", SRMODE=>"ASYNC", LUT0_INITVAL=>X"FFFF", 
                   REG0_SD=>"VHI", CHECK_DI0=>TRUE, CHECK_M1=>TRUE, 
                   CHECK_LSR=>TRUE)
      port map (M1=>reset_sync_inst_reset_sync_reg_0, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>reset_sync_inst_VCC, A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>'X', CE=>'X', CLK=>clk_100mhz_c, LSR=>rst_n_c, OFX1=>open, 
                F1=>open, Q1=>reset_sync_inst_reset_sync_reg_1, OFX0=>open, 
                F0=>reset_sync_inst_VCC, Q0=>reset_sync_inst_reset_sync_reg_0);
    reset_sync_inst_SLICE_301I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", 
                   LSRMUX=>"INV", GSR=>"DISABLED", SRMODE=>"ASYNC", 
                   CHECK_M1=>TRUE, CHECK_M0=>TRUE, CHECK_LSR=>TRUE)
      port map (M1=>reset_sync_inst_reset_sync_reg_2, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>reset_sync_inst_reset_sync_reg_1, CE=>'X', 
                CLK=>clk_100mhz_c, LSR=>rst_n_c, OFX1=>open, F1=>open, 
                Q1=>led_power_c, OFX0=>open, F0=>open, 
                Q0=>reset_sync_inst_reset_sync_reg_2);
    extractor_inst_SLICE_302I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_1, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_0, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_1, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_0);
    extractor_inst_SLICE_303I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_3, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_2, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_3, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_2);
    extractor_inst_SLICE_304I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_5, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_4, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_5, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_4);
    extractor_inst_SLICE_305I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_7, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_6, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_7, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_6);
    extractor_inst_SLICE_306I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_9, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_8, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_9, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_8);
    extractor_inst_SLICE_307I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_11, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_10, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_11, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_10);
    extractor_inst_SLICE_308I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_13, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_12, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_13, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_12);
    extractor_inst_SLICE_309I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_15, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_14, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_15, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_14);
    extractor_inst_SLICE_310I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_17, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_16, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_17, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_16);
    extractor_inst_SLICE_311I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_19, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_18, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_19, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_18);
    extractor_inst_SLICE_312I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_21, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_20, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_21, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_20);
    extractor_inst_SLICE_313I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_23, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_22, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_23, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_22);
    extractor_inst_SLICE_314I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_25, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_24, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_25, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_24);
    extractor_inst_SLICE_315I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_27, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_26, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_27, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_26);
    extractor_inst_SLICE_316I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_29, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_28, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_29, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_28);
    extractor_inst_SLICE_317I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_31, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_30, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_31, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_30);
    extractor_inst_SLICE_318I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_33, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_32, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_33, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_32);
    extractor_inst_SLICE_319I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_35, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_34, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_35, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_34);
    extractor_inst_SLICE_320I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_37, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_36, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_37, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_36);
    extractor_inst_SLICE_321I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_seconds_field_39, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_seconds_field_38, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>seconds_since_2000_39, 
                OFX0=>open, F0=>open, Q0=>seconds_since_2000_38);
    extractor_inst_SLICE_322I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_1, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>extractor_inst_subsec_field_0, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_1, OFX0=>open, 
                F0=>open, Q0=>subseconds_0);
    extractor_inst_SLICE_323I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_3, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>extractor_inst_subsec_field_2, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_3, OFX0=>open, 
                F0=>open, Q0=>subseconds_2);
    extractor_inst_SLICE_324I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_5, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>extractor_inst_subsec_field_4, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_5, OFX0=>open, 
                F0=>open, Q0=>subseconds_4);
    extractor_inst_SLICE_325I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_7, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>extractor_inst_subsec_field_6, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_7, OFX0=>open, 
                F0=>open, Q0=>subseconds_6);
    extractor_inst_SLICE_326I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_9, FXA=>'X', FXB=>'X', A1=>'X', 
                B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', A0=>'X', 
                B0=>'X', C0=>'X', D0=>'X', M0=>extractor_inst_subsec_field_8, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_9, OFX0=>open, 
                F0=>open, Q0=>subseconds_8);
    extractor_inst_SLICE_327I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_11, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_10, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_11, OFX0=>open, 
                F0=>open, Q0=>subseconds_10);
    extractor_inst_SLICE_328I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_13, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_12, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_13, OFX0=>open, 
                F0=>open, Q0=>subseconds_12);
    extractor_inst_SLICE_329I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_15, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_14, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_15, OFX0=>open, 
                F0=>open, Q0=>subseconds_14);
    extractor_inst_SLICE_330I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_17, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_16, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_17, OFX0=>open, 
                F0=>open, Q0=>subseconds_16);
    extractor_inst_SLICE_331I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_19, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_18, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_19, OFX0=>open, 
                F0=>open, Q0=>subseconds_18);
    extractor_inst_SLICE_332I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_21, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_20, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_21, OFX0=>open, 
                F0=>open, Q0=>subseconds_20);
    extractor_inst_SLICE_333I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_23, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_22, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_23, OFX0=>open, 
                F0=>open, Q0=>subseconds_22);
    extractor_inst_SLICE_334I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_25, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_24, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_25, OFX0=>open, 
                F0=>open, Q0=>subseconds_24);
    extractor_inst_SLICE_335I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_27, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_26, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_27, OFX0=>open, 
                F0=>open, Q0=>subseconds_26);
    extractor_inst_SLICE_336I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_29, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_28, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_29, OFX0=>open, 
                F0=>open, Q0=>subseconds_28);
    extractor_inst_SLICE_337I: SLOGICB
      generic map (M0MUX=>"SIG", M1MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", 
                   SRMODE=>"ASYNC", CHECK_M1=>TRUE, CHECK_M0=>TRUE, 
                   CHECK_CE=>TRUE)
      port map (M1=>extractor_inst_subsec_field_31, FXA=>'X', FXB=>'X', 
                A1=>'X', B1=>'X', C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>'X', B0=>'X', C0=>'X', D0=>'X', 
                M0=>extractor_inst_subsec_field_30, 
                CE=>extractor_inst_extract_state_4, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>subseconds_31, OFX0=>open, 
                F0=>open, Q0=>subseconds_30);
    pps_inst_SLICE_338I: SLOGICB
      generic map (LUT0_INITVAL=>X"04AE", LUT1_INITVAL=>X"DFDF")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_N_295, 
                B1=>pps_inst_sync_error_13, C1=>pps_inst_sync_valid, D1=>'X', 
                DI1=>'X', DI0=>'X', A0=>pps_inst_pps_state_ns_i_o2_3_4, 
                B0=>pps_inst_pps_state_ns_0_o2_1_1, C0=>pps_inst_sync_error_10, 
                D0=>pps_inst_sync_error_13, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_state_ns_0_o2_1_1, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_o2_0_1, 
                Q0=>open);
    pps_inst_SLICE_339I: SLOGICB
      generic map (LUT0_INITVAL=>X"1B1B", LUT1_INITVAL=>X"0B0F")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29, 
                C1=>pps_inst_subsec_counter_6_1_3, D1=>pps_inst_un1_m3_0_a3_2, 
                DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>subseconds_3, D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_6_cry_3_0_RNO, Q1=>open, 
                OFX0=>open, F0=>pps_inst_subsec_counter_6_1_3, Q0=>open);
    pps_inst_SLICE_340I: SLOGICB
      generic map (LUT0_INITVAL=>X"1B1B", LUT1_INITVAL=>X"0B0F")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29, 
                C1=>pps_inst_subsec_counter_6_1_5, D1=>pps_inst_un1_m3_0_a3_2, 
                DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>subseconds_5, D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_6_cry_5_0_RNO, Q1=>open, 
                OFX0=>open, F0=>pps_inst_subsec_counter_6_1_5, Q0=>open);
    pps_inst_SLICE_341I: SLOGICB
      generic map (LUT0_INITVAL=>X"1B1B", LUT1_INITVAL=>X"0B0F")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29, 
                C1=>pps_inst_subsec_counter_6_1_10, D1=>pps_inst_un1_m3_0_a3_2, 
                DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>subseconds_10, D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_6_cry_9_0_RNO_0, Q1=>open, 
                OFX0=>open, F0=>pps_inst_subsec_counter_6_1_10, Q0=>open);
    extractor_inst_SLICE_342I: SLOGICB
      generic map (LUT0_INITVAL=>X"FCFE", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_byte_index_n1_i_a2, 
                B1=>extractor_inst_packet_active, 
                C1=>extractor_inst_un28_timestamp_buffer, D1=>packet_end, 
                DI1=>'X', DI0=>'X', A0=>extractor_inst_un1_packet_active8_i_o2, 
                B0=>extractor_inst_un1_packet_active8_i_a4_0, 
                C0=>extractor_inst_packet_active6, D0=>packet_end, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_un1_packet_active8_i_a4_0, Q1=>open, 
                OFX0=>open, F0=>extractor_inst_un1_packet_active8_i_0, 
                Q0=>open);
    pps_inst_SLICE_343I: SLOGICB
      generic map (M0MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"SIG", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"B3A0", LUT1_INITVAL=>X"4444", 
                   CHECK_M0=>TRUE, CHECK_CE=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_armed, 
                B1=>pps_inst_pps_state_2, C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_N_288, B0=>pps_inst_pps_state_ns_0_o2_1_1, 
                C0=>pps_inst_N_370, D0=>pps_inst_pps_state_ns_0_a2_2_2, 
                M0=>pps_inst_pps_state_2, 
                CE=>pps_inst_un1_next_pps_time_1_sqmuxa_i, CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>pps_inst_N_370, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_299, Q0=>pps_inst_pps_armed);
    pps_inst_SLICE_344I: SLOGICB
      generic map (LUT0_INITVAL=>X"C080", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_pps_state_ns_0_a2_0_9_1, 
                B1=>pps_inst_pps_state_ns_0_a2_0_10_1, 
                C1=>pps_inst_pps_state_ns_0_a2_0_11_1, 
                D1=>pps_inst_pps_state_ns_0_a2_0_12_1, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_N_357, B0=>pps_inst_pps_state_ns_0_a2_0_1, 
                C0=>pps_inst_pps_state_1, D0=>pps_inst_pps_state_ns_0_o2_0_1, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_a2_0_1, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_344, Q0=>open);
    pps_inst_SLICE_345I: SLOGICB
      generic map (LUT0_INITVAL=>X"23FF", LUT1_INITVAL=>X"EEEE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_11, 
                B1=>pps_inst_sync_error_12, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>pps_inst_pps_state_ns_i_o2_2_4, 
                B0=>pps_inst_pps_state_ns_i_o2_3_4, C0=>pps_inst_sync_error_10, 
                D0=>pps_inst_sync_error_13, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_state_ns_i_o2_3_4, 
                Q1=>open, OFX0=>open, F0=>pps_inst_N_288, Q0=>open);
    pps_inst_SLICE_346I: SLOGICB
      generic map (LUT0_INITVAL=>X"20F0", LUT1_INITVAL=>X"ECFC")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_pps_state_ns_i_a2_4_4, 
                B1=>pps_inst_drift_accumulator8lt31_3, 
                C1=>pps_inst_pps_state_ns_i_a2_3_1_4, 
                D1=>pps_inst_sync_error_4, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_state_ns_i_o2_2_4, 
                B0=>pps_inst_pps_state_ns_i_o2_3_4, C0=>pps_inst_sync_error_10, 
                D0=>pps_inst_sync_error_13, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_state_ns_i_o2_2_4, 
                Q1=>open, OFX0=>open, F0=>pps_inst_N_357, Q0=>open);
    pps_inst_SLICE_347I: SLOGICB
      generic map (LUT0_INITVAL=>X"AE04", LUT1_INITVAL=>X"0800")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_9, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_11, 
                C1=>pps_inst_un1_m3_0_a3_1, D1=>pps_inst_un1_m3_0_a3_2, 
                DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>pps_inst_un1_N_4_0, 
                D0=>subseconds_11, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_un1_N_4_0, Q1=>open, OFX0=>open, 
                F0=>pps_inst_subsec_counter_6_cry_11_0_RNO, Q0=>open);
    pps_inst_SLICE_348I: SLOGICB
      generic map (LUT0_INITVAL=>X"EAEA", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_8, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_9, 
                C1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_10, 
                D1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_11, DI1=>'X', 
                DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_current_seconds_0_sqmuxa_1_a2_3, 
                C0=>pps_inst_current_seconds_0_sqmuxa_1_a2_29, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29, Q1=>open, 
                OFX0=>open, F0=>pps_inst_current_secondse, Q0=>open);
    pps_inst_SLICE_349I: SLOGICB
      generic map (LUT0_INITVAL=>X"CCC8", LUT1_INITVAL=>X"FFFE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_21, 
                B1=>pps_inst_pps_pulse_counter_22, 
                C1=>pps_inst_pps_state_ns_0_o2_0_9_2, 
                D1=>pps_inst_pps_state_ns_0_o2_0_14_2, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_N_360, B0=>pps_inst_pps_state_3, 
                C0=>pps_inst_pps_state_ns_0_o2_0_18_2, 
                D0=>pps_inst_pps_state_ns_0_o2_0_19_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_o2_0_18_2, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_346, Q0=>open);
    pps_inst_SLICE_350I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_28, 
                B1=>pps_inst_subsec_counter_29, C1=>pps_inst_subsec_counter_30, 
                D1=>pps_inst_subsec_counter_31, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_seconds_0_sqmuxa_1_a2_1, 
                B0=>pps_inst_current_seconds_0_sqmuxa_1_a2_23, 
                C0=>pps_inst_current_seconds_0_sqmuxa_1_a2_27_4, 
                D0=>pps_inst_current_seconds_0_sqmuxa_1_a2_27_5, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_current_seconds_0_sqmuxa_1_a2_27_5, Q1=>open, 
                OFX0=>open, F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_3, 
                Q0=>open);
    pps_inst_SLICE_351I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFFE", LUT1_INITVAL=>X"FFFE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_13, 
                B1=>pps_inst_pps_pulse_counter_14, 
                C1=>pps_inst_pps_pulse_counter_15, 
                D1=>pps_inst_pps_pulse_counter_16, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_pulse_counter_17, 
                B0=>pps_inst_pps_pulse_counter_18, 
                C0=>pps_inst_pps_state_ns_0_o2_0_11_2, 
                D0=>pps_inst_pps_state_ns_0_o2_0_17_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_o2_0_11_2, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_state_ns_0_o2_0_19_2, Q0=>open);
    pps_inst_SLICE_352I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_12, 
                B1=>pps_inst_pps_pulse_counter_13, 
                C1=>pps_inst_pps_pulse_counter_14, 
                D1=>pps_inst_pps_pulse_counter_15, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_armed_1_sqmuxa_11, 
                B0=>pps_inst_pps_armed_1_sqmuxa_12, 
                C0=>pps_inst_pps_armed_1_sqmuxa_13, 
                D0=>pps_inst_pps_armed_1_sqmuxa_14, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_armed_1_sqmuxa_14, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_armed_1_sqmuxa_20, 
                Q0=>open);
    pps_inst_SLICE_353I: SLOGICB
      generic map (LUT0_INITVAL=>X"EFFF", LUT1_INITVAL=>X"7777")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_8, 
                B1=>pps_inst_sync_error_9, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>pps_inst_drift_accumulator8lt31_3, 
                B0=>pps_inst_pps_state_ns_0_o2_3_1_1, 
                C0=>pps_inst_sync_error_5, D0=>pps_inst_sync_error_6, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_drift_accumulator8lt31_3, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_295, Q0=>open);
    pps_inst_SLICE_354I: SLOGICB
      generic map (LUT0_INITVAL=>X"E000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_5, 
                B1=>pps_inst_pps_pulse_counter_6, 
                C1=>pps_inst_pps_pulse_counter_8, 
                D1=>pps_inst_pps_pulse_counter_9, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_pulse_counter_3, 
                B0=>pps_inst_pps_pulse_counter_4, 
                C0=>pps_inst_pps_pulse_counter_7, 
                D0=>pps_inst_pps_state_ns_0_a2_1_3_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_a2_1_3_2, Q1=>open, OFX0=>open, 
                F0=>pps_inst_N_360, Q0=>open);
    pps_inst_SLICE_355I: SLOGICB
      generic map (LUT0_INITVAL=>X"8080", LUT1_INITVAL=>X"8080")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_16, 
                B1=>pps_inst_subsec_counter_17, C1=>pps_inst_time_valid, 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_current_seconds_0_sqmuxa_1_a2_0_0, 
                B0=>pps_inst_subsec_counter_18, C0=>pps_inst_subsec_counter_19, 
                D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_current_seconds_0_sqmuxa_1_a2_0_0, Q1=>open, 
                OFX0=>open, F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_1, 
                Q0=>open);
    pps_inst_SLICE_356I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFFE", LUT1_INITVAL=>X"EEEE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_10, 
                B1=>pps_inst_pps_pulse_counter_31, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>pps_inst_pps_pulse_counter_11, 
                B0=>pps_inst_pps_pulse_counter_12, 
                C0=>pps_inst_pps_state_ns_0_o2_0_3_2, 
                D0=>pps_inst_pps_state_ns_0_o2_0_13_2, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_o2_0_3_2, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_state_ns_0_o2_0_17_2, Q0=>open);
    pps_inst_SLICE_357I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"7777")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_8, 
                B1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_10, C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_subsec_counter_3, 
                B0=>pps_inst_subsec_counter_5, C0=>pps_inst_subsec_counter_10, 
                D0=>pps_inst_subsec_counter_11, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_un1_m3_0_a3_1, Q1=>open, 
                OFX0=>open, F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_8, 
                Q0=>open);
    pps_inst_SLICE_358I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0202")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>pps_inst_pps_state_ns_0_a2_0_8_1, 
                B1=>pps_inst_sync_error_28, C1=>pps_inst_sync_error_27, 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_sync_error_20, 
                B0=>pps_inst_sync_error_21, C0=>pps_inst_sync_error_30, 
                D0=>pps_inst_sync_error_31, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_state_ns_0_a2_0_12_1, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_a2_0_8_1, 
                Q0=>open);
    pps_inst_SLICE_359I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"7FFF")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_28, 
                B1=>pps_inst_subsec_counter_29, C1=>pps_inst_subsec_counter_30, 
                D1=>pps_inst_subsec_counter_31, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_subsec_counter_RNI4M97H_28, 
                B0=>pps_inst_subsec_counter_RNI6M77H_24, 
                C0=>pps_inst_subsec_counter_RNIM577H_20, 
                D0=>pps_inst_subsec_counter_RNIAM37H_16, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_RNI4M97H_28, Q1=>open, OFX0=>open, 
                F0=>pps_inst_un1_m3_0_a3_2, Q0=>open);
    extractor_inst_SLICE_360I: SLOGICB
      generic map (LUT0_INITVAL=>X"0080", LUT1_INITVAL=>X"1000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>packet_end, 
                B1=>extractor_inst_packet_active6, 
                C1=>extractor_inst_packet_active, D1=>debug_status_c_2, 
                DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_n1_i_a2, 
                C0=>extractor_inst_byte_index_2, 
                D0=>extractor_inst_byte_index_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                Q1=>open, OFX0=>open, 
                F0=>extractor_inst_timestamp_buffer_4_0_sqmuxa, Q0=>open);
    extractor_inst_SLICE_361I: SLOGICB
      generic map (LUT0_INITVAL=>X"0800", LUT1_INITVAL=>X"4444")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_0, 
                B1=>extractor_inst_byte_index_1, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_2, 
                C0=>extractor_inst_byte_index_3, 
                D0=>extractor_inst_timestamp_buffer_6_0_sqmuxa_0_a4_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_timestamp_buffer_6_0_sqmuxa_0_a4_0, 
                Q1=>open, OFX0=>open, 
                F0=>extractor_inst_timestamp_buffer_6_0_sqmuxa, Q0=>open);
    extractor_inst_SLICE_362I: SLOGICB
      generic map (LUT0_INITVAL=>X"0800", LUT1_INITVAL=>X"2222")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_0, 
                B1=>extractor_inst_byte_index_1, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_2, 
                C0=>extractor_inst_byte_index_3, 
                D0=>extractor_inst_timestamp_buffer_5_0_sqmuxa_0_a4_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_timestamp_buffer_5_0_sqmuxa_0_a4_0, 
                Q1=>open, OFX0=>open, 
                F0=>extractor_inst_timestamp_buffer_5_0_sqmuxa, Q0=>open);
    extractor_inst_SLICE_363I: SLOGICB
      generic map (LUT0_INITVAL=>X"0040", LUT1_INITVAL=>X"7777")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_0, 
                B1=>extractor_inst_byte_index_1, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>extractor_inst_byte_index_n1_i_o2, 
                B0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                C0=>extractor_inst_byte_index_2, 
                D0=>extractor_inst_byte_index_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>extractor_inst_byte_index_n1_i_o2, 
                Q1=>open, OFX0=>open, 
                F0=>extractor_inst_timestamp_buffer_7_0_sqmuxa, Q0=>open);
    extractor_inst_SLICE_364I: SLOGICB
      generic map (LUT0_INITVAL=>X"0800", LUT1_INITVAL=>X"1111")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_0, 
                B1=>extractor_inst_byte_index_1, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_n1_i_a2, 
                C0=>extractor_inst_byte_index_2, 
                D0=>extractor_inst_byte_index_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>extractor_inst_byte_index_n1_i_a2, 
                Q1=>open, OFX0=>open, 
                F0=>extractor_inst_timestamp_buffer_8_0_sqmuxa, Q0=>open);
    extractor_inst_SLICE_365I: SLOGICB
      generic map (LUT0_INITVAL=>X"CCCD", LUT1_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>extractor_inst_byte_index_2, 
                B1=>extractor_inst_byte_index_3, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>extractor_inst_un1_packet_active8_i_o2, 
                B0=>extractor_inst_packet_active6, 
                C0=>extractor_inst_un28_timestamp_buffer, D0=>packet_end, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_un28_timestamp_buffer, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_byte_indexe, Q0=>open);
    extractor_inst_SLICE_366I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_seconds_field_4, 
                B1=>extractor_inst_seconds_field_5, 
                C1=>extractor_inst_seconds_field_6, 
                D1=>extractor_inst_seconds_field_7, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_extract_state_tr8_21, 
                B0=>extractor_inst_extract_state_tr8_22, 
                C0=>extractor_inst_extract_state_tr8_23, 
                D0=>extractor_inst_extract_state_tr8_24, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_tr8_24, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_36, Q0=>open);
    extractor_inst_SLICE_367I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_seconds_field_20, 
                B1=>extractor_inst_seconds_field_21, 
                C1=>extractor_inst_seconds_field_22, 
                D1=>extractor_inst_seconds_field_23, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_extract_state_tr8_25, 
                B0=>extractor_inst_extract_state_tr8_26, 
                C0=>extractor_inst_extract_state_tr8_27, 
                D0=>extractor_inst_extract_state_tr8_28, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_tr8_28, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_37, Q0=>open);
    extractor_inst_SLICE_368I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_extract_state_2, 
                B1=>extractor_inst_seconds_field_31, C1=>'X', D1=>'X', 
                DI1=>'X', DI0=>'X', A0=>extractor_inst_extract_state_tr8_0, 
                B0=>extractor_inst_seconds_field_28, 
                C0=>extractor_inst_seconds_field_29, 
                D0=>extractor_inst_seconds_field_30, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_tr8_0, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_30, Q0=>open);
    parser_inst_SLICE_369I: SLOGICB
      generic map (LUT0_INITVAL=>X"0501", LUT1_INITVAL=>X"EEEE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_parser_state_2, 
                B1=>parser_inst_parser_state_3, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_parser_state_RNIVVM5_2, 
                B0=>parser_inst_byte_counter, C0=>parser_inst_parser_state_1, 
                D0=>parser_inst_t2mi_valid_sync, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>parser_inst_parser_state_RNIVVM5_2, 
                Q1=>open, OFX0=>open, F0=>parser_inst_N_4_i, Q0=>open);
    parser_inst_SLICE_370I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFF7", LUT1_INITVAL=>X"FFF7")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_t2mi_data_sync_0, 
                B1=>parser_inst_t2mi_data_sync_2, 
                C1=>parser_inst_t2mi_data_sync_4, 
                D1=>parser_inst_t2mi_data_sync_7, DI1=>'X', DI0=>'X', 
                A0=>parser_inst_t2mi_data_sync_1, 
                B0=>parser_inst_t2mi_data_sync_6, 
                C0=>parser_inst_un1_sync_counter14_i_0_o3_4_0, 
                D0=>parser_inst_un1_sync_counter14_i_0_o3_5_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>parser_inst_un1_sync_counter14_i_0_o3_5_0, Q1=>open, 
                OFX0=>open, F0=>parser_inst_un1_sync_counter14_i_0_o3_0, 
                Q0=>open);
    parser_inst_SLICE_371I: SLOGICB
      generic map (LUT0_INITVAL=>X"0004", LUT1_INITVAL=>X"7777")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>parser_inst_parser_state_3, 
                B1=>parser_inst_t2mi_valid_sync, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_parser_state_ns_i_0_o3_4, 
                B0=>parser_inst_N_101_10, C0=>parser_inst_packet_length_reg_13, 
                D0=>parser_inst_packet_length_reg_15, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>parser_inst_parser_state_ns_i_0_o3_4, Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_ns_0_a2_1_5, Q0=>open);
    parser_inst_SLICE_372I: SLOGICB
      generic map (LUT0_INITVAL=>X"FEFC", LUT1_INITVAL=>X"7777")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>led_sync_c, 
                B1=>parser_inst_sync_found, C1=>'X', D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>parser_inst_parser_state_ns_i_o3_0, 
                B0=>parser_inst_parser_state_RNIVVM5_2, 
                C0=>parser_inst_parser_state_1, D0=>parser_inst_parser_state_5, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>parser_inst_parser_state_ns_i_o3_0, Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_ns_i_0_1_0, Q0=>open);
    parser_inst_SLICE_373I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFFE", LUT1_INITVAL=>X"EEEE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_packet_length_reg_13, 
                B1=>parser_inst_packet_length_reg_15, C1=>'X', D1=>'X', 
                DI1=>'X', DI0=>'X', A0=>parser_inst_g2_0_6, 
                B0=>parser_inst_g2_0_7, C0=>parser_inst_g2_0_8, 
                D0=>parser_inst_g2_0_9, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>parser_inst_g2_0_6, Q1=>open, OFX0=>open, 
                F0=>parser_inst_g2_0, Q0=>open);
    pps_inst_SLICE_374I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"7FFF")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_20, 
                B1=>pps_inst_subsec_counter_21, C1=>pps_inst_subsec_counter_22, 
                D1=>pps_inst_subsec_counter_23, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_subsec_counter_20, B0=>pps_inst_subsec_counter_21, 
                C0=>pps_inst_subsec_counter_22, D0=>pps_inst_subsec_counter_23, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_RNIM577H_20, Q1=>open, OFX0=>open, 
                F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_23, Q0=>open);
    pps_inst_SLICE_375I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"7FFF")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_24, 
                B1=>pps_inst_subsec_counter_25, C1=>pps_inst_subsec_counter_26, 
                D1=>pps_inst_subsec_counter_27, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_subsec_counter_24, B0=>pps_inst_subsec_counter_25, 
                C0=>pps_inst_subsec_counter_26, D0=>pps_inst_subsec_counter_27, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_subsec_counter_RNI6M77H_24, Q1=>open, OFX0=>open, 
                F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_27_4, Q0=>open);
    extractor_inst_SLICE_376I: SLOGICB
      generic map (LUT0_INITVAL=>X"0400", LUT1_INITVAL=>X"0004")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_byte_index_n1_i_o2, 
                B1=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                C1=>extractor_inst_byte_index_2, 
                D1=>extractor_inst_byte_index_3, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_byte_index_n1_i_o2, 
                B0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                C0=>extractor_inst_byte_index_2, 
                D0=>extractor_inst_byte_index_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_timestamp_buffer_3_0_sqmuxa, Q1=>open, 
                OFX0=>open, F0=>extractor_inst_timestamp_buffer_11_0_sqmuxa, 
                Q0=>open);
    parser_inst_SLICE_377I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"FFFE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_packet_length_reg_2, 
                B1=>parser_inst_packet_length_reg_3, 
                C1=>parser_inst_packet_length_reg_4, 
                D1=>parser_inst_packet_length_reg_6, DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_2, 
                B0=>parser_inst_packet_length_reg_3, 
                C0=>parser_inst_packet_length_reg_4, 
                D0=>parser_inst_packet_length_reg_6, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>parser_inst_g2_0_7, 
                Q1=>open, OFX0=>open, F0=>parser_inst_N_101_10, Q0=>open);
    parser_inst_SLICE_378I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"FFFE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_packet_length_reg_9, 
                B1=>parser_inst_packet_length_reg_11, 
                C1=>parser_inst_packet_length_reg_12, 
                D1=>parser_inst_packet_length_reg_14, DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_9, 
                B0=>parser_inst_packet_length_reg_11, 
                C0=>parser_inst_packet_length_reg_12, 
                D0=>parser_inst_packet_length_reg_14, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>parser_inst_g2_0_9, 
                Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_ns_0_a2_12_4_5, Q0=>open);
    pps_inst_SLICE_379I: SLOGICB
      generic map (LUT0_INITVAL=>X"AE04", LUT1_INITVAL=>X"AE04")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_time_valid, C1=>pps_inst_un1_N_4_0, 
                D1=>subseconds_25, DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>pps_inst_un1_N_4_0, 
                D0=>subseconds_12, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_subsec_counter_6_cry_25_0_RNO, 
                Q1=>open, OFX0=>open, 
                F0=>pps_inst_subsec_counter_6_cry_11_0_RNO_0, Q0=>open);
    pps_inst_SLICE_380I: SLOGICB
      generic map (LUT0_INITVAL=>X"AE04", LUT1_INITVAL=>X"AE04")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_time_valid, C1=>pps_inst_un1_N_4_0, 
                D1=>subseconds_23, DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>pps_inst_un1_N_4_0, 
                D0=>subseconds_14, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_subsec_counter_6_cry_23_0_RNO, 
                Q1=>open, OFX0=>open, 
                F0=>pps_inst_subsec_counter_6_cry_13_0_RNO_0, Q0=>open);
    pps_inst_SLICE_381I: SLOGICB
      generic map (LUT0_INITVAL=>X"AE04", LUT1_INITVAL=>X"AE04")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_time_valid, C1=>pps_inst_un1_N_4_0, 
                D1=>subseconds_19, DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>pps_inst_un1_N_4_0, 
                D0=>subseconds_16, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_subsec_counter_6_cry_19_0_RNO, 
                Q1=>open, OFX0=>open, 
                F0=>pps_inst_subsec_counter_6_cry_15_0_RNO_0, Q0=>open);
    pps_inst_SLICE_382I: SLOGICB
      generic map (LUT0_INITVAL=>X"AE04", LUT1_INITVAL=>X"AE04")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_time_valid, C1=>pps_inst_un1_N_4_0, 
                D1=>subseconds_18, DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>pps_inst_un1_N_4_0, 
                D0=>subseconds_17, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_subsec_counter_6_cry_17_0_RNO_0, 
                Q1=>open, OFX0=>open, 
                F0=>pps_inst_subsec_counter_6_cry_17_0_RNO, Q0=>open);
    pps_inst_SLICE_383I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFFE", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_26, 
                B1=>pps_inst_pps_pulse_counter_27, 
                C1=>pps_inst_pps_pulse_counter_28, 
                D1=>pps_inst_pps_pulse_counter_29, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_pulse_counter_27, 
                B0=>pps_inst_pps_pulse_counter_28, 
                C0=>pps_inst_pps_pulse_counter_29, 
                D0=>pps_inst_pps_pulse_counter_30, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_armed_1_sqmuxa_12, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_o2_0_13_2, 
                Q0=>open);
    pps_inst_SLICE_384I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFFE", LUT1_INITVAL=>X"0101")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_23, 
                B1=>pps_inst_pps_pulse_counter_24, 
                C1=>pps_inst_pps_pulse_counter_25, D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_pulse_counter_23, 
                B0=>pps_inst_pps_pulse_counter_24, 
                C0=>pps_inst_pps_pulse_counter_25, 
                D0=>pps_inst_pps_pulse_counter_26, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_armed_1_sqmuxa_11, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_o2_0_14_2, 
                Q0=>open);
    extractor_inst_SLICE_385I: SLOGICB
      generic map (LUT0_INITVAL=>X"2000", LUT1_INITVAL=>X"0008")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B1=>extractor_inst_byte_index_n1_i_a2, 
                C1=>extractor_inst_byte_index_2, 
                D1=>extractor_inst_byte_index_3, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_2, 
                C0=>extractor_inst_byte_index_3, 
                D0=>extractor_inst_timestamp_buffer_6_0_sqmuxa_0_a4_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_timestamp_buffer_0_0_sqmuxa, Q1=>open, 
                OFX0=>open, F0=>extractor_inst_timestamp_buffer_10_0_sqmuxa, 
                Q0=>open);
    extractor_inst_SLICE_386I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_seconds_field_12, 
                B1=>extractor_inst_seconds_field_13, 
                C1=>extractor_inst_seconds_field_14, 
                D1=>extractor_inst_seconds_field_15, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_seconds_field_16, 
                B0=>extractor_inst_seconds_field_17, 
                C0=>extractor_inst_seconds_field_18, 
                D0=>extractor_inst_seconds_field_19, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_extract_state_tr8_26, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_27, Q0=>open);
    extractor_inst_SLICE_387I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>extractor_inst_seconds_field_36, 
                B1=>extractor_inst_seconds_field_37, 
                C1=>extractor_inst_seconds_field_38, 
                D1=>extractor_inst_seconds_field_39, DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_seconds_field_0, 
                B0=>extractor_inst_seconds_field_1, 
                C0=>extractor_inst_seconds_field_2, 
                D0=>extractor_inst_seconds_field_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>extractor_inst_extract_state_tr8_22, 
                Q1=>open, OFX0=>open, F0=>extractor_inst_extract_state_tr8_23, 
                Q0=>open);
    extractor_inst_SLICE_388I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0808")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>packet_start, 
                B1=>packet_type_5, C1=>packet_type_7, D1=>'X', DI1=>'X', 
                DI0=>'X', A0=>packet_type_0, B0=>packet_type_1, 
                C0=>packet_type_2, D0=>packet_type_3, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>extractor_inst_packet_active6_4, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_packet_active6_5, Q0=>open);
    parser_inst_SLICE_389I: SLOGICB
      generic map (LUT0_INITVAL=>X"1111", LUT1_INITVAL=>X"FFFE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', 
                A1=>parser_inst_packet_length_reg_5, 
                B1=>parser_inst_packet_length_reg_7, 
                C1=>parser_inst_packet_length_reg_8, 
                D1=>parser_inst_packet_length_reg_10, DI1=>'X', DI0=>'X', 
                A0=>parser_inst_packet_length_reg_5, 
                B0=>parser_inst_packet_length_reg_8, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>parser_inst_g2_0_8, Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_ns_0_a2_12_3_5, Q0=>open);
    pps_inst_SLICE_390I: SLOGICB
      generic map (LUT0_INITVAL=>X"EEEE", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_pulse_counter_19, 
                B1=>pps_inst_pps_pulse_counter_20, 
                C1=>pps_inst_pps_pulse_counter_21, 
                D1=>pps_inst_pps_pulse_counter_22, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_pulse_counter_19, 
                B0=>pps_inst_pps_pulse_counter_20, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_armed_1_sqmuxa_16, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_state_ns_0_o2_0_9_2, Q0=>open);
    pps_inst_SLICE_391I: SLOGICB
      generic map (LUT0_INITVAL=>X"1111", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_15, 
                B1=>pps_inst_sync_error_16, C1=>pps_inst_sync_error_17, 
                D1=>pps_inst_sync_error_18, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_sync_error_27, B0=>pps_inst_sync_error_28, 
                C0=>'X', D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>pps_inst_drift_accumulator8lto31_12, Q1=>open, 
                OFX0=>open, F0=>pps_inst_N_378_3, Q0=>open);
    pps_inst_SLICE_392I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_subsec_counter_8, 
                B1=>pps_inst_subsec_counter_9, C1=>pps_inst_subsec_counter_13, 
                D1=>pps_inst_subsec_counter_15, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_subsec_counter_0, B0=>pps_inst_subsec_counter_1, 
                C0=>pps_inst_subsec_counter_12, D0=>pps_inst_subsec_counter_14, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_11, Q1=>open, 
                OFX0=>open, F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_9, 
                Q0=>open);
    pps_inst_SLICE_393I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0101")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_5, 
                B1=>pps_inst_sync_error_6, C1=>pps_inst_sync_error_7, D1=>'X', 
                DI1=>'X', DI0=>'X', A0=>pps_inst_sync_error_0, 
                B0=>pps_inst_sync_error_1, C0=>pps_inst_sync_error_2, 
                D0=>pps_inst_sync_error_3, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_pps_state_ns_i_a2_3_1_4, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_i_a2_4_4, 
                Q0=>open);
    pps_inst_SLICE_394I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000", LUT1_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>debug_status_c_3, 
                B1=>pps_inst_subsec_counter_6, C1=>subseconds_6, D1=>'X', 
                DI1=>'X', DI0=>'X', A0=>pps_inst_subsec_counter_2, 
                B0=>pps_inst_subsec_counter_4, C0=>pps_inst_subsec_counter_6, 
                D0=>pps_inst_subsec_counter_7, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>pps_inst_subsec_counter_6_axb_6, 
                Q1=>open, OFX0=>open, 
                F0=>pps_inst_current_seconds_0_sqmuxa_1_a2_29_10, Q0=>open);
    pps_inst_SLICE_395I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_10, 
                B1=>pps_inst_sync_error_13, C1=>pps_inst_sync_error_23, 
                D1=>pps_inst_sync_error_24, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_sync_error_19, B0=>pps_inst_sync_error_20, 
                C0=>pps_inst_sync_error_21, D0=>pps_inst_sync_error_22, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_drift_accumulator8lto31_14, Q1=>open, OFX0=>open, 
                F0=>pps_inst_drift_accumulator8lto31_13, Q0=>open);
    pps_inst_SLICE_396I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_25, 
                B1=>pps_inst_sync_error_26, C1=>pps_inst_sync_error_29, 
                D1=>pps_inst_sync_error_30, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_sync_error_11, B0=>pps_inst_sync_error_12, 
                C0=>pps_inst_sync_error_14, D0=>pps_inst_sync_error_31, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_drift_accumulator8lto31_10, Q1=>open, OFX0=>open, 
                F0=>pps_inst_drift_accumulator8lto31_11, Q0=>open);
    pps_inst_SLICE_397I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001", LUT1_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_sync_error_18, 
                B1=>pps_inst_sync_error_19, C1=>pps_inst_sync_error_24, 
                D1=>pps_inst_sync_error_25, DI1=>'X', DI0=>'X', 
                A0=>pps_inst_sync_error_16, B0=>pps_inst_sync_error_17, 
                C0=>pps_inst_sync_error_22, D0=>pps_inst_sync_error_23, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>pps_inst_pps_state_ns_0_a2_0_11_1, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_state_ns_0_a2_0_10_1, Q0=>open);
    pps_inst_SLICE_398I: SLOGICB
      generic map (LUT0_INITVAL=>X"0004", LUT1_INITVAL=>X"1111")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>pps_inst_pps_state_0, 
                B1=>pps_inst_pps_state_2, C1=>'X', D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>pps_inst_pps_state_ns_i_o2_3_4, B0=>pps_inst_pps_state_1, 
                C0=>pps_inst_pps_state_2, D0=>pps_inst_sync_error_10, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>pps_inst_N_166, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_a2_2_2, 
                Q0=>open);
    SLICE_399I: SLOGICB
      generic map (M0MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FEFE", CHECK_M0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_5, 
                B0=>debug_status_c_6, C0=>debug_status_c_7, D0=>'X', 
                M0=>pps_inst_pps_state_4, CE=>'X', CLK=>clk_100mhz_c, LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, F0=>led_error_c, 
                Q0=>debug_status_c_7);
    pps_inst_SLICE_400I: SLOGICB
      generic map (LUT0_INITVAL=>X"FFF1")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_pps_state_4, 
                B0=>pps_inst_pps_state_1, C0=>pps_inst_pps_state_2, 
                D0=>pps_inst_pps_state_0, M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', 
                OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_pulse_countere, Q0=>open);
    pps_inst_SLICE_401I: SLOGICB
      generic map (LUT0_INITVAL=>X"1F1F")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_sync_error_3, 
                B0=>pps_inst_sync_error_4, C0=>pps_inst_sync_error_7, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_state_ns_0_o2_3_1_1, 
                Q0=>open);
    pps_inst_SLICE_402I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_sync_error_14, 
                B0=>pps_inst_sync_error_15, C0=>pps_inst_sync_error_26, 
                D0=>pps_inst_sync_error_29, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_state_ns_0_a2_0_9_1, Q0=>open);
    pps_inst_SLICE_403I: SLOGICB
      generic map (LUT0_INITVAL=>X"0001")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_pps_pulse_counter_10, 
                B0=>pps_inst_pps_pulse_counter_11, 
                C0=>pps_inst_pps_pulse_counter_30, 
                D0=>pps_inst_pps_pulse_counter_31, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>pps_inst_pps_armed_1_sqmuxa_13, Q0=>open);
    pps_inst_SLICE_404I: SLOGICB
      generic map (LUT0_INITVAL=>X"0100")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>pps_inst_pps_pulse_counter_16, 
                B0=>pps_inst_pps_pulse_counter_17, 
                C0=>pps_inst_pps_pulse_counter_18, D0=>pps_inst_pps_state_3, 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_pps_armed_1_sqmuxa_15, 
                Q0=>open);
    pps_inst_SLICE_405I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_1, C0=>subseconds_1, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_1, 
                Q0=>open);
    pps_inst_SLICE_406I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_2, C0=>subseconds_2, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_2, 
                Q0=>open);
    pps_inst_SLICE_407I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_4, C0=>subseconds_4, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_4, 
                Q0=>open);
    pps_inst_SLICE_408I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_7, C0=>subseconds_7, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_7, 
                Q0=>open);
    pps_inst_SLICE_409I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_8, C0=>subseconds_8, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_8, 
                Q0=>open);
    pps_inst_SLICE_410I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_9, C0=>subseconds_9, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_9, 
                Q0=>open);
    pps_inst_SLICE_411I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_13, C0=>subseconds_13, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_13, 
                Q0=>open);
    pps_inst_SLICE_412I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_15, C0=>subseconds_15, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_15, 
                Q0=>open);
    pps_inst_SLICE_413I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_20, C0=>subseconds_20, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_20, 
                Q0=>open);
    pps_inst_SLICE_414I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_21, C0=>subseconds_21, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_21, 
                Q0=>open);
    pps_inst_SLICE_415I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_22, C0=>subseconds_22, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_22, 
                Q0=>open);
    pps_inst_SLICE_416I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_24, C0=>subseconds_24, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_24, 
                Q0=>open);
    pps_inst_SLICE_417I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_26, C0=>subseconds_26, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_26, 
                Q0=>open);
    pps_inst_SLICE_418I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_27, C0=>subseconds_27, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_27, 
                Q0=>open);
    pps_inst_SLICE_419I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_28, C0=>subseconds_28, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_28, 
                Q0=>open);
    pps_inst_SLICE_420I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_29, C0=>subseconds_29, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_29, 
                Q0=>open);
    pps_inst_SLICE_421I: SLOGICB
      generic map (LUT0_INITVAL=>X"E4E4")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_subsec_counter_30, C0=>subseconds_30, D0=>'X', 
                M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, 
                Q1=>open, OFX0=>open, F0=>pps_inst_subsec_counter_6_axb_30, 
                Q0=>open);
    pps_inst_SLICE_422I: SLOGICB
      generic map (LUT0_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>'X', D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>pps_inst_sync_error22, Q0=>open);
    pps_inst_SLICE_423I: SLOGICB
      generic map (LUT0_INITVAL=>X"EEEE")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>debug_status_c_3, 
                B0=>pps_inst_time_valid, C0=>'X', D0=>'X', M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>pps_inst_time_valid_2, Q0=>open);
    extractor_inst_SLICE_424I: SLOGICB
      generic map (LUT0_INITVAL=>X"2000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_timestamp_buffer_0_0_sqmuxa_0_a2_0, 
                B0=>extractor_inst_byte_index_2, 
                C0=>extractor_inst_byte_index_3, 
                D0=>extractor_inst_timestamp_buffer_5_0_sqmuxa_0_a4_0, M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>open, F0=>extractor_inst_timestamp_buffer_9_0_sqmuxa, 
                Q0=>open);
    extractor_inst_SLICE_425I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_seconds_field_32, 
                B0=>extractor_inst_seconds_field_33, 
                C0=>extractor_inst_seconds_field_34, 
                D0=>extractor_inst_seconds_field_35, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_21, Q0=>open);
    extractor_inst_SLICE_426I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_seconds_field_8, 
                B0=>extractor_inst_seconds_field_9, 
                C0=>extractor_inst_seconds_field_10, 
                D0=>extractor_inst_seconds_field_11, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_25, Q0=>open);
    extractor_inst_SLICE_427I: SLOGICB
      generic map (LUT0_INITVAL=>X"8000")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_seconds_field_24, 
                B0=>extractor_inst_seconds_field_25, 
                C0=>extractor_inst_seconds_field_26, 
                D0=>extractor_inst_seconds_field_27, M0=>'X', CE=>'X', 
                CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_tr8_29, Q0=>open);
    extractor_inst_SLICE_428I: SLOGICB
      generic map (M0MUX=>"SIG", CLKMUX=>"SIG", CEMUX=>"VHI", SRMODE=>"ASYNC", 
                   LUT0_INITVAL=>X"FEFE", CHECK_M0=>TRUE)
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>extractor_inst_extract_state_0, 
                B0=>extractor_inst_extract_state_3, 
                C0=>extractor_inst_extract_state_4, D0=>'X', 
                M0=>extractor_inst_extract_state_3, CE=>'X', CLK=>clk_100mhz_c, 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>extractor_inst_extract_state_ns_2_3, 
                Q0=>extractor_inst_extract_state_4);
    parser_inst_SLICE_429I: SLOGICB
      generic map (LUT0_INITVAL=>X"2020")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>parser_inst_t2mi_valid_sync, 
                B0=>parser_inst_parser_state_2, C0=>parser_inst_parser_state_3, 
                D0=>'X', M0=>'X', CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, 
                F1=>open, Q1=>open, OFX0=>open, 
                F0=>parser_inst_parser_state_RNI7DD56_2, Q0=>open);
    parser_inst_SLICE_430I: SLOGICB
      generic map (LUT0_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>parser_inst_parser_state_1, 
                B0=>parser_inst_t2mi_valid_sync, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>open, F0=>parser_inst_N_87_i, Q0=>open);
    parser_inst_SLICE_431I: SLOGICB
      generic map (LUT0_INITVAL=>X"8888")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', A0=>parser_inst_parser_state_2, 
                B0=>parser_inst_t2mi_valid_sync, C0=>'X', D0=>'X', M0=>'X', 
                CE=>'X', CLK=>'X', LSR=>'X', OFX1=>open, F1=>open, Q1=>open, 
                OFX0=>open, F0=>parser_inst_packet_length_regce_8, Q0=>open);
    parser_inst_SLICE_432I: SLOGICB
      generic map (LUT0_INITVAL=>X"01CC")
      port map (M1=>'X', FXA=>'X', FXB=>'X', A1=>'X', B1=>'X', C1=>'X', 
                D1=>'X', DI1=>'X', DI0=>'X', 
                A0=>parser_inst_parser_state_ns_i_o3_0, 
                B0=>parser_inst_byte_counter, C0=>parser_inst_parser_state_5, 
                D0=>parser_inst_t2mi_valid_sync, M0=>'X', CE=>'X', CLK=>'X', 
                LSR=>'X', OFX1=>open, F1=>open, Q1=>open, OFX0=>open, 
                F0=>parser_inst_N_91_i_mb_mb_1_0, Q0=>open);
    pps_outI: pps_outB
      port map (PADDO=>led_pps_c, ppsout=>pps_out);
    clk_100mhzI: clk_100mhzB
      port map (PADDI=>clk_100mhz_c, clk100mhz=>clk_100mhz);
    led_errorI: led_errorB
      port map (PADDO=>led_error_c, lederror=>led_error);
    led_ppsI: led_ppsB
      port map (PADDO=>led_pps_c, ledpps=>led_pps);
    led_syncI: led_syncB
      port map (PADDO=>led_sync_c, ledsync=>led_sync);
    led_powerI: led_powerB
      port map (PADDO=>led_power_c, ledpower=>led_power);
    debug_status_7_I: debug_status_7_B
      port map (PADDO=>debug_status_c_7, debugstatus7=>debug_status(7));
    debug_status_6_I: debug_status_6_B
      port map (PADDO=>debug_status_c_6, debugstatus6=>debug_status(6));
    debug_status_5_I: debug_status_5_B
      port map (PADDO=>debug_status_c_5, debugstatus5=>debug_status(5));
    debug_status_4_I: debug_status_4_B
      port map (PADDO=>debug_status_c_3, debugstatus4=>debug_status(4));
    debug_status_3_I: debug_status_3_B
      port map (PADDO=>debug_status_c_3, debugstatus3=>debug_status(3));
    debug_status_2_I: debug_status_2_B
      port map (PADDO=>debug_status_c_2, debugstatus2=>debug_status(2));
    debug_status_1_I: debug_status_1_B
      port map (PADDO=>led_sync_c, debugstatus1=>debug_status(1));
    debug_status_0_I: debug_status_0_B
      port map (PADDO=>led_power_c, debugstatus0=>debug_status(0));
    sync_lockedI: sync_lockedB
      port map (PADDO=>led_sync_c, synclocked=>sync_locked);
    timestamp_validI: timestamp_validB
      port map (PADDO=>debug_status_c_3, timestampvalid=>timestamp_valid);
    t2mi_data_7_I: t2mi_data_7_B
      port map (PADDI=>t2mi_data_c_7, t2midata7=>t2mi_data(7));
    t2mi_data_7_MGIOLI: t2mi_data_7_MGIOL
      port map (DI=>t2mi_data_c_7, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_7);
    t2mi_data_6_I: t2mi_data_6_B
      port map (PADDI=>t2mi_data_c_6, t2midata6=>t2mi_data(6));
    t2mi_data_6_MGIOLI: t2mi_data_6_MGIOL
      port map (DI=>t2mi_data_c_6, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_6);
    t2mi_data_5_I: t2mi_data_5_B
      port map (PADDI=>t2mi_data_c_5, t2midata5=>t2mi_data(5));
    t2mi_data_5_MGIOLI: t2mi_data_5_MGIOL
      port map (DI=>t2mi_data_c_5, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_5);
    t2mi_data_4_I: t2mi_data_4_B
      port map (PADDI=>t2mi_data_c_4, t2midata4=>t2mi_data(4));
    t2mi_data_4_MGIOLI: t2mi_data_4_MGIOL
      port map (DI=>t2mi_data_c_4, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_4);
    t2mi_data_3_I: t2mi_data_3_B
      port map (PADDI=>t2mi_data_c_3, t2midata3=>t2mi_data(3));
    t2mi_data_3_MGIOLI: t2mi_data_3_MGIOL
      port map (DI=>t2mi_data_c_3, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_3);
    t2mi_data_2_I: t2mi_data_2_B
      port map (PADDI=>t2mi_data_c_2, t2midata2=>t2mi_data(2));
    t2mi_data_2_MGIOLI: t2mi_data_2_MGIOL
      port map (DI=>t2mi_data_c_2, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_2);
    t2mi_data_1_I: t2mi_data_1_B
      port map (PADDI=>t2mi_data_c_1, t2midata1=>t2mi_data(1));
    t2mi_data_1_MGIOLI: t2mi_data_1_MGIOL
      port map (DI=>t2mi_data_c_1, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_1);
    t2mi_data_0_I: t2mi_data_0_B
      port map (PADDI=>t2mi_data_c_0, t2midata0=>t2mi_data(0));
    t2mi_data_0_MGIOLI: t2mi_data_0_MGIOL
      port map (DI=>t2mi_data_c_0, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_data_sync_0);
    t2mi_validI: t2mi_validB
      port map (PADDI=>t2mi_valid_c, t2mivalid=>t2mi_valid);
    t2mi_valid_MGIOLI: t2mi_valid_MGIOL
      port map (DI=>t2mi_valid_c, CLK=>clk_100mhz_c, 
                INFF=>parser_inst_t2mi_valid_sync);
    rst_nI: rst_nB
      port map (PADDI=>rst_n_c, rstn=>rst_n);
    GSR_INST: GSR_INSTB
      port map (GSRNET=>led_power_c);
    VHI_INST: VHI
      port map (Z=>VCCI);
    PUR_INST: PUR
      port map (PUR=>VCCI);
  end Structure;



  library IEEE, vital2000, ECP5U;
  configuration Structure_CON of t2mi_pps_top is
    for Structure
    end for;
  end Structure_CON;


