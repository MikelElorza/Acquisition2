program PDLM_SimpleDemo;
//
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  PDLMUser_ImportUnit in 'PDLMUser_ImportUnit.pas',
  PDLMUser_HelperUnit in 'PDLMUser_HelperUnit.pas',
  PDLMUser_TagsUnit   in 'PDLMUser_TagsUnit.pas',
  PDLMUser_ErrorCodes in 'PDLMUser_ErrorCodes.pas';

type
  TErrorNumbers            = PDLM_ERROR_NONE .. -PDLM_ERROR_WINUSB_STORED_ERROR;
  TAllowedRetVals          = set of TErrorNumbers;

const
  NoErrorsAllowed:         TAllowedRetVals = [PDLM_ERROR_NONE];
  ErrorsAllowedOnOpen:     TAllowedRetVals = [PDLM_ERROR_NONE, -PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED, -PDLM_ERROR_USB_INAPPROPRIATE_DEVICE, -PDLM_ERROR_DEVICE_ALREADY_OPENED, -PDLM_ERROR_OPEN_DEVICE_FAILED, -PDLM_ERROR_USB_UNKNOWN_DEVICE];
  ErrorsAllowedOnTagDescr: TAllowedRetVals = [PDLM_ERROR_NONE, -PDLM_ERROR_UNKNOWN_TAG];
  ErrorsAllowedOnExtTrig:  TAllowedRetVals = [PDLM_ERROR_NONE, -PDLM_ERROR_VALUE_NOT_AVAILABLE];

