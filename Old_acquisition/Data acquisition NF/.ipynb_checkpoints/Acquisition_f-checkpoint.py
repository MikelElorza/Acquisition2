import os
import numpy as np
from skimage.filters import median
import matplotlib.pyplot as plt
import time
import sys
LLDpath=os.environ['JLASERDATA']
sys.path.append(LLDpath+"/Proyectos/analysis/Analysis1/")
from AnalysisNF_f import *
datapath=LLDpath+'/Proyectos/data/Data1/'
setuppath='Proyectos/Setup/NF_setup0'

def create_folder(path):
    try: 
        os.mkdir(path) 
    except OSError as error: 
        print(error)  
        cont=input('Do you want to continue writting?')
        if cont in ['NO','No','no']:
            exit()
    return

def Autofocus(y,z,x0,x1,step,stp):
    stp.set_filter(0)
    stp.set_y(y)
    stp.set_z(z)
    x=x0
    xs=np.array([])
    arr=np.array([])
    stp.open_shutter()
    while (x<x1):
        f0=stp.frame()
        f=median(f0)
        maximo=np.max(f)
        arr=np.append(arr,maximo)
        xs=np.append(xs,x)
        x+=step/1000
        stp.set_x(x)
    stp.close_shutter()
    xs=xs[1:]
    arr=arr[1:]
    posfocus=xs[np.where(arr==np.max(arr))[0][0]]
    return xs,arr,posfocus

def Filter_frame(filt,stp):
    stp.set_filter(filt)
    stp.open_shutter()
    f=stp.frame()
    stp.close_shutter()
    return f  

def Dark(filt,stp):
    stp.set_filter(filt)
    f=stp.frame()
    return f

# +
def Photobleaching(sample,name,N,filt,waitT,stp):
    runpath=Get_pbpath(sample,name)
    create_folder(runpath)
    f = open(runpath+"Measurement_description.txt",'w')
    f.write('Filter:{}'.format(filt)+'\n')
    f.write('Exposure time for imaging:{}'.format(stp.get_exposure())+'\n')
    f.write('Time between images:{}'.format(waitT)+'\n')
    f.write('Number of frames:{}'.format(N)+'\n')
    f.write('Position (y,z,x): {},{},{}'.format(stp.get_y(),stp.get_z(),stp.get_x())+'\n')
    f.write("Binning:"+str(stp.get_binning())+'\n')
    f.write("Setup:"+setuppath+'\n')
    f.close()

    ppath=runpath+'Filter{}/'.format(filt)
    create_folder(ppath)
    Temporal_evolution(ppath,N,filt,waitT,stp)
    
    
    
# -

def Temporal_evolution(ppath,N,filt,waitT,stp):
    data=np.array([])
    stp.set_filter(filt)
    stp.open_shutter()
    stp.start_stream()
    time.sleep(5)
    for i in range(0,N):
        f=stp.frame()
        np.savetxt(ppath+'Exp{:.2f}_wait{}_{}'.format(stp.get_exposure(),waitT,i),f)
        data=np.append(data,np.sum(f))
        time.sleep(waitT)
    pt=stp.get_power()
    stp.close_stream()
    np.savetxt(ppath+'Power',pt)
    stp.close_shutter()
    return data   

def Scan(ys,zs,xf0,texp_f,texp_im,ran,sample,runame,stp):
    runpath=Get_scanpath(sample,runame)
    create_folder(runpath)
    f = open(runpath+"Measurement_description.txt",'w')
    f.write("Measurement name:{} \n".format(runame))
    ba=input('Has it Barium? (YES/NO)')
    f.write("Barium:{} \n".format(ba))
    f.write("Exposure time for imaging:"+str(texp_im)+'\n')
    f.write("Exposure time for focusing:"+str(texp_f)+'\n')
    f.write("Binning:"+str(stp.get_binning())+'\n')
    f.write("Setup:"+setuppath+'\n')
    face=input('Description:')
    f.write("Comments:"+face+'\n')
    f.close()
    ps = open(runpath+"Positions.txt",'w')
    i=1
    plt.figure()
    for yi in ys:
        for zi in zs:
            stp.set_exposure(texp_f)
            xs,arr,xfocus=Autofocus(yi,zi,xf0-ran/1000,xf0+ran/1000,1,stp)
            plt.plot(xs,arr)
            ps.write(str(yi)+' '+str(zi)+' '+str(xfocus)+'\n')
            stp.set_exposure(texp_im)
            Filter_loop(yi,zi,xfocus,i,runpath,stp)    
            np.savetxt(runpath+'Point{}/Focusing.txt'.format(i),np.array([xs,arr]),fmt='%.4f')
            i+=1
    ps.close()

def Filter_loop(y,z,x,i,path,stp):
    stp.set_y(y)
    stp.set_z(z)
    stp.set_x(x)
    ppath=path+'Point{}/'.format(i)
    dpath=path+'Point{}/Darks/'.format(i)
    impath=path+'Point{}/Images/'.format(i)
    create_folder(ppath)
    create_folder(dpath)
    create_folder(impath)  
    stp.close_stream()
    stp.start_stream()
    for filt in range(0,11):
        fd=Dark(filt,stp)
        fim=Filter_frame(filt,stp)
        np.savetxt(dpath+'BG_EXP{:.2f}_BIN{}_F{}'.format(stp.get_exposure(),stp.get_binning(),filt),fd,fmt='%i')
        np.savetxt(impath+'IMG_EXP{:.2f}_BIN{}_F{}'.format(stp.get_exposure(),stp.get_binning(),filt),fim,fmt='%i')
    pt=stp.get_power()
    np.savetxt(ppath+'Power',pt)
    stp.set_filter(0)
    stp.close_stream()       

def New_sample():
    Molecs=['None','G0','G0-Sl','G1','G1-Sl','G2','G2-Sl','Ir-Sl','Ru-Sl']
    Subs=['ITO','Quartz']
    Deps=['None','Evaporation','Spin Coating','Dip Coating']
    
    print('Write the name of the sample:')
    name=input()    
    
    samplepath=datapath+name
    create_folder(samplepath)
    f = open(samplepath+"/Sample_description.txt", "w")
    f.write("Name:"+name+'\n')
    
    print('Select molecule:')
    print(Molecs)
    mol=input()
    if mol not in Molecs:
        print('Molecule is not valid')
        f.close()
        return False
    print()
    print()
    
    f.write("Molecule:"+mol+'\n')
    
    print('Select substrate:')
    print(Subs)
    sub=input()
    if sub not in Subs:
        print('Substrate is not valid')
        f.close()
        return False
    print()
    
    f.write("Substrate:"+sub+'\n')
    
    print('Select deposition method:')
    print(Deps)
    dep=input()
    print()
    if dep not in Deps:
        print('Deposition method is not valid')
        f.close()
        return False
    
    f.write("Deposition method:"+dep+'\n')
    
    print('Add description (optional):')
    descr=input()
    print()
    f.write("Description:"+descr+'\n')
    f.close()
    
    create_folder(samplepath+'/Microscope')
    create_folder(samplepath+'/Microscope/Narrow Field')
    create_folder(samplepath+'/Microscope/Narrow Field/SCANS')
    create_folder(samplepath+'/Microscope/Narrow Field/PHOTOBLEACHING')
    create_folder(samplepath+'/Microscope/Wide Field')


