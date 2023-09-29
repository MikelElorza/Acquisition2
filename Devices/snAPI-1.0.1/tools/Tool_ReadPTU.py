from snAPI.Main import *

if(__name__ == "__main__"):

    # PTU data
    start = 0
    length = 10
    
    sn = snAPI()
    #sn.getFileDevice(r"C:\Data\PicoQuant\default.ptu")
    sn.getFileDevice(r'Q:\090_SPAD-Array\Q_Sicherung\F7-10-T2G1\35_C_1h_-500mV.ptu')
    sn.getDeviceConfig()
    sn.logPrint(json.dumps(sn.deviceConfig, indent=2))
    
    sn.getMeasDescription()
    sn.logPrint(json.dumps(sn.measDescription, indent=2))
    
    sn.unfold.measure(acqTime=1000, size=int(sn.measDescription["NumRecs"]), waitFinished=True)
    times, channels  = sn.unfold.getData()
    sn.logPrint(f"Unfold data records: {len(times)}")
    sn.logPrint("  channel |  absTime") 
    sn.logPrint("--------------------")
    
    for i in range(start,start+length):
        sn.logPrint(f"{channels[1000000000+i]:9} | {times[i]:8}")