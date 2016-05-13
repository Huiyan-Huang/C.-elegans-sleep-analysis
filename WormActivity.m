function WormActivity(FirstImageFilename,LastImageFilename,WormData,ActiveRegion,Rx,Ry)
%
%WormActivity(FirstImageFilename,LastImageFilename)
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
%April 29, 2009
%

tol=50;
figure;
%Read in file names and plot first image
[Image1,map]=imread(FirstImageFilename);
subplot(2,3,4);imagesc(Image1);
colormap(gray);
axis off;
%Draw Region
hold on
axis manual
plot(Rx,Ry);

%Initilize
[rows,columns]=size(FirstImageFilename);
ImageNumber=FirstImageFilename(1,(columns-7):(columns-4));
ImNum=str2num(ImageNumber);
First=ImNum;
NumberOfImages=str2num(LastImageFilename(1,(columns-7):(columns-4)))-ImNum;
Last=First+NumberOfImages;
x=[First:Last-1];
%
%Plot calculated worm activity
subplot(2,3,1:3);
plot(x,WormData./max(WormData),'-rs','LineWidth',1.2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',3);
set(gca,'XTick',First:floor(NumberOfImages/10+1):(First+NumberOfImages));
xlabel('Image Number','FontSize',12);
ylabel('Normalized Activity Level','FontSize',12);
GT=num2str(ActiveRegion);
GT=['Worm Activity (region ' GT ')'];
title(GT,'FontSize',12);

%zoom on;
%
%Take user graphic input and plots the change between
%the selected input images.
%

%while waitforbuttonpress ~= 1 end;

%Graphical user input to select image to exam
but = 1;
while but == 1
    subplot(2,3,1:3);
    [xi,yi,but] = ginput(1);
    ImNumStr1=num2str(round(xi));
    ImNum=str2num(ImNumStr1);
     [r2,c2]=size(ImNumStr1);
     z=4-c2;
     if (z>0)
         for j=1:z ImNumStr1=['0' ImNumStr1]; end; 
     end;
    I1=[FirstImageFilename(1:(columns-8)) ImNumStr1 FirstImageFilename((columns-3):columns)];
    [Image1,map]=imread(I1);
    subplot(2,3,4);imagesc(Image1);
    %plot region being examined
    hold on
    axis manual
    plot(Rx,Ry);   
    axis off;
    title(ImNumStr1,'FontSize',12);

        
    ImNumStr2=num2str(round(xi)+1);
    ImNum=str2num(ImNumStr2);
     [r2,c2]=size(ImNumStr2);
     z=4-c2;
     if (z>0)
         for j=1:z ImNumStr2=['0' ImNumStr2]; end; 
     end;
    I2=[FirstImageFilename(1:(columns-8)) ImNumStr2 FirstImageFilename((columns-3):columns)];
    [Image2,map]=imread(I2);
    subplot(2,3,5);imagesc(Image2);axis off;
    %plot region being examined
    hold on
    plot(Rx,Ry);
    title(ImNumStr2,'FontSize',12);

    
    DIF=abs(double(Image2)-double(Image1));
%set anything below "tol" equal to zero to eleminate noise
    n=find(DIF<tol);
    DIF(n)=0;
    subplot(2,3,6);image(DIF); axis off;
    %plot region being examined
    hold on
    axis manual
    plot(Rx,Ry);
    title('Difference Between Images','FontSize',12);

 end;
 

