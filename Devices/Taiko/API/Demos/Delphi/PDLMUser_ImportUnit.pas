//-----------------------------------------------------------------------------
//
//      PDLMUser_ImportUnit.pas
//
//-----------------------------------------------------------------------------
//
//  Imports the  PLD M1 "Taiko"  functions from PDLM_Lib.dll  V2.0.<xx>.<nnn>
//    <xx>  = 32: PDLM_Lib for x86 target architecture;
//    <xx>  = 64: PDLM_Lib for x64 target architecture;
//    <nnn> = SVN build number
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  09.09.18   first released for V1.0.<xx>
//  apo  24.09.19   released for V2.0.<xx>
//
//-----------------------------------------------------------------------------
//
unit PDLMUser_ImportUnit;

interface

uses
  WinApi.Windows, WinApi.Messages,
  System.UITypes, System.SysUtils, System.Classes, System.Math,
  PDLMUser_ErrorCodes, PDLMUser_TagsUnit;

  const
    STR_LIB_NAME                                = 'PDLM_Lib.dll';
    LIB_VERSION_REFERENCE                       =    '2.1.';        // minor low word (SVN-build) may be ignored
    LIB_VERSION_COMPLEN                         =         4;

    FW_VERSION_REFERENCE                        =    '2.1.';
    FW_VERSION_COMPLEN                          =         4;

    MILLISECONDS_PER_DAY                        =  86400000;
    SECONDS_PER_DAY                             =     86400;
    DAC_12bit_MAXVALUE                          =      4095;

    PDLM_SUPREQ_OPT_NO_PREAMBLE                 = $00000001;        // option parameters for PDLM_CreateSupportRequestText
    PDLM_SUPREQ_OPT_NO_TITLE                    = $00000002;
    PDLM_SUPREQ_OPT_NO_CALLING_SW_INDENT        = $00000004;
    PDLM_SUPREQ_OPT_NO_SYSTEM_INFO              = $00000008;
    //

    WM_PDLM_BASE                                = Cardinal ($1200);              // i.e (PRODID_THOR shl 8), which is definitively > WM_USER
    //
    WM_ON_PENDING_ERRORS                        = Cardinal (WM_PDLM_BASE + $01); // on 0->1 PDLM_DEVSTATE_ERRORMSG_PENDING
    WM_ON_LOCKING_CHANGE                        = Cardinal (WM_PDLM_BASE + $02); // on any  PDLM_DEVSTATEMASK_LOCKED
    WM_ON_LASERHEAD_CHANGE                      = Cardinal (WM_PDLM_BASE + $03); // on 0->1 PDLM_DEVSTATE_LASERHEAD_CHANGED
    WM_ON_LASER_NOT_OPERATIONAL_CHANGE          = Cardinal (WM_PDLM_BASE + $04); // on 0->1 or 1->0 PDLM_DEVSTATEMASK_LASER_NOT_OPERATIONAL
    WM_ON_DEVICE_NOT_OPERATIONAL_CHANGE         = Cardinal (WM_PDLM_BASE + $05); // on 0->1 or 1->0 PDLM_DEVSTATEMASK_DEVICE_NOT_OPERATIONAL
    WM_ON_PARAMETER_CHANGE                      = Cardinal (WM_PDLM_BASE + $07); // on 0->1 PDLM_DEVSTATEMASK_PARAMCHANGES
    WM_ON_EXCLUSIVE_UI_CHANGE                   = Cardinal (WM_PDLM_BASE + $08); // on any  PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED
    WM_ON_WARNINGS_CHANGE                       = Cardinal (WM_PDLM_BASE + $09); // on 0->1 or 1->0 PDLM_DEVSTATEMASK_WARNINGS
    WM_ON_OTHER_STATES_CHANGE                   = Cardinal (WM_PDLM_BASE + $FF); // on any  other changes


    PDLM_MAX_USB_DEVICES                        =         8;

    PDLM_USB_STRDESCR_LEN                       =       255;
    PDLM_ERRSTRING_MAXLEN                       =        47;
    PDLM_HW_INFO_MAXLEN                         =        36;
    PDLM_PRODUCT_MAXLEN                         =        32;
    PQUSB_SERIAL_MAXLEN                         =        12;
    PDLM_SERIAL_MAXLEN                          =         8;
    PDLM_FW_VERSIONINFO_LEN                     =         8;

    PDLM_TIMER_MAXCOUNT                         =         1;

    PDLM_UI_COOPERATIVE                         =         0;
    PDLM_UI_EXCLUSIVE                           =         1;

    PDLM_LASER_UNLOCKED                         =         0;
    PDLM_LASER_LOCKED                           =         1;

    PDLM_SOFTLOCK_UNLOCKED                      =         0;
    PDLM_SOFTLOCK_LOCKED                        =         1;

    PDLM_GATE_DISABLED                          =         0;
    PDLM_GATE_ENABLED                           =         1;
    PDLM_GATEIMP_10k_OHM                        =         0;
    PDLM_GATEIMP_50_OHM                         =         1;

    PDLM_BUZZERTONE_OFF                         =         0;
    PDLM_BUZZERTONE_ON                          =         1;

    PDLM_LHEADFAN_OFF                           =         0;
    PDLM_LHEADFAN_ON                            =         1;

    PDLM_PRESETS_MAXCOUNT                       =         9;
    PDLM_PRESETINFO_MAXLEN                      =       255;

    PDLM_FREQUENCY_MIN                          =         1;
    PDLM_FREQUENCY_MAX                          = 100000000;

  type
    {$MINENUMSIZE 4}
    T_LaserMode                                 = (PDLM_LASERMODE_UNASSIGNED=-1, PDLM_LASERMODE_CW, PDLM_LASERMODE_PULSE, PDLM_LASERMODE_BURST);
    T_TriggerSource                             = (PDLM_TRIGGERSOURCE_INTERNAL, PDLM_TRIGGERSOURCE_EXTERNAL_FALLING_EDGE, PDLM_TRIGGERSOURCE_EXTERNAL_RISING_EDGE);

    T_TempScale                                 = (PDLM_TEMPSCALE_CELSIUS, PDLM_TEMPSCALE_FAHRENHEIT, PDLM_TEMPSCALE_KELVIN);

  const
    PDLM_TEMPSCALE_UNITS                        : array [T_TempScale] of string = ('°C', '°F', 'K ');

  type
    // Statusbits (Abfrage mit der Funktion PDLM_GetSystemStatus)
    //
    T_PDLM_DEVSTATE_IDX = (
      PDLM_DEVSTATEIDX_INITIALIZING                     =  0, // 0x00000001
      PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED              =  1, // 0x00000002
      PDLM_DEVSTATEIDX_COMMISSIONING_MODE               =  2, // 0x00000004
      PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE            =  3, // 0x00000008
      PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING                =  4, // 0x00000010
      PDLM_DEVSTATEIDX_DEVICE_DEFECT                    =  5, // 0x00000020
      PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE              =  6, // 0x00000040
      PDLM_DEVSTATEIDX_BUSY                             =  7, // 0x00000080
      PDLM_DEVSTATEIDX_EXCLUSIVE_SW_OP_GRANTED          =  8, // 0x00000100
      PDLM_DEVSTATEIDX_PARAMETER_CHANGES_PENDING        =  9, // 0x00000200
      PDLM_DEVSTATEIDX_ILLEGAL_10                       = 10,
      PDLM_DEVSTATEIDX_LASERHEAD_CHANGED                = 11, // 0x00000800
      PDLM_DEVSTATEIDX_LASERHEAD_MISSING                = 12, // 0x00001000
      PDLM_DEVSTATEIDX_LASERHEAD_DEFECT                 = 13, // 0x00002000
      PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE           = 14, // 0x00004000
      PDLM_DEVSTATEIDX_LASERHEAD_DECALIBRATED           = 15, // 0x00008000
      PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_LOW     = 16, // 0x00010000
      PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_HIGH    = 17, // 0x00020000
      PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED       = 18, // 0x00040000
      PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED        = 19, // 0x00080000
      PDLM_DEVSTATEIDX_LASERHEAD_FAN_RUNNING            = 20, // 0x00100000
      PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE           = 21, // 0x00200000
      PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE      = 22, // 0x00400000
      PDLM_DEVSTATEIDX_LOCKED_BY_ON_OFF_BUTTON          = 23, // 0x00800000
      PDLM_DEVSTATEIDX_SOFTLOCK                         = 24, // 0x01000000
      PDLM_DEVSTATEIDX_KEYLOCK                          = 25, // 0x02000000
      PDLM_DEVSTATEIDX_LOCKED_BY_SECURITY_POLICY        = 26, // 0x04000000
      PDLM_DEVSTATEIDX_INTERLOCK                        = 27, // 0x08000000
      PDLM_DEVSTATEIDX_LASERHEAD_PULSE_POWER_INACCURATE = 28, // 0x10000000
      PDLM_DEVSTATEIDX_ILLEGAL_29                       = 29,
      PDLM_DEVSTATEIDX_ILLEGAL_30                       = 30,
      PDLM_DEVSTATEIDX_ERRORMSG_PENDING                 = 31  // 0x80000000
    );

    T_PDLM_DEVSTATE_BS = set of T_PDLM_DEVSTATE_IDX;

    T_PDLM_DEVSTATE = record
      case integer of
        0:  (bs: T_PDLM_DEVSTATE_BS;);
        1:  (ui: Cardinal;);
        2:  (li: integer;);
    end;

    {$MINENUMSIZE 4}
  const
    //T_PDLM_DEVSTATES                                                                                                 // state val:  // handled by:
    PDLM_DEVSTATE_INITIALIZING                      =  1 shl ord (PDLM_DEVSTATEIDX_INITIALIZING);                      // $00000001,  // DEVICE_NOT_OPERATIONAL     während des Hochfahrens
    PDLM_DEVSTATE_DEVICE_UNCALIBRATED               =  1 shl ord (PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED);               // $00000002,  // DEVICE_NOT_OPERATIONAL     während der Einmessung nach dem Hochfahren
    PDLM_DEVSTATE_COMMISSIONING_MODE                =  1 shl ord (PDLM_DEVSTATEIDX_COMMISSIONING_MODE);                // $00000004,  // OTHER_STATES               zum Abschalten einiger Sicherheitssperren der FW während des Einmessens
    PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE             =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE);             // $00000008,  // LASER_NOT_OPERATIONAL      Schutzzustand bei Fehlersituation des Laserkopfes (Abziehen/Anstecken heilt u.U.)
    PDLM_DEVSTATE_FW_UPDATE_RUNNING                 =  1 shl ord (PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING);                 // $00000010,  // DEVICE_NOT_OPERATIONAL     nur Update-Datenblöcke werden akzeptiert
    PDLM_DEVSTATE_DEVICE_DEFECT                     =  1 shl ord (PDLM_DEVSTATEIDX_DEVICE_DEFECT);                     // $00000020,  // DEVICE_NOT_OPERATIONAL     Device defect;
    PDLM_DEVSTATE_DEVICE_INCOMPATIBLE               =  1 shl ord (PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE);               // $00000040,  // DEVICE_NOT_OPERATIONAL     Device incompatible, nur update und commissioning commands erlaubt
    PDLM_DEVSTATE_BUSY                              =  1 shl ord (PDLM_DEVSTATEIDX_BUSY);                              // $00000080,  // DEVICE_NOT_OPERATIONAL     Gerät ist von anderer SW geblockt oder beschäftigt
    PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED           =  1 shl ord (PDLM_DEVSTATEIDX_EXCLUSIVE_SW_OP_GRANTED);           // $00000100,  // EXCLUSIVE_UI_CHANGE        wenn eine SW exklusiven Zugriff hat / manuelle Changes am Device nicht möglich
    PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING         =  1 shl ord (PDLM_DEVSTATEIDX_PARAMETER_CHANGES_PENDING);         // $00000200,  // PARAMETER_CHANGE           während eine SW Zugriff hat, änderte sich ein Parameter (durch manuellen od. automatischen Eingriff)
    PDLM_DEVSTATE_ILLEGAL_10                        =  1 shl ord (PDLM_DEVSTATEIDX_ILLEGAL_10);                        // $00000400,  // - ILLEGAL                  wird ignoriert
    PDLM_DEVSTATE_LASERHEAD_CHANGED                 =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_CHANGED);                 // $00000800,  // LASERHEAD_CHANGE           der neu angesteckte Laserkopf ist ein anderer als der letzte zuvor
    PDLM_DEVSTATE_LASERHEAD_MISSING                 =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_MISSING);                 // $00001000,  // LASER_NOT_OPERATIONAL      wenn der Laserkopf völlig fehlt oder nicht erkannt wird
    PDLM_DEVSTATE_LASERHEAD_DEFECT                  =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_DEFECT);                  // $00002000,  // LASER_NOT_OPERATIONAL      wenn der Laserkopf als schadhaft erkannt wird
    PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE            =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE);            // $00004000,  // LASER_NOT_OPERATIONAL      unbekannter Laserkopf Typ
    PDLM_DEVSTATE_LASERHEAD_DECALIBRATED            =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_DECALIBRATED);            // $00008000,  // LASER_NOT_OPERATIONAL      wenn der Laserkopf dekalibriert ist
    PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_LOW      =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_LOW);      // $00010000,  // OTHER_STATES               Temperatur der Diode liegt unter dem gewünschten Wert
    PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_HIGH     =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_HIGH);     // $00020000,  // OTHER_STATES               Temperatur der Diode liegt über dem gewünschten Wert
    PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATED        =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED);        // $00040000,  // LASER_NOT_OPERATIONAL      Temperatur der Diode liegt über der Abschaltschwelle
    PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATED         =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED);         // $00080000,  // LASER_NOT_OPERATIONAL      Temperatur des Lasergehäuses liegt über der Abschaltschwelle
    PDLM_DEVSTATE_LASERHEAD_FAN_RUNNING             =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_FAN_RUNNING);             // $00100000,  // OTHER_STATES               Lüfterkühlung des Laserkopfes in Betrieb
    PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE            =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE);            // $00200000,  // LASER_NOT_OPERATIONAL      Laserkopf inkompatibel mit firmware
    PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE       =  1 shl ord (PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE);       // $00400000,  // LOCKING_CHANGE             wenn der Laserkopf als Demo-Gerät verliehen wurde und die Demo-Zeit abgelaufen ist
    PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON           =  1 shl ord (PDLM_DEVSTATEIDX_LOCKED_BY_ON_OFF_BUTTON);           // $00800000,  // LOCKING_CHANGE             wenn der Laserkopf betriebsbereit ist und der On/Off Knopf gedrückt wurde
    PDLM_DEVSTATE_SOFTLOCK                          =  1 shl ord (PDLM_DEVSTATEIDX_SOFTLOCK);                          // $01000000,  // LOCKING_CHANGE             wenn die Softlock-Funktion gesetzt wurde
    PDLM_DEVSTATE_KEYLOCK                           =  1 shl ord (PDLM_DEVSTATEIDX_KEYLOCK);                           // $02000000,  // LOCKING_CHANGE             wenn der Schlüsselschalter auf StdBy steht
    PDLM_DEVSTATE_LOCKED_BY_SECURITY_POLICY         =  1 shl ord (PDLM_DEVSTATEIDX_LOCKED_BY_SECURITY_POLICY);         // $04000000,  // LOCKING_CHANGE             wenn ein Class IV Laser angesteckt wurde und der Schlüsselschalter noch nicht betätigt wurde
    PDLM_DEVSTATE_INTERLOCK                         =  1 shl ord (PDLM_DEVSTATEIDX_INTERLOCK);                         // $08000000,  // LOCKING_CHANGE             wenn der Interlock-Kreis geöffnet wurde (Sicherheits- und Schutzschalter)
    PDLM_DEVSTATE_LASERHEAD_PULSE_POWER_INACCURATE  =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_PULSE_POWER_INACCURATE);  // $10000000,  // OTHER_STATES               wenn z.B. eine andere als die Temperatur, bei der kalibriert wurde, eingestellt ist
    PDLM_DEVSTATE_ILLEGAL_29                        =  1 shl ord (PDLM_DEVSTATEIDX_ILLEGAL_29);                        // $20000000,  // - ILLEGAL                  wird ignoriert
    PDLM_DEVSTATE_ILLEGAL_30                        =  1 shl ord (PDLM_DEVSTATEIDX_ILLEGAL_30);                        // $40000000,  // - ILLEGAL                  wird ignoriert
    PDLM_DEVSTATE_ERRORMSG_PENDING                  =  1 shl ord (PDLM_DEVSTATEIDX_ERRORMSG_PENDING);                  // $80000000   // PENDING_ERRORS             wenn HW-Error aufgetreten ist / sind; können mit Fkt. "PDLM_GetQueuedError" abgefragt werden


  const

  //PDLM_DEVSTATE_ERRORMSG_PENDING                                                                             // $80000000   // handled by  WM_ON_PENDING_ERRORS_CHANGE

  //PDLM_DEVSTATE_BS_WARNINGS_ONLY                                                                             // $10008002   // no own message; handled together with other flags
    PDLM_DEVSTATE_BS_WARNINGS_ONLY              : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DECALIBRATED,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_PULSE_POWER_INACCURATE ];

  //PDLM_DEVSTATE_BS_ILLEGAL_STATES                                                                            // $60000400;  // no own message, state flags neither assigned nor handled
    PDLM_DEVSTATE_BS_ILLEGAL_STATES             : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_ILLEGAL_10,
                                                                         PDLM_DEVSTATEIDX_ILLEGAL_29,
                                                                         PDLM_DEVSTATEIDX_ILLEGAL_30 ];

    PDLM_DEVSTATE_BS_LOCKED_EXCL_ON_OFF_BTN     : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_INTERLOCK,
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_SECURITY_POLICY,
                                                                         PDLM_DEVSTATEIDX_KEYLOCK,
                                                                         PDLM_DEVSTATEIDX_SOFTLOCK,
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE ];

  //PDLM_DEVSTATE_BS_LOCKED                                                                                    // $0FC00000   // handled by  WM_ON_LOCKING_CHANGE
    PDLM_DEVSTATE_BS_LOCKED                     : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_INTERLOCK,
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_SECURITY_POLICY,
                                                                         PDLM_DEVSTATEIDX_KEYLOCK,
                                                                         PDLM_DEVSTATEIDX_SOFTLOCK,
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_ON_OFF_BUTTON,
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE ];


  //PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL                                                                     // $002CF008   // handled by  WM_ON_LASER_NOT_OPERATIONAL_CHANGE
    PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL      : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DEFECT,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_MISSING,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE ];

  //PDLM_DEVSTATE_LASERHEAD_CHANGED             =  1 shl ord (PDLM_DEVSTATEIDX_LASERHEAD_CHANGED);             // $00000800   // handled by  WM_ON_LASERHEAD_CHANGE
  //PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING     =  1 shl ord (PDLM_DEVSTATEIDX_PARAMETER_CHANGES_PENDING);     // $00000200   // handled by  WM_ON_PARAMETER_CHANGE
  //PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED       =  1 shl ord (PDLM_DEVSTATEIDX_EXCLUSIVE_SW_OP_GRANTED);       // $00000100   // handled by  WM_ON_EXCLUSIVE_UI_CHANGE

  //PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL                                                                    // $00000071   // handled by  WM_ON_DEVICE_NOT_OPERATIONAL_CHANGE
    PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL     : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE,
                                                                         PDLM_DEVSTATEIDX_DEVICE_DEFECT,
                                                                         PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING,
                                                                         PDLM_DEVSTATEIDX_INITIALIZING ];

  //PDLM_DEVSTATE_BS_OTHER_STATES                                                                              // $00130084   // handled by  WM_ON_OTHER_STATES_CHANGE
    PDLM_DEVSTATE_BS_OTHER_STATES               : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_LASERHEAD_FAN_RUNNING,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_HIGH,
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_LOW,
                                                                         PDLM_DEVSTATEIDX_BUSY,
                                                                         PDLM_DEVSTATEIDX_COMMISSIONING_MODE ];

  //                                                                                                           // __________  //
  //                                                                                                           // $FFFFFFFF   //


  //PDLM_DEVSTATE_BS_ALL_WARNINGS                                                                              // $xxxxxxxx   // non destructivly handled by  WM_ON_WARNINGS_CHANGE
    PDLM_DEVSTATE_BS_ALL_WARNINGS               : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED,                // PDLM_DEVSTATE_BS_WARNINGS_ONLY
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DECALIBRATED,             // PDLM_DEVSTATE_BS_WARNINGS_ONLY
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_PULSE_POWER_INACCURATE,   // PDLM_DEVSTATE_BS_WARNINGS_ONLY
                                                                         //                                                   //
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE,             // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED,          // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED,         // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE,             // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DEFECT,                   // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE,              // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         //                                                   //
                                                                         PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE,                // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         PDLM_DEVSTATEIDX_DEVICE_DEFECT,                      // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING,                  // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         //                                                   //
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE,        // additionally
                                                                         PDLM_DEVSTATEIDX_COMMISSIONING_MODE ];               // additionally

    PDLM_DEVSTATE_BS_DEVICE_WARNINGS            : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED,                // PDLM_DEVSTATE_BS_WARNINGS_ONLY
                                                                         PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE,                // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         PDLM_DEVSTATEIDX_DEVICE_DEFECT,                      // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING,                  // PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL  - PDLM_DEVSTATEIDX_INITIALIZING
                                                                         PDLM_DEVSTATEIDX_COMMISSIONING_MODE ];               // additionally

    PDLM_DEVSTATE_BS_LASER_WARNINGS             : T_PDLM_DEVSTATE_BS = [ PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE,             // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED,          // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED,         // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE,             // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_DEFECT,                   // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE,              // PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL   - PDLM_DEVSTATEIDX_LASERHEAD_MISSING
                                                                         PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE ];      // additionally

  type
    {$MINENUMSIZE 4}
  //
    T_DeviceState = record
    private
      FState : T_PDLM_DEVSTATE;
      //
      function GetInitializing : boolean;
      function GetUncalibrated : boolean;
      function GetCommisioning : boolean;
      function GetLHSafetyMode : boolean;
      //
      function GetFWUpdateRunning : boolean;
      function GetDeviceDefect : boolean;
      function GetDeviceIncompatible : boolean;
      function GetBusy : boolean;
      //
      function GetExclusive : boolean;
      function GetParamChanges : boolean;
      // dummy
      function GetLHChanged : boolean;
      //
      function GetLHMissing : boolean;
      function GetLHDefect : boolean;
      function GetLHUnknownType : boolean;
      function GetLHDecalibrated : boolean;
      //
      function GetLHDiodeTempTooLow : boolean;
      function GetLHDiodeTempTooHigh : boolean;
      function GetLHDiodeOverheated : boolean;
      function GetLHCaseOverheated : boolean;
      //
      function GetLHFanRunning : boolean;
      function GetLHIncompatible : boolean;
      function GetExpiredDemoMode : boolean;
      function GetOnOffButton : boolean;
      //
      function GetSoftLocked : boolean;
      function GetKeyLocked : boolean;
      function GetSecurityPolicy : boolean;
      function GetInterLocked : boolean;
      //
      function GetPulsPowerInaccurate : boolean;
      // dummy, dummy
      function GetErrormsgPending : boolean;
      //
      // groups
      //
      function GetDeviceNotOperational : boolean;
      function GetLaserNotOperational : boolean;
      function GetLaserLocked : boolean;
      function GetLaserLockedExclOnOff : boolean;
      function GetWarningsOnly : boolean;
      function GetAllWarnings : boolean;
      function GetDeviceWarnings : boolean;
      function GetLaserWarnings : boolean;
      function GetOtherStates : boolean;
      //
    public
      property ui                          : Cardinal           read FState.ui write FState.ui;
      property bs                          : T_PDLM_DEVSTATE_BS read FState.bs write FState.bs;
      //
      property Initializing                : boolean  read GetInitializing;
      property Uncalibrated                : boolean  read GetUncalibrated;
      property CommissioningMode           : boolean  read GetCommisioning;
      property LH_SafetyMode               : boolean  read GetLHSafetyMode;
      property FWUpdateRunning             : boolean  read GetFWUpdateRunning;
      property DeviceDefect                : boolean  read GetDeviceDefect;
      property DeviceIncompatible          : boolean  read GetDeviceIncompatible;
      property Busy                        : boolean  read GetBusy;
      property ExclusiveSWOpGranted        : boolean  read GetExclusive;
      property ParameterChangesPending     : boolean  read GetParamChanges;
      property LH_Changed                  : boolean  read GetLHChanged;
      property LH_Missing                  : boolean  read GetLHMissing;
      property LH_Defect                   : boolean  read GetLHDefect;
      property LH_UnknownType              : boolean  read GetLHUnknownType;
      property LH_Decalibrated             : boolean  read GetLHDecalibrated;
      property LH_DiodeTempTooLow          : boolean  read GetLHDiodeTempTooLow;
      property LH_DiodeTempTooHigh         : boolean  read GetLHDiodeTempTooHigh;
      property LH_DiodeOverheated          : boolean  read GetLHDiodeOverheated;
      property LH_CaseOverheated           : boolean  read GetLHCaseOverheated;
      property LH_FanRunning               : boolean  read GetLHFanRunning;
      property LH_Incompatible             : boolean  read GetLHIncompatible;
      property LockedByExpiredDemoMode     : boolean  read GetExpiredDemoMode;
      property LockedByOnOffButton         : boolean  read GetOnOffButton;
      property SoftLocked                  : boolean  read GetSoftLocked;
      property KeyLocked                   : boolean  read GetKeyLocked;
      property LockedBySecurityPolicy      : boolean  read GetSecurityPolicy;
      property InterLocked                 : boolean  read GetInterLocked;
      Property PulsPowerInaccurate         : boolean  read GetPulsPowerInaccurate;
      property ErrormsgPending             : boolean  read GetErrormsgPending;
      //
      property DeviceNotOperational        : boolean  read GetDeviceNotOperational;
      property LaserNotOperational         : boolean  read GetLaserNotOperational;
      property LaserLocked                 : boolean  read GetLaserLocked;
      property LaserLockedExclOnOff        : boolean  read GetLaserLockedExclOnOff;
      property WarningsOnly                : boolean  read GetWarningsOnly;
      property AllWarnings                 : boolean  read GetAllWarnings;
      property DeviceWarnings              : boolean  read GetDeviceWarnings;
      property LaserWarnings               : boolean  read GetLaserWarnings;
      property OtherStates                 : boolean  read GetOtherStates;
    end;

    T_PDLM_SHORTVERSION = packed record
      Major   : word;
      Minor   : word;
    end;

    T_VersNum = packed record
      V       : T_PDLM_SHORTVERSION;
      Notes   : array [0..15] of AnsiChar;       // "beta", "pre-release", etc.
    end;

    T_DeviceData = packed record
      SerNo   : Cardinal;                        // serial number
      ArtNo   : Cardinal;                        // abas article number 950001
      DevName : array [0..15] of AnsiChar;       // "Taiko" / "Tabla" / "Conga" ...
      DevType : array [0..15] of AnsiChar;       // "PDL M<n>" <n> = 1,2,4
      Date    : array [0..15] of AnsiChar;       // date of manufacturing
      VersPCB : array [0..15] of AnsiChar;       // 078.2005.0102
      VersDev : T_VersNum;                       //
    end;
    P_DeviceData = ^T_DeviceData;


    T_LHFeature = (
      PDLM_LHFEATURE_CW_MODE_CAPABILITY           = $00000001,
      PDLM_LHFEATURE_PULSE_MAXPOWER               = $00000002,
      PDLM_LHFEATURE_BURST_MODE_CAPABILITY        = $00000010,
      PDLM_LHFEATURE_LOWFREQ_RESTRICTED_BURSTS    = $00000020,        // Vorerst nicht unterstützt
      PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS  = $00000040,        // Vorerst nicht unterstützt
      PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_PULSES  = $00000080,
      PDLM_LHFEATURE_WL_TUNABLE                   = $00000100,
      PDLM_LHFEATURE_COOLING_FAN                  = $00010000,
      PDLM_LHFEATURE_SWITCHABLE_FAN               = $00020000,        // Kann [0, 1] fuer Lüfter aus / ein (Lüftergeschwindigkeit ist fest verdrahtet)
      PDLM_LHFEATURE_INTENSITY_SENSOR_TYPE        = $0F000000
    );

    T_LHFeatures = packed record
    private
      uiF : Cardinal;
      function  Get_HasCWCapability : boolean;
      procedure Set_HasCWCapability (value: boolean);
      function  Get_HasPulseMaxPower : boolean;
      procedure Set_HasPulseMaxPower (value: boolean);
      function  Get_HasBurstCapability : boolean;
      procedure Set_HasBurstCapability (value: boolean);
      function  Get_IsLowFreqRestrictedBurst : boolean;
      procedure Set_IsLowFreqRestrictedBurst (value: boolean);
      function  Get_IsExternalTriggerableBurst : boolean;
      procedure Set_IsExternalTriggerableBurst (value: boolean);
      function  Get_IsExternalTriggerablePulse : boolean;
      procedure Set_IsExternalTriggerablePulse (value: boolean);
      function  Get_IsWLTunable : boolean;
      procedure Set_IsWLTunable (value: boolean);
      function  Get_HasCoolingFan : boolean;
      procedure Set_HasCoolingFan (value: boolean);
      function  Get_IsSwitchableFan : boolean;
      procedure Set_IsSwitchableFan (value: boolean);
      function  Get_HasIntensitySensor : boolean;
      function  Get_IntensitySensorType : byte;
      procedure Set_IntensitySensorType (value: byte);
    public
      property ui                         : Cardinal read uiF                            write uiF;
      //
      property HasCWCapability            : boolean  read Get_HasCWCapability            write Set_HasCWCapability;
      property HasPulseMaxPower           : boolean  read Get_HasPulseMaxPower           write Set_HasPulseMaxPower;
      property HasBurstCapability         : boolean  read Get_HasBurstCapability         write Set_HasBurstCapability;
      property IsLowFreqRestrictedBurst   : boolean  read Get_IsLowFreqRestrictedBurst   write Set_IsLowFreqRestrictedBurst;
      property IsExternalTriggerableBurst : boolean  read Get_IsExternalTriggerableBurst write Set_IsExternalTriggerableBurst;
      property IsExternalTriggerablePulse : boolean  read Get_IsExternalTriggerablePulse write Set_IsExternalTriggerablePulse;
      property IsWLTunable                : boolean  read Get_IsWLTunable                write Set_IsWLTunable;
      property HasCoolingFan              : boolean  read Get_HasCoolingFan              write Set_HasCoolingFan;
      property IsSwitchableFan            : boolean  read Get_IsSwitchableFan            write Set_IsSwitchableFan;
      property HasIntensitySensor         : boolean  read Get_HasIntensitySensor;
      property IntensitySensorType        : byte     read Get_IntensitySensorType        write Set_IntensitySensorType;
    end;

  const
    LHDATA_MAXCASETEMP_MASK      = $03FF;
    LHDATA_CLASS4_PROT_MASK      = $0400;

  type
    T_LHData_LaserType           = (LHDATA_LASERTYPE_UNDEFINED   = $0000,
                                    LHDATA_LASERTYPE_LDH         = $0010,  // Laser diode
                                    LHDATA_LASERTYPE_LDH_FSL     = $0018,  // Laser diode with Fast Switched Laser mode, pulse gate used for that
                                    LHDATA_LASERTYPE_LED         = $0020,  // Led
                                    LHDATA_LASERTYPE_TA_SHG      = $0030,  // with tapered fiber amplifier and second harmonic generation
                                    LHDATA_LASERTYPE_FIBER       = $0040,  // fiber
                                    LHDATA_LASERTYPE_FIBER_FSL   = $0048,  // fiber,  Fast Switched Laser mode
                                    LHDATA_LASERTYPE_FA          = $0050,  // fiber amplifier
                                    LHDATA_LASERTYPE_FA_SHG      = $0060,  // fiber amplifier  and second harmonic generation
                                    LHDATA_LASERTYPE_BRIDGE      = $00F0   // for legacy heads  (compatible to  PDL-820, PDL-828)
                                   );
    T_LHData_LaserTypeIdx        = (LHDATA_LASERTYPEIDX_UNDEFINED,
                                    LHDATA_LASERTYPEIDX_LDH,
                                    LHDATA_LASERTYPEIDX_LDH_FSL,
                                    LHDATA_LASERTYPEIDX_LED,
                                    LHDATA_LASERTYPEIDX_TA_SHG,
                                    LHDATA_LASERTYPEIDX_FIBER,
                                    LHDATA_LASERTYPEIDX_FIBER_FSL,
                                    LHDATA_LASERTYPEIDX_FA,
                                    LHDATA_LASERTYPEIDX_FA_SHG,
                                    LHDATA_LASERTYPEIDX_BRIDGE
                                   );
  const
    LHDATA_LASERTYPE_LEGALSET    : set of T_LHData_LaserType
                                   = [ LHDATA_LASERTYPE_UNDEFINED,
                                       LHDATA_LASERTYPE_LDH,
                                       LHDATA_LASERTYPE_LDH_FSL,
                                       LHDATA_LASERTYPE_LED,
                                       LHDATA_LASERTYPE_TA_SHG,
                                       LHDATA_LASERTYPE_FIBER,
                                       LHDATA_LASERTYPE_FIBER_FSL,
                                       LHDATA_LASERTYPE_FA,
                                       LHDATA_LASERTYPE_FA_SHG,
                                       LHDATA_LASERTYPE_BRIDGE
                                     ];
    LHDATA_LASERTYPE_TEXTS       : array [T_LHData_LaserTypeIdx] of string
                                   = ('undefined',
                                      'LDH',
                                      'LDH (FSL)',
                                      'PLS (LED)',
                                      'DTA (TA, SHG)',
                                      'LDH (F-head)',
                                      'LDH (F-head, FSL)',
                                      'LDH (F-head, FA)',
                                      'LDH (F-head, FA, FSL, SHG)',
                                      'Legacy Bridge'
                                     );
  type

    T_LHData = packed record                          // laser head data
      // C-representation:
      //  uint32_t            SN;                     // serial number
      //  T_PDLM_LHFEATURE    Features;               // bitset
      //  uint32_t            FreqMin;                // in Hz
      //  uint32_t            FreqMax;                // in Hz
      //  uint32_t            CwPowerMax;             // in nW
      //  uint32_t            PulsePowerMax;          // in nW
      //  uint16_t            WavelengthNominal;      // in 1/10 nm
      //  uint16_t            CaseTempMax       : 10; // max. case temp.  in [1/10 °C]
      //  uint16_t            Protection        :  1; // > 0,  if laser class 4
      //  uint16_t            CwCurrentPolarity :  1; // 0 = positive, 1 = negative
      //                                              // This field is not used in Taiko, but will be used in other products
      //  uint16_t            : 4;                    // unnamed dummy
      //  uint16_t            LHTypeCtrlVoltage : 12; // max. voltage of the driver for this LH type in [cV];  1cV == 10 mV;
      //                                              // Range: [(0,00V == 0x000) <= LHCtrlVoltage <= (40,95V == 0xFFF)]
      //  uint16_t            : 4;                    // unnamed dummy
      //  uint16_t            LHMaxVoltage      : 12; // max. voltage of this individual LH diode    in [cV];  1cV == 10 mV;
      //                                              // Range: [(0,00V == 0x000) <= LHMaxVoltage  <=  LHCtrlVoltage   ]
      //  uint16_t            : 4;                    // unnamed dummy
      //  uint16_t            CurrentTEP12V;          // Current consumption of TEP 12V power supply in mA. Is for future
      //                                              // use in Sepia3, where several laser heads can be connected. The Sepia3
      //                                              // must know if it can supply enough power.
      //  uint16_t            LaserType;              // Laser head type
      //  T_PDLM_LHVERSION    Version;                // Laser head version number
      //  uint16_t            calibratedWarrantHours;
      //
      function  GetProtection : boolean;
      procedure SetProtection (value: boolean);
      function  GetCaseTMax : Word;
      procedure SetCaseTMax (value: Word);
      //
      function  LaserTypeByTypeIdx (value: word {i.e. T_LHData_LaserTypeIdx}): T_LHData_LaserType;
      function  LaserTypeIdxByType (value: T_LHData_LaserType): word; {i.e. T_LHData_LaserTypeIdx}
      //
    public
      SerNo               : Cardinal;              // serial number
      Features            : T_LHFeatures;          // bitset
      FreqMin             : Cardinal;              // in Hz
      FreqMax             : Cardinal;              // in Hz
      CwPowerMax          : Cardinal;              // in nW
      PulsePowerMax       : Cardinal;              // in nW
      WavelengthNominal   : Word;                  // in 1/10 nm
      //                                           //
    private                                        //
      casetmax_class4prot : Word;                  // CaseTMax:   max. case temp.  in [1/10 °C]  (only 10 bit used),
      //                                           // Class4Prot: true if laser class >= IV  (only 1 bit used)
    public                                         //
      LHTypeCtrlVoltage   : Word;                  // max. voltage of the PDL M driver for this LH type  (only 12 bit used)
      //                                           // in [cV];  1cV == 10 mV; Range: [(0,00V == 0x000) <= LHCtrlVoltage <= (40,95V == 0xFFF)]
      LHMaxVoltage        : Word;                  // max. voltage of this individual LH diode  (only 12 bit used)
      //                                           // in [cV];  1cV == 10 mV; Range: [(0,00V == 0x000) <= LHMaxVoltage  <=  LHCtrlVoltage   ]
      CurrentTEP12V       : Word;                  // Current consumption of TEP 12V power supply in mA. Is for future use in Sepia3,
      //                                           // where several laser heads can be connected. The Sepia3 must know if it can supply enough power.
      LaserType           : Word;                  // const. ID (refer to T_LHData_LaserType constants)
      //                                           //
      VersLH              : T_PDLM_SHORTVERSION;   // Laser head version number
      //
      CalWarrentHours     : Word;                  // Calibrated promised time in hours
      //
      property Protection : boolean                read GetProtection   write SetProtection;
      property CaseTMax   : Word                   read GetCaseTMax     write SetCaseTMax;
    end;
    P_LHData  = ^T_LHData;

    T_LHInfo = packed record                     // laser head info
      LType         : array [0..15] of AnsiChar; // e.g. LDH-D-C-405
      Date          : array [0..15] of AnsiChar; // date of manufacturing
      LClass        : array [0..15] of AnsiChar; // laser class
    end;
    P_LHInfo  = ^T_LHInfo;

  const
    PDLM_LH_ABSOLUTE_MIN_TEMP                          =    50;   //   5.0 °C   // limited to  0°C + (PDLM_LH_MAX_DELTA_TEMP div 2)
    PDLM_LH_ABSOLUTE_MAX_TEMP                          =   750;   // +75.0 °C   // limited to 80°C - (PDLM_LH_MAX_DELTA_TEMP div 2)
    PDLM_LH_MAX_DELTA_TEMP                             =   100;   //  ±5.0 °C   // only as a upper limit, actually, delta temp should be set to 4, i.e.  ±0.2 °C

    PDLM_LH_PULSE_LINPWR_TABLE_IDX                     =     0;
    PDLM_LH_PULSE_MAXPWR_TABLE_IDX                     =     1;


  type
    TPDLM_LH_GUID = record
      case byte of
        0:  (bArr    : array [0..15] of byte);
        1:  (wArr    : array [0.. 7] of word);
        2:  (dwArr   : array [0.. 3] of Cardinal);
        3:  (ui64Arr : array [0.. 1] of UInt64);
        4:  (guid    : TGUID);
    end;

    T_FIRMWARE_UPDATE_STATUS = (
      PDLM_START,
      PDLM_DATA_TRANSFER,
      PDLM_ERASE_FLASH,
      PDLM_WRITE_FLASH,
      PDLM_VERIFY_FLASH,
      PDLM_FAILED,
      PDLM_READY
    );

    T_FirmwareUpdateInfo = packed record
      Status     : T_FIRMWARE_UPDATE_STATUS;
      Progress   : Word;
      Error      : Integer;
    end;
    P_FirmwareUpdateInfo = ^T_FirmwareUpdateInfo;

  const
    UNASSIGNED_INT_GUARD                        = $47110815;
    UNASSIGNED_INT_GUARD2                       = $47120817;
    UNASSIGNED_CARD_GUARD   : Cardinal          = $08154711;
    UNASSIGNED_CARD_GUARD2  : Cardinal          = $08174712;
    UNASSIGNED_FLOAT_GUARD                      = NaN;
    UNASSIGNED_FLOAT_GUARD2                     = NaN;
    UNASSIGNED_STR_GUARD                        = '???';




  // ---  library functions  ---------------------------------------------------

  function PDLM_GetLibraryVersion               (var cLibVersion: string) : integer;
  function PDLM_GetUSBDriverInfo                (var cUSBDrvName, cUSBDrvVers, cUSBDrvDate: string) : integer;
  function PDLM_DecodeError                     (iErrCode: integer; var cErrorString: string) : integer;
  function PDLM_GetTagDescription               (uiTag: Cardinal; var uiTypeCode: Cardinal; var cName: string) : integer;
  function PDLM_DecodeLHFeatures                (uiLHFeatures: Cardinal; var cLHFeatures: string) : integer;
  function PDLM_DecodePulseShape                (uiPulseShape: Cardinal; var cPulseShape: string) : integer;
  function PDLM_DecodeSystemStatus              (Status: Cardinal; var cStatusText: string) : integer;


  // ---  USB functions  -------------------------------------------------------

  function PDLM_OpenDevice                      (iDevIdx: integer; var cSerialNumber: string) : integer;
  function PDLM_OpenGetSerNumAndClose           (iDevIdx: integer; var cSerialNumber: string) : integer;
  function PDLM_CloseDevice                     (iDevIdx: integer) : integer;
  function PDLM_GetUSBStrDescriptor             (iDevIdx: integer; var cDescriptor: string) : integer;


  // ---  device functions  ----------------------------------------------------

  function PDLM_GetSystemStatus                 (iDevIdx: integer; var Status: Cardinal) : integer;
  function PDLM_GetQueuedError                  (iDevIdx: integer; var iErrCode: integer) : integer;
  function PDLM_GetQueuedErrorString            (iDevIdx: integer; iErrCode: integer; var cErrorString: string) : integer;
  function PDLM_GetHardwareInfo                 (iDevIdx: integer; var cInfos: string) : integer;
  function PDLM_GetFWVersion                    (iDevIdx: integer; var cFWVersion: string) : integer;
  function PDLM_GetFPGAVersion                  (iDevIdx: integer; var cFPGAVersion: string) : integer;
  function PDLM_GetLHVersion                    (iDevIdx: integer; var cLHVersion: string) : integer;
  //
  function PDLM_SetHWND                         (iDevIdx: integer; WindowHandle : HWND) : integer;
  function PDLM_ResetStateHandling              (iDevIdx: integer; uiMask: Cardinal; uiStatus: Cardinal): integer;
  function PDLM_GetQueuedChanges                (iDevIdx: integer; var TagValueList: T_TaggedValueList; var uiListLen: Cardinal): integer;
  function PDLM_GetTaggedValueList              (iDevIdx: integer; iListLen: integer; var TaggedValueList: T_TaggedValueList) : integer;
  //
  function PDLM_GetDeviceData                   (iDevIdx: integer; var DevData: T_DeviceData) : integer;
  function PDLM_GetLHData                       (iDevIdx: integer; var LHData: T_LHData) : integer;
  function PDLM_GetLHInfo                       (iDevIdx: integer; var LHInfo: T_LHInfo) : integer;
  function PDLM_GetLHFeatures                   (iDevIdx: integer; var LHFeatures: Cardinal) : integer;
  //
  function PDLM_SetSoftLock                     (iDevIdx: integer; bLocked: boolean) : integer;
  function PDLM_GetSoftLock                     (iDevIdx: integer; var bLocked: boolean) : integer;
  function PDLM_GetLocked                       (iDevIdx: integer; var bLocked: boolean) : integer;
  //
  function PDLM_SetExclusiveUI                  (iDevIdx: integer; bUIExclusive: boolean) : integer;
  function PDLM_GetExclusiveUI                  (iDevIdx: integer; var bUIExclusive: boolean) : integer;
  //
  function PDLM_SetLaserMode                    (iDevIdx: integer; lmMode: T_LaserMode) : integer;
  function PDLM_GetLaserMode                    (iDevIdx: integer; var lmMode: T_LaserMode) : integer;
  function PDLM_SetTriggerMode                  (iDevIdx: integer; tsMode: T_TriggerSource) : integer;
  function PDLM_GetTriggerMode                  (iDevIdx: integer; var tsMode: T_TriggerSource) : integer;
  //
  function PDLM_SetFastGate                     (iDevIdx: integer; bGateEnabled: boolean) : integer;
  function PDLM_GetFastGate                     (iDevIdx: integer; var bGateEnabled: boolean) : integer;
  function PDLM_SetFastGateImp                  (iDevIdx: integer; uiImpClass: Cardinal) : integer;
  function PDLM_GetFastGateImp                  (iDevIdx: integer; var uiImpClass: Cardinal) : integer;
  //
  function PDLM_SetSlowGate                     (iDevIdx: integer; bGateEnabled: boolean) : integer;
  function PDLM_GetSlowGate                     (iDevIdx: integer; var bGateEnabled: boolean) : integer;
  //
  function PDLM_SetTempScale                    (iDevIdx: integer; uiScaleID: Cardinal) : integer;
  function PDLM_GetTempScale                    (iDevIdx: integer; var uiScaleID: Cardinal) : integer;

  function PDLM_GetLHTargetTempLimits           (iDevIdx: integer; uiScaleID: Cardinal; var fMinTemp, fMaxTemp: Single) : integer;
  function PDLM_SetLHTargetTemp                 (iDevIdx: integer; uiScaleID: Cardinal; fTargTemp: Single) : integer;
  function PDLM_GetLHTargetTemp                 (iDevIdx: integer; uiScaleID: Cardinal; var fTargTemp: Single) : integer;
  function PDLM_GetLHCurrentTemp                (iDevIdx: integer; uiScaleID: Cardinal; var fCurrTemp: Single) : integer;
  function PDLM_GetLHCaseTemp                   (iDevIdx: integer; uiScaleID: Cardinal; var fCaseTemp: Single) : integer;

  function PDLM_GetLHWavelength                 (iDevIdx: integer; var fWavelength: Single) : integer;
  //
  function PDLM_GetLHFrequencyLimits            (iDevIdx: integer; var uiMinFreq, uiMaxFreq: Cardinal) : integer;
  function PDLM_SetFrequency                    (iDevIdx: integer; uiFrequency: Cardinal) : integer;
  function PDLM_GetFrequency                    (iDevIdx: integer; var uiFrequency: Cardinal) : integer;
  //
  function PDLM_SetPulsePowerPermille           (iDevIdx: integer; uiPulsePowerPermille: Cardinal) : integer;
  function PDLM_GetPulsePowerPermille           (iDevIdx: integer; var uiPulsePowerPermille: Cardinal) : integer;
  function PDLM_GetPulsePowerLimits             (iDevIdx: integer; var fMinPulsePower, fMaxPulsePower: Single) : integer;
  function PDLM_SetPulsePower                   (iDevIdx: integer; fPulsePower: Single) : integer;
  function PDLM_GetPulsePower                   (iDevIdx: integer; var fPulsePower: Single) : integer;
  function PDLM_GetPulseShape                   (iDevIdx: integer; var uiPulseShape: Cardinal) : integer;
  function PDLM_SetLDHPulsePowerTable           (iDevIdx: integer; uiTableIdx: Cardinal) : integer;
  function PDLM_GetLDHPulsePowerTable           (iDevIdx: integer; var uiTableIdx: Cardinal) : integer;
  //
  function PDLM_SetCwPowerPermille              (iDevIdx: integer; uiCwPowerPermille: Cardinal) : integer;
  function PDLM_GetCwPowerPermille              (iDevIdx: integer; var uiCwPowerPermille: Cardinal) : integer;
  function PDLM_GetCwPowerLimits                (iDevIdx: integer; var fMinCwPower, fMaxCwPower: Single) : integer;
  function PDLM_SetCwPower                      (iDevIdx: integer; fCwPower: Single) : integer;
  function PDLM_GetCwPower                      (iDevIdx: integer; var fCwPower: Single) : integer;
  //
  function PDLM_GetTriggerLevelLimits           (iDevIdx: integer; var fMinTrigLevel, fMaxTrigLevel: Single) : integer;
  function PDLM_SetTriggerLevel                 (iDevIdx: integer; fTrigLevel: Single) : integer;
  function PDLM_GetTriggerLevel                 (iDevIdx: integer; var fTrigLevel: Single) : integer;
  function PDLM_GetTriggerFrequency             (iDevIdx: integer; var uiFrequency: Cardinal) : integer;
  //
  function PDLM_SetBurst                        (iDevIdx: integer; uiBurstLen, uiPeriodLen: Cardinal) : integer;
  function PDLM_GetBurst                        (iDevIdx: integer; var uiBurstLen, uiPeriodLen: Cardinal) : integer;
  //
  function PDLM_SetBuzzer                       (iDevIdx: integer; bBuzzOn: boolean) : integer;
  //
  function PDLM_SetLHFan                        (iDevIdx: integer; bFanRunning: boolean) : integer;
  function PDLM_GetLHFan                        (iDevIdx: integer; var bFanRunning: boolean) : integer;
  //
  function PDLM_GetPresetInfo                   (iDevIdx: integer; uiPresetIdx: Cardinal; var cPresetInfo: string) : integer;
  function PDLM_GetPresetText                   (iDevIdx: integer; uiPresetIdx: Cardinal; var cPresetText: string) : integer;
  function PDLM_StorePreset                     (iDevIdx: integer; uiPresetIdx: Cardinal; const cPresetInfo: string) : integer;
  function PDLM_RecallPreset                    (iDevIdx: integer; uiPresetIdx: Cardinal) : integer;
  function PDLM_ErasePreset                     (iDevIdx: integer; uiPresetIdx: Cardinal) : integer;
  //
  function PDLM_TerminateLHDemoMode             (iDevIdx: integer; const cDemoReleaseKey: string) : integer;
  function PDLM_CreateSupportRequestText        (iDevIdx: integer; const cPreamble, cCallingSW: string; const iOptions: integer; var cSupportInfo: string) : integer;
  //
  function PDLM_FirmwareUpdate                  (iDevIdx: integer; fileName: string) : integer;
  function PDLM_FirmwareUpdateStatus            (iDevIdx: integer; var fwuInfo: T_FirmwareUpdateInfo) : integer;
  //
  //
  var
    strLibVersion             : string;
    bPLDMImportLibOK          : Boolean;
    //
    bActiveDebugOut           : Boolean;
    bIntensityDebugOut        : Boolean;
    hdlDLL                    : THandle;
    strCurLibName             : string;
    //
    iDevIdx                   : integer;
    iTemp                     : integer;
    iTemp2                    : integer;
    uiTemp                    : cardinal;
    bTemp                     : boolean;
    strTemp                   : string;
    //
    TmpTaggedValList          : T_TaggedValueList;
    //
  {$ifdef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    bCalledByPolling          : boolean;
  {$endif}
    //
implementation

  uses
  {$ifdef __ADDED_FORMS_FOR_TEMP_DEBUG__}
    PDLM_Dlg, LogWinDlg,
  {$endif}
    System.StrUtils, System.AnsiStrings;

  const
    TEMPVAR_LENGTH            =  1025;
    TEMPLONGVAR_LENGTH        = 65537;

  type
    T_PDLM_GetLibraryVersion                   = function (pcLibVersion: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetUSBDriverInfo                    = function (pcUSBDrvName: pAnsiChar; uiNBufLen: Cardinal; pcUSBDrvVers: pAnsiChar; uiVBufLen: Cardinal; pcUSBDrvDate: pAnsiChar; uiDBufLen: Cardinal) : integer; stdcall;
    T_PDLM_DecodeError                         = function (iErrCode: integer; pcErrTxt: pAnsiChar; var uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetTagDescription                   = function (uiTag: Cardinal; var uiTypeCode: Cardinal; pcTagName: pAnsiChar) : integer; stdcall;
    T_PDLM_DecodePulseShape                    = function (uiPulseShape: Cardinal; pcPulseShape: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_DecodeLHFeatures                    = function (uiLHFeatures: Cardinal; pcLHFeatures: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_DecodeSystemStatus                  = function (uiStatus: Cardinal; pcStatusBuffer: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    //
    T_PDLM_OpenDevice                          = function (iDevIdx: integer; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_PDLM_OpenGetSerNumAndClose               = function (iDevIdx: integer; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_PDLM_CloseDevice                         = function (iDevIdx: integer) : integer; stdcall;
    T_PDLM_GetStrDescriptor                    = function (iDevIdx: integer; pcDescriptor: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    //
    T_PDLM_GetSystemStatus                     = function (iDevIdx: integer; var uiStatus: Cardinal) : integer; stdcall;
    T_PDLM_GetQueuedError                      = function (iDevIdx: integer; var iErrCode: integer) : integer; stdcall;
    T_PDLM_GetQueuedErrorString                = function (iDevIdx: integer; iErrCode: integer; pcErrTxt: pAnsiChar) : integer; stdcall;
    T_PDLM_GetHardwareInfo                     = function (iDevIdx: integer; pcInfos: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetFWVersion                        = function (iDevIdx: integer; pcFWVersion: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetFPGAVersion                      = function (iDevIdx: integer; pcFPGAVersion: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetLHVersion                        = function (iDevIdx: integer; pcLHVersion: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetLHFeatures                       = function (iDevIdx: integer; var uiLHFeatures: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetHWND                             = function (iDevIdx: integer; WindowHandle : HWND) : integer; stdcall;
    T_PDLM_ResetStateHandling                  = function (iDevIdx: integer; uiMask: Cardinal; uiStatus: Cardinal) : integer; stdcall;
    T_PDLM_GetTimerParams                      = function (iDevIdx: integer; uiTimerIdx: Cardinal; var uiEnable: Cardinal; var uiPeriod: Cardinal) : integer; stdcall;
    T_PDLM_SetPollTimerMode                    = function (iDevIdx: integer; uiEnable, uiSingleShot: Cardinal) : integer; stdcall;
    T_PDLM_GetQueuedChanges                    = function (iDevIdx: integer; pTagValueList: P_TaggedValue; var uiListLen: Cardinal): integer; stdcall;
    //
    T_PDLM_GetLocked                           = function (iDevIdx: integer; var uiLocked: Cardinal) : integer; stdcall;
    T_PDLM_SetSoftLock                         = function (iDevIdx: integer; uiLocked: Cardinal) : integer; stdcall;
    T_PDLM_GetSoftLock                         = function (iDevIdx: integer; var uiLocked: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetLaserMode                        = function (iDevIdx: integer; uiMode: Cardinal) : integer; stdcall;
    T_PDLM_GetLaserMode                        = function (iDevIdx: integer; var uiMode: Cardinal) : integer; stdcall;
    T_PDLM_SetTriggerMode                      = function (iDevIdx: integer; uiMode: Cardinal) : integer; stdcall;
    T_PDLM_GetTriggerMode                      = function (iDevIdx: integer; var uiMode: Cardinal) : integer; stdcall;
    //
    T_PDLM_GetTriggerLevelLimits               = function (iDevIdx: integer; var fMinLevel, fMaxLevel: Single) : integer; stdcall;
    T_PDLM_SetTriggerLevel                     = function (iDevIdx: integer; fLevel: Single) : integer; stdcall;
    T_PDLM_GetTriggerLevel                     = function (iDevIdx: integer; var fLevel: Single) : integer; stdcall;
    T_PDLM_GetTriggerFrequency                 = function (iDevIdx: integer; var uiFrequency: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetFastGate                         = function (iDevIdx: integer; uiMode: Cardinal) : integer; stdcall;
    T_PDLM_GetFastGate                         = function (iDevIdx: integer; var uiMode: Cardinal) : integer; stdcall;
    T_PDLM_SetFastGateImp                      = function (iDevIdx: integer; uiImpClass: Cardinal) : integer; stdcall;
    T_PDLM_GetFastGateImp                      = function (iDevIdx: integer; var uiImpClass: Cardinal) : integer; stdcall;
    T_PDLM_SetSlowGate                         = function (iDevIdx: integer; uiMode: Cardinal) : integer; stdcall;
    T_PDLM_GetSlowGate                         = function (iDevIdx: integer; var uiMode: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetTempScale                        = function (iDevIdx: integer; uiTempScaleIdx: Cardinal) : integer; stdcall;
    T_PDLM_GetTempScale                        = function (iDevIdx: integer; var uiTempScaleIdx: Cardinal) : integer; stdcall;
    T_PDLM_GetLHTargetTempLimits               = function (iDevIdx: integer; uiScaleID: Cardinal; var fMinTemp, fMaxTemp: Single) : integer; stdcall;
    T_PDLM_SetLHTargetTemp                     = function (iDevIdx: integer; uiScaleID: Cardinal; fTargTemp: Single) : integer; stdcall;
    T_PDLM_GetLHTargetTemp                     = function (iDevIdx: integer; uiScaleID: Cardinal; var fTargTemp: Single) : integer; stdcall;
    T_PDLM_GetLHCurrentTemp                    = function (iDevIdx: integer; uiScaleID: Cardinal; var fCurrTemp: Single) : integer; stdcall;
    T_PDLM_GetLHCaseTemp                       = function (iDevIdx: integer; uiScaleID: Cardinal; var fCaseTemp: Single) : integer; stdcall;
    //
    T_PDLM_GetLHWavelength                     = function (iDevIdx: integer; var fWavelength: Single) : integer; stdcall;
    //
    T_PDLM_GetLHFrequencyLimits                = function (iDevIdx: integer; var uiMinFreq, uiMaxFreq: Cardinal) : integer; stdcall;
    T_PDLM_SetFrequency                        = function (iDevIdx: integer; uiFrequency: Cardinal) : integer; stdcall;
    T_PDLM_GetFrequency                        = function (iDevIdx: integer; var uiFrequency: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetPulsePowerPermille               = function (iDevIdx: integer; uiPulsePowerPermille: Cardinal) : integer; stdcall;
    T_PDLM_GetPulsePowerPermille               = function (iDevIdx: integer; var uiPulsePowerPermille: Cardinal) : integer; stdcall;
    T_PDLM_GetPulsePowerLimits                 = function (iDevIdx: integer; var fMinPulsePower, fMaxPulsePower: Single) : integer; stdcall;
    T_PDLM_SetPulsePower                       = function (iDevIdx: integer; fPulsePower: Single) : integer; stdcall;
    T_PDLM_GetPulsePower                       = function (iDevIdx: integer; var fPulsePower: Single) : integer; stdcall;
    T_PDLM_GetPulseShape                       = function (iDevIdx: integer; var uiPulseShape: Cardinal) : integer; stdcall;
    T_PDLM_SetLDHPulsePowerTable               = function (iDevIdx: integer; uiTableIdx: Cardinal) : integer; stdcall;
    T_PDLM_GetLDHPulsePowerTable               = function (iDevIdx: integer; var uiTableIdx: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetCWPowerPermille                  = function (iDevIdx: integer; uiLHCwPowerPermille: Cardinal) : integer; stdcall;
    T_PDLM_GetCWPowerPermille                  = function (iDevIdx: integer; var uiLHCwPowerPermille: Cardinal) : integer; stdcall;
    T_PDLM_GetCwPowerLimits                    = function (iDevIdx: integer; var fMinCwPower, fMaxCwPower: Single) : integer; stdcall;
    T_PDLM_SetCwPower                          = function (iDevIdx: integer; fCwPower: Single) : integer; stdcall;
    T_PDLM_GetCwPower                          = function (iDevIdx: integer; var fCwPower: Single) : integer; stdcall;
    //
    T_PDLM_SetBurst                            = function (iDevIdx: integer; uiBurstLen, uiPeriodLen: Cardinal) : integer; stdcall;
    T_PDLM_GetBurst                            = function (iDevIdx: integer; var uiBurstLen, uiPeriodLen: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetBuzzer                           = function (iDevIdx: integer; uiBuzzOn: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetLHFan                            = function (iDevIdx: integer; uiFanValue: Cardinal) : integer; stdcall;
    T_PDLM_GetLHFan                            = function (iDevIdx: integer; var uiFanValue: Cardinal) : integer; stdcall;
    //
    T_PDLM_SetExclusiveUI                      = function (iDevIdx: integer; uiUIExclusive: Cardinal) : integer; stdcall;
    T_PDLM_GetExclusiveUI                      = function (iDevIdx: integer; var uiUIExclusive: Cardinal) : integer; stdcall;
    //
    T_PDLM_GetPresetInfo                       = function (iDevIdx: integer; uiPresetIdx: Cardinal; pcPresetInfo: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_GetPresetText                       = function (iDevIdx: integer; uiPresetIdx: Cardinal; pcPresetText: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_StorePreset                         = function (iDevIdx: integer; uiPresetIdx: Cardinal; pcPresetInfo: pAnsiChar; uiBufLen: Cardinal) : integer; stdcall;
    T_PDLM_RecallPreset                        = function (iDevIdx: integer; uiPresetIdx: Cardinal) : integer; stdcall;
    T_PDLM_ErasePreset                         = function (iDevIdx: integer; uiPresetIdx: Cardinal) : integer; stdcall;
    //
    T_PDLM_GetTagValueList                     = function (iDevIdx: integer; iListLen: integer; pTaggedValueList: P_TaggedValue) : integer; stdcall;
    //
    T_PDLM_TerminateLHDemoMode                 = function (iDevIdx: integer; cDemoReleaseKey: pAnsiChar) : integer; stdcall;
    T_PDLM_CreateSupportRequestText            = function (iDevIdx: integer; cPreamble, cCallingSW: pAnsiChar; iOptions, iBufferLen: integer; cBuffer: pAnsiChar) : integer; stdcall;
    //
    T_PDLM_FirmwareUpdate                      = function (iDevIdx: integer; pcFirmwareFile: pAnsiChar) : integer; stdcall;
    T_PDLM_FirmwareUpdateStatus                = function (iDevIdx: integer; var fwuInfo: T_FirmwareUpdateInfo) : integer stdcall;
    //
    T_PDLM_GetDeviceData                       = function (iDevIdx: integer; pDevData: P_DeviceData; DataSize: Cardinal) : integer; stdcall;
    T_PDLM_GetLHData                           = function (iDevIdx: integer; pLHData: P_LHData; DataSize: Cardinal) : integer; stdcall;
    T_PDLM_GetLHInfo                           = function (iDevIdx: integer; pLHInfo: P_LHInfo; DataSize: Cardinal) : integer; stdcall;
    //
    //

  var
    _PDLM_GetLibraryVersion                    : T_PDLM_GetLibraryVersion;
    _PDLM_GetUSBDriverInfo                     : T_PDLM_GetUSBDriverInfo;
    _PDLM_DecodeError                          : T_PDLM_DecodeError;
    _PDLM_GetTagDescription                    : T_PDLM_GetTagDescription;
    _PDLM_DecodeLHFeatures                     : T_PDLM_DecodeLHFeatures;
    _PDLM_DecodePulseShape                     : T_PDLM_DecodePulseShape;
    _PDLM_DecodeSystemStatus                   : T_PDLM_DecodeSystemStatus;
    //
    //
    _PDLM_OpenDevice                           : T_PDLM_OpenDevice;
    _PDLM_OpenGetSerNumAndClose                : T_PDLM_OpenGetSerNumAndClose;
    _PDLM_CloseDevice                          : T_PDLM_CloseDevice;
    _PDLM_GetUSBStrDescriptor                  : T_PDLM_GetStrDescriptor;
    //
    _PDLM_GetSystemStatus                      : T_PDLM_GetSystemStatus;
    _PDLM_GetQueuedError                       : T_PDLM_GetQueuedError;
    _PDLM_GetQueuedErrorString                 : T_PDLM_GetQueuedErrorString;
    _PDLM_GetHardwareInfo                      : T_PDLM_GetHardwareInfo;
    _PDLM_GetFWVersion                         : T_PDLM_GetFWVersion;
    _PDLM_GetFPGAVersion                       : T_PDLM_GetFPGAVersion;
    _PDLM_GetLHVersion                         : T_PDLM_GetLHVersion;
    _PDLM_GetLHFeatures                        : T_PDLM_GetLHFeatures;
    //
    _PDLM_SetHWND                              : T_PDLM_SetHWND;
    _PDLM_ResetStateHandling                   : T_PDLM_ResetStateHandling;
    _PDLM_GetQueuedChanges                     : T_PDLM_GetQueuedChanges;
    //
    _PDLM_GetLocked                            : T_PDLM_GetLocked;
    _PDLM_SetSoftLock                          : T_PDLM_SetSoftLock;
    _PDLM_GetSoftLock                          : T_PDLM_GetSoftLock;
    //
    _PDLM_SetLaserMode                         : T_PDLM_SetLaserMode;
    _PDLM_GetLaserMode                         : T_PDLM_GetLaserMode;
    _PDLM_SetTriggerMode                       : T_PDLM_SetTriggerMode;
    _PDLM_GetTriggerMode                       : T_PDLM_GetTriggerMode;
    //
    _PDLM_GetTriggerLevelLimits                : T_PDLM_GetTriggerLevelLimits;
    _PDLM_SetTriggerLevel                      : T_PDLM_SetTriggerLevel;
    _PDLM_GetTriggerLevel                      : T_PDLM_GetTriggerLevel;
    _PDLM_GetTriggerFrequency                  : T_PDLM_GetTriggerFrequency;
    //
    _PDLM_SetFastGate                          : T_PDLM_SetFastGate;
    _PDLM_GetFastGate                          : T_PDLM_GetFastGate;
    _PDLM_SetFastGateImp                       : T_PDLM_SetFastGateImp;
    _PDLM_GetFastGateImp                       : T_PDLM_GetFastGateImp;
    //
    _PDLM_SetSlowGate                          : T_PDLM_SetSlowGate;
    _PDLM_GetSlowGate                          : T_PDLM_GetSlowGate;
    //
    _PDLM_SetTempScale                         : T_PDLM_SetTempScale;
    _PDLM_GetTempScale                         : T_PDLM_GetTempScale;
    _PDLM_GetLHTargetTempLimits                : T_PDLM_GetLHTargetTempLimits;
    _PDLM_SetLHTargetTemp                      : T_PDLM_SetLHTargetTemp;
    _PDLM_GetLHTargetTemp                      : T_PDLM_GetLHTargetTemp;
    _PDLM_GetLHCurrentTemp                     : T_PDLM_GetLHCurrentTemp;
    _PDLM_GetLHCaseTemp                        : T_PDLM_GetLHCaseTemp;
    //
    _PDLM_GetLHWavelength                      : T_PDLM_GetLHWavelength;
    //
    _PDLM_GetLHFrequencyLimits                 : T_PDLM_GetLHFrequencyLimits;
    _PDLM_SetFrequency                         : T_PDLM_SetFrequency;
    _PDLM_GetFrequency                         : T_PDLM_GetFrequency;
    //
    _PDLM_GetPulsePowerLimits                  : T_PDLM_GetPulsePowerLimits;
    _PDLM_SetPulsePower                        : T_PDLM_SetPulsePower;
    _PDLM_GetPulsePower                        : T_PDLM_GetPulsePower;
    _PDLM_SetPulsePowerPermille                : T_PDLM_SetPulsePowerPermille;
    _PDLM_GetPulsePowerPermille                : T_PDLM_GetPulsePowerPermille;
    _PDLM_GetPulseShape                        : T_PDLM_GetPulseShape;
    _PDLM_SetLDHPulsePowerTable                : T_PDLM_SetLDHPulsePowerTable;
    _PDLM_GetLDHPulsePowerTable                : T_PDLM_GetLDHPulsePowerTable;
    //
    _PDLM_GetCwPowerLimits                     : T_PDLM_GetCwPowerLimits;
    _PDLM_SetCwPower                           : T_PDLM_SetCwPower;
    _PDLM_GetCwPower                           : T_PDLM_GetCwPower;
    _PDLM_SetCWPowerPermille                   : T_PDLM_SetCWPowerPermille;
    _PDLM_GetCWPowerPermille                   : T_PDLM_GetCWPowerPermille;
    //
    _PDLM_SetBurst                             : T_PDLM_SetBurst;
    _PDLM_GetBurst                             : T_PDLM_GetBurst;
    //
    _PDLM_SetBuzzer                            : T_PDLM_SetBuzzer;
    //
    _PDLM_SetLHFan                             : T_PDLM_SetLHFan;
    _PDLM_GetLHFan                             : T_PDLM_GetLHFan;
    //
    _PDLM_SetExclusiveUI                       : T_PDLM_SetExclusiveUI;
    _PDLM_GetExclusiveUI                       : T_PDLM_GetExclusiveUI;
    //
    //
    _PDLM_GetPresetInfo                        : T_PDLM_GetPresetInfo;
    _PDLM_GetPresetText                        : T_PDLM_GetPresetText;
    _PDLM_StorePreset                          : T_PDLM_StorePreset;
    _PDLM_RecallPreset                         : T_PDLM_RecallPreset;
    _PDLM_ErasePreset                          : T_PDLM_ErasePreset;
    //
    _PDLM_GetTagValueList                      : T_PDLM_GetTagValueList;
    //
    _PDLM_TerminateLHDemoMode                  : T_PDLM_TerminateLHDemoMode;
    _PDLM_CreateSupportRequestText             : T_PDLM_CreateSupportRequestText;
    //
    _PDLM_FirmwareUpdate                       : T_PDLM_FirmwareUpdate;
    _PDLM_FirmwareUpdateStatus                 : T_PDLM_FirmwareUpdateStatus;
    //
    _PDLM_GetDeviceData                        : T_PDLM_GetDeviceData;
    _PDLM_GetLHData                            : T_PDLM_GetLHData;
    _PDLM_GetLHInfo                            : T_PDLM_GetLHInfo;
    //

//-----------------------------------------------------------------------------
//
//      {T_PDLM_DEVSTATE}
//
//-----------------------------------------------------------------------------

    function T_DeviceState.GetInitializing : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_INITIALIZING in FState.bs);
    end;

    function T_DeviceState.GetUncalibrated : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_DEVICE_UNCALIBRATED in FState.bs);
    end;

    function T_DeviceState.GetCommisioning : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_COMMISSIONING_MODE in FState.bs);
    end;

    function T_DeviceState.GetLHSafetyMode : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_SAFETY_MODE in FState.bs);
    end;

    function T_DeviceState.GetFWUpdateRunning : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_FW_UPDATE_RUNNING in FState.bs);
    end;

    function T_DeviceState.GetDeviceDefect : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_DEVICE_DEFECT in FState.bs);
    end;

    function T_DeviceState.GetDeviceIncompatible : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_DEVICE_INCOMPATIBLE in FState.bs);
    end;

    function T_DeviceState.GetBusy : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_BUSY in FState.bs);
    end;

    function T_DeviceState.GetExclusive : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_EXCLUSIVE_SW_OP_GRANTED in FState.bs);
    end;

    function T_DeviceState.GetParamChanges : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_PARAMETER_CHANGES_PENDING in FState.bs);
    end;

    function T_DeviceState.GetLHChanged : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_CHANGED in FState.bs);
    end;

    function T_DeviceState.GetLHMissing : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_MISSING in FState.bs);
    end;

    function T_DeviceState.GetLHDefect : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_DEFECT in FState.bs);
    end;

    function T_DeviceState.GetLHUnknownType : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_UNKNOWN_TYPE in FState.bs);
    end;

    function T_DeviceState.GetLHDecalibrated : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_DECALIBRATED in FState.bs);
    end;

    function T_DeviceState.GetLHDiodeTempTooLow : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_LOW in FState.bs);
    end;

    function T_DeviceState.GetLHDiodeTempTooHigh : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_TEMP_TOO_HIGH in FState.bs);
    end;

    function T_DeviceState.GetLHDiodeOverheated : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_DIODE_OVERHEATED in FState.bs);
    end;

    function T_DeviceState.GetLHCaseOverheated : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_CASE_OVERHEATED in FState.bs);
    end;

    function T_DeviceState.GetLHFanRunning : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_FAN_RUNNING in FState.bs);
    end;

    function T_DeviceState.GetLHIncompatible : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_INCOMPATIBLE in FState.bs);
    end;

    function T_DeviceState.GetExpiredDemoMode : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LOCKED_BY_EXPIRED_DEMO_MODE in FState.bs);
    end;

    function T_DeviceState.GetOnOffButton : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LOCKED_BY_ON_OFF_BUTTON in FState.bs);
    end;

    function T_DeviceState.GetSoftLocked : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_SOFTLOCK in FState.bs);
    end;

    function T_DeviceState.GetKeyLocked : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_KEYLOCK in FState.bs);
    end;

    function T_DeviceState.GetSecurityPolicy : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LOCKED_BY_SECURITY_POLICY in FState.bs);
    end;

    function T_DeviceState.GetInterLocked : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_INTERLOCK in FState.bs);
    end;

    function T_DeviceState.GetPulsPowerInaccurate : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_LASERHEAD_PULSE_POWER_INACCURATE in FState.bs);
    end;

    function T_DeviceState.GetErrormsgPending : boolean;
    begin
      result := (PDLM_DEVSTATEIDX_ERRORMSG_PENDING in FState.bs);
    end;

    // groups:

    function T_DeviceState.GetDeviceNotOperational : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_DEVICE_NOT_OPERATIONAL * FState.bs) = []);
    end;

    function T_DeviceState.GetLaserNotOperational : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_LASER_NOT_OPERATIONAL * FState.bs) = []);
    end;

    function T_DeviceState.GetLaserLocked : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_LOCKED * FState.bs) = []);
    end;

    function T_DeviceState.GetLaserLockedExclOnOff : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_LOCKED_EXCL_ON_OFF_BTN * FState.bs) = []);
    end;

    function T_DeviceState.GetWarningsOnly : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_WARNINGS_ONLY * FState.bs) = []);
    end;

    function T_DeviceState.GetAllWarnings : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_ALL_WARNINGS * FState.bs) = []);
    end;

    function T_DeviceState.GetDeviceWarnings : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_DEVICE_WARNINGS * FState.bs) = []);
    end;

    function T_DeviceState.GetLaserWarnings : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_LASER_WARNINGS * FState.bs) = []);
    end;

    function T_DeviceState.GetOtherStates : boolean;
    begin
      result := not ((PDLM_DEVSTATE_BS_OTHER_STATES * FState.bs) = []);
    end;

