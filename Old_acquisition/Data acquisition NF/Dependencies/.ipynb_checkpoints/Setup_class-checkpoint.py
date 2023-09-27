import sys
sys.path.append("./Dependencies/")
import filter_wheels as fw
from zaber_motion import Units
import numpy as np
class Setup:
    def __init__(self, cam0, eng, h_filters,h_rotor, shutter,
                 xdrive, ydrive, zdrive,Pmeter, DeviceHandle, hdl: int = 0):
        self.cam0 = cam0
        self.eng = eng
        self.h_filters = h_filters
        self.h_rotor = h_rotor
        self.shutter = shutter
        self.xdrive = xdrive
        self.ydrive = ydrive
        self.zdrive = zdrive
        self.hdl = hdl
        self.Nfilter=12
        self.Pmeter=Pmeter
        self.DeviceHandle=DeviceHandle
        self.close_shutter()
        self.rotation(0)
        self.set_filter(0)
        self.set_x(0)
        self.set_y(0)
        self.set_z(0)
    def get_exposure(self):
        return self.cam0.get_attribute_value("EXPOSURE TIME")
    def set_exposure(self,texp):
        self.cam0.set_attribute_value("EXPOSURE TIME",texp)
    def get_binning(self):
        return self.cam0.get_attribute_value("BINNING")
    def frame(self):
        texp=self.get_exposure()
        return self.cam0.snap(timeout=texp+1)
    def set_x(self,pos):
        self.xdrive.move_absolute(pos, Units.LENGTH_MILLIMETRES)
    def get_x(self):
        return self.xdrive.get_position(Units.LENGTH_MILLIMETRES)
    def set_y(self,pos):
        self.ydrive.move_absolute(pos, Units.LENGTH_MILLIMETRES)
    def get_y(self):
        return self.ydrive.get_position(Units.LENGTH_MILLIMETRES)
    def set_z(self,pos):
        self.zdrive.move_absolute(pos, Units.LENGTH_MILLIMETRES)
    def get_z(self):
        return self.zdrive.get_position(Units.LENGTH_MILLIMETRES)
    def open_shutter(self):
        self.eng.openShutterPy(self.shutter, nargout=0)
    def close_shutter(self):
        self.eng.closeShutterPy(self.shutter, nargout=0)
    def set_filter(self,N):
        #N goes from 0 to 11
        # 0 is no filter
        if N<6:
            fw.move_LowFilterWh(N+1, self.hdl)
            self.eng.moveFilterPy(self.h_filters, 0, nargout=0)
        if (N>=6)and(N<12):
            fw.move_LowFilterWh(1, self.hdl)
            self.eng.moveFilterPy(self.h_filters, N-5, nargout=0)
    def rotation(self,alpha):
        return self.eng.movePolarizerPy(self.h_rotor,alpha,nargout=0)
    '''def get_power(self):
        self.Pmeter.StartStream(DeviceHandle, 0)
        time.sleep(2)
        data = self.Pmeter.GetData(self.DeviceHandle, 0)
        self.Pmeter.StopAllStreams()
        return [data[0],data[1]]'''
    def start_stream(self):
        self.Pmeter.StartStream(self.DeviceHandle, 0)
    def close_stream(self):
        self.Pmeter.StopAllStreams()
    def get_power(self):
        data = self.Pmeter.GetData(self.DeviceHandle, 0)
        return np.array(data[0]),np.array(data[1])


