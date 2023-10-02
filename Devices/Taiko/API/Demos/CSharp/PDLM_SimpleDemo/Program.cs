using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

namespace PDLM_SimpleDemo
{
  partial class Program
  {
    // Application constants
    public const string DLL_VERSION_REF = "2.1.";
    public const string DEVICE_NAME = "Taiko PDL-M1";
    public const string PDLMLib = "pdlm_lib.dll";
    public static readonly string[] PDLM_TEMPSCALE_UNITS = { "°C", "°F", "K" };

    public static UInt32 CurTempScale = (UInt32)PDLM_TempScale.PDLM_TEMPERATURESCALE_CELSIUS;
    public static UInt32 OldTempScale = (UInt32)PDLM_TempScale.PDLM_TEMPERATURESCALE_CELSIUS;
    public static Int32 usbIndex = -1;

    public const UInt32 MAX_TAGLIST_LEN = 64;

    public enum PDLM_UI_Remotesetting : UInt32
    {
      COOPERATIVE,
      EXCLUSIVE
    }

    // Import API functions
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetLibraryVersion(StringBuilder version, uint uiBuffLen);
    [DllImport(PDLMLib)]
    extern static PDLM_Errors PDLM_GetUSBDriverInfo(StringBuilder driverService, uint uiSBuffLen,
      StringBuilder driverVersion, uint uiVBuffLen,
      StringBuilder driverDate, uint uiDBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_OpenDevice(int USBIdx, StringBuilder cSerNo);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_CloseDevice(int USBIdx);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetExclusiveUI(int USBIdx, PDLM_UI_Remotesetting mode);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetSystemStatus(int USBIdx, ref UInt32 status);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetLHInfo(int USBIdx, ref LaserInfo info, UInt32 size);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetLHData(int USBIdx, ref LaserData info, UInt32 size);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetTempScale(int USBIdx, ref UInt32 CurTempScale);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetTempScale(int USBIdx, UInt32 CurTempScale);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetLaserMode(int USBIdx, PDLM_LaserMode mode);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetFrequency(int USBIdx, ref UInt32 freq);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetPulsePowerPermille(int USBIdx, UInt32 permille);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetPulsePower(int USBIdx, ref float fPower);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetTagValueList(int USBIdx, UInt32 uiListLen, ref TagValue_T pTagValueList);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetTagDescription(PDLM_Tags Tag, ref PDLM_Tagtype TypeCode, StringBuilder tagName);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetQueuedChanges(int USBIdx, ref TagValue_T pTagValueList, ref UInt32 uiListLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetFWVersion(int USBIdx, StringBuilder version, UInt32 uiBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetFPGAVersion(int USBIdx, StringBuilder version, UInt32 uiBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetLHVersion(int USBIdx, StringBuilder version, UInt32 uiBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetFrequency(int USBIdx, UInt32 freq);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_DecodeError(int iErrCode, StringBuilder cBuffer, ref UInt32 uiBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_DecodePulseShape(UInt32 shape, StringBuilder cBuffer, UInt32 uiBuffLen);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_SetLDHPulsePowerTable(int USBIdx, PDLM_PulsePowerTable TableIdx);
    [DllImport(PDLMLib)] extern static PDLM_Errors PDLM_GetLDHPulsePowerTable(int USBIdx, ref PDLM_PulsePowerTable TableIdx);


    [StructLayout(LayoutKind.Sequential)]
    public struct LaserInfo
    {
      [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
      public byte[] LaserType;
      [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
      public byte[] DateOfManufacture;
      [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
      public byte[] LaserClass;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TLHVersNum
    {
      public UInt16 Major;
      public UInt16 Minor;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 2)]
    public struct LaserData
    {
      public UInt32 Serial;
      public UInt32 Features;
      public UInt32 FreqMin;
      public UInt32 FreqMax;
      public UInt32 CwPowerMax;
      public UInt32 PulsePowerMax;
      //
      public UInt16 WavelengthNominal;
      //
      // this is to mock up for bit-sensitive access:
      //   CaseTempMax : 10 bits, Protection and CwCurrentPolarity 1 bit each
      private UInt16 F_10Temp_1Prot_1Plrty_4;
      public UInt16 CaseTempMax {
        get { return (UInt16)(F_10Temp_1Prot_1Plrty_4 & (UInt16)0x03FF); }
        set { F_10Temp_1Prot_1Plrty_4 = (UInt16)(((UInt16)F_10Temp_1Prot_1Plrty_4 & (UInt16)0x0C00) | (UInt16)((UInt16)value & (UInt16)0x03FF)); }
        }
      public bool Protection {
        get { return ((F_10Temp_1Prot_1Plrty_4 & (UInt16)0x0400) > 0); }
        set { F_10Temp_1Prot_1Plrty_4 = (value ? (UInt16)((UInt16)F_10Temp_1Prot_1Plrty_4 | (UInt16)0x0400) : (UInt16)((UInt16)F_10Temp_1Prot_1Plrty_4 & (UInt16)0x0BFF)); }
        }
      public bool CwCurrentPolarity {
        get { return ((F_10Temp_1Prot_1Plrty_4 & (UInt16)0x0800) > 0); }
        set { F_10Temp_1Prot_1Plrty_4 = (value ? (UInt16)(F_10Temp_1Prot_1Plrty_4 | (UInt16)0x0800) : (UInt16)(F_10Temp_1Prot_1Plrty_4 & (UInt16)0x07FF)); }
        }
      //
      // this is to mock up for bit-sensitive access:
      //   LHTypeCtrlVoltage : 12 bits
      private UInt16 F_12LHTypeCtrlVoltage_4;
      public UInt16 LHTypeCtrlVoltage {
        get { return (UInt16)(F_12LHTypeCtrlVoltage_4 & (UInt16)0x0FFF); }
        set { F_12LHTypeCtrlVoltage_4 = (UInt16)((UInt16)((UInt16)value & (UInt16)0x0FFF)); }
        }
      //
      // this is to mock up for bit-sensitive access:
      //   LHMaxVoltage : 12 bits
      private UInt16 F_12LHMaxVoltage_4;
      public UInt16 LHMaxVoltage
      {
        get { return (UInt16)(F_12LHMaxVoltage_4 & (UInt16)0x0FFF); }
        set { F_12LHMaxVoltage_4 = (UInt16)((UInt16)((UInt16)value & (UInt16)0x0FFF)); }
      }
      //
      public UInt16 CurrentTEP12V;
      public UInt16 LaserType;
      //
      public TLHVersNum LaserVersion;
      //
      public UInt16 CalibratedWarrantHours;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct TagTypedValue_T
    {
      [FieldOffset(0)] public uint uiValue;
      [FieldOffset(0)] public int iValue;
      [FieldOffset(0)] public float fValue;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TagValue_T
    {
      public PDLM_Tags tag;
      public TagTypedValue_T value;

      public TagValue_T(PDLM_Tags tagInit, TagTypedValue_T valueInit)
      {
        tag = tagInit;
        value = valueInit;
      }
    }

    // This class is responsible to generate an array of tag/value pairs for every tag in PDLM_Tags
    public class TagValueArray_T
    {
      public TagValue_T[] tagsAndValues;
      public TagValue_T[] tagsAndValuesCopy;
      public int Length { get; private set; }

      public TagValueArray_T(TagArray_T tags)
      {
        Length = tags.Count;
        tagsAndValues = new TagValue_T[Length];
        tagsAndValuesCopy = new TagValue_T[Length];

        PDLM_Tags[] tmparray = tags.ToArray();

        for (int i = 0; i < Length; ++i)
        {
          tagsAndValues[i].tag = tagsAndValuesCopy[i].tag = tmparray[i];
          tagsAndValues[i].value.fValue = tagsAndValuesCopy[i].value.fValue = 0;
        }
      }

      public TagValueArray_T(UInt32 count)
      {
        tagsAndValues = new TagValue_T[count];
        tagsAndValuesCopy = new TagValue_T[count];
        Length = (int)count;
      }

      public TagValue_T GetOriginalTag(int index)
      { 
        return tagsAndValuesCopy[index]; 
      }

      public TagValue_T this[int index] => tagsAndValues[index];
    }

    // This class is responsible to generate an array of tag/value pairs for every tag in PDLM_Tags
    public class TagArray_T
    {
      public List<PDLM_Tags> puretags = new List<PDLM_Tags>();
      public int Count { get; private set; }

      public TagArray_T()
      {
        // Insert a NONE tag as default at index 0
        // This way it is assured that Count is always >= 1, too
        puretags.Insert(0, PDLM_Tags.NONE);
        Count = 1;
      }

      public void AddAll()
      {
        // Clear the list to avoid duplicates
        puretags.Clear();

        // Get all values of enumerated tags
        Array TagValues = System.Enum.GetValues(typeof(PDLM_Tags));

        // Add all enumerated tags to the puretags list
        foreach (PDLM_Tags tagid in TagValues)
        {
          // The NONE tag is always present so do not add this again
          if (tagid != PDLM_Tags.NONE)
          {
            // Due to contructor initialization the Count is always >= 1
            puretags.Insert(puretags.Count - 1, tagid);
          }
        }

        Count = TagValues.Length;
      }

      public void Add(PDLM_Tags tag)
      {
        // Due to contructor initialization the Count is always >= 1
        puretags.Insert(puretags.Count - 1, tag);
        ++Count;
      }

      public PDLM_Tags[] ToArray()
      {
        return puretags.ToArray();
      }
    }


    //********************************************************
    // Show error message
    //********************************************************
    static void ShowErrorMessage(String errorMsg)
    {
      Console.WriteLine("Error: {0}", errorMsg);
    }

    //********************************************************
    // Check return value
    //********************************************************
    static void CheckReturnValue(String FuncName, PDLM_Errors RetIn, out PDLM_Errors RetOut, PDLM_Errors[] AllowedRetVals, String ErrMsg)
    {
      //
      const int STD_BUFFER_LEN = 1024;
      int i = 0;
      uint BuffLen = 1023;
      bool Allowed = false;
      char c;
      StringBuilder ErrTxt = new StringBuilder(STD_BUFFER_LEN);
      //
      RetOut = RetIn;
      //
      if (RetIn != (Int32)PDLM_Errors.NONE)
      {
        while (AllowedRetVals[i] != 0)
        {
          if (AllowedRetVals[i] == RetIn)
          {
            Allowed = true;
            break;
          }
          i++;
        }
        //
        if (!Allowed)
        {
          if (ErrMsg.Length > 0)
            Console.WriteLine("\n  {0}", ErrMsg);
          PDLM_DecodeError((int)RetIn, ErrTxt, ref BuffLen);
          Console.WriteLine("\n  Error {0}  occured during \"{1}\" execution.\n    i.e. \"{2}\"\n", RetIn, FuncName, ErrTxt);
          Console.Write("\n  Hit return key to exit...  > ");
          c = (char)Console.Read();
          if (usbIndex >= 0)
            PDLM_CloseDevice(usbIndex);
          System.Environment.Exit((int)RetIn);
        }
      }
    }

    //********************************************************
    // Check dll version
    //********************************************************
    static Boolean IsDllVersionOkay(String version)
    {
      return version.StartsWith(DLL_VERSION_REF);
    }

    //********************************************************
    // Check for specific status bit(s)
    //********************************************************
    static Boolean CheckForStatusBits(UInt32 DeviceStatus, UInt32 CheckBits)
    {
      return ((DeviceStatus & CheckBits) > 0);
    }

    //********************************************************
    // Ensure value to be in given range
    //********************************************************
    static UInt32 EnsureRange(UInt32 Val, UInt32 Min, UInt32 Max)
    {
      UInt32 ret;

      if (Val > Max)
        ret = Max;
      else if (Val < Min)
        ret = Min;
      else
        ret = Val;

      return ret;
    }

    //********************************************************
    // Open device and get serial number
    //********************************************************
    static int OpenFirstPdlm(ref String pdlmSerial)
    {
      int i;
      int pdlmUsbIdx = -1;
      StringBuilder ser = new StringBuilder(23);

      for (i = 0; i < 8; i++)
      {
        if (PDLM_OpenDevice(i, ser) == PDLM_Errors.NONE)
        {
          pdlmSerial = ser.ToString();
          pdlmUsbIdx = i;
          break;
        }
      }
      return pdlmUsbIdx;
    }

    //**********************************************************
    // Convert UInt32 frequency [Hz] to more readable format
    //**********************************************************
    public static String Freq2FormatedString(UInt32 freq_Hz)
    {
      String ret = string.Empty;

      if (freq_Hz >= 1000000)
        ret = (freq_Hz / 1000000).ToString() + " MHz";
      else if (freq_Hz >= 1000)
        ret = (freq_Hz / 1000).ToString() + " kHz";
      else
        ret = freq_Hz.ToString() + " Hz";

      return ret;
    }

    //**********************************************************
    // Convert UInt32 frequency [Hz] to more readable format
    //**********************************************************
    public static String Float2FormatedString(float value, string unit)
    {
      String ret = string.Empty;

      if (value < 1E-012)
        ret = String.Format("{0:F3} f" + unit, (value * 1E+015));
      else if (value < 1E-009)
        ret = String.Format("{0:F3} p" + unit, (value * 1E+012));
      else if (value < 1E-006)
        ret = String.Format("{0:F3} n" + unit, (value * 1E+009));
      else if (value < 1E-003)
        ret = String.Format("{0:F3} µ" + unit, (value * 1E+006));
      else if (value < 1)
        ret = String.Format("{0:F3} m" + unit, (value * 1E+003));
      else
        ret = String.Format("{0:F3} " + unit, value);

      return ret;
    }

    //**********************************************************
    // Calculate temperature from raw value to given scale
    //**********************************************************
    public static double CalcTemperature(UInt32 ScaleIdx, UInt32 RawValue)
    {
      double ret;

      switch ((PDLM_TempScale)(ScaleIdx))
      {
        case PDLM_TempScale.PDLM_TEMPERATURESCALE_FAHRENHEIT:
          ret = ((0.18 * RawValue) + 32.0);
          break;

        case PDLM_TempScale.PDLM_TEMPERATURESCALE_KELVIN:
          ret = ((0.1 * RawValue) + 273.1);
          break;

        case PDLM_TempScale.PDLM_TEMPERATURESCALE_CELSIUS:
        default:
          ret = (0.1 * RawValue);
          break;
      }
      return ret;
    }

    public static void WriteLn_Tag(TagValue_T tagAndValue)
    {
      PDLM_Tagtype TagType = PDLM_Tagtype.VOID;
      StringBuilder TagName = new StringBuilder(50);
      string formattedTagName;

      PDLM_GetTagDescription(tagAndValue.tag, ref TagType, TagName);
      formattedTagName = TagName.ToString().PadRight(24);

      Console.Write("  - {0} : ", formattedTagName);

      switch (tagAndValue.tag)
      {
        case PDLM_Tags.NONE:
          break; // Do nothing for NONE tag
        case PDLM_Tags.PulsePower:
        case PDLM_Tags.PulsePowerHiLimit:
        case PDLM_Tags.PulsePowerLoLimit:
          Console.WriteLine("{0}", Float2FormatedString(tagAndValue.value.fValue, "W"));
          break;

        case PDLM_Tags.PulsePowerNanowatt:
          Console.WriteLine("{0} nW ==> {1}", tagAndValue.value.uiValue, Float2FormatedString(1.0e-9F * tagAndValue.value.uiValue, "W"));
          break;

        case PDLM_Tags.PulsePowerPermille:
          Console.WriteLine("{0} permille ==> {1:F1} %", tagAndValue.value.uiValue, ((float)tagAndValue.value.uiValue / 10));
          break;

        case PDLM_Tags.PulseEnergy:
          Console.WriteLine("{0} fJ ==> {1}", tagAndValue.value.uiValue, Float2FormatedString(1.0e-15F * tagAndValue.value.uiValue, "J"));
          break;

        case PDLM_Tags.PulseShape:
          StringBuilder shapeString = new StringBuilder(32);
          PDLM_DecodePulseShape(tagAndValue.value.uiValue, shapeString, (uint)shapeString.Capacity);
          Console.WriteLine("{0} ==> {1}", tagAndValue.value.uiValue, shapeString);
          break;

        case PDLM_Tags.Frequency:
          Console.WriteLine("{0}", Freq2FormatedString(tagAndValue.value.uiValue));
          break;

        case PDLM_Tags.TempScale:
          if (tagAndValue.value.uiValue < PDLM_TEMPSCALE_UNITS.Length)
          {
            CurTempScale = tagAndValue.value.uiValue;
            Console.WriteLine("{0} ==> {1}", CurTempScale, PDLM_TEMPSCALE_UNITS[CurTempScale]);
          }
          else Console.WriteLine("  Value out of range");
          break;

        case PDLM_Tags.TargetTemp:
        case PDLM_Tags.CurrentTemp:
        case PDLM_Tags.CaseTemp:
          Console.WriteLine("{0:F1} {1}", tagAndValue.value.fValue, PDLM_TEMPSCALE_UNITS[CurTempScale]);
          break;

        case PDLM_Tags.TargetTempRaw:
        case PDLM_Tags.CurrentTempRaw:
        case PDLM_Tags.CaseTempRaw:
          Console.WriteLine("{0:D3}°C/10 ==> {1:F1} {2}", tagAndValue.value.uiValue, CalcTemperature(CurTempScale, tagAndValue.value.uiValue), PDLM_TEMPSCALE_UNITS[CurTempScale]);
          break;

        case PDLM_Tags.TriggerLevel:
          Console.WriteLine("{0:F3} V", tagAndValue.value.fValue);
          break;

        default:
          // If no special output format is defined output default non specialized output
          switch (TagType)
          {
            case PDLM_Tagtype.VOID:
              Console.WriteLine(" no var");
              break;

            case PDLM_Tagtype.BOOL:
              Console.WriteLine("{0}", tagAndValue.value.iValue > 0 ? "TRUE" : "FALSE");
              break;

            case PDLM_Tagtype.INT:
              Console.WriteLine("{0}", tagAndValue.value.iValue);
              break;

            case PDLM_Tagtype.INT_IN_PERTHOUSAND:
              Console.WriteLine("{0:F3}", tagAndValue.value.iValue / 1000);
              break;

            case PDLM_Tagtype.SINGLE:
              Console.WriteLine("{0}", tagAndValue.value.fValue);
              break;

            case PDLM_Tagtype.UINT:
              Console.WriteLine("{0}", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_DAC:
              Console.WriteLine("0x{0:X4}", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_IN_PERCENT:
              Console.WriteLine("{0} %", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_IN_PERMILLE:
              Console.WriteLine("{0:F1} %", tagAndValue.value.uiValue / 10);
              break;

            case PDLM_Tagtype.UINT_IN_TENTH:
              Console.WriteLine("{0:F1} ", tagAndValue.value.uiValue / 10);
              break;

            case PDLM_Tagtype.UINT_IN_PERMYRIAD: // per 10.000
              Console.WriteLine("{0:F2} %", tagAndValue.value.uiValue / 100);
              break;

            case PDLM_Tagtype.UINT_IN_PERMILLION:
              Console.WriteLine("{0} ppm", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_IN_PERTHOUSAND:
              Console.WriteLine("{0:F3} ", tagAndValue.value.uiValue / 1000);
              break;

            case PDLM_Tagtype.UINT_IN_PERBILLION:
              Console.WriteLine("{0} ppb", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_IN_PERTRILLION:
              Console.WriteLine("{0} ppt", tagAndValue.value.uiValue);
              break;

            case PDLM_Tagtype.UINT_IN_PERQUADTRILLION:
              Console.WriteLine("{0} ppq", tagAndValue.value.uiValue);
              break;

            default:
              Console.WriteLine("{0}", tagAndValue.value.uiValue);
              break;
          }
          break;
      }
    }
  }
}
