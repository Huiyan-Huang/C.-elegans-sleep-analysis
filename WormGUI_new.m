 function varargout = WormGUI_new(varargin)
% WORMGUI_NEW M-file for WormGUI _new.fig
%      WORMGUI_NEW, by itself, creates a new WORMGUI_NEW or raises the existing
%      singleton*.
%
%      H = WORMGUI_NEW returns the handle to a new WORMGUI_NEW or the handle to
%      the existing singleton*.
%
%      WORMGUI_NEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMGUI_NEW.M with the given input arguments.
%
%      WORMGUI_NEW('Property','Value',...) creates a new WORMGUI_NEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WormGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WormGUI_new_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WormGUI_new

% Last Modified by GUIDE v2.5 27-Jun-2014 15:34:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WormGUI_new_OpeningFcn, ...
                   'gui_OutputFcn',  @WormGUI_new_OutputFcn, ...
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

% --- Executes just before WormGUI_new is made visible.
function WormGUI_new_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WormGUI_new (see VARARGIN)

% Choose default command line output for WormGUI_new
handles.output = hObject;

handles.Rx=zeros(10,5);
handles.Ry=zeros(10,5);
handles.ActiveRegion = 1;
handles.radiobuttons=[handles.radiobutton1,handles.radiobutton2,handles.radiobutton3,handles.radiobutton4,handles.radiobutton5,handles.radiobutton6,handles.radiobutton7,handles.radiobutton8,handles.radiobutton9,handles.radiobutton10];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WormGUI_new wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WormGUI_new_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%"FIRST FILE NAME"
function Frist_Img_Callback(hObject, eventdata, handles)
% hObject    handle to Frist_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_Img as text
%        str2double(get(hObject,'String')) returns contents of Last_Img as a double


%"FIRST FILE NAME"
% --- Executes during object creation, after setting all properties.
function Frist_Img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frist_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%"LAST FILE NAME"
function Last_Img_Callback(hObject, eventdata, handles)
% hObject    handle to Last_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Last_Img as text
%        str2double(get(hObject,'String')) returns contents of Last_Img as a double

%"LAST FILE NAME"
% --- Executes during object creation, after setting all properties.
function Last_Img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Last_Img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%"RUN"
% --- Executes on button press in Run_btm .
function Run_btm_Callback(hObject, eventdata, handles)
% hObject    handle to Run_btm "RUN" (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  LastFileName=get(handles.Last_Img,'String');
  FirstFileName=get(handles.Frist_Img,'String');
  handles = guidata(gcbo);
  set(handles.text1,'String',['PROCESSING - Please wait']);
  pause(1);
  [handles.WormData,handles.Fquiescent,handles.FQ]=RunWorms(FirstFileName,LastFileName,handles.Rx,handles.Ry);
  guidata(gcbo,handles);
  set(handles.text1,'String',['FINISHED PROCESSING']);
 

%"MARK REGION"
% --- Executes on button press in Activty_btm .
function Mark_btm_Callback(hObject, eventdata, handles)
% hObject    handle to Activty_btm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.Frist_Img,'String');
    handles = guidata(gcbo);
    i=handles.ActiveRegion;
    set(handles.text1,'String',['Draw box around region.']);
    pause(1);
    [Rx(i,:),Ry(i,:)]=SetRegions(FirstFileName);
    handles.Rx(i,:) = Rx(i,:);
    handles.Ry(i,:) = Ry(i,:);
    guidata(gcbo,handles);
    set(handles.text1,'String',['Select another region or press "Run".']);
	set(handles.radiobuttons(i),'String',['+']);
    %disp(handles.Rx);

%"WORM ACTIVITY"
% --- Executes on button press in Quiec_btm .
function Activty_btm_Callback(hObject, eventdata, handles)
% hObject    handle to Quiec_btm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.Frist_Img,'String');
    LastFileName=get(handles.Last_Img,'String');
    handles = guidata(gcbo);
    Rx=handles.Rx(handles.ActiveRegion,:);
    Ry=handles.Ry(handles.ActiveRegion,:);
    ActiveRegion=handles.ActiveRegion;
    WormData=handles.WormData(handles.ActiveRegion,:);
    set(handles.text1,'String',['Click on data point to view details.']);
    WormActivity(FirstFileName,LastFileName,WormData,ActiveRegion,Rx,Ry);
    set(handles.text1,'String',['Select function.']);
   
    
%"FRACT. QUIECENT"
% --- Executes on button press in Quiec_btm .
function Quiec_btm_Callback(hObject, eventdata, handles)
% hObject    handle to Quiec_btm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.Frist_Img,'String');
    LastFileName=get(handles.Last_Img,'String');
    handles = guidata(gcbo);
    ActiveRegion=handles.ActiveRegion;
    WormData=handles.WormData(handles.ActiveRegion,:);
    set(handles.text1,'String',['Click on data point to view details.']);
    Quiecence(FirstFileName,LastFileName,WormData,ActiveRegion);
    set(handles.text1,'String',['Select function.']);

function uibuttongroup1_SelectionChangeFcn(hObject,eventdata,handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(hObject,'Tag')   % Get Tag of selected object
    case 'radiobutton1'
        handles = guidata(gcbo);
        handles.ActiveRegion = 1;
        guidata(gcbo,handles);
    case 'radiobutton2'
        handles = guidata(gcbo);
        handles.ActiveRegion = 2;
        guidata(gcbo,handles);
    case 'radiobutton3'
        handles = guidata(gcbo);
        handles.ActiveRegion = 3;
        guidata(gcbo,handles);    
    case 'radiobutton4'
        handles = guidata(gcbo);
        handles.ActiveRegion = 4;
        guidata(gcbo,handles);
    case 'radiobutton5'
        handles = guidata(gcbo);
        handles.ActiveRegion = 5;
        guidata(gcbo,handles);
    case 'radiobutton6'
        handles = guidata(gcbo);
        handles.ActiveRegion = 6;
        guidata(gcbo,handles);
    case 'radiobutton7'
        handles = guidata(gcbo);
        handles.ActiveRegion = 7;
        guidata(gcbo,handles);
    case 'radiobutton8'
        handles = guidata(gcbo);
        handles.ActiveRegion = 8;
        guidata(gcbo,handles);
    case 'radiobutton9'
        handles = guidata(gcbo);
        handles.ActiveRegion = 9;
        guidata(gcbo,handles);
    case 'radiobutton10'
        handles = guidata(gcbo);
        handles.ActiveRegion = 10;
        guidata(gcbo,handles);
end

% --- Executes on button press in Save_btm.
function Save_btm_Callback(hObject, eventdata, handles)
% hObject    handle to Save_btm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  OutputFileName=get(handles.Out_name,'String');
  handles = guidata(gcbo);  
  set(handles.text1,'String',['SAVING']);
  Sq=size(handles.FQ,2);
  Sw=size(handles.WormData,2);
  dlmwrite(OutputFileName, [handles.WormData(:,1:Sq)',handles.FQ',handles.Fquiescent'],',');
  dlmwrite(OutputFileName, handles.WormData(:,Sq+1:Sw)','-append','delimiter', ',');
  set(handles.text1,'String',['Finished Saving']);

function Out_name_Callback(hObject, eventdata, handles)
% hObject    handle to Out_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Out_name as text
%        str2double(get(hObject,'String')) returns contents of Out_name as a double

% --- Executes during object creation, after setting all properties.
function Out_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Out_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


