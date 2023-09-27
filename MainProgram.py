# -*- coding: utf-8 -*-
"""
Created on Thu Sep 14 09:08:33 2023

@author: Mikel
"""

from PDXC_COMMAND_LIB import pdxc
import TaikoON_OFF as tk
from snAPI.Main import *

sn = snAPI()
sn.getDevice(libType=LibType.HH)