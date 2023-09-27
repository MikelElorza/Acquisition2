# sys.path.append('C:\\Users\\NEXT-BOLD\\Documents\\SERGIO\\FilterWheel')
# sys.path.append('C:\\Users\\NEXT-BOLD\\Documents\\SERGIO\\FilterWheel\\Thorlabs_FWxC_PythonSDK\\')

from FilterWheel.Thorlabs_FWxC_PythonSDK.FWxC_COMMAND_LIB import *
import matlab.engine

def connectLowFilters():
    """Connect Short λ filter wheel
    Controlled by python engine"""
    devs = FWxCListDevices()
    #print(devs[0][0])
    if(len(devs)<=0):
        print('There are no devices connected')

    FWxC= devs[0]
    return FWxC

def Start_Low_FilterWheel(serialNumber):
   hdl = FWxCOpen(serialNumber,115200,3)
   #or check by "FWxCIsOpen(devs[0])"
   print('hdl = ', hdl)
   if(hdl < 0):
       print("Connect ",serialNumber, "fail" )
       #FWxCClose(hdl)
       return -1;
   #else:
#       print("Connect ",serialNumber, "successful")
#       print("hdl: ", hdl)
   print('Is open, ', FWxCIsOpen(serialNumber))
   return hdl

def move_LowFilterWh(newpos, hdl):
     flagSet = FWxCSetPosition(hdl, int(newpos))

     if(flagSet<0):
         print("Set Position Mode fail" , flagSet)
     position=[0]
     result, position = FWxCGetPosition(hdl,position)
     if(result<0):
        print("Get Position fail",result)

def start_HighFilters(eng):
    """Connect Long λ filter wheel
    Controlled by matlab engine"""
    h_filters = eng.startFiltersPy(0, nargout=1)
    return h_filters


