/*---------------------------------------------------------------------------*/
//
// PDLMUser_errorcodes.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
// - Consider, that a human readable error string can be queried by utilisation
//   of the function "PDLM_GetErrorString".
//
// - Notice, that there is a HW-depending group of runtime errors, with numbers
//   between "PDLM_ERROR_HW_ERROR_OFFSET" and "PDLM_ERROR_HW_MAX_ERROR_NUM" that
//   are _not_ listed, since they are HW-version individual codes and as for the
//   other errorcodes listed here, a human readable error string can be queried
//   by utilisation of the function "PDLM_GetQueuedErrorString".
//
/*---------------------------------------------------------------------------*/
//
#pragma once


//
//***************************************************************************
//***  Return- and Error-Codes                                            ***
//***************************************************************************
//

//****************************************************//************//
#define PDLM_ERROR_NONE                                           0
#define PDLM_ERROR_DEVICE_NOT_FOUND                              -1
#define PDLM_ERROR_NOT_CONNECTED                                 -2
#define PDLM_ERROR_ALREADY_CONNECTED                             -3
#define PDLM_ERROR_WRONG_USBIDX                                  -4
#define PDLM_ERROR_ILLEGAL_INDEX                                 -5
#define PDLM_ERROR_ILLEGAL_VALUE                                 -6
#define PDLM_ERROR_USB_MSG_INTEGRITY_VIOLATED                    -7
#define PDLM_ERROR_ILLEGAL_NODEINDEX                             -8
#define PDLM_ERROR_WRONG_PARAMETER                               -9
#define PDLM_ERROR_INCOMPATIBLE_FW                              -10
#define PDLM_ERROR_WRONG_SERIALNUMBER                           -11
#define PDLM_ERROR_WRONG_PRODUCTMODEL                           -12
#define PDLM_ERROR_BUFFER_TOO_SMALL                             -13
#define PDLM_ERROR_INDEX_NOT_FOUND                              -14
#define PDLM_ERROR_FW_MEMORY_ALLOCATION_ERROR                   -15
#define PDLM_ERROR_FREQUENCY_TOO_HIGH                           -16
#define PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED                       -17
#define PDLM_ERROR_USB_INAPPROPRIATE_DEVICE                     -18
#define PDLM_ERROR_USB_GET_DSCR_FAILED                          -19
#define PDLM_ERROR_USB_INVALID_HANDLE                           -20
#define PDLM_ERROR_USB_INVALID_DSCRBUF                          -21
#define PDLM_ERROR_USB_IOCTL_FAILED                             -22
#define PDLM_ERROR_USB_VCMD_FAILED                              -23
#define PDLM_ERROR_USB_NO_SUCH_PIPE                             -24
#define PDLM_ERROR_USB_REGNTFY_FAILED                           -25
#define PDLM_ERROR_USBDRIVER_NO_MEMORY                          -26
#define PDLM_ERROR_DEVICE_ALREADY_OPENED                        -27
#define PDLM_ERROR_OPEN_DEVICE_FAILED                           -28
#define PDLM_ERROR_USB_UNKNOWN_DEVICE                           -29
#define PDLM_ERROR_EMPTY_QUEUE                                  -30
#define PDLM_ERROR_FEATURE_NOT_AVAILABLE                        -31
#define PDLM_ERROR_UNINITIALIZED_DATA                           -32
#define PDLM_ERROR_DLL_MEMORY_ALLOCATION_ERROR                  -33
#define PDLM_ERROR_UNKNOWN_TAG                                  -34
#define PDLM_ERROR_OPEN_FILE                                    -35
#define PDLM_ERROR_FW_FOOTER                                    -36
#define PDLM_ERROR_FIRMWARE_UPDATE                              -37
#define PDLM_ERROR_FIRMWARE_UPDATE_RUNNING                      -38
#define PDLM_ERROR_INCOMPATIBLE_HARDWARE                        -39
#define PDLM_ERROR_VALUE_NOT_AVAILABLE                          -40
#define PDLM_ERROR_USB_SET_TIMED_OUT                            -41
#define PDLM_ERROR_USB_GET_TIMED_OUT                            -42
#define PDLM_ERROR_USB_SET_FAILED                               -43
#define PDLM_ERROR_USB_GET_FAILED                               -44
#define PDLM_ERROR_USB_DATA_SIZE_TOO_BIG                        -45
#define PDLM_ERROR_FW_VERSION_CHECK                             -46
#define PDLM_ERROR_WRONG_DRIVER                                 -47
#define PDLM_ERROR_WINUSB_STORED_ERROR                          -48
//****************************************************//************//
#define PDLM_MAX_ERROR_NUM                                      -48
//****************************************************//************//
#define PDLM_ERROR_UNKNOWN_ERRORCODE                           -999
//****************************************************//************//
#define PDLM_ERROR_HW_ERROR_OFFSET                            -1000
#define PDLM_ERROR_HW_MAX_ERROR_NUM                           -2999
//****************************************************//************//
#define PDLM_ERROR_FUNCTION_IS_PQ_INTERNAL                    -9000
#define PDLM_ERROR_FUNCTION_NOT_IMPLEMENTED_YET               -9999
//****************************************************//************//
#define PDLM_ERROR_INITIAL_VALUE                                  1
//****************************************************//************//

