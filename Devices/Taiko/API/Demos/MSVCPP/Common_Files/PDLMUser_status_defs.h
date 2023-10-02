/*---------------------------------------------------------------------------*/
//
// PDLMUser_status_defs.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
#pragma once

//
//***************************************************************************
//*** Positions of the corresponding flag bits (enum type)                ***
//***************************************************************************
//

typedef enum _PDLM_DEVSTATE_IDX
{
  IDX_INITIALIZING                     =  0, // 0x00000001
  IDX_DEVICE_UNCALIBRATED              =  1, // 0x00000002
  IDX_COMMISSIONING_MODE               =  2, // 0x00000004
  IDX_LASERHEAD_SAFETY_MODE            =  3, // 0x00000008
  IDX_FW_UPDATE_RUNNING                =  4, // 0x00000010
  IDX_DEVICE_DEFECT                    =  5, // 0x00000020
  IDX_DEVICE_INCOMPATIBLE              =  6, // 0x00000040
  IDX_BUSY                             =  7, // 0x00000080
  IDX_EXCLUSIVE_SW_OP_GRANTED          =  8, // 0x00000100
  IDX_PARAMETER_CHANGES_PENDING        =  9, // 0x00000200
  // dummy3                            = 10,
  IDX_LASERHEAD_CHANGED                = 11, // 0x00000800
  IDX_LASERHEAD_MISSING                = 12, // 0x00001000
  IDX_LASERHEAD_DEFECT                 = 13, // 0x00002000
  IDX_LASERHEAD_UNKOWN_TYPE            = 14, // 0x00004000
  IDX_LASERHEAD_DECALIBRATED           = 15, // 0x00008000
  IDX_LASERHEAD_DIODE_TEMP_TOO_LOW     = 16, // 0x00010000
  IDX_LASERHEAD_DIODE_TEMP_TOO_HIGH    = 17, // 0x00020000
  IDX_LASERHEAD_DIODE_OVERHEATING      = 18, // 0x00040000
  IDX_LASERHEAD_CASE_OVERHEATING       = 19, // 0x00080000
  IDX_LASERHEAD_FAN_RUNNING            = 20, // 0x00100000
  IDX_LASERHEAD_INCOMPATIBLE           = 21, // 0x00200000
  IDX_LOCKED_BY_EXPIRED_DEMO_MODE      = 22, // 0x00400000
  IDX_LOCKED_BY_ON_OFF_BUTTON          = 23, // 0x00800000
  IDX_SOFTLOCK                         = 24, // 0x01000000
  IDX_KEYLOCK                          = 25, // 0x02000000
  IDX_LOCKED_BY_SECURITY_POLICY        = 26, // 0x04000000
  IDX_INTERLOCK                        = 27, // 0x08000000
  IDX_LASERHEAD_PULSE_POWER_INACCURATE = 28, // 0x10000000
  // dummy5                            = 29,
  // dummy5                            = 30,
  IDX_ERRORMSG_PENDING                 = 31  // 0x80000000
} PDLM_DEVSTATE_IDX;

// Structure that contains all the status bits
typedef __packed struct _T_PDLM_DEVSTATE_BS
{
  uint32_t Initializing            : 1;  // 0x00000001
  uint32_t DeviceUncalibrated      : 1;  // 0x00000002
  uint32_t CommissioningMode       : 1;  // 0x00000004
  uint32_t LH_SafetyMode           : 1;  // 0x00000008
  uint32_t FWUpdateRunning         : 1;  // 0x00000010
  uint32_t DeviceDefect            : 1;  // 0x00000020
  uint32_t DeviceIncompatible      : 1;  // 0x00000040
  uint32_t Busy                    : 1;  // 0x00000080
  uint32_t ExclusiveSWOpGranted    : 1;  // 0x00000100
  uint32_t ParameterChangesPending : 1;  // 0x00000200
  uint32_t : 1;  // 0x00000400
  uint32_t LH_Changed              : 1;  // 0x00000800
  uint32_t LH_Missing              : 1;  // 0x00001000
  uint32_t LH_Defect               : 1;  // 0x00002000
  uint32_t LH_UnkownType           : 1;  // 0x00004000
  uint32_t LH_Decalibrated         : 1;  // 0x00008000
  uint32_t LH_DiodeTempTooLow      : 1;  // 0x00010000
  uint32_t LH_DiodeTempTooHigh     : 1;  // 0x00020000
  uint32_t LH_DiodeOverheating     : 1;  // 0x00040000
  uint32_t LH_CaseOverheating      : 1;  // 0x00080000
  uint32_t LH_FanRunning           : 1;  // 0x00100000
  uint32_t LH_Incompatible         : 1;  // 0x00200000
  uint32_t LockedByExpiredDemoMode : 1;  // 0x00400000
  uint32_t LockedByOnOffButton     : 1;  // 0x00800000
  uint32_t SoftLock                : 1;  // 0x01000000
  uint32_t KeyLock                 : 1;  // 0x02000000
  uint32_t LockedBySecurityPolicy  : 1;  // 0x04000000
  uint32_t InterLock               : 1;  // 0x08000000
  uint32_t LH_PulsePowerInaccurate : 1;  // 0x10000000
  uint32_t : 1;  // 0x20000000
  uint32_t : 1;  // 0x40000000
  uint32_t ErrormsgPending         : 1;  // 0x80000000
} T_PDLM_DEVSTATE_BS;

