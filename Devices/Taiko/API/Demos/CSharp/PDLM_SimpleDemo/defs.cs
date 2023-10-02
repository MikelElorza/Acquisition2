using System;

namespace PDLM_SimpleDemo
{
  // API constants
  public enum PDLM_Errors : Int32
  {
    NONE = 0,
    DEVICE_NOT_FOUND = -1,
    NOT_CONNECTED = -2,
    ALREADY_CONNECTED = -3,
    WRONG_USBIDX = -4,
    ILLEGAL_INDEX = -5,
    ILLEGAL_VALUE = -6,
    USB_MSG_INTEGRITY_VIOLATED = -7,
    ILLEGAL_NODEINDEX = -8,
    WRONG_PARAMETER = -9,
    INCOMPATIBLE_FW = -10,
    WRONG_SERIALNUMBER = -11,
    WRONG_PRODUCTMODEL = -12,
    BUFFER_TOO_SMALL = -13,
    INDEX_NOT_FOUND = -14,
    FW_MEMORY_ALLOCATION_ERROR = -15,
    FREQUENCY_TOO_HIGH = -16,
    DEVICE_BUSY_OR_BLOCKED = -17,
    USB_INAPPROPRIATE_DEVICE = -18,
    USB_GET_DSCR_FAILED = -19,
    USB_INVALID_HANDLE = -20,
    USB_INVALID_DSCRBUF = -21,
    USB_IOCTL_FAILED = -22,
    USB_VCMD_FAILED = -23,
    USB_NO_SUCH_PIPE = -24,
    USB_REGNTFY_FAILED = -25,
    USBDRIVER_NO_MEMORY = -26,
    DEVICE_ALREADY_OPENED = -27,
    OPEN_DEVICE_FAILED = -28,
    USB_UNKNOWN_DEVICE = -29,
    EMPTY_QUEUE = -30,
    FEATURE_NOT_AVAILABLE = -31,
    UNINITIALIZED_DATA = -32,
    DLL_MEMORY_ALLOCATION_ERROR = -33,
    UNKNOWN_TAG = -34,
    OPEN_FILE = -35,
    FW_FOOTER = -36,
    FIRMWARE_UPDATE = -37,
    FIRMWARE_UPDATE_RUNNING = -38,
    INCOMPATIBLE_HARDWARE = -39,
    VALUE_NOT_AVAILABLE = -40,
    USB_SET_TIMED_OUT = -41,
    USB_GET_TIMED_OUT = -42,
    USB_SET_FAILED = -43,
    USB_GET_FAILED = -44,
    USB_DATA_SIZE_TOO_BIG = -45,
    FW_VERSION_CHECK = -46,
    WRONG_DRIVER = -47,
    WINUSB_STORED_ERROR = -48,
    PDLM_MAX_ERROR_NUM = -48,
    // .. to be continued
    //
    UNKNOWN_ERRORCODE = -999,
    //
    HW_ERROR_OFFSET = -1000,
    HW_MAX_ERROR_NUM = -2999,
    //
    FUNCTION_IS_PQ_INTERNAL = -9000,
    FUNCTION_NOT_IMPLEMENTED_YET = -9999,
    INITIAL_VALUE = 1
  }

