IM=imread('straighten_test.jpg');
load('straighten_test.mat')
IM2 = straighten(IM,[x;y]',450);
figure(1);clf;
subplot(1,2,1);imagesc(IM);axis image off;hold on;plot(x,y,'o-')
subplot(1,2,2);imagesc(permute(IM2,[2,1,3])./255);axis image off
saveas(gcf,'straighten_result.jpg');
%% to get the points from the image
% IM=imread('straighten_test.jpg');
% f = figure(1);clf;
% imagesc(IM);axis image off;
% hold on;
% [x,y,b]=ginput(1);
% plot(x,y,'o-');hold off
% while b~=3
%     [x_,y_,b]=ginput(1);
%     if b==8 %backspace
%         x(end)=[];y(end)=[];
%     else
%         x=[x,x_];y=[y,y_];
%     end
%     f.Children(1).Children(1).XData=x;
%     f.Children(1).Children(1).YData=y;
% end
% save('straighten_test.mat','x','y');