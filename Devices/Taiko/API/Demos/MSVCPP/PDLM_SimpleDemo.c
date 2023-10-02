#include <windows.h> // Use this case, because winegcc uses this case, too
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <malloc.h>

#include <stdint.h>

#ifdef _MSC_VER
#define __packed
#define __attribute__(X)
#pragma pack(1)
#endif

#include "Common_Files/PDLMUser_errorcodes.h"
#include "Common_Files/PDLMUser_ui_defs.h"
#include "Common_Files/PDLMUser_tag_defs.h"
#include "Common_Files/PDLMUser_type_defs.h"
#include "Common_Files/PDLMUser_status_defs.h"
#include "Common_Files/PDLMUser.h"


#define  STD_BUFFER_LEN     1024

int iNoErrorsAllowed[1]         = { PDLM_ERROR_NONE };
int iErrorsOnOpenAllowed[6]     = { PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED, PDLM_ERROR_USB_INAPPROPRIATE_DEVICE, PDLM_ERROR_DEVICE_ALREADY_OPENED, PDLM_ERROR_OPEN_DEVICE_FAILED, PDLM_ERROR_USB_UNKNOWN_DEVICE, PDLM_ERROR_NONE };
int iErrorsAllowedOnTagDescr[2] = { PDLM_ERROR_UNKNOWN_TAG, PDLM_ERROR_NONE };
int iErrorsAllowedOnExtTrig[2]  = { PDLM_ERROR_VALUE_NOT_AVAILABLE, PDLM_ERROR_NONE };
int CurTempScale                = PDLM_TEMPERATURESCALE_CELSIUS;
int OldTempScale                = PDLM_TEMPERATURESCALE_CELSIUS;
int iUSBIdx;


  void CheckReturnValue(char* cFuncName, int iRetIn, int* iRetOut, int* AllowedRetVals, char* cErrMsg)
  {
    char cErrTxt[STD_BUFFER_LEN];
    char c;
    int i;
    int iBuffLen = STD_BUFFER_LEN;
    int bAllowed;
    //
    i = 0;
    bAllowed = FALSE;
    *iRetOut = iRetIn;
    //
    if (iRetIn != PDLM_ERROR_NONE)
    {
      while (AllowedRetVals[i] != 0)
      {
        if (AllowedRetVals[i] == iRetIn)
        {
          bAllowed = TRUE;
          break;
        }
        i++;
      }
      //
      if (bAllowed == FALSE)
      {
        if (strlen(cErrMsg) > 0)
        {
          printf("\n  %s", cErrMsg);
        }
        PDLM_DecodeError(iRetIn, cErrTxt, &iBuffLen);
        printf("\n  Error %d  occured during \"%s\" execution.\n    i.e. \"%s\"\n", iRetIn, cFuncName, cErrTxt);
        printf("\n  Hit return key to exit...  > ");
        scanf_s("%c", &c, 1);
        PDLM_CloseDevice(iUSBIdx);
        exit(iRetIn);
      }
    }
  }

  void UInt2MantPrfx(uint32_t freq, uint32_t *mant, uint32_t *prfx)
  {
    *prfx = PREFIX_ZEROIDX;
    *mant = freq;
    //
    while (*mant > 999)
    {
      *mant = *mant / 1000;
      *prfx += 1;
    }
  }

  void Float2MantPrfx(float value, float *mant, int *prfx)
  {
    int sign;
    //
    *prfx = PREFIX_ZEROIDX;
    *mant = fabsf (value);
    sign  = (value < 0.0000000000F ? -1 : 1);
    //
    while (*mant > 999.99999F)
    {
      *mant = *mant / 1000.0000F;
      *prfx += 1;
    }
    //
    if (*mant > 0.00000000000F)
    {
      while (*mant < 1.0000000F)
      {
        *mant = *mant * 1000.0000F;
        *prfx -= 1;
      }
    }
    *mant = *mant * sign;
  }

  uint32_t EnsureRange(uint32_t Val, uint32_t Min, uint32_t Max)
  {
    if (Val > Max)
    {
      return Max;
    }
    if (Val < Min)
    {
      return Min;
    }
    return Val;
  }

  float CalcTemperature (uint32_t uiScaleIdx, uint32_t uiRawValue)
  {
    switch (uiScaleIdx)
    {
    case PDLM_TEMPERATURESCALE_FAHRENHEIT:
      return ((0.18F * uiRawValue) + 32.0F);
      break;
    case PDLM_TEMPERATURESCALE_KELVIN:
      return ((0.1F * uiRawValue) + 273.1F);
      break;
    case PDLM_TEMPERATURESCALE_CELSIUS:
    default:
      return (0.1F * uiRawValue);
    }
  }

  int Demo_PrintTagValue(PTagValue TagValue)
  {
    uint32_t TagType;
    char     TagName[PDLM_TAGNAME_MAXLEN + 1];
    char     cBuffer[STD_BUFFER_LEN];
    float    fMant;
    int      iPrfx;
    uint32_t uiMant;
    uint32_t uiPrfx;
    //
    int      iRet = PDLM_ERROR_NONE;
    //
    if (TagValue->Tag != PDLM_TAG_NONE)
    {
      CheckReturnValue("PDLM_GetTagDescription", PDLM_GetTagDescription(TagValue->Tag, &TagType, TagName), &iRet, iErrorsAllowedOnTagDescr, "  Cannot get tag description.");
      //
      switch (TagValue->Tag)
      {
        case PDLM_TAG_LDH_PulsePowerTable:
          printf("  -%27s : %3d      ==>  %s\n", TagName, TagValue->Value.ValueUInt, (TagValue->Value.ValueUInt > 0 ? "max. power mode" : "linear power mode"));
          break;
        case PDLM_TAG_PulsePower:
        case PDLM_TAG_PulsePowerHiLimit:
        case PDLM_TAG_PulsePowerLoLimit:
          Float2MantPrfx (TagValue->Value.ValueFloat, &fMant, &iPrfx);
          printf("  -%27s : %7.3f %sW\n", TagName, fMant, UNIT_PREFIX[iPrfx]);
          break;
        case PDLM_TAG_PulsePowerNanowatt:
          Float2MantPrfx (1e-9F * TagValue->Value.ValueUInt, &fMant, &iPrfx);
          printf("  -%27s : %u nW  ==> %7.3f %sW\n", TagName, TagValue->Value.ValueUInt, fMant, UNIT_PREFIX[iPrfx]);
          break;
        case PDLM_TAG_PulsePowerPermille:
          printf("  -%27s :%4d  permille  ==> %5.1f %%\n", TagName, TagValue->Value.ValueUInt, 0.1F * TagValue->Value.ValueUInt);
          break;
        case PDLM_TAG_PulseShape:
          iRet = PDLM_DecodePulseShape(TagValue->Value.ValueUInt, cBuffer, STD_BUFFER_LEN - 1);
          printf("  -%27s : %3d      ==>  \"%s\"\n", TagName, TagValue->Value.ValueUInt, cBuffer);
          break;
        case PDLM_TAG_Frequency:
          UInt2MantPrfx(TagValue->Value.ValueUInt, &uiMant, &uiPrfx);
          printf("  -%27s : %3d %sHz\n", TagName, uiMant, UNIT_PREFIX[uiPrfx]);
          break;
        case PDLM_TAG_TempScale:
          CurTempScale = TagValue->Value.ValueUInt;
          printf("  -%27s : %3d      ==>  %s\n", TagName, TagValue->Value.ValueUInt, TEMPSCALE_UNITS [TagValue->Value.ValueUInt]);
          break;
        case PDLM_TAG_TargetTemp:
        case PDLM_TAG_CurrentTemp:
        case PDLM_TAG_CaseTemp:
          printf("  -%27s : %5.1f %s\n", TagName, TagValue->Value.ValueFloat, TEMPSCALE_UNITS[CurTempScale]);
          break;
        case PDLM_TAG_TargetTempRaw:
        case PDLM_TAG_CurrentTempRaw:
        case PDLM_TAG_CaseTempRaw:
          printf("  -%27s : %3u%s/10 ==>  %5.1f %s\n", TagName, TagValue->Value.ValueUInt, TEMPSCALE_UNITS[PDLM_TEMPERATURESCALE_CELSIUS], CalcTemperature(CurTempScale, TagValue->Value.ValueUInt), TEMPSCALE_UNITS[CurTempScale]);
          break;
        case PDLM_TAG_TriggerLevel:
          printf("  -%27s :%8.3f V\n", TagName, TagValue->Value.ValueFloat);
          break;
        default:;
          /* */
          switch (TagType) {
            case PDLM_TAGTYPE_SINGLE:
              printf("  -%27s : %7.3f\n", TagName, TagValue->Value.ValueFloat);
              break;
            case PDLM_TAGTYPE_INT:
              printf("  -%27s : %3d\n", TagName, TagValue->Value.ValueInt);
              break;
            case PDLM_TAGTYPE_INT_IN_PERTHOUSAND:
              printf("  -%27s : %3d   ==> %.3f\n", TagName,  TagValue->Value.ValueInt, 0.001F * TagValue->Value.ValueInt);
              break;
            case PDLM_TAGTYPE_UINT_DAC:
              printf("  -%27s : 0x%04X\n", TagName, TagValue->Value.ValueUInt);
              break;
            case PDLM_TAGTYPE_UINT_IN_TENTH:
              printf("  -%27s : %3d   ==> %.1f\n", TagName,  TagValue->Value.ValueUInt, 0.1F * TagValue->Value.ValueUInt);
              break;
            default:
              printf("  -%27s : %3u\n", TagName, TagValue->Value.ValueUInt);
          }
      }
    }
    return iRet;
  }



