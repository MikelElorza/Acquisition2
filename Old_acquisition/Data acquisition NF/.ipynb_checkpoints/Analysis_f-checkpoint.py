import os
import numpy as np
import matplotlib.pyplot as plt
import copy

LLDpath=os.environ['JLASERDATA']
wls=np.array([400.0, 438.0, 503.0, 549.0, 575.0, 600.0, 630.0, 676.0, 732.0, 810.0])
wws=np.array([40.0, 24.0,   40.0,   17.0,  15.0,  14.0,  38.0,  29.0,  68.0,  10.0])
qe=np.array([0.4,0.55,0.77,0.83,0.82,0.82,0.81,0.75,0.65,0.48])

def to_pe(im,b):
    return (im-b**2*100)*0.46


def Get_samplepath(sample):
    return LLDpath+'/Proyectos/data/Data1/'+sample+'/'

def Get_scanpath(sample,scan):
    spath=Get_samplepath(sample)
    mpath=spath+'Microscope/Narrow Field/SCANS/'+scan+'/'
    return mpath

def Get_pbpath(sample,pb):
    spath=Get_samplepath(sample)
    mpath=spath+'Microscope/Narrow Field/PHOTOBLEACHING/'+pb+'/'
    return mpath

def Get_scan_info(runpath):
    f=open(runpath+'Measurement_description.txt')
    rname=f.readline()[:-1].split(':')[-1]
    ba=f.readline()[:-1].split(':')[-1]
    texp_im=float(f.readline()[:-1].split(':')[-1])
    texp_f=float(f.readline()[:-1].split(':')[-1])
    binning=int(f.readline()[:-1].split(':')[-1])
    setup=f.readline()[:-1].split(':')[-1]
    descr=f.readline()[:-1].split(':')[-1]
    
    print('SCAN INFO')
    print('________________')
    print('Scan name: {}'.format(rname))
    print('Ba: {}'.format(ba))
    print('Exposure time for imaging: {}'.format(texp_im))
    print('exposure time for focusing: {}'.format(texp_f))
    print('Binning: {}'.format(binning))
    print('Setup: {}'.format(setup))
    print('Description: {}'.format(descr))
    
    return rname,ba,texp_im,texp_f,binning,setup,descr

def Get_photobleaching_info(runpath):
    f=open(runpath+'Measurement_description.txt')
    filt=f.readline()[:-1].split(':')[-1]
    texp=float(f.readline()[:-1].split(':')[-1])
    wait=float(f.readline()[:-1].split(':')[-1])
    N=int(f.readline()[:-1].split(':')[-1])
    y,z,x=f.readline()[:-1].split(':')[-1].split(',')
    binning=int(f.readline()[:-1].split(':')[-1])    
    print('Photobleaching INFO')
    print('________________')
    print('Filter: {}'.format(filt))
    print('Exposure time: {}'.format(texp))
    print('Time between frames: {}'.format(wait))
    print('Binning: {}'.format(binning))
    print('Number of frames: {}'.format(N))
    print('Y,Z,X: {}'.format(float(y),float(z),float(y)))
    return filt,texp,wait,N,float(y),float(z),float(y),binning

def Get_sample_info(sample):
    samplepath=Get_samplepath(sample)
    f=open(samplepath+'Sample_description.txt')
    name=f.readline()[:-1].split(':')[-1]
    mol=f.readline()[:-1].split(':')[-1]
    subs=f.readline()[:-1].split(':')[-1]
    dep=f.readline()[:-1].split(':')[-1]
    descr=f.readline()[:-1].split(':')[-1]
    
    print('SAMPLE INFO')
    print('________________')
    print('Sample name: {}'.format(name))
    print('Molecule: {}'.format(mol))
    print('Substrate: {}'.format(subs))
    print('Deposition method: {}'.format(dep))
    print('Description: {}'.format(descr))

    return name,mol,subs,dep,descr

def Get_image(runpath,point,filt):
    pointpath=runpath+'Point{}/'.format(point)
    files=os.listdir(pointpath+'Images/')
    im=[file for file in files if 'F{}'.format(filt) in file][0]
    p=pointpath+'Images/'+im
    f=np.loadtxt(p)
    return f

