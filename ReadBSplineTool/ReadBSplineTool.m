function varargout = ReadBSplineTool(varargin)
% READBSPLINETOOL MATLAB code for ReadBSplineTool.fig
%      READBSPLINETOOL, by itself, creates a new READBSPLINETOOL or raises the existing
%      singleton*.
%
%      H = READBSPLINETOOL returns the handle to a new READBSPLINETOOL or the handle to
%      the existing singleton*.
%
%      READBSPLINETOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READBSPLINETOOL.M with the given input arguments.
%
%      READBSPLINETOOL('Property','Value',...) creates a new READBSPLINETOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ReadBSplineTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ReadBSplineTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ReadBSplineTool

% Last Modified by GUIDE v2.5 06-Apr-2018 14:56:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ReadBSplineTool_OpeningFcn, ...
                   'gui_OutputFcn',  @ReadBSplineTool_OutputFcn, ...
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


% --- Executes just before ReadBSplineTool is made visible.
function ReadBSplineTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ReadBSplineTool (see VARARGIN)

% Choose default command line output for ReadBSplineTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%% 初始化GUI
Initialize_gui(hObject, handles);

% UIWAIT makes ReadBSplineTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ReadBSplineTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%初始化GUI
function Initialize_gui(hObject, handles)
global FileEntity;
if isfield(handles, 'metricdata')
    return;
end
display('————————————————————————————————————————');
% Initialize FileEntity
FileEntity{1}.FigHandle = 1;
if size(FileEntity,2) > 1
    for i = 2:size(FileEntity,2)
        allObj = findobj;
        bOneObj = find(allObj == FileEntity{i}.FigHandle);
        if size(bOneObj,1) ~= 0
            close(FileEntity{i}.FigHandle);
        end
        FileEntity(i) = [];
    end
    FileEntity{1}.FigHandle = 1;
end
% Tool Figure Handle Initialize
handles.figure1(1);
% Initialize UI parameter
handles.metricdata.Plane = 'X-Y平面';
handles.metricdata.DisplayCP = 0;
handles.metricdata.IJKIncrementalMode = 0;
handles.metricdata.ScatterPrecision = 0.01;
handles.metricdata.firstFileColor = cell(1,4);
handles.metricdata.secondFileColor = cell(1,4);
handles.metricdata.firstFileColor{1} = '.--b';
handles.metricdata.firstFileColor{2} = '.--m';
handles.metricdata.firstFileColor{3} = '.--r';
handles.metricdata.firstFileColor{4} = 'o--k';
for i = 1:3
    handles.metricdata.secondFileColor{i} = '*-g';
end
handles.metricdata.secondFileColor{4} = 'x-g';
handles.metricdata.PathName = which('ReadBSplineTool.exe');
n_PathIndex = strfind(handles.metricdata.PathName, 'ReadBSplineTool.exe');
handles.metricdata.PathName = handles.metricdata.PathName(1:n_PathIndex-1);
handles.metricdata.FirstFileName = '';
handles.metricdata.SecondFileName = '';
% Data Process Initialize
set(handles.popupmenu_view, 'String', {'X-Y平面', 'Y-Z平面', 'Z-X平面', '三维视图'});
set(handles.checkbox_displayControlPoint, 'Value', handles.metricdata.DisplayCP);
set(handles.checkbox_arcIJKMode, 'Value', handles.metricdata.IJKIncrementalMode);
set(handles.edit_scatterPrecision, 'String', handles.metricdata.ScatterPrecision);
set(handles.edit_firstFileLine, 'String', handles.metricdata.firstFileColor{1});
set(handles.edit_firstFileArc, 'String', handles.metricdata.firstFileColor{2});
set(handles.edit_firstFileNurbs, 'String', handles.metricdata.firstFileColor{3});
set(handles.edit_firstFileControlPoint, 'String', handles.metricdata.firstFileColor{4});
set(handles.edit_secondFileLine, 'String', handles.metricdata.secondFileColor{1});
set(handles.edit_secondFileArc, 'String', handles.metricdata.secondFileColor{2});
set(handles.edit_secondFileNurbs, 'String', handles.metricdata.secondFileColor{3});
set(handles.edit_secondFileControlPoint, 'String', handles.metricdata.secondFileColor{4});
set(handles.edit_firstFile, 'String', handles.metricdata.FirstFileName);
set(handles.edit_secondFile, 'String', handles.metricdata.SecondFileName);
% Update Tool Figure handles structure
set(handles.figure1, 'NumberTitle', 'off', 'Name', '数据分析工具');
% Save the value of parameters
guidata(handles.figure1, handles);


