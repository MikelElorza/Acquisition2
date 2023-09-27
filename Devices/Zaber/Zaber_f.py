from zaber_motion import Library
from zaber_motion.binary import Connection
from zaber_motion.gcode import OfflineTranslator
from zaber_motion import ascii as ASCII
from zaber_motion import Units
Library.enable_device_db_store()

def connectZdrive(com='COM5'):
    """Connect z_drive, using binary communication protocol
        Return:
        connz: connection object
        zdrive: motor object
    """
    connz = Connection.open_serial_port(com)
    devList = connz.detect_devices()
    print('Found {} devices'.format(devList[0]))
    zdrive = devList[0]
    zdrive.home()
    print("-Homed-")
    return [connz, zdrive]
def moveZ_abs(handle,pos):
    handle[1].move_absolute(pos, Units.LENGTH_MILLIMETRES)
    
def moveZ_relative(handle,pos):
    handle[1].move_relative(pos, Units.LENGTH_MILLIMETRES)
def closeZ(handle):
    handle[0].close()