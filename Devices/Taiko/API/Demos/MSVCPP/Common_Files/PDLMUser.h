/*---------------------------------------------------------------------------*/
//
// PDLMUser.h
//
// © 2018 PicoQuant GmbH;   POD et. al.
// All Rights Reserved
//
/*---------------------------------------------------------------------------*/
//
#pragma once

#ifdef __cplusplus
  extern "C"
  {
#endif

#ifdef _PDLM_API
  #define PDLM_API
#else
  #define PDLM_API  __declspec(dllimport)
#endif

#include <stdint.h>
#include <float.h>


//
//***************************************************************************
//***  PDLM Message IDs for Windows                                       ***
//***  (as sent in case of changes to the system state)                   ***
//***************************************************************************
//

//****************************************************//************//
#define WM_PDLM_BASE                                         0x1200
//****************************************************//************//

#define WM_ON_PENDING_ERRORS                  (WM_PDLM_BASE + 0x01) // on 0->1 PDLM_DEVSTATE_ERRORMSG_PENDING
#define WM_ON_LOCKING_CHANGE                  (WM_PDLM_BASE + 0x02) // on any  PDLM_DEVSTATEMASK_LOCKED
#define WM_ON_LASERHEAD_CHANGE                (WM_PDLM_BASE + 0x03) // on 0->1 PDLM_DEVSTATE_LASERHEAD_CHANGED
#define WM_ON_LASER_NOT_OPERATIONAL_CHANGE    (WM_PDLM_BASE + 0x04) // on 0->1 or 1->0 PDLM_DEVSTATEMASK_LASER_NOT_OPERATIONAL
#define WM_ON_DEVICE_NOT_OPERATIONAL_CHANGE   (WM_PDLM_BASE + 0x05) // on 0->1 or 1->0 PDLM_DEVSTATEMASK_DEVICE_NOT_OPERATIONAL
#define WM_ON_PARAMETER_CHANGE                (WM_PDLM_BASE + 0x07) // on 0->1 PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING
#define WM_ON_EXCLUSIVE_UI_CHANGE             (WM_PDLM_BASE + 0x08) // on any  PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED
#define WM_ON_WARNINGS_CHANGE                 (WM_PDLM_BASE + 0x09) // on any  PDLM_DEVSTATEMASK_ALL_WARNINGS
#define WM_ON_OTHER_STATES_CHANGE             (WM_PDLM_BASE + 0xFF) // on any  PDLM_DEVSTATEMASK_UNHANDLED



//
//***************************************************************************
//***                                                                     ***
//***  Library Interface Functions (a.k.a. Anonymous Functions)           ***
//***                                                                     ***
//***************************************************************************
//
  //
  // these functions work "anonymously", i.e.: they don't need a device-context
  //   as given by an USBIdx but even work if no device was opened at all.
  //

  int PDLM_API __stdcall PDLM_GetLibraryVersion(char *Version, uint32_t uiBuffLen);
  //
  // *Version    : O    pointer to the output string buffer
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // gets library version as a string (e.g. "0.0.0.0")
  //
  
  int PDLM_API __stdcall PDLM_GetUSBDriverInfo(char *Name, uint32_t uiNBuffLen, char *Version, uint32_t uiVBuffLen, char *Date, uint32_t uiDBuffLen);
  //
  // *Name       : O    pointer to the output name string buffer
  // uiNBuffLen  : I    to transmit the maximum name string buffer length
  // *Version    : O    pointer to the output version string buffer
  // uiVBuffLen  : I    to transmit the maximum version string buffer length
  // *Date       : O    pointer to the output date string buffer
  // uiDBuffLen  : I    to transmit the maximum date string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if any of the provided buffers is to small
  //
  // gets current USB driver's sevice name, version and release date as strings
  //

  int PDLM_API __stdcall PDLM_DecodeError(int iErrCode, char* cBuffer, uint32_t* uiBuffLen);
  //
  // iErrCode    : I    the error number
  // *cBuffer    : O    pointer to the output string buffer
  // *uiBuffLen  : I/O  pointer to a variable that contains the maximum string buffer length
  //                    if set to 0, the length of the error text is returned in this variable
  //                    but no text is returned in cBuffer
  //
  // returns     : PDLM_ERROR_UNKNOWN_ERRORCODE if errorcode not found
  //               PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // gets an error string, as identified by the error code given
  //

  int PDLM_API __stdcall PDLM_GetTagDescription(uint32_t Tag, uint32_t* TypeCode, char* cName);
  //
  // Tag         : I    the tag code
  // *TypeCode   : O    pointer to an unsigned integer variable that returns the typecode of the tag,
  // *cName      : O    pointer to a string variable that returns the name of the tag
  //
  // returns     : PDLM_ERROR_UNKNOWN_TAG if no tag is registered for the tag code given
  //               PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // gets the typecode and name as a formal description of the requested tag
  // see the appendix for a table of the legal Tag types
  //

  int PDLM_API __stdcall PDLM_DecodePulseShape(uint32_t shape, char* cBuffer, uint32_t uiBuffLen);
  //
  // shape       : I    the pulse shape code
  // *cBuffer    : O    pointer to a string variable for the decoded pulse shape
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if shape is no legal pulse shape code
  //               PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // gets a string, containing the pulse shape as identified by the shape code given
  //

  int PDLM_API __stdcall PDLM_DecodeLHFeatures(uint32_t LHFeatures, char* cBuffer, uint32_t uiBuffLen);
  //
  // LHFeatures  : I    the laser head features code
  // *cBuffer    : O    pointer to a string variable for the decoded LH features
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // This function decodes the value of the bitcoded variable LHFeatures into a
  // string as a list of unique features, separated by "; ". the buffer provided has
  // to be "just big enough", i.e. a block of 256 bytes according to todays known
  // features. But the actual length of this list is subject to changes without notice
  //

  int PDLM_API __stdcall PDLM_DecodeSystemStatus(uint32_t state, char* cBuffer, uint32_t uiBuffLen);
  //
  // state       : I    the status code (32-bit bitset) to decode
  // *cBuffer    : O    pointer to a string variable for the decoded status
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // decodes the status code to a human readable string, where the
  //   texts corresponding to the status bits set are separated by "; "
  //



//
//***************************************************************************
//*** All following functions will only work if you identify a device by  ***
//*** an USBIdx. Commonly they could also return some low level codes     ***
//*** from the USB-interface, e.g. "PDLM_ERROR_USB_IOCTL_FAILED", which   ***
//*** signals a severe, mostly unrecoverable USB communication problem    ***
//*** (e.g. connection lost), in which case one better should close and   ***
//*** re-open the device...                                               ***
//***************************************************************************
//


//
//***************************************************************************
//***                                                                     ***
//***  Device Basic Functions                                             ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_OpenDevice(int USBIdx, char* cSerNo);
  //
  // USBIdx      : I    the USB index [0..7]
  // *cSerNo     : I/O  pointer to a string variable of at least 8 characters length
  //                      for the serial number of the device
  //
  // returns     : PDLM_ERROR_WRONG_PARAMETER           if USBIdx is out of range [0..7]
  //               PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED    if device is busy (i.e. opened by another program)
  //               PDLM_ERROR_USB_INAPPROPRIATE_DEVICE  if the serial number given doesn't match
  //               PDLM_ERROR_USB_GET_DSCR_FAILED       if USB descriptor couldn't be loaded
  //               PDLM_ERROR_USBDRIVER_NO_MEMORY       if driver gets out of memory
  //               PDLM_ERROR_DEVICE_ALREADY_OPENED     if SW tries to re-open a device already opened
  //               PDLM_ERROR_OPEN_DEVICE_FAILED        if driver couldn't get a valid windows handle
  //               PDLM_ERROR_USB_UNKNOWN_DEVICE        if device is no Taiko
  //
  // opens device (exclusively) as identified by USBIdx and
  //   if cSerNo was given empty, returns the serial number (e.g. "1234567") of the connected PDL M,
  //   else comparing the serial number given, returning with an error if it doesn't match.
  // in case of erroneous termination, cSerNo might be undefined (empty).
  //

  int PDLM_API __stdcall PDLM_CloseDevice(int USBIdx);
  //
  // USBIdx      : I    the USB index [0..7]
  //
  // closes device as identified by USBIdx
  //

  int PDLM_API __stdcall PDLM_OpenGetSerNumAndClose(int USBIdx, char* cSerNo);
  //
  // USBIdx      : I    the USB index [0..7]
  // *cSerNo     : I/O  pointer to an string variable of at least 8 characters length
  //                      for the serial number of the device
  //
  // returns     : same errorlist as for PDLM_OpenDevice
  //
  // opens device as identified by USBIdx (non-exclusively, therefore returning a serial number even for blocked devices) and
  //   if cSerNo is empty, returns serial number (e.g. "1234567") of connected PDL M,
  //   else comparing the serial number given, returning with error if it doesn't match
  // after successfully opening, device will be closed again.
  // in case of erroneous termination, cSerNo might still be undefined (empty).
  //

  //****************************************************//***************************
  // PDLM_UI_COOPERATIVE                                // UI on device stays active
  // PDLM_UI_EXCLUSIVE                                  // UI on device is locked
  //****************************************************//***************************

  int PDLM_API __stdcall PDLM_SetExclusiveUI(int USBIdx, uint32_t  mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the desired UI access mode
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE  if mode codes other than allowed are set
  //
  // sets the UI access mode. if set to "PDLM_UI_COOPERATIVE", the user is allowed
  // to change settings directly on the device by using the knob, which is illuminated
  // whith a green backlight, while the calling program is still running and may or
  // may not launch changes by itself. if set to "PDLM_UI_EXCLUSIVE", on the other hand,
  // changes are restricted to the calling software, the knob is diabled and its back-
  // light is shut off.
  //
  // Note: if you have to rely on undisturbed operation of your program, you may block
  // user interaction; But take care to properly release the "PDLM_UI_EXCLUSIVE" mode,
  // after you're done. if the program terminates without re-setting the UI-mode back
  // to "PDLM_UI_COOPERATIVE" by hazard, the device will stay blocked. But in worst
  // case, only a power-down / power-up cycle will release the UI again.
  //

  int PDLM_API __stdcall PDLM_GetExclusiveUI(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the current UI access mode
  //
  // reads the current state of the UI access mode
  //


//
//***************************************************************************
//***                                                                     ***
//***  Common Device Information Functions                                ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetUSBStrDescriptor(int USBIdx, char* Descr, uint32_t uiBuffLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Descr      : O    pointer to a string variable for the string descriptor
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL          if the provided buffer is to small
  //               PDLM_ERROR_USB_GET_DSCR_FAILED       if USB descriptor couldn't be loaded
  //
  // returns a string with concatenated USB string descriptors, separated by a ';' character
  //

  int PDLM_API __stdcall PDLM_GetHardwareInfo(int USBIdx, char* Infos, uint32_t uiBuffLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Infos      : O    pointer to a string variable for the hardware info
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // hardware info, usually shown as part of About box/Support info texts.
  // mainly this identifies the hardware product type and version...
  //

  int PDLM_API __stdcall PDLM_CreateSupportRequestText(int USBIdx, char*    cPreamble,
                                                                   char*    cCallingSW,
                                                                   uint32_t uiOptions,
                                                                   uint32_t uiBuffLen,
                                                                   char*    cBuffer);
  //
  // USBIdx      : I    the USB index [0..7]
  // *cPreamble  : I    pointer to a string for the preamble text to include
  //                      e.g. open the About box and refer to all text before "<snip>"
  // *cCallingSW : I    pointer to a string to identify the calling software to include
  //                      e.g. open the About box and refer to the paragraph "Calling Software"
  // uiOptions   : I    bitset of options, the caller could choose and combine from:
  //                      PDLM_SUPREQ_OPT_NO_PREAMBLE          0x01  if included, the preamble will be suppressed
  //                      PDLM_SUPREQ_OPT_NO_TITLE             0x02  if included, the title will be suppressed
  //                      PDLM_SUPREQ_OPT_NO_CALLING_SW_INDENT 0x04  if included, the info on calling software will not be indented
  //                      PDLM_SUPREQ_OPT_NO_SYSTEM_INFO       0x08  if included, the system info will be suppressed
  // uiBuffLen   : I    to transmit the maximum string buffer length
  // *cBuffer    : O    pointer to a string variable to take the SupportRequestText
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // common hardware, software and environment info, as usually shown in a About... box
  // or in the support infos. Should contain all relevant informations about the system,
  // including Versions / Features / Options / Environment
  //

  int PDLM_API __stdcall PDLM_GetFWVersion(int USBIdx, char *Version, uint32_t uiBuffLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Version    : O    pointer to a string variable for the firmware version
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // gets the firmware version
  //

  int PDLM_API __stdcall PDLM_GetFPGAVersion(int USBIdx, char *Version, uint32_t uiBuffLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Version    : O    pointer to a string variable for the FPGA version
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // gets the FPGA version
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device Function for Detailled Information                          ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetDeviceData(int USBIdx, TDeviceData* Data, uint32_t size);
  //
  // The infos provided by this data struct are also available as part of the 
  // text in PDLM_CreateSupportRequestText
  //


//
//***************************************************************************
//***                                                                     ***
//***  Laser Head Functions for Detailled Information                     ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetLHVersion(int USBIdx, char *Version, uint32_t uiBuffLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Version    : O    pointer to a string variable for the laser head version
  // uiBuffLen   : I    to transmit the maximum string buffer length
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL  if the provided buffer is to small
  //
  // gets the laser head version as text
  //


  int PDLM_API __stdcall PDLM_GetLHData(int USBIdx, TLaserData* pData, uint32_t size);
  //
  // The infos on the laser head provided by this data struct are also available as 
  // part of the text in PDLM_CreateSupportRequestText or other dedicated functions
  //

  int PDLM_API __stdcall PDLM_GetLHInfo(int USBIdx, TLaserInfo* pInfo, uint32_t size);
  //
  // This function provides additional (text-) information on the laser head
  //
  // typedef __packed struct _TLaserInfo
  // {
  //   char                LType  [PDLM_LDH_STRING_LENGTH]; // e.g. "LDH-IX-B-405"
  //   char                Date   [PDLM_LDH_STRING_LENGTH]; // date of manufacturing e.g. "2017-01-23" (yyyy-mm-dd)
  //   char                LClass [PDLM_LDH_STRING_LENGTH]; // laser class e.g. "3R"
  // } TLaserInfo;
  //

  int PDLM_API __stdcall PDLM_GetLHFeatures(int USBIdx, uint32_t* LHFeatures);
  //
  // USBIdx      : I    the USB index [0..7]
  // *LHFeatures : O    pointer to a variable for the laser head feature code
  //
  // This function gets the feature code of the currently connected laser head.
  // it may be decoded by bitwise operations with the constant symbols named
  // "PDLM_LHFEATURE_<feature>", as can be found in "PDLMUser_ui_defs.h".
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device Functions for Status and Error Informations                 ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_SetHWND(int USBIdx, HWND hwnd);
  //
  // USBIdx      : I    the USB index [0..7]
  // hwnd        : I    the handle of the application's main window
  //
  // returns     : PDLM_ERROR_USB_REGNTFY_FAILED if registration fails
  //               PDLM_ERROR_USB_INVALID_HANDLE
  //
  // transmits the handle of the message-loop-holding window (i.e. in most cases
  // the application's main window) to the DLL, so that it can post asynchrone
  // messages with device feedback to the host software by use of windows messages.
  //
  // the window class of this window should implement and register handlers for
  // messages that are posted as notifications on several occations. Notifications
  // are usually sent with this window handle, a message ID to identify the event
  // handler that is resposible for it, a WPARAM typed short parameter named wParam
  // and a LPARAM typed long parameter named lParam. When the DLL is posting one of
  // the following notification messages, in wParam the USBIdx is sent, whilst in
  // lParam the current status word (as uint32_t) is transmitted.
  //
  // nine different messages (all of type notification) are defined:
  //
  //   WM_ON_PENDING_ERRORS                = (WM_PDLM_BASE + 0x01) // on 0->1 PDLM_DEVSTATE_ERRORMSG_PENDING
  //   WM_ON_LOCKING_CHANGE                = (WM_PDLM_BASE + 0x02) // on any  PDLM_DEVSTATEMASK_LOCKED
  //   WM_ON_LASERHEAD_CHANGE              = (WM_PDLM_BASE + 0x03) // on 0->1 PDLM_DEVSTATE_LASERHEAD_CHANGED
  //   WM_ON_LASER_NOT_OPERATIONAL_CHANGE  = (WM_PDLM_BASE + 0x04) // on 0->1 or 1->0 PDLM_DEVSTATEMASK_LASER_NOT_OPERATIONAL
  //   WM_ON_DEVICE_NOT_OPERATIONAL_CHANGE = (WM_PDLM_BASE + 0x05) // on 0->1 or 1->0 PDLM_DEVSTATEMASK_DEVICE_NOT_OPERATIONAL
  //   WM_ON_PARAMETER_CHANGE              = (WM_PDLM_BASE + 0x07) // on any  PDLM_DEVSTATE_PARAMETER_CHANGES_PENDING
  //   WM_ON_EXCLUSIVE_UI_CHANGE           = (WM_PDLM_BASE + 0x08) // on any  PDLM_DEVSTATE_EXCLUSIVE_SW_OP_GRANTED
  //   WM_ON_WARNINGS_CHANGE               = (WM_PDLM_BASE + 0x09) // on any  PDLM_DEVSTATEMASK_ALL_WARNINGS
  //   WM_ON_OTHER_STATES_CHANGE           = (WM_PDLM_BASE + 0xFF) // on any other status changes
  //
  // wherein
  //   WM_PDLM_BASE                        = 0x1200
  //


  int PDLM_API __stdcall PDLM_GetSystemStatus(int USBIdx, uint32_t* state);
  //
  // USBIdx      : I    the USB index [0..7]
  // *state      : O    pointer to an unsigned integer variable for the status code
  //
  // gets the bitcoded state code; see the "Table of all assigned status bits" below,
  // for further information on the sub-structure of the status code.
  //

  int PDLM_API __stdcall PDLM_GetQueuedChanges(int USBIdx, TTagValue* TagValList, uint32_t* uiListLen);
  //
  // USBIdx      : I    the USB index [0..7]
  // *TagValList : O    pointer to a variable, holding a tag value list (array)
  // *uiListLen  : I/O  pointer to an unsigned integer variable to enter the length
  //                      of the tag value list provided (max. number of elements).
  //                      returning, the number of elements transferred is accessable.
  //
  // returns     : PDLM_ERROR_BUFFER_TOO_SMALL
  //               PDLM_ERROR_DLL_MEMORY_ALLOCATION_ERROR
  //

  int PDLM_API __stdcall PDLM_GetTagValueList(int USBIdx, uint32_t uiListLen, TTagValue* TagValList);
  //
  // USBIdx      : I    the USB index [0..7]
  // uiListLen   : I    entering the amount of elements in the list of
  //                      tagged values to retrieve
  // *TagValList : I/O  pointer to an array of TTagValue typed fields;
  //                      initialize the fields with the tags of the values
  //                      to retrieve and get the desired values after return
  //                      from the call to this function
  //
  // This function takes a pointer to an array of TTagValue typed fields,
  // initialized with the tags of the desired values as input templates
  // and returns it back with the current values identified by the tags
  // filled into the appropriate subfields.
  //
  // TTagValue contains a field "Value" of TValueType, which is a union
  // of various typed fields. Check for the interpretation of the value
  // by calling the function "PDLM_GetTagDescription", by which you can
  // find out about the base type and scaling of the value. So, if you
  // e. g. work in pulse mode and want to get informed on the optical
  // power currently emitted, you might insert a template initialized
  // with the tag "PDLM_TAG_PulsePower", "PDLM_TAG_PulsePowerNanowatt"
  // or "PDLM_TAG_PulsePowerPermille", depending on the kind of visuali-
  // zation and processing you further intend. "PDLM_TAG_PulsePower"
  // will return as a float value scaled in Watt (W), while the value
  //  of"PDLM_TAG_PulsePowerNanowatt" will return as an unsigned integer
  // and - as the name of the tag might suggest - is scaled in nW. Also
  // suggested by name is the value of "PDLM_TAG_PulsePowerPermille" an
  // unsigned integer, too, but related to  the maximum power and scaled
  // in permille thereof.
  //

  int PDLM_API __stdcall PDLM_GetQueuedError(int USBIdx, int *ErrCode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *ErrCode    : O    pointer to an integer variable, returning the deepest error code
  //
  // If an error situation was not directly produced by a call to a function,
  // e.g. a laser head overheating, or similar, the situation is registered
  // and an errorcode is queued. To signal new elments in the queue, the most
  // significant bit in the status code, "PDLM_STATE_ERROR_MESSAGE_PENDING" is
  // set. With this bit set, the user can get the queued codes by a (multiple)
  // call to this function. Each call returns the deepest code (FIFO), until
  // the queue is purged. With retrieving the recent error code element, the
  // signalling status flag is reset to 0.
  //

  int PDLM_API __stdcall PDLM_GetQueuedErrorString(int USBIdx, int ErrCode, char* ErrText);
  //
  // USBIdx      : I    the USB index [0..7]
  // ErrCode     : I    entering the error code to decode
  // *ErrText    : O    pointer to the output string buffer
  //
  // decodes the error code given into a human readable string.
  // Grant ErrText to hold at least PDLM_HW_ERRORSTRING_MAXLEN+1 characters
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device Functions for Laser Locking                                 ***
//***                                                                     ***
//***************************************************************************
//

  //****************************************************//
  // PDLM_LASER_UNLOCKED                                //
  // PDLM_LASER_LOCKED                                  //
  //****************************************************//

  int PDLM_API __stdcall PDLM_GetLocked(int USBIdx, uint32_t* Locked);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Locked     : O    pointer to an unsigned integer variable to return the locking state
  //
  // returns the over-all locking state of the laser.
  // to get further information on why the laser is locked, inspect the staus code
  //

  int PDLM_API __stdcall PDLM_SetSoftLock(int USBIdx, uint32_t SoftLocked);
  //
  // USBIdx      : I    the USB index [0..7]
  // SoftLocked  : I    the desired soft locking state
  //
  // sets the soft locking state of the laser.
  //

  int PDLM_API __stdcall PDLM_GetSoftLock(int USBIdx, uint32_t *SoftLocked);
  //
  // USBIdx      : I    the USB index [0..7]
  // *SoftLocked : O    pointer to an unsigned integer variable to return the soft locking state
  //
  // returns the soft locking state of the laser.
  // notice, that even if the value returned equals PDLM_LASER_UNLOCKED,
  // the laser might be locked by several other reasons, inspect the staus code.
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device Functions for the Laser Emission Mode (device working mode) ***
//***                                                                     ***
//***************************************************************************
//

  //****************************************************//**********************
  // PDLM_LASER_MODE_CW                                 // continuous wave mode
  // PDLM_LASER_MODE_PULSE                              // pulse mode
  // PDLM_LASER_MODE_BURST                              // burst mode
  //****************************************************//**********************

  int PDLM_API __stdcall PDLM_SetLaserMode(int USBIdx, uint32_t mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the desired laser emission mode
  //
  // returns     : PDLM_ERROR_FEATURE_NOT_AVAILABLE if the mode is not allowed for this type of laser
  //               PDLM_ERROR_ILLEGAL_VALUE         if mode codes other than mentioned above are set
  //
  // This function sets the laser emission mode. For some laser heads,
  // certain laser modes might not be suitable (i.e. not allowed)
  //
  // Notice: Setting laser mode to burst mode is not allowed, as long as the
  //         device is triggered externally
  //
  // Notice: On changing the device working mode, several other values are
  //         automatically changed, too. They contain e.g. the optical output
  //         power, that is changed to the latest valid settings. This is due
  //         to the fact, that Taiko always maintains safe operating values
  //         according to the limits stored in the laser head connected. The
  //         optical power in CW-mode may not be suitable or even totally out
  //         of bounds for pulse mode...
  //

  int PDLM_API __stdcall PDLM_GetLaserMode(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *mode       : O    pointer to an unsigned integer variable,
  //                      returning the current laser emission mode
  //
  // this function gets the current laser emission mode
  //
  
  int PDLM_API __stdcall PDLM_SetLDHPulsePowerTable(int USBIdx, uint32_t tableidx);
  int PDLM_API __stdcall PDLM_GetLDHPulsePowerTable(int USBIdx, uint32_t* tableidx);


//
//***************************************************************************
//***                                                                     ***
//***  Device Functions for Triggering and Gating                         ***
//***                                                                     ***
//***************************************************************************
//

  //****************************************************//*************************************************
  // PDLM_TRIGGER_INTERNAL                              // device is triggered internally
  // PDLM_TRIGGER_EXTERNAL_FALLING_EDGE                 // device is triggered externally on falling edge
  // PDLM_TRIGGER_EXTERNAL_RISING_EDGE                  // device is triggered externally on rising edge
  //****************************************************//*************************************************
  // PDLM_DISABLE                                       // gating disabled
  // PDLM_ENABLE                                        // gating enabled
  //****************************************************//*************************************************
  // PDLM_GATEIMP_10k_OHM                               // high gating impedance
  // PDLM_GATEIMP_50_OHM                                // low gating impedance
  //****************************************************//*************************************************

  int PDLM_API __stdcall PDLM_SetTriggerMode(int USBIdx, uint32_t mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the code of the desired trigger mode
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if mode has a value other than the three allowed values
  //
  // sets the code of the desired trigger mode of the device.
  // if trigger mode was set to one of the external modes, the user
  // should also set the trigger level to appropriate values
  //
  // Notice: The context of "intensity" is changing, when switching from
  //         internal to external triggering. Since we can't "know" about
  //         the characteristics of the external signal, we can't go on
  //         with table-driven power linearization at a given frequency.
  //         Instead, we switch to the old PDL-like mode, where controlling
  //         "intensity" only means to control the diode voltage (which is
  //         PQ-internally called "PosVar"), from 0V to maximum.
  //         Consequently, a wide part of the lower range of the permille
  //         scale only drives the laser head in sub-threshold (LED) domain.
  //         The maximum, 1000 permille, is a laser head individual voltage,
  //         which is carefully chosen to prevent the head from being damaged.
  //

  int PDLM_API __stdcall PDLM_GetTriggerMode(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *mode       : O    pointer to an unsigned integer variable,
  //                      returning the code of the current trigger mode
  //
  // gets the code of the current trigger mode of the device.
  //

  int PDLM_API __stdcall PDLM_GetTriggerLevelLimits(int USBIdx, float* MinLevel, float* MaxLevel);
  //
  // USBIdx      : I    the USB index [0..7]
  // *MinLevel   : O    pointer to a float variable (single precision),
  //                      returning the device's trigger level lower limit in Volt
  // *MaxLevel   : O    pointer to a float variable (single precision),
  //                      returning the device's trigger level upper limit in Volt
  //
  // gets the limits of the external trigger level in Volt
  //

  int PDLM_API __stdcall PDLM_SetTriggerLevel(int USBIdx, float  Level);
  //
  // USBIdx      : I    the USB index [0..7]
  // Level       : I    the device's desired trigger level in Volt
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if Level is outside of the limits
  //
  // sets the external trigger level in Volt
  //

  int PDLM_API __stdcall PDLM_GetTriggerLevel(int USBIdx, float* Level);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Level      : O    pointer to a float variable (single precision),
  //                      returning the device's current trigger level in Volt
  //
  // gets the external trigger level in Volt
  //

  int PDLM_API __stdcall PDLM_GetExtTriggerFrequency(int USBIdx, uint32_t* ExtFreq);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Level      : O    pointer to an unsigned integer variable,
  //                      returning the device's current external trigger frequency in Hertz
  //
  // gets the external trigger frequency in Hertz
  //
  // consider, that a call to this function is not intended to be an equivalent
  // to a regular measurement, but it provides a raw means to get an order of
  // magnitude of the external trigger signal's frequency. the base resolution
  // of the implemented counter is 80 Hz, so that is strongly recommended to trust
  // only those readings, that are significantly higher than 8kHz.
  //

  int PDLM_API __stdcall PDLM_SetFastGate(int USBIdx, uint32_t mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the code of the desired fast gate mode (boolean)
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if mode has a value other than the two allowed values
  //
  // sets the code of the desired fast gate mode of the device (enabled / disabled).
  // if fast gate mode was set to enabled, the user should also set the fast gate impedance
  // to an appropriate value
  //

  int PDLM_API __stdcall PDLM_GetFastGate(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *mode       : O    pointer to an unsigned integer variable,
  //                      returning the code of the current fast gate mode
  //
  // gets the code of the fast gate mode (boolean: enabled / disabled) of the device
  //

  int PDLM_API __stdcall PDLM_SetFastGateImp(int USBIdx, uint32_t mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the code of the desired fast gate impedances (enum)
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if mode has a value other than the two allowed values
  //
  // with this function, code for the impedance of the fast gate input can be set.
  // there are only two values allowed:
  //   0 : 10kOhms (high impedance),
  //   1 : 50 Ohms (low impedance)
  //

  int PDLM_API __stdcall PDLM_GetFastGateImp(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *mode       : O    pointer to an unsigned integer variable,
  //                      returning the code of the desired fast gate impedances (enum)
  //
  // gets the code for the impedance of the fast gate input currently set.
  //

  int PDLM_API __stdcall PDLM_SetSlowGate(int USBIdx, uint32_t mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // mode        : I    the code of the desired slow gate mode (boolean)
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if mode has a value other than the two allowed values
  //
  // sets the code of the desired slow gate mode of the device (enabled / disabled).
  //

  int PDLM_API __stdcall PDLM_GetSlowGate(int USBIdx, uint32_t* mode);
  //
  // USBIdx      : I    the USB index [0..7]
  // *mode       : O    pointer to an unsigned integer variable,
  //                      returning the code of the current slow gate mode
  //
  // gets the code of the slow gate mode (boolean: enabled / disabled) of the device
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device Functions for Pulse Frequency and Burst Settings            ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetFrequencyLimits(int USBIdx, uint32_t* MinFreq, uint32_t* MaxFreq);
  //
  // USBIdx      : I    the USB index [0..7]
  // *MinFreq    : O    pointer to a float variable (single precision),
  //                      returning the device's lower limit frequency in Hertz
  // *MaxFreq    : O    pointer to a float variable (single precision),
  //                      returning the device's upper limit frequency in Hertz
  //
  // gets the current limits of the device's pulse frequency in Hertz
  //
  // Notice: The frequency limits depend on the laser head as currently connected.
  //         Consider to call this function whenever you changed the laserhead.
  //

  int PDLM_API __stdcall PDLM_SetFrequency(int USBIdx, uint32_t freq);
  int PDLM_API __stdcall PDLM_GetFrequency(int USBIdx, uint32_t* freq);
  //
  // These functions read and write the frequency of the device's base-oscillator in Hertz.
  // The latter is responsible for the pulse frequencies in pulse mode and burst mode as well.
  //

  int PDLM_API __stdcall PDLM_SetBurst(int USBIdx, uint32_t BurstLength, uint32_t PeriodLength);
  int PDLM_API __stdcall PDLM_GetBurst(int USBIdx, uint32_t* BurstLength, uint32_t* PeriodLength);
  //
  // These functions read and write the burst definition, defined in pulses.
  // limits are:
  //                2   <=  BurstLength   <   (2^24 - 1) = 16777215
  // (BurstLength + 1)  <=  PeriodLength  <=   16777215
  //
  // Although periods with very long pulse pauses are possible, consider to look
  // for alternative ways to implement the desired behaviour, like e.g. external
  // triggering or gating, since during measurements, it is very hard to decide,
  // whether the laser driver is still working in a valid burst cycle or just shut
  // off due to an error occured...
  //


//
//***************************************************************************
//***                                                                     ***
//***  Device and Laser Head Functions for Temperature Settings           ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_SetTempScale(int USBIdx, uint32_t ScaleID);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //
  // This function sets the code of the temperature scale as currently
  // used in the device's GUI. Three scale IDs are supported:
  //
  //   0: "PDLM_TEMPERATURESCALE_CELSIUS"
  //   1: "PDLM_TEMPERATURESCALE_FAHRENHEIT"
  //   2: "PDLM_TEMPERATURESCALE_KELVIN"
  //

  int PDLM_API __stdcall PDLM_GetTempScale(int USBIdx, uint32_t* ScaleID);
  //
  // USBIdx      : I    the USB index [0..7]
  // *ScaleID    : O    pointer to an unsigned integer variable
  //                      returning the code of the temperature scale as currently set
  //
  // gets the current temperature scale code
  //

  //
  // The following functions concerning temperatures have all to be called
  // with a valid ScaleID of arbitrary choice. It may or may not differ
  // from the ScaleID as currently used in the device's GUI.
  //
  // Notice: All internal calculations and settings are in fact performed in
  //         and rounded to tenths of a Celsius degree (1/10 °C = 1/10 K).
  //         This might explain the otherwise somewhat weird stepping and
  //         rounding effects when using the scale of Fahrenheit degrees (°F)...
  //
  // TargetTemp:  set-value for the temperature of the laser diode
  // CurrentTemp: actual-value of the temperature of the laser diode
  // CaseTemp:    actual-value of the temperature inside of the laser head case
  //

  int PDLM_API __stdcall PDLM_GetLHTargetTempLimits(int USBIdx, uint32_t ScaleID, float *MinTemp, float *MaxTemp);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  // *MinTemp    : O    pointer to a float variable returning the laser diode's
  //                      target temperature lower limit, in units of the
  //                      desired temperature scale.
  // *MaxTemp    : O    pointer to a float variable returning the laser diode's
  //                      target temperature upper limit, in units of the
  //                      desired temperature scale.
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //

  int PDLM_API __stdcall PDLM_SetLHTargetTemp(int USBIdx, uint32_t ScaleID, float  TargTemp);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  // TargTemp    : I    the laser diode's desired target temperature in
  //                      units of the desired temperature scale.
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //

  int PDLM_API __stdcall PDLM_GetLHTargetTemp(int USBIdx, uint32_t ScaleID, float* TargTemp);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  // *TargTemp   : O    pointer to a float variable returning the laser diode's
  //                      target temperature as currently set, in units of the
  //                      desired temperature scale.
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //

  int PDLM_API __stdcall PDLM_GetLHCurrentTemp(int USBIdx, uint32_t ScaleID, float* CurrTemp);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  // *CurrTemp   : O    pointer to a float variable returning the laser diode temperature as
  //                      currently measured, in units of the desired temperature scale
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //

  int PDLM_API __stdcall PDLM_GetLHCaseTemp(int USBIdx, uint32_t ScaleID, float* CaseTemp);
  //
  // USBIdx      : I    the USB index [0..7]
  // ScaleID     : I    the code of the desired temperature scale (enum)
  // *CaseTemp   : O    pointer to a float variable returning the case temperature as
  //                      currently measured, in units of the desired temperature scale
  //
  // returns     : PDLM_ERROR_ILLEGAL_VALUE if ScaleID has a value other than the three allowed values
  //

  int PDLM_API __stdcall PDLM_GetLHWavelength(int USBIdx, float* Wavelength);
  //
  // USBIdx      : I    the USB index [0..7]
  // *Wavelength : O    pointer to a float variable (single precision),
  //                      returning the laser head's wavelength in nm
  //
  // gets the wavelength in nm.
  //
  // Wavelength-tuning is only an oblique result of temperature settings, provided
  // that the connected laser head supports the feature "PDLM_LHFEATURE_WL_TUNABLE".
  // (s. Appendix). Therefore there is only a get-function.
  //
  // Notice: This wavelength is only an estimated value, it is not measured
  //         at request time, but is derived from the data that was measured
  //         at calibration time.
  //


//
//***************************************************************************
//***                                                                     ***
//***  Laser Head Functions for Pulse Power Settings                      ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetPulsePowerLimits(int USBIdx, float* fMinPower, float* fMaxPower);
  //
  // USBIdx      : I    the USB index [0..7]
  // *fMinPower  : O    pointer to a float variable (single precision),
  //                      returning the laser head's pulse power lower limit in Watt
  // *fMaxPower  : O    pointer to a float variable (single precision),
  //                      returning the laser head's pulse power upper limit in Watt
  //
  // gets the current limits of the laser head's pulse power in Watt
  //
  // Notice: The optical pulse power depends on the laser head itself
  //         and as it is measured as an integral value over time, it
  //         also depends on the current pulse frequency. Consider to
  //         call this function whenever you changed the laserhead or
  //         the repetition rate (pulse frequency).
  //

  int PDLM_API __stdcall PDLM_SetPulsePower(int USBIdx, float fPower);
  int PDLM_API __stdcall PDLM_GetPulsePower(int USBIdx, float* fPower);
  //
  // Diese Funktionen lesen und schreiben die einzustellende bzw. eingestellte optische
  // Leistung in Watt. Die jeweiligen Grenzwerte (Limits) sind natürlich laserkopfbezogen
  // und müssen für jeden Kopf erneut abgefragt werden. Bei Verletzung der Grenzwerte
  // retourniert die Set-Funktion "PDLM_ERROR_ILLEGAL_VALUE".
  //
  // Obwohl es in den meisten Fällen sehr bequem ist, die optische Leistung absolut
  // und in Watt eingeben zu können, mag es doch oft noch günstiger sein, die Leistung
  // in Relation zum erreichbaren Maximum fMaxPower in Promille anzugeben. Einer der
  // Vorteile dieser Eingabeform ist, daß sie (innerhalb der Grenzen 0..1000) stets
  // erfolgreich terminiert, während eine optische Leistung von beispielsweise 150mW
  // bei dem einen Laserkopf einen gültigen Eingabewert darstellt, während bei einem
  // anderen Kopf der gleichen Familie der Gültigkeitsbereich schon verletzt sein mag...
  //
  int PDLM_API __stdcall PDLM_SetPulsePowerPermille(int USBIdx, uint32_t permille);
  int PDLM_API __stdcall PDLM_GetPulsePowerPermille(int USBIdx, uint32_t *permille);
  //


//
//***************************************************************************
//***                                                                     ***
//***  Laser Head Functions for CW Power Settings                         ***
//***                                                                     ***
//***************************************************************************
//

  int PDLM_API __stdcall PDLM_GetCwPowerLimits(int USBIdx, float* MinPower, float* MaxPower);
  int PDLM_API __stdcall PDLM_SetCwPower(int USBIdx, float fPower);
  int PDLM_API __stdcall PDLM_GetCwPower(int USBIdx, float* fPower);
  //
  // Diese Funktionen lesen und schreiben die einzustellende bzw. eingestellte optische
  // Leistung in Watt. Die jeweiligen Grenzwerte (Limits) sind natürlich laserkopfbezogen
  // und müssen für jeden Kopf erneut abgefragt werden. Bei Verletzung der Grenzwerte
  // retourniert die Set-Funktion "PDLM_ERROR_ILLEGAL_VALUE". <Rest-Text anlog zu PulsePower>
  //
  int PDLM_API __stdcall PDLM_SetCwPowerPermille(int USBIdx, uint32_t permille);
  int PDLM_API __stdcall PDLM_GetCwPowerPermille(int USBIdx, uint32_t *permille);
  //
  // setzen und lesen der CW Power in Promille
  //


//
//***************************************************************************
//***                                                                     ***
//***  Laser Head Special Functions                                       ***
//***                                                                     ***
//***************************************************************************
//

  //****************************************************//*************************************************
  // PDLM_DISABLE                                       // fan disabled
  // PDLM_ENABLE                                        // fan enabled  (cooling)
  //****************************************************//*************************************************

  int PDLM_API __stdcall PDLM_SetLHFan(int USBIdx, uint32_t FanValue);
  int PDLM_API __stdcall PDLM_GetLHFan(int USBIdx, uint32_t* FanValue);


//
//***************************************************************************
//***                                                                     ***
//***  Functions for Device and Laser Head Presets                        ***
//***                                                                     ***
//***************************************************************************
//

  //  PsIdx ist der Preset Index [1..9], deshalb haben alle Presetfunktionen
  //    PDLM_ERROR_ILLEGAL_INDEX
  //  als möglichen Rückgabewert. Die beiden Get-Funktionen für Texte haben zusätzlich noch
  //    PDLM_ERROR_BUFFER_TOO_SMALL
  //

  int PDLM_API __stdcall PDLM_StorePreset(int USBIdx, uint32_t PsIdx, char *PsInfo, uint32_t size);
  //
  // Mit den Einstellungsdaten wird auch die Seriennummer des Laserkopfes im Device gesichert.
  // PsInfo ist ein freier Text (z.B. ein Name oder Bezeichner), der mit dem Preset abgespeichert wird...
  //

  int PDLM_API __stdcall PDLM_GetPresetInfo(int USBIdx, uint32_t PsIdx, char *PsInfo, uint32_t size);
  //
  // PsInfo kann mit dieser Funktion vorab gelesen werden (z.B. zum Aufbau einer Auswahlliste)
  //

  int PDLM_API __stdcall PDLM_GetPresetText(int USBIdx, uint32_t PsIdx, char *PsText, uint32_t size);
  //
  // PsText ist eine Zusammenfassung der im Preset gespeicherten Einstellungen als Textblock.
  //

  int PDLM_API __stdcall PDLM_RecallPreset(int USBIdx, uint32_t PsIdx);
  int PDLM_API __stdcall PDLM_ErasePreset(int USBIdx, uint32_t PsIdx);
  //
  // ...sind beide wohl fast selbsterklärend.
  //
  // Vielleicht doch noch den Hinweis, daß ...
  //
  //   ... sie beide schon nach Entgegennahme eines gültigen Parameters terminieren;
  //       Die Ausführung (der zuvor gequeueten Änderungen) erfolgt wegen des hohen
  //       Umfanges der Änderungen erst nach dem eigentlichen Befehlsende.
  //   ... Fehlersituationen, die erst während der Ausführung des Recalls auftreten,
  //       als Runtime-Errors gemeldet werden müssen, der Return-Code sollte dann ja
  //       schon längst mit PDLM_ERROR_NONE zurückgekehrt sein.
  //   ... Recall nur mit exakt dem gleichen Kopf (gleicher LH-SerialNo) funktioniert,
  //       (andernfalls Runtime-Error)
  //   ... Recall die aktuellen Einstellungswerte unwiederbringlich überschreibt,
  //   ... Erase die Presetdaten des Slots (Index) im Gerät unwiederbringlich löscht.
  //

