program PDLM_ComprehensiveDemo;
//

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Math,
  System.Classes,
  System.Character,
  System.SysUtils,
  System.StrUtils,
  PDLMUser_TagsUnit in 'PDLMUser_TagsUnit.pas',
  PDLMUser_ImportUnit in 'PDLMUser_ImportUnit.pas',
  PDLMUser_HelperUnit in 'PDLMUser_HelperUnit.pas',
  PDLMUser_ErrorCodes in 'PDLMUser_ErrorCodes.pas';

type
  TUSBIdx                         = 0..(PDLM_MAX_USB_DEVICES-1);
  TUSBIdxSet                      = set of TUSBIdx;
  TACharSet                       = set of AnsiChar;
  TErrorNumbers                   = PDLM_ERROR_NONE .. -PDLM_ERROR_UNKNOWN_TAG;
  TAllowedRetVals                 = set of TErrorNumbers;

const
  STR_LINEBREAK                   = ''#$0D#$0A;
  STR_LASERMODE_CW                = 'continuous wave - mode';
  STR_LASERMODE_PULSE             = 'pulse - mode';
  STR_LASERMODE_BURST             = 'burst - mode';
  //
  CHAR_ZERO_OFFSET                = ord ('0');
  //
  CHAR_YES                        = 'y';
  CHAR_NO                         = 'n';
  //
  CHAR_EXCLUSIVE_UI               = 'e';
  CHAR_COOPERATIVE_UI             = 'c';
  //
  CHAR_SOFT_LOCK                  = 'l';
  CHAR_SOFT_UNLOCK                = 'u';
  //
  CHAR_CW_MODE                    = 'c';
  CHAR_PULSE_MODE                 = 'p';
  CHAR_BURST_MODE                 = 'b';
  //
  CHAR_SWITCH_PULSEPOWERMODE      = 'm';
  //
  CHAR_DEC_BY_THOUSAND            = 'k';
  CHAR_INC_BY_THOUSAND            = 'K';
  CHAR_DEC_BY_HUNDRED             = 'h';
  CHAR_INC_BY_HUNDRED             = 'H';
  CHAR_DEC_BY_TEN                 = 't';
  CHAR_INC_BY_TEN                 = 'T';
  CHAR_DEC_BY_ONE                 = 'o';
  CHAR_INC_BY_ONE                 = 'O';
  //
  CHAR_DEC_BY_TENTH               = 'd';
  CHAR_INC_BY_TENTH               = 'D';
  CHAR_DEC_BY_HUNDREDTH           = 'c';
  CHAR_INC_BY_HUNDREDTH           = 'C';
  CHAR_DEC_BY_THOUSANDTH          = 'm';
  CHAR_INC_BY_THOUSANDTH          = 'M';
  //
  CHAR_SCALE_CELSIUS              = 'C';
  CHAR_SCALE_FAHRENHEIT           = 'F';
  CHAR_SCALE_KELVIN               = 'K';
  //
  CHAR_SWITCH_BPARAM              = 'B';
  //
  CHAR_TRIG_INTERNAL              = 'i';
  CHAR_TRIG_EXT_FALLING           = 'f';
  CHAR_TRIG_EXT_RISING            = 'r';
  //
  CHAR_FREQ_DEC_SEQIDX            = 's';
  CHAR_FREQ_INC_SEQIDX            = 'S';
  CHAR_FREQ_PREFIX_MEGA           = 'M';
  CHAR_FREQ_PREFIX_KILO           = 'k';
  CHAR_FREQ_PREFIX_NONE           = '_';
  //
  CHAR_PROG_EXIT                  = 'x';
  CHAR_PHASE_EXIT                 = '-';
  //
  CHAR_MAIN_INFO                  = 'i';
  CHAR_MAIN_INFO_LONG             = 'I';
  CHAR_MAIN_UIMODE                = 'u';
  CHAR_MAIN_LOCKING               = 'l';
  CHAR_MAIN_EMISSION              = 'e';
  CHAR_MAIN_TRIGGER               = 't';
  CHAR_MAIN_FREQ                  = 'f';
  CHAR_MAIN_POWER                 = 'p';
  CHAR_MAIN_BURST                 = 'b';
  CHAR_MAIN_TEMP                  = 'T';
  //
  PROMPT_ALL_KEYS_SET             = [#$01..#$FF];
  PROMPT_NUMERIC_BASE_1E2_SET     = [CHAR_DEC_BY_TEN, CHAR_INC_BY_TEN, CHAR_DEC_BY_ONE, CHAR_INC_BY_ONE];
  PROMPT_1E2_1DECIMAL_CHANGE_SET  = PROMPT_NUMERIC_BASE_1E2_SET    + [CHAR_DEC_BY_TENTH, CHAR_INC_BY_TENTH];
  PROMPT_NUMERIC_BASE_1E3_SET     = PROMPT_NUMERIC_BASE_1E2_SET    + [CHAR_DEC_BY_HUNDRED,  CHAR_INC_BY_HUNDRED];
  PROMPT_NUMERIC_BASE_1E4_SET     = PROMPT_NUMERIC_BASE_1E3_SET    + [CHAR_DEC_BY_THOUSAND, CHAR_INC_BY_THOUSAND];
  PROMPT_1E0_2DECIMALS_CHANGE_SET = [CHAR_DEC_BY_TENTH, CHAR_INC_BY_TENTH, CHAR_DEC_BY_HUNDREDTH, CHAR_INC_BY_HUNDREDTH, CHAR_DEC_BY_THOUSANDTH, CHAR_INC_BY_THOUSANDTH];
  //
  PROMPT_PROG_EXIT                = [CHAR_PROG_EXIT];
  PROMPT_PHASE_EXIT               = [CHAR_PHASE_EXIT];
  PROMPT_USBIDX_SET_X             = ['0'..'7'] + PROMPT_PROG_EXIT;
  PROMPT_YES_NO_SET               = [CHAR_YES, CHAR_NO];
  PROMPT_YES_NO_SET_X             = PROMPT_YES_NO_SET + PROMPT_PROG_EXIT;
  PROMPT_EXITCODES                = PROMPT_PHASE_EXIT + PROMPT_PROG_EXIT;
  //
  PROMPT_SOFTLOCK_SET             = [CHAR_SOFT_LOCK, CHAR_SOFT_UNLOCK];
  PROMPT_SOFTLOCK_SET_EX          = PROMPT_SOFTLOCK_SET + PROMPT_EXITCODES;
  //
  PROMPT_UIMODE_SET               = [CHAR_EXCLUSIVE_UI, CHAR_COOPERATIVE_UI];
  PROMPT_UIMODE_SET_EX            = PROMPT_UIMODE_SET + PROMPT_EXITCODES;
  //
  PROMPT_LASERMODE_SET            = [CHAR_CW_MODE, CHAR_PULSE_MODE, CHAR_BURST_MODE];
  PROMPT_LASERMODE_SET_EX         = PROMPT_LASERMODE_SET            + PROMPT_EXITCODES;
  //
  PROMPT_POWERCHANGE_SET_EX       = PROMPT_1E2_1DECIMAL_CHANGE_SET  + PROMPT_EXITCODES;
  PROMPT_POWER_MODECHANGE_SET_EX  = PROMPT_POWERCHANGE_SET_EX + [CHAR_SWITCH_PULSEPOWERMODE];
  //
  PROMPT_TRIGGER_MODES            = [CHAR_TRIG_INTERNAL, CHAR_TRIG_EXT_FALLING, CHAR_TRIG_EXT_RISING];
  PROMPT_INTTRIGGER_CHANGE_SET    = PROMPT_TRIGGER_MODES;
  PROMPT_INTTRIGGER_CHANGE_SET_EX = PROMPT_INTTRIGGER_CHANGE_SET    + PROMPT_EXITCODES;
  PROMPT_EXTTRIGGER_CHANGE_SET    = PROMPT_TRIGGER_MODES + PROMPT_1E0_2DECIMALS_CHANGE_SET;
  PROMPT_EXTTRIGGER_CHANGE_SET_EX = PROMPT_EXTTRIGGER_CHANGE_SET    + PROMPT_EXITCODES;
  //
  PROMPT_TARGETTEMP_CHANGE_SET    = PROMPT_1E2_1DECIMAL_CHANGE_SET  + [CHAR_SCALE_CELSIUS, CHAR_SCALE_FAHRENHEIT, CHAR_SCALE_KELVIN];
  PROMPT_TARGETTEMP_CHANGE_SET_EX = PROMPT_TARGETTEMP_CHANGE_SET    + PROMPT_EXITCODES;
  //
  PROMPT_BURSTDATA_CHANGE_SET     = PROMPT_NUMERIC_BASE_1E4_SET     + [CHAR_SWITCH_BPARAM];
  PROMPT_BURSTDATA_CHANGE_SET_EX  = PROMPT_BURSTDATA_CHANGE_SET     + PROMPT_EXITCODES;
  //
  PROMPT_FREQUENCY_PREFIXES       = [CHAR_FREQ_PREFIX_MEGA, CHAR_FREQ_PREFIX_KILO, CHAR_FREQ_PREFIX_NONE];

  PROMPT_FREQUENCY_BASE_SET       = PROMPT_NUMERIC_BASE_1E2_SET     + PROMPT_FREQUENCY_PREFIXES + [CHAR_FREQ_DEC_SEQIDX, CHAR_FREQ_INC_SEQIDX];
  PROMPT_FREQUENCY_BASE_SET_EX    = PROMPT_FREQUENCY_BASE_SET       + PROMPT_EXITCODES;
  //
  PROMPT_MAINMENU_SET             = [CHAR_MAIN_INFO, CHAR_MAIN_INFO_LONG, CHAR_MAIN_UIMODE, CHAR_MAIN_LOCKING, CHAR_MAIN_EMISSION, CHAR_MAIN_TRIGGER, CHAR_MAIN_FREQ, CHAR_MAIN_POWER, CHAR_MAIN_BURST, CHAR_MAIN_TEMP];
  PROMPT_MAINMENU_SET_EX          = PROMPT_MAINMENU_SET + PROMPT_EXITCODES;


var
  bChanges    : boolean;
  dsState     : T_DeviceState;
  strlList    : TStringList;

const
  SCALE_UNITS : array [T_TempScale] of string = ('°C', '°F', 'K');
  SCALE_STEP  : array [T_TempScale] of single = ( 1.0,  1.8, 1.0);


  function PromptSet (strPreamble, strPrompt: string; CharSet: TACharSet): AnsiChar;
  var
    c      : AnsiChar;
    bInSet : boolean;
  begin
    WriteLn (strPreamble);
    //
    repeat
      SetCursorPos (0, GetCursorY);
      Write (strPrompt, '> ');
      //readln (c);
      c := ReadKey;
      Write (c);
      bInSet := c in CharSet;
    until bInSet;
    //
    WriteLn;
    result := c;
  end;

  procedure CheckReturnValue (strFuncName: string; iRetIn: integer; var iRetOut: integer; AllowedRetVals: TAllowedRetVals = [PDLM_ERROR_NONE]; strAdditionalInfo: string = '');
  var
    strErrTxt : string;
  begin
    iRetOut := iRetIn;
    if not ((-iRetIn) in AllowedRetVals)
    then begin
      PDLM_DecodeError(iRetIn, strErrTxt);
      //
      WriteLn;
      if (Length (strAdditionalInfo) > 0)
      then begin
        Writeln (strAdditionalInfo);
      end;
      PromptSet ('  Error ' + IntToStr(iRetIn) + ' occured during "' + strFuncName + '" execution.' + STR_LINEBREAK + '    i.e. "' + strErrTxt + '"',
                 '  Hit any key to exit...', PROMPT_ALL_KEYS_SET);
      Halt (iRetIn);
    end;
  end;

  function USBIdxSetToStr (const IdxSet : TUSBIdxSet) : string;
  var
    i : TUSBIdx;
  begin
    result := '[';
    for i:=0 to (PDLM_MAX_USB_DEVICES-1)
    do begin
      if i in IdxSet
      then begin
        if length(result) > 1
        then begin
          result := result + ', ';
        end;
        result := result + IntToStr(i);
      end;
    end;
    result := result + ']';
  end;

  function CharSetToStr (const CharSet : TACharSet) : string;
  var
    i      : integer;
    cs     : TACharSet;
    str    : string;
    cLo    : AnsiChar;
    cHi    : AnsiChar;
    strEsc : string;
  begin
    result := '[';
    strEsc := '';
    cs := CharSet;
    for i:=0 to 255
    do begin
      cHi := AnsiChar(i);
      str := ''+char(cHi);
      str := AnsiLowerCase(str);
      cLo := AnsiChar(str[1]);
      //
      if cLo in cs
      then begin
        if cLo in PROMPT_EXITCODES
        then begin
          if length(strEsc) > 0
          then begin
            strEsc := strEsc + ',';
          end;
          strEsc := strEsc + char(cLo);
        end
        else begin
          if length(result) > 1
          then begin
            result := result + ',';
          end;
          result := result + char(cLo);
        end;
        Exclude (cs, cLo);
      end;
      //
      if cHi in cs
      then begin
        if cHi in PROMPT_EXITCODES
        then begin
          if length(strEsc) > 0
          then begin
            strEsc := strEsc + ',';
          end;
          strEsc := strEsc + char(cHi);
        end
        else begin
          if length(result) > 1
          then begin
            result := result + ',';
          end;
          result := result + char(cHi);
        end;
        Exclude (cs, cHi);
      end;
    end;
    result := result + ifthen ((length (result) > 1) and (length (strEsc) > 0), ',  ', '') + strEsc + ']';
  end;

  procedure Check_SystemState (iUSBIdx : TUSBIdx);
  var
    iRetVal      : integer;
    strValue     : string;
    iListIdx     : integer;
    iErrCode     : integer;
    TagValueList : T_TaggedValueList;
    uiListLen    : cardinal;
    uiTypeCode   : cardinal;
    uiStateCode  : cardinal;
    strTagName   : string;
  begin
    //
    // check frequently for system state and HW-errors:
    //
    CheckReturnValue ('PDLM_GetSystemStatus', PDLM_GetSystemStatus(iUSBIdx, uiStateCode), iRetVal);
    dsState.ui := uiStateCode;
    CheckReturnValue ('PDLM_DecodeSystemStatus', PDLM_DecodeSystemStatus(dsState.ui, strValue), iRetVal);
    strlList.Clear;
    strlList.StrictDelimiter := true;
    strlList.Delimiter := ';';
    strlList.DelimitedText := trim (strValue);
    //
    if (strlList.Count > 0)
    then begin
      WriteLn;
      WriteLn ('  System State:');
      for iListIdx:=0 to (strlList.Count-1)
      do begin
        WriteLn ('  - ' + trim (strlList.Strings[iListIdx]));
      end;
      WriteLn;
      //
      if dsState.ErrormsgPending
      then begin
        WriteLn ('  + Hardware errors detected:');
        while dsState.ErrormsgPending
        do begin
          CheckReturnValue ('PDLM_GetQueuedError', PDLM_GetQueuedError(iUSBIdx, iErrCode), iRetVal);
          CheckReturnValue ('PDLM_GetQueuedErrorString', PDLM_GetQueuedErrorString(iUSBIdx, iErrCode, strValue), iRetVal);
          WriteLn ('    - (', iErrCode:5, '): "', strValue, '"');
          CheckReturnValue ('PDLM_GetSystemStatus', PDLM_GetSystemStatus(iUSBIdx, uiStateCode), iRetVal);
          dsState.ui := uiStateCode;
        end;
        WriteLn;
      end;
      //
      if bChanges and dsState.ParameterChangesPending
      then begin
        //
        // This is mainly needed, if there is a (G)UI permanently showing
        // some volatile parameter values. Win-programs may even register
        // their main window handle (by function "PDLM_SetHWND"), to get
        // Win-messages on changes directly from the API.
        //
        // And although this demo is a simple CLI programm, where we have
        // no need to do so, we illustrate how to get the information on
        // asynchronous parameter changes (just for the records).
        // Consider, that there is a tag descriptor with tag name and
        // type information. Use this type info to scale the transmitted
        // values correctly according to their individual format.
        //
        // This routine, as scetched below, will only do a coarse handling
        // in writing the values in different formats out. But by filteríng
        // for distinct tag ids (e.g. by a case-handler on each enum value
        // of T_TagCode) we could easily write very sophisticated handlers
        // for any tags we want.
        //
        //
        // Get the whole list in one call
        CheckReturnValue ('PDLM_GetQueuedChanges', PDLM_GetQueuedChanges (iUSBIdx, TagValueList, uiListLen), iRetVal);
        // unusually, but it could be empty, in very rare cases, too...
        if uiListLen > 0
        then begin
          WriteLn ('  Parameters changed:');
          // now go for each element of the list...
          for iListIdx := 0 to (uiListLen-1)
          do begin
            // ...and get its descriptor first (of course, you could also
            // make them up into a prefetched table on start-up time...)
            CheckReturnValue ('PDLM_GetTagDescription', PDLM_GetTagDescription (TagValueList[iListIdx].tcTag, uiTypeCode, strTagName), iRetVal);
            // now we know the individual name and type of the changed value
            Write (strTagName:40, '  changed to  ');
            case uiTypeCode of
              PDLM_TAGTYPE_BOOL                     : WriteLn (BoolToStr (LongBool(TagValueList[iListIdx].ttvValue.uiValue), true):10);
              //
              PDLM_TAGTYPE_UINT                     : WriteLn (     TagValueList[iListIdx].ttvValue.uiValue:10);
              PDLM_TAGTYPE_UINT_DAC                 : WriteLn (('0x'+IntToHex (TagValueList[iListIdx].ttvValue.uiValue, 4)):10); // for any direct given raw DAC value
              PDLM_TAGTYPE_UINT_ENUM                : WriteLn (     TagValueList[iListIdx].ttvValue.uiValue:10,   ' (enum)');    // for list-driven values
              //
              PDLM_TAGTYPE_UINT_IN_TENTH            : WriteLn (1e-1*TagValueList[iListIdx].ttvValue.uiValue:12:1, ' °C');        // for temperatures in tenth of a celsius degree
              PDLM_TAGTYPE_UINT_IN_PERCENT          : WriteLn (     TagValueList[iListIdx].ttvValue.uiValue:10,   ' %');         // for interpolation tables
              PDLM_TAGTYPE_UINT_IN_PERMILLE         : WriteLn (1e-1*TagValueList[iListIdx].ttvValue.uiValue:12:1, ' %');         // for permille values in power or current interpolation tables
              PDLM_TAGTYPE_UINT_IN_PERTHOUSAND      : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.uiValue:14:3);               // for (positive only) milli Volts, milli Watts, etc.
              PDLM_TAGTYPE_UINT_IN_PERMYRIAD        : WriteLn (1e-4*TagValueList[iListIdx].ttvValue.uiValue:15:4);               // for current interpolation tables (a hundreth of a percent)
              PDLM_TAGTYPE_UINT_IN_PERMILLION       : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.uiValue:14:3, ' mW');        // for power values in 10^(-6) Watt = uW
              PDLM_TAGTYPE_UINT_IN_PERBILLION       : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.uiValue:14:3, ' µW');        // for power values in 10^(-9) Watt = nW
              PDLM_TAGTYPE_UINT_IN_PERTRILLION      : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.uiValue:14:3, ' nm');        // for wavelength values in 10^(-12) Meter  = pm
              PDLM_TAGTYPE_UINT_IN_PERQUADRILLION   : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.uiValue:14:3, ' pJ');        // for pulse energy values in 10^(-15) Joule = fJ
              //
              PDLM_TAGTYPE_INT                      : WriteLn (     TagValueList[iListIdx].ttvValue.iValue:10);
              PDLM_TAGTYPE_INT_IN_PERTHOUSAND       : WriteLn (1e-3*TagValueList[iListIdx].ttvValue.iValue:14:3,  ' V');         // for milli Volts (trigger level)
              //
              PDLM_TAGTYPE_SINGLE                   : WriteLn (     TagValueList[iListIdx].ttvValue.fValue:23:12);
              PDLM_TAGTYPE_VOID                     : WriteLn ('???':10);
            end;
          end;
        end;
      end;
    end;
  end;

  function Present_DetailedInfos (iUSBIdx : TUSBIdx; bAddChanges : boolean) : AnsiChar;
  var
    iRetVal    : integer;
    strHWInfo  : string;
    strFWVers  : string;
    DevData    : T_DeviceData;
    LHData     : T_LHData;
    LHInfo     : T_LHInfo;
    uiFeatures : Cardinal;
    iListIdx   : integer;
    strValue   : string;
  begin
    bChanges := bAddChanges;
    CheckReturnValue ('PDLM_GetHardwareInfo', PDLM_GetHardwareInfo (iUSBIdx, strHWInfo), iRetVal);
    CheckReturnValue ('PDLM_GetFWVersion',    PDLM_GetFWVersion    (iUSBIdx, strFWVers), iRetVal);
    CheckReturnValue ('PDLM_GetDeviceData',   PDLM_GetDeviceData   (iUSBIdx, DevData),   iRetVal);
    //
    WriteLn ('  Device:');
    WriteLn ('  HW-Info            : ', strHWInfo);
    WriteLn ('  Serial No.         : ', DevData.SerNo);
    Write   ('  Device-Version     : ', DevData.VersDev.V.Major, '.', DevData.VersDev.V.Minor);
    strValue := string (AnsiString (DevData.VersDev.Notes));
    if Length (trim (strValue)) > 0 then
      WriteLn (';  ', trim (strValue))
    else
      WriteLn;
    WriteLn ('  FW-Version         : ', strFWVers);
    WriteLn ('  PCB-Version        : ', DevData.VersPCB);
    //
    if not dsState.LaserNotOperational
    then begin
      CheckReturnValue ('PDLM_GetLHVersion',     PDLM_GetLHVersion     (iUSBIdx, strValue),    iRetVal);
      CheckReturnValue ('PDLM_GetLHData',        PDLM_GetLHData        (iUSBIdx, LHData),      iRetVal);
      CheckReturnValue ('PDLM_GetLHInfo',        PDLM_GetLHInfo        (iUSBIdx, LHInfo),      iRetVal);
      CheckReturnValue ('PDLM_GetLHFeatures',    PDLM_GetLHFeatures    (iUSBIdx, uiFeatures),  iRetVal);
      CheckReturnValue ('PDLM_DecodeLHFeatures', PDLM_DecodeLHFeatures (uiFeatures, strValue), iRetVal);
      //
      strlList.Clear;
      strlList.StrictDelimiter := true;
      strlList.Delimiter := ';';
      strlList.DelimitedText := trim (strValue);
      //
      WriteLn;
      WriteLn ('  Laser Head:');
      WriteLn ('  Type               : ', LHInfo.LType, ',  Laser-Class : ', LHInfo.LClass);
      WriteLn ('  Serial No.         : ', LHData.SerNo);
      WriteLn ('  LH-Version         : ', LHData.VersLH.Major,'.', LHData.VersLH.Minor);
      WriteLn ('  Nominal Wavelength :', 0.1*LHData.WavelengthNominal:6:1, ' nm');
      WriteLn ('  Frequency Range    : ',
                  FormatFloatFixedDecimalsWithUnit (1.0*LHData.FreqMin, 0, 'Hz', 1, true),
               ' <=  f  <= ',
                  FormatFloatFixedDecimalsWithUnit (1.0*LHData.FreqMax, 0, 'Hz', 1, true));
      WriteLn ('  LH-Features        : 0x', IntToHex (Int64 (uiFeatures), 8), ',  i. e.:');
      if (strlList.Count > 0)
      then begin
        for iListIdx:=0 to (strlList.Count-1)
        do begin
          WriteLn ('                       - ', trim (strlList.Strings[iListIdx]));
        end;
      end;
      //
    end
    else begin
      WriteLn ('  Laser head not operational!')
    end;
    //
    WriteLn;
    result :=  PromptSet ('  Do you want to read additional support infos on this device?', '  Enter ' + CharSetToStr(PROMPT_YES_NO_SET_X) + ' ', PROMPT_YES_NO_SET_X);
    if (result = CHAR_PROG_EXIT) then
      Exit;
    //
    if (result = CHAR_YES)
    then begin
      CheckReturnValue ('PDLM_CreateSupportRequestText', PDLM_CreateSupportRequestText (iUSBIdx, 'Support-Request-Text:' + STR_LINEBREAK + STR_LINEBREAK, 'PDL-M1 "Taiko" Demo', 0, strValue), iRetVal);
      WriteLn;
      WriteLn (strValue);
    end;
    //
  end;

  function Change_DeviceUIMode (iUSBIdx : TUSBIdx; var bExclusive : boolean) : AnsiChar;
  var
    iRetVal : integer;
  begin
    //
    // claim for host SW exclusive UI?
    //
    CheckReturnValue ('PDLM_GetExclusiveUI', PDLM_GetExclusiveUI(iUSBIdx, bExclusive), iRetVal);
    result := PromptSet  ('  Currently, device is in ' + ifthen (bExclusive, 'host SW exclusive', 'cooperative') + ' UI mode' + STR_LINEBREAK +
                          '    ' + CHAR_EXCLUSIVE_UI   + ' : host SW exclusive UI mode,' + STR_LINEBREAK +
                          '    ' + CHAR_COOPERATIVE_UI + ' : cooperative UI mode',
                          '  Set a new UI mode (' + CHAR_PHASE_EXIT + ' for no change) ' + CharSetToStr (PROMPT_UIMODE_SET_EX) + ' ', PROMPT_UIMODE_SET_EX);
    if (result = CHAR_PROG_EXIT) then
      Exit;
    //
    if not (result in PROMPT_PHASE_EXIT)
    then begin
      case result of
        CHAR_EXCLUSIVE_UI   : CheckReturnValue ('PDLM_SetExclusiveUI', PDLM_SetExclusiveUI(iUSBIdx, true),  iRetVal);
        CHAR_COOPERATIVE_UI : CheckReturnValue ('PDLM_SetExclusiveUI', PDLM_SetExclusiveUI(iUSBIdx, false), iRetVal);
      end;
      //
      Sleep (1); // wait, 'till the changes are done!
      CheckReturnValue ('PDLM_GetExclusiveUI', PDLM_GetExclusiveUI(iUSBIdx, bExclusive), iRetVal);
    end;
    CheckReturnValue ('PDLM_GetExclusiveUI', PDLM_GetExclusiveUI(iUSBIdx, bExclusive), iRetVal);
    WriteLn ('  Now, device UI is in ' + ifthen (bExclusive, 'exclusive', 'cooperative') + ' mode');
    WriteLn;
  end;

  function Change_Locking (iUSBIdx : TUSBIdx; var bSoftLocked : boolean) : AnsiChar;
  var
    iRetVal  : integer;
    bLocked  : boolean;
  begin
    CheckReturnValue ('PDLM_GetLocked', PDLM_GetLocked (iUSBIdx, bLocked), iRetVal);
    CheckReturnValue ('PDLM_GetSoftLock', PDLM_GetSoftLock (iUSBIdx, bSoftLocked), iRetVal);
    //
    repeat
      Result :=  PromptSet ('  Currently, the device is ' + ifthen (not bLocked, 'un', '') + 'locked; Soft-lock state is' + ifthen (bSoftLocked, ' ', ' not ') + 'set' + STR_LINEBREAK +
                            '    ' + CHAR_SOFT_LOCK   + ' : sets soft lock state to locked' + STR_LINEBREAK +
                            '    ' + CHAR_SOFT_UNLOCK + ' : sets soft lock state to unlocked',
                            '  Enter a key (' + CHAR_PHASE_EXIT + ' for no change) ' + CharSetToStr (PROMPT_SOFTLOCK_SET_EX) + ' ', PROMPT_SOFTLOCK_SET_EX);
      if (Result = CHAR_PROG_EXIT) then
        Exit;
      //
      if not (Result in PROMPT_PHASE_EXIT)
      then begin
        CheckReturnValue ('PDLM_SetSoftLock', PDLM_SetSoftLock (iUSBIdx, (Result = CHAR_SOFT_LOCK)), iRetVal);
        CheckReturnValue ('PDLM_GetLocked', PDLM_GetLocked (iUSBIdx, bLocked), iRetVal);
        CheckReturnValue ('PDLM_GetSoftLock', PDLM_GetSoftLock (iUSBIdx, bSoftLocked), iRetVal);
        WriteLn ('  Now, the device is ' + ifthen (not bLocked, 'un', '') + 'locked; Soft-lock state is' + ifthen (bSoftLocked, ' ', ' not ') + 'set');
        WriteLn;
      end;
      //
    until (Result in PROMPT_PHASE_EXIT);
  end;

  function Change_EmissionMode (iUSBIdx : TUSBIdx; var lmMode : T_LaserMode) : AnsiChar;
  var
    iRetVal  : integer;
    strValue : string;
  begin
    //
    // get / set emission mode  (i.e. laser mode)
    //
    CheckReturnValue ('PDLM_GetLaserMode', PDLM_GetLaserMode(iUSBIdx, lmMode), iRetVal);
    case lmMode of
      PDLM_LASERMODE_CW    : strValue := STR_LASERMODE_CW;
      PDLM_LASERMODE_PULSE : strValue := STR_LASERMODE_PULSE;
      PDLM_LASERMODE_BURST : strValue := STR_LASERMODE_BURST;
    end;
    result :=  PromptSet ('  Current emission mode is ' + strValue + STR_LINEBREAK +
                          '    ' + CHAR_CW_MODE    + ' : ' + STR_LASERMODE_CW      + STR_LINEBREAK +
                          '    ' + CHAR_PULSE_MODE + ' : ' + STR_LASERMODE_PULSE   + STR_LINEBREAK +
                          '    ' + CHAR_BURST_MODE + ' : ' + STR_LASERMODE_BURST,
                          '  Set a new emission mode (' + CHAR_PHASE_EXIT + ' for no change) ' + CharSetToStr (PROMPT_LASERMODE_SET_EX) + ' ', PROMPT_LASERMODE_SET_EX);
    if (result = CHAR_PROG_EXIT) then
      Exit;
    //
    if not (result in PROMPT_PHASE_EXIT)
    then begin
      case result of
        CHAR_CW_MODE    : CheckReturnValue ('PDLM_SetLaserMode', PDLM_SetLaserMode(iUSBIdx, PDLM_LASERMODE_CW),    iRetVal);
        CHAR_PULSE_MODE : CheckReturnValue ('PDLM_SetLaserMode', PDLM_SetLaserMode(iUSBIdx, PDLM_LASERMODE_PULSE), iRetVal);
        CHAR_BURST_MODE : CheckReturnValue ('PDLM_SetLaserMode', PDLM_SetLaserMode(iUSBIdx, PDLM_LASERMODE_BURST), iRetVal);
      end;
    end;
    //
    Sleep (10); // wait, 'till the changes are done!
    //
    CheckReturnValue ('PDLM_GetLaserMode', PDLM_GetLaserMode(iUSBIdx, lmMode), iRetVal);
    case lmMode of
      PDLM_LASERMODE_CW    : strValue := STR_LASERMODE_CW;
      PDLM_LASERMODE_PULSE : strValue := STR_LASERMODE_PULSE;
      PDLM_LASERMODE_BURST : strValue := STR_LASERMODE_BURST;
    end;
    WriteLn ('  New emission mode is ' + strValue);
    WriteLn;
  end;

  function Change_CWPower (iUSBIdx : TUSBIdx) : AnsiChar;
  var
    iRetVal     : integer;
    bFirstTime  : boolean;
    fMinVal     : single;
    fMaxVal     : single;
    fCurVal     : single;
    uiCurVal    : cardinal;
    uiNxtVal    : cardinal;
  begin
    //
    // get / set optical CW power
    //
    CheckReturnValue ('PDLM_GetCwPowerLimits',   PDLM_GetCwPowerLimits(iUSBIdx, fMinVal, fMaxVal), iRetVal);
    CheckReturnValue ('PDLM_GetCwPower',         PDLM_GetCwPower(iUSBIdx, fCurVal), iRetVal);
    CheckReturnValue ('PDLM_GetCwPowerPermille', PDLM_GetCwPowerPermille(iUSBIdx, uiCurVal), iRetVal);
    //
    WriteLn ('  CW power-limits are: ', FormatFloatFixedMantissaWithUnit (fMinVal, 4, 'W', 0, true), ' ... ', FormatFloatFixedMantissaWithUnit (fMaxVal, 4, 'W', 0, true));
    WriteLn ('  Current CW power is: ', FormatFloatFixedMantissaWithUnit (fCurVal, 4, 'W', 0, true), ' <==>', (0.1*uiCurVal):6:1, '%');
    WriteLn;
    //
    bFirstTime := true;
    repeat
      result := PromptSet ('  Change the CW power value:' + ifthen (bFirstTime, STR_LINEBREAK +
                      '    ' + CHAR_INC_BY_TEN   + ' : by +10.0%' + STR_LINEBREAK +
                      '    ' + CHAR_INC_BY_ONE   + ' : by  +1.0%' + STR_LINEBREAK +
                      '    ' + CHAR_INC_BY_TENTH + ' : by  +0.1%' + STR_LINEBREAK +
                      '    ' + CHAR_DEC_BY_TENTH + ' : by  -0.1%' + STR_LINEBREAK +
                      '    ' + CHAR_DEC_BY_ONE   + ' : by  -1.0%' + STR_LINEBREAK +
                      '    ' + CHAR_DEC_BY_TEN   + ' : by -10.0%', ''),
                      '  Enter change code ' + CharSetToStr (PROMPT_POWERCHANGE_SET_EX) + ' ', PROMPT_POWERCHANGE_SET_EX);
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      bFirstTime := false;
      uiNxtVal   := uiCurVal;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        case result of
          CHAR_INC_BY_TEN   : uiNxtVal := cardinal (EnsureRange (+100 + integer(uiCurVal), 0, 1000));
          CHAR_INC_BY_ONE   : uiNxtVal := cardinal (EnsureRange (+ 10 + integer(uiCurVal), 0, 1000));
          CHAR_INC_BY_TENTH : uiNxtVal := cardinal (EnsureRange (+  1 + integer(uiCurVal), 0, 1000));
          CHAR_DEC_BY_TENTH : uiNxtVal := cardinal (EnsureRange (-  1 + integer(uiCurVal), 0, 1000));
          CHAR_DEC_BY_ONE   : uiNxtVal := cardinal (EnsureRange (- 10 + integer(uiCurVal), 0, 1000));
          CHAR_DEC_BY_TEN   : uiNxtVal := cardinal (EnsureRange (-100 + integer(uiCurVal), 0, 1000));
        end;
        CheckReturnValue ('PDLM_SetCwPowerPermille', PDLM_SetCwPowerPermille(iUSBIdx, uiNxtVal), iRetVal);
        Sleep (10); // wait, 'till the changes are done!
        CheckReturnValue ('PDLM_GetCwPower',         PDLM_GetCwPower(iUSBIdx, fCurVal), iRetVal);
        CheckReturnValue ('PDLM_GetCwPowerPermille', PDLM_GetCwPowerPermille(iUSBIdx, uiCurVal), iRetVal);
        //
        WriteLn ('  Current CW power is: ', FormatFloatFixedMantissaWithUnit (fCurVal, 4, 'W', 0, true), ' <==>', (0.1*uiCurVal):6:1, '%');
        WriteLn;
      end;
    until (result in PROMPT_PHASE_EXIT);
  end;

  function Change_PulsePower (iUSBIdx : TUSBIdx) : AnsiChar;
  var
    iRetVal     : integer;
    bFirstTime  : boolean;
    uiFeatures  : Cardinal;
    LHFeatures  : T_LHFeatures;
    bHasMaxPwr  : boolean;
    uiTblIdx    : cardinal;
    uiDesIdx    : cardinal;
    fMinVal     : single;
    fMaxVal     : single;
    fCurVal     : single;
    uiCurVal    : cardinal;
    uiNxtVal    : cardinal;
    uiShape     : cardinal;
    strShape    : string;
    strCurMode  : string;
    strDesMode  : string;
    CurSet      : TACharSet;
  begin
    //
    // get / set optical pulse power
    //
    CheckReturnValue ('PDLM_GetLHFeatures', PDLM_GetLHFeatures(iUSBIdx, uiFeatures), iRetVal);
    LHFeatures.ui := uiFeatures;
    bHasMaxPwr := LHFeatures.HasPulseMaxPower;
    uiDesIdx := PDLM_LH_PULSE_LINPWR_TABLE_IDX;
    //
    CheckReturnValue ('PDLM_GetPulsePower',         PDLM_GetPulsePower(iUSBIdx, fCurVal), iRetVal);
    CheckReturnValue ('PDLM_GetPulsePowerPermille', PDLM_GetPulsePowerPermille(iUSBIdx, uiCurVal), iRetVal);
    CheckReturnValue ('PDLM_GetPulseShape',         PDLM_GetPulseShape(iUSBIdx, uiShape), iRetVal);
    CheckReturnValue ('PDLM_DecodePulseShape',      PDLM_DecodePulseShape(uiShape, strShape), iRetVal);
    //
    bFirstTime := true;
    repeat
      //
      if bFirstTime
      then begin
        if bHasMaxPwr then
        begin
          CheckReturnValue ('PDLM_GetPulsePowerLimits',   PDLM_GetPulsePowerLimits(iUSBIdx, fMinVal, fMaxVal), iRetVal);
          CheckReturnValue ('PDLM_GetLDHPulsePowerTable', PDLM_GetLDHPulsePowerTable(iUSBIdx, uiTblIdx), iRetVal);
          strCurMode := ifthen(uiTblIdx = PDLM_LH_PULSE_LINPWR_TABLE_IDX, 'linear', 'max. power');
          strDesMode := ifthen(uiTblIdx = PDLM_LH_PULSE_MAXPWR_TABLE_IDX, 'linear', 'max. power');
          uiDesIdx   := ifthen(uiTblIdx = PDLM_LH_PULSE_MAXPWR_TABLE_IDX, PDLM_LH_PULSE_LINPWR_TABLE_IDX, PDLM_LH_PULSE_MAXPWR_TABLE_IDX);
          CurSet     := PROMPT_POWER_MODECHANGE_SET_EX;
        end
        else begin
          strCurMode := '';
          strDesMode := '';
          uiDesIdx   := PDLM_LH_PULSE_LINPWR_TABLE_IDX;
          CurSet     := PROMPT_POWERCHANGE_SET_EX;
        end;
        //
        WriteLn ('  Pulse power-limits are: ', FormatFloatFixedMantissaWithUnit (fMinVal, 4, 'W', 0, true), ' ... ', FormatFloatFixedMantissaWithUnit (fMaxVal, 4, 'W', 0, true), ifthen (bHasMaxPwr, ' (' + strCurMode + ' mode)', ' ') );
        WriteLn ('  Current pulse power is: ', FormatFloatFixedMantissaWithUnit (fCurVal, 4, 'W', 0, true), ' <==>', (0.1*uiCurVal):6:1, '%  (', strShape, ')');
        WriteLn;
      end;
      //
      result :=  PromptSet ('  Change the pulse power value:' + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TEN   + ' : by +10.0%' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_ONE   + ' : by  +1.0%' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TENTH + ' : by  +0.1%' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TENTH + ' : by  -0.1%' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_ONE   + ' : by  -1.0%' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TEN   + ' : by -10.0%' + ifthen (bHasMaxPwr,  STR_LINEBREAK +
                              '  or' + STR_LINEBREAK +
                              '    ' + CHAR_SWITCH_PULSEPOWERMODE + ' : switch pulse power mode to ' + strDesMode + ' mode' + STR_LINEBREAK, STR_LINEBREAK), ''),
                            '  Enter change code ' + CharSetToStr (CurSet) + ' ', CurSet);
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      bFirstTime := (result = CHAR_SWITCH_PULSEPOWERMODE);
      uiNxtVal   := uiCurVal;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        if (result = CHAR_SWITCH_PULSEPOWERMODE)
        then begin
          CheckReturnValue ('PDLM_SetLDHPulsePowerTable', PDLM_SetLDHPulsePowerTable(iUSBIdx, uiDesIdx), iRetVal);
          Sleep (10); // wait, 'till the changes are done!
        end
        else begin
          case result of
            CHAR_INC_BY_TEN   : uiNxtVal := cardinal (EnsureRange (+100 + integer(uiCurVal), 0, 1000));
            CHAR_INC_BY_ONE   : uiNxtVal := cardinal (EnsureRange (+ 10 + integer(uiCurVal), 0, 1000));
            CHAR_INC_BY_TENTH : uiNxtVal := cardinal (EnsureRange (+  1 + integer(uiCurVal), 0, 1000));
            CHAR_DEC_BY_TENTH : uiNxtVal := cardinal (EnsureRange (-  1 + integer(uiCurVal), 0, 1000));
            CHAR_DEC_BY_ONE   : uiNxtVal := cardinal (EnsureRange (- 10 + integer(uiCurVal), 0, 1000));
            CHAR_DEC_BY_TEN   : uiNxtVal := cardinal (EnsureRange (-100 + integer(uiCurVal), 0, 1000));
          end;
          CheckReturnValue ('PDLM_SetPulsePowerPermille', PDLM_SetPulsePowerPermille(iUSBIdx, uiNxtVal), iRetVal);
          Sleep (10); // wait, 'till the changes are done!
        end;
        CheckReturnValue ('PDLM_GetPulsePower',         PDLM_GetPulsePower(iUSBIdx, fCurVal), iRetVal);
        CheckReturnValue ('PDLM_GetPulsePowerPermille', PDLM_GetPulsePowerPermille(iUSBIdx, uiCurVal), iRetVal);
        CheckReturnValue ('PDLM_GetPulseShape',         PDLM_GetPulseShape(iUSBIdx, uiShape), iRetVal);
        CheckReturnValue ('PDLM_DecodePulseShape',      PDLM_DecodePulseShape(uiShape, strShape), iRetVal);
        //
        WriteLn ('  Current pulse power is: ', FormatFloatFixedMantissaWithUnit (fCurVal, 4, 'W', 0, true), ' <==>', (0.1*uiCurVal):6:1, '%  (', strShape, ')');
        WriteLn;
      end;
    until (result in PROMPT_PHASE_EXIT);
    //
  end;


  function Change_LHTemperature (iUSBIdx : TUSBIdx; var uiScale : T_TempScale) : AnsiChar;
  var
    iRetVal     : integer;
    bFirstTime  : boolean;
    fMinVal     : single;
    fMaxVal     : single;
    fCurVal     : single;
    fNxtVal     : single;
    uiTemp      : cardinal;
    //
  begin
    //
    // get / set laser head temperature
    //
    CheckReturnValue ('PDLM_GetTempScale',          PDLM_GetTempScale(iUSBIdx, uiTemp), iRetVal);
    uiScale := T_TempScale (uiTemp);
    //
    CheckReturnValue ('PDLM_GetLHTargetTempLimits', PDLM_GetLHTargetTempLimits(iUSBIdx, ord (uiScale), fMinVal, fMaxVal), iRetVal);
    CheckReturnValue ('PDLM_GetLHTargetTemp',       PDLM_GetLHTargetTemp(iUSBIdx, ord (uiScale), fCurVal), iRetVal);
    //
    bFirstTime := true;
    //
    repeat
      WriteLn;
      if bFirstTime
      then begin
        WriteLn ('  laser diode temperature-limits are: ', FormatFloatFixedDecimalsWithUnit (fMinVal, 1, SCALE_UNITS [uiScale], 0, true), ' ... ', FormatFloatFixedDecimalsWithUnit (fMaxVal, 1, SCALE_UNITS [uiScale], 0, true));
        WriteLn ('  Current laser diode temperature is: ', FormatFloatFixedDecimalsWithUnit (fCurVal, 1, SCALE_UNITS [uiScale], 0, true));
        WriteLn;
      end;
      //
      result :=  PromptSet ('  Change the temperature scale'  + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_SCALE_CELSIUS    + ' : to Celsius degrees    (°C)' + STR_LINEBREAK +
                            '    ' + CHAR_SCALE_FAHRENHEIT + ' : to Fahrenheit degrees (°F)' + STR_LINEBREAK +
                            '    ' + CHAR_SCALE_KELVIN     + ' : to Kelvin units       ( K)' + STR_LINEBREAK , STR_LINEBREAK) +
                            '  or change the laser diode target temperature value:' + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TEN       + ' : by +10.0' + SCALE_UNITS [uiScale] + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_ONE       + ' : by  +1.0' + SCALE_UNITS [uiScale] + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TENTH     + ' : by  +0.1' + SCALE_UNITS [uiScale] + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TENTH     + ' : by  -0.1' + SCALE_UNITS [uiScale] + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_ONE       + ' : by  -1.0' + SCALE_UNITS [uiScale] + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TEN       + ' : by -10.0' + SCALE_UNITS [uiScale], ''),
                            '  Enter change code ' + CharSetToStr (PROMPT_TARGETTEMP_CHANGE_SET_EX) + ' ', PROMPT_TARGETTEMP_CHANGE_SET_EX);
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      bFirstTime := false;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        case result of
          CHAR_INC_BY_TEN       : begin
                                    fNxtVal := EnsureRange (+10.0 + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_INC_BY_ONE       : begin
                                    fNxtVal := EnsureRange (+ 1.0 + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_INC_BY_TENTH     : begin
                                    fNxtVal := EnsureRange (+ 0.1*SCALE_STEP[uiScale] + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_DEC_BY_TENTH     : begin
                                    fNxtVal := EnsureRange (- 0.1*SCALE_STEP[uiScale] + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_DEC_BY_ONE       : begin
                                    fNxtVal := EnsureRange (- 1.0 + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_DEC_BY_TEN       : begin
                                    fNxtVal := EnsureRange (-10.0 + fCurVal, fMinVal, fMaxVal);
                                    CheckReturnValue ('PDLM_SetLHTargetTemp', PDLM_SetLHTargetTemp (iUSBIdx, ord (uiScale), fNxtVal), iRetVal);
                                  end;
          CHAR_SCALE_CELSIUS    : begin
                                    bFirstTime := true;
                                    uiScale    := PDLM_TEMPSCALE_CELSIUS;
                                    CheckReturnValue ('PDLM_SetTempScale',          PDLM_SetTempScale(iUSBIdx, ord (uiScale)), iRetVal);
                                    CheckReturnValue ('PDLM_GetLHTargetTempLimits', PDLM_GetLHTargetTempLimits(iUSBIdx, ord (uiScale), fMinVal, fMaxVal), iRetVal);
                                  end;
          CHAR_SCALE_FAHRENHEIT : begin
                                    bFirstTime := true;
                                    uiScale    := PDLM_TEMPSCALE_FAHRENHEIT;
                                    CheckReturnValue ('PDLM_SetTempScale',          PDLM_SetTempScale(iUSBIdx, ord (uiScale)), iRetVal);
                                    CheckReturnValue ('PDLM_GetLHTargetTempLimits', PDLM_GetLHTargetTempLimits(iUSBIdx, ord (uiScale), fMinVal, fMaxVal), iRetVal);
                                  end;
          CHAR_SCALE_KELVIN     : begin
                                    bFirstTime := true;
                                    uiScale    := PDLM_TEMPSCALE_KELVIN;
                                    CheckReturnValue ('PDLM_SetTempScale',          PDLM_SetTempScale(iUSBIdx, ord (uiScale)), iRetVal);
                                    CheckReturnValue ('PDLM_GetLHTargetTempLimits', PDLM_GetLHTargetTempLimits(iUSBIdx, ord (uiScale), fMinVal, fMaxVal), iRetVal);
                                  end;
        end;
        Sleep (10); // wait, 'till the changes are done!
        CheckReturnValue ('PDLM_GetLHTargetTemp', PDLM_GetLHTargetTemp(iUSBIdx, ord (uiScale), fCurVal), iRetVal);
        //
        WriteLn ('  Currently, the laser diode target temperature is set to: ', FormatFloatFixedDecimalsWithUnit (fCurVal, 1, SCALE_UNITS [uiScale], 0, true));
        WriteLn;
      end;
      //
    until (result in PROMPT_PHASE_EXIT);
    //
  end;


  function Change_BurstData (iUSBIdx : TUSBIdx) : AnsiChar;
  var
    iRetVal       : integer;
    bFirstTime    : boolean;
    bChngBLength  : boolean;
    uiBLength     : cardinal;
    uiBPeriod     : cardinal;
    //
  begin
    //
    // get / set burst data, beginning with burst period
    //
    bChngBLength := false;
    //
    bFirstTime := true;
    //
    CheckReturnValue ('PDLM_GetBurst', PDLM_GetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
    //
    //
    repeat
      WriteLn;
      if bFirstTime
      then begin
        if bChngBLength
        then begin
          WriteLn ('  burst length limits are: 2 ... ', uiBPeriod - 1);
        end
        else begin
          WriteLn ('  burst period limits are: ', uiBLength + 1, ' ... 16777215');
        end;
        WriteLn ('  Current burst ',  ifthen (bChngBLength, 'length', 'period'), ' is: ', ifthen (bChngBLength, uiBLength, uiBPeriod));
        WriteLn;
      end;
      //
      result :=  PromptSet ('  Switch the burst parameter to change:'  + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_SWITCH_BPARAM    + ' : to burst ' + ifthen (bChngBLength, 'period', 'length') + STR_LINEBREAK, STR_LINEBREAK) +
                            '  or change the burst ' + ifthen (bChngBLength, 'length', 'period') + ' value:' + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_THOUSAND  + ' : by +1000' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_HUNDRED   + ' : by  +100' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TEN       + ' : by   +10' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_ONE       + ' : by    +1' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_ONE       + ' : by    -1' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TEN       + ' : by   -10' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_HUNDRED   + ' : by  -100' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_THOUSAND  + ' : by -1000', ''),
                            '  Enter change code ' + CharSetToStr (PROMPT_BURSTDATA_CHANGE_SET_EX) + ' ', PROMPT_BURSTDATA_CHANGE_SET_EX);
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      bFirstTime := false;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        case result of
          CHAR_SWITCH_BPARAM    : begin
                                    bFirstTime   := true;
                                    bChngBLength := not bChngBLength;
                                  end;
          CHAR_INC_BY_THOUSAND  : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (+1000 + uiBLength, 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (+1000 + uiBPeriod, uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_INC_BY_HUNDRED   : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (+100 + uiBLength, 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (+100 + uiBPeriod, uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_INC_BY_TEN       : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (+10 + uiBLength, 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (+10 + uiBPeriod, uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_INC_BY_ONE       : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (+1 + uiBLength, 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (+1 + uiBPeriod, uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_DEC_BY_ONE       : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (-1 + integer(uiBLength), 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (-1 + integer(uiBPeriod), uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_DEC_BY_TEN       : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (-10 + integer(uiBLength), 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (-10 + integer(uiBPeriod), uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_DEC_BY_HUNDRED   : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (-100 + integer(uiBLength), 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (-100 + integer(uiBPeriod), uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
          CHAR_DEC_BY_THOUSAND  : begin
                                    if bChngBLength then
                                      uiBLength := EnsureRange (-1000 + integer(uiBLength), 2, uiBPeriod - 1)
                                    else
                                      uiBPeriod := EnsureRange (-1000 + integer(uiBPeriod), uiBLength + 1, 16777215);
                                    CheckReturnValue ('PDLM_SetBurst', PDLM_SetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
                                  end;
        end;
        Sleep (10); // wait, 'till the changes are done!
        //
        CheckReturnValue ('PDLM_GetBurst', PDLM_GetBurst(iUSBIdx, uiBLength, uiBPeriod), iRetVal);
        //
        WriteLn ('  Currently, the burst ',  ifthen (bChngBLength, 'length', 'period'), ' is set to: ', ifthen (bChngBLength, uiBLength, uiBPeriod));
        WriteLn;
      end;
      //
    until (result in PROMPT_PHASE_EXIT);
    //
  end;


  function Change_Frequency  (iUSBIdx : TUSBIdx) : AnsiChar;
  var
    iRetVal             : integer;
    uiMantissa          : cardinal;
    uiMantissaIdx       : cardinal;
    uiExponentIdx       : cardinal;
    bMember_1_2_5       : boolean;
    uiMinFreq           : cardinal;
    uiMaxFreq           : cardinal;
    uiFrequency         : cardinal;
    CurPrompt           : TACharSet;
  const
    MANTISSAE_1_2_5     : array [0..8] of cardinal = (1, 2, 5, 10, 20, 50, 100, 200, 500);

    function HasMantissa_1_2_5 (uiInput : cardinal; var uiMantIdx : cardinal): boolean;
    var
      i : cardinal;
    begin
      result := false;
      for i:=8 downto 0
      do begin
        if uiInput >= MANTISSAE_1_2_5 [i]
        then begin
          result    := (uiInput = MANTISSAE_1_2_5 [i]);
          uiMantIdx := i;
          break;
        end;
      end;
    end;

    function GetExponent(uiExpIdx : cardinal): cardinal;
    begin
      case uiExpIdx of
        2: result := 1000000;
        1: result := 1000;
      else result := 1;
      end;
    end;

  begin
    //
    // get / set frequency
    //
    repeat
      //
      CheckReturnValue ('PDLM_GetLHFrequencyLimits', PDLM_GetLHFrequencyLimits (iUSBIdx, uiMinFreq, uiMaxFreq), iRetVal);
      CheckReturnValue ('PDLM_GetFrequency', PDLM_GetFrequency(iUSBIdx, uiFrequency), iRetVal);
      //
      if uiFrequency = 0
      then begin
        Writeln ('  Error detected: Frequency = 0!');
        result := '-';
        exit;
      end;
      //
      CurPrompt := PROMPT_FREQUENCY_BASE_SET_EX;
      //
      // legal prompt sets:
      //                                                   1-2-5-
      //                                                  sequence    ones    tens     Hz-prefix
      //         f         Mant      MantIdx  ExpIdx       s   S     o   O   t   T     M   k   1
      //
      //         1         1         0        0            -   x     -   -   -   -     x   x  (-)
      //    2..100    2..100      1..6        0            x   x     -   -   -   -     x   x  (-)
      //       200       200         7        0            x   x     -   -   -   -     -   x  (-)
      //       500       500         8        0            x   x!    -   -   -   -     -   x  (-)
      //         1k        1         0        1            x!  x     -   -   -   -     x  (-)  x
      //   2k..100k   2..100      1..6        1            x   x     -   -   -   -     x  (-)  x
      //       200k      200         7        1            x   x     -   -   -   -     -  (-)  x
      //       500k      500         8        1            x   x!    -   -   -   -     -  (-)  x
      //         1M        1         0        2            x!  x     -   x   -   x    (-)  x   x
      //         2M        2         1        2            x   x     x   x   -   x    (-)  x   x
      //   3M .. 4M     3..4         X        2            -   -     x   x   -   x     -   -   -
      //         5M        5         2        2            x   x     x   x   -   x    (-)  x   x
      //   6M .. 9M     6..9         X        2            -   -     x   x   -   x     -   -   -
      //        10M       10         3        2            x   x     x   x   -   x    (-)  x   x
      //  11M ..19M   11..19         X        2            -   -     x   x   x   x     -   -   -
      //        20M       20         4        2            x   x     x   x   x   x    (-)  x   x
      //  21M ..49M   21..49         X        2            -   -     x   x   x   x     -   -   -
      //        50M       50         5        2            x   x     x   x   x   x    (-)  x   x
      //  51M ..90M   51..90         X        2            -   -     x   x   x   x     -   -   -
      //  91M ..99M   91..99         X        2            -   -     x   x   x   -     -   -   -
      //       100M      100         6        2            x   -     x   -   x   -    (-)  x   x
      //
      uiMantissa    := uiFrequency;
      uiExponentIdx := 0;
      uiMantissaIdx := 0;
      //
      while uiMantissa > 999
      do begin
        uiMantissa := uiMantissa div 1000;
        inc (uiExponentIdx);
      end;
      //
      bMember_1_2_5 := HasMantissa_1_2_5 (uiMantissa, uiMantissaIdx);
      //
      if (not bMember_1_2_5) or (uiFrequency = 1)
      then begin
        Exclude (CurPrompt, CHAR_FREQ_DEC_SEQIDX);
      end;
      //
      if (not bMember_1_2_5) or (uiFrequency = 100000000)
      then begin
        Exclude (CurPrompt, CHAR_FREQ_INC_SEQIDX);
      end;
      //
      if (not bMember_1_2_5) or (uiExponentIdx > 1) or (uiMantissa > 100)
      then begin
        Exclude (CurPrompt, CHAR_FREQ_PREFIX_MEGA);
      end;
      //
      if (not bMember_1_2_5) or (uiExponentIdx = 1)
      then begin
        Exclude (CurPrompt, CHAR_FREQ_PREFIX_KILO);
      end;
      //
      if (not bMember_1_2_5) or (uiExponentIdx = 0)
      then begin
        Exclude (CurPrompt, CHAR_FREQ_PREFIX_NONE);
      end;
      //
      if (uiFrequency <= 10000000)
      then begin
        Exclude (CurPrompt, CHAR_DEC_BY_TEN);
        //
        if (uiFrequency <= 1000000)
        then begin
          Exclude (CurPrompt, CHAR_DEC_BY_ONE);
          //
          if (uiFrequency < 1000000)
          then begin
            Exclude (CurPrompt, CHAR_INC_BY_ONE);
            Exclude (CurPrompt, CHAR_INC_BY_TEN);
          end;
        end;
      end;
      //
      if (uiFrequency > 90000000)
      then begin
        Exclude (CurPrompt, CHAR_INC_BY_TEN);
        //
        if (uiFrequency = 100000000)
        then begin
          Exclude (CurPrompt, CHAR_INC_BY_ONE);
        end;
      end;
      //
      WriteLn ('  Frequency limits are: ', FormatFloatFixedDecimalsWithUnit (1.0*uiMinFreq,   0, 'Hz', 1, true), ' ... ', FormatFloatFixedDecimalsWithUnit (1.0*uiMaxFreq, 0, 'Hz', 1, true));
      WriteLn ('  Current frequency is: ', FormatFloatFixedDecimalsWithUnit (1.0*uiFrequency, 0, 'Hz', 1, true));
      WriteLn;

      //
      if bMember_1_2_5
      then begin
        result :=  PromptSet ('  Frequency is element of the 1-2-5 sequence:' + STR_LINEBREAK +
                              ifthen (CharInSet (CHAR_FREQ_DEC_SEQIDX, CurPrompt), '    ' + CHAR_FREQ_DEC_SEQIDX  + ' : change frequency to predecessor in sequence' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_FREQ_INC_SEQIDX, CurPrompt), '    ' + CHAR_FREQ_INC_SEQIDX  + ' : change frequency to successor in sequence' + STR_LINEBREAK, '') +
                              '  or change the prefix of the frequency unit:' + STR_LINEBREAK +
                              ifthen (CharInSet (CHAR_FREQ_PREFIX_MEGA, CurPrompt), '    ' + CHAR_FREQ_PREFIX_MEGA + ' : change unit to MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_FREQ_PREFIX_KILO, CurPrompt), '    ' + CHAR_FREQ_PREFIX_KILO + ' : change unit to kHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_FREQ_PREFIX_NONE, CurPrompt), '    ' + CHAR_FREQ_PREFIX_NONE + ' : change unit to  Hz' + STR_LINEBREAK, '') +
                              ifthen (uiExponentIdx > 1, '  or change the frequency value directly:' + STR_LINEBREAK +
                              ifthen (CharInSet (CHAR_INC_BY_TEN, CurPrompt), '    ' + CHAR_INC_BY_TEN       + ' : by   +10 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_INC_BY_ONE, CurPrompt), '    ' + CHAR_INC_BY_ONE       + ' : by    +1 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_DEC_BY_ONE, CurPrompt), '    ' + CHAR_DEC_BY_ONE       + ' : by    -1 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_DEC_BY_TEN, CurPrompt), '    ' + CHAR_DEC_BY_TEN       + ' : by   -10 MHz' + STR_LINEBREAK, ''), ''),
                              '  Enter change code ' + CharSetToStr (CurPrompt) + ' ', CurPrompt);
      end
      else begin
        result :=  PromptSet ('  Change the frequency value :' + STR_LINEBREAK +
                              ifthen (CharInSet (CHAR_INC_BY_TEN, CurPrompt), '    ' + CHAR_INC_BY_TEN       + ' : by   +10 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_INC_BY_ONE, CurPrompt), '    ' + CHAR_INC_BY_ONE       + ' : by    +1 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_DEC_BY_ONE, CurPrompt), '    ' + CHAR_DEC_BY_ONE       + ' : by    -1 MHz' + STR_LINEBREAK, '') +
                              ifthen (CharInSet (CHAR_DEC_BY_TEN, CurPrompt), '    ' + CHAR_DEC_BY_TEN       + ' : by   -10 MHz' + STR_LINEBREAK, ''),
                              '  Enter change code ' + CharSetToStr (CurPrompt) + ' ', CurPrompt);
      end;
      //
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        case result of
          CHAR_FREQ_DEC_SEQIDX  : begin
                                    if (uiMantissaIdx = Low (MANTISSAE_1_2_5))
                                    then begin
                                      dec (uiExponentIdx);
                                      uiMantissaIdx := High (MANTISSAE_1_2_5);
                                    end
                                    else begin
                                      dec (uiMantissaIdx);
                                    end;
                                    uiMantissa  := MANTISSAE_1_2_5 [uiMantissaIdx];
                                  end;
          CHAR_FREQ_INC_SEQIDX  : begin
                                    if (uiMantissaIdx = High (MANTISSAE_1_2_5))
                                    then begin
                                      inc (uiExponentIdx);
                                      uiMantissaIdx := Low (MANTISSAE_1_2_5);
                                    end
                                    else begin
                                      inc (uiMantissaIdx);
                                    end;
                                    uiMantissa  := MANTISSAE_1_2_5 [uiMantissaIdx];
                                  end;
          CHAR_FREQ_PREFIX_MEGA : uiExponentIdx := 2;
          CHAR_FREQ_PREFIX_KILO : uiExponentIdx := 1;
          CHAR_FREQ_PREFIX_NONE : uiExponentIdx := 0;
          CHAR_INC_BY_TEN       : inc (uiMantissa, 10);
          CHAR_INC_BY_ONE       : inc (uiMantissa);
          CHAR_DEC_BY_ONE       : dec (uiMantissa);
          CHAR_DEC_BY_TEN       : dec (uiMantissa, 10);
        end;
        //
        uiFrequency := EnsureRange (uiMantissa * GetExponent(uiExponentIdx), uiMinFreq, uiMaxFreq);
        CheckReturnValue ('PDLM_SetFrequency', PDLM_SetFrequency(iUSBIdx, uiFrequency), iRetVal);
        Sleep (10); // wait, 'till the changes are done!
        //
        CheckReturnValue ('PDLM_GetFrequency', PDLM_GetFrequency(iUSBIdx, uiFrequency), iRetVal);
        //
        WriteLn ('  Currently, frequency is set to: ', FormatFloatFixedDecimalsWithUnit (1.0*uiFrequency, 0, 'Hz', 1, true));
        WriteLn;
      end;
      //
    until (result in PROMPT_PHASE_EXIT);
    //
  end;


  function Change_TriggerMode (iUSBIdx : TUSBIdx) : AnsiChar;
  var
    iRetVal     : integer;
    bFirstTime  : boolean;
    bExternal   : boolean;
    fMinVal     : single;
    fMaxVal     : single;
    fCurVal     : single;
    fNxtVal     : single;
    tmMode      : T_TriggerSource;
    uiTemp      : cardinal;
    fExtTrgFreq : single;
    CurPrompt   : TACharSet;
    iCount      : integer;
  const
    MeasCount   = 3;
  begin
    //
    // get / set trigger mode and trigger level
    //
    bFirstTime := true;
    //
    repeat
      //
      CheckReturnValue ('PDLM_GetTriggerMode', PDLM_GetTriggerMode(iUSBIdx, tmMode), iRetVal);
      bExternal := (tmMode <> PDLM_TRIGGERSOURCE_INTERNAL);
      //
      if bExternal
      then begin
        CheckReturnValue ('PDLM_GetTriggerLevelLimits', PDLM_GetTriggerLevelLimits(iUSBIdx, fMinVal, fMaxVal), iRetVal);
        CheckReturnValue ('PDLM_GetTriggerLevel',       PDLM_GetTriggerLevel(iUSBIdx, fCurVal), iRetVal);
        CurPrompt := PROMPT_EXTTRIGGER_CHANGE_SET_EX;
      end
      else begin
        CurPrompt := PROMPT_INTTRIGGER_CHANGE_SET_EX;
      end;
      //
      WriteLn;
      if bFirstTime
      then begin
        Write ('  current trigger mode  is : ');
        case tmMode of
          PDLM_TRIGGERSOURCE_INTERNAL              : WriteLn ('"triggered internally"');
          PDLM_TRIGGERSOURCE_EXTERNAL_FALLING_EDGE : WriteLn ('"triggered on falling edge of an external signal"');
          PDLM_TRIGGERSOURCE_EXTERNAL_RISING_EDGE  : WriteLn ('"triggered on rising edge of an external signal"');
        end;
        if bExternal
        then begin
          WriteLn ('  trigger level limits are : ', fMinVal:6:3, ' V ...', fMaxVal:6:3, ' V');
          WriteLn ('  current trigger level is : ', fCurVal:6:3, ' V');
        end;
      end
      else begin
        if bExternal
        then begin
          WriteLn ('  new ext.trigger level is : ', fCurVal:6:3, ' V');
        end;
      end;
      if bExternal
      then begin
        fExtTrgFreq := 0;
        for iCount := 1 to MeasCount
        do begin
          CheckReturnValue ('PDLM_GetTriggerFrequency', PDLM_GetTriggerFrequency(iUSBIdx, uiTemp), iRetVal);
          fExtTrgFreq := fExtTrgFreq + uiTemp;
          if iCount < MeasCount then
            Sleep (120);
        end;
        fExtTrgFreq := fExtTrgFreq / MeasCount;
        WriteLn ('  ext.trigger frequency is : ', FormatFloatFixedMantissaWithUnit (fExtTrgFreq, 4, 'Hz', 1, true), ' (approx.)');
      end;
      WriteLn;
      //
      result :=  PromptSet ('  Change the trigger mode'  + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_TRIG_INTERNAL     + ' : to "triggered internally"' + STR_LINEBREAK +
                            '    ' + CHAR_TRIG_EXT_FALLING  + ' : to "triggered on falling edge of an external signal"' + STR_LINEBREAK +
                            '    ' + CHAR_TRIG_EXT_RISING   + ' : to "triggered on rising edge of an external signal"', '') + ifthen (bExternal, STR_LINEBREAK +
                            '  or change the trigger level value:' + ifthen (bFirstTime, STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_TENTH      + ' : by +0.100 V' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_HUNDREDTH  + ' : by +0.010 V' + STR_LINEBREAK +
                            '    ' + CHAR_INC_BY_THOUSANDTH + ' : by +0.001 V' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_THOUSANDTH + ' : by -0.001 V' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_HUNDREDTH  + ' : by -0.010 V' + STR_LINEBREAK +
                            '    ' + CHAR_DEC_BY_TENTH      + ' : by -0.100 V', ''), ''),
                            '  Enter change code ' + CharSetToStr (CurPrompt) + ' ', CurPrompt);
      if (result = CHAR_PROG_EXIT) then
        Exit;
      //
      bFirstTime := false;
      //
      if not (result in PROMPT_PHASE_EXIT)
      then begin
        case result of
          CHAR_INC_BY_TENTH       : begin
                                      fNxtVal := EnsureRange (+ 0.100 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_INC_BY_HUNDREDTH   : begin
                                      fNxtVal := EnsureRange (+ 0.010 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_INC_BY_THOUSANDTH  : begin
                                      fNxtVal := EnsureRange (+ 0.001 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_DEC_BY_THOUSANDTH  : begin
                                      fNxtVal := EnsureRange (- 0.001 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_DEC_BY_HUNDREDTH   : begin
                                      fNxtVal := EnsureRange (- 0.010 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_DEC_BY_TENTH       : begin
                                      fNxtVal := EnsureRange (- 0.100 + fCurVal, fMinVal, fMaxVal);
                                      CheckReturnValue ('PDLM_SetTriggerLevel', PDLM_SetTriggerLevel(iUSBIdx, fNxtVal), iRetVal);
                                    end;
          CHAR_TRIG_INTERNAL      : begin
                                      CheckReturnValue ('PDLM_SetTriggerMode',  PDLM_SetTriggerMode(iUSBIdx, PDLM_TRIGGERSOURCE_INTERNAL),              iRetVal);
                                      bFirstTime := true;
                                    end;
          CHAR_TRIG_EXT_FALLING   : begin
                                      CheckReturnValue ('PDLM_SetTriggerMode',  PDLM_SetTriggerMode(iUSBIdx, PDLM_TRIGGERSOURCE_EXTERNAL_FALLING_EDGE), iRetVal);
                                      bFirstTime := true;
                                    end;
          CHAR_TRIG_EXT_RISING    : begin
                                      CheckReturnValue ('PDLM_SetTriggerMode',  PDLM_SetTriggerMode(iUSBIdx, PDLM_TRIGGERSOURCE_EXTERNAL_RISING_EDGE),  iRetVal);
                                      bFirstTime := true;
                                    end;
        end;
      end;
      //
    until (result in PROMPT_PHASE_EXIT);
    //
  end;


var
  c           : AnsiChar;
  iRetVal     : integer;
  iUSBIdx     : TUSBIdx;
  iTempIdx    : TUSBIdx;
  strValue    : string;
  bExclusive  : boolean;
  bSoftLocked : boolean;
  lmMode      : T_LaserMode = PDLM_LASERMODE_UNASSIGNED;
  AllUSBIdx   : TUSBIdxSet  = [];
  AllUSBChar  : TACharSet   = [];
  uiScale     : T_TempScale;

begin
  bChanges    := false;
  try
    strlList  := TStringList.Create;
    try
      //
      writeln;
      writeln(' PDL-M1 "Taiko"    Demo Application    A. Podubrin, PicoQuant GmbH, 2018 ');
      writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      writeln;
      //
      CheckReturnValue ('PDLM_GetLibraryVersion', PDLM_GetLibraryVersion (strValue), iRetVal);
      WriteLn ('  Library Version : ' + strValue);
      //
      // List all available Taikos
      //
      WriteLn;
      WriteLn ('  List of all available Taikos:');
      for iTempIdx := 0 to (PDLM_MAX_USB_DEVICES-1)
      do begin
        strValue := '';
        CheckReturnValue ('PDLM_OpenGetSerNumAndClose', PDLM_OpenGetSerNumAndClose (iTempIdx, strValue), iRetVal, [PDLM_ERROR_NONE, -PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED, -PDLM_ERROR_USB_INAPPROPRIATE_DEVICE, -PDLM_ERROR_DEVICE_ALREADY_OPENED, -PDLM_ERROR_OPEN_DEVICE_FAILED, -PDLM_ERROR_USB_UNKNOWN_DEVICE]);
        case iRetVal of
          PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED   :   WriteLn ('    ', iTempIdx, '  ', strValue:8, '  busy');
          PDLM_ERROR_USB_INAPPROPRIATE_DEVICE :   WriteLn ('    ', iTempIdx, '  ', strValue:8, '  inappropriate');
          PDLM_ERROR_DEVICE_ALREADY_OPENED    :   WriteLn ('    ', iTempIdx, '  ', strValue:8, '  opened by another SW instance');
          PDLM_ERROR_OPEN_DEVICE_FAILED       : ;
          PDLM_ERROR_USB_UNKNOWN_DEVICE       : ;
          PDLM_ERROR_NONE                     : begin
                                                  WriteLn ('    ', iTempIdx, '  ', strValue:8, '  ready to connect');
                                                  Include (AllUSBIdx,  iTempIdx);
                                                  Include (AllUSBChar, AnsiChar (CHAR_ZERO_OFFSET + iTempIdx));
                                                end;
        else
          ;
        end;
      end;
      //
      WriteLn;
      c := PromptSet ('  Please enter an USB index or "x" to exit program', '  Valid entries are ' + USBIdxSetToStr(AllUSBIdx), AllUSBChar + PROMPT_PROG_EXIT);
      if (c = CHAR_PROG_EXIT) then
        Exit;
      //
      iUSBIdx := ord (c) - CHAR_ZERO_OFFSET;
      //
      WriteLn;
      WriteLn ('  Try to open USB device ' + IntToStr (iUSBIdx) + '...');
      CheckReturnValue ('PDLM_OpenDevice', PDLM_OpenDevice(iUSBIdx, strValue), iRetVal);
      try
        WriteLn ('  Opened device ', iUSBIdx, ' with serial number ', strValue);
        //
        repeat
          //
          // check frequently for system state and HW-errors:
          //
          Check_SystemState (iUSBIdx);
          CheckReturnValue ('PDLM_GetLaserMode', PDLM_GetLaserMode(iUSBIdx, lmMode), iRetVal);
          //
          //
          WriteLn;
          c := PromptSet ('  Main Menu' + STR_LINEBREAK +
                          '  =========' +  STR_LINEBREAK + STR_LINEBREAK +
                          '  Choose one of the following options:' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_INFO       + ' : detailed information, suppress infos on changes' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_INFO_LONG  + ' : detailed information, include infos on changes' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_UIMODE     + ' : device UI mode' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_LOCKING    + ' : locking' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_EMISSION   + ' : laser emission mode' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_TRIGGER    + ' : trigger mode' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_FREQ       + ' : frequency' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_POWER      + ' : optical power' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_BURST      + ' : burst data' + STR_LINEBREAK +
                          '    ' + CHAR_MAIN_TEMP       + ' : laser head temperature',
                          '  Enter ' + CharSetToStr(PROMPT_MAINMENU_SET_EX) + ' ', PROMPT_MAINMENU_SET_EX);
          if (c = CHAR_PROG_EXIT) then
            Exit;
          //
          WriteLn;
          //
          case c of
            CHAR_MAIN_INFO       : c := Present_DetailedInfos (iUSBIdx, false);
            CHAR_MAIN_INFO_LONG  : c := Present_DetailedInfos (iUSBIdx, true);
            CHAR_MAIN_UIMODE     : c := Change_DeviceUIMode (iUSBIdx, bExclusive);               // device UI mode
            CHAR_MAIN_LOCKING    : c := Change_Locking (iUSBIdx, bSoftLocked);                   // soft-lock mode
            CHAR_MAIN_EMISSION   : c := Change_EmissionMode (iUSBIdx, lmMode);                   // laser emission mode
            CHAR_MAIN_TRIGGER    : c := Change_TriggerMode (iUSBIdx);                            // trigger mode and trigger level
            CHAR_MAIN_FREQ       : c := Change_Frequency  (iUSBIdx);
            CHAR_MAIN_POWER      : begin                                                         // optical power ...
                                     if (lmMode = PDLM_LASERMODE_CW) then
                                       c := Change_CWPower (iUSBIdx)                             //   ... in CW mode
                                     else
                                       c := Change_PulsePower (iUSBIdx);                         //   ... in pulse mode
                                   end;
            CHAR_MAIN_BURST      : c := Change_BurstData (iUSBIdx);                              // burst data
            CHAR_MAIN_TEMP       : c := Change_LHTemperature (iUSBIdx, uiScale);                 // laser diode temperature
          end;
          //
          WriteLn;
          //
        until (c = CHAR_PROG_EXIT);
        //
        if bExclusive
        then begin
          CheckReturnValue ('PDLM_SetExclusiveUI', PDLM_SetExclusiveUI(iUSBIdx, false), iRetVal);
        end;
        //
      finally
        PDLM_CloseDevice(iUSBIdx);
      end;
    finally
      strlList.Free;
      WriteLn;
      PromptSet ('PDL-M1 "Taiko" - Demo terminated!', '  Hit any key to exit... ', PROMPT_ALL_KEYS_SET);
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
end.