typedef union _T_PDLM_DEVSTATE
{
  T_PDLM_DEVSTATE_BS bs;
  uint32_t           ui;
} T_PDLM_DEVSTATE;

//
//***************************************************************************
//*** Defines for all the status bits                                     ***
//***************************************************************************
//

#define PDLM_DEVSTATE_INITIALIZING                     (1 << IDX_INITIALIZING                    ) // 0x00000001 // Device is initializing during boot up
#define PDLM_DEVSTATE_DEVICE_UNCALIBRATED              (1 << IDX_DEVICE_UNCALIBRATED             ) // 0x00000002 // Device has no valid data in eeprom
#define PDLM_DEVSTATE_COMMISSIONING_MODE               (1 << IDX_COMMISSIONING_MODE              ) // 0x00000004 // During commissioning. All errors coming from device/laserhead are ignored
#define PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE            (1 << IDX_LASERHEAD_SAFETY_MODE           ) // 0x00000008 // Laser head safety mode
#define PDLM_DEVSTATE_FW_UPDATE_RUNNING                (1 << IDX_FW_UPDATE_RUNNING               ) // 0x00000010 // During firmware update
#define PDLM_DEVSTATE_DEVICE_DEFECT                    (1 << IDX_DEVICE_DEFECT                   ) // 0x00000020 // At least one Part of the device hardware is defect
#define PDLM_DEVSTATE_DEVICE_INCOMPATIBLE              (1 << IDX_DEVICE_INCOMPATIBLE             ) // 0x00000040 // The firmware cannot control the read device version
#define PDLM_DEVSTATE_BUSY                             (1 << IDX_BUSY                            ) // 0x00000080 // Device is busy during costly calculations, etc
#define PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED          (1 << IDX_EXCLUSIVE_SW_OP_GRANTED         ) // 0x00000100 // Only the host software can manipulate the device
#define PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING        (1 << IDX_PARAMETER_CHANGES_PENDING       ) // 0x00000200 // At least one parameter of the device has changed
#define PDLM_DEVSTATE_LASERHEAD_CHANGED                (1 << IDX_LASERHEAD_CHANGED               ) // 0x00000800 // When a new laser head was connected
#define PDLM_DEVSTATE_LASERHEAD_MISSING                (1 << IDX_LASERHEAD_MISSING               ) // 0x00001000 // No laser head connected
#define PDLM_DEVSTATE_LASERHEAD_DEFECT                 (1 << IDX_LASERHEAD_DEFECT                ) // 0x00002000 // Laser head defect
#define PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE           (1 << IDX_LASERHEAD_UNKOWN_TYPE           ) // 0x00004000 // The laser type cannot be controlled by the laser driver
#define PDLM_DEVSTATE_LASERHEAD_DECALIBRATED           (1 << IDX_LASERHEAD_DECALIBRATED          ) // 0x00008000 // Calibration time of laser head expired
#define PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_LOW     (1 << IDX_LASERHEAD_DIODE_TEMP_TOO_LOW    ) // 0x00010000 // Laser head temperature is below set point
#define PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_HIGH    (1 << IDX_LASERHEAD_DIODE_TEMP_TOO_HIGH   ) // 0x00020000 // Laser head temperature is above set point
#define PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING      (1 << IDX_LASERHEAD_DIODE_OVERHEATING     ) // 0x00040000 // Laser head diode overheated
#define PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING       (1 << IDX_LASERHEAD_CASE_OVERHEATING      ) // 0x00080000 // Laser head case overheated
#define PDLM_DEVSTATE_LASERHEAD_FAN_RUNNING            (1 << IDX_LASERHEAD_FAN_RUNNING           ) // 0x00100000 // Laser head fan is running
#define PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE           (1 << IDX_LASERHEAD_INCOMPATIBLE          ) // 0x00200000 // The firmware cannot control the laser version read
#define PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE      (1 << IDX_LOCKED_BY_EXPIRED_DEMO_MODE     ) // 0x00400000 // Laser will be locked when demo mode expired
#define PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON          (1 << IDX_LOCKED_BY_ON_OFF_BUTTON         ) // 0x00800000 // Laser is off by On/Off button
#define PDLM_DEVSTATE_SOFTLOCK                         (1 << IDX_SOFTLOCK                        ) // 0x01000000 // Laser is off by host software
#define PDLM_DEVSTATE_KEYLOCK                          (1 << IDX_KEYLOCK                         ) // 0x02000000 // Laser is off by keylock
#define PDLM_DEVSTATE_LOCKED_BY_SECURITY_POLICY        (1 << IDX_LOCKED_BY_SECURITY_POLICY       ) // 0x04000000 // Laser Class IV - Rules
#define PDLM_DEVSTATE_INTERLOCK                        (1 << IDX_INTERLOCK                       ) // 0x08000000 // Laser is off because interlock is unplugged
#define PDLM_DEVSTATE_LASERHEAD_PULSE_POWER_INACCURATE (1 << IDX_LASERHEAD_PULSE_POWER_INACCURATE) // 0x10000000 // Laser temperature differs from what it was calibrated to
#define PDLM_DEVSTATE_ERRORMSG_PENDING                 (1 << IDX_ERRORMSG_PENDING                ) // 0x80000000 // Error message pending in error queue, not laser head related



//
//***************************************************************************
//*** Table of useful status masks                                        ***
//*** (i.e. semantic goups of more than one status bit)                   ***
//*** with their associated conditions for notification                   ***
//***************************************************************************
//

//****************************************************//************//************************************************************
// States / StateMasks                                // bitpattern // results on changes
//****************************************************//************//************************************************************
//                                                    //            //
#define PDLM_DEVSTATEMASK_DEVICE_NOT_OPERATIONAL         0x00000071 // fires notification  "WM_ON_DEVICE_NOT_OPERATIONAL_CHANGE"
// = ( PDLM_DEVSTATE_INITIALIZING                     //            //   if changing from   0  to (>0)
//   | PDLM_DEVSTATE_FW_UPDATE_RUNNING                //            //   or          from (>0) to   0
//   | PDLM_DEVSTATE_DEVICE_DEFECT                    //            //   but not     from (>0) to another value (>0)
//   | PDLM_DEVSTATE_DEVICE_INCOMPATIBLE              //            //
//   )                                                //            //
//                                                    //            //
//     PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED          // 0x00000100 // fires notification  "WM_ON_EXCLUSIVE_UI_CHANGE"
//                                                    //            //   on any change
//                                                    //            //
//     PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING        // 0x00000200 // fires notification  "WM_ON_PARAMETER_CHANGE"
//                                                    //            //   if changing from   0  to (>0)
//                                                    //            //
//     PDLM_DEVSTATE_LASERHEAD_CHANGED                // 0x00000800 // fires notification  "WM_ON_LASERHEAD_CHANGE"
//                                                    //            //   if changing from   0  to (>0)
//                                                    //            //
#define PDLM_DEVSTATEMASK_LASER_NOT_OPERATIONAL          0x002C7008 // fires notification  "WM_ON_LASER_NOT_OPERATIONAL_CHANGE"
// = ( PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE            //            //   if changing from   0  to (>0)
//   | PDLM_DEVSTATE_LASERHEAD_MISSING                //            //   or          from (>0) to   0
//   | PDLM_DEVSTATE_LASERHEAD_DEFECT                 //            //   but not     from (>0) to another value (>0)
//   | PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE           //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING      //            //
//   | PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING       //            //
//   | PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE           //            //
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_LOCKED                         0x0FC00000 // fires notification  "WM_ON_LOCKING_CHANGE"
// = ( PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE      //            //   on any change
//   | PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON          //            //
//   | PDLM_DEVSTATE_SOFTLOCK                         //            //
//   | PDLM_DEVSTATE_KEYLOCK                          //            //
//   | PDLM_DEVSTATE_LOCKED_BY_SECURITY_POLICY        //            //
//   | PDLM_DEVSTATE_INTERLOCK                        //            //
//   )                                                //            //
//                                                    //            //
//     PDLM_DEVSTATE_ERRORMSG_PENDING                 // 0x80000000 // fires notification  "WM_ON_PENDING_ERRORS"
//                                                    //            //   if changing from   0  to (>0)
//                                                    //            //
#define PDLM_DEVSTATEMASK_WARNINGS_ONLY                  0x10008002 // a notification will be fired together with other flags,
// = ( PDLM_DEVSTATE_DEVICE_UNCALIBRATED              //            //   see below: PDLM_DEVSTATEMASK_ALL_WARNINGS
//   | PDLM_DEVSTATE_LASERHEAD_DECALIBRATED           //            //
//   | PDLM_DEVSTATE_LASERHEAD_PULSE_POWER_INACCURATE //            //
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_UNHANDLED                      0x00130084 // fires notification  "WM_ON_OTHER_STATES_CHANGE"
// = ( PDLM_DEVSTATE_COMMISSIONING_MODE               //            //   on any change
//   | PDLM_DEVSTATE_BUSY                             //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_LOW     //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_HIGH    //            //
//   | PDLM_DEVSTATE_LASERHEAD_FAN_RUNNING            //            //
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_ILLEGAL_STATES                 0x60000400 // these state flags (unused dummys) are always ignored
//                                                    //            //
//****************************************************//************//************************************************************
//                                                    // 0xFFFFFFFF //
//****************************************************//************//************************************************************
//                                                    //            //
// additional status masks (for warnings)             //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_ALL_WARNINGS                   0x106CE07E // fires notification  "WM_ON_WARNINGS_CHANGE"
// = ( PDLM_DEVSTATE_DEVICE_UNCALIBRATED              //            //   on any change; All Flags produce "!"-Warnings, except of:
//   | PDLM_DEVSTATE_COMMISSIONING_MODE               //            //
//   | PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE            //            //
//   | PDLM_DEVSTATE_FW_UPDATE_RUNNING                //            //
//   | PDLM_DEVSTATE_DEVICE_DEFECT                    //            //
//   | PDLM_DEVSTATE_DEVICE_INCOMPATIBLE              //            //
//   | PDLM_DEVSTATE_LASERHEAD_DEFECT                 //            //
//   | PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE           //            //
//   | PDLM_DEVSTATE_LASERHEAD_DECALIBRATED           //            // this one produces a LH-"C"-Warning
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING      //            //
//   | PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING       //            //
//   | PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE           //            //
//   | PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE      //            //
//   | PDLM_DEVSTATE_LASERHEAD_PULSE_POWER_INACCURATE //            // this one produces a LH-"i"-Warning
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_DEVICE_WARNINGS                0x00000076 // these produce all Dev-"!"-Warnings
// = ( PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED           //            //
//   | PDLM_DEVSTATE_COMMISSIONING_MODE               //            //
//   | PDLM_DEVSTATE_FW_UPDATE_RUNNING                //            //
//   | PDLM_DEVSTATE_DEVICE_DEFECT                    //            //
//   | PDLM_DEVSTATE_DEVICE_INCOMPATIBLE              //            //
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_LASER_WARNINGS                 0x006C6008 // these produce all LH-"!"-Warnings
// = ( PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE            //            //
//   | PDLM_DEVSTATE_LASERHEAD_DEFECT                 //            //
//   | PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE           //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING      //            //
//   | PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING       //            //
//   | PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE           //            //
//   | PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE      //            //
//   )                                                //            //
//                                                    //            //
#define PDLM_DEVSTATEMASK_LASERHEAD_STATUS_FLAGS         0x047FE808 // if a laser head is disconnected, all laser head related 
// = ( PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE            //            //   flags are reset, besides PDLM_DEVSTATE_LASERHEAD_MISSING
//   | PDLM_DEVSTATE_LASERHEAD_CHANGED                //            //
//   | PDLM_DEVSTATE_LASERHEAD_DEFECT                 //            //
//   | PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE           //            //
//   | PDLM_DEVSTATE_LASERHEAD_DECALIBRATED           //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_LOW     //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_HIGH    //            //
//   | PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING      //            //
//   | PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING       //            //
//   | PDLM_DEVSTATE_LASERHEAD_FAN_RUNNING            //            //
//   | PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE           //            //
//   | PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE      //            //
//   | PDLM_DEVSTATE_LOCKED_BY_SECURITY_POLICY        //            //
//   )                                                //            //
//                                                    //            //
//****************************************************//************//************************************************************
