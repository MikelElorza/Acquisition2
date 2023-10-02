import ctypes as ct
from ctypes import byref
from ctypes import windll
import time
import os

# From common_files

PDLM_MAX_USBDEVICES = 8
PDLM_LDH_STRING_LENGTH = 16
PDLM_UI_COOPERATIVE = 0
PDLM_UI_EXCLUSIVE = 1
PDLM_LASER_MODE_PULSE = 1

PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON = 1 << 23
PDLM_DEVSTATE_KEYLOCK = 1 << 25

MAX_TAGLIST_LEN = 64
PDLM_TAGNAME_MAXLEN = 31
PDLM_TAG_LDH_PulsePowerTable = 0x00000021
PDLM_TAG_PulsePowerHiLimit = 0x0000004A
PDLM_TAG_PulsePowerPermille = 0x000000B4
PDLM_TAG_PulseShape = 0x000000B5
PDLM_TAG_PulsePower = 0x000000B8
PDLM_TAG_PulsePowerNanowatt = 0x000000BC
PDLM_TAG_Frequency = 0x000000A8
PDLM_TAG_TempScale = 0x0000009F
PDLM_TAG_TargetTemp = 0x00000098
PDLM_TAG_TargetTempRaw = 0x00000090
PDLM_TAG_TriggerLevel = 0x00000048
PDLM_TAG_PulseShape = 0x000000B5
PDLM_TAG_NONE = 0x00000000
PDLM_TAGTYPE_INT = 0x00110001
PDLM_TAGTYPE_UINT = 0x00010001
PDLM_TAGTYPE_UINT_ENUM = 0x00010002
PDLM_TAGTYPE_SINGLE = 0x01000001

PDLM_TEMPERATURESCALE_CELSIUS = 0
PDLM_TEMPERATURESCALE_FAHRENHEIT = 1
PDLM_TEMPERATURESCALE_KELVIN = 2

PDLM_ERROR_NONE = 0
PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED = -17
PDLM_ERROR_USB_INAPPROPRIATE_DEVICE = -18
PDLM_ERROR_DEVICE_ALREADY_OPENED = -27
PDLM_ERROR_OPEN_DEVICE_FAILED = -28
PDLM_ERROR_USB_UNKNOWN_DEVICE = -29
PDLM_ERROR_UNKNOWN_TAG = -34
PDLM_ERROR_VALUE_NOT_AVAILABLE = -40

ERRORS_ON_OPEN_ALLOWED = [ PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED,
                           PDLM_ERROR_USB_INAPPROPRIATE_DEVICE,
                           PDLM_ERROR_DEVICE_ALREADY_OPENED,
                           PDLM_ERROR_OPEN_DEVICE_FAILED,
                           PDLM_ERROR_USB_UNKNOWN_DEVICE ]
ERRORS_ALLOWED_ON_TAG_DESCR = [ PDLM_ERROR_UNKNOWN_TAG ]
ERRORS_ALLOWED_ON_EXT_TRIG = [ PDLM_ERROR_VALUE_NOT_AVAILABLE ]

UNIT_PREFIX = ["a", "f", "p", "n", "\u03BC", "m", "", "k", "M", "G"]
TEMPSCALE_UNITS = ["°C", "°F", "K"]
PREFIX_ZEROIDX = 6
STD_BUFFER_LEN = 1024

dir_path = os.path.dirname(os.path.realpath(__file__))
pdlm_lib = ct.WinDLL(dir_path+"\pdlm_lib.dll")

# Classes to enable easy reading of tags
class TValueType(ct.Union):
    _fields_ = [
        ("ValueUInt", ct.c_uint32),
        ("ValueInt", ct.c_int32),
        ("ValueFloat", ct.c_float)
    ]

class TTagValue(ct.Structure):
    _fields_ = [
        ("Tag", ct.c_uint32),
        ("Value", TValueType)
    ]