var
  USBIdx: Integer;
  CurTempScale: Cardinal;
  OldTempScale: Cardinal;

  procedure CheckReturnValue (strFuncName: string; iRetIn: integer; var iRetOut: integer; AllowedRetVals: TAllowedRetVals = [PDLM_ERROR_NONE]; strAdditionalInfo: string = '');
  var
    strErrTxt : string;
  begin
    iRetOut := iRetIn;
    if (iRetIn <> PDLM_ERROR_NONE)
    then begin
      if not ((-iRetIn) in AllowedRetVals)
      then begin
        PDLM_DecodeError(iRetIn, strErrTxt);
        //
        writeln;
        if (Length (strAdditionalInfo) > 0)
        then begin
          writeln (strAdditionalInfo);
        end;
        writeln ('  Error ' + IntToStr(iRetIn) + ' occured during "' + strFuncName + '" execution.');
        writeln ('    i.e. "' + strErrTxt + '"');
        write ('hit return to leave...');
        Readln;
        PDLM_CloseDevice(USBIdx);
        Halt (iRetIn);
      end;
    end;
  end;

  function CalcTemperature (ScaleIdx : T_TempScale; uiRawValue: Cardinal) : Single;
  begin
    case ScaleIdx of
      PDLM_TEMPSCALE_FAHRENHEIT: result := (0.18  * uiRawValue) +  32.0;
      PDLM_TEMPSCALE_KELVIN:     result := (0.1   * uiRawValue) + 273.1;
    else
      result := 0.1   * uiRawValue;
    end;
  end;

  function Demo_PrintTagValue(const TagValue: T_TaggedValue) : integer;
  var
    TagType: cardinal;
    TagName: string;
    fMant: single;
    iPrfx: integer;
    uiMant: cardinal;
    uiPrfx: cardinal;
    strTemp: string;
  begin
    result := PDLM_ERROR_NONE;
    CheckReturnValue('PDLM_GetTagDescription', PDLM_GetTagDescription(TagValue.tcTag, TagType, TagName), result, ErrorsAllowedOnTagDescr, '  Cannot get tag description.');
    //
    if (TagValue.tcTag <> PDLM_TAG_NONE)
    then begin

      case TagValue.tcTag of
        PDLM_TAG_NONE: begin
          result := PDLM_ERROR_ILLEGAL_VALUE;
        end;
        PDLM_TAG_LDH_PulsePowerTable: begin
          writeln('  -', TagName:27, ' :', TagValue.ttvValue.uiValue:4, '  ==> ', ifthen(TagValue.ttvValue.uiValue > 0, 'max.', 'linear'), ' power mode');
        end;
        PDLM_TAG_PulsePower,
        PDLM_TAG_PulsePowerHiLimit,
        PDLM_TAG_PulsePowerLoLimit: begin
          Float2MantPrfx (TagValue.ttvValue.fValue, fMant, iPrfx);
          writeln('  -', TagName:27, ' : ', fMant:7:3, PreFixChar[iPrfx]:2, 'W');
        end;
        PDLM_TAG_PulsePowerNanoWatt:
        begin
          Float2MantPrfx (1e-9 * TagValue.ttvValue.uiValue, fMant, iPrfx);
          writeln('  -', TagName:27, ' : ', TagValue.ttvValue.uiValue, ' nW  ==> ' , fMant:7:3, PreFixChar[iPrfx]:2, 'W');
        end;
        PDLM_TAG_PulsePowerPermille: begin
          writeln('  -', TagName:27, ' :', TagValue.ttvValue.uiValue:4, ' permille  ==> ', (0.1 * TagValue.ttvValue.uiValue):5:1, '%');
        end;
        PDLM_TAG_PulsePowerShape: begin
          PDLM_DecodePulseShape (TagValue.ttvValue.uiValue, strTemp);
          writeln('  -', TagName:27, ' : ', TagValue.ttvValue.uiValue:3, '  ==> "', strTemp, '"');
        end;
        PDLM_TAG_Frequency: begin
          UInt2MantPrfx(TagValue.ttvValue.uiValue, uiMant, uiPrfx);
          writeln('  -', TagName:27, ' : ', uiMant:3, PreFixChar[uiPrfx]:2, 'Hz');
        end;
        PDLM_TAG_TempScale: begin
          CurTempScale := TagValue.ttvValue.uiValue;
          writeln('  -', TagName:27, ' : ', CurTempScale:3, '  ==> ', PDLM_TEMPSCALE_UNITS [T_TempScale(CurTempScale)]);
        end;
        PDLM_TAG_LHTargetTempRaw,
        PDLM_TAG_LHCurrentTempRaw,
        PDLM_TAG_LHCaseTempRaw: begin
          writeln('  -', TagName:27, ' : ', TagValue.ttvValue.uiValue:3, PDLM_TEMPSCALE_UNITS [PDLM_TEMPSCALE_CELSIUS], '/10  ==> ', CalcTemperature(T_TempScale (CurTempScale), TagValue.ttvValue.uiValue):5:1, ' ', PDLM_TEMPSCALE_UNITS [T_TempScale(CurTempScale)]);
        end;
        PDLM_TAG_LHTargetTemp,
        PDLM_TAG_LHCurrentTemp,
        PDLM_TAG_LHCaseTemp: begin
          writeln('  -', TagName:27, ' : ', TagValue.ttvValue.fValue:5:1, ' ', PDLM_TEMPSCALE_UNITS [T_TempScale(CurTempScale)]);
        end;
        PDLM_TAG_TriggerLevel: begin
          writeln('  -', TagName:27, ' : ', TagValue.ttvValue.fValue:7:3, ' V');
        end;
      else
        case TagType of
          PDLM_TAGTYPE_SINGLE:             writeln('  -', TagName:27, ' : ', TagValue.ttvValue.fValue);
          PDLM_TAGTYPE_INT:                writeln('  -', TagName:27, ' : ', TagValue.ttvValue.iValue);
          PDLM_TAGTYPE_INT_IN_PERTHOUSAND: writeln('  -', TagName:27, ' : ', TagValue.ttvValue.iValue, '  ==> ', (0.001 * TagValue.ttvValue.iValue):7:3);
          PDLM_TAGTYPE_UINT_DAC:           writeln('  -', TagName:27, ' : 0x', IntToHex(TagValue.ttvValue.uiValue, 4));
          PDLM_TAGTYPE_UINT_IN_TENTH:      writeln('  -', TagName:27, ' : ', TagValue.ttvValue.uiValue:3, '  ==> ', (0.1 * TagValue.ttvValue.uiValue):5:1);
        else                               writeln('  -', TagName:27, ' : ', TagValue.ttvValue.uiValue);
        end;
      end;
    end;
  end;


procedure Main;
var
  i, Res: Integer;
  strBuffer: string;
  VersStr: string;
  DrvName: string;
  DrvVers: string;
  DrvDate: string;
  Serial: string;
  Status: LongWord;
  DevState: T_DeviceState;
  LHInfo: T_LHInfo;
  LHData: T_LHData;
  FreqMinMant: cardinal;
  FreqMinPrfx: cardinal;
  FreqMaxMant: cardinal;
  FreqMaxPrfx: cardinal;
  FreqCur: cardinal;
  FreqCurMant: cardinal;
  FreqCurPrfx: cardinal;
  FreqSet: cardinal;
  FreqSetMant: cardinal;
  FreqSetPrfx: cardinal;
  PowerPermille: cardinal;
  RealPower: single;
  PowerMant: single;
  PowerPrfx: integer;
  strErrBuff: string;
  Num: LongWord;
  isChanged: Boolean;
  TagList: T_TaggedValueList;
  TagListCopy: T_TaggedValueList;
  ListLen: Integer;
  TagType: cardinal;
  TagName: string;
  c: string;
  //
