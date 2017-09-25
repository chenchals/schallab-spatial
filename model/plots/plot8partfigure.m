function varargout = plot8partfigure(varargin)
% PLOT8PARTFIGURE MATLAB code for plot8partfigure.fig
%      PLOT8PARTFIGURE, by itself, creates a new PLOT8PARTFIGURE or raises the existing
%      singleton*.
%
%      H = PLOT8PARTFIGURE returns the handle to a new PLOT8PARTFIGURE or the handle to
%      the existing singleton*.
%
%      PLOT8PARTFIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT8PARTFIGURE.M with the given input arguments.
%
%      PLOT8PARTFIGURE('Property','Value',...) creates a new PLOT8PARTFIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot8partfigure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot8partfigure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot8partfigure

% Last Modified by GUIDE v2.5 22-Sep-2017 21:53:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot8partfigure_OpeningFcn, ...
                   'gui_OutputFcn',  @plot8partfigure_OutputFcn, ...
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


% --- Executes just before plot8partfigure is made visible.
function plot8partfigure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plot8partfigure (see VARARGIN)

% Choose default command line output for plot8partfigure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plot8partfigure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plot8partfigure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4
