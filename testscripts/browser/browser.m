function varargout = browser(varargin)
% BROWSER MATLAB code for browser.fig
%      BROWSER, by itself, creates a new BROWSER or raises the existing
%      singleton*.
%
%      H = BROWSER returns the handle to a new BROWSER or the handle to
%      the existing singleton*.
%
%      BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BROWSER.M with the given input arguments.
%
%      BROWSER('Property','Value',...) creates a new BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before browser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help browser

% Last Modified by GUIDE v2.5 16-Oct-2017 16:57:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @browser_OpeningFcn, ...
                   'gui_OutputFcn',  @browser_OutputFcn, ...
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


% --- Executes just before browser is made visible.
function browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to browser (see VARARGIN)

% Choose default command line output for browser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes browser wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in getFileList.
function getFileList_Callback(hObject, eventdata, handles)
% hObject    handle to getFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns getFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from getFileList
   contents = cellstr(get(hObject,'String'));
   if numel(contents)==1
     set(hObject,'String',getFileList);
     elsehe
     selectedFile = contents{get(hObject,'Value')};
     [~,f,~] = fileparts(selectedFile);
     session = load(selectedFile);
     doPlot8R(session,f)
   end


% --- Executes during object creation, after setting all properties.
function getFileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to getFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end  

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over getFileList.
function getFileList_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to getFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   filelist = getFileList;
   set(hObject,'String',filelist);