begin

  if not bPLDMImportLibOK then
  begin
    writeln('Cannot load ', STR_LIB_NAME, ', ', strLibVersion);
    Exit;
  end;
  //
  writeln;
  writeln(' PDL-M1 "Taiko"  Demo Application  © 2019 by PicoQuant GmbH, A. Podubrin');
  writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  //
  CheckReturnValue('PDLM_GetLibraryVersion', PDLM_GetLibraryVersion(VersStr), Res);
  writeln('  [ Delphi / Object Pascal ]  ', ('Library Version : ' + VersStr):41);
  writeln;
  //
  //
  CheckReturnValue('PDLM_GetUSBDriverInfo', PDLM_GetUSBDriverInfo(DrvName, DrvVers, DrvDate), Res, NoErrorsAllowed);
  writeln('  USB-Driver Service: "', DrvName, '"; V', DrvVers, ', ', DrvDate); writeln;
  //
  USBIdx := -1;
  //
  // Open Device
  for i := 0 to PDLM_MAX_USB_DEVICES - 1 do
  begin
    Serial := '';
    CheckReturnValue ('PDLM_OpenGetSerNumAndClose', PDLM_OpenGetSerNumAndClose(i, Serial), Res, ErrorsAllowedOnOpen);
    if not ( (Res = PDLM_ERROR_USB_UNKNOWN_DEVICE)
          or (Res = PDLM_ERROR_OPEN_DEVICE_FAILED)
           )
    then begin
      strBuffer := '  USB-Index ' + IntToStr (i) + ': PDL-M1 with serial number ' + Serial + ' found. ';
      //
      case res of
        PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED :
          begin
            writeln (strBuffer, '(busy)');
          end;
        PDLM_ERROR_USB_INAPPROPRIATE_DEVICE :
          begin
            writeln (strBuffer, '(inappropriate)');
          end;
        PDLM_ERROR_DEVICE_ALREADY_OPENED :
          begin
            writeln (strBuffer, '(already opened)');
          end;
        PDLM_ERROR_NONE :
          begin
            writeln (strBuffer, '(ready to run)');
            if USBIdx < 0 then  USBIdx := i;
          end;
      end;
    end;
  end;
  //
  if USBIdx < 0 then
  begin
    writeln('  No PDL-M1 found.');
    writeln;
    Exit;
  end;
  //
  CheckReturnValue ('PDLM_OpenDevice', PDLM_OpenDevice(USBIdx, Serial), Res, NoErrorsAllowed, '  Cannot open device ' + IntToStr (USBIdx) + '.');
  writeln('  USB-Index ' + IntToStr (USBIdx) + ': PDL-M1 opened.');
  writeln;
  //
  try
    writeln ('  Version Infos:');
    CheckReturnValue ('PDLM_GetFWVersion', PDLM_GetFWVersion(USBIdx, VersStr), Res, NoErrorsAllowed, '  Cannot retrieve FW version.');
    writeln ('  - FW   : ', VersStr);
    //
    CheckReturnValue ('PDLM_GetFPGAVersion', PDLM_GetFPGAVersion(USBIdx, VersStr), Res, NoErrorsAllowed, '  Cannot retrieve FPGA version.');
    writeln ('  - FPGA : ', VersStr);
    //
    CheckReturnValue ('PDLM_GetLHVersion', PDLM_GetLHVersion(USBIdx, VersStr), Res, NoErrorsAllowed, '  Cannot retrieve LH version.');
    writeln ('  - LH   : ', VersStr);
    writeln;
    //
    // lock the GUI as long we are working with it
    // (PDLM_CloseDevice will automatically unlock it)
    CheckReturnValue ('PDLM_SetExclusiveUI', PDLM_SetExclusiveUI(USBIdx, True), Res, NoErrorsAllowed, '  Cannot lock the device GUI.');
    //
    // Check Status of PDL-M
    CheckReturnValue ('PDLM_GetSystemStatus', PDLM_GetSystemStatus(USBIdx, Status), Res, NoErrorsAllowed, '  Cannot read system status.');
    //
    // To interpret the status code, one can either use the helper struct...
    DevState.ui := Status;
    writeln('  Laser is', ifthen (DevState.LockedByOnOffButton, ' ', ' NOT '), 'locked by On/Off button');
    //
    // ...or one can decode it "by hand"
    writeln('  Laser is', ifthen ((PDLM_DEVSTATE_KEYLOCK and Status) > 0, ' ', ' NOT '), 'locked by key');
    writeln;
    //
    // Get some LaserHead Informations
    CheckReturnValue ('PDLM_GetLHInfo', PDLM_GetLHInfo(USBIdx, LHInfo), Res, NoErrorsAllowed, '  Cannot get laser head info.');
    writeln('  Connected laser head:');
    writeln('  - laser head type            : "', LHInfo.LType, '"');
    writeln('  - date of manufacturing      : ', LHInfo.Date);
    writeln('  - laser power class          : ', LHInfo.LClass);
    //
    // Get specs of the laserhead
    CheckReturnValue ('PDLM_GetLHData', PDLM_GetLHData(USBIdx, LHData), Res, NoErrorsAllowed, '  Cannot get laser head data.');
    UInt2MantPrfx(LHData.FreqMin, FreqMinMant, FreqMinPrfx);
    UInt2MantPrfx(LHData.FreqMax, FreqMaxMant, FreqMaxPrfx);
    writeln('  - frequency range            : ', FreqMinMant:3, PreFixChar[FreqMinPrfx]:2, 'Hz - ', FreqMaxMant:3, PreFixChar[FreqMaxPrfx]:2, 'Hz');
    writeln;
    //
    // Get current temperature scale
    CheckReturnValue ('PDLM_GetTempScale', PDLM_GetTempScale (USBIdx, CurTempScale), Res, NoErrorsAllowed, '  Cannot get current temperature scale.');
    OldTempScale := CurTempScale;
    //
    CurTempScale := Cardinal(PDLM_TEMPSCALE_CELSIUS); // Cardinal(PDLM_TEMPSCALE_FAHRENHEIT);
    if not (OldTempScale = CurTempScale) then
      CheckReturnValue ('PDLM_SetTempScale', PDLM_SetTempScale (USBIdx, CurTempScale), Res, NoErrorsAllowed, '  Cannot set current temperature scale.');
    //
    // Set laser mode to pulsed emission
    CheckReturnValue ('PDLM_SetLaserMode', PDLM_SetLaserMode(USBIdx, PDLM_LASERMODE_PULSE), Res, NoErrorsAllowed, '  Cannot set laser mode to pulsed.');
    //
    // check which frequency is currently set
    CheckReturnValue ('PDLM_GetFrequency', PDLM_GetFrequency(USBIdx, FreqCur), Res, NoErrorsAllowed, '  Cannot get frequency.');
    UInt2MantPrfx(FreqCur, &FreqCurMant, &FreqCurPrfx);
    writeln('  Frequency is currently       : ', FreqCurMant:3, PreFixChar[FreqCurPrfx]:2, 'Hz');
    //
    // set to 10 Mhz if in range for this head
    FreqSet := EnsureRange (10000000, LHData.FreqMin, LHData.FreqMax); // make sure its in the Range
    CheckReturnValue ('PDLM_SetFrequency', PDLM_SetFrequency(USBIdx, FreqSet), Res, NoErrorsAllowed, '  Cannot set frequency.');
    UInt2MantPrfx(FreqSet, &FreqSetMant, &FreqSetPrfx);
    writeln('  Frequency set to             : ', FreqSetMant:3, PreFixChar[FreqSetPrfx]:2, 'Hz');
    //
    // Set Power
    PowerPermille := 50; // 5.0%  //  900; // 90.0 %  // 1000; // 100.0%  //  400; // 40.0 %  //  68; // 6.8%  //
    CheckReturnValue ('PDLM_SetPulsePowerPermille', PDLM_SetPulsePowerPermille(USBIdx, PowerPermille), Res, NoErrorsAllowed, '  Cannot set pulse power.');
    //
    // read the resulting Power in mW
    CheckReturnValue ('PDLM_GetPulsePower', PDLM_GetPulsePower(USBIdx, RealPower), Res, ErrorsAllowedOnExtTrig, '  Cannot read pulse power.');
    if (Res = PDLM_ERROR_NONE)
    then begin
      if (RealPower = 0)
      then begin
        writeln('  Cannot set power.');
        if (LHData.Protection) then
          writeln('  - This is a class 4 laser head; You must unlock it by key first.')
        else
          writeln('  - Check for laser locking conditions.');
      end
      else begin
        Float2MantPrfx(RealPower, PowerMant, PowerPrfx);
        writeln('  Pulse power set to           :', (0.1 * PowerPermille):6:1, '%  ==>  ', PowerMant:7:3, PreFixChar[PowerPrfx]:2, 'W');
      end;
    end
    else
      writeln('  Pulse power set to           :', (0.1 * PowerPermille):6:1, '%');
    //
    // one can also get the Information via a TagList all together with one call
    //  prepare list
    SetLength(TagList, 10);
    FillChar(TagList[0], Length(TagList) * sizeof(T_TaggedValue), #0);
    //
    TagList[0].tcTag := PDLM_TAG_Frequency;
    TagList[1].tcTag := PDLM_TAG_TempScale;
    TagList[2].tcTag := PDLM_TAG_LHTargetTemp;
    TagList[3].tcTag := PDLM_TAG_TriggerLevel;
    TagList[4].tcTag := PDLM_TAG_LDH_PulsePowerTable;
    TagList[5].tcTag := PDLM_TAG_PulsePowerHiLimit;
    TagList[6].tcTag := PDLM_TAG_PulsePowerPermille;
    TagList[7].tcTag := PDLM_TAG_PulsePower;
    TagList[8].tcTag := PDLM_TAG_PulsePowerShape;
    TagList[9].tcTag := PDLM_TAG_NONE; // every list must finish with a PDLM_TAG_NONE as last entry
    TagListCopy := Copy(TagList);      // we save a copy for later use
    ListLen := Length(TagList);
    // do the call
    CheckReturnValue ('PDLM_GetTaggedValueList', PDLM_GetTaggedValueList(USBIdx, ListLen, TagList), Res, NoErrorsAllowed, '  Cannot get values via TagList.');
    writeln;
    writeln('  Got via TagList:');
    for i:=0 to ListLen-2  // last tag (i.e. PDLM_TAG_NONE) will be ignored
    do begin
      if (TagList[i].tcTag = TagListCopy[i].tcTag)
      then begin
        CheckReturnValue ('Demo_PrintTagValue', Demo_PrintTagValue(TagList[i]), Res, NoErrorsAllowed, '  Cannot print the tag value.');
      end
      else begin
        CheckReturnValue ('PDLM_GetTagDescription', PDLM_GetTagDescription(TagListCopy[i].tcTag, TagType, TagName), Res, ErrorsAllowedOnTagDescr, '  Cannot get tag description.');
        //
        PDLM_DecodeError (TagList[i].ttvValue.iValue, strErrBuff);
        writeln('  - error (' + IntToStr (TagList[i].ttvValue.iValue) + ') on ' + IntToStr (i) + '. value (', TagName, '): "', strErrBuff, '"');
      end;
    end;
    writeln;
    //
    // Unlock the Device GUI and ask user to change something
    CheckReturnValue ('PDLM_SetExclusiveUI', PDLM_SetExclusiveUI(USBIdx, False), Res, NoErrorsAllowed, '  Cannot unlock the device GUI.');
    //
    // Wait a little bit, Clear pending changes
    Sleep(100);
    //
    CheckReturnValue ('PDLM_GetQueuedChanges', PDLM_GetQueuedChanges(USBIdx, TagList, Num), Res, NoErrorsAllowed, '  Cannot get pending changes.');
    writeln('  Device GUI unlocked');
    writeln;
    //
    repeat
      write('  Change something (frequency, power or type ''x'' to leave) and hit return >');

      Readln (c);

      // Check for changes
      SetLength(TagList, 0);   // erases TagList
      Num := 64;
    //SetLength(TagList, Num); // re-allocates TagList
      CheckReturnValue ('PDLM_GetQueuedChanges', PDLM_GetQueuedChanges(USBIdx, TagList, Num), Res, NoErrorsAllowed, '  Cannot get pending changes.');
      isChanged := False;
      writeln;
      for i := 0 to Num - 1 do
      begin
        CheckReturnValue ('Demo_PrintTagValue', Demo_PrintTagValue(TagList[i]), Res, NoErrorsAllowed, '  Cannot print the tag value.');
        isChanged := True;
      end;
      if not ((c = 'x') or IsChanged) then
        writeln('No frequency or pulse power changes detected.');
      //
      writeln;
    until (c = 'x');
    //
  finally
    PDLM_CloseDevice(USBIdx);
  end;
end;

begin
  Main;
  write ('hit return to leave...');
  Readln;
end.
