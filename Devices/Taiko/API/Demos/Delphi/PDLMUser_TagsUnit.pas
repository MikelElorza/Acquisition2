unit PDLMUser_TagsUnit;

interface

  const
                PDLM_TAGNAME_MAXLEN                   = 31;
                //
                //
    // Tag Types
                //
                PDLM_TAGTYPE_BOOL                     = $00000001;
                PDLM_TAGTYPE_UINT                     = $00010001;
                PDLM_TAGTYPE_UINT_ENUM                = $00010002;          // for list-driven values
                PDLM_TAGTYPE_UINT_DAC                 = $00010003;          // for any direct given raw DAC value
                PDLM_TAGTYPE_UINT_IN_TENTH            = $00010101;          // for temperatures in tenth of a celsius degree
                PDLM_TAGTYPE_UINT_IN_PERCENT          = $00010201;          // for interpolation tables
                PDLM_TAGTYPE_UINT_IN_PERMILLE         = $00010301;          // for permille values in power or current interpolation tables
                PDLM_TAGTYPE_UINT_IN_PERTHOUSAND      = $00010302;          // for (positive only) milli Volts, milli Watts, etc.
                PDLM_TAGTYPE_UINT_IN_PERMYRIAD        = $00010401;          // for current interpolation tables (a hundreth of a percent)
                PDLM_TAGTYPE_UINT_IN_PERMILLION       = $00010601;          // for power values in 10^(-6) Watt = uW
                PDLM_TAGTYPE_UINT_IN_PERBILLION       = $00010901;          // for power values in 10^(-9) Watt = nW
                PDLM_TAGTYPE_UINT_IN_PERTRILLION      = $00010C01;          // for wavelength values in 10^(-12) Meter  = pm
                PDLM_TAGTYPE_UINT_IN_PERQUADRILLION   = $00010F01;          // for pulse energy values in 10^(-15) Joule = fJ
                //
                PDLM_TAGTYPE_INT                      = $00110001;
                PDLM_TAGTYPE_INT_IN_PERTHOUSAND       = $00110302;          // for milli Volts (trigger level, negative values included)
                //
                PDLM_TAGTYPE_SINGLE                   = $01000001;
                PDLM_TAGTYPE_VOID                     = $FFFFFFFF;
                //
                //
                //
    //
    // Tag IDs
    //
    // Consider, that there are some more tags defined for internal use.
    //           Current PDLM_TAG_COUNT is 54;
    //           This is subject to change without notice
    //
                //
                PDLM_TAG_LaserMode                    = $00000020;          //
                PDLM_TAG_LDH_PulsePowerTable          = $00000021;          //
                //                                                          //
                PDLM_TAG_TriggerMode                  = $00000030;          //
                PDLM_TAG_TriggerLevel                 = $00000048;          //  in V
                PDLM_TAG_TriggerLevelLoLimit          = $00000049;          //  in V
                PDLM_TAG_TriggerLevelHiLimit          = $0000004A;          //  in V
                //                                                          //
                PDLM_TAG_FastGate                     = $00000050;          //
                PDLM_TAG_FastGateImp                  = $00000060;          //
                PDLM_TAG_SlowGate                     = $00000070;          //
                //                                                          //
                //                                                          //  The temperatures sent with the following tags are unambiguous data.
                //                                                          //  They are always fired on changes in the HW
                PDLM_TAG_LHTargetTempRaw              = $00000090;          //  in 1/10 °C (as cardinal)
                PDLM_TAG_LHTargetTempRawLoLimit       = $00000091;          //  in 1/10 °C (as cardinal)
                PDLM_TAG_LHTargetTempRawHiLimit       = $00000092;          //  in 1/10 °C (as cardinal)
                PDLM_TAG_LHCurrentTempRaw             = $00000094;          //  in 1/10 °C (as cardinal)
                PDLM_TAG_LHCaseTempRaw                = $00000095;          //  in 1/10 °C (as cardinal)
                //                                                          //
                //                                                          //  The temperatures sent with these tags are ambiguous data!
                //                                                          //  They depend on the TempScale as currently set.
                //                                                          //  They are only sent if explicitely requested!
                PDLM_TAG_LHTargetTemp                 = $00000098;          //  in arbitrary temperature units (as single)
                PDLM_TAG_LHTargetTempLoLimit          = $00000099;          //  in arbitrary temperature units (as single)
                PDLM_TAG_LHTargetTempHiLimit          = $0000009A;          //  in arbitrary temperature units (as single)
                PDLM_TAG_LHCurrentTemp                = $0000009C;          //  in arbitrary temperature units (as single)
                PDLM_TAG_LHCaseTemp                   = $0000009D;          //  in arbitrary temperature units (as single)
                //                                                          //
                PDLM_TAG_TempScale                    = $0000009F;          //  identifies the temperature scale currently in use
                //                                                          //
                PDLM_TAG_Frequency                    = $000000A8;          //  in Hz
                PDLM_TAG_FrequencyLoLimit             = $000000A9;          //  in Hz
                PDLM_TAG_FrequencyHiLimit             = $000000AA;          //  in Hz
                //                                                          //
                PDLM_TAG_PulsePowerPermille           = $000000B4;          //
                PDLM_TAG_PulsePowerShape              = $000000B5;          //
                PDLM_TAG_PulsePower                   = $000000B8;          //  in W
                PDLM_TAG_PulsePowerLoLimit            = $000000B9;          //  in W
                PDLM_TAG_PulsePowerHiLimit            = $000000BA;          //  in W
                PDLM_TAG_PulsePowerNanoWatt           = $000000BC;          //  in nW
                //                                                          //
                PDLM_TAG_CwPowerPermille              = $000000C4;          //
                PDLM_TAG_CwPower                      = $000000C8;          //  in W
                PDLM_TAG_CwPowerLoLimit               = $000000C9;          //  in W
                PDLM_TAG_CwPowerHiLimit               = $000000CA;          //  in W
                PDLM_TAG_CwPowerMicroWatt             = $000000CC;          //  in µW
                //                                                          //
                PDLM_TAG_BurstLen                     = $000000D0;          //
                PDLM_TAG_BurstPeriod                  = $000000E0;          //
                //                                                          //
                PDLM_TAG_LHFan                        = $000000F0;          //  represented by a function, and additionally by a system state bit
                //                                                          //
                PDLM_TAG_UI_Exclusive                 = $00000100;          //  represented by a function, and additionally by a system state bit
                //                                                          //
                PDLM_TAG_NONE                         = $00000000;          //

  type

    T_TagDef = record
      tag_name : string;
      tag_code : cardinal;
      tag_type : cardinal;
    end;
    T_TagDefList = array of T_TagDef;

    T_TagTypedValue = record
      case cardinal of
        PDLM_TAGTYPE_BOOL,
        PDLM_TAGTYPE_UINT_ENUM,
        PDLM_TAGTYPE_UINT_DAC,
        PDLM_TAGTYPE_UINT_IN_TENTH,                // for temperatures in tenth of a celsius degree
        PDLM_TAGTYPE_UINT_IN_PERCENT,              // for interpolation tables
        PDLM_TAGTYPE_UINT_IN_PERMILLE,             // for permille values in power or current interpolation tables
        PDLM_TAGTYPE_UINT_IN_PERTHOUSAND,          // for (positive only) milli Volts, milli Watts, etc.
        PDLM_TAGTYPE_UINT_IN_PERMYRIAD,            // for current interpolation tables (a hundreth of a percent)
        PDLM_TAGTYPE_UINT_IN_PERMILLION,           // for power values in 10^(-6) Watt = uW
        PDLM_TAGTYPE_UINT_IN_PERBILLION,           // for power values in 10^(-9) Watt = nW
        PDLM_TAGTYPE_UINT_IN_PERTRILLION,          // for wavelength values in 10^(-12) m  = pm
        PDLM_TAGTYPE_UINT_IN_PERQUADRILLION,       // for pulse energy values in 10^(-15) joules = femto joule
        PDLM_TAGTYPE_UINT:
          (uiValue : Cardinal;);
        PDLM_TAGTYPE_INT_IN_PERTHOUSAND,           // for milli Volts (trigger level)
        PDLM_TAGTYPE_INT:
          (iValue  : integer;);
        PDLM_TAGTYPE_SINGLE:
          (fValue  : Single;);
    end;

    T_TaggedValue = record
      tcTag    : Cardinal;
      ttvValue : T_TagTypedValue;
    end;
    P_TaggedValue = ^T_TaggedValue;

    T_TaggedValueList = array of T_TaggedValue;
    P_TaggedValueList = ^T_TaggedValueList;

implementation

end.
