function varargout = WormGUI(varargin)
% WORMGUI M-file for WormGUI.fig
%      WORMGUI, by itself, creates a new WORMGUI or raises the existing
%      singleton*.
%
%      H = WORMGUI returns the handle to a new WORMGUI or the handle to
%      the existing singleton*.
%
%      WORMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORMGUI.M with the given input arguments.
%
%      WORMGUI('Property','Value',...) creates a new WORMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WormGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WormGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WormGUI

% Last Modified by GUIDE v2.5 03-May-2009 19:07:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WormGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @WormGUI_OutputFcn, ...
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

% --- Executes just before WormGUI is made visible.
function WormGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WormGUI (see VARARGIN)

% Choose default command line output for WormGUI
handles.output = hObject;

handles.Rx=zeros(6,5);
handles.Ry=zeros(6,5);
handles.ActiveRegion = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WormGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WormGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%"FIRST FILE NAME"
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


%"FIRST FILE NAME"
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%"LAST FILE NAME"
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

%"LAST FILE NAME"
% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%"RUN"
% --- Executes on button press in pushbutton1 .
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 "RUN" (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  LastFileName=get(handles.edit2,'String');
  FirstFileName=get(handles.edit1,'String');
  handles = guidata(gcbo);
  set(handles.text1,'String',['PROCESSING - Please wait']);
  pause(1);
  [handles.WormData,handles.Fquiescent,handles.FQ]=RunWorms(FirstFileName,LastFileName,handles.Rx,handles.Ry);
  guidata(gcbo,handles);
  set(handles.text1,'String',['FINISHED PROCESSING']);
 

%"MARK REGION"
% --- Executes on button press in pushbutton3 .
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.edit1,'String');
    handles = guidata(gcbo);
    i=handles.ActiveRegion;
    set(handles.text1,'String',['Draw box around region.']);
    pause(1);
    [Rx(i,:),Ry(i,:)]=SetRegions(FirstFileName);
    handles.Rx(i,:) = Rx(i,:);
    handles.Ry(i,:) = Ry(i,:);
    guidata(gcbo,handles);
    set(handles.text1,'String',['Select another region or press "Run".']);

%"WORM ACTIVITY"
% --- Executes on button press in pushbutton4 .
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.edit1,'String');
    LastFileName=get(handles.edit2,'String');
    handles = guidata(gcbo);
    Rx=handles.Rx(handles.ActiveRegion,:);
    Ry=handles.Ry(handles.ActiveRegion,:);
    ActiveRegion=handles.ActiveRegion;
    WormData=handles.WormData(handles.ActiveRegion,:);
    set(handles.text1,'String',['Click on data point to view details.']);
    WormActivity(FirstFileName,LastFileName,WormData,ActiveRegion,Rx,Ry);
    set(handles.text1,'String',['Select function.']);
   
    
%"FRACT. QUIECENT"
% --- Executes on button press in pushbutton4 .
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    FirstFileName=get(handles.edit1,'String');
    LastFileName=get(handles.edit2,'String');
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
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  OutputFileName=get(handles.edit4,'String');
  handles = guidata(gcbo);  
  set(handles.text1,'String',['SAVING']);
  Sq=size(handles.FQ,2);
  Sw=size(handles.WormData,2);
  dlmwrite(OutputFileName, [handles.WormData(:,1:Sq)',handles.FQ',handles.Fquiescent'],',');
  dlmwrite(OutputFileName, handles.WormData(:,Sq+1:Sw)','-append','delimiter', ',');
  set(handles.text1,'String',['Finished Saving']);

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


