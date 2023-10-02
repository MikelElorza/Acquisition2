
using System;
using System.Text;
using System.Threading;

//********************************************************
// Main
//********************************************************
namespace PDLM_SimpleDemo
{
  partial class Program
  {

    static void Main(string[] args)
    {
      PDLM_Errors ret;
      String input;
      //
      StringBuilder libraryVersionString = new StringBuilder(32);
      StringBuilder driverVersionString = new StringBuilder(32);
      StringBuilder driverDateString = new StringBuilder(32);
      StringBuilder driverServiceString = new StringBuilder(32);
      //
      UInt32 byteCount = 0;
      UInt32 deviceStatus = 0;
      String serialNumber = String.Empty;
      UInt32 frequency = 0;
      UInt32 freqNew;
      UInt32 power_PerMille;
      float fPower = 0;
      //
      PDLM_Errors[] NoErrorsAllowed = { PDLM_Errors.NONE };
      PDLM_Errors[] ErrorsOnOpenAllowed = { PDLM_Errors.DEVICE_BUSY_OR_BLOCKED,
                                                 PDLM_Errors.USB_INAPPROPRIATE_DEVICE,
                                                 PDLM_Errors.DEVICE_ALREADY_OPENED,
                                                 PDLM_Errors.OPEN_DEVICE_FAILED,
                                                 PDLM_Errors.USB_UNKNOWN_DEVICE,
                                                 PDLM_Errors.NONE };
      PDLM_Errors[] ErrorsAllowedOnTagDescr = { PDLM_Errors.UNKNOWN_TAG,
                                                 PDLM_Errors.NONE };
      PDLM_Errors[] ErrorsAllowedOnExtTrig = { PDLM_Errors.VALUE_NOT_AVAILABLE,
                                                 PDLM_Errors.NONE };
      //
      //
      // get version of .dll file
      CheckReturnValue("PDLM_GetLibraryVersion", PDLM_GetLibraryVersion(libraryVersionString, (uint)libraryVersionString.Capacity), out ret, NoErrorsAllowed, "");
      // check DLL version            
      if (IsDllVersionOkay(libraryVersionString.ToString()) == true)
      {
        CheckReturnValue("PDLM_GetUSBDriverInfo", PDLM_GetUSBDriverInfo(driverServiceString, (uint)driverServiceString.Capacity,
          driverVersionString, (uint)driverVersionString.Capacity,
          driverDateString, (uint)driverDateString.Capacity), out ret, NoErrorsAllowed,
          "  Cannot get driver info, probably due to no available devices or no installed driver.");

        Console.WriteLine("\n PDL-M1 \"Taiko\"  Demo Application  \xB8 2019 by PicoQuant GmbH, A. Podubrin");
        Console.WriteLine("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        Console.WriteLine("  [ C# ]        {0,55}  \n", "Library version : " + libraryVersionString.ToString());

        Console.WriteLine("  USB-Driver Service: '" + driverServiceString.ToString() +
                          "'; V" + driverVersionString.ToString() +
                          ", " + driverDateString.ToString());
        //
        // open and get serial
        usbIndex = OpenFirstPdlm(ref serialNumber);
        if (usbIndex != -1)
        {
          try
          {
            Console.WriteLine("\n  USB index {0}: {1} with serial number {2} found", usbIndex, DEVICE_NAME, serialNumber);
            //
            Console.WriteLine("\n  Versions info:");
            CheckReturnValue("PDLM_GetFWVersion", PDLM_GetFWVersion(usbIndex, libraryVersionString, (uint)libraryVersionString.Capacity), out ret, NoErrorsAllowed, "  Cannot retrieve FW version.");
            Console.WriteLine("  - FW   : {0}", libraryVersionString);
            CheckReturnValue("PDLM_GetFPGAVersion", PDLM_GetFPGAVersion(usbIndex, libraryVersionString, (uint)libraryVersionString.Capacity), out ret, NoErrorsAllowed, "  Cannot retrieve FPGA version.");
            Console.WriteLine("  - FPGA : {0}", libraryVersionString);
            CheckReturnValue("PDLM_GetLHVersion", PDLM_GetLHVersion(usbIndex, libraryVersionString, (uint)libraryVersionString.Capacity), out ret, NoErrorsAllowed, "  Cannot retrieve LH version.");
            Console.WriteLine("  - LH   : {0}", libraryVersionString);
            //
            // lock manual operation as long we are working with it; it will automatically unlock on PDLM_CloseDevice
            CheckReturnValue("PDLM_SetExclusiveUI", PDLM_SetExclusiveUI(usbIndex, PDLM_UI_Remotesetting.EXCLUSIVE), out ret, NoErrorsAllowed, "  Cannot lock the device GUI.");
            //
            // check status of PDL
            CheckReturnValue("PDLM_GetSystemStatus", PDLM_GetSystemStatus(usbIndex, ref deviceStatus), out ret, NoErrorsAllowed, "  Cannot read system status.");
            Console.WriteLine("");
            //
            // check laser locking status
            Console.WriteLine("  Laser is" + (CheckForStatusBits(deviceStatus, (UInt32)(DeviceStatus.PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON)) ? " " : " NOT ") + "locked by On/ Off Button");
            Console.WriteLine("  Laser is" + (CheckForStatusBits(deviceStatus, (UInt32)(DeviceStatus.PDLM_DEVSTATE_KEYLOCK)) ? " " : " NOT ") + "locked by key");
            Console.WriteLine("");
            //
            // get laser specific info
            LaserInfo laserData = new LaserInfo();
            byteCount = Convert.ToUInt32(System.Runtime.InteropServices.Marshal.SizeOf(typeof(LaserInfo)));
            CheckReturnValue("PDLM_GetLHInfo", PDLM_GetLHInfo(usbIndex, ref laserData, byteCount), out ret, NoErrorsAllowed, "  Cannot get laser head info.");
            string typeString = System.Text.Encoding.Default.GetString(laserData.LaserType);
            string dateString = System.Text.Encoding.Default.GetString(laserData.DateOfManufacture);
            string classString = System.Text.Encoding.Default.GetString(laserData.LaserClass);
            Console.WriteLine("  Connected laser head:");
            Console.WriteLine("  - laser head type          : {0}", typeString);
            Console.WriteLine("  - date of manufacture      : {0}", dateString);
            Console.WriteLine("  - laser power class        : {0}", classString);
            Console.WriteLine("");
            //
            // get laser head specific data
            LaserData lDat = new LaserData();
            byteCount = Convert.ToUInt32(System.Runtime.InteropServices.Marshal.SizeOf(typeof(LaserData)));
            CheckReturnValue("PDLM_GetLHData", PDLM_GetLHData(usbIndex, ref lDat, byteCount), out ret, NoErrorsAllowed, "  Cannot get laser head data.");
            Console.WriteLine("  - frequency range          : {0} - {1}", Freq2FormatedString(lDat.FreqMin), Freq2FormatedString(lDat.FreqMax));
            Console.WriteLine("");
            //
            //
            // get current temperature scale
            CheckReturnValue("PDLM_GetTempScale", PDLM_GetTempScale(usbIndex, ref CurTempScale), out ret, NoErrorsAllowed, "  Cannot get current temperature scale.");
            OldTempScale = CurTempScale;
            //
            // if you want to read your device in °F, change this parameter and execute the next two code lines:
            //
            //CurTempScale = (UInt32)PDLM_TempScale.PDLM_TEMPERATURESCALE_CELSIUS; // (UInt32)PDLM_TempScale.PDLM_TEMPERATURESCALE_FAHRENHEIT;
            //CheckReturnValue("PDLM_SetTempScale", PDLM_SetTempScale(usbIndex, CurTempScale), out ret, NoErrorsAllowed, "  Cannot set current temperature scale.");
            //
            // set laser mode to pulsed emission
            CheckReturnValue("PDLM_SetLaserMode", PDLM_SetLaserMode(usbIndex, PDLM_LaserMode.PDLM_LASER_MODE_PULSE), out ret, NoErrorsAllowed, "  Cannot set laser mode to pulsed.");
            //
            // Check which frequency is currently set
            CheckReturnValue("PDLM_GetFrequency", PDLM_GetFrequency(usbIndex, ref frequency), out ret, NoErrorsAllowed, "  Cannot get frequency.");
            Console.WriteLine("  frequency currently set    : {0}", Freq2FormatedString(frequency));
            //
            // Set (new) frequency to 10MHz if allowed
            freqNew = EnsureRange(10000000, lDat.FreqMin, lDat.FreqMax);
            //
            // Check if new frequency is supported by connected laser head
            if (freqNew != 10000000)
              Console.WriteLine("  frequency of 10MHz is not supported by laser head, set to {0} instead", Freq2FormatedString(freqNew));
            //
            CheckReturnValue("PDLM_SetFrequency", PDLM_SetFrequency(usbIndex, freqNew), out ret, NoErrorsAllowed, "  Cannot set frequency.");
            Console.WriteLine("  frequency now set to       : {0}", Freq2FormatedString(freqNew));
            //
            // Set Power to 5%
            power_PerMille = 50;
            CheckReturnValue("PDLM_SetPulsePowerPermille", PDLM_SetPulsePowerPermille(usbIndex, power_PerMille), out ret, NoErrorsAllowed, "  Cannot set pulse power.");
            //
            // Read the resulting power in W
            CheckReturnValue("PDLM_GetPulsePower", PDLM_GetPulsePower(usbIndex, ref fPower), out ret, ErrorsAllowedOnExtTrig, "  Cannot read pulse power.");
            //
            if (ret == PDLM_Errors.NONE)
            {
              if (fPower == 0)
              {
                Console.WriteLine("  Cannot set power.");
                if (lDat.Protection)
                  Console.WriteLine("  - This is a class 4 laser head; You must unlock it by key first.");
                else
                  Console.WriteLine("  - Check for laser locking conditions.");
              }
              else
                Console.WriteLine("  pulse power set to         : {0:F1} % ==> {1}", (power_PerMille / 10), Float2FormatedString(fPower, "W"));
            }
            else
              Console.WriteLine("  pulse power set to         : {0:F1} %", (power_PerMille / 10));
            Console.WriteLine("");
            //
            //
            // You can also get the information via a tagList all together in one call
            TagArray_T tagsOfInterest = new TagArray_T();
            //
            tagsOfInterest.Add(PDLM_Tags.Frequency);
            tagsOfInterest.Add(PDLM_Tags.TempScale);
            tagsOfInterest.Add(PDLM_Tags.TargetTemp);
            tagsOfInterest.Add(PDLM_Tags.TriggerLevel);
            tagsOfInterest.Add(PDLM_Tags.LDH_PulsePowerTable);
            tagsOfInterest.Add(PDLM_Tags.PulsePowerHiLimit);
            tagsOfInterest.Add(PDLM_Tags.PulsePowerPermille);
            tagsOfInterest.Add(PDLM_Tags.PulsePower);
            tagsOfInterest.Add(PDLM_Tags.PulseShape);
            // NONE tag must not be added: It is added by contructor of TagArray_T

            TagValueArray_T TagValues = new TagValueArray_T(tagsOfInterest);
            UInt32 tagCount = (UInt32)TagValues.Length;
            //
            CheckReturnValue("PDLM_GetTagValueList", PDLM_GetTagValueList(usbIndex, tagCount, ref TagValues.tagsAndValues[0]), out ret, NoErrorsAllowed, "  Cannot get Values via TagList.");
            //
            Console.WriteLine("  Got via tag list:");
            //
            // Iterate over all tags in tag array but do not include the terminating NONE tag.
            for (int i = 0; i < tagCount - 1; ++i)
            {
              if (TagValues[i].tag == TagValues.GetOriginalTag(i).tag)
              {
                WriteLn_Tag(TagValues[i]);
              }
              else
              {
                StringBuilder errorDesciption = new StringBuilder(32);
                uint size = (uint)errorDesciption.Capacity;
                PDLM_DecodeError(TagValues.GetOriginalTag(i).value.iValue, errorDesciption, ref size);
                ShowErrorMessage(String.Format("Error {0} on {1}: Tagged value: {2}", TagValues.GetOriginalTag(i).value.iValue, i, errorDesciption.ToString()));
              }
            }
            Console.WriteLine("");
            //
            // Unlock the device GUI and ask user to change something
            CheckReturnValue("PDLM_SetExclusiveUI", PDLM_SetExclusiveUI(usbIndex, PDLM_UI_Remotesetting.COOPERATIVE), out ret, NoErrorsAllowed, "Cannot unlock device GUI");
            Console.WriteLine("  Device GUI unlocked");
            //
            Thread.Sleep(100);
            //
            UInt32 changesCount = MAX_TAGLIST_LEN;
            TagValues = new TagValueArray_T(changesCount);
            //
            // Get last changes to reset list input
            CheckReturnValue("PDLM_GetQueuedChanges", PDLM_GetQueuedChanges(usbIndex, ref TagValues.tagsAndValues[0], ref changesCount), out ret, NoErrorsAllowed, "  Cannot get pending changes.");
            do
            {
              Console.WriteLine("");
              Console.Write("  Change something (frequency, power or type 'x' to exit) and hit return: ");
              input = Console.ReadLine();
              //
              if ((string.Compare(input, "x") != 0) && (string.Compare(input, "X") != 0))
              {
                changesCount = (uint)TagValues.Length;
                CheckReturnValue("PDLM_GetQueuedChanges", PDLM_GetQueuedChanges(usbIndex, ref TagValues.tagsAndValues[0], ref changesCount), out ret, NoErrorsAllowed, "  Cannot get pending changes.");
                if (changesCount > 0)
                  for (int i = 0; i < changesCount; i++)
                    WriteLn_Tag(TagValues.tagsAndValues[i]);
                else
                  Console.WriteLine("  No changes detected");
              }
              else
                break;
            } while (true);
          }
          finally
          {
            PDLM_SetExclusiveUI(usbIndex, PDLM_UI_Remotesetting.COOPERATIVE);
            if (OldTempScale != CurTempScale)
              PDLM_SetTempScale(usbIndex, OldTempScale);
            PDLM_CloseDevice(usbIndex);
          }
        }
        else ShowErrorMessage(String.Format("No {0} found", DEVICE_NAME));
      }
      else
      {
        // Error-Handling
        if (ret == PDLM_Errors.BUFFER_TOO_SMALL)
          ShowErrorMessage("Buffer too small");
        else ShowErrorMessage("Lib Version error");
      }

      Thread.Sleep(3000);
    }
  }
}
