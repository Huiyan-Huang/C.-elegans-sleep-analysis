function [WormData,Fquiescent,FQ]=RunWorms(FirstImageFilename,LastImageFilename,Rx,Ry)
%
%[WormData,Fquiescent]=RunWorms(FirstImageFilename,LastImageFilename)
%
%This program looks at a series of images and plots the relative change
%between images.  It was written to track activity level of worms.
%
%FirstImageFilename - the name of the first image in the sequence including
%the extension.
%
%LastImageFilename - the name of the last image in the sequence including
%the extension.
%
% D.P. Hart (dphart@mit.edu)
%
good_idx=(sum(Rx, 2)>0);
Rx=Rx(good_idx, :);
Ry=Ry(good_idx, :);
no_cells=size(Rx); %changed CTZHU 06/29/2014
no_cells=no_cells(1); %changed CTZHU 06/29/2014

tol=50; %sets camera noise threshold to minimize effects of camera noise
%Read in file names and initilize variables
img_step=1; %1 means process every image, change it to other value for skipping images. CTZHU 03/22/2014
n_dig=length(FirstImageFilename)-find(FirstImageFilename~=LastImageFilename, 1)-3; %number of digits in filename. CTZHU 03/22/2014
[Image1,map]=imread(FirstImageFilename);
[rows,columns]=size(FirstImageFilename);
ImageNumber=FirstImageFilename(1,(columns-4-n_dig+1):(columns-4));
ImNum=str2num(ImageNumber);
First=ImNum;
NumberOfImages=str2num(LastImageFilename(1,(columns-4-n_dig+1):(columns-4)))-ImNum;
Last=First+NumberOfImages;
if img_step~=1 %changed CTZHU 03/22/2014
    temp=1:NumberOfImages;
    NumberOfImages=length(temp(1:img_step:end));
end;
[Y,X]=size(Image1);
NumValidImages=0; %the first image must be good
WormLength=5000; % set range to accept pixal changes.  This minimizes noise.
%
%Calculate flatfield correction
%  All of the images are averaged and the mean pixel intensity is set to
%  128 so that the value of 'flatfield' equals 
%  128/(average pixel intensity) at each pixel.  Note - this can add
%  considerable noise to the data if the images are poor.  However, for
%  properly exposed images, it normalizes the pixel change across the image
%  reducing the effects of vignetting and non-uniform exposure.
Flatfield=double(Image1);
for i=1:NumberOfImages
     ImNum=ImNum+img_step; %changed CTZHU 03/22/2014
     if ImNum>Last
         ImNum=Last;
     end  %changed CTZHU 03/22/2014
     ImNumStr=num2str(ImNum);
     [r2,c2]=size(ImNumStr);
     z=n_dig-c2;
     if (z>0)
         for j=1:z ImNumStr=['0' ImNumStr]; end; 
     end;
     I2=[FirstImageFilename(1:(columns-4-n_dig)) ImNumStr FirstImageFilename((columns-3):columns)];
     %check if image exists
     [fid,message] = fopen(I2, 'r');
     if fid~=-1
     fclose(fid);
     [Image2,map]=imread(I2);
     Flatfield=Flatfield+double(Image2);
     NumValidImages=NumValidImages+1;
     else disp([message ' ' I2])
     end
end
Flatfield=(128*NumValidImages)./Flatfield;
%
%Calculate worm activity based on change between adjacent images
%
ImNum=First;
WormData=zeros(no_cells,NumberOfImages);
for i=1:NumberOfImages
     ImNum=ImNum+img_step; %changed CTZHU 03/22/2014
     if ImNum>Last
         ImNum=Last;
     end  %changed CTZHU 03/22/2014
     ImNumStr=num2str(ImNum);
     [r2,c2]=size(ImNumStr);
     z=n_dig-c2;
     if (z>0)
         for j=1:z ImNumStr=['0' ImNumStr]; end; 
     end;
     I2=[FirstImageFilename(1:(columns-4-n_dig)) ImNumStr FirstImageFilename((columns-3):columns)];
     %disp(I2(end-8:end)); %debug
     %check if image exists
     [fid,message] = fopen(I2, 'r');
     if fid~=-1 % skip if image file has been deleted     
     fclose(fid);
     [Image2,map]=imread(I2);
     Dif=abs(double(Image2)-double(Image1));
     Dif(Dif<tol)=0;
%
%Checks that the image
%differences all occur within the same general area.  Anything too far from
%the worm is likely bad data or camera noise. If the differences are
%distributed over the image, it is likely that the camera moved relative to
%the sample.
%

%
%
    Diff=zeros(size(Dif));
         for k=1:no_cells %changed CTZHU 06/29/2014
            if Rx(k,1)>0
              x=Rx(k,1):Rx(k,2);
              y=Ry(k,2):Ry(k,3);
    %          
    %
    %[M,N]=find(Dif(y,x)>0);
    %if M>2 
    %    if N>2
    %MCenter=floor(median(M));
    %NCenter=floor(median(N));
    %top=MCenter-WormLength;
    %bottom=MCenter+WormLength;
    %left=NCenter-WormLength;
    %right=NCenter+WormLength;
    %if top<Ry(k,2) top=Ry(k,2); end
    %if bottom>Ry(k,3) bottom=Ry(k,3); end
    %if left<Rx(k,1) left=Rx(k,1); end
    %if right>Rx(k,2) right=Rx(k,2); end
    %for yy=top:bottom
    %    for xx=left:right
    %    Diff(yy,xx)=Dif(yy,xx)*Flatfield(yy,xx);
    %    end
    %end
    %    end
    %end
    %
              WormData(k,i)=sum(sum(Dif(y,x))); 
            end;
         end;
         %x(i)=ImNum-1; %What is this suppose to do? Looks like BS to me.
         Image1=Image2;
         end %end 'if fid' check for valid image file name
end;
%disp(x) %debug
%
%Calculate Quiecence
%
SleepLimit=0.05; %arbitrary value defining sleep threshold.  Value based of quiescent literature 
Fquiescent=zeros(no_cells,NumValidImages-60); %data uses 60 image running filter.  Value of 60 based on quiescent literature
ImNum=First;
for i=30:(NumValidImages-31) FQ(i-29)=First+i; end;
    
for k=1:no_cells
   if Rx(k,1)>0
       Wmax=max(WormData(k,:))+1;
       FQ(1)=First+30;
       for i=-30:30
          if (WormData(k,1+30+i)./Wmax<SleepLimit) Fquiescent(k,1)=Fquiescent(k,1)+1; end;
       end;
       for i=32:(NumValidImages-30)
          Fquiescent(k,i-30)=Fquiescent(k,i-31);
          if (WormData(k,i+30)/Wmax<SleepLimit) Fquiescent(k,i-30)=Fquiescent(k,i-30)+1; end;
          if (WormData(k,i-30)/Wmax<SleepLimit) Fquiescent(k,i-30)=Fquiescent(k,i-30)-1; end;
          if Fquiescent(k,i-30)<0 Fquiescent(k,i-30)=0; end;
       end;
   end;
end;
Fquiescent=Fquiescent./61;