int main(int argc, char* argv[])
{
  int iRet                        = PDLM_ERROR_NONE;
  char cFormatOpenResult[]        = "  USB-Index %d: PDL-M1 with serial number %s found. %s\n";
  //
  char cDrvName[64]               = { 0 };
  char cDrvVers[64]               = { 0 };
  char cDrvDate[64]               = { 0 };
  //
  int             i;
  uint32_t        uiStatus; // status code for direct use
  T_PDLM_DEVSTATE DevState; // status helper struct
  TLaserInfo      LHInfo;
  TLaserData      LHData;
  uint32_t        FreqMinMant;
  uint32_t        FreqMinPrfx;
  uint32_t        FreqMaxMant;
  uint32_t        FreqMaxPrfx;
  uint32_t        FreqCur;
  uint32_t        FreqCurMant;
  uint32_t        FreqCurPrfx;
  uint32_t        FreqSet;
  uint32_t        FreqSetMant;
  uint32_t        FreqSetPrfx;
  uint32_t        PowerPermille;
  float           RealPower;
  float           PowerMant;
  uint32_t        PowerPrfx;
  uint32_t        ListLen;
  TTagValue       TagList [MAX_TAGLIST_LEN];
  TTagValue       TagListCopy [MAX_TAGLIST_LEN];
  uint32_t        TagType;
  char            TagName [PDLM_TAGNAME_MAXLEN + 1];
  uint32_t        IsChanged;
  char            c;
  char            cLibVers [STD_BUFFER_LEN];
  char            cBuffer [STD_BUFFER_LEN];
  uint32_t        uiBufLen;
  //
  HMODULE         DLL = LoadLibraryA((LPCSTR)("PDLM_Lib.dll"));
  //
  //
  printf("\n PDL-M1 \"Taiko\"  Demo Application  \xB8 2019 by PicoQuant GmbH, A. Podubrin\n");
  printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
  //
  CheckReturnValue("PDLM_GetLibraryVersion", PDLM_GetLibraryVersion(cLibVers, STD_BUFFER_LEN), &iRet, iNoErrorsAllowed, "");
  sprintf_s(cBuffer, sizeof(cBuffer), "Library Version : %s", cLibVers);
  printf("  [ C / C++ ]   %55s  \n\n", cBuffer);
  //
  //
  CheckReturnValue("PDLM_GetUSBDriverInfo", PDLM_GetUSBDriverInfo(cDrvName, sizeof(cDrvName), cDrvVers, sizeof(cDrvVers), cDrvDate, sizeof(cDrvDate)), &iRet, iNoErrorsAllowed, "  Cannot get driver info, probably due to no available devices or no installed driver.");
  printf("  USB-Driver Service: '%s'; V%s, %s\n\n", cDrvName, cDrvVers, cDrvDate);
  //
  //
  iUSBIdx = -1;
  //
  // open Device
  for (i = 0; i < PDLM_MAX_USBDEVICES; i++)
  {
    SecureZeroMemory(cBuffer, sizeof(cBuffer));
    CheckReturnValue("PDLM_OpenGetSerNumAndClose", PDLM_OpenGetSerNumAndClose(i, cBuffer), &iRet, iErrorsOnOpenAllowed, "");
    //
    if ((iRet != PDLM_ERROR_USB_UNKNOWN_DEVICE)
      && (iRet != PDLM_ERROR_OPEN_DEVICE_FAILED)
      )
    {
      switch (iRet)
      {
      case PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED:
        printf(cFormatOpenResult, i, cBuffer, "(busy)");
        break;
      case PDLM_ERROR_USB_INAPPROPRIATE_DEVICE:
        printf(cFormatOpenResult, i, cBuffer, "(inappropriate)");
        break;
      case PDLM_ERROR_DEVICE_ALREADY_OPENED:
        printf(cFormatOpenResult, i, cBuffer, "(already opened)");
        break;
      case PDLM_ERROR_NONE:
        printf(cFormatOpenResult, i, cBuffer, "(ready to run)");
        if (iUSBIdx < 0)
        {
          iUSBIdx = i;
        }
        break;
      }
    }
  }
  //
  if (iUSBIdx < 0)
  {
    printf("  No PDL-M1 found.\n");
    iRet = 0;
  }
  else
  {
    CheckReturnValue("PDLM_OpenDevice", PDLM_OpenDevice(iUSBIdx, cBuffer), &iRet, iNoErrorsAllowed, "  Cannot open device.");
    printf("  USB-Index %d: PDL-M1 opened.\n\n", iUSBIdx);
    //
    __try
    {
      CheckReturnValue ("PDLM_GetFWVersion", PDLM_GetFWVersion(iUSBIdx, cBuffer, sizeof(cBuffer)), &iRet, iNoErrorsAllowed, "  Cannot retrieve FW version.");
      printf("  - FW   : %s\n", cBuffer);
      //
      CheckReturnValue ("PDLM_GetFPGAVersion", PDLM_GetFPGAVersion(iUSBIdx, cBuffer, sizeof(cBuffer)), &iRet, iNoErrorsAllowed, "  Cannot retrieve FPGA version.");
      printf("  - FPGA : %s\n", cBuffer);
      //
      CheckReturnValue ("PDLM_GetLHVersion", PDLM_GetLHVersion(iUSBIdx, cBuffer, sizeof(cBuffer)), &iRet, iNoErrorsAllowed, "  Cannot retrieve LH version.");
      printf("  - LH   : %s\n\n", cBuffer);
      //
      // lock the GUI as long we are working with it
      // (PDLM_CloseDevice will automatically unlock it)
      CheckReturnValue ("PDLM_SetExclusiveUI", PDLM_SetExclusiveUI (iUSBIdx, PDLM_UI_EXCLUSIVE), &iRet, iNoErrorsAllowed, "  Cannot lock the device GUI.");
      //
      // check Status of the PDL-M1 device
      CheckReturnValue ("PDLM_GetSystemStatus", PDLM_GetSystemStatus (iUSBIdx, &uiStatus), &iRet, iNoErrorsAllowed, "  Cannot read system status.");
      //
      // to interpret the status code, one can either use the helper struct...
      DevState.ui = uiStatus;
      printf("  Laser is%slocked by On/Off Button\n", DevState.bs.LockedByOnOffButton? " " : " NOT ");
      //
      // ...or one decodes it "by hand"
      printf("  Laser is%slocked by key\n", ((PDLM_DEVSTATE_KEYLOCK & uiStatus) > 0) ? " " : " NOT ");
      //
      // get some LaserHead Informations
      CheckReturnValue("PDLM_GetLHInfo", PDLM_GetLHInfo (iUSBIdx, &LHInfo, sizeof(LHInfo)), &iRet, iNoErrorsAllowed, "  Cannot get laser head info.");
      printf("\n  connected laser head:\n");
      printf("  - laser head type            : \"%s\"\n", LHInfo.LType);
      printf("  - date of manufacturing      : %s\n", LHInfo.Date);
      printf("  - laser power class          : %s\n", LHInfo.LClass);
      //
      // get specs of the laserhead
      CheckReturnValue("PDLM_GetLHData", PDLM_GetLHData (iUSBIdx, &LHData, sizeof (LHData)), &iRet, iNoErrorsAllowed, "  Cannot get laser head data.");
      //
      UInt2MantPrfx (LHData.FreqMin, &FreqMinMant, &FreqMinPrfx);
      UInt2MantPrfx (LHData.FreqMax, &FreqMaxMant, &FreqMaxPrfx);
      //
      printf("  - frequency range            : %3d %sHz - %3d %sHz\n", FreqMinMant, UNIT_PREFIX[FreqMinPrfx], FreqMaxMant, UNIT_PREFIX[FreqMaxPrfx]);
      //
      // get current temperature scale
      CheckReturnValue("PDLM_GetTempScale", PDLM_GetTempScale(iUSBIdx, &CurTempScale), &iRet, iNoErrorsAllowed, "  Cannot get current temperature scale.");
      OldTempScale = CurTempScale;
      //
      CurTempScale = PDLM_TEMPERATURESCALE_CELSIUS; // PDLM_TEMPERATURESCALE_FAHRENHEIT;
      if (OldTempScale != CurTempScale)
      {
        CheckReturnValue("PDLM_SetTempScale", PDLM_SetTempScale(iUSBIdx, CurTempScale), &iRet, iNoErrorsAllowed, "  Cannot set current temperature scale.");
      }
      //
      // set laser mode to pulsed emission
      CheckReturnValue("PDLM_SetLaserMode", PDLM_SetLaserMode (iUSBIdx, PDLM_LASER_MODE_PULSE), &iRet, iNoErrorsAllowed, "  Cannot set laser mode to pulsed.");
      //
      // check which frequency is currently set
      CheckReturnValue("PDLM_GetFrequency", PDLM_GetFrequency (iUSBIdx, &FreqCur), &iRet, iNoErrorsAllowed, "  Cannot get frequency.");
      //
      UInt2MantPrfx(FreqCur, &FreqCurMant, &FreqCurPrfx);
      printf("\n  frequency currently set      : %3d %sHz\n", FreqCurMant, UNIT_PREFIX[FreqCurPrfx]);
      //
      // set to 10 Mhz if in range for this head
      FreqSet = EnsureRange ((unsigned int)(1e7), LHData.FreqMin, LHData.FreqMax);
      UInt2MantPrfx(FreqSet, &FreqSetMant, &FreqSetPrfx);
      //
      CheckReturnValue("PDLM_SetFrequency", PDLM_SetFrequency (iUSBIdx, FreqSet), &iRet, iNoErrorsAllowed, "  Cannot set frequency.");
      printf("  frequency now set to         : %3d %sHz\n", FreqSetMant, UNIT_PREFIX[FreqSetPrfx]);
      //
      //
      // set optical power in permille values  (try also other values as commented)
      PowerPermille = 50; // 5.0%    //  900; // 90.0 %    // 1000; // 100.0%    //  400; // 40.0 %    //  68; // 6.8%  //
      CheckReturnValue("PDLM_SetPulsePowerPermille", PDLM_SetPulsePowerPermille(iUSBIdx, PowerPermille), &iRet, iNoErrorsAllowed, "  Cannot set pulse power.");
      //
      // read the resulting Power in W
      CheckReturnValue("PDLM_GetPulsePower", PDLM_GetPulsePower (iUSBIdx, &RealPower), &iRet, iErrorsAllowedOnExtTrig, "  Cannot read pulse power.");
      if (iRet == PDLM_ERROR_NONE)
      {
        if (RealPower == 0)
        {
          printf("  Cannot set power.\n");
          if (LHData.Protection > 0)
          {
            printf("  - This is a class 4 laser head; You must unlock it by key first.\n");
          }
          else
          {
            printf("  - Check for laser locking conditions.\n");
          }
        }
        else
        {
          Float2MantPrfx(RealPower, &PowerMant, &PowerPrfx);
          printf("  pulse power set to           :%6.1f %%  ==>  %7.3f %sW\n", 0.1 * PowerPermille, PowerMant, UNIT_PREFIX[PowerPrfx]);
        }
      }
      else
      {
        printf("  pulse power set to           :%6.1f %%\n", 0.1 * PowerPermille);
      }
      //
      // one can also get the Information via a TagList all together in one call
      //
      //  initialize/prepare list (somewhat bigger than the number of all tags defined)
      //
      SecureZeroMemory(TagList, sizeof(TagList));
      //
      ListLen = 10;
      //
      TagList[0].Tag = PDLM_TAG_Frequency;
      TagList[1].Tag = PDLM_TAG_TempScale;
      TagList[2].Tag = PDLM_TAG_TargetTemp;
      TagList[3].Tag = PDLM_TAG_TriggerLevel;
      TagList[4].Tag = PDLM_TAG_LDH_PulsePowerTable;
      TagList[5].Tag = PDLM_TAG_PulsePowerHiLimit;
      TagList[6].Tag = PDLM_TAG_PulsePowerPermille;
      TagList[7].Tag = PDLM_TAG_PulsePower;
      TagList[8].Tag = PDLM_TAG_PulseShape;
      TagList[9].Tag = PDLM_TAG_NONE;  // every list must finish with a PDLM_TAG_NONE as last entry
      //
      memcpy_s(TagListCopy, MAX_TAGLIST_LEN * sizeof(TTagValue), TagList, ListLen * sizeof(TTagValue));
      //
      //
      // do the call
      CheckReturnValue("PDLM_GetTagValueList", PDLM_GetTagValueList(iUSBIdx, ListLen, TagList), &iRet, iNoErrorsAllowed, "  Cannot get Values via TagList.");
      //
      printf("\n  got via TagList:\n");
      //
      for (int i = 0; i < ((int)(ListLen) - 1); i++)
      {
        if (TagList[i].Tag == TagListCopy[i].Tag)
        {
          CheckReturnValue("Demo_PrintTagValue", Demo_PrintTagValue(&(TagList[i])), &iRet, iNoErrorsAllowed, "  Cannot print the tag value.");
        }
        else
        {
          CheckReturnValue("PDLM_GetTagDescription", PDLM_GetTagDescription(TagListCopy[i].Tag, &TagType, TagName), &iRet, iErrorsAllowedOnTagDescr, "  Cannot get tag description.");
          uiBufLen = STD_BUFFER_LEN - 1;
          PDLM_DecodeError(TagList[i].Value.ValueInt, cBuffer, &uiBufLen);
          printf("  - error (%d) on %d. value (%s): \"%s\"\n", TagList[i].Value.ValueInt, i, TagName, cBuffer);
        }
      }
      printf("\n");
      //
      //
      // Unlock the device GUI and ask user to change something
      CheckReturnValue("PDLM_SetExclusiveUI", PDLM_SetExclusiveUI (iUSBIdx, PDLM_UI_COOPERATIVE), &iRet, iNoErrorsAllowed, "  Cannot unlock the device GUI.");
      //
      // Wait a little bit, clear pending changes
      Sleep(100);
      //
      ListLen = MAX_TAGLIST_LEN;
      SecureZeroMemory (TagList, MAX_TAGLIST_LEN);
      CheckReturnValue("PDLM_GetQueuedChanges", PDLM_GetQueuedChanges (iUSBIdx, TagList, &ListLen), &iRet, iNoErrorsAllowed, "  Cannot get pending changes.");
      //
      printf("  device GUI unlocked\n");
      //
      do
      {
        IsChanged = 0;
        printf("\n  Change something (frequency, power or type 'x' to leave) and hit return >");
        scanf_s("%c", &c, 1);
        printf("\n");
        //
        // Check for changes
        ListLen = MAX_TAGLIST_LEN;
        SecureZeroMemory(TagList, ListLen);
        //
        CheckReturnValue("PDLM_GetQueuedChanges", PDLM_GetQueuedChanges(iUSBIdx, TagList, &ListLen), &iRet, iNoErrorsAllowed, "  Cannot get pending changes.");
        IsChanged = 0;
        //
        printf("\n  changes as got via TagList:\n");
        //
        for (int i = 0; i < ((int)(ListLen)); i++)
        {
          if (TagList[i].Tag != PDLM_TAG_NONE)
          {
            CheckReturnValue("Demo_PrintTagValue", Demo_PrintTagValue(&(TagList[i])), &iRet, iNoErrorsAllowed, "  Cannot print the tag value.");
            IsChanged = 1;
          }
        }
        //
        //
        if ((c != 'x') && !IsChanged)
        {
          printf("  - no frequency or pulse power changes detected.\n");
        }
        printf("\n");
        //
      } while (c != 'x');
    }
    __finally
    {
      // termination code:
      //
      PDLM_SetExclusiveUI(iUSBIdx, PDLM_UI_COOPERATIVE);
      if (OldTempScale != CurTempScale)
      {
        PDLM_SetTempScale(iUSBIdx, OldTempScale);
      }
      PDLM_CloseDevice (iUSBIdx); // sets also UI-mode back to PDLM_UI_COOPERATIVE...
    }
  }
  //
  printf ("\nhit return to leave...");
  scanf_s ("%c", &c, 1);
  exit (iRet);
}
