#2014.10.17 by Huiyan (Winnie) Huang
#This version is for movies that run for variable times.

#This version was written after finalizing everything with Anne.
#Lethargus entry was defined as fractional Q (fQ) stays above 0.1 for at least 20min.
#Lethargus entry was further adjusted to be the first frame of the first bout from the 60 frames used to calculate fQ.
#Likewise, lethargus exit was defined as fQ stays below 0.1 for at least 20min.
#Lethargus exit was further adjusted to be the last frame of the last bout from the 60 frames used to calculate fQ.
#The entire lethargus was divided into early, middle, late, overrun1, and overrun2 (E, M, L, O1, O2).
#In order not to disrupt bouts, all bouts spanning two stages are included into both stages.
#Therefore, summary of all # of bouts from all five stages will not necessarily be equal to # of bouts for the entire lethargus.

import copy
import sys
import getopt
import os
import matplotlib.pyplot as plt

path=r'C:\Users\Hart_E5430\Desktop\Winnie\10 chamber analysis\2016.05.05.WH.L4440.cct-6.12h.P.txt'
ChamberN=8

#This module assigns the worm status with 1 (quiescent) or 0 (moving).
#It reads the path file into two lists:
#imagesubtraction data (imagesub[]) and 60 frame rolling average data (avg60[])
#However, only the imagesub[] is taken for all the following calculations.
#avg60[] applies the threshold of 5% max difference, which we do not follow at all.
def chamber(path):
        #path=r'D:Hart_lab\Results\Chamber\Matlabtxt\...'
        imagesub=[]
        avg60=[]
        f1=open(path)
        for line in f1:
                tmp=line.replace('\n','')
                tmp=tmp.split(',')
                tmp=map(float, tmp)
                imagesub.append(tmp[:ChamberN])
                if len(tmp)>10:
                        avg60.append(tmp[-ChamberN:])
        f1.close()
        inv_imagesub=[[item[i] for item in imagesub] for i in range(len(imagesub[0]))]
        inv_avg60=[[item[i] for item in avg60] for i in range(len(avg60[0]))]  
        wormstatus=[[(item==0)*1 for item in inv_imagesub[i]] for i in range(len(imagesub[0]))]
        return wormstatus


#This module is used to find all the ranges that the fractionalQ is above a certain threshold.
#Before using this module, datalist(fractionalQ) needs to be converted to a list with only 0's and 1's.
def stretches(datalist):
        start=[]
        end=[]
        try:
                start.append(datalist.index(1))
                for i in range(datalist.index(1)+1,len(datalist)):
                        if datalist[i]!=datalist[i-1]:
                                if datalist[i]==0:
                                        end.append(i-1)
                                else:
                                        start.append(i)
                if datalist[-1]==1:
                        end.append(len(datalist)-1)
                result=[(start[i],end[i]) for i in range(len(start))]
                return result
        except ValueError:
                return []

#This module merges all the ranges that have a gap less than a certain threshold, in this case, 119 frames (20min).
def mergeQ(inputQ,gapthld=119):
        if inputQ!=[]:
                Q2bcom=[inputQ[0]]
                for i in range(1,len(inputQ)):
                        if (inputQ[i][0]-Q2bcom[-1][1])<=gapthld:
                            Q2bcom[-1]=tuple([Q2bcom[-1][0],inputQ[i][-1]])
                        else:
                            Q2bcom.append(inputQ[i])
        else:
                Q2bcom=[(0,0)]
        return Q2bcom

#This module is used to calculate the area underneath the fractionQ curve.
def integralQ(inputindexQ,inputfractQ):
        tmpQ=[]
        if inputindexQ!=[]:
                for i in range(len(inputindexQ)):
                        tmpQ.append(sum(inputfractQ[inputindexQ[i][0]:inputindexQ[i][1]+1]))
        else:
                tmpQ=[0]
        return tmpQ