def Get_dark(runpath,point,filt):
    pointpath=runpath+'Point{}/'.format(point)
    files=os.listdir(pointpath+'Darks/')
    im=[file for file in files if 'F{}'.format(filt) in file][0]
    p=pointpath+'Darks/'+im
    f=np.loadtxt(p)
    return f

def Im_dark(runpath,point,filt):
    pointpath=runpath+'Point{}/'.format(point)
    im=Get_image(runpath,point,filt)
    d=Get_dark(runpath,point,filt)
    return im-d

def Get_power(runpath,point):
    pointpath=runpath+'Point{}/'.format(point)
    p=pointpath+'Power'
    f=np.loadtxt(p)
    return f

def Photobleaching_power(runpath,filt):
    p=runpath+'/Filter{}/Power'.format(filt)
    pt=np.loadtxt(p)
    return pt

def Photobleaching_im(runpath,n,filt,b):
    pp=runpath+'Filter{}/'.format(filt)
    files=os.listdir(pp)
    ims=[file for file in files if file[0:3]=='Exp']
    im=[img for img in ims if int(img.split('_')[-1])==n][0]
    im=to_pe(np.loadtxt(pp+str(im)),b)
    return im

def Photobleaching(runpath,filt,roi,b):
    suma=np.array([])
    p=runpath+'Filter{}/'.format(filt)
    files=os.listdir(p)
    ims=[file for file in files if file[0:3]=='Exp']
    for i in range(0,len(ims)):
        im=[img for img in ims if int(img.split('_')[-1])==i][0]
        im=np.loadtxt(p+str(im))[roi[0]:roi[1],roi[2]:roi[3]]
        im=to_pe(im,b)
        suma=np.append(suma,np.sum(im))
    return suma

def Get_mask(im,thresh):
    mask=im>thresh
    return mask

def Get_point_focus(runpath,point):
    pointpath=runpath+'Point{}/'.format(point)
    data=np.loadtxt(pointpath+'Focusing.txt')
    return data

def Get_positions(runpath):
    poss=np.loadtxt(runpath+'Positions.txt')
    return poss

def Samples():
    sp=LLDpath+'/Proyectos/data/Data1/'
    return os.listdir(sp)

def Scans(sample):
    samplepath=Get_samplepath(sample)
    mp=samplepath+'Microscope/Narrow Field/SCANS/'
    return os.listdir(mp)

def PBs(sample):
    samplepath=Get_samplepath(sample)
    mp=samplepath+'Microscope/Narrow Field/PHOTOBLEACHING/'
    return os.listdir(mp)

def Charge(runpath,point,thresh,b):
    im0=Im_dark(runpath,point,0)
    mask=Get_mask(im0,thresh)
    s=np.array([])
    for filt in range (1,11):
        im=Im_dark(runpath,point,filt)*mask
        s=np.append(s,np.sum(im))
    return s[1:]

def Ppwrs(runpath,points):
    ppwrs=np.array([])
    for point in points:
        p,t=Get_power(runpath,point)
        ppwr=np.max(p)
        ppwrs=np.append(ppwrs,ppwr)
    return ppwrs


def plot_spectrum(wls,wws,sw,lbl):
    plt.errorbar(wls,sw,xerr=np.array(wws)/2,yerr=np.sqrt(wls),elinewidth=1,capsize=3,ecolor='k',label='Point{}'.format(lbl))
    plt.scatter(wls,sw,marker='x',color='k')
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Counts/nm')
    plt.legend()

def plot_spectrums(wls,wws,ss,points,scale='linear'):
    for i,point in enumerate(points):
        sw=ss[i]
        plt.errorbar(wls,sw,xerr=np.array(wws)/2,yerr=np.sqrt(wls),elinewidth=1,capsize=3,ecolor='k',label='Point{}'.format(point))
        plt.scatter(wls,sw,marker='x',color='k')
    plt.xlabel('Wavelength (nm)')
    plt.ylabel('Counts/nm (normalized with power)')
    plt.legend()
    plt.yscale(scale)

# +
def Charges(runpath,points,thresh,b):
    chs=Charge(runpath,points[0],thresh,b)
    for point in points[1:]:
        ch=Charge(runpath,point,thresh,b)
        chs=np.vstack((chs,ch))
    return chs

def Spectrums(chs,ppwrs):
    ss=copy.copy(chs)
    for i,cp in enumerate(chs):
        ss[i]=cp/qe[1:]/wws[1:]/ppwrs[i]
    return ss
