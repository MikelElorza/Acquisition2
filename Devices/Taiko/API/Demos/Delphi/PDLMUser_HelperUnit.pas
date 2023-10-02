unit PDLMUser_HelperUnit;
//
// Console routines by Rudolph Velthuis
// Format routines by PicoQuant (apo)
//
interface

uses
  System.Classes, System.SysUtils;

const
  PreFixChar:array[-8..8] of Char = ('y', 'z', 'a', 'f', 'p', 'n', 'µ', 'm', ' ',
     'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y');
  //
  function KeyPressed : Boolean;
  function ReadKey    : AnsiChar;
  //
  function GetCursorX: Integer; {$IFDEF INLINES}inline;{$ENDIF}
  function GetCursorY: Integer; {$IFDEF INLINES}inline;{$ENDIF}
  procedure SetCursorPos(X, Y: Smallint);
  //
  function FormatFloatFixedDecimalsWithUnit (const Data: Extended; const Decimals: cardinal; const BaseUnit:string; BlankLeadingUnit:integer=1; UsePrefixes:boolean=true):string;
  function FormatFloatFixedMantissaWithUnit (const Data: Extended; const MantissaLength: cardinal; const BaseUnit:string; BlankLeadingUnit:integer=1; UsePrefixes:boolean=true):string;
  //
  procedure UInt2MantPrfx (value : cardinal; var mant: cardinal; var prfx: cardinal);
  procedure Float2MantPrfx(value: single; var mant: single; var prfx: integer);

var
  FormatSettings_spec       : TFormatSettings;
  kTb_cbxList               : TStringList;

implementation

uses
  WinAPI.Windows,
  System.Math;

var
  ExtendedChar : AnsiChar = #0;
  StdIn        : THandle;
  StdOut       : THandle;

type
  PKey = ^TKey;
  TKey = record
    KeyCode: Smallint;
    Normal: Smallint;
    Shift: Smallint;
    Ctrl: Smallint;
    Alt: Smallint;
  end;

const
  CKeys: array[0..88] of TKey = (
    (KeyCode: VK_BACK;     Normal: $8;        Shift: $8;       Ctrl: $7F;  Alt: $10E; ),
    (KeyCode: VK_TAB;      Normal: $9;        Shift: $10F;     Ctrl: $194; Alt: $1A5; ),
    (KeyCode: VK_RETURN;   Normal: $D;        Shift: $D;       Ctrl: $A;   Alt: $1A6),
    (KeyCode: VK_ESCAPE;   Normal: $1B;       Shift: $1B;      Ctrl: $1B;  Alt: $101),
    (KeyCode: VK_SPACE;    Normal: $20;       Shift: $20;      Ctrl: $103; Alt: $20),
    (KeyCode: Ord('0');    Normal: Ord('0');  Shift: Ord(')'); Ctrl: - 1;  Alt: $181),
    (KeyCode: Ord('1');    Normal: Ord('1');  Shift: Ord('!'); Ctrl: - 1;  Alt: $178),
    (KeyCode: Ord('2');    Normal: Ord('2');  Shift: Ord('@'); Ctrl: $103; Alt: $179),
    (KeyCode: Ord('3');    Normal: Ord('3');  Shift: Ord('#'); Ctrl: - 1;  Alt: $17A),
    (KeyCode: Ord('4');    Normal: Ord('4');  Shift: Ord('$'); Ctrl: - 1;  Alt: $17B),
    (KeyCode: Ord('5');    Normal: Ord('5');  Shift: Ord('%'); Ctrl: - 1;  Alt: $17C),
    (KeyCode: Ord('6');    Normal: Ord('6');  Shift: Ord('^'); Ctrl: $1E;  Alt: $17D),
    (KeyCode: Ord('7');    Normal: Ord('7');  Shift: Ord('&'); Ctrl: - 1;  Alt: $17E),
    (KeyCode: Ord('8');    Normal: Ord('8');  Shift: Ord('*'); Ctrl: - 1;  Alt: $17F),
    (KeyCode: Ord('9');    Normal: Ord('9');  Shift: Ord('('); Ctrl: - 1;  Alt: $180),
    (KeyCode: Ord('A');    Normal: Ord('a');  Shift: Ord('A'); Ctrl: $1;   Alt: $11E),
    (KeyCode: Ord('B');    Normal: Ord('b');  Shift: Ord('B'); Ctrl: $2;   Alt: $130),
    (KeyCode: Ord('C');    Normal: Ord('c');  Shift: Ord('C'); Ctrl: $3;   Alt: $12E),
    (KeyCode: Ord('D');    Normal: Ord('d');  Shift: Ord('D'); Ctrl: $4;   Alt: $120),
    (KeyCode: Ord('E');    Normal: Ord('e');  Shift: Ord('E'); Ctrl: $5;   Alt: $112),
    (KeyCode: Ord('F');    Normal: Ord('f');  Shift: Ord('F'); Ctrl: $6;   Alt: $121),
    (KeyCode: Ord('G');    Normal: Ord('g');  Shift: Ord('G'); Ctrl: $7;   Alt: $122),
    (KeyCode: Ord('H');    Normal: Ord('h');  Shift: Ord('H'); Ctrl: $8;   Alt: $123),
    (KeyCode: Ord('I');    Normal: Ord('i');  Shift: Ord('I'); Ctrl: $9;   Alt: $117),
    (KeyCode: Ord('J');    Normal: Ord('j');  Shift: Ord('J'); Ctrl: $A;   Alt: $124),
    (KeyCode: Ord('K');    Normal: Ord('k');  Shift: Ord('K'); Ctrl: $B;   Alt: $125),
    (KeyCode: Ord('L');    Normal: Ord('l');  Shift: Ord('L'); Ctrl: $C;   Alt: $126),
    (KeyCode: Ord('M');    Normal: Ord('m');  Shift: Ord('M'); Ctrl: $D;   Alt: $132),
    (KeyCode: Ord('N');    Normal: Ord('n');  Shift: Ord('N'); Ctrl: $E;   Alt: $131),
    (KeyCode: Ord('O');    Normal: Ord('o');  Shift: Ord('O'); Ctrl: $F;   Alt: $118),
    (KeyCode: Ord('P');    Normal: Ord('p');  Shift: Ord('P'); Ctrl: $10;  Alt: $119),
    (KeyCode: Ord('Q');    Normal: Ord('q');  Shift: Ord('Q'); Ctrl: $11;  Alt: $110),
    (KeyCode: Ord('R');    Normal: Ord('r');  Shift: Ord('R'); Ctrl: $12;  Alt: $113),
    (KeyCode: Ord('S');    Normal: Ord('s');  Shift: Ord('S'); Ctrl: $13;  Alt: $11F),
    (KeyCode: Ord('T');    Normal: Ord('t');  Shift: Ord('T'); Ctrl: $14;  Alt: $114),
    (KeyCode: Ord('U');    Normal: Ord('u');  Shift: Ord('U'); Ctrl: $15;  Alt: $116),
    (KeyCode: Ord('V');    Normal: Ord('v');  Shift: Ord('V'); Ctrl: $16;  Alt: $12F),
    (KeyCode: Ord('W');    Normal: Ord('w');  Shift: Ord('W'); Ctrl: $17;  Alt: $111),
    (KeyCode: Ord('X');    Normal: Ord('x');  Shift: Ord('X'); Ctrl: $18;  Alt: $12D),
    (KeyCode: Ord('Y');    Normal: Ord('y');  Shift: Ord('Y'); Ctrl: $19;  Alt: $115),
    (KeyCode: Ord('Z');    Normal: Ord('z');  Shift: Ord('Z'); Ctrl: $1A;  Alt: $12C),
    (KeyCode: VK_PRIOR;    Normal: $149;      Shift: $149;     Ctrl: $184; Alt: $199),
    (KeyCode: VK_NEXT;     Normal: $151;      Shift: $151;     Ctrl: $176; Alt: $1A1),
    (KeyCode: VK_END;      Normal: $14F;      Shift: $14F;     Ctrl: $175; Alt: $19F),
    (KeyCode: VK_HOME;     Normal: $147;      Shift: $147;     Ctrl: $177; Alt: $197),
    (KeyCode: VK_LEFT;     Normal: $14B;      Shift: $14B;     Ctrl: $173; Alt: $19B),
    (KeyCode: VK_UP;       Normal: $148;      Shift: $148;     Ctrl: $18D; Alt: $198),
    (KeyCode: VK_RIGHT;    Normal: $14D;      Shift: $14D;     Ctrl: $174; Alt: $19D),
    (KeyCode: VK_DOWN;     Normal: $150;      Shift: $150;     Ctrl: $191; Alt: $1A0),
    (KeyCode: VK_INSERT;   Normal: $152;      Shift: $152;     Ctrl: $192; Alt: $1A2),
    (KeyCode: VK_DELETE;   Normal: $153;      Shift: $153;     Ctrl: $193; Alt: $1A3),
    (KeyCode: VK_NUMPAD0;  Normal: Ord('0');  Shift: $152;     Ctrl: $192; Alt: - 1),
    (KeyCode: VK_NUMPAD1;  Normal: Ord('1');  Shift: $14F;     Ctrl: $175; Alt: - 1),
    (KeyCode: VK_NUMPAD2;  Normal: Ord('2');  Shift: $150;     Ctrl: $191; Alt: - 1),
    (KeyCode: VK_NUMPAD3;  Normal: Ord('3');  Shift: $151;     Ctrl: $176; Alt: - 1),
    (KeyCode: VK_NUMPAD4;  Normal: Ord('4');  Shift: $14B;     Ctrl: $173; Alt: - 1),
    (KeyCode: VK_NUMPAD5;  Normal: Ord('5');  Shift: $14C;     Ctrl: $18F; Alt: - 1),
    (KeyCode: VK_NUMPAD6;  Normal: Ord('6');  Shift: $14D;     Ctrl: $174; Alt: - 1),
    (KeyCode: VK_NUMPAD7;  Normal: Ord('7');  Shift: $147;     Ctrl: $177; Alt: - 1),
    (KeyCode: VK_NUMPAD8;  Normal: Ord('8');  Shift: $148;     Ctrl: $18D; Alt: - 1),
    (KeyCode: VK_NUMPAD9;  Normal: Ord('9');  Shift: $149;     Ctrl: $184; Alt: - 1),
    (KeyCode: VK_MULTIPLY; Normal: Ord('*');  Shift: Ord('*'); Ctrl: $196; Alt: $137),
    (KeyCode: VK_ADD;      Normal: Ord('+');  Shift: Ord('+'); Ctrl: $190; Alt: $14E),
    (KeyCode: VK_SUBTRACT; Normal: Ord('-');  Shift: Ord('-'); Ctrl: $18E; Alt: $14A),
    (KeyCode: VK_DECIMAL;  Normal: Ord('.');  Shift: Ord('.'); Ctrl: $153; Alt: $193),
    (KeyCode: VK_DIVIDE;   Normal: Ord('/');  Shift: Ord('/'); Ctrl: $195; Alt: $1A4),
    (KeyCode: VK_F1;       Normal: $13B;      Shift: $154;     Ctrl: $15E; Alt: $168),
    (KeyCode: VK_F2;       Normal: $13C;      Shift: $155;     Ctrl: $15F; Alt: $169),
    (KeyCode: VK_F3;       Normal: $13D;      Shift: $156;     Ctrl: $160; Alt: $16A),
    (KeyCode: VK_F4;       Normal: $13E;      Shift: $157;     Ctrl: $161; Alt: $16B),
    (KeyCode: VK_F5;       Normal: $13F;      Shift: $158;     Ctrl: $162; Alt: $16C),
    (KeyCode: VK_F6;       Normal: $140;      Shift: $159;     Ctrl: $163; Alt: $16D),
    (KeyCode: VK_F7;       Normal: $141;      Shift: $15A;     Ctrl: $164; Alt: $16E),
    (KeyCode: VK_F8;       Normal: $142;      Shift: $15B;     Ctrl: $165; Alt: $16F),
    (KeyCode: VK_F9;       Normal: $143;      Shift: $15C;     Ctrl: $166; Alt: $170),
    (KeyCode: VK_F10;      Normal: $144;      Shift: $15D;     Ctrl: $167; Alt: $171),
    (KeyCode: VK_F11;      Normal: $185;      Shift: $187;     Ctrl: $189; Alt: $18B),
    (KeyCode: VK_F12;      Normal: $186;      Shift: $188;     Ctrl: $18A; Alt: $18C),
    (KeyCode: $DC;         Normal: Ord('\');  Shift: Ord('|'); Ctrl: $1C;  Alt: $12B),
    (KeyCode: $BF;         Normal: Ord('/');  Shift: Ord('?'); Ctrl: - 1;  Alt: $135),
    (KeyCode: $BD;         Normal: Ord('-');  Shift: Ord('_'); Ctrl: $1F;  Alt: $182),
    (KeyCode: $BB;         Normal: Ord('=');  Shift: Ord('+'); Ctrl: - 1;  Alt: $183),
    (KeyCode: $DB;         Normal: Ord('[');  Shift: Ord('{'); Ctrl: $1B;  Alt: $11A),
    (KeyCode: $DD;         Normal: Ord(']');  Shift: Ord('}'); Ctrl: $1D;  Alt: $11B),
    (KeyCode: $BA;         Normal: Ord(';');  Shift: Ord(':'); Ctrl: - 1;  Alt: $127),
    (KeyCode: $DE;         Normal: Ord(''''); Shift: Ord('"'); Ctrl: - 1;  Alt: $128),
    (KeyCode: $BC;         Normal: Ord(',');  Shift: Ord('<'); Ctrl: - 1;  Alt: $133),
    (KeyCode: $BE;         Normal: Ord('.');  Shift: Ord('>'); Ctrl: - 1;  Alt: $134),
    (KeyCode: $C0;         Normal: Ord('`');  Shift: Ord('~'); Ctrl: - 1;  Alt: $129)
  );


function FindKeyCode(KeyCode: Smallint): PKey; {$IFDEF INLINES}inline;{$ENDIF}
var
  I: Integer;
begin
  for I := 0 to High(CKeys) do
    if CKeys[I].KeyCode = KeyCode then
    begin
      Result := @CKeys[I];
      Exit;
    end;
  Result := nil;
end;

function TranslateKey(const Rec: TInputRecord; State: Integer; Key: PKey; KeyCode: Integer): Smallint;
begin
  if State and (RIGHT_ALT_PRESSED or LEFT_ALT_PRESSED) <> 0 then
    Result := Key^.Alt
  else if State and (RIGHT_CTRL_PRESSED or LEFT_CTRL_PRESSED) <> 0 then
    Result := Key^.Ctrl
  else if State and SHIFT_PRESSED <> 0 then
    Result := Key^.Shift
  else if KeyCode in [Ord('A')..Ord('Z')] then
    Result := Ord(Rec.Event.KeyEvent.AsciiChar)
  else
    Result := Key^.Normal;
end;

function ConvertKey(const Rec: TInputRecord; Key: PKey): Smallint;
  {$IFDEF INLINES}inline;{$ENDIF}
begin
  if Assigned(Key) then
    Result := TranslateKey(Rec, Rec.Event.KeyEvent.dwControlKeyState,
      Key, Rec.Event.KeyEvent.wVirtualKeyCode)
  else
    Result := -1
end;


function KeyPressed : Boolean;
var
  InputRecArray : array of TInputRecord;
  NumRead       : DWORD;
  NumEvents     : DWORD;
  I             : Integer;
  KeyCode       : Word;
begin
  Result := False;
  GetNumberOfConsoleInputEvents (StdIn, NumEvents);
  if NumEvents = 0 then
    Exit;
  SetLength(InputRecArray, NumEvents);
  PeekConsoleInput(StdIn, InputRecArray[0], NumEvents, NumRead);
  for I := 0 to High(InputRecArray) do
  begin
    if (InputRecArray[I].EventType and Key_Event <> 0) and
       InputRecArray[I].Event.KeyEvent.bKeyDown then
    begin
      KeyCode := InputRecArray[I].Event.KeyEvent.wVirtualKeyCode;
      if not (KeyCode in [VK_SHIFT, VK_MENU, VK_CONTROL]) then
      begin
        if ConvertKey(InputRecArray[I], FindKeyCode(KeyCode)) <> -1 then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

function ReadKey : AnsiChar;
var
  InputRec: TInputRecord;
  NumRead: Cardinal;
  KeyMode: DWORD;
  KeyCode: Smallint;
begin
  if ExtendedChar <> #0
  then begin
    Result := ExtendedChar;
    ExtendedChar := #0;
    Exit;
  end
  else begin
    GetConsoleMode(StdIn, KeyMode);
    SetConsoleMode(StdIn, 0);
    repeat
      ReadConsoleInput(StdIn, InputRec, 1, NumRead);
      if (InputRec.EventType and KEY_EVENT <> 0) and
         InputRec.Event.KeyEvent.bKeyDown then
      begin
        if InputRec.Event.KeyEvent.AsciiChar <> #0 then
        begin
          // From Delphi 2009 on, Result is WideChar
          Result := AnsiChar(Ord(InputRec.Event.KeyEvent.AsciiChar));
          Break;
        end;
        KeyCode := ConvertKey(InputRec,
          FindKeyCode(InputRec.Event.KeyEvent.wVirtualKeyCode));
        if KeyCode > $FF then
        begin
          ExtendedChar := AnsiChar(KeyCode and $FF);
          Result := #0;
          Break;
        end;
      end;
    until False;
    SetConsoleMode(StdIn, KeyMode);
  end;
end;

function GetCursorX: Integer; {$IFDEF INLINES}inline;{$ENDIF}
var
  BufferInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleSCreenBufferInfo(StdOut, BufferInfo);
  Result := BufferInfo.dwCursorPosition.X;
end;

function GetCursorY: Integer; {$IFDEF INLINES}inline;{$ENDIF}
var
  BufferInfo: TConsoleScreenBufferInfo;
begin
  GetConsoleSCreenBufferInfo(StdOut, BufferInfo);
  Result := BufferInfo.dwCursorPosition.Y;
end;

procedure SetCursorPos(X, Y: Smallint);
var
  NewPos: TCoord;
begin
  NewPos.X := X;
  NewPos.Y := Y;
  SetConsoleCursorPosition(StdOut, NewPos);
end;

function FormatFloatFixedDecimalsWithUnit(const Data: Extended; const Decimals: cardinal; const BaseUnit:string; BlankLeadingUnit:integer=1; UsePrefixes:boolean=true):string;
var
  AbsData: Extended;
  Factor: Extended;
  PrefixIdx: Integer;
  PrefixedUnit: String;
  FactorUnit: String;
  EngExponent: String;
begin
  AbsData := abs (Data);
  //
  if (AbsData = 0) or (BaseUnit = '')
                   or (BaseUnit = 'a.u.')
                   or (BaseUnit = '%')
                   or (BaseUnit = '°C')
                   or (BaseUnit = '°F')
                   or (BaseUnit = 'K')
  then begin
    Factor     := 1;
    PrefixIdx  := 0;
    FactorUnit := BaseUnit;
  end
  else begin
    if ((BaseUnit = 's') or (BaseUnit = 'sec')) and (AbsData >= 60) then
    begin
      FactorUnit := BaseUnit;
      PrefixIdx  := 0;
      //
      Factor     := 60;
      if (AbsData / Factor) < 60
      then begin
        FactorUnit := 'min';
      end
      else begin
        Factor := Factor * 60;
        if (AbsData / Factor) < 24
        then begin
          FactorUnit := 'h';
        end
        else begin
          Factor := Factor * 24;
          if (AbsData / Factor) <  (1461.0 / 4) // 365.25
          then begin
            FactorUnit := 'd';
          end
          else begin
            Factor := Factor * 1461 / 4;
            FactorUnit := 'yrs';
          end;
        end;
      end;
    end
    else begin
      FactorUnit := BaseUnit;
      Factor     := 1;
      PrefixIdx  := 0;
      while (((AbsData / Factor) >= 1000) and InRange (PrefixIdx, 0, High(PreFixChar)-1))
      do begin
        inc (PrefixIdx);
        Factor   := Factor * 1000;
      end;
      while (((AbsData / Factor) < 1) and InRange (PrefixIdx, Low(PreFixChar)-1, 0))
      do begin
        dec (PrefixIdx);
        Factor   := Factor / 1000;
      end;
    end;
  end;
  //
  if UsePrefixes
  then begin
    case BlankLeadingUnit of
      0: PrefixedUnit :=       trim (' ' + PreFixChar[PrefixIdx]) + trim (FactorUnit);   //  'mW',   'W'   :  (prefixed) unit follows value directly, without a blank
      1: PrefixedUnit := ' ' + trim (' ' + PreFixChar[PrefixIdx]) + trim (FactorUnit);   //  ' mW',  ' W'  :  (prefixed) unit follows value with a blank
    else PrefixedUnit :=             ' ' + PreFixChar[PrefixIdx]  + trim (FactorUnit);   //  ' mW',  '  W' :   prefixed  unit follows value with 1 blank,
    end;                                                                                  //                  unprefixed unit follows value with 2 blanks (tabulated unit)
  end
  else begin
    if PrefixIdx = 0
    then begin
      EngExponent := '';
    end
    else begin
      EngExponent := 'e' + IntToStr (PrefixIdx*3);
    end;
    //
    case BlankLeadingUnit of
      0: PrefixedUnit :=       trim (' ' + EngExponent) + trim (FactorUnit);   //  'mW',   'W'   :  (prefixed) unit follows value directly, without a blank
      1: PrefixedUnit := ' ' + trim (' ' + EngExponent) + trim (FactorUnit);   //  ' mW',  ' W'  :  (prefixed) unit follows value with a blank
    else PrefixedUnit :=             ' ' + EngExponent  + trim (FactorUnit);   //  ' mW',  '  W' :   prefixed  unit follows value with 1 blank,
    end;                                                                       //                    unprefixed unit follows value with 2 blanks (tabulated unit)
  end;
  //
  Result := FloatToStrF ((Data / Factor), ffFixed, 17, Decimals, FormatSettings_spec) + PrefixedUnit;
  //
end;


function FormatFloatFixedMantissaWithUnit (const Data: Extended; const MantissaLength: cardinal; const BaseUnit:string; BlankLeadingUnit:integer=1; UsePrefixes:boolean=true):string;
var
  AbsData: Extended;
  Factor:  Extended;
  Rounded: Extended;
  SignFac: Integer;
  DecimalIdx: Integer;
  Decimals: Integer;
begin
  AbsData := abs (Data);
  SignFac := ifthen (Data > 0, 1, -1);
  DecimalIdx := 0;
  Factor  := 1;
  if AbsData > 0
  then begin
    //
    // Normalisierungsfaktor für AbsData ermitteln ( -->  1 <= (AbsData / Factor) < 10)
    //
    while ((AbsData / Factor) >= 10)
    do begin
      inc (DecimalIdx);
      Factor   := Factor * 10;
    end;
    while ((AbsData / Factor) < 1)
    do begin
      dec (DecimalIdx);
      Factor   := Factor / 10;
    end;
  end;
  //
  // unter Verwendung des Normalisierungsfaktors auf Mantissenlänge (+1 Schutzstelle) runden
  //
  AbsData := abs (SimpleRoundTo (Data / Factor, -(MantissaLength-1)) * Factor);
  Rounded := AbsData / Factor;
  //
  // Fehler durch Aufrundung auf 10 behandeln (zusätzliche Stelle streichen)
  //
  if (Rounded = 10)
  then begin
    inc (DecimalIdx);
    //Factor   := Factor * 10;
  end;
  //
  // Anzahl der tatsächlichen Nachkommastellen bei dieser Mantissenlänge bestimmen
  //
  Decimals := MantissaLength-1;
  //
  if (  (BaseUnit = '')
     or (BaseUnit = 'a.u.')
     or (BaseUnit = '%')
     or (BaseUnit = '°C')
     or (BaseUnit = '°F')
     or (BaseUnit = 'K')
     )
  then begin
    Decimals := max ((-DecimalIdx) + Decimals, 0);
  end
  else begin
    while ((DecimalIdx mod 3) <> 0)
    do begin
      if DecimalIdx > 0
      then begin
        inc (DecimalIdx);
        dec (Decimals);
      end
      else begin
        dec (DecimalIdx);
        dec (Decimals);
      end;
    end;
    Decimals := max (Decimals, 0);
  end;
  //
  Result := FormatFloatFixedDecimalsWithUnit(ifthen (SignFac > 0, AbsData, -AbsData), Decimals, BaseUnit, BlankLeadingUnit, UsePrefixes);
end;


  procedure UInt2MantPrfx (value : cardinal; var mant: cardinal; var prfx: cardinal);
  begin
    prfx := 0;
    mant := value;
    //
    while (mant > 999)
    do begin
      mant := mant div 1000;
      inc (prfx);
    end;
  end;

  procedure Float2MantPrfx(value: single; var mant: single; var prfx: integer);
  var
    sign : integer;
  begin
    prfx := 0;
    mant := abs (value);
    sign := ifthen (value < 0.0, -1, 1);
    //
    while (mant > 999.99999)
    do begin
      mant := mant / 1000.00000;
      inc (prfx);
    end;
    //
    if (mant > 0.00000000000)
    then begin
      while (mant < 1.0000000)
      do begin
        mant := mant * 1000.00000;
        dec (prfx);
      end;
    end;
    mant := mant * sign;
    //
  end; // Float2MantPrfx


initialization
  StdIn  := GetStdHandle(STD_INPUT_HANDLE);
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  //
  FormatSettings_spec                 := TFormatSettings.Create ('en-US');//
  FormatSettings_spec.DateSeparator   := '-';
  FormatSettings_spec.TimeSeparator   := ':';
  FormatSettings_spec.ShortTimeFormat := 'hh:nn:ss';
  FormatSettings_spec.LongTimeFormat  := 'hh:nn:ss.zzz';
  FormatSettings_spec.ShortDateFormat := 'yy/mm/dd';
  FormatSettings_spec.LongDateFormat  := 'yyyy/mm/dd';
  //
end.
