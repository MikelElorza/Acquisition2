from zaber_motion import Library
from zaber_motion.binary import Connection
from zaber_motion.gcode import OfflineTranslator
from zaber_motion import ascii as ASCII

from zaber_motion import Units
Library.enable_device_db_store()

def start_drives(com='COM6'):
    """Connect x_drive and y_drive, using ASCII communication protocol
        Return:
        conn: connection object
        xdrive, ydrive: motor objects
    """

    conn = ASCII.Connection.open_serial_port(com)
    devList = conn.detect_devices()
    print('Found {} devices'.format(devList[0]))
    xdrive = devList[0].get_axis(1)
    ydrive = devList[1].get_axis(1)
    return conn, xdrive, ydrive

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
    return connz, zdrive
