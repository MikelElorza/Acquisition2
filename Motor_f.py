# -*- coding: utf-8 -*-
"""
Created on Thu Sep 14 10:04:36 2023

@author: Mikel
"""

import time
import numpy as np
import sys
sys.path.append('Devices/PDXC/Thorlabs_PDXC_PythonSDK')
import Piezo_f as pz

sys.path.append('Devices/Zaber')
import Zaber_f as zb

def connectX():
    return pz.connect_stage(0)

def connectY():
    return pz.connect_stage(1)

def connectZ():
    return zb.connectZdrive()

def move_abs_z(handle,z):
    return zb.moveZ_abs(handle,z)

def move_abs_xy(handle,pos):
    pz.move_abs(handle,pos)

def move_rel_z(handle,dz):
    return zb.moveZ_rel(handle,z)

def move_rel_xy(handle,dx):
    pz.move_rel(handle,pos)
    

def Z_scan(handle,z0,zf,N,wait):
    zs=np.linspace(z0,zf,N)
    for zi in zs:
        move_abs_z(handle,zi)
        time.sleep(wait)
    return True

def XY_scan(handlex,handley,x0,xf,Nx,y0,yf,Ny,wait):
    
    #Create the scanning pattern (it is important to be ordered to minimize displacements)
    xs=np.linspace(x0,xf,Nx)
    ys=np.linspace(y0,yf,Ny)
    XY=np.meshgrid(xs,ys)
    Order=np.zeros_like(XY[0])
    for i in range(0,np.shape(XY[0])[0]):
        for j in range(0,np.shape(XY[0])[1]):
            if j%2==0:
                Order[i,j]=i+Ny*j
            else:
                Order[i,j]=Nx-i-1+Ny*j
    xx,yy,o=XY[0].flatten(),XY[1].flatten(),Order.flatten()
    xsorted=[x for _, x in sorted(zip(o,xx))]
    ysorted=[x for _, x in sorted(zip(o, yy))]
    pairs=np.vstack((xsorted,ysorted)).T
    # The points of the scan are saved at pairs (ordered)
    
    for point in pairs:
        move_abs_xy(handlex,point[0])
        move_abs_xy(handley,point[1])
        time.sleep(wait)
                
    return True
        
        