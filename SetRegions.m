function [Rx,Ry]=SetRegions(FirstImageFilename)
%
%
print('this function is running')
[Image1,map]=imread(FirstImageFilename);
figure;
imagesc(Image1);
colormap(gray);
axis off;
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);

p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
Rx = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
Ry = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on
axis manual
plot(Rx,Ry);                            % redraw in dataspace units
Rx=uint16(Rx);
Ry=uint16(Ry);