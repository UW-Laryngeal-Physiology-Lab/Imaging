function CombineToHeatmap(input)
totalSize=zeros(size(input,1),1);
for i=1:length(input)
    for j=1:size(input(i).data,2)
        if mod(j,2)==0%even
            input(i).data(:,j)=input(i).data(:,j)-input(i).originPt(2);
        else%odd
            input(i).data(:,j)=input(i).data(:,j)-input(i).originPt(1);
        end
    end
    input(i).data=input(i).data./input(i).GPratio;
    totalSize(i)=size(input(i).data,2);
end
totalData=zeros(size(input(i).data,1),sum(totalSize));
nextColumn=1;
for i=1:length(input)
    totalData(:,nextColumn:(nextColumn+totalSize(i)-1))=input(i).data;
    nextColumn=nextColumn+totalSize(i);
end


%totalData=totalData(:,1:1000);
%%Calculate freq and amp values for each point
freq=zeros(size(totalData,2),1);
amp=zeros(size(totalData,2),1);
error=zeros(size(totalData,2),1);
phase=zeros(size(totalData,2),1);
a1=zeros(size(totalData,2),2);
for i=1:size(totalData,2)
    time=(1:size(totalData,1))';
    totalData(:,i)=fillgaps(totalData(:,i));
    points=totalData(:,i);
    time(isnan(points))=[];
    points(isnan(points))=[];
    if length(points)>3
        [fourierFit, gof] = fit(time,points, 'fourier1');
        error(i)=gof.rsquare;
        freq(i)=fourierFit.w;
        amp(i)=sqrt(fourierFit.a1.^2+fourierFit.b1.^2);
        phase(i)=atan2(fourierFit.a1,fourierFit.b1);
        a1(i,:)=[fourierFit.a1,fourierFit.b1];
    else
        amp(i)=NaN;
        freq(i)=NaN;
        phase(i)=NaN;
    end
end
%Uncomment these to delete bad points. If too many are deleted though, we
%won't get a plot!
%amp(amp<0.01)=NaN;
%freq(freq<0.01)=NaN;

%%Split freq, amp values into x,y coord.
freqX=zeros(length(amp)/2,1);
freqY=zeros(length(amp)/2,1);
ampX=zeros(length(amp)/2,1);
ampY=zeros(length(amp)/2,1);
errorX=zeros(length(amp)/2,1);
errorY=zeros(length(amp)/2,1);
phaseX=zeros(length(amp)/2,1);
phaseY=zeros(length(amp)/2,1);
dataX=zeros(size(totalData,1),length(amp)/2);
dataY=zeros(size(totalData,1),length(amp)/2);
for i=1:length(amp)
    if mod(i,2)==1
        dataX(:,ceil(i/2))=totalData(:,i);
        phaseX(ceil(i/2))=phase(i);
        errorX(ceil(i/2))=error(i);
        freqX(ceil(i/2))=freq(i);
        ampX(ceil(i/2))=amp(i);
    else
        dataY(:,i/2)=totalData(:,i);
        phaseY(i/2)=phase(i);
        freqY(i/2)=freq(i);
        ampY(i/2)=amp(i);
        errorY(i/2)=error(i);
    end
end

phaseY=abs(phaseX);

%%Filter out bad points
%Uncomment the two exclude lines, otherwise the block of code is pointless,
%and no bad points are deleted. Temporarily commented for testing purposes.
freqSquare=zeros(length(ampX),1);
ampSquare=zeros(length(ampX),1);
x=zeros(length(ampX),1);
y=zeros(length(ampX),1);
exclude=zeros(length(ampX),1);
freqSquareMean=mean(rmoutliers(freq(~isnan(freq))))*sqrt(2);
for i=1:length(ampX)
    if isnan(ampX(i))||isnan(ampY(i))||isnan(freqX(i))||isnan(freqY(i))
       % exclude(i)=i;
    else
        tempX=totalData(~isnan(totalData(:,i*2-1)),i*2-1);
        x(i)=tempX(1);
        tempY=totalData(~isnan(totalData(:,i*2)),i*2);
        y(i)=tempY(1);
        ampSquare(i)=sqrt(ampX(i)^2+ampY(i)^2);
        freqSquare(i)=sqrt(freqX(i)^2+freqY(i)^2);
        if errorX(i)<0.7||errorY(i)<0.7||freqSquare(i)<freqSquareMean-0.1...
                ||freqSquare(i)>freqSquareMean+0.1||ampSquare(i)>50
            %exclude(i)=i;
        end
    end
end
exclude(exclude==0)=[];
x(exclude)=[];
y(exclude)=[];
ampSquare(exclude)=[];
freqSquare(exclude)=[];
phaseY(exclude)=[];
dataX(:,exclude)=[];
dataY(:,exclude)=[];