  public enum PDLM_Tags : UInt32
  {
    NONE = 0x00000000,
    Locked = 0x00000010,
    SoftLock = 0x00000011,
    KeyLock = 0x00000012,
    Class_IV_Lock = 0x00000014,
    Interlock = 0x00000018,
    LaserMode = 0x00000020,
    LDH_PulsePowerTable = 0x00000021,
    TriggerMode = 0x00000030,
    TriggerLevelRaw = 0x00000040,
    TriggerLevelRawLoLimit = 0x00000041,
    TriggerLevelRawHiLimit = 0x00000042,
    TriggerLevel = 0x00000048,
    TriggerLevelLoLimit = 0x00000049,
    TriggerLevelHiLimit = 0x0000004A,
    FastGate = 0x00000050,
    FastGateImp = 0x00000060,
    SlowGate = 0x00000070,
    TargetTempRaw = 0x00000090,
    TargetTempRawLoLimit = 0x00000091,
    TargetTempRawHiLimit = 0x00000092,
    CurrentTempRaw = 0x00000094,
    CaseTempRaw = 0x00000095,
    TargetTemp = 0x00000098,
    TargetTempLoLimit = 0x00000099,
    TargetTempHiLimit = 0x0000009A,
    CurrentTemp = 0x0000009C,
    CaseTemp = 0x0000009D,
    TempScale = 0x0000009F,
    Frequency = 0x000000A8,
    FrequencyLoLimit = 0x000000A9,
    FrequencyHiLimit = 0x000000AA,
    PulsePowerRaw = 0x000000B0,
    PulsePowerRawLoLimit = 0x000000B1,
    PulsePowerRawHiLimit = 0x000000B2,
    PulsePowerPermille = 0x000000B4,
    PulseShape = 0x000000B5,
    PulsePower = 0x000000B8,
    PulsePowerLoLimit = 0x000000B9,
    PulsePowerHiLimit = 0x000000BA,
    PulsePowerNanowatt = 0x000000BC,
    PulsePowerVoltage = 0x000000BE,
    PulseEnergy = 0x000000BF,
    CwPowerRaw = 0x000000C0,
    CwPowerRawLoLimit = 0x000000C1,
    CwPowerRawHiLimit = 0x000000C2,
    CwPowerPermille = 0x000000C4,
    CwPower = 0x000000C8,
    CwPowerLoLimit = 0x000000C9,
    CwPowerHiLimit = 0x000000CA,
    CwPowerMicroWatt = 0x000000CC,
    BurstLen = 0x000000D0,
    BurstPeriod = 0x000000E0,
    LDH_Fan = 0x000000F0,
    UI_Exclusive = 0x00000100
  }

  public enum PDLM_Tagtype : UInt32
  {
    BOOL = 0x00000001,
    //
    UINT = 0x00010001,
    UINT_ENUM = 0x00010002,          // for list-driven values
    UINT_DAC = 0x00010003,          // for any direct given raw DAC value
    UINT_IN_TENTH = 0x00010101,          // for temperatures in tenth of a celsius degree
    UINT_IN_PERCENT = 0x00010201,          // for interpolation tables
    UINT_IN_PERMILLE = 0x00010301,          // for permille values in power or current interpolation tables
    UINT_IN_PERTHOUSAND = 0x00010302,          // for (positive only) milli Volts, milli Watts, etc.
    UINT_IN_PERMYRIAD = 0x00010401,          // for current interpolation tables (a hundreth of a percent)
    UINT_IN_PERMILLION = 0x00010601,          // for cw    power values in 10^(-6) Watt = uW
    UINT_IN_PERBILLION = 0x00010901,          // for pulse power values in 10^(-9) Watt = nW
    UINT_IN_PERTRILLION = 0x00010C01,          // for wavelength values in 10^(-12) m  = pm
    UINT_IN_PERQUADTRILLION = 0x00010F01,          // for pulse energy values in 10^(-15) joules = femto joule
                                                   //
    INT = 0x00110001,
    INT_IN_PERTHOUSAND = 0x00110302,          // for milli Volts, etc.
                                              //
    SINGLE = 0x01000001,
    VOID = 0xFFFFFFFF
  }

