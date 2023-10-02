/*---------------------------------------------------------------------------*/
//
// PDLMUser_type_defs.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
#pragma once

//
//***************************************************************************
//***  Basic UI Types                                                     ***
//***************************************************************************
//

  typedef __packed struct _TVersNum
  {
    uint16_t Major;                                // currently valid: Versions  "0.0"  or   "1.0"
    uint16_t Minor;                                //
    char     Notes[PDLM_DEV_STRING_LENGTH];        // Version device notes, eg "beta-test", "pre-release", etc...
  } TVersNum, *PVersNum;

  typedef __packed struct _TDeviceData
  {
    uint32_t   SN;                                    // serial number
    uint32_t   ArtNo;                                 // article number
    char       Name[PDLM_DEV_STRING_LENGTH];          // e.g. "Taiko"
    char       Type[PDLM_DEV_STRING_LENGTH];          // e.g. "PDL M1"
    char       Date[PDLM_DEV_STRING_LENGTH];          // date of manufacturing
    char       VersPCB[PDLM_DEV_STRING_LENGTH];       // version PCB e.g. "078.2005.0104"
    TVersNum   VersDev;                               // version device
  } TDeviceData, *PDeviceData;

  typedef __packed struct _TLHVersNum
  {
    uint16_t   major;
    uint16_t   minor;
  } TLHVersNum, *PLHVersNum;

  typedef __packed struct _TLaserData
  {
    uint32_t   SN;                                    // serial number, a real number not a string
    uint32_t   Features;                              // bitset; for direct access use function "PDLM_GetLHFeatures"
    uint32_t   FreqMin;                               // laser minimum frequency in Hz; for better access use function "PDLM_GetFrequencyLimits"
    uint32_t   FreqMax;                               // laser maximum frequency in Hz;  "            "           "         "
    uint32_t   CwPowerMax;                            // in microwatts; just informative, should not be used in calculations
    uint32_t   PulsePowerMax;                         // in microwatts; just informative, should not be used in calculations
    uint16_t   WavelengthNominal;                     // in 1/10 nm
                                                      // next three named items share the same uint16_t (bitmasked)
    uint16_t   CaseTempMax       : 10;                // maximum case temperature in 1/10 of °C
    uint16_t   Protection        : 1;                 // 0 = class 3,  1 = class 4
    uint16_t   CwCurrentPolarity : 1;                 // 0 = positive, 1 = negative;  not used in Taiko, reserved for future devices
    uint16_t                     : 4;                 // dummy, reserved for future use...
                                                      // next named item uses only a part of an uint16_t (bitmasked)
    uint16_t   LHTypeCtrlVoltage : 12;                // maximum voltage of the driver for this LH type in cV. 1cV == 10 mV
    uint16_t                     : 4;                 // dummy, reserved for future use...
                                                      // next named item uses only a part of an uint16_t (bitmasked)
    uint16_t   LHMaxVoltage      : 12;                // maximum voltage of this individual LH diode in cV. 1cV == 10 mV
    uint16_t                     : 4;                 // dummy, reserved for future use...
    uint16_t   CurrentTEP12V;                         // Current consumption of TEP 12V power supply in mA, reserved for future devices
    uint16_t   laserType;                             // identifies the type of the taiko laser head (see above)
    TLHVersNum laserVersion;                          // for direct access use function "PDLM_GetLHVersion"
    uint16_t   calibratedWarrantHours;                // Duration of valid calibration in hours
  } TLaserData, *PLaserData;


  typedef __packed struct _TLaserInfo
  {
    char       LType  [PDLM_LDH_STRING_LENGTH];       // e.g. "LDH-D-C-405"
    char       Date   [PDLM_LDH_STRING_LENGTH];       // date of manufacturing e.g. "2017-01-23"
    char       LClass [PDLM_LDH_STRING_LENGTH];       // laser class e.g. "3B"
  } TLaserInfo, *PLaserInfo;



  typedef union _TValueType {
    uint32_t ValueUInt;                               // for PDLM_TAGTYPE_BOOL, PDLM_TAGTYPE_UINT_ENUM, PDLM_TAGTYPE_UINT_DAC, PDLM_TAGTYPE_UINT_IN_TENTH, PDLM_TAGTYPE_UINT_IN_PERBILLION, PDLM_TAGTYPE_UINT
    int32_t  ValueInt;                                // for PDLM_TAGTYPE_INT
    float    ValueFloat;                              // for PDLM_TAGTYPE_SINGLE
  } TValueType, *PValueType;

  typedef struct _TTagValue {
    uint32_t   Tag;
    TValueType Value;
  } TTagValue, *PTagValue;

  typedef struct _TTagTypeDef {
    uint32_t   tag;
    uint32_t   tagtype;
    char       name [PDLM_TAGNAME_MAXLEN + 1];
  } TTagTypeDef, *PTagTypeDef;

