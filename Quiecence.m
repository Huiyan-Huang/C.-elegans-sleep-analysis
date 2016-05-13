function Quiecence(FirstImageFilename,LastImageFilename,WormData,ActiveRegion)
%
%Quiecence(FirstImageFilename,LastImageFilename,WormData,Rx,Ry)
%
% D.P. Hart (dphart@mit.edu)
%April 29, 2009

%
%Calculate fractional quiescents based on surrounding 60
%images
%
SleepLimit=0.05;
Fquiescent(1)=0;
Wmax=max(WormData(:)+1);

[rows,columns]=size(FirstImageFilename);
ImageNumber=FirstImageFilename(1,(columns-7):(columns-4));
ImNum=str2num(ImageNumber);
First=ImNum;
NumberOfImages=str2num(LastImageFilename(1,(columns-7):(columns-4)))-ImNum;
Last=First+NumberOfImages;

FQ(1)=First+30;
for i=-30:30
    if (WormData(1+30+i)./Wmax<SleepLimit) Fquiescent(1)=Fquiescent(1)+1; end;
end;
for i=32:(NumberOfImages-30)
    Fquiescent(i-30)=Fquiescent(i-31);
    if (WormData(i+30)/Wmax<SleepLimit) Fquiescent(i-30)=Fquiescent(i-30)+1; end;
    if (WormData(i-30)/Wmax<SleepLimit) Fquiescent(i-30)=Fquiescent(i-30)-1; end;
    if Fquiescent(i-30)<0 Fquiescent(i-30)=0; end;
    FQ(i-30)=First+i-1;
end;
Fquiescent=Fquiescent./60;
%
%Plot the results
%
figure;
plot(FQ,Fquiescent,'-rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',3);
axis([FQ(1) FQ(NumberOfImages-60) 0 1]);
set(gca,'XTick',First:floor(NumberOfImages/10+1):(First+NumberOfImages));
xlabel('Image Number','FontSize',12);
ylabel('Fractional Quiescents','FontSize',12);
GT=num2str(ActiveRegion);
GT=['Worm Fractional Quiescents (region ' GT ')'];
title(GT,'FontSize',12);
zoom on;
