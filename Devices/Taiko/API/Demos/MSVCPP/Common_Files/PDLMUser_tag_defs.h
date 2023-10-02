/*---------------------------------------------------------------------------*/
//
// PDLMUser_tag_defs.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
#pragma once

#define PDLM_TAGNAME_MAXLEN                                      31

//
//***************************************************************************
//*** Table of all declared tag types                                     ***
//***************************************************************************
//
//****************************************************//************//***************************************************************
#define PDLM_TAGTYPE_BOOL                                0x00000001 //
#define PDLM_TAGTYPE_UINT                                0x00010001 //
#define PDLM_TAGTYPE_UINT_ENUM                           0x00010002 // for list-driven values
#define PDLM_TAGTYPE_UINT_DAC                            0x00010003 // for any directly given raw DAC value
#define PDLM_TAGTYPE_UINT_IN_TENTH                       0x00010101 // for temperatures in tenth of a celsius degree
#define PDLM_TAGTYPE_UINT_IN_PERCENT                     0x00010201 // for interpolation tables
#define PDLM_TAGTYPE_UINT_IN_PERMILLE                    0x00010301 // for permille values in power or current interpolation tables
#define PDLM_TAGTYPE_UINT_IN_PERTHOUSAND                 0x00010302 // for unsigned values of e.g. milli Watts, etc.
#define PDLM_TAGTYPE_UINT_IN_PERMYRIAD                   0x00010401 // for current interpolation tables (a hundreth of a percent)
#define PDLM_TAGTYPE_UINT_IN_PERMILLION                  0x00010601 // for cw    power values in 10^(-6) Watt = uW
#define PDLM_TAGTYPE_UINT_IN_PERBILLION                  0x00010901 // for pulse power values in 10^(-9) Watt = nW
#define PDLM_TAGTYPE_UINT_IN_PERTRILLION                 0x00010C01 // for wavelength values in 10^(-12) m  = pm
#define PDLM_TAGTYPE_UINT_IN_PERQUADTRILLION             0x00010F01 // for pulse energy values in 10^(-15) joules = femto joule
#define PDLM_TAGTYPE_INT                                 0x00110001 //
#define PDLM_TAGTYPE_INT_IN_PERTHOUSAND                  0x00110302 // for signed values of e.g. milli Volts etc.
#define PDLM_TAGTYPE_SINGLE                              0x01000001 //
#define PDLM_TAGTYPE_VOID                                0xFFFFFFFF //
//****************************************************//************//***************************************************************

//
//***************************************************************************
//*** Table of documented tags                                            ***
//***************************************************************************
//
// Consider, that there are some more tags defined for internal use.
//           Current PDLM_TAG_COUNT is 55;
//           This is subject to change without notice
//
#define MAX_TAGLIST_LEN                                          64
//
//****************************************************//************//***************************************************************
#define PDLM_TAG_NONE                                    0x00000000 //
//                                                                  //
#define PDLM_TAG_LaserMode                               0x00000020 //
#define PDLM_TAG_LDH_PulsePowerTable                     0x00000021 //
//                                                                  //
#define PDLM_TAG_TriggerMode                             0x00000030 //
#define PDLM_TAG_TriggerLevel                            0x00000048 // in V
#define PDLM_TAG_TriggerLevelLoLimit                     0x00000049 // in V
#define PDLM_TAG_TriggerLevelHiLimit                     0x0000004A // in V
#define PDLM_TAG_FastGate                                0x00000050 //
#define PDLM_TAG_FastGateImp                             0x00000060 //
#define PDLM_TAG_SlowGate                                0x00000070 //
//                                                                  //
//                                                                  // The temperatures sent with the following tags are unambiguous data.
//                                                                  // They are always fired on changes in the HW
#define PDLM_TAG_TargetTempRaw                           0x00000090 // in 1/10 °C (as unsigned int)
#define PDLM_TAG_TargetTempRawLoLimit                    0x00000091 // in 1/10 °C (as unsigned int)
#define PDLM_TAG_TargetTempRawHiLimit                    0x00000092 // in 1/10 °C (as unsigned int)
#define PDLM_TAG_CurrentTempRaw                          0x00000094 // in 1/10 °C (as unsigned int)
#define PDLM_TAG_CaseTempRaw                             0x00000095 // in 1/10 °C (as unsigned int)
//                                                                  //
//                                                                  // The temperatures sent with these tags are ambiguous data!
//                                                                  // They depend on the current TempScale value.
//                                                                  // They are only sent if explicitely requested!
#define PDLM_TAG_TargetTemp                              0x00000098 // in arbitrary temperature units (as float)
#define PDLM_TAG_TargetTempLoLimit                       0x00000099 // in arbitrary temperature units (as float)
#define PDLM_TAG_TargetTempHiLimit                       0x0000009A // in arbitrary temperature units (as float)
#define PDLM_TAG_CurrentTemp                             0x0000009C // in arbitrary temperature units (as float)
#define PDLM_TAG_CaseTemp                                0x0000009D // in arbitrary temperature units (as float)
//                                                                  //
#define PDLM_TAG_TempScale                               0x0000009F // identifies the temperature scale currently in use
//                                                                  //
#define PDLM_TAG_Frequency                               0x000000A8 // in Hz
#define PDLM_TAG_FrequencyLoLimit                        0x000000A9 //
#define PDLM_TAG_FrequencyHiLimit                        0x000000AA //
//                                                                  //
#define PDLM_TAG_PulsePowerPermille                      0x000000B4 //
#define PDLM_TAG_PulseShape                              0x000000B5 //
#define PDLM_TAG_PulsePower                              0x000000B8 // in W
#define PDLM_TAG_PulsePowerLoLimit                       0x000000B9 // in W
#define PDLM_TAG_PulsePowerHiLimit                       0x000000BA // in W
#define PDLM_TAG_PulsePowerNanowatt                      0x000000BC // in nW
#define PDLM_TAG_PulseEnergy                             0x000000BF // in fJ
//                                                                  //
#define PDLM_TAG_CwPowerPermille                         0x000000C4 //
#define PDLM_TAG_CwPower                                 0x000000C8 // in W
#define PDLM_TAG_CwPowerLoLimit                          0x000000C9 // in W
#define PDLM_TAG_CwPowerHiLimit                          0x000000CA // in W
#define PDLM_TAG_CwPowerMicroWatt                        0x000000CC // in µW
//                                                                  //
#define PDLM_TAG_BurstLen                                0x000000D0 //
#define PDLM_TAG_BurstPeriod                             0x000000E0 //
//                                                                  //
#define PDLM_TAG_LDH_Fan                                 0x000000F0 // is also published by status flag
#define PDLM_TAG_UI_Exclusive                            0x00000100 // is also published by status flag
//****************************************************//************//***************************************************************