#This module divides the lethargus into five stages, each being 45min
#and calculates totalQ, average pause duration(s), total # of bouts and bout frequency(/h).
def divideStages(position_fQ,position_status,fraction,status):
        if position_fQ!=[0,0]:
                try:
                        bin_edges_fQ=range(position_fQ[0],len(fraction)+1,270) #position in fractQ[]
                except TypeError:
                        print position_fQ
                bin_edges_fQ=bin_edges_fQ[:6]
                Qstage=[sum(fraction[bin_edges_fQ[i]:bin_edges_fQ[i+1]])/6.0 for i in range(len(bin_edges_fQ)-1)]
                #This calculation does not correct the position for Qstages.
                #And Qentry takes the non-corrected position.
        else:
                return {'stage':[[]]*5,'duration':[[]]*5,'episodes':[[]]*5,'freq':[[]]*5,
                        'pauses':[[]]*5,'bin_edges_pairs':[[]]*5}
        
        if position_status!=[0,0]:
                try:
                        bin_edges=range(position_status[0],len(status)+1,270) #position in wormstatus[]
                except TypeError:
                        print position_status
                bin_edges=bin_edges[:6]
                bin_edges_pairs=zip(bin_edges[:-1],bin_edges[1:])
                bin_edges_pairs=[list(item) for item in bin_edges_pairs]
                for i in range(len(bin_edges_pairs)):
                        if status[bin_edges_pairs[i][0]-1]*status[bin_edges_pairs[i][0]]==1:
                                try:
                                        temp_status_before=status[:bin_edges_pairs[i][0]]
                                        temp_status_before.reverse()
                                        bin_edges_pairs[i][0]=bin_edges_pairs[i][0]-temp_status_before.index(0)
                                except ValueError:
                                        bin_edges_pairs=[]
                                        break
                        if status[bin_edges_pairs[i][1]-1]*status[bin_edges_pairs[i][1]]==1:
                                try:
                                        bin_edges_pairs[i][1]=status[bin_edges_pairs[i][1]:].index(0)+bin_edges_pairs[i][1]
                                except ValueError:
                                        bin_edges_pairs=[] 
                                        break
                #Qstage=[sum(fraction[item[0]:item[1]])/6.0 for item in bin_edges_pairs]
                #If Qstage is calculated according to the corrected stages, not disrupting episodes, use this calculation.
                StageStatus=[status[item[0]:item[1]] for item in bin_edges_pairs]
                Pauses=map(stretches, StageStatus)
                Qepisodes=map(len, Pauses)
                APD=[]
                for i in range(len(StageStatus)):
                        try:
                                APD.append(sum(StageStatus[i])*10.0/Qepisodes[i])
                        except ZeroDivisionError:
                                APD.append(float('Nan'))
                Qfreq=[]
                for i in range(len(StageStatus)):
                        try:
                                Qfreq.append(Qepisodes[i]*360.0/(bin_edges_pairs[i][1]-bin_edges_pairs[i][0]))
                        except ZeroDivisionError:
                                Qfreq.append(float('Nan'))
                #Qfreq is # of episodes divided by actual time instead of 45min

        else:
                return {'stage':[[]]*5,'duration':[[]]*5,'episodes':[[]]*5,'freq':[[]]*5,
                        'pauses':[[]]*5,'bin_edges_pairs':[[]]*5}
        return {'stage':Qstage+[[]]*5,'duration':APD+[[]]*5,'episodes':Qepisodes+[[]]*5,
                'freq':Qfreq+[[]]*5,'pauses':Pauses+[[]]*5,'bin_edges_pairs':bin_edges_pairs+[[]]*5}

#This module uses all the previous defined functions to analyze the quiescence in high resolution.
    #Definition of quiescence:
        #entry: fractional Q stays above 0.1 for at least 20min.
        #exit: fractional Q stays below 0.1 for at least 20min.
        #Qthld20min throws away all Q periods less than 20min and gives all Q periods that meet our Q definition.
        #Abnormal conditions include:
        #1) no entry of Q --> Q=0
        #2) miss the entry of Q --> Qentry=0 --> invalid data?
        #3) no exit of Q --> Qexit=11.994 --> invalid data?
        #4) multiple entries and exits --> define the max(correctedQ) as the real Q
        #5) control chamber --> Q=4260
    #The total duration of quiescence is divided into stages. Each stage contains 45min.
        #To cover most of the mutants, which will have more than 3hrs' lethargus, total of five stages are calculated.
        #For each stage, totalQ, average pause duration(s), total # of bouts and bout frequency(/h) is calculated. 
        #totalQ within stages is calculated without applying the 0.1 fractionalQ. This means animals can have Q outside the length of lethargus.        
        #Q episodes that span two stages--> do not split, expand the stage to include episodes spanning both edges
        

wormstatus=chamber(path)
#wormstatus=[item[:3000] for item in wormstatus]
#manually define the region you want to analyze your data by changing the values for [:3000]
fractQ=[[sum(item[i-60:i])/60.0 for i in range(60,len(wormstatus[0])+1)] for item in wormstatus]
totalQ=[sum(fractQ[i]) for i in range(len(fractQ))]

Qthld=0.1
fractQthld=[[(item>=Qthld)*1 for item in fractQ[i]] for i in range(len(fractQ))]
allQ=map(stretches,fractQthld)
allmergedQ=map(mergeQ,allQ)
Qthld20min=[[[((item[1]-item[0])>119)*jtem for jtem in item] for item in ktem] for ktem in allmergedQ]
allintegralQ=map(integralQ,Qthld20min,fractQ)
correctedQ=map(max,allintegralQ)
correctedQ_min=[item/6.0 for item in correctedQ]

indexQ=[allintegralQ[i].index(correctedQ[i]) for i in range(len(correctedQ))]
Qposition_fQ=[Qthld20min[i][indexQ[i]] for i in range(len(indexQ))]
Qposition_status=copy.deepcopy(Qposition_fQ)
for i in range(len(Qposition_status)):
        try:
                Qposition_status[i][0]=wormstatus[i][Qposition_status[i][0]:Qposition_status[i][0]+60].index(1)+Qposition_status[i][0]
                temp_60end=wormstatus[i][Qposition_status[i][1]:Qposition_status[i][1]+60]
                temp_60end.reverse()
                Qposition_status[i][1]=Qposition_status[i][1]+59-temp_60end.index(1)
        except ValueError:
                Qposition_status[i]=[0,0]