%%% 选择视图
% --- Executes on selection change in popupmenu_view.
function popupmenu_view_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_view contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_view
nPlaneIndex = get(handles.popupmenu_view, 'Value');
listContents = cellstr(get(hObject, 'String'));
strPlane = listContents{nPlaneIndex};
if isempty(strPlane)
    set(hObject, 'String', handles.metricdata.Plane);
    errordlg('请选择正确的视图名称！', 'Error');
    return;
end
handles.metricdata.Plane = strPlane;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_view_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 显示NURBS曲线的控制点
% --- Executes on button press in checkbox_displayControlPoint.
function checkbox_displayControlPoint_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_displayControlPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_displayControlPoint
bDisplayControlPoint = get(hObject,'Value');
handles.metricdata.DisplayCP = bDisplayControlPoint;
guidata(hObject, handles);


%%% 圆心编程IJK增量方式
% --- Executes on button press in checkbox_arcIJKMode.
function checkbox_arcIJKMode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_arcIJKMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_arcIJKMode
bIJKIncrementalMode = get(hObject, 'Value');
handles.metricdata.IJKIncrementalMode = bIJKIncrementalMode;
guidata(hObject, handles);


%%% 曲线离散精度
function edit_scatterPrecision_Callback(hObject, eventdata, handles)
% hObject    handle to edit_scatterPrecision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_scatterPrecision as text
%        str2double(get(hObject,'String')) returns contents of edit_scatterPrecision as a double
nScatterPrecision = str2double(get(hObject, 'String'));
if isnan(nScatterPrecision) || nScatterPrecision < 0.0001 || nScatterPrecision > 1
    set(hObject, 'String', handles.metricdata.ScatterPrecision);
    errordlg('请输入正确的离散精度（取值范围：[0.0001, 1]）！', 'Error');
    return;