//-----------------------------------------------------------------------------
//
//      {T_LHFeatures}
//
//-----------------------------------------------------------------------------

    function T_LHFeatures.Get_HasCWCapability : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_CW_MODE_CAPABILITY)) > 0);
    end;

    procedure T_LHFeatures.Set_HasCWCapability (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_CW_MODE_CAPABILITY));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_CW_MODE_CAPABILITY));
      end;
    end;

    function  T_LHFeatures.Get_HasPulseMaxPower : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_PULSE_MAXPOWER)) > 0);
    end;

    procedure T_LHFeatures.Set_HasPulseMaxPower (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_PULSE_MAXPOWER));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_PULSE_MAXPOWER));
      end;
    end;

    function  T_LHFeatures.Get_HasBurstCapability : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_BURST_MODE_CAPABILITY)) > 0);
    end;

    procedure T_LHFeatures.Set_HasBurstCapability (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_BURST_MODE_CAPABILITY));
      end
      else begin
        uiF := (uiF and not (  Cardinal (PDLM_LHFEATURE_BURST_MODE_CAPABILITY)
                          or Cardinal (PDLM_LHFEATURE_LOWFREQ_RESTRICTED_BURSTS)
                          or Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS)
                          ));
      end;
    end;

    function  T_LHFeatures.Get_IsLowFreqRestrictedBurst : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_LOWFREQ_RESTRICTED_BURSTS)) > 0);
    end;

    procedure T_LHFeatures.Set_IsLowFreqRestrictedBurst (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_LOWFREQ_RESTRICTED_BURSTS));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_LOWFREQ_RESTRICTED_BURSTS));
      end;
    end;

    function  T_LHFeatures.Get_IsExternalTriggerableBurst : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS)) > 0);
    end;

    procedure T_LHFeatures.Set_IsExternalTriggerableBurst (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_BURSTS));
      end;
    end;

    function  T_LHFeatures.Get_IsExternalTriggerablePulse : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_PULSES)) > 0);
    end;

    procedure T_LHFeatures.Set_IsExternalTriggerablePulse (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_PULSES));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_EXTERNAL_TRIGGERABLE_PULSES));
      end;
    end;

    function T_LHFeatures.Get_IsWLTunable : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_WL_TUNABLE)) > 0);
    end;

    procedure T_LHFeatures.Set_IsWLTunable (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_WL_TUNABLE));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_WL_TUNABLE));
      end;
    end;

    function T_LHFeatures.Get_HasCoolingFan : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_COOLING_FAN)) > 0);
    end;

    procedure T_LHFeatures.Set_HasCoolingFan (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_COOLING_FAN));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_COOLING_FAN));
      end;
    end;

    function T_LHFeatures.Get_IsSwitchableFan : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_SWITCHABLE_FAN)) > 0);
    end;

    procedure T_LHFeatures.Set_IsSwitchableFan (value: boolean);
    begin
      if value
      then begin
        uiF := (uiF or Cardinal (PDLM_LHFEATURE_SWITCHABLE_FAN));
      end
      else begin
        uiF := (uiF and not Cardinal (PDLM_LHFEATURE_SWITCHABLE_FAN));
      end;
    end;

    function T_LHFeatures.Get_HasIntensitySensor : boolean;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_INTENSITY_SENSOR_TYPE)) > 0);
    end;

    function T_LHFeatures.Get_IntensitySensorType : byte;
    begin
      result := ((uiF and Cardinal (PDLM_LHFEATURE_INTENSITY_SENSOR_TYPE)) shr 24);
    end;

    procedure T_LHFeatures.Set_IntensitySensorType (value: byte);
    begin
      uiF := ((uiF and not Cardinal (PDLM_LHFEATURE_INTENSITY_SENSOR_TYPE)) or ((value and $0000000F) shl 24));
    end;


//-----------------------------------------------------------------------------
//
//      {T_LHData}
//
//-----------------------------------------------------------------------------

    function T_LHData.GetProtection : boolean;
    begin
      result := (CaseTMax_Class4Prot and LHDATA_CLASS4_PROT_MASK) > 0;
    end;

    procedure T_LHData.SetProtection (value: boolean);
    begin
      CaseTMax_Class4Prot := (CaseTMax_Class4Prot and LHDATA_MAXCASETEMP_MASK) or ifthen (value, LHDATA_CLASS4_PROT_MASK, 0);
    end;

    function T_LHData.GetCaseTMax : Word;
    begin
      result := (CaseTMax_Class4Prot and LHDATA_MAXCASETEMP_MASK);
    end;

    procedure T_LHData.SetCaseTMax (value: Word);
    begin
      if value <= LHDATA_MAXCASETEMP_MASK
      then begin
        CaseTMax_Class4Prot := (CaseTMax_Class4Prot and LHDATA_CLASS4_PROT_MASK) or (value and LHDATA_MAXCASETEMP_MASK);
      end;
    end;

    function T_LHData.LaserTypeByTypeIdx (value: word {i.e. T_LHData_LaserTypeIdx} ): T_LHData_LaserType;
    begin
      case T_LHData_LaserTypeIdx (value) of
        LHDATA_LASERTYPEIDX_UNDEFINED:      result := LHDATA_LASERTYPE_UNDEFINED;
        LHDATA_LASERTYPEIDX_LDH:            result := LHDATA_LASERTYPE_LDH;
        LHDATA_LASERTYPEIDX_LDH_FSL:        result := LHDATA_LASERTYPE_LDH_FSL;
        LHDATA_LASERTYPEIDX_LED:            result := LHDATA_LASERTYPE_LED;
        LHDATA_LASERTYPEIDX_TA_SHG:         result := LHDATA_LASERTYPE_TA_SHG;
        LHDATA_LASERTYPEIDX_FIBER:          result := LHDATA_LASERTYPE_FIBER;
        LHDATA_LASERTYPEIDX_FIBER_FSL:      result := LHDATA_LASERTYPE_FIBER_FSL;
        LHDATA_LASERTYPEIDX_FA:             result := LHDATA_LASERTYPE_FA;
        LHDATA_LASERTYPEIDX_FA_SHG:         result := LHDATA_LASERTYPE_FA_SHG;
        LHDATA_LASERTYPEIDX_BRIDGE:         result := LHDATA_LASERTYPE_BRIDGE;
      else
        result := LHDATA_LASERTYPE_UNDEFINED;
      end;
    end;

    function T_LHData.LaserTypeIdxByType (value: T_LHData_LaserType): word; {i.e. T_LHData_LaserTypeIdx}
    begin
      case value of
        LHDATA_LASERTYPE_UNDEFINED:      result := ord (LHDATA_LASERTYPEIDX_UNDEFINED);
        LHDATA_LASERTYPE_LDH:            result := ord (LHDATA_LASERTYPEIDX_LDH);
        LHDATA_LASERTYPE_LDH_FSL:        result := ord (LHDATA_LASERTYPEIDX_LDH_FSL);
        LHDATA_LASERTYPE_LED:            result := ord (LHDATA_LASERTYPEIDX_LED);
        LHDATA_LASERTYPE_TA_SHG:         result := ord (LHDATA_LASERTYPEIDX_TA_SHG);
        LHDATA_LASERTYPE_FIBER:          result := ord (LHDATA_LASERTYPEIDX_FIBER);
        LHDATA_LASERTYPE_FIBER_FSL:      result := ord (LHDATA_LASERTYPEIDX_FIBER_FSL);
        LHDATA_LASERTYPE_FA:             result := ord (LHDATA_LASERTYPEIDX_FA);
        LHDATA_LASERTYPE_FA_SHG:         result := ord (LHDATA_LASERTYPEIDX_FA_SHG);
        LHDATA_LASERTYPE_BRIDGE:         result := ord (LHDATA_LASERTYPEIDX_BRIDGE);
      else
        result := ord (LHDATA_LASERTYPEIDX_UNDEFINED);
      end;
    end;