%Plotting prep
close all
image=input(1).Img;
y=-y;
pixelX=x.*input(1).GPratio;
pixelY=y.*input(1).GPratio;
normX=(pixelX+input(1).originPt(1))./size(image,2);
normY=(pixelY+input(1).originPt(2))./size(image,1);
contourSize=[min(normX),min(normY),range(normX),range(normY)];
[X,Y]=meshgrid(x,y);



% Create UIFigure and hide until all components are created
UIFigure = uifigure('Visible', 'off');
screenSize=get(0,'screensize');
UIFigure.Position=screenSize;
UIFigure.Name = 'UI Figure';
UIFigure.WindowState = 'maximized';

% Create ddLabel
ddLabel = uilabel(UIFigure);
ddLabel.HorizontalAlignment = 'right';
ddLabel.Position = [0 0.95*screenSize(4) 0.1516*screenSize(3) 0.0458*screenSize(4)];
ddLabel.Text = 'Select Data Type';

% Create UIAxes
ampUIPanel=uipanel(UIFigure,'Visible','on','Position',[0 0.1458*screenSize(4) 0.6422*screenSize(3) 0.8125*screenSize(4)]);
phaseUIPanel=uipanel(UIFigure,'Visible','off','Position',ampUIPanel.Position);
freqUIPanel=uipanel(UIFigure,'Visible','off','Position',ampUIPanel.Position);
Z=griddata(x,y,ampSquare,X,Y);
ampAx1=axes('Parent',ampUIPanel,'Visible','off');
ampAx2=axes('Parent',ampUIPanel,'Visible','off');
ampAx3=axes('Parent',ampUIPanel,'Visible','off');


%Create amplitude axis
I=imshow(image,'Parent',ampAx2);
I.AlphaData=0.6;  %Transparency of image: [0,1]
set(ampAx2, 'Units','normalized','Position',[0 0 1 1]);
[~,c]=contourf(ampAx1,X,Y,Z,100);
c.LineStyle='none';
scatter(ampAx3,x,y,20,ampSquare,'x');
ampAx1.Visible="off";
realPosition=ampUIPanel.Position;%Want to find actual normalized location of image w/i panel
realPosition(1)=0;
realPosition(2)=0;
if(size(image,1)<size(image,2))
    ratio=realPosition(3)/size(image,2);
    realPosition(4)=size(image,1)*ratio;
    realPosition(2)=(ampUIPanel.Position(4)-realPosition(4))/2;
else
    ratio=realPosition(4)/size(image,1);
    realPosition(3)=size(image,2)*ratio;
    realPosition(1)=(ampUIPanel.Position(3)-realPosition(3))/2;
end
realPosition(1)=realPosition(1)/ampUIPanel.Position(3);
realPosition(2)=realPosition(2)/ampUIPanel.Position(4);
realPosition(3)=realPosition(3)/ampUIPanel.Position(3);
realPosition(4)=realPosition(4)/ampUIPanel.Position(4);

colorbarPosition=realPosition;
colorbarPosition(1)=colorbarPosition(1)+colorbarPosition(3);
colorbarPosition(3)=0.025;
colorbar(ampAx3,'Units','normalized','Position',colorbarPosition);

ampAx2.Position=[0 0 1 1];
set(ampAx1,'Units','normalized','Position',[realPosition(1)+contourSize(1)*realPosition(3),...
    realPosition(2)+(1-contourSize(2)-contourSize(4))*realPosition(4),contourSize(3)*realPosition(3),contourSize(4)*realPosition(4)]);
set(ampAx3,'Units','normalized','Position',ampAx1.Position);
ampAx3.Color='none';
ampAx3.Visible='off';
ampAx1.Color='none';

%Create freq panel
Z=griddata(x,y,freqSquare,X,Y);
freqAx1=axes('Parent',freqUIPanel,'Visible','off');
freqAx2=axes('Parent',freqUIPanel,'Visible','off');
freqAx3=axes('Parent',freqUIPanel,'Visible','off');
I=imshow(image,'Parent',freqAx2);
set(freqAx2,'Units','normalized','Position',[0,0,1,1]);
I.AlphaData=0.6;  %Transparency of image: [0,1]
[~,c]=contourf(freqAx1,X,Y,Z,100);
c.LineStyle='none';
scatter(freqAx3,x,y,20,freqSquare,'x');
freqAx1.Visible="off";
colorbar(freqAx3,'Units','normalized','Position',colorbarPosition);
freqAx2.Position=[0 0 1 1];
set(freqAx1,'Units','normalized','Position',ampAx1.Position);
set(freqAx3,'Units','normalized','Position',ampAx1.Position);
freqAx3.Color='none';
freqAx3.Visible='off';
freqAx1.Color='none';