def print_tag_value(tag_value):
    global temp_scale
    buf = ct.create_string_buffer(b"", STD_BUFFER_LEN)
    if tag_value.Tag == PDLM_TAG_NONE:
        buf_len = ct.c_uint(STD_BUFFER_LEN - 1)
        pdlm_lib.PDLM_DecodeError(tag_value.Value.ValueInt, buf, byref(buf_len))
        print("  - Error (%d) on fetching %d. tagged value: \"%s\"" %
              (tag_value.Value.ValueInt, i, buf.value.decode("utf-8")))
    else:
        tag_type = ct.c_uint()
        tag_name = ct.create_string_buffer(b"", PDLM_TAGNAME_MAXLEN + 1)
        check_ret_value("PDLM_GetTagDescription",
                        pdlm_lib.PDLM_GetTagDescription(tag_value.Tag, byref(tag_type), tag_name),
                        ERRORS_ALLOWED_ON_TAG_DESCR, "  Can't get tag description")
        if tag_value.Tag == PDLM_TAG_LDH_PulsePowerTable:
            power_table = tag_value.Value.ValueUInt
            power_table_str = "max. power mode" if power_table > 0 else "linear power mode"
            print("  -%27s : %3d  ==> %s" %
                  (tag_name.value.decode("utf-8"), power_table, power_table_str))
        elif tag_value.Tag == PDLM_TAG_PulsePowerHiLimit:
            real_power = 1e-9 * tag_value.Value.ValueUInt
            print("  -%27s : %10s" %
                  (tag_name.value.decode("utf-8"), float_get_unit_prefix(real_power, "W")))
        elif tag_value.Tag == PDLM_TAG_PulsePowerPermille:
            per_mille = tag_value.Value.ValueUInt
            print("  -%27s :%4d permille  ==> %5.1f %%" %
                  (tag_name.value.decode("utf-8"), per_mille, 0.1 * per_mille))
        elif tag_value.Tag == PDLM_TAG_PulsePower:
            power = tag_value.Value.ValueFloat
            print("  -%27s : %10s" %
                  (tag_name.value.decode("utf-8"), float_get_unit_prefix(power, "W")))
        elif tag_value.Tag == PDLM_TAG_Frequency:
            freq_cur = tag_value.Value.ValueUInt
            print("  -%27s : %7s" %
                  (tag_name.value.decode("utf-8"), int_get_unit_prefix(freq_cur, "Hz")))
        elif tag_value.Tag == PDLM_TAG_TempScale:
            temp_scale = tag_value.Value.ValueUInt
            print("  -%27s : %3d  ==>  %s" %
                  (tag_name.value.decode("utf-8"), temp_scale, TEMPSCALE_UNITS[temp_scale]))
        elif tag_value.Tag == PDLM_TAG_TargetTemp:
            temp = tag_value.Value.ValueFloat
            print("  -%27s : %5.1f %s" %
                  (tag_name.value.decode("utf-8"), temp, TEMPSCALE_UNITS[temp_scale]))
        elif tag_value.Tag == PDLM_TAG_TriggerLevel:
            trig_lvl = tag_value.Value.ValueFloat
            print("  -%27s : %7.3f V" %
                  (tag_name.value.decode("utf-8"), trig_lvl))
        elif tag_value.Tag == PDLM_TAG_PulseShape:
            pdlm_lib.PDLM_DecodePulseShape(tag_value.Value.ValueUInt,
                                           buf, ct.c_uint(STD_BUFFER_LEN -1))
            print("  -%27s : %3d  ==>  \"%s\"" %
                  (tag_name.value.decode("utf-8"), tag_value.Value.ValueUInt,
                   buf.value.decode("utf-8")))
        elif tag_type.value == PDLM_TAGTYPE_SINGLE:
            print("  -%27s : %f" %
                  (tag_name.value.decode("utf-8"), tag_value.Value.ValueFloat))
        elif tag_type.value >= PDLM_TAGTYPE_INT:
            print("  -%27s : %d" %
                  (tag_name.value.decode("utf-8"), tag_value.Value.ValueInt))
        else:
            print("  -%27s : %u" %
                  (tag_name.value.decode("utf-8"), tag_value.Value.ValueUInt))

def int_get_unit_prefix(x, unit):
    i = PREFIX_ZEROIDX
    while (x % 1000 == 0) and (i < len(UNIT_PREFIX)-1):
        x /= 1000
        i += 1
    whole_string = "%d%2s%s" % (x, UNIT_PREFIX[i], unit)
    return whole_string

def float_get_unit_prefix(x, unit):
    i = PREFIX_ZEROIDX
    if int(x) == 0:
        while (int(x) == 0) and (i > 0):
            x *= 1000
            i -= 1
    else:
        while (int(x) % 1000 == 0) and (i < len(UNIT_PREFIX)-1):
            x /= 1000
            i += 1
    whole_string = "%.3f%2s%s" % (x, UNIT_PREFIX[i], unit)
    return whole_string

