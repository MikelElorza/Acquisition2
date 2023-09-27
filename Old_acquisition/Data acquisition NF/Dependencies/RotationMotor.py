from FilterWheel.Thorlabs_FWxC_PythonSDK.FWxC_COMMAND_LIB import *
import matlab.engine


def start_Rotor(eng):
    """Connect Polarizer
    Controlled by matlab engine"""
    h_polarizer = eng.startPolarizerPy(0, nargout=1)
    return h_polarizer

def move_Rotor(eng,h_polarizer,n):
#    eng.addpath('C:\\Users\\NEXT-BOLD\\Documents\\SERGIO\\Autofocus ');
    eng.movePolarizerPy(h_polarizer,n,nargout=0)   