//-----------------------------------------------------------------------------
//
//      {Library Functions}
//
//-----------------------------------------------------------------------------

  function PDLM_GetLibraryVersion (var cLibVersion: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_GetLibraryVersion(PC, TEMPVAR_LENGTH);
      cLibVersion := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetLibraryVersion


  function PDLM_GetUSBDriverInfo (var cUSBDrvName, cUSBDrvVers, cUSBDrvDate: string) : integer;
  var
    PCN: PAnsiChar;
    PCV: PAnsiChar;
    PCD: PAnsiChar;
  begin
    PCN := AllocMem(TEMPVAR_LENGTH);
    PCV := AllocMem(TEMPVAR_LENGTH);
    PCD := AllocMem(TEMPVAR_LENGTH);
    try
      result := _PDLM_GetUSBDriverInfo (PCN, TEMPVAR_LENGTH, PCV, TEMPVAR_LENGTH, PCD, TEMPVAR_LENGTH);
      if result = PDLM_ERROR_NONE then
      begin
        cUSBDrvName := string(PCN);
        cUSBDrvVers := string(PCV);
        cUSBDrvDate := string(PCD);
      end;
    finally
      FreeMem(PCD);
      FreeMem(PCV);
      FreeMem(PCN);
    end;
  end; // PDLM_GetUSBDriverInfo


  function PDLM_DecodeError (iErrCode: integer; var cErrorString: string) : integer;
  var
    BufLen: Cardinal;
    PC: PAnsiChar;
  begin
    BufLen := 0;
    Result := _PDLM_DecodeError(iErrCode, nil, BufLen);
    if Result = PDLM_ERROR_NONE
    then begin
      PC := AllocMem(BufLen);
      try
        Result := _PDLM_DecodeError(iErrCode, PC, BufLen);
        cErrorString := string(PC);
      finally
        FreeMem(PC);
      end;
    end;
  end; // PDLM_DecodeError

  function PDLM_GetTagDescription (uiTag: Cardinal; var uiTypeCode: Cardinal; var cName: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPLONGVAR_LENGTH);
    try
      Result := _PDLM_GetTagDescription(uiTag, uiTypeCode, PC);
      cName := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetTagDescription

  function PDLM_DecodeLHFeatures (uiLHFeatures: Cardinal; var cLHFeatures: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPLONGVAR_LENGTH);
    try
      Result := _PDLM_DecodeLHFeatures(uiLHFeatures, PC, TEMPLONGVAR_LENGTH  - 1);
      if (Result = PDLM_ERROR_NONE) then
        cLHFeatures := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_DecodeLHFeatures

  function PDLM_DecodePulseShape (uiPulseShape: Cardinal; var cPulseShape: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_DecodePulseShape(uiPulseShape, PC, TEMPVAR_LENGTH  - 1);
      if (Result = PDLM_ERROR_NONE) then
        cPulseShape := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_DecodePulseShape

  function PDLM_DecodeSystemStatus (Status: Cardinal; var cStatusText: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPLONGVAR_LENGTH);
    try
      Result := _PDLM_DecodeSystemStatus(Status, PC, TEMPLONGVAR_LENGTH  - 1);
      cStatusText := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_DecodeSystemStatus



  function PDLM_OpenDevice (iDevIdx: integer; var cSerialNumber: string) : integer;
  var
    SN: AnsiString;
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      if (Length(cSerialNumber) > 0) and (Length(cSerialNumber) < TEMPVAR_LENGTH) then
      begin
        SN := AnsiString(Trim(cSerialNumber));
        {$ifdef VER230}
          StrCopy(PC, PAnsiChar(strSN));
        {$else}
          System.AnsiStrings.StrCopy(PC, PAnsiChar(SN));
        {$endif}
      end;
      result := _PDLM_OpenDevice(iDevIdx, PC);
      cSerialNumber := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_OpenDevice


  function PDLM_OpenGetSerNumAndClose (iDevIdx: integer; var cSerialNumber: string) : integer;
  var
    SN: AnsiString;
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      if (Length(cSerialNumber) > 0) and (Length(cSerialNumber) < TEMPVAR_LENGTH) then
      begin
        SN := AnsiString(Trim(cSerialNumber));
        {$ifdef VER230}
          StrCopy(PC, PAnsiChar(strSN));
        {$else}
          System.AnsiStrings.StrCopy(PC, PAnsiChar(SN));
        {$endif}
      end;
      result := _PDLM_OpenGetSerNumAndClose(iDevIdx, PC);
      cSerialNumber := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_OpenGetSerNumAndClose


  function PDLM_CloseDevice (iDevIdx: integer) : integer;
  begin
    result := _PDLM_CloseDevice(iDevIdx);
  end; // PDLM_CloseDevice


  function PDLM_GetUSBStrDescriptor (iDevIdx: integer; var cDescriptor: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_GetUSBStrDescriptor(iDevIdx, PC, TEMPVAR_LENGTH);
      cDescriptor := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetUSBStrDescriptor


  function PDLM_GetHardwareInfo (iDevIdx: integer; var cInfos: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      result := _PDLM_GetHardwareInfo(iDevIdx, PC, TEMPVAR_LENGTH);
      cInfos := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetHardwareInfo


  function PDLM_GetLHFeatures (iDevIdx: integer; var LHFeatures: Cardinal) : integer;
  begin
    Result := _PDLM_GetLHFeatures(iDevIdx, LHFeatures);
  end; // PDLM_GetLHFeatures

  function PDLM_GetSystemStatus (iDevIdx: integer; var Status: Cardinal) : integer;
  begin
    Result := _PDLM_GetSystemStatus(iDevIdx, Status);
  end; // PDLM_GetSystemStatus


  function PDLM_GetQueuedError (iDevIdx: integer; var iErrCode: integer) : integer;
  begin
    Result := _PDLM_GetQueuedError(iDevIdx, iErrCode);
  end; // PDLM_GetQueuedError

  function PDLM_GetQueuedErrorString (iDevIdx: integer; iErrCode: integer; var cErrorString: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPLONGVAR_LENGTH);
    try
      Result := _PDLM_GetQueuedErrorString(iDevIdx, iErrCode, PC);
      cErrorString := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetQueuedErrorString


  function PDLM_GetFWVersion (iDevIdx: integer; var cFWVersion: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_GetFWVersion(iDevIdx, PC, TEMPVAR_LENGTH);
      cFWVersion := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetFWVersion

  function PDLM_GetFPGAVersion (iDevIdx: integer; var cFPGAVersion: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_GetFPGAVersion(iDevIdx, PC, TEMPVAR_LENGTH);
      cFPGAVersion := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetFPGAVersion

  function PDLM_GetLHVersion (iDevIdx: integer; var cLHVersion: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    try
      Result := _PDLM_GetLHVersion(iDevIdx, PC, TEMPVAR_LENGTH);
      cLHVersion := string(PC);
    finally
      FreeMem(PC);
    end;
  end; // PDLM_GetLHVersion


  function PDLM_GetLocked (iDevIdx: integer; var bLocked: boolean) : integer;
  var
    IsLocked: LongWord;
  begin
    IsLocked := 0;
    result := _PDLM_GetLocked (iDevIdx, IsLocked);
    bLocked  := IsLocked <> PDLM_LASER_UNLOCKED;
  end; // PDLM_GetLocked

  function PDLM_SetSoftLock (iDevIdx: integer; bLocked: boolean) : integer;
  begin
    Result := _PDLM_SetSoftLock (iDevIdx, ifthen (bLocked, PDLM_SOFTLOCK_LOCKED, PDLM_SOFTLOCK_UNLOCKED));
  end;  // PDLM_SetSoftLock

  function PDLM_GetSoftLock (iDevIdx: integer; var bLocked: boolean) : integer;
  var
    IsLocked: LongWord;
  begin
    IsLocked := 0;
    Result := _PDLM_GetSoftLock(iDevIdx, IsLocked);
    bLocked := IsLocked > PDLM_SOFTLOCK_UNLOCKED;
  end; // PDLM_GetSoftLock


  function PDLM_SetLaserMode (iDevIdx: integer; lmMode: T_LaserMode) : integer;
  begin
    Result := _PDLM_SetLaserMode(iDevIdx, ord (lmMode));
  end; // PDLM_SetLaserMode

  function PDLM_GetLaserMode (iDevIdx: integer; var lmMode: T_LaserMode) : integer;
  var
    uiMode: LongWord;
  begin
    uiMode := 0;
    result := _PDLM_GetLaserMode(iDevIdx, uiMode);
    if result = PDLM_ERROR_NONE
    then begin
      try
        lmMode := T_LaserMode(uiMode);
      except
        lmMode := PDLM_LASERMODE_UNASSIGNED;
      end;
    end;
  end; // PDLM_GetLaserMode


  function PDLM_SetTriggerMode (iDevIdx: integer; tsMode: T_TriggerSource) : integer;
  begin
    Result := _PDLM_SetTriggerMode(iDevIdx, ord (tsMode));
  end; // PDLM_SetTriggerMode

  function PDLM_GetTriggerMode (iDevIdx: integer; var tsMode: T_TriggerSource) : integer;
  var
    uiMode: LongWord;
  begin
    uiMode := 0;
    Result := _PDLM_GetTriggerMode(iDevIdx, uiMode);
    if Result = PDLM_ERROR_NONE
    then begin
      try
        tsMode := T_TriggerSource (uiMode);
      except
        tsMode := PDLM_TRIGGERSOURCE_INTERNAL;
      end;
    end;
  end; // PDLM_GetTriggerMode


  function PDLM_GetTriggerLevelLimits (iDevIdx: integer; var fMinTrigLevel, fMaxTrigLevel: Single) : integer;
  begin
    Result := _PDLM_GetTriggerLevelLimits(iDevIdx, fMinTrigLevel, fMaxTrigLevel);
  end; // PDLM_GetTriggerLevelLimits

  function PDLM_SetTriggerLevel (iDevIdx: integer; fTrigLevel: Single) : integer;
  begin
    Result := _PDLM_SetTriggerLevel(iDevIdx, fTrigLevel);
  end; // PDLM_SetTriggerLevel

  function PDLM_GetTriggerLevel (iDevIdx: integer; var fTrigLevel: Single) : integer;
  begin
    Result := _PDLM_GetTriggerLevel(iDevIdx, fTrigLevel);
  end; // PDLM_GetTriggerLevel


  function PDLM_GetTriggerFrequency (iDevIdx: integer; var uiFrequency: Cardinal) : integer;
  begin
    Result := _PDLM_GetTriggerFrequency(iDevIdx, uiFrequency);
  end; // PDLM_GetTriggerFrequency


  function PDLM_SetFastGate (iDevIdx: integer; bGateEnabled: boolean) : integer;
  begin
    Result := _PDLM_SetFastGate (iDevIdx, ifthen (bGateEnabled, PDLM_GATE_ENABLED, PDLM_GATE_DISABLED));
  end; // PDLM_SetFastGate

  function PDLM_GetFastGate (iDevIdx: integer; var bGateEnabled: boolean) : integer;
  var
    uiGateEna: LongWord;
  begin
    uiGateEna := 0;
    Result := _PDLM_GetFastGate (iDevIdx, uiGateEna);
    if Result = PDLM_ERROR_NONE
    then begin
      bGateEnabled := uiGateEna > PDLM_GATE_DISABLED;
    end;
  end; // PDLM_GetFastGate

  function PDLM_SetFastGateImp(iDevIdx: integer; uiImpClass: Cardinal): integer;
  begin
    Result := _PDLM_SetFastGateImp(iDevIdx, uiImpClass);
  end; // PDLM_SetFastGateImp

  function PDLM_GetFastGateImp(iDevIdx: integer; var uiImpClass: Cardinal): integer;
  begin
    Result := _PDLM_GetFastGateImp (iDevIdx, uiImpClass);
  end; // PDLM_GetFastGateImp


  function PDLM_SetSlowGate (iDevIdx: integer; bGateEnabled: boolean) : integer;
  begin
    Result := _PDLM_SetSlowGate (iDevIdx, ifthen (bGateEnabled, PDLM_GATE_ENABLED, PDLM_GATE_DISABLED));
  end; // PDLM_SetSlowGate


  function PDLM_GetSlowGate(iDevIdx: integer; var bGateEnabled: boolean): integer;
  var
    uiGateEna: LongWord;
  begin
    uiGateEna := 0;
    Result := _PDLM_GetSlowGate (iDevIdx, uiGateEna);
    bGateEnabled := uiGateEna <> PDLM_GATE_DISABLED;
  end; // PDLM_GetSlowGate


  function PDLM_SetTempScale (iDevIdx: integer; uiScaleID: Cardinal) : integer;
  begin
    Result := _PDLM_SetTempScale(iDevIdx, uiScaleID);
  end; // PDLM_SetTempScale

  function PDLM_GetTempScale(iDevIdx: integer; var uiScaleID: Cardinal): integer;
  begin
    Result := _PDLM_GetTempScale(iDevIdx, uiScaleID);
  end; // PDLM_GetTempScale


  function PDLM_GetLHTargetTempLimits (iDevIdx: integer; uiScaleID: Cardinal; var fMinTemp, fMaxTemp: Single) : integer;
  begin
    if InRange(uiScaleID, ord(Low(PDLM_TEMPSCALE_UNITS)), ord(High(PDLM_TEMPSCALE_UNITS)))
    then begin
      result := _PDLM_GetLHTargetTempLimits(iDevIdx, uiScaleID, fMinTemp, fMaxTemp);
    end
    else begin
      result := PDLM_ERROR_ILLEGAL_VALUE;
    end;
  end;  // PDLM_GetLHTargetTempLimits


  function PDLM_SetLHTargetTemp (iDevIdx: integer; uiScaleID: Cardinal; fTargTemp: Single) : integer;
  begin
    if InRange(uiScaleID, ord(Low(PDLM_TEMPSCALE_UNITS)), Ord(High(PDLM_TEMPSCALE_UNITS)))
    then begin
      result := _PDLM_SetLHTargetTemp(iDevIdx, uiScaleID, fTargTemp);
    end
    else begin
      result := PDLM_ERROR_ILLEGAL_VALUE;
    end;
  end; // PDLM_SetLHTargetTemp

  function PDLM_GetLHTargetTemp(iDevIdx: integer; uiScaleID: Cardinal; var fTargTemp: Single): integer;
  begin
    if InRange(uiScaleID, ord(Low(PDLM_TEMPSCALE_UNITS)), Ord(High(PDLM_TEMPSCALE_UNITS)))
    then begin
      result := _PDLM_GetLHTargetTemp(iDevIdx, uiScaleID, fTargTemp);
    end
    else begin
      result := PDLM_ERROR_ILLEGAL_VALUE;
    end;
  end; // PDLM_GetLHTargetTemp


  function PDLM_GetLHCurrentTemp (iDevIdx: integer; uiScaleID: Cardinal; var fCurrTemp: Single) : integer;
  begin
    if InRange(uiScaleID, ord(Low(PDLM_TEMPSCALE_UNITS)), Ord(High(PDLM_TEMPSCALE_UNITS)))
    then begin
      Result := _PDLM_GetLHCurrentTemp(iDevIdx, uiScaleID, fCurrTemp);
    end
    else begin
      Result := PDLM_ERROR_ILLEGAL_VALUE;
    end;
  end; // PDLM_GetLHCurrentTemp


  function PDLM_GetLHCaseTemp(iDevIdx: integer; uiScaleID: Cardinal; var fCaseTemp: Single): integer;
  begin
    if InRange(uiScaleID, ord(Low(PDLM_TEMPSCALE_UNITS)), Ord(High(PDLM_TEMPSCALE_UNITS)))
    then begin
      result := _PDLM_GetLHCaseTemp(iDevIdx, uiScaleID, fCaseTemp);
    end
    else begin
      result := PDLM_ERROR_ILLEGAL_VALUE;
    end;
  end; // PDLM_GetLHCaseTemp


  function PDLM_GetLHWavelength (iDevIdx: integer; var fWavelength: Single) : integer;
  begin
    Result := _PDLM_GetLHWavelength(iDevIdx, fWavelength);
  end; // PDLM_GetLHWavelength


  function PDLM_GetLHFrequencyLimits (iDevIdx: integer; var uiMinFreq, uiMaxFreq: Cardinal): integer;
  begin
    Result := _PDLM_GetLHFrequencyLimits(iDevIdx, uiMinFreq, uiMaxFreq);
  end; // PDLM_GetLHFrequencyLimits

  function PDLM_SetFrequency(iDevIdx: integer; uiFrequency: Cardinal): integer;
  begin
    Result := _PDLM_SetFrequency(iDevIdx, uiFrequency);
  end; // PDLM_SetFrequency

  function PDLM_GetFrequency(iDevIdx: integer; var uiFrequency: Cardinal): integer;
  begin
    Result := _PDLM_GetFrequency (iDevIdx, uiFrequency);
  end; // PDLM_GetFrequency


  function PDLM_SetPulsePowerPermille (iDevIdx: integer; uiPulsePowerPermille: Cardinal) : integer;
  begin
    Result := _PDLM_SetPulsePowerPermille(iDevIdx, uiPulsePowerPermille);
  end; // PDLM_SetPulsePowerPermille


  function PDLM_GetPulsePowerPermille(iDevIdx: integer; var uiPulsePowerPermille: Cardinal): integer;
  begin
    Result := _PDLM_GetPulsePowerPermille(iDevIdx, uiPulsePowerPermille);
  end; // PDLM_GetPulsePowerPermille


  function PDLM_GetPulsePowerLimits (iDevIdx: integer; var fMinPulsePower, fMaxPulsePower: Single) : integer;
  begin
    Result := _PDLM_GetPulsePowerLimits (iDevIdx, fMinPulsePower, fMaxPulsePower);
  end; // PDLM_GetPulsePowerLimits

  function PDLM_SetPulsePower(iDevIdx: integer; fPulsePower: Single): integer;
  begin
    Result := _PDLM_SetPulsePower(iDevIdx, fPulsePower);
  end; // PDLM_SetPulsePower

  function PDLM_GetPulsePower(iDevIdx: integer; var fPulsePower: Single): integer;
  begin
    Result := _PDLM_GetPulsePower (iDevIdx, fPulsePower);
  end; // PDLM_GetPulsePower

  function PDLM_GetPulseShape (iDevIdx: integer; var uiPulseShape: Cardinal) : integer;
  begin
    Result := _PDLM_GetPulseShape (iDevIdx, uiPulseShape);
  end; // PDLM_GetPulseShape


  function PDLM_SetLDHPulsePowerTable (iDevIdx: integer; uiTableIdx: Cardinal) : integer;
  begin
    Result := _PDLM_SetLDHPulsePowerTable (iDevIdx, uiTableIdx);
  end;  // PDLM_SetLDHPulsePowerTable

  function PDLM_GetLDHPulsePowerTable (iDevIdx: integer; var uiTableIdx: Cardinal) : integer;
  begin
    Result := _PDLM_GetLDHPulsePowerTable (iDevIdx, uiTableIdx);
  end;  // PDLM_GetLDHPulsePowerTable


  function PDLM_GetCwPowerLimits(iDevIdx: integer; var fMinCwPower, fMaxCwPower: Single): integer;
  begin
    Result := _PDLM_GetCwPowerLimits(iDevIdx, fMinCwPower, fMaxCwPower);
  end; // PDLM_GetCwPowerLimits

  function PDLM_SetCwPower(iDevIdx: integer; fCwPower: Single): integer;
  begin
    Result := _PDLM_SetCwPower(iDevIdx, fCwPower);
  end; // PDLM_SetCwPower

  function PDLM_GetCwPower(iDevIdx: integer; var fCwPower: Single): integer;
  begin
    Result := _PDLM_GetCwPower(iDevIdx, fCwPower);
  end; // PDLM_GetCwPower

  function PDLM_SetCWPowerPermille(iDevIdx: integer; uiCwPowerPermille: Cardinal): integer;
  begin
    Result := _PDLM_SetCWPowerPermille(iDevIdx, uiCwPowerPermille);
  end; // PDLM_SetCWPowerPermille

  function PDLM_GetCWPowerPermille (iDevIdx: integer; var uiCwPowerPermille: Cardinal): integer;
  begin
    Result := _PDLM_GetCWPowerPermille (iDevIdx, uiCwPowerPermille);
  end; // PDLM_GetCWPowerPermille


  function PDLM_SetBurst (iDevIdx: integer; uiBurstLen, uiPeriodLen: Cardinal) : integer;
  begin
    Result := _PDLM_SetBurst(iDevIdx, uiBurstLen, uiPeriodLen);
  end; // PDLM_SetBurst

  function PDLM_GetBurst(iDevIdx: integer; var uiBurstLen, uiPeriodLen: Cardinal): integer;
  begin
    Result := _PDLM_GetBurst(iDevIdx, uiBurstLen, uiPeriodLen);
  end; // PDLM_GetBurst

  function PDLM_SetBuzzer(iDevIdx: integer; bBuzzOn: Boolean): integer;
  begin
    Result := _PDLM_SetBuzzer(iDevIdx, IfThen(bBuzzOn, PDLM_BUZZERTONE_ON, PDLM_BUZZERTONE_OFF));
  end; // PDLM_SetBuzzer

  function PDLM_SetLHFan(iDevIdx: integer; bFanRunning: Boolean): integer;
  begin
    Result := _PDLM_SetLHFan (iDevIdx, IfThen(bFanRunning, PDLM_LHEADFAN_ON, PDLM_LHEADFAN_OFF));
  end; // PDLM_SetLHFan

  function PDLM_GetLHFan (iDevIdx: integer; var bFanRunning: boolean): integer;
  var
    IsFanRunning: LongWord;
  begin
    IsFanRunning := 0;
    Result := _PDLM_GetLHFan(iDevIdx, IsFanRunning);
    bFanRunning := IsFanRunning <> PDLM_LHEADFAN_OFF;
  end; // PDLM_GetLHFan

  function PDLM_SetExclusiveUI (iDevIdx: integer; bUIExclusive: Boolean): integer;
  begin
    Result := _PDLM_SetExclusiveUI (iDevIdx, IfThen(bUIExclusive, PDLM_UI_EXCLUSIVE, PDLM_UI_COOPERATIVE));
  end; // PDLM_SetExclusiveUI

  function PDLM_GetExclusiveUI(iDevIdx: integer; var bUIExclusive: boolean): integer;
  var
    IsUIExclusive: LongWord;
  begin
    IsUIExclusive := 0;
    Result := _PDLM_GetExclusiveUI(iDevIdx, IsUIExclusive);
    bUIExclusive := IsUIExclusive <> PDLM_UI_COOPERATIVE;
  end; // PDLM_GetExclusiveUI


  function PDLM_GetPresetInfo (iDevIdx: integer; uiPresetIdx: Cardinal; var cPresetInfo: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    Result := _PDLM_GetPresetInfo(iDevIdx, uiPresetIdx, PC, TEMPVAR_LENGTH - 1);
    cPresetInfo := string(PC);
    FreeMem(PC);
  end; // PDLM_GetPresetInfo

  function PDLM_GetPresetText (iDevIdx: integer; uiPresetIdx: Cardinal; var cPresetText: string) : integer;
  var
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPVAR_LENGTH);
    Result := _PDLM_GetPresetText(iDevIdx, uiPresetIdx, PC, TEMPVAR_LENGTH - 1);
    cPresetText := string(PC);
    FreeMem(PC);
  end; // PDLM_GetPresetText

  function PDLM_StorePreset(iDevIdx: integer; uiPresetIdx: Cardinal; const cPresetInfo: string): integer;
  var
    PInfo: AnsiString;
  begin
    PInfo := AnsiString(cPresetInfo);
    Result := _PDLM_StorePreset (iDevIdx, uiPresetIdx, PAnsiChar(PInfo), Length(PInfo) + 1);
  end;  // PDLM_StorePreset

  function PDLM_RecallPreset(iDevIdx: integer; uiPresetIdx: Cardinal): integer;
  begin
    Result := _PDLM_RecallPreset(iDevIdx, uiPresetIdx);
  end;  // PDLM_RecallPreset

  function PDLM_ErasePreset(iDevIdx: integer; uiPresetIdx: Cardinal): integer;
  begin
    Result := _PDLM_ErasePreset(iDevIdx, uiPresetIdx);
  end;  // PDLM_ErasePreset


  function PDLM_SetHWND (iDevIdx: integer; WindowHandle: HWND) : integer;
  begin
    Result := _PDLM_SetHWND(iDevIdx, WindowHandle);
  end; // PDLM_SetHWND

  function PDLM_ResetStateHandling(iDevIdx: integer; uiMask: Cardinal; uiStatus: Cardinal): integer;
  begin
    Result := _PDLM_ResetStateHandling(iDevIdx, uiMask, uiStatus);
  end; // PDLM_ResetStateHandling


  function PDLM_GetQueuedChanges(iDevIdx: integer; var TagValueList: T_TaggedValueList; var uiListLen: Cardinal): integer;
  var
    pTVL: Pointer;
    pTV: P_TaggedValue;
    i: Integer;
  begin
    SetLength(TagValueList, 0);
    pTVL := AllocMem(TEMPLONGVAR_LENGTH);
    uiListLen := TEMPLONGVAR_LENGTH div SizeOf(T_TaggedValue);
    Result := _PDLM_GetQueuedChanges(iDevIdx, pTVL, uiListLen);
    if Result = PDLM_ERROR_NONE then
    begin
      SetLength(TagValueList, uiListLen+1);
      pTV := pTVL;
      for i := 0 to High(TagValueList)-1 do
      begin
        TagValueList[i] := pTV^;
        Inc(pTV);
      end;
    end;
    FreeMem(pTVL);
  end; // PDLM_GetQueuedChanges


  function PDLM_GetTaggedValueList (iDevIdx: integer; iListLen: integer; var TaggedValueList: T_TaggedValueList) : integer;
  begin
    Result := _PDLM_GetTagValueList(iDevIdx, iListLen, @TaggedValueList[0]);
  end; // PDLM_GetTaggedValueList


  function PDLM_TerminateLHDemoMode(iDevIdx: integer; const cDemoReleaseKey: string): integer;
  var
    strReleaseKey: AnsiString;
  begin
    strReleaseKey := AnsiString(cDemoReleaseKey);
    Result := _PDLM_TerminateLHDemoMode (iDevIdx, PAnsiChar(strReleaseKey));
  end; // PDLM_TerminateLHDemoMode


  function PDLM_CreateSupportRequestText (iDevIdx: integer; const cPreamble, cCallingSW: string; const iOptions: integer; var cSupportInfo: string) : integer;
  var
    strPreamble,
    strCallingSW: AnsiString;
    PC: PAnsiChar;
  begin
    PC := AllocMem(TEMPLONGVAR_LENGTH);
    strPreamble := AnsiString(cPreamble);
    strCallingSW := AnsiString(cCallingSW);
    Result := _PDLM_CreateSupportRequestText(iDevIdx, PAnsiChar(strPreamble), PAnsiChar(strCallingSW), iOptions, TEMPLONGVAR_LENGTH, PC);
    cSupportInfo := string(PC);
    FreeMem(PC);
  end; // PDLM_CreateSupportRequestText


  function PDLM_FirmwareUpdate (iDevIdx: integer; fileName: string) : integer;
  var
    strFilename: AnsiString;
  begin
    strFilename := AnsiString (fileName);
    Result := _PDLM_FirmwareUpdate(iDevIdx, PAnsiChar(strFileName));
  end; // PDLM_FirmwareUpdate

  function PDLM_FirmwareUpdateStatus(iDevIdx: integer; var fwuInfo: T_FirmwareUpdateInfo): integer;
  begin
    Result := _PDLM_FirmwareUpdateStatus(iDevIdx, fwuInfo);
  end; // PDLM_FirmwareUpdateStatus

  function PDLM_GetDeviceData(iDevIdx: integer; var DevData: T_DeviceData): integer;
  begin
    Result := _PDLM_GetDeviceData(iDevIdx, @DevData, SizeOf(T_DeviceData));
  end; // PDLM_GetDeviceData

  function PDLM_GetLHData(iDevIdx: integer; var LHData: T_LHData): integer;
  begin
    Result := _PDLM_GetLHData (iDevIdx, @LHData, SizeOf(T_LHData));
  end; // PDLM_GetLHData

  function PDLM_GetLHInfo(iDevIdx: integer; var LHInfo: T_LHInfo): integer;
  begin
    Result := _PDLM_GetLHInfo(iDevIdx, @LHInfo, SizeOf(T_LHInfo));
  end; // PDLM_GetLHInfo


  function GetCheckProc(hModule: HMODULE; lpProcName: LPCSTR): FARPROC;
  begin
    if bPLDMImportLibOK
    then begin
      result := GetProcAddress(hModule, lpProcName);
      if not Assigned(Result)
      then begin
        strLibVersion := lpProcName + ' not found!';
        bPLDMImportLibOK := False;
      end;
    end
    else begin
      result := nil;
    end;
  end;

  procedure LoadLib;
  var
    iRet: Integer;
  begin
    bPLDMImportLibOK := True;
    //
    hdlDLL := LoadLibrary(STR_LIB_NAME);
    //
    if hdlDLL = 0
    then begin
      strLibVersion := STR_LIB_NAME + ' not found!';
      bPLDMImportLibOK := false;
      exit;
    end
    else begin
      @_PDLM_GetLibraryVersion        := GetCheckProc (hdlDLL, 'PDLM_GetLibraryVersion');
      @_PDLM_GetUSBDriverInfo         := GetCheckProc (hdlDLL, 'PDLM_GetUSBDriverInfo');
      @_PDLM_DecodeError              := GetCheckProc (hdlDLL, 'PDLM_DecodeError');
      @_PDLM_GetTagDescription        := GetCheckProc (hdlDLL, 'PDLM_GetTagDescription');
      @_PDLM_DecodeLHFeatures         := GetCheckProc (hdlDLL, 'PDLM_DecodeLHFeatures');
      @_PDLM_DecodePulseShape         := GetCheckProc (hdlDLL, 'PDLM_DecodePulseShape');
      @_PDLM_DecodeSystemStatus       := GetCheckProc (hdlDLL, 'PDLM_DecodeSystemStatus');
      //
      @_PDLM_OpenDevice               := GetCheckProc (hdlDLL, 'PDLM_OpenDevice');
      @_PDLM_OpenGetSerNumAndClose    := GetCheckProc (hdlDLL, 'PDLM_OpenGetSerNumAndClose');
      @_PDLM_CloseDevice              := GetCheckProc (hdlDLL, 'PDLM_CloseDevice');
      @_PDLM_GetUSBStrDescriptor      := GetCheckProc (hdlDLL, 'PDLM_GetUSBStrDescriptor');
      @_PDLM_GetHardwareInfo          := GetCheckProc (hdlDLL, 'PDLM_GetHardwareInfo');
      @_PDLM_GetFWVersion             := GetCheckProc (hdlDLL, 'PDLM_GetFWVersion');
      @_PDLM_GetFPGAVersion           := GetCheckProc (hdlDLL, 'PDLM_GetFPGAVersion');
      @_PDLM_GetLHVersion             := GetCheckProc (hdlDLL, 'PDLM_GetLHVersion');
      @_PDLM_GetLHFeatures            := GetCheckProc (hdlDLL, 'PDLM_GetLHFeatures');
      //
      @_PDLM_GetSystemStatus          := GetCheckProc (hdlDLL, 'PDLM_GetSystemStatus');
      @_PDLM_GetQueuedError           := GetCheckProc (hdlDLL, 'PDLM_GetQueuedError');
      @_PDLM_GetQueuedErrorString     := GetCheckProc (hdlDLL, 'PDLM_GetQueuedErrorString');
      //
      @_PDLM_SetHWND                  := GetCheckProc (hdlDLL, 'PDLM_SetHWND');
      @_PDLM_ResetStateHandling       := GetCheckProc (hdlDLL, 'PDLM_ResetStateHandling');
      @_PDLM_GetQueuedChanges         := GetCheckProc (hdlDLL, 'PDLM_GetQueuedChanges');
      //
      @_PDLM_GetLocked                := GetCheckProc (hdlDLL, 'PDLM_GetLocked');
      @_PDLM_SetSoftLock              := GetCheckProc (hdlDLL, 'PDLM_SetSoftLock');
      @_PDLM_GetSoftLock              := GetCheckProc (hdlDLL, 'PDLM_GetSoftLock');
      //
      @_PDLM_GetDeviceData            := GetCheckProc (hdlDLL, 'PDLM_GetDeviceData');
      @_PDLM_GetLHData                := GetCheckProc (hdlDLL, 'PDLM_GetLHData');
      @_PDLM_GetLHInfo                := GetCheckProc (hdlDLL, 'PDLM_GetLHInfo');
      //
      @_PDLM_SetLaserMode             := GetCheckProc (hdlDLL, 'PDLM_SetLaserMode');
      @_PDLM_GetLaserMode             := GetCheckProc (hdlDLL, 'PDLM_GetLaserMode');
      @_PDLM_SetTriggerMode           := GetCheckProc (hdlDLL, 'PDLM_SetTriggerMode');
      @_PDLM_GetTriggerMode           := GetCheckProc (hdlDLL, 'PDLM_GetTriggerMode');
      //
      @_PDLM_GetTriggerLevelLimits    := GetCheckProc (hdlDLL, 'PDLM_GetTriggerLevelLimits');
      @_PDLM_SetTriggerLevel          := GetCheckProc (hdlDLL, 'PDLM_SetTriggerLevel');
      @_PDLM_GetTriggerLevel          := GetCheckProc (hdlDLL, 'PDLM_GetTriggerLevel');
      @_PDLM_GetTriggerFrequency      := GetCheckProc (hdlDLL, 'PDLM_GetExtTriggerFrequency');
      //
      @_PDLM_SetFastGate              := GetCheckProc (hdlDLL, 'PDLM_SetFastGate');
      @_PDLM_GetFastGate              := GetCheckProc (hdlDLL, 'PDLM_GetFastGate');
      @_PDLM_SetFastGateImp           := GetCheckProc (hdlDLL, 'PDLM_SetFastGateImp');
      @_PDLM_GetFastGateImp           := GetCheckProc (hdlDLL, 'PDLM_GetFastGateImp');
      @_PDLM_SetSlowGate              := GetCheckProc (hdlDLL, 'PDLM_SetSlowGate');
      @_PDLM_GetSlowGate              := GetCheckProc (hdlDLL, 'PDLM_GetSlowGate');
      //
      @_PDLM_SetTempScale             := GetCheckProc (hdlDLL, 'PDLM_SetTempScale');
      @_PDLM_GetTempScale             := GetCheckProc (hdlDLL, 'PDLM_GetTempScale');
      @_PDLM_GetLHTargetTempLimits    := GetCheckProc (hdlDLL, 'PDLM_GetLHTargetTempLimits');
      @_PDLM_SetLHTargetTemp          := GetCheckProc (hdlDLL, 'PDLM_SetLHTargetTemp');
      @_PDLM_GetLHTargetTemp          := GetCheckProc (hdlDLL, 'PDLM_GetLHTargetTemp');
      @_PDLM_GetLHCurrentTemp         := GetCheckProc (hdlDLL, 'PDLM_GetLHCurrentTemp');
      @_PDLM_GetLHCaseTemp            := GetCheckProc (hdlDLL, 'PDLM_GetLHCaseTemp');
      //
      @_PDLM_GetLHWavelength          := GetCheckProc (hdlDLL, 'PDLM_GetLHWavelength');
      //
      @_PDLM_GetLHFrequencyLimits     := GetCheckProc (hdlDLL, 'PDLM_GetFrequencyLimits');
      @_PDLM_SetFrequency             := GetCheckProc (hdlDLL, 'PDLM_SetFrequency');
      @_PDLM_GetFrequency             := GetCheckProc (hdlDLL, 'PDLM_GetFrequency');
      //
      @_PDLM_SetPulsePowerPermille    := GetCheckProc (hdlDLL, 'PDLM_SetPulsePowerPermille');
      @_PDLM_GetPulsePowerPermille    := GetCheckProc (hdlDLL, 'PDLM_GetPulsePowerPermille');
      @_PDLM_GetPulsePowerLimits      := GetCheckProc (hdlDLL, 'PDLM_GetPulsePowerLimits');
      @_PDLM_SetPulsePower            := GetCheckProc (hdlDLL, 'PDLM_SetPulsePower');
      @_PDLM_GetPulsePower            := GetCheckProc (hdlDLL, 'PDLM_GetPulsePower');
      @_PDLM_GetPulseShape            := GetCheckProc (hdlDLL, 'PDLM_GetPulseShape');
      @_PDLM_SetLDHPulsePowerTable    := GetCheckProc (hdlDLL, 'PDLM_SetLDHPulsePowerTable');
      @_PDLM_GetLDHPulsePowerTable    := GetCheckProc (hdlDLL, 'PDLM_GetLDHPulsePowerTable');
      //
      @_PDLM_SetCWPowerPermille       := GetCheckProc (hdlDLL, 'PDLM_SetCwPowerPermille');
      @_PDLM_GetCWPowerPermille       := GetCheckProc (hdlDLL, 'PDLM_GetCwPowerPermille');
      @_PDLM_GetCwPowerLimits         := GetCheckProc (hdlDLL, 'PDLM_GetCwPowerLimits');
      @_PDLM_SetCwPower               := GetCheckProc (hdlDLL, 'PDLM_SetCwPower');
      @_PDLM_GetCwPower               := GetCheckProc (hdlDLL, 'PDLM_GetCwPower');
      //
      @_PDLM_SetBurst                 := GetCheckProc (hdlDLL, 'PDLM_SetBurst');
      @_PDLM_GetBurst                 := GetCheckProc (hdlDLL, 'PDLM_GetBurst');
      //
      @_PDLM_SetBuzzer                := GetCheckProc (hdlDLL, 'PDLM_SetBuzzer');
      //
      @_PDLM_SetLHFan                 := GetCheckProc (hdlDLL, 'PDLM_SetLHFan');
      @_PDLM_GetLHFan                 := GetCheckProc (hdlDLL, 'PDLM_GetLHFan');
      //
      @_PDLM_SetExclusiveUI           := GetCheckProc (hdlDLL, 'PDLM_SetExclusiveUI');
      @_PDLM_GetExclusiveUI           := GetCheckProc (hdlDLL, 'PDLM_GetExclusiveUI');
      //
      @_PDLM_GetPresetInfo            := GetCheckProc (hdlDLL, 'PDLM_GetPresetInfo');
      @_PDLM_GetPresetText            := GetCheckProc (hdlDLL, 'PDLM_GetPresetText');
      @_PDLM_StorePreset              := GetCheckProc (hdlDLL, 'PDLM_StorePreset');
      @_PDLM_RecallPreset             := GetCheckProc (hdlDLL, 'PDLM_RecallPreset');
      @_PDLM_ErasePreset              := GetCheckProc (hdlDLL, 'PDLM_ErasePreset');
      //
      @_PDLM_GetTagValueList          := GetCheckProc (hdlDLL, 'PDLM_GetTagValueList');
      @_PDLM_TerminateLHDemoMode      := GetCheckProc (hdlDLL, 'PDLM_TerminateLHDemoMode');
      @_PDLM_CreateSupportRequestText := GetCheckProc (hdlDLL, 'PDLM_CreateSupportRequestText');
      //
      @_PDLM_FirmwareUpdate           := GetCheckProc (hdlDLL, 'PDLM_FirmwareUpdate');
      @_PDLM_FirmwareUpdateStatus     := GetCheckProc (hdlDLL, 'PDLM_FirmwareUpdateStatus');
      //
      //
      if bPLDMImportLibOK
      then begin
        strLibVersion := '';
        iRet := PDLM_GetLibraryVersion (strLibVersion);
        if (iRet = PDLM_ERROR_NONE)
        then begin
          if (0 > StrLComp(PChar(strLibVersion), PChar(LIB_VERSION_REFERENCE), LIB_VERSION_COMPLEN))
          then begin
            strLibVersion := 'LibVers ' + LIB_VERSION_REFERENCE + 'x expected, ' + strLibVersion + ' found!';
            bPLDMImportLibOK := false;
          end;
        end
        else begin
          strLibVersion := 'GetLibVers-Error ' + IntToStr (iRet);
          bPLDMImportLibOK := false;
        end;
      end
      else begin
        strLibVersion := 'ImportLib-Error!';
      end;
      //
    end;
  end;

  procedure CloseLib;
  begin
    FreeLibrary(hdlDLL);
  end;


initialization
  {$ifdef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    bCalledByPolling                  := false;
  {$endif}

  SetLength (TmpTaggedValList, TEMPVAR_LENGTH);

  bPLDMImportLibOK    := true;
  LoadLib;
  //
finalization
  //
  SetLength(TmpTaggedValList, 0);
  //
  CloseLib;
  //
end.