  public enum PDLM_TagVarType : UInt32
  {
    NONE = PDLM_Tagtype.VOID,
    Locked = PDLM_Tagtype.BOOL,
    SoftLock = PDLM_Tagtype.BOOL,
    KeyLock = PDLM_Tagtype.BOOL,
    Class_IV_Lock = PDLM_Tagtype.BOOL,
    Interlock = PDLM_Tagtype.BOOL,
    LaserMode = PDLM_Tagtype.UINT_ENUM,
    LDH_PulsePowerTable = PDLM_Tagtype.UINT_ENUM,
    TriggerMode = PDLM_Tagtype.UINT_ENUM,
    TriggerLevelRaw = PDLM_Tagtype.UINT_DAC,
    TriggerLevelRawLoLimit = PDLM_Tagtype.UINT_DAC,
    TriggerLevelRawHiLimit = PDLM_Tagtype.UINT_DAC,
    TriggerLevel = PDLM_Tagtype.SINGLE,             // ...but from HW up into the API it is PDLM_TAGTYPE_INT_IN_PERTHOUSAND
    TriggerLevelLoLimit = PDLM_Tagtype.SINGLE,      // ...but from HW up into the API it is PDLM_TAGTYPE_INT_IN_PERTHOUSAND
    TriggerLevelHiLimit = PDLM_Tagtype.SINGLE,      // ...but from HW up into the API it is PDLM_TAGTYPE_INT_IN_PERTHOUSAND
    //
    FastGate = PDLM_Tagtype.BOOL,
    FastGateImp = PDLM_Tagtype.UINT_ENUM,
    SlowGate = PDLM_Tagtype.BOOL,
    TargetTempRaw = PDLM_Tagtype.UINT_IN_TENTH,
    TargetTempRawLoLimit = PDLM_Tagtype.UINT_IN_TENTH,
    TargetTempRawHiLimit = PDLM_Tagtype.UINT_IN_TENTH,
    CurrentTempRaw = PDLM_Tagtype.UINT_IN_TENTH,
    CaseTempRaw = PDLM_Tagtype.UINT_IN_TENTH,
    //
    TargetTemp = PDLM_Tagtype.SINGLE,
    TargetTempLoLimit = PDLM_Tagtype.SINGLE,
    TargetTempHiLimit = PDLM_Tagtype.SINGLE,
    CurrentTemp = PDLM_Tagtype.SINGLE,
    CaseTemp = PDLM_Tagtype.SINGLE,
    //
    TempScale = PDLM_Tagtype.UINT_ENUM,
    //
    Frequency = PDLM_Tagtype.UINT,
    FrequencyLoLimit = PDLM_Tagtype.UINT,
    FrequencyHiLimit = PDLM_Tagtype.UINT,
    //
    PulsePowerRaw = PDLM_Tagtype.UINT_DAC,
    PulsePowerRawLoLimit = PDLM_Tagtype.UINT_DAC,
    PulsePowerRawHiLimit = PDLM_Tagtype.UINT_DAC,
    PulsePowerPermille = PDLM_Tagtype.UINT_IN_PERMILLE,
    PulseShape = PDLM_Tagtype.UINT_ENUM,
    PulsePower = PDLM_Tagtype.SINGLE,
    PulsePowerLoLimit = PDLM_Tagtype.SINGLE,
    PulsePowerHiLimit = PDLM_Tagtype.SINGLE,
    PulsePowerNanowatt = PDLM_Tagtype.UINT_IN_PERBILLION,
    PulsePowerVoltage = PDLM_Tagtype.UINT_IN_PERTHOUSAND,
    PulseEnergy = PDLM_Tagtype.UINT_IN_PERQUADTRILLION,
    //
    CwPowerRaw = PDLM_Tagtype.UINT_DAC,
    CwPowerRawLoLimit = PDLM_Tagtype.UINT_DAC,
    CwPowerRawHiLimit = PDLM_Tagtype.UINT_DAC,
    CwPowerPermille = PDLM_Tagtype.UINT_IN_PERMILLE,
    CwPower = PDLM_Tagtype.SINGLE,
    CwPowerLoLimit = PDLM_Tagtype.SINGLE,
    CwPowerHiLimit = PDLM_Tagtype.SINGLE,
    CwPowerMicroWatt = PDLM_Tagtype.UINT_IN_PERMILLION,
    //
    BurstLen = PDLM_Tagtype.UINT,
    BurstPeriod = PDLM_Tagtype.UINT,
    LDH_Fan = PDLM_Tagtype.BOOL,     // fuer [ 0,1];  // Alternative [0,100] fuer Prozent wurde verworfen (11.10.16)
    PDLM_TAGVARTYPE_UI_Exclusive = PDLM_Tagtype.BOOL
  }