def check_ret_value(func_name, ret, allowed_ret_vals, error_msg):
    if (ret != PDLM_ERROR_NONE) and (ret not in allowed_ret_vals):
        if error_msg:
            print("[ERROR] %s" % error_msg)
        error_text = ct.create_string_buffer(b"", STD_BUFFER_LEN)
        buffer_len = ct.c_uint(STD_BUFFER_LEN)
        pdlm_lib.PDLM_DecodeError(ret, error_text, byref(buffer_len))
        error_text = error_text.value.decode("utf-8")
        print("[ERROR] %d occured in \"%s\"" % (ret, func_name))
        print("[ERROR] %s" % error_text)
        pdlm_lib.PDLM_CloseDevice(USB_idx)
        exit(ret)
    return ret

def calc_temp(scale_idx, raw_value):
    if scale_idx == PDLM_TEMPERATURESCALE_FAHRENHEIT:
        return (0.18*raw_value + 32)
    if scale_idx == PDLM_TEMPERATURESCALE_CELSIUS:
        return 0.1*raw_value
    if scale_idx == PDLM_TEMPERATURESCALE_KELVIN:
        return (0.1*raw_value + 273.1)

def main():
    global USB_idx
    global temp_scale
    print("\n PDL-M1 \"Taiko\"  Demo Application  \u00A9 2018 by PicoQuant GmbH, Keno Goertz")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    lib_version = ct.create_string_buffer(b"", STD_BUFFER_LEN)
    check_ret_value("PDLM_GetLibraryVersion",
                    pdlm_lib.PDLM_GetLibraryVersion(lib_version, STD_BUFFER_LEN),
                    [], None)
    lib_version = lib_version.value.decode("utf-8")
    print("  [ Python ] %47s%s\n" % ("Library version: ", lib_version))

    driver_name = ct.create_string_buffer(b"", STD_BUFFER_LEN)
    driver_version = ct.create_string_buffer(b"", STD_BUFFER_LEN)
    driver_date = ct.create_string_buffer(b"", STD_BUFFER_LEN)
    check_ret_value(
        "PDLM_GetUSBDriverInfo",
        pdlm_lib.PDLM_GetUSBDriverInfo(
            driver_name, STD_BUFFER_LEN,
            driver_version, STD_BUFFER_LEN,
            driver_date, STD_BUFFER_LEN
        ), [], None
    )
    driver_name = driver_name.value.decode("utf-8")
    driver_version = driver_version.value.decode("utf-8")
    driver_date = driver_date.value.decode("utf-8")
    print("  USB-Driver Service: '%s'; V%s, %s\n"
          % (driver_name, driver_version, driver_date))

    USB_idx = -1
    for i in range(PDLM_MAX_USBDEVICES):
        buf = ct.create_string_buffer(b"", STD_BUFFER_LEN)
        ret = check_ret_value("PDLM_OpenGetSerNumAndClose",
                              pdlm_lib.PDLM_OpenGetSerNumAndClose(ct.c_int(i), buf),
                              ERRORS_ON_OPEN_ALLOWED, None)
        if (ret != PDLM_ERROR_USB_UNKNOWN_DEVICE) and \
                (ret != PDLM_ERROR_OPEN_DEVICE_FAILED):
            if ret == PDLM_ERROR_NONE and USB_idx < 0:
                USB_idx = i
            switcher = {
                PDLM_ERROR_DEVICE_BUSY_OR_BLOCKED: "(busy)",
                PDLM_ERROR_USB_INAPPROPRIATE_DEVICE: "(inappropriate)",
                PDLM_ERROR_DEVICE_ALREADY_OPENED: "(already opened)",
                PDLM_ERROR_NONE: "(ready to run)"
            }
            print("  USB-Index %d: PDL-M1 with serial number %s found %s" %
                  (i, buf.value.decode("utf-8"), switcher.get(ret)))
    if USB_idx < 0:
        print("  No PDL-M1 found.")
        exit(0)

    USB_idx = ct.c_int(USB_idx)
    check_ret_value("PDLM_OpenDevice",
                    pdlm_lib.PDLM_OpenDevice(USB_idx, buf),
                    [], "  Can't open device.")
    print("  USB-Index %d: PDL-M1 opened.\n" % USB_idx.value)

    check_ret_value("PDLM_GetFWVersion",
                    pdlm_lib.PDLM_GetFWVersion(USB_idx, buf, ct.c_uint(len(buf))),
                    [], "  Can't retrieve FW version.")
    print("  - FW   : %s" % buf.value.decode("utf-8"))
    check_ret_value("PDLM_GetFGPAVersion",
                    pdlm_lib.PDLM_GetFPGAVersion(USB_idx, buf, ct.c_uint(len(buf))),
                    [], "  Can't retrieve FPGA version.")
    print("  - FPGA : %s" % buf.value.decode("utf-8"))
    check_ret_value("PDLM_GetLHVersion",
                    pdlm_lib.PDLM_GetLHVersion(USB_idx, buf, ct.c_uint(len(buf))),
                    [], "  Can't retrive LH version.")
    print("  - LH   : %s\n" % buf.value.decode("utf-8"))
    
    # Lock the GUI as long as we are working with it
    check_ret_value("PDLM_SetExclusiveUI",
                    pdlm_lib.PDLM_SetExclusiveUI(USB_idx, ct.c_uint(PDLM_UI_EXCLUSIVE)),
                    [], "  Can't lock the device GUI.")
    
    ui_status = ct.c_uint()
    check_ret_value("PDLM_GetSystemStatus",
                    pdlm_lib.PDLM_GetSystemStatus(USB_idx, byref(ui_status)),
                    [], "  Can't read system status.")
    # Interpret the system status code:
    print("  Laser is%slocked by On/Off Button" %
          (" " if (PDLM_DEVSTATE_LOCKED_BY_ON_OFF_BUTTON & ui_status.value > 0) else " NOT "))
    print("  Laser is%slocked by key\n" %
          (" " if (PDLM_DEVSTATE_KEYLOCK & ui_status.value > 0) else " NOT "))
    
    # Laser head info is in a struct that is defined here:
    class TLaserInfo(ct.Structure):
        _fields_ = [
            ("LType", ct.c_char*PDLM_LDH_STRING_LENGTH),
            ("Date", ct.c_char*PDLM_LDH_STRING_LENGTH),
            ("LClass", ct.c_char*PDLM_LDH_STRING_LENGTH)
        ]
    lh_info = TLaserInfo()
    check_ret_value("PDLM_GetLHInfo",
                    pdlm_lib.PDLM_GetLHInfo(USB_idx, byref(lh_info), ct.sizeof(lh_info)),
                    [], "  Can't get laser head info.")
    print("  Connected laser head:")
    print("  - laser head type       : %s" % lh_info.LType.decode("utf-8"))
    print("  - date of manufacturing : %s" % lh_info.Date.decode("utf-8"))
    print("  - laser power class     : %s" % lh_info.LClass.decode("utf-8"))
    
    # Laser head data is in a struct
    lh_data = ct.c_buffer(b"", 52)
    check_ret_value("PDLM_GetLHData",
                    pdlm_lib.PDLM_GetLHData(USB_idx, lh_data, len(lh_data)),
                    [], "  Can't get laser head data.")
    freq_min = int.from_bytes(lh_data.raw[8:12], byteorder="little", signed=False)
    freq_max = int.from_bytes(lh_data.raw[12:16], byteorder="little", signed=False)
    print("  - frequency range       : %7s - %7s\n" %
          (int_get_unit_prefix(freq_min, "Hz"), int_get_unit_prefix(freq_max, "Hz")))

    # Get current temperature scale
    temp_scale = ct.c_uint()
    check_ret_value("PDLM_GetTempScale",
                    pdlm_lib.PDLM_GetTempScale(USB_idx, byref(temp_scale)),
                    [], "  Cannot get current temperature scale.")
    
    # Set laser mode to pulsed
    check_ret_value("PDLM_SetLaserMode",
                    pdlm_lib.PDLM_SetLaserMode(USB_idx, PDLM_LASER_MODE_PULSE),
                    [], "  Can't set laser mode to pulsed.")
    freq_cur = ct.c_uint()
    check_ret_value("PDLM_GetFrequency",
                    pdlm_lib.PDLM_GetFrequency(USB_idx, byref(freq_cur)),
                    [], "  Can't get frequency.")
    print("  Frequency currently set : %7s" % int_get_unit_prefix(freq_cur.value, "Hz"))
    
    # Set frequency to 10 MHz if in range for this head
    freq_set = ct.c_uint(int(1e7)) if freq_min < 1e7 and 1e7 < freq_max else freq_cur
    check_ret_value("PDLM_SetFrequency",
                    pdlm_lib.PDLM_SetFrequency(USB_idx, freq_set),
                    [], "  Can't set frequency.")
    print("  Frequency now set to    : %7s" % int_get_unit_prefix(freq_set.value, "Hz"))
    
    # Set optical power in permille (you can change this)
    power_permille = ct.c_uint(50) # 5.0%
    check_ret_value("PDLM_SetPulsePowerPermille",
                    pdlm_lib.PDLM_SetPulsePowerPermille(USB_idx, power_permille),
                    [], "  Can't set pulse power.")
    # Read the resulting power in W
    power = ct.c_float()
    check_ret_value("PDLM_GetPulsePower",
                    pdlm_lib.PDLM_GetPulsePower(USB_idx, byref(power)),
                    ERRORS_ALLOWED_ON_EXT_TRIG, "  Can't set pulse power.")
    print("  Pulse power set to      : %5.1f %%  ==>  %s\n" %
          (0.1 * power_permille.value, float_get_unit_prefix(power.value, "W")))
    
    # One can also get the information via a TagList all together with one call
    # using the TValueType union and TTagValue struct
    tag_list = (TTagValue * MAX_TAGLIST_LEN)()
    list_len = ct.c_uint(10)
    tag_list[0].Tag = PDLM_TAG_Frequency;
    tag_list[1].Tag = PDLM_TAG_TempScale;
    tag_list[2].Tag = PDLM_TAG_TargetTemp;
    tag_list[3].Tag = PDLM_TAG_TriggerLevel;
    tag_list[4].Tag = PDLM_TAG_LDH_PulsePowerTable;
    tag_list[5].Tag = PDLM_TAG_PulsePowerHiLimit;
    tag_list[6].Tag = PDLM_TAG_PulsePowerPermille;
    tag_list[7].Tag = PDLM_TAG_PulsePower;
    tag_list[8].Tag = PDLM_TAG_PulseShape;
    tag_list[9].Tag = PDLM_TAG_NONE # every list must finish with a PDLM_TAG_NONE as last entry
    
    check_ret_value("PDLM_GetTagValueList",
                    pdlm_lib.PDLM_GetTagValueList(USB_idx, list_len, tag_list),
                    [], "  Can't get values via TagList.")
    print("  Got via TagList:")
    for i in range(list_len.value-1):
        print_tag_value(tag_list[i])
    
    # Unlock the device GUI and ask user to change something
    check_ret_value("PDLM_SetExclusiveUI",
                    pdlm_lib.PDLM_SetExclusiveUI(USB_idx, ct.c_uint(PDLM_UI_COOPERATIVE)),
                    [], "  Can't unlock the device GUI.")
    # Wait a little bit, clear pending changes
    time.sleep(0.1)
    list_len = ct.c_uint(MAX_TAGLIST_LEN)
    tag_list = (TTagValue * MAX_TAGLIST_LEN)()
    check_ret_value("PDLM_GetQueuedChanges",
                    pdlm_lib.PDLM_GetQueuedChanges(USB_idx, tag_list, byref(list_len)),
                    [], "  Can't get pending changes.")
    print("\n  Device GUI unlocked")
    
    while(True):
        is_changed = False
        c = input("\n  Change something on the device GUI or type 'x' to leave, and hit return > "); print()
        continue_execution = False if c == 'x' else True
        if not continue_execution:
            break
        list_len = ct.c_uint(MAX_TAGLIST_LEN)
        tag_list = (TTagValue * MAX_TAGLIST_LEN)()
        check_ret_value("PDLM_GetQueuedChanges",
                        pdlm_lib.PDLM_GetQueuedChanges(USB_idx, tag_list, byref(list_len)),
                        [], "  Can't get pending changes.");
        print("  Changes as got via TagList:")
        for i in range(list_len.value):
            if tag_list[i].Tag != PDLM_TAG_NONE:
                print_tag_value(tag_list[i])
                is_changed = True
        if not is_changed:
            print("  - No changes detected.")
    pdlm_lib.PDLM_CloseDevice(USB_idx)

if __name__ == "__main__":
    global USB_idx
    try:
        main()
    except Exception as e:
        if USB_idx.value >= 0:
            pdlm_lib.PDLM_CloseDevice(USB_idx)
        raise(e)