#Qposition_status is moved to the first episode of the 60 frames that gives the starting 0.1
#and last episode of the 60 frames that gives the ending 0.1.
Qentry=[Qposition_status[i][0]/360.0 for i in range(len(Qposition_status))]
Qexit=[Qposition_status[i][1]/360.0 for i in range(len(Qposition_status))]
Qduration=[(Qexit[i]-Qentry[i]) for i in range(len(Qentry))]
Leth_status=[wormstatus[i][Qposition_status[i][0]:Qposition_status[i][1]+1] for i in range(len(Qposition_status))]
#realQ=map(sum,Leth_status)
#realQ_min=[item/6.0 for item in realQ]
tQpauses=map(stretches,Leth_status)
tQepisodes=map(len,tQpauses)
tAPD=[]
for i in range(len(tQpauses)):
        try:
                tAPD.append(sum(Leth_status[i])*10.0/tQepisodes[i])
        except ZeroDivisionError:
                tAPD.append(float('Nan'))
tQfreq=[]
for i in range(len(tQpauses)):
        try:
                tQfreq.append(tQepisodes[i]/Qduration[i])
        except ZeroDivisionError:
                tQfreq.append(float('Nan'))
Leth_fractQ=[fractQ[i][Qposition_fQ[i][0]:Qposition_fQ[i][1]+1] for i in range(len(Qposition_fQ))]
peak_fQ=map(max,Leth_fractQ)

                                                
StageAnalysis=map(divideStages,Qposition_fQ,Qposition_status,fractQ,wormstatus)
titlelist=['name','entry/h','exit/h','duration/h','totalQ','corrected totalQ',
                'corrected totalQ/min','tAPD/s','t#','tQfreq','peak fQ',
                'Q E/min','Q M/min','Q L/min','Q O1/min','Q O2/min','APD E/s','APD M/s','APD L/s',
                'APD O1/s','APD O2/s','# E','# M','# L','# O1','# O2','freq E',
                'freq M','freq L','freq O1','freq O2']
outputlist=[]
for i in range(len(StageAnalysis)):
        outputlist.append([i+1]+[Qentry[i]]+[Qexit[i]]+[Qduration[i]]+
                                [totalQ[i]]+[correctedQ[i]]+[correctedQ_min[i]]+
                                [tAPD[i]]+[tQepisodes[i]]+[tQfreq[i]]+[peak_fQ[i]]+
                                StageAnalysis[i]['stage'][:5]+StageAnalysis[i]['duration'][:5]+
                                StageAnalysis[i]['episodes'][:5]+StageAnalysis[i]['freq'][:5])
outputstr=[map(str,item) for item in outputlist]
inv_fractQ=[[item[i] for item in fractQ] for i in range(len(fractQ[0]))]
inv_fractQstr=[map(str,item) for item in inv_fractQ]
inv_wormstatus=[[item[i] for item in wormstatus] for i in range(len(wormstatus[0]))]
inv_wormstatusstr=[map(str,item) for item in inv_wormstatus]


def doplot(fractQ,figname):
        plt.figure(figsize=(ChamberN*2.6,8))
        for i in range(ChamberN):
                plt.subplot(2,ChamberN/2, i+1)
                plt.plot(range(len(fractQ[0])),fractQ[i])
                plt.tick_params(axis='x', labelsize='small')
                plt.hlines(0.1, 0, len(fractQ[0]), color='r', linestyle='--')
                plt.ylim((0.0, 1.0))
                plt.xlim((0.0,float(len(fractQ[0]))))
                plt.title('Chamber %s' %(i+1))
        plt.savefig(figname)
        plt.close()

            
folderpath, filename=os.path.split(path)
filename1=filename.replace('.txt','_results.txt')
filehandle1=open(os.path.join(folderpath,filename1),'w')
print>>filehandle1,'\t'.join(titlelist)
for item in outputstr:
        print>>filehandle1,'\t'.join(item)
filehandle1.close()

#filename2=filename.replace('.txt','_fractQ.txt')
#filehandle2=open(os.path.join(folderpath,filename2),'w')
#for item in inv_fractQstr:
#        print>>filehandle2,'\t'.join(item)
#filehandle2.close()

#filename3=filename.replace('.txt','_wormstatus.txt')
#filehandle3=open(os.path.join(folderpath,filename3),'w')
#for item in inv_wormstatusstr:
#        print>>filehandle3,'\t'.join(item)
#filehandle3.close()

filename4=filename.replace('.txt','.png')
figname=os.path.join(folderpath,filename4)
doplot(fractQ,figname)


#Other results for output: pause duration histogam