end
handles.metricdata.ScatterPrecision = nScatterPrecision;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_scatterPrecision_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scatterPrecision (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 导入文件
% --- Executes on button press in pushbutton_importFiles.
function pushbutton_importFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_importFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%% 检查加工文件
FileName = [];
try
    [FileName, PathName] = uigetfile({'*.*', '所有文件(*.*)'}, 'Open File',...
        'MultiSelect', 'on', handles.metricdata.PathName);
catch ErrorInfo
    errordlg(ErrorInfo.message, '错误');
    return;
end
if isempty(FileName) || isnumeric(FileName)
    return;
end
%%% 设置加工文件路径
if ~iscell(FileName)
    % 只有一个文件
    handles.metricdata.PathName = PathName;
    handles.metricdata.FirstFileName = strcat(PathName, FileName);
elseif length(FileName) > 2
    errordlg('同时最多只能打开两个文件，请重新选择!', '错误');
    return;
else
    handles.metricdata.PathName = PathName;
    handles.metricdata.FirstFileName = strcat(PathName, FileName{1});
    handles.metricdata.SecondFileName = strcat(PathName, FileName{2});
end
set(handles.edit_firstFile, 'String', handles.metricdata.FirstFileName);
set(handles.edit_secondFile, 'String', handles.metricdata.SecondFileName);
guidata(hObject, handles);


%%% 画图比较
% --- Executes on button press in pushbutton_drawAndCompare.
function pushbutton_drawAndCompare_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_drawAndCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FileEntity;
% 检查加工文件
bFirstFileExist = ~isempty(handles.metricdata.FirstFileName);
bSecondFileExist = ~isempty(handles.metricdata.SecondFileName);
if ~bFirstFileExist && ~bSecondFileExist
    msgbox('请先输入加工文件的路径, 然后再执行该操作!');
    return;
end
%%% 设置用于画图的全局变量
GlobalVariable(handles);
% 画图
nFigureId = FileEntity{end}.FigHandle;
msgHandle = msgbox('正在准备图像数据, 请耐心等待....', '', 'help');
hFirst = 0;
hSecond = 0;
try
    if bFirstFileExist
        hFirst = AnalyseAndDrawGFile(handles.metricdata.FirstFileName, nFigureId+1, 1);
    end
    if bSecondFileExist
        hSecond = AnalyseAndDrawGFile(handles.metricdata.SecondFileName, nFigureId+1, 2);
    end
catch ErrorInfo
    close(msgHandle);
    errordlg(ErrorInfo.message, '错误');
    return;
end
close(msgHandle);
% 图例
ExecLegendIntem(handles, bFirstFileExist, hFirst, bSecondFileExist, hSecond);
% 更新FileEntity
nSize = size(FileEntity,2);
FileEntity{nSize+1}.FigHandle = nFigureId + 1;

%%% 图例
function ExecLegendIntem(handles, bFirstFileExist, hFirst, bSecondFileExist, hSecond)
vecFileFlag = {'line: ', 'arc: ', 'nurbs: ', 'controlpoint: '};
vecHandles = zeros(1,8);
vecFileNames = cell(1,8);
nIndex = 0;
if bFirstFileExist
    nFirstIndex = strfind(handles.metricdata.FirstFileName, '\');
    strFirstFileName = handles.metricdata.FirstFileName(nFirstIndex(length(nFirstIndex))+1:end);
    for i = 1:length(hFirst)
        if 0 == hFirst(i)
            continue;
        end
        nIndex = nIndex + 1;
        vecHandles(nIndex) = hFirst(i);
        vecFileNames{nIndex} = [vecFileFlag{i}, strFirstFileName];
    end
end
if bSecondFileExist
    nSecondIndex = strfind(handles.metricdata.SecondFileName, '\');
    strSecondFileName = handles.metricdata.SecondFileName(nSecondIndex(length(nSecondIndex))+1:end);
    for i = 1:length(hSecond)
        if 0 == hSecond(i)
            continue;
        end
        nIndex = nIndex + 1;
        vecHandles(nIndex) = hSecond(i);
        vecFileNames{nIndex} = [vecFileFlag{i}, strSecondFileName];
    end
end
legend(vecHandles(1:nIndex), vecFileNames(1:nIndex));


%%% 清空图像
% --- Executes on button press in pushbutton_clearFigure.
function pushbutton_clearFigure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FileEntity;
try
    if size(FileEntity,2) < 2
        FileEntity{1}.FigHandle = 1;
    else
        nSize = size(FileEntity,2);
        i = nSize;
        while i > 1
            allObj = findobj;
            bOneObj = find(allObj == FileEntity{i}.FigHandle);
            if size(bOneObj, 1) ~= 0
                close(FileEntity{i}.FigHandle);
            end
            FileEntity(i) = [];
            i = i - 1;
        end
        FileEntity{1}.FigHandle = 1;
    end
catch ErrorInfo
    errordlg(ErrorInfo.message, '错误');
end
uiresume(handles.figure1);


%%% 关闭工具
% --- Executes on button press in pushbutton_closeTool.
function pushbutton_closeTool_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closeTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
clear all;



%%% 第一个加工文件
function edit_firstFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstFile as text
%        str2double(get(hObject,'String')) returns contents of edit_firstFile as a double
strFirstFile = get(hObject, 'String');
if isempty(strFirstFile)
    % 清空文件
    handles.metricdata.FirstFileName = '';
    set(hObject, 'String', handles.metricdata.FirstFileName);
    guidata(hObject, handles);
    return;
end
% 检查文件是否存在
bFileExist = exist(strFirstFile, 'file');
if 0 == bFileExist || 7 == bFileExist
    set(hObject, 'String', handles.metricdata.FirstFileName);
    errordlg('文件路径不合法，请输入正确的文件路径！', '错误');
    return;
end
nxIndex = strfind(strFirstFile, '\');
if isempty(nxIndex)
    set(hObject, 'String', handles.metricdata.FirstFileName);
    errordlg('文件路径不合法，请输入正确的文件路径！', '错误');
    return;
else
    % 加工文件路径
    strFilePath = strFirstFile(1:nxIndex(length(nxIndex)));
    handles.metricdata.PathName = strFilePath;
    handles.metricdata.FirstFileName = strFirstFile;
    set(hObject, 'String', handles.metricdata.FirstFileName);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_firstFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第二个加工文件
function edit_secondFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_secondFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_secondFile as text
%        str2double(get(hObject,'String')) returns contents of edit_secondFile as a double
strSecondFile = get(hObject, 'String');
if isempty(strSecondFile)
    % 清空文件
    handles.metricdata.SecondFileName = '';
    set(hObject, 'String', handles.metricdata.SecondFileName);
    guidata(hObject, handles);
    return;
end
% 检查文件是否存在
bFileExist = exist(strSecondFile, 'file');
if 0 == bFileExist || 7 == bFileExist
    set(hObject, 'String', handles.metricdata.SecondFileName);
    errordlg('文件路径不合法，请输入正确的文件路径！', '错误');
    return;
end
nxIndex = strfind(strSecondFile, '\');
if isempty(nxIndex)
    set(hObject, 'String', handles.metricdata.SecondFileName);
    errordlg('文件路径不合法，请输入正确的文件路径！', '错误');
    return;
else
    % 加工文件
    strFilePath = strSecondFile(1:nxIndex(length(nxIndex)));
    handles.metricdata.PathName = strFilePath;
    handles.metricdata.SecondFileName = strSecondFile;
    set(hObject, 'String', handles.metricdata.SecondFileName);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_secondFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_secondFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 检查颜色是否合法
function bLegal = CheckColorLegal(strColor)
bLegal = false;
vecColor = {'b', 'g', 'r', 'c', 'm', 'y', 'k', 'w'};
vecPoint = {'.', 'o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>', 'p', 'h'};
vecLine = {'-', ':', '--'};
if (length(strColor) > 4) || (length(strColor) < 1)
    return;
end
nColorCount = 0;
for i = 1:length(vecColor)
    vecIndex = strfind(strColor, vecColor{i});
    nColorCount = nColorCount + length(vecIndex);
end
if nColorCount > 1
    return;
end
nPointCount = 0;
for i = 1:length(vecPoint)
    vecIndex = strfind(strColor, vecPoint{i});
    nPointCount = nPointCount + length(vecIndex);
end
if (nPointCount > 1) || (nColorCount + nPointCount > length(strColor))
    return;
end
nLineCount = length(strColor)-nColorCount-nPointCount;
if 0 == nLineCount
    bLegal = true;
elseif 1 == nLineCount
    if ~isempty(strfind(strColor,vecLine{1})) || ~isempty(strfind(strColor,vecLine{2}))
        bLegal = true;
    end
elseif 2 == nLineCount
    if ~isempty(strfind(strColor, vecLine{3}))
        bLegal = true;
    end
end


%%% 第一个文件的直线颜色
function edit_firstFileLine_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstFileLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstFileLine as text
%        str2double(get(hObject,'String')) returns contents of edit_firstFileLine as a double
strFirstColor = get(hObject, 'String');
if ~CheckColorLegal(strFirstColor)
    set(hObject, 'String', handles.metricdata.firstFileColor{1});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.firstFileColor{1} = strFirstColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_firstFileLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstFileLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第二个文件的直线颜色
function edit_secondFileLine_Callback(hObject, eventdata, handles)
% hObject    handle to edit_secondFileLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_secondFileLine as text
%        str2double(get(hObject,'String')) returns contents of edit_secondFileLine as a double
strSecondColor = get(hObject, 'String');
if ~CheckColorLegal(strSecondColor)
    set(hObject, 'String', handles.metricdata.secondFileColor{1});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.secondFileColor{1} = strSecondColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_secondFileLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_secondFileLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第一个文件的圆弧颜色
function edit_firstFileArc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstFileArc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstFileArc as text
%        str2double(get(hObject,'String')) returns contents of edit_firstFileArc as a double
strFirstColor = get(hObject, 'String');
if ~CheckColorLegal(strFirstColor)
    set(hObject, 'String', handles.metricdata.firstFileColor{2});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.firstFileColor{2} = strFirstColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_firstFileArc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstFileArc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第二个文件的圆弧颜色
function edit_secondFileArc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_secondFileArc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_secondFileArc as text
%        str2double(get(hObject,'String')) returns contents of edit_secondFileArc as a double
strSecondColor = get(hObject, 'String');
if ~CheckColorLegal(strSecondColor)
    set(hObject, 'String', handles.metricdata.secondFileColor{2});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.secondFileColor{2} = strSecondColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_secondFileArc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_secondFileArc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第一个文件的NURBS曲线颜色
function edit_firstFileNurbs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstFileNurbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstFileNurbs as text
%        str2double(get(hObject,'String')) returns contents of edit_firstFileNurbs as a double
strFirstColor = get(hObject, 'String');
if ~CheckColorLegal(strFirstColor)
    set(hObject, 'String', handles.metricdata.firstFileColor{3});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.firstFileColor{3} = strFirstColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_firstFileNurbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstFileNurbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第二个文件的NURBS曲线颜色
function edit_secondFileNurbs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_secondFileNurbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_secondFileNurbs as text
%        str2double(get(hObject,'String')) returns contents of edit_secondFileNurbs as a double
strSecondColor = get(hObject, 'String');
if ~CheckColorLegal(strSecondColor)
    set(hObject, 'String', handles.metricdata.secondFileColor{3});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.secondFileColor{3} = strSecondColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_secondFileNurbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_secondFileNurbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第一个文件的控制点颜色
function edit_firstFileControlPoint_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstFileControlPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstFileControlPoint as text
%        str2double(get(hObject,'String')) returns contents of edit_firstFileControlPoint as a double
strFirstColor = get(hObject, 'String');
if ~CheckColorLegal(strFirstColor)
    set(hObject, 'String', handles.metricdata.firstFileColor{4});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.firstFileColor{4} = strFirstColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_firstFileControlPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstFileControlPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% 第二个文件的控制点颜色
function edit_secondFileControlPoint_Callback(hObject, eventdata, handles)
% hObject    handle to edit_secondFileControlPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_secondFileControlPoint as text
%        str2double(get(hObject,'String')) returns contents of edit_secondFileControlPoint as a double
strSecondColor = get(hObject, 'String');
if ~CheckColorLegal(strSecondColor)
    set(hObject, 'String', handles.metricdata.secondFileColor{4});
    errordlg('图像颜色不合法，请重新输入！', '错误');
    return;
end
handles.metricdata.secondFileColor{4} = strSecondColor;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_secondFileControlPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_secondFileControlPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
