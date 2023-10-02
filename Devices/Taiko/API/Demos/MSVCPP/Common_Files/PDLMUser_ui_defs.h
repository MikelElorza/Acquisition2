/*---------------------------------------------------------------------------*/
//
// PDLMUser_ui_defs.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
#pragma once


//
//***************************************************************************
//***  Basic UI Constants                                                 ***
//***************************************************************************
//
//****************************************************//************//
#define PDLM_LIBVERSION_MAXLEN                                   12
#define PDLM_USB_INDEX_MIN                                        0
#define PDLM_USB_INDEX_MAX                                        7
#define PDLM_MAX_USBDEVICES                                       8
#define PDLM_HW_ERRORSTRING_MAXLEN                               47
#define PDLM_HW_INFO_MAXLEN                                      36
#define PDLM_DEV_STRING_LENGTH                                   16
#define PDLM_LDH_STRING_LENGTH                                   16
//****************************************************//************//
#define PDLM_UI_COOPERATIVE                                       0
#define PDLM_UI_EXCLUSIVE                                         1
//****************************************************//************//
#define PDLM_LASER_UNLOCKED                                       0
#define PDLM_LASER_LOCKED                                         1
//****************************************************//************//
#define PDLM_LASER_MODE_CW                                        0
#define PDLM_LASER_MODE_PULSE                                     1
#define PDLM_LASER_MODE_BURST                                     2
//****************************************************//************//
#define PDLM_LDH_LINEAR_PULSE_TABLE                               0
#define PDLM_LDH_MAX_POWER_PULSE_TABLE                            1
//****************************************************//************//
#define PDLM_TRIGGER_INTERNAL                                     0
#define PDLM_TRIGGER_EXTERNAL_FALLING_EDGE                        1
#define PDLM_TRIGGER_EXTERNAL_RISING_EDGE                         2
//****************************************************//************//
#define PDLM_DISABLE                                              0
#define PDLM_ENABLE                                               1
//****************************************************//************//
#define PDLM_GATEIMP_10k_OHM                                      0
#define PDLM_GATEIMP_50_OHM                                       1
//****************************************************//************//
#define PDLM_TRIGGER_INTERNAL                                     0
#define PDLM_TRIGGER_EXTERNAL_FALLING_EDGE                        1
#define PDLM_TRIGGER_EXTERNAL_RISING_EDGE                         2
//****************************************************//************//
#define PDLM_DISABLE                                              0
#define PDLM_ENABLE                                               1
//****************************************************//************//
#define PDLM_GATEIMP_10k_OHM                                      0
#define PDLM_GATEIMP_50_OHM                                       1
//****************************************************//************//
#define PDLM_TEMPERATURESCALE_CELSIUS                             0
#define PDLM_TEMPERATURESCALE_FAHRENHEIT                          1
#define PDLM_TEMPERATURESCALE_KELVIN                              2
//****************************************************//************//
//
//
//***************************************************************************
//***  Table of laser head types (uint16_t)                               ***
//***************************************************************************
//
//****************************************************//************//************************************************************
#define LASER_TYPE_UNDEFINED                                 0x0000 //
#define LASER_TYPE_LDH                                       0x0010 // Laser diode
#define LASER_TYPE_LDH_FSL                                   0x0018 // Laser diode with Fast Switched Laser mode, implemented by fast gate
#define LASER_TYPE_LED                                       0x0020 // only LED emission (no laser!)
#define LASER_TYPE_TA_SHG                                    0x0030 // With tapered amplifier and second harmonic generation
#define LASER_TYPE_FIBER                                     0x0040 // Fiber
#define LASER_TYPE_FIBER_FSL                                 0x0048 // Fiber with Fast Switched Laser mode
#define LASER_TYPE_FA                                        0x0050 // Fiber amplifier
#define LASER_TYPE_FA_SHG                                    0x0060 // Fiber amplifier and second harmonic generation
#define LASER_TYPE_BRIDGE                                    0x00F0 // Brige for old generation laser heads
//****************************************************//************//************************************************************
//
//
//***************************************************************************
//***  Table of laser head feature bits                                   ***
//***    as needed in field Features of struct TLaserData                 ***
//***    and function "PDLM_GetLHFeatures", as well.                      ***
//***************************************************************************
//***  Notice, that there is another, unsaid, implicite feature,          ***
//***    which could be imagined as always "set",                         ***
//***    that could be called "PDLM_LHFEATURE_PULSE_CAPABILITY"           ***
//***************************************************************************
//
//****************************************************//************//************************************************************
#define PDLM_LHFEATURE_CW_CAPABILITY                     0x00000001 // set, if CW mode is supported
#define PDLM_LHFEATURE_PULSE_MAXPOWER                    0x00000002 // set, if laser head supports max. power mode
#define PDLM_LHFEATURE_BURST_CAPABILITY                  0x00000010 // set, if burst mode is supported
#define PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS       0x00000040 // set, if external triggering is supported in burst mode
#define PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_PULSES       0x00000080 // set, if external triggering is supported in pulse mode
#define PDLM_LHFEATURE_WL_TUNABLE                        0x00000100 // set, if thermal changes have influence on the wavelength
#define PDLM_LHFEATURE_COOLING_FAN                       0x00010000 // set, if the laser head has a build-in fan for cooling
#define PDLM_LHFEATURE_SWITCHABLE_FAN                    0x00020000 // set, if this fan is on/off switchable
#define PDLM_LHFEATURE_INTENSITY_SENSOR_TYPE             0x0F000000 // these four bits code the PQ type-ID of the intensity sensor
//****************************************************//************//************************************************************
//
//
//***************************************************************************
//***  Helpful character constants for (G)UIs                             ***
//***************************************************************************
//***  Notice, that some characters have to be adapted to the UI in use   ***
//***    see e.g. the greek letter mu, which could be coded as 0xB5, 0xE6 ***
//***    or even simply be "µ". The Same goes for the degree sign "°" and ***
//***    others. All these constants need to be carefully checked...      ***
//***************************************************************************
//
#define PREFIX_ZEROIDX                                          6
//
// char UNIT_PREFIX [10][2]   = { "a", "f", "p", "n", "µ", "m", "", "k", "M", "G" };
// char TEMPSCALE_UNITS[3][3] = { "°C", "°F", "K" };
//
// if this doesn't work, try that:
//
char UNIT_PREFIX [10][2]   = { "a", "f", "p", "n", "\xE6", "m", "", "k", "M", "G" };
char TEMPSCALE_UNITS[3][3] = { "\xF8""C", "\xF8""F", "K" };
//
