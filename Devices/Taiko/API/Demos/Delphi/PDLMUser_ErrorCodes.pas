//-----------------------------------------------------------------------------
//
//      PDLMUser_ErrorCodes.pas
//
//-----------------------------------------------------------------------------
//
//  Exports the official list of error codes for PDLM_Lib.dll V2.0.xx.4120
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  09.09.18   first released (derived from PDLM_Lib.dll)
//
//-----------------------------------------------------------------------------
//
unit PDLMUser_ErrorCodes;

interface

  const
    //
    PDLM_ERROR_NONE                           =      0;
    PDLM_ERROR_DEVICE_NOT_FOUND               =     -1;
    PDLM_ERROR_NOT_CONNECTED                  =     -2;
    PDLM_ERROR_ALREADY_CONNECTED              =     -3;
    PDLM_ERROR_WRONG_USBIDX                   =     -4;
    PDLM_ERROR_ILLEGAL_INDEX                  =     -5;
    PDLM_ERROR_ILLEGAL_VALUE                  =     -6;
    PDLM_ERROR_USB_MESSAGE_INTEGRITY_VIOLATED =     -7;
    PDLM_ERROR_ILLEGAL_NODEINDEX              =     -8;
    PDLM_ERROR_WRONG_PARAMETER                =     -9;
    PDLM_ERROR_FW_VERSION_TO_LOW              =    -10;
    PDLM_ERROR_WRONG_SERIALNUMBER             =    -11;
    PDLM_ERROR_WRONG_PRODUCTMODEL             =    -12;
    PDLM_ERROR_BUFFER_TOO_SMALL               =    -13;
    PDLM_ERROR_INDEX_NOT_FOUND                =    -14;
    PDLM_ERROR_FW_MEMORY_ALLOCATION           =    -15;
    PDLM_ERROR_FREQUENCY_TO_BIG               =    -16;
    PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED         =    -17;
    //
    PDLM_ERROR_USB_INAPPROPRIATE_DEVICE       =    -18;
    PDLM_ERROR_USB_GET_DSCR_FAILED            =    -19;
    PDLM_ERROR_USB_INVALID_HANDLE             =    -20;
    PDLM_ERROR_USB_INVALID_DSCRBUF            =    -21;
    PDLM_ERROR_USB_IOCTL_FAILED               =    -22;
    PDLM_ERROR_USB_VCMD_FAILED                =    -23;
    PDLM_ERROR_USB_NO_SUCH_PIPE               =    -24;
    PDLM_ERROR_USB_REGNTFY_FAILED             =    -25;
    PDLM_ERROR_USBDRIVER_NO_MEMORY            =    -26;
    PDLM_ERROR_DEVICE_ALREADY_OPENED          =    -27;
    PDLM_ERROR_OPEN_DEVICE_FAILED             =    -28;
    PDLM_ERROR_USB_UNKNOWN_DEVICE             =    -29;
    PDLM_ERROR_EMPTY_QUEUE                    =    -30;
    PDLM_ERROR_FEATURE_NOT_AVAILABLE          =    -31;
    PDLM_ERROR_UNINITIALIZED_DATA             =    -32;
    PDLM_ERROR_DLL_MEMORY_ALLOCATION_ERROR    =    -33;
    PDLM_ERROR_UNKNOWN_TAG                    =    -34;
    PDLM_ERROR_OPEN_FILE                      =    -35;
    PDLM_ERROR_FW_FOOTER                      =    -36;
    PDLM_ERROR_FIRMWARE_UPDATE                =    -37;
    PDLM_ERROR_FIRMWARE_UPDATE_RUNNING        =    -38;
    PDLM_ERROR_INCOMPATIBLE_HARDWARE          =    -39;
    PDLM_ERROR_VALUE_NOT_AVAILABLE            =    -40;
    PDLM_ERROR_USB_SET_TIMED_OUT              =    -41;
    PDLM_ERROR_USB_GET_TIMED_OUT              =    -42;
    PDLM_ERROR_USB_SET_FAILED                 =    -43;
    PDLM_ERROR_USB_GET_FAILED                 =    -44;
    PDLM_ERROR_USB_DATA_SIZE_TOO_BIG          =    -45;
    PDLM_ERROR_FW_VERSION_CHECK               =    -46;
    PDLM_ERROR_WRONG_DRIVER                   =    -47;
    PDLM_ERROR_WINUSB_STORED_ERROR            =    -48;
    //
    PDLM_ERROR_UNEXPECTED_VALUE               =   -997;
    PDLM_ERROR_NOT_IMPLEMENTED_YET            =   -998;
    PDLM_ERROR_UNKNOWN_ERRORCODE              =   -999;
    PDLM_ERROR_FUNCTION_IS_PQ_INTERNAL        =  -9000;
    PDLM_ERROR_FUNCTION_NOT_IMPLEMENTED_YET   =  -9999;
    PDLM_ERROR_INITIAL_VALUE                  =      1;
    //
    PDLM_ERROR_HW_ERROR_OFFSET                =  -1000;
    PDLM_ERROR_HW_MAX_ERROR_NUM               =  -2999;
    //
    PDLM_ERROR_InvalidLow                     = -10000;
    PDLM_ERROR_InvalidHigh                    =      2;

implementation

end.