  public enum PDLM_LaserMode : UInt32
  {
    PDLM_LASER_MODE_CW,
    PDLM_LASER_MODE_PULSE,
    PDLM_LASER_MODE_BURST
  }

  public enum PDLM_TempScale : UInt32
  {
    PDLM_TEMPERATURESCALE_CELSIUS,
    PDLM_TEMPERATURESCALE_FAHRENHEIT,
    PDLM_TEMPERATURESCALE_KELVIN
  }

  public enum PDLM_PulsePowerTable
  {
    LDH_LINEAR_PULSE_TABLE,
    LDH_MAX_POWER_PULSE_TABLE
  }

  [Flags]
  public enum DeviceStatus : UInt32
  {
    PDLM_DEVSTATE_INITIALIZING = 0x00000001, // Device is initializing during boot up
    PDLM_DEVSTATE_DEVICE_UNCALIBRATED = 0x00000002, // If the device has no valid data in eeprom
    PDLM_DEVSTATE_COMMISSIONING_MODE = 0x00000004, // During commissioning. All errors coming from device/laserhead are ignored
    PDLM_DEVSTATE_LASERHEAD_SAFETY_MODE = 0x00000008, // Laser head safety mode
    PDLM_DEVSTATE_FW_UPDATE_RUNNING = 0x00000010, // During firmware update
    PDLM_DEVSTATE_DEVICE_DEFECT = 0x00000020, // At least one Part of the device hardware is defect
    PDLM_DEVSTATE_DEVICE_INCOMPATIBLE = 0x00000040, // The firmware cannot control the read device version
    PDLM_DEVSTATE_BUSY = 0x00000080, // Device is busy during costly calculations, etc
    PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED = 0x00000100, // Only the host software can manipulate the device
    PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING = 0x00000200, // At least one parameter of the device has changed
    PDLM_DEVSTATE_LASERHEAD_CHANGED = 0x00000800, // When a new laser head was connected
    PDLM_DEVSTATE_LASERHEAD_MISSING = 0x00001000, // No laser head connected
    PDLM_DEVSTATE_LASERHEAD_DEFECT = 0x00002000, // Laser head defect
    PDLM_DEVSTATE_LASERHEAD_UNKNOWN_TYPE = 0x00004000, // The laser type cannot be controlled by the laser driver
    PDLM_DEVSTATE_LASERHEAD_DECALIBRATED = 0x00008000, // Laser head calibration expired, data may no longer be valid
    PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_LOW = 0x00010000, // Laser head temperature is below set point
    PDLM_DEVSTATE_LASERHEAD_DIODE_TEMP_TOO_HIGH = 0x00020000, // Laser head temperature is above set point
    PDLM_DEVSTATE_LASERHEAD_DIODE_OVERHEATING = 0x00040000, // Laser head diode overheated
    PDLM_DEVSTATE_LASERHEAD_CASE_OVERHEATING = 0x00080000, // Laser head case overheated
    PDLM_DEVSTATE_LASERHEAD_FAN_RUNNING = 0x00100000, // Laser head fan is running
    PDLM_DEVSTATE_LASERHEAD_INCOMPATIBLE = 0x00200000, // The firmware cannot control the laser version read
    PDLM_DEVSTATE_LOCKED_BY_EXPIRED_DEMO_MODE = 0x00400000, // Laser will be locked when demo mode expired
    PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON = 0x00800000, // Laser is off by On/Off button
    PDLM_DEVSTATE_SOFTLOCK = 0x01000000, // Laser is off by host software
    PDLM_DEVSTATE_KEYLOCK = 0x02000000, // Laser is off by keylock
    PDLM_DEVSTATE_LOCKED_BY_SECURITY_POLICY = 0x04000000, // Laser Class IV - Rules
    PDLM_DEVSTATE_INTERLOCK = 0x08000000, // Laser is off because interlock is unplugged
    PDLM_DEVSTATE_LASERHEAD_PULSE_POWER_INACCURATE = 0x10000000, // Laser temperature differs from what it was calibrated on
    PDLM_DEVSTATE_ERRORMSG_PENDING = 0x80000000  // Error message pending in error queue, not laser head related
  }
}
