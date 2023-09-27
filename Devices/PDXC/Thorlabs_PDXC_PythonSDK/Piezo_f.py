import numpy as np
from PDXC_COMMAND_LIB import pdxc
import time
def setting(pdxcobj):
    print("-- Stage settings --")

    # closed loop #
    print("-  closed loop mode  -")
    result = pdxcobj.SetLoop(0, 0)
    if result < 0:
        print("set loop to closed loop failed", result)
    else:
        print("set loop to closed loop")

    print("-  Manual Mode  -")
    result = pdxcobj.SetCurrentStatusInExternalTrigger(0, "AR/AF")
    if result < 0:
        print("set trigger mode to manual mode failed", result)
    else:
        print("set trigger mode to manual mode")

    result = pdxcobj.SetPositionCalibration(0, 1)  # Under closed loop,stage must be homed before move and jog
    if result < 0:
        print("set PositionCalibration home failed", result)
    else:
        print("set PositionCalibration home")

    homed = [0]
    result = pdxcobj.GetCalibrationIsCompleted(0, homed)
    if result < 0:
        print("get CalibrationIsCompleted failed", result)
    else:
        print("get CalibrationIsCompleted: done")

    result = pdxcobj.SetTargetSpeed(0, 15)  # PDX1:2-20 mm/s; PDX2:1-10 mm/s; PDXR:10-30 °/s
    if result < 0:
        print("set TargetSpeed to 10 failed", result)
    else:
        print("set TargetSpeed to 10")

def connect_stage(i):
    print("---- Connecting PDXC motor ----")
    pdxcobj = pdxc()
    try:
        devs = pdxc.ListDevices()
        print("Devices="+str(devs))
        if len(devs) <= 0:
            print('There is no devices connected')
            exit()
        device_info = devs[i]
        sn = device_info[0]
        print("connect ", sn)
        hdl = pdxcobj.Open(sn, 115200, 3)
        if hdl < 0:
            print("open ", sn, " failed")
            exit()
        if pdxcobj.IsOpen(sn) == 0:
            print("pdxcIsOpen failed")
            pdxcobj.Close()
            exit()

        result = pdxcobj.SetDaisyChain(0)  # 0:Single Mode, 1:Main, 2 -12 : Secondary1 - Secondary11
        ty = [0]
        if pdxcobj.GetSpeedStageType(0, ty) < 0:
            print("pdxcGetSpeedStageType failed")
        else:
            sn2 = [0]
            pdxcobj.GetSN2(0, sn2)
            if ty[0] == 0:
                if 'PDXR' in str(sn2):
                    print("Found PDXR stage")
                elif "PDX1" in str(sn2):
                    print("Found PDX1 stage")
                else:
                    print("Found PDX2 stage")
                setting(pdxcobj)
    except Exception as e:
        print("Warning:", e)
    return pdxcobj
def move_abs(pdxcobj,pos):
    result=pdxcobj.SetTargetPosition(0, pos)
    if result < 0:
        return False
    else:
        return True

def move_rel(pdxcobj,dx):
    result=pdxcobj.SetStepPulseAndResponse(0, dx) ## in mm
    if result < 0:
        return False
    else:
        return True