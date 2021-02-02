function varargout = frequencyWave(varargin)
% FR  EQUENCYWAVE MATLAB code for frequencyWave.fig
%      FREQUENCYWAVE, by itself, creates a new FREQUENCYWAVE or raises the existing
%      singleton*.
%
%      H = FREQUENCYWAV E returns the handle to a new FREQUENCYWAVE or the handle to
%      the existing singleton*.
%
%      FREQUENCYWAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQUENCYWAVE.M with the given input arguments.
% 
%      FREQUENCYWAVE('Property','Value',...) creates a new FREQUENCYWAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frequencyWave_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frequencyWave_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frequencyWave

% Last Modified by GUIDE v2.5 06-Nov-2019 11:31:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @frequencyWave_OpeningFcn, ...
    'gui_OutputFcn',  @frequencyWave_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before frequencyWave is made visible.
function frequencyWave_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frequencyWave (see VARARGIN)

% Choose default command line output for frequencyWave
handles.output = hObject;

% set video display parameters
set(handles.numberOfImagesLabel, 'String', 'Number of Images: N/A');
set(handles.rotateLabel, 'String', 'Rotate');
set(handles.rotateSlider, 'min', -180);
set(handles.rotateSlider, 'max', 180);
set(handles.rotateSlider, 'Value', 0);
set(handles.rotateSlider, 'SliderStep', [1/360 , 10/360]);
set(handles.frameRangeLabel, 'String', 'Frame Range');
set(handles.markStart, 'String', '1');
set(handles.togglePlotPoints,'Value',1);

% set detect corners parameters
set(handles.harris,'Value',1);
set(handles.minEigen,'Value',0);
set(handles.fast,'Value',0);
set(handles.brisk,'Value',0);
set(handles.MinQualityLabel,'String',{'Minimum Pixel'; 'Quality'});
set(handles.minQuality, 'String', '0.0001');
set(handles.filterSizeLabel,'String','Filter Size');
set(handles.filterSize, 'String', '5');
set(handles.minContrastLabel,'String',{'Minimum'; 'Contrast'});
set(handles.minContrast, 'String', '0.2');
handles.CornerType = 1; %flags corner type that is selected
handles.cornerTypeName = 'harris';

% set point tracker parameters
handles.NumPyramidLevels = 4;
set(handles.numOfPyramidsLabel, 'String', ['Number of Pyramids: ' num2str(handles.NumPyramidLevels)]);
handles.MaxIterations = 30;
set(handles.maxIterationsLabel, 'String', ['Max Iterations: ' num2str(handles.MaxIterations)]);
set(handles.MaxBidirectionalErrorLabel,'String',{'Maximum Bidirectional'; 'Error'});
set(handles.MaxBidirectionalError,'String','10');
set(handles.BlockSizeLabel,'String','Block Size');
set(handles.BlockSize,'String','9');

% other variables
handles.imageIndex = 1;
handles.rotateIndex = 0;

%variables for the Axes
set(handles.glottisLengthField,'Value', 0.00)
handles.Xaxis = [];
handles.Yaxis = [];
handles.GPratio = 0;
handles.origin = [0,0]; % holds center of referecne axis drawn by DrawAxes
handles.glottisLengthFlag = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes frequencyWave wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = frequencyWave_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function File_menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Load_files_Callback(hObject, eventdata, handles)
% hObject    handle to Load_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Load_images_Callback(hObject, eventdata, handles)
% hObject    handle to Load_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%copies the axes
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% When this function is called the user selects a directory of images that 
% will be tracked. The directory of images is added to the path and
% visualization parameters are initailized.

% select directory and add to path.
folder_name = uigetdir;
addpath(genpath(folder_name));
[handles.images, handles.folder_name] = dir_Images(folder_name);
handles.save_folder_name = [handles.folder_name filesep 'saves'];
mkdir(handles.save_folder_name);

% set additonal gui parameters from image directory path and size and
% image size.
set(handles.Folder_Load_Path, 'String', handles.folder_name);
set(handles.Folder_Save_Path, 'String', handles.save_folder_name);
set(handles.frameSlider, 'min', 1);
set(handles.frameSlider, 'max', length(handles.images));
set(handles.frameSlider, 'Value', 1);
set(handles.frameSlider, 'SliderStep', [1/length(handles.images) , 10/length(handles.images) ]);
set(handles.markEnd,'String', num2str(length(handles.images)));
set(handles.numberOfImagesLabel,'String', ['Number of Images: ' num2str(length(handles.images))]);

% initialize first image and set roi to size of image
handles.I = imread(handles.images{2});
[h,w] = size(handles.I)
handles.roibox = [1 1 w-1 h-1];

% check for correr detection method and call the selected method
if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to Load_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Save_files_Callback(hObject, eventdata, handles)
% hObject    handle to Save_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% when this function is called all figures are force closed.
 close all force;

% --------------------------------------------------------------------
function Save_images_Callback(hObject, eventdata, handles)
% hObject    handle to Save_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Save_video_Callback(hObject, eventdata, handles)
% hObject    handle to Save_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Save_data_Callback(hObject, eventdata, handles)
% hObject    handle to Save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Save_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to Save_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Edit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Tools_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Tools_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Convert_avi2images_Callback(hObject, eventdata, handles)
% hObject    handle to Convert_avi2images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When this function is called segmentVideo.m is called. 
segmentVideo;


% --------------------------------------------------------------------
function Convert_imagesRGB2Gray_Callback(hObject, eventdata, handles)
% hObject    handle to Convert_imagesRGB2Gray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When this function is called convertImagesRGB2Gray.m is called. 
convertImagesRGB2Gray;


function minQuality_Callback(hObject, eventdata, handles)
% hObject    handle to minQuality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%copies the axes
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function gets minimum quality  value that is entered by the user and
% updates the corners detected by corner detection functions.
if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function minQuality_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minQuality (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filterSize_Callback(hObject, eventdata, handles)
% hObject    handle to filterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function gets filter size value that is entered by the user and
% updates the corners detected by corner detection functions.
if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filterSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in harris.
function harris_Callback(hObject, eventdata, handles)
% hObject    handle to harris (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function detects HARRIS corners from corner detection parameters and
% displays dected corneres on the image.
set(handles.filterSizeLabel,'Visible','On');
set(handles.filterSize,'Visible','On');
set(handles.minContrastLabel,'Visible','Off');
set(handles.minContrast,'Visible','Off');
set(handles.threshold,'Visible','Off');
set(handles.numOctaves,'Visible','Off');
set(handles.numScaleLevels,'Visible','Off');
filterSize = str2double(get(handles.filterSize, 'String'));
minQuality = str2double(get(handles.minQuality, 'String'));

handles.CornerType = 1;
handles.cornerTypeName = 'harris';

I = imrotate(imread(handles.images{handles.imageIndex}), handles.rotateIndex);
[handles.corners, handles.numPts] = find_Points3(I,minQuality,filterSize, handles.CornerType,handles.roibox);

if (get(handles.togglePlotPoints,'Value') == 1)
    imshow(I, 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    scatter(handles.corners.Location(:,1),handles.corners.Location(:,2),'*','Parent',handles.axes1);
    rectangle('Position',handles.roibox,'EdgeColor','r')
    hold(handles.axes1, 'off');
else
    imshow(I, 'Parent', handles.axes1);
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --- Executes on button press in minEigen.
function minEigen_Callback(hObject, eventdata, handles)
% hObject    handle to minEigen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function detects MINEIGEN corners from corner detection parameters and
% displays dected corneres on the image.
set(handles.filterSizeLabel,'Visible','On');
set(handles.filterSize,'Visible','On');
set(handles.minContrastLabel,'Visible','Off');
set(handles.minContrast,'Visible','Off');
set(handles.threshold,'Visible','Off');
set(handles.numOctaves,'Visible','Off');
set(handles.numScaleLevels,'Visible','Off');
filterSize = str2double(get(handles.filterSize, 'String'));
minQuality = str2double(get(handles.minQuality, 'String'));

handles.CornerType = 2;
handles.cornerTypeName = 'minEigen';

I = imrotate(imread(handles.images{handles.imageIndex}), handles.rotateIndex);
[handles.corners, numPts] = find_Points3(I,minQuality,filterSize, handles.CornerType,handles.roibox);

if (get(handles.togglePlotPoints,'Value') == 1)
    imshow(I, 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    scatter(handles.corners.Location(:,1),handles.corners.Location(:,2),'*','Parent',handles.axes1);
    rectangle('Position',handles.roibox,'EdgeColor','r')

    hold(handles.axes1, 'off');
else
    imshow(I, 'Parent', handles.axes1);
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);

% --- Executes on button press in fast.
function fast_Callback(hObject, eventdata, handles)
% hObject    handle to fast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function detects FAST corners from corner detection parameters and
% displays dected corneres on the image.
set(handles.filterSizeLabel,'Visible','Off');
set(handles.filterSize,'Visible','Off');
set(handles.minContrastLabel,'Visible','On');
set(handles.minContrast,'Visible','On');
set(handles.threshold,'Visible','Off');
set(handles.numOctaves,'Visible','Off');
set(handles.numScaleLevels,'Visible','Off');
minContrast = str2double(get(handles.minContrast,'String'));
minQuality = str2double(get(handles.minQuality, 'String'));

handles.CornerType = 3;
handles.cornerTypeName = 'fast';

I = imrotate(imread(handles.images{handles.imageIndex}), handles.rotateIndex);
[handles.corners, numPts] = find_Points3(I,minQuality,minContrast, handles.CornerType,handles.roibox);

if (get(handles.togglePlotPoints,'Value') == 1)
    imshow(I, 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    scatter(handles.corners.Location(:,1),handles.corners.Location(:,2),'*','Parent',handles.axes1);
    rectangle('Position',handles.roibox,'EdgeColor','r')

    hold(handles.axes1, 'off');
else
    imshow(I, 'Parent', handles.axes1);
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --- Executes on button press in brisk.
function brisk_Callback(hObject, eventdata, handles)
% hObject    handle to brisk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function detects BRISK corners from corner detection parameters and
% displays dected corneres on the image.
set(handles.filterSizeLabel,'Visible','Off');
set(handles.filterSize,'Visible','Off');
set(handles.minContrastLabel,'Visible','On');
set(handles.minContrast,'Visible','On');
set(handles.threshold,'Visible','Off');
set(handles.numOctaves,'Visible','Off');
set(handles.numScaleLevels,'Visible','Off');
minContrast = str2double(get(handles.minContrast,'String'));
minQuality = str2double(get(handles.minQuality, 'String'));

handles.CornerType = 4;
handles.cornerTypeName = 'brisk';

I = imrotate(imread(handles.images{handles.imageIndex}), handles.rotateIndex);
[handles.corners, numPts] = find_Points3(I,minQuality,minContrast, handles.CornerType,handles.roibox);

if (get(handles.togglePlotPoints,'Value') == 1)
    imshow(I, 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    scatter(handles.corners.Location(:,1),handles.corners.Location(:,2),'*','Parent',handles.axes1);
    rectangle('Position',handles.roibox,'EdgeColor','r')

    hold(handles.axes1, 'off');
else
    imshow(I, 'Parent', handles.axes1);
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


function kaze_Callback(hObject, eventdata, handles)
%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

set(handles.filterSizeLabel,'Visible','Off');
set(handles.filterSize,'Visible','Off');
set(handles.minContrastLabel,'Visible','Off');
set(handles.minContrast,'Visible','Off');
set(handles.threshold,'Visible','On');
set(handles.numOctaves,'Visible','On');
set(handles.numScaleLevels,'Visible','On');

threshold = str2double(get(handles.threshold,'String'));
numOctaves = str2double(get(handles.numOctaves, 'String'));
numScaleLevels = str2double(get(handles.numScaleLevels, 'String'));

handles.CornerType = 5;
handles.cornerTypeName = 'kaze';

I = imrotate(imread(handles.images{handles.imageIndex}), handles.rotateIndex);
handles.corners = detectKAZEFeatures(I,'Threshold', threshold,'NumOctaves', numOctaves, 'NumScaleLevels', numScaleLevels ,'ROI', handles.roibox);

if (get(handles.togglePlotPoints,'Value') == 1)
    imshow(I, 'Parent', handles.axes1);
    hold(handles.axes1, 'on');
    scatter(handles.corners.Location(:,1),handles.corners.Location(:,2),'*','Parent',handles.axes1);
    rectangle('Position',handles.roibox,'EdgeColor','r')

    hold(handles.axes1, 'off');
else
    imshow(I, 'Parent', handles.axes1);
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


function minContrast_Callback(hObject, eventdata, handles)
% hObject    handle to minContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function gets minimum contrast value that is entered by the user and
% updates the corners detected by corner detection functions.
if (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
end    

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function minContrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaxBidirectionalError_Callback(hObject, eventdata, handles)
% hObject    handle to MaxBidirectionalError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MaxBidirectionalError_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxBidirectionalError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BlockSize_Callback(hObject, eventdata, handles)
% hObject    handle to BlockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BlockSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trackPoints.
function trackPoints_Callback(hObject, eventdata, handles)
% hObject    handle to trackPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.Xaxis) || isempty(handles.Yaxis)
    f = warndlg("The axes must be drawn to track points", 'Warning');
elseif handles.glottisLengthFlag == 0
    f = warndlg("No glottis length was entered", "warning");
else

    %get the pig number from the user for saving
    pigNum = input("Enter the pig number (ex '8'): ", 's');



    % get point tracking parameter values
    BlockSize = [str2double(get(handles.BlockSize,'String')),str2double(get(handles.BlockSize,'String'))];
    MaxBidirectionalError = str2double(get(handles.MaxBidirectionalError,'String'));
    minContrast = str2double(get(handles.minContrast,'String'));
    minQuality = str2double(get(handles.minQuality, 'String'));
    filterSize = str2double(get(handles.filterSize, 'String'));
    threshold = str2double(get(handles.threshold,'String'));
    numOctaves = str2double(get(handles.numOctaves, 'String'));
    numScaleLevels = str2double(get(handles.numScaleLevels, 'String'));
    [c tf] = clock;

    % get start frame value
    startFrame = str2double(get(handles.markStart,'String'));
    % get end frame value
    endFrame = str2double(get(handles.markEnd,'String'));

    table_save_file = strcat('Pig', pigNum, '_Frames-', num2str(startFrame), '-', num2str(endFrame),...
        '-', handles.cornerTypeName, '-', num2str(minQuality), '-', ...
        datestr(now,'mm-dd-yyyy_HH-MM-SS'));

    %gets the the filepath and name from user
    filter = {'*.mat'};
    [file,path] = uiputfile(filter, "Select file", table_save_file);

    % copy name of folder where images are held
    image_save_folder = handles.folder_name;

    % create matrix that will hold tracked point locations
    master = [];
    lip = startFrame; % copy of variable name to be passed into function calls
    % update current image
    I = imrotate(imread(handles.images{lip}), handles.rotateIndex);
    % detect points on first image using user selected detection algorithm
    if handles.CornerType == 1 | handles.CornerType == 2
        [handles.corners, numPts] = find_Points3(I,minQuality,filterSize, handles.CornerType,handles.roibox);
        filterName = get(handles.filterSize, 'String');
    elseif handles.CornerType == 3 | handles.CornerType == 4
        [handles.corners, numPts] = find_Points3(I,minQuality,minContrast, handles.CornerType,handles.roibox);
        filterName = get(handles.minContrast, 'String');
    elseif handles.CornerType == 5
        handles.corners = detectKAZEFeatures(I,'Threshold', threshold,'NumOctaves', numOctaves, 'NumScaleLevels', numScaleLevels ,'ROI', handles.roibox);
        filterName = get(handles.minContrast, 'String');
    end
    % handles.corners = remove_lines2(handles.corners,handles.images,lip,handles.rotateIndex);

    % initialize a point tracker object for each detected point
    [handles.pointTracker, handles.initial_points, point_validity] = ...
        initalize_PointTracker2(handles.corners, I, handles.NumPyramidLevels,...
        MaxBidirectionalError, handles.MaxIterations, BlockSize);
    % track all points across frame range
    [handles.all_tracked] = track_Points4(handles.pointTracker, handles.images,...
        handles.initial_points, lip, endFrame,handles.rotateIndex);

    % nanArray does not appear to alter the code in any way?
    nanArrayRow = lip-(startFrame);
    nanArrayCol= length(handles.all_tracked(1,:));
    nanArray = nan(nanArrayRow,nanArrayCol);
    handles.all_tracked = [nanArray; handles.all_tracked];
    % update the matrix that holds the locations of every tracked point
    master = [master,handles.all_tracked];

    % % prepare to save tracked point information to Excel
    % table_save_folder = [handles.save_folder_name filesep];

    % emptyTable = [];

    rotatedImage = imrotate(imread(handles.images{1}), handles.rotateIndex);
    glottalLength = str2num(handles.glottisLengthField.String);
    output_table = struct('data', master, "GPratio", handles.GPratio,'originPt', handles.origin, 'glottalLength',...
        glottalLength,'Img', rotatedImage);

    save([path file],'output_table');

    % save data to Excel file (to be located in 'saves' folder in 'pics' folder
    % that holds the images used for this analysis)
    % handles.all_tabel_full_filename = save_Table4(handles.images, master, ...
    %     emptyTable, startFrame, endFrame, 1, table_save_folder, ...
    %     image_save_folder, table_save_file,handles.rotateIndex);

    % imwrite(I,[table_save_folder 'first.png']);

    % handles - everything I want to pass to analyze gui. Parameters that need
    % to be save to load any pre-tracked files
    % handles.folder_name;
    % handles.f_start = str2double(get(handles.markStart,'String'));
    % handles.f_end = str2double(get(handles.markEnd,'String'));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function markEndButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markEndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function markStart_Callback(hObject, eventdata, handles)
% hObject    handle to markStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function markStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end


% This function gets image index value that is entered by the user and
% updates the corners detected by corner detection functions.
handles.imageIndex = int32(get(hObject, 'Value'));
set(handles.Folder_Save_Path,'String',int32(get(hObject, 'Value')));
set(handles.text21,'String', int32(get(hObject, 'Value')));

if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
elseif (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end


%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function rotateSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rotateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end


% This function gets rotation index value that is entered by the user and
% updates the corners detected by corner detection functions.
handles.rotateIndex = int32(get(hObject, 'Value'));

if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
elseif (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end


%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rotateSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in markStartButton.
function markStartButton_Callback(hObject, eventdata, handles)
% hObject    handle to markStartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.markStart,'String', num2str(handles.imageIndex))
guidata(hObject, handles);

% --- Executes on button press in markEndButton.
function markEndButton_Callback(hObject, eventdata, handles)
% hObject    handle to markEndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.markEnd,'String', num2str(handles.imageIndex))
guidata(hObject, handles);

function markEnd_Callback(hObject, eventdata, handles)
% hObject    handle to markEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.markEnd2, 'String', get(handles.markEnd,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function markEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in togglePlotPoints.
function togglePlotPoints_Callback(hObject, eventdata, handles)
% hObject    handle to togglePlotPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function gets updates view of detected corners on or off
if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
elseif (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);



function markStart2_Callback(hObject, eventdata, handles)
% hObject    handle to markStart2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of markStart2 as text
%        str2double(get(hObject,'String')) returns contents of markStart2 as a double


% --- Executes during object creation, after setting all properties.
function markStart2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markStart2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in drawROI.
function drawROI_Callback(hObject, eventdata, handles)
% hObject    handle to drawROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

% This function gets roi values that is entered by the user and
% updates the corners detected by corner detection functions.
handles.roibox = getrect;
rectangle('Position',handles.roibox,'EdgeColor','r')

if (get(handles.harris,'Value') == 1)
    harris_Callback(hObject, eventdata, handles)
elseif (get(handles.minEigen,'Value') == 1)
    minEigen_Callback(hObject, eventdata, handles)
elseif (get(handles.fast,'Value') == 1)
    fast_Callback(hObject, eventdata, handles)
elseif (get(handles.brisk,'Value') == 1)
    brisk_Callback(hObject, eventdata, handles)
elseif (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function analyzeWaveGui_Callback(hObject, eventdata, handles)
% hObject    handle to analyzeWaveGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
analyzeWave2;



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

%updates the features displayed if kaze features are selected
if (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numOctaves_Callback(hObject, eventdata, handles)
% hObject    handle to numOctaves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numOctaves as text
%        str2double(get(hObject,'String')) returns contents of numOctaves as a double
%updates the features displayed if kaze features are selected

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

if (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function numOctaves_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numOctaves (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numScaleLevels_Callback(hObject, eventdata, handles)
% hObject    handle to numScaleLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numScaleLevels as text
%        str2double(get(hObject,'String')) returns contents of numScaleLevels as a double
%updates the features displayed if kaze features are selected

%saves the axes and redraws them
Xaxis_copy = [];
Yaxis_copy = [];
if ~isempty(handles.Xaxis) && ~isempty(handles.Yaxis)
    Xaxis_copy = copy(handles.Xaxis);
    Yaxis_copy = copy(handles.Yaxis);
    delete(handles.Xaxis);
    delete(handles.Yaxis);
    handles.Xaxis = [];
    handles.Yaxis = [];
end

if (get(handles.kaze,'Value') == 1)
    kaze_Callback(hObject, eventdata, handles)
end

%redraws the axis from the copy
if ~isempty(Xaxis_copy) && ~isempty(Yaxis_copy)
    handles.Xaxis = drawline('Position', Xaxis_copy.Position, "Color", "magenta");
    handles.Yaxis = drawline('Position', Yaxis_copy.Position, "Color", "magenta");
    handles.Xaxis.InteractionsAllowed = "none";
    handles.Yaxis.InteractionsAllowed = "none"; 
end

guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function numScaleLevels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numScaleLevels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in drawAxesButton. Draws a horizontal line
% to represent the glottal length and a vertical line as a y-axis reference
function drawAxesButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawAxesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes = drawline(I);




function glottisLengthText_Callback(hObject, eventdata, handles)
% hObject    handle to glottisLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of glottisLengthText as text
%        str2double(get(hObject,'String')) returns contents of glottisLengthText as a double


% --- Executes during object creation, after setting all properties.
function glottisLengthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glottisLengthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in drawAxes. Draws a horixontal x-axis that
% is the length of the glottis and vertical axis for reference at the
% midline
function drawAxes_Callback(hObject, eventdata, handles)
% hObject    handle to drawAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.Xaxis)
    delete(handles.Xaxis)
end
if ~isempty(handles.Yaxis)
    delete(handles.Yaxis)
end

handles.Xaxis = drawline(handles.axes1,"Color", "magenta");
Ymidpoint = mean(handles.Xaxis.Position(:,2));
handles.Xaxis.Position = [handles.Xaxis.Position(1,1) Ymidpoint; handles.Xaxis.Position(2,1) Ymidpoint];
handles.Xaxis.InteractionsAllowed = "none";

Xmidpoint = mean(handles.Xaxis.Position(:,1));
yLength = (handles.Xaxis.Position(1,1) - handles.Xaxis.Position(2,1))/3;
handles.Yaxis = drawline('Position', [Xmidpoint, Ymidpoint + yLength; Xmidpoint, Ymidpoint - yLength],"Color", "magenta");
handles.Yaxis.InteractionsAllowed = "none";

handles.origin = [Xmidpoint, Ymidpoint];
val = str2num(handles.glottisLengthField.String);
Xlength = (handles.Xaxis.Position(2,1) - handles.Xaxis.Position(1,1));
handles.GPratio = Xlength/val;

guidata(hObject, handles);




function glottisLengthField_Callback(hObject, eventdata, handles)
% hObject    handle to glottisLengthField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of glottisLengthField as text
%        str2double(get(hObject,'String')) returns contents of glottisLengthField as a double
if ~isempty(handles.Xaxis)
    val = str2num(handles.glottisLengthField.String);
    Xlength = (handles.Xaxis.Position(2,1) - handles.Xaxis.Position(1,1));
    handles.GPratio = Xlength/val;
end
handles.glottisLengthFlag = 1;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function glottisLengthField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glottisLengthField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function RunCombineToHeatmap_Callback(hObject, eventdata, handles)
% hObject    handle to RunCombineToHeatmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%select all input files
[inputFileName,inputPathName]=uigetfile('*.mat','Select the INPUT DATA FILE(s)','MultiSelect','on');

%holds a struct of each of the input files
combinedStruct = repmat(struct('data', [], "GPratio", 0,'originPt', ...
        [], 'glottalLength', 0,'Img', []), length(inputFileName(1,:)),1);

% %adds each input file to the struct
addpath(inputPathName);
for i = 1:1:length(inputFileName(1,:))
    structToAdd = load(cell2mat(inputFileName(1,i)))
    combinedStruct(i) = struct('data', structToAdd.output_table.data, "GPratio", structToAdd.output_table.GPratio,'originPt', ...
        structToAdd.output_table.originPt, 'glottalLength', structToAdd.output_table.glottalLength,'Img', structToAdd.output_table.Img);
    
    
end
CombineToHeatmap(combinedStruct);
return
