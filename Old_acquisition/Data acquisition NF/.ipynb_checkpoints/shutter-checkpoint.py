""" Note: to avoid redefining the matlab engine (eng),
    it is only defined in filter_wheels.start_HighFilters().
    Also, because importing this engine is quite slow """

def connectShutter(eng):
    """This connects the shutter and opens it by default"""
    h_shutter = eng.startShutterPy(nargout=1)
    return h_shutter

def open_shutter(eng, h_shutter):
    eng.openShutterPy(h_shutter, nargout=0)

def close_shutter(eng, h_shutter):
    eng.closeShutterPy(h_shutter, nargout=0)