%Create phase panel. 
%Note that this is currently phase Y, could expirment w/ phaseX, or
%phaseSquare
Z=griddata(x,y,phaseY,X,Y);
phaseAx1=axes('Parent',phaseUIPanel,'Visible','off');
phaseAx2=axes('Parent',phaseUIPanel,'Visible','off');
phaseAx3=axes('Parent',phaseUIPanel,'Visible','off');
I=imshow(image,'Parent',phaseAx2);
set(phaseAx2,'Units','normalized','Position',[0,0,1,1]);
I.AlphaData=0.6;  %Transparency of image: [0,1]
[~,c]=contourf(phaseAx1,X,Y,Z,100);
c.LineStyle='none';
scatter(phaseAx3,x,y,20,phaseY,'x');
phaseAx1.Visible="off";
colorbar(phaseAx3,'Units','normalized','Position',colorbarPosition);
phaseAx2.Position=[0 0 1 1];
set(phaseAx1,'Units','normalized','Position',ampAx1.Position);
set(phaseAx3,'Units','normalized','Position',ampAx1.Position);
phaseAx3.Color='none';
phaseAx3.Visible='off';
phaseAx1.Color='none';



% Create dd
dd = uidropdown(UIFigure);
dd.Items = {'Amplitude', 'Phase', 'Frequency'};
dd.Position = [0.16*screenSize(3) 0.96*screenSize(4) 0.1516*screenSize(3) 0.02*screenSize(4)];
dd.Value = 'Amplitude';
dd.ValueChangedFcn=@(dd,event) selection(dd,ampUIPanel,phaseUIPanel,freqUIPanel);


% Create UIAxes2
UIAxes1 = uiaxes(UIFigure);
title(UIAxes1, 'X Position vs Time')
xlabel(UIAxes1, 'Time(frames)')
ylabel(UIAxes1, 'X Position(mm)')
UIAxes1.Position = [0.6719*screenSize(3) 0.575*screenSize(4) 0.3297*screenSize(3) 0.4071*screenSize(4)];

% Create UIAxes2_2
UIAxes2 = uiaxes(UIFigure);
title(UIAxes2, 'Y Position vs Time')
xlabel(UIAxes2, 'Time(frames)')
ylabel(UIAxes2, 'Y Position(mm)')
UIAxes2.Position = UIAxes1.Position;
UIAxes2.Position(2)=0.1554*screenSize(4);

% Create TextArea
TextArea = uitextarea(UIFigure);
TextArea.Position = [0 0 screenSize(3) 0.1458*screenSize(4)];

% Show the figure after all components are created
UIFigure.Visible = 'on';

picBounds=ampUIPanel.Position.*realPosition;
picBounds(1)=ampUIPanel.Position(1)+ampUIPanel.Position(3)*realPosition(1);
picBounds(2)=ampUIPanel.Position(2)+ampUIPanel.Position(4)*realPosition(2);
xTotalPixel=normX*picBounds(3)+picBounds(1);
normY=(1-((-y)*input(1).GPratio+input(1).originPt(1))./size(image,1));
normY=normY/range(normY)*ampAx1.Position(4);
normY=normY-min(normY)+ampAx1.Position(2);
yTotalPixel=normY*picBounds(4)+picBounds(2);
P=[xTotalPixel,yTotalPixel];


UIFigure.WindowButtonDownFcn=@(UIFigure,~)mouseClick(UIFigure,TextArea,...
    picBounds,P,dataX,-dataY,UIAxes1,UIAxes2,ampSquare,freqSquare,phaseY);

    %Display in text area info about closest point
    function mouseClick(UIFigure,TextArea,picBounds,P,dataX,dataY,UIAxes1,UIAxes2,ampSquare,freqSquare,phaseY)
        click=UIFigure.CurrentPoint;
        if(click(1)>=picBounds(1)&&click(1)<=(picBounds(1)+picBounds(3)))
            if(click(2)>=picBounds(2)&&click(2)<=(picBounds(2)+picBounds(4)))
                idx=dsearchn(P,click);
                time=(1:size(dataX,1))';
                plot(UIAxes1,time,dataX(:,idx));
                plot(UIAxes2,time,dataY(:,idx));
                TextArea.Value={['X-Position: ',num2str(dataX(1,idx)),'   Y-Position: ',num2str(dataY(1,idx))];'';
                    ['Frequency: ',num2str(freqSquare(idx)),' Amplitude: ',num2str(ampSquare(idx)),' Phase: ',num2str(phaseY(idx))]};
            end
        end
        
    end

    %Function for if you choose to look at a different panel
    function selection(dd,ampUIPanel,phaseUIPanel,freqUIPanel)
        val=dd.Value;
        ampUIPanel.Visible='off';
        phaseUIPanel.Visible='off';
        freqUIPanel.Visible='off';
        if(strcmp(val,'Amplitude'))
            ampUIPanel.Visible='on';
        end
        if(strcmp(val,'Phase'))
            phaseUIPanel.Visible='on';
        end
        if(strcmp(val,'Frequency'))
            freqUIPanel.Visible='on';
        end
    end
end