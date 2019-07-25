function [IM2] = straightenRH(IM,pts,width)
%STRAIGHTEN Straightens an image based on the spline interpolation between
%the input points. 
% based on the straightenLine function in the Straightener plugin from ImageJ1
% https://github.com/imagej/imagej1/blob/master/ij/plugin/Straightener.java#L101
% https://github.com/imagej/imagej1/blob/master/ij/gui/PolygonRoi.java
debug=false;
if ndims(IM)==3
    for ct = 1:size(IM,3)
        IM2(:,:,ct)=straighten(IM(:,:,ct),pts,width);
    end
    return;
end
% must make spline with one pixel segment lengths
[x,y]=fitSplineForStraightening(pts(:,1),pts(:,2));

if debug
    figure(99);clf;
    imagesc(IM);axis image
    hold on;
    plot(x,y,'o-');
    title('spline')
    pause
end

for ct = 1:length(x)
    if ct == 1
        dx = x(2)-x(1); %extrapolate first direction
        dy = y(1)-y(2);
    else
        dx = x(ct)-x(ct-1);
        dy = y(ct-1)-y(ct);
    end
    %want to move 1 pixel when we move the pointer dx dy
    L = sqrt(dx^2+dy^2); 
    dx = dx/L; 
    dy = dy/L;
    
    xStart = x(ct)-(dy*width)/2; %start half the width away
    yStart = y(ct)-(dx*width)/2; 
    if debug
        figure(1);clf;
        imagesc(IM);axis image;hold on;
        plot(x,y,'-');
        plot(x(ct),y(ct),'o-');
        plot([xStart,xStart+dy*width],[yStart,yStart+dx*width],'r--')
        pause(0.1)
    end
    for ct2 = 1:width
        IM2(ct,ct2) = getInterpolatedValue(IM,xStart,yStart);
        xStart=xStart+dy;
        yStart=yStart+dx;
    end
end

end

function I = getInterpolatedValue(IM,y,x)
% interpolation of pixelvalues one-indexed
% IM = [0,1,2;2,3,4;4,5,6]; 
% getInterpolatedValue(IM,1,1);
% > 0
x = [floor(x),ceil(x),rem(x,1)];
y = [floor(y),ceil(y),rem(y,1)];
I(1,1) = IM(x(1),y(1))*(1-x(3))*(1-y(3));
I(2,1) = IM(x(1),y(2))*(1-x(3))*(0+y(3));
I(1,2) = IM(x(2),y(1))*(0+x(3))*(1-y(3));
I(2,2) = IM(x(2),y(2))*(0+x(3))*(0+y(3));
I = sum(I(:));
end

function [xspl,yspl] = fitSplineForStraightening(xVal,yVal)
%return a spline fit with distances of 1 between the points
%based on https://github.com/imagej/imagej1/blob/master/ij/gui/PolygonRoi.java#L1006
dx=0.1;
pp = spline(xVal,yVal);
xspl(1)=xVal(1);yspl(1)=yVal(1);
xspl(2)=xVal(1);yspl(2)=yVal(1);
ct=2;
while xspl(end-1)<xVal(end)
    xspl(ct)=xspl(ct)+dx;
    yspl(ct)=ppval(pp,xspl(ct));
    d = (xspl(ct-1)-xspl(ct))^2+(yspl(ct-1)-yspl(ct))^2;
    if d>1
        ct=ct+1;
        xspl(ct)=xspl(ct-1);
    end
end
xspl(end)=[];
end
