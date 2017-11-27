function varargout = DataAnalysisTool(varargin)
% DATAANALYSISTOOL MATLAB code for DataAnalysisTool.fig
%      DATAANALYSISTOOL, by itself, creates a new DATAANALYSISTOOL or raises the existing
%      singleton*.
%
%      H = DATAANALYSISTOOL returns the handle to a new DATAANALYSISTOOL or the handle to
%      the existing singleton*.
%
%      DATAANALYSISTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAANALYSISTOOL.M with the given input arguments.
%
%      DATAANALYSISTOOL('Property','Value',...) creates a new DATAANALYSISTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataAnalysisTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataAnalysisTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataAnalysisTool

% Last Modified by GUIDE v2.5 26-Nov-2017 18:02:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataAnalysisTool_OpeningFcn, ...
                   'gui_OutputFcn',  @DataAnalysisTool_OutputFcn, ...
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


% --- Executes just before DataAnalysisTool is made visible.
function DataAnalysisTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataAnalysisTool (see VARARGIN)

% Choose default command line output for DataAnalysisTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%% ��ʼ��GUI
Initialize_gui(handles);

% UIWAIT makes DataAnalysisTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataAnalysisTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%��ʼ��GUI
function Initialize_gui(handles)
global FileEntity;
if isfield(handles, 'metricdata')
    return;
end
display('��������������������������������������������������������������������������������');
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
% global parameter
handles.metricdata.period = 0.001;
handles.metricdata.dataFormat = '%f %f %f';
handles.metricdata.validColumn = '1 2';
% data pre-process
handles.metricdata.deleteRepeat = 1;
% list files parameter
handles.metricdata.dataFiles = {'', '', '', '', '', ''};
% draw option parameter
handles.metricdata.singleAxisMode = 0;
handles.metricdata.drawTrack = 1;
handles.metricdata.drawTimeSpeed = 1;
handles.metricdata.drawTimeAcc = 0;
handles.metricdata.drawTimeJerk = 0;
handles.metricdata.drawDistSpeed = 0;
% cut option parameter
handles.metricdata.cutTime1 = {0, 0};
handles.metricdata.cutTime2 = {0, 0};
handles.metricdata.cutTime3 = {0, 0};
% file directory
handles.metricdata.dataFileDir = which('DataAnalysisTool.exe');
index = strfind(handles.metricdata.dataFileDir, 'DataAnalysisTool.exe');
handles.metricdata.dataFileDir = handles.metricdata.dataFileDir(1:index-1);
% Data Process Initialize
set(handles.edit_Period, 'String', handles.metricdata.period);
set(handles.edit_DataFormat, 'String', handles.metricdata.dataFormat);
set(handles.edit_ValidColumn, 'String', handles.metricdata.validColumn);
set(handles.checkbox_DeleteRepeat, 'Value', handles.metricdata.deleteRepeat);
set(handles.text_DataFile1, 'String', handles.metricdata.dataFiles{1});
set(handles.text_DataFile2, 'String', handles.metricdata.dataFiles{2});
set(handles.text_DataFile3, 'String', handles.metricdata.dataFiles{3});
set(handles.text_DataFile4, 'String', handles.metricdata.dataFiles{4});
set(handles.text_DataFile5, 'String', handles.metricdata.dataFiles{5});
set(handles.text_DataFile6, 'String', handles.metricdata.dataFiles{6});
set(handles.checkbox_SingleAxisMode, 'Value', handles.metricdata.singleAxisMode);
set(handles.checkbox_DrawTrack, 'Value', handles.metricdata.drawTrack);
set(handles.checkbox_DrawTimeSpeed, 'Value', handles.metricdata.drawTimeSpeed);
set(handles.checkbox_DrawTimeAcc, 'Value', handles.metricdata.drawTimeAcc);
set(handles.checkbox_DrawTimeJerk, 'Value', handles.metricdata.drawTimeJerk);
set(handles.checkbox_DrawDistSpeed, 'Value', handles.metricdata.drawDistSpeed);
set(handles.edit_StartTime1, 'String', handles.metricdata.cutTime1{1});
set(handles.edit_EndTime1, 'String', handles.metricdata.cutTime1{2});
set(handles.edit_StartTime2, 'String', handles.metricdata.cutTime2{1});
set(handles.edit_EndTime2, 'String', handles.metricdata.cutTime2{2});
set(handles.edit_StartTime3, 'String', handles.metricdata.cutTime3{1});
set(handles.edit_EndTime3, 'String', handles.metricdata.cutTime3{2});
% Update Tool Figure handles structure
set(handles.figure1, 'NumberTitle', 'off', 'Name', '���ݷ�������');
% Save the value of parameters
guidata(handles.figure1, handles);


%%% ��������
function edit_Period_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Period as text
%        str2double(get(hObject,'String')) returns contents of edit_Period as a double
period = str2double(get(hObject, 'String'));
if isnan(period) || period <= 0
    set(hObject, 'String', handles.metricdata.period);
    errordlg('��������ȷ�Ŀ������ڣ�', 'Error');
    return;
end
handles.metricdata.period = period;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_Period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ���ݸ�ʽ
function edit_DataFormat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DataFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DataFormat as text
%        str2double(get(hObject,'String')) returns contents of edit_DataFormat as a double
dataFormat = get(hObject, 'String');
% ������ݸ�ʽ
handles.metricdata.dataFormat = dataFormat;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_DataFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DataFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ��Ч������
function edit_ValidColumn_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ValidColumn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ValidColumn as text
%        str2double(get(hObject,'String')) returns contents of edit_ValidColumn as a double
validColumn = get(hObject, 'String');
% �����Ч�����У�ֻ�ܰ������ֺͿո�
for i = 1:length(validColumn)
    c = validColumn(i);
    if c ~= ' ' && (c < '0' || c > '9')
        set(hObject, 'String', handles.metricdata.validColumn);
        errordlg('��������ȷ����Ч�����У�ֻ�ܰ������ֺͿո�', 'Warning');
        return;
    end
end
% �������ֵ�Ƿ������
validColumnNum = textscan(validColumn, '%f');
validColumnNum = validColumnNum{1};
if length(validColumnNum) < 1 || validColumnNum(1) < 1
    set(hObject, 'String', handles.metricdata.validColumn);
    errordlg('��������ȷ����Ч�����У���Ч�����б������1��', 'Warning');
    return;
end
handles.metricdata.validColumn = validColumn;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_ValidColumn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ValidColumn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ɾ����β��������
% --- Executes on button press in checkbox_DeleteRepeat.
function checkbox_DeleteRepeat_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DeleteRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DeleteRepeat
handles.metricdata.deleteRepeat = get(hObject, 'Value');
guidata(hObject, handles);


%%% �����ļ�
% --- Executes on button press in pushbutton_ImportFiles.
function pushbutton_ImportFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ImportFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [fileNames, fileDir] = uigetfile({'*.*', '�����ļ�(*.*)'},...
        'Open File', 'MultiSelect', 'on', handles.metricdata.dataFileDir);
catch
    errordlg('�򿪼ӹ��ļ�ʧ�ܣ�', '����');
    return;
end
if isempty(fileNames) || isnumeric(fileNames)
    errordlg('�����ļ�Ϊ�գ�', '����');
    return;
end
% �����ļ�Ŀ¼
handles.metricdata.dataFileDir = fileDir;
if ~iscell(fileNames)
    % ֻ��һ���ļ�
    handles.metricdata.dataFiles{1} = strcat(fileDir, fileNames);
    for i = 2:6
        handles.metricdata.dataFiles{i} = '';
    end
elseif length(fileNames) > 6
    errordlg('ͬʱ���ֻ�ܴ������ļ���������ѡ��', '����');
    return;
else
    % ��������ļ�
    for i = 1:length(fileNames)
        handles.metricdata.dataFiles{i} = strcat(fileDir, fileNames{i});
    end
    for i = length(fileNames)+1:6
        handles.metricdata.dataFiles{i} = '';
    end
end
set(handles.text_DataFile1, 'String', handles.metricdata.dataFiles{1});
set(handles.text_DataFile2, 'String', handles.metricdata.dataFiles{2});
set(handles.text_DataFile3, 'String', handles.metricdata.dataFiles{3});
set(handles.text_DataFile4, 'String', handles.metricdata.dataFiles{4});
set(handles.text_DataFile5, 'String', handles.metricdata.dataFiles{5});
set(handles.text_DataFile6, 'String', handles.metricdata.dataFiles{6});
guidata(hObject, handles);


%%% ��ͼ�Ƚ�
% --- Executes on button press in pushbutton_DrawAndCompare.
function pushbutton_DrawAndCompare_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DrawAndCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GlobalVariable(handles);
allFiles = ParseValidFilePath(handles.metricdata.dataFiles);
[allMotionTracks, allMotionFlags] = GetMotionTrack(allFiles);
AnalysisMotionTrack(allMotionTracks, allMotionFlags);


%%% ִ�м���
% --- Executes on button press in pushbutton_ExecCut.
function pushbutton_ExecCut_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ExecCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ��鵱ǰ�Ƿ�ֻ��һ���ļ�
allFiles = ParseValidFilePath(handles.metricdata.dataFiles);
if length(allFiles) < 1
    errordlg('�����ļ�Ϊ�գ�', '����');
    return;
elseif length(allFiles) > 1
    errordlg('ֻ֧�ֶԵ����ļ����м��У�', '����');
    return;
end
% ����Ƿ������Ч�ļ��з�Χ
if handles.metricdata.cutTime1{1} >= handles.metricdata.cutTime1{2}...
    && handles.metricdata.cutTime2{1} >= handles.metricdata.cutTime2{2}...
    && handles.metricdata.cutTime3{1} >= handles.metricdata.cutTime3{2}
    errordlg('û����Ч�ļ��з�Χ��', '����');
    return;
end
% ���з�Χ
GlobalVariable(handles);
global g_period;
cutIndexs = cell(3,1);
index = 0;
if handles.metricdata.cutTime1{1} < handles.metricdata.cutTime1{2}
    index = index + 1;
    cutIndexs{index}.startIndex = int32(handles.metricdata.cutTime1{1} / g_period);
    cutIndexs{index}.endIndex = int32(handles.metricdata.cutTime1{2} / g_period);
end
if handles.metricdata.cutTime2{1} < handles.metricdata.cutTime2{2}
    index = index + 1;
    cutIndexs{index}.startIndex = int32(handles.metricdata.cutTime2{1} / g_period);
    cutIndexs{index}.endIndex = int32(handles.metricdata.cutTime2{2} / g_period);
end
if handles.metricdata.cutTime3{1} < handles.metricdata.cutTime3{2}
    index = index + 1;
    cutIndexs{index}.startIndex = int32(handles.metricdata.cutTime3{1} / g_period);
    cutIndexs{index}.endIndex = int32(handles.metricdata.cutTime3{2} / g_period);
end
cutIndexs = cutIndexs(1:index);
% ִ�м���
[cutMotionTracks, cutMotionFlags] = GetCutMotionTrack(allFiles{1}, cutIndexs);
AnalysisMotionTrack(cutMotionTracks, cutMotionFlags);


%%% ���ͼ��
% --- Executes on button press in pushbutton_ClearFigure.
function pushbutton_ClearFigure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ClearFigure (see GCBO)
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
            oneObj = find(allObj == FileEntity{i}.FigHandle);
            if size(oneObj, 1) ~= 0
                close(FileEntity{i}.FigHandle);
            end
            FileEntity(i) = [];
            i = i - 1;
        end
        FileEntity{1}.FigHandle = 1;
    end
catch
    errordlg('Figure�ر�ʱ����', '����');
end
uiresume(handles.figure1);


%%% �رչ���
% --- Executes on button press in pushbutton_CloseTool.
function pushbutton_CloseTool_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_CloseTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
clear all;


%%% ��һ����ʼʱ��
function edit_StartTime1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StartTime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StartTime1 as text
%        str2double(get(hObject,'String')) returns contents of edit_StartTime1 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime1{1});
    errordlg('��������ȷ����ʼʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime1{1} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_StartTime1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StartTime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ��һ����ֹʱ��
function edit_EndTime1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EndTime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EndTime1 as text
%        str2double(get(hObject,'String')) returns contents of edit_EndTime1 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime1{2});
    errordlg('��������ȷ����ֹʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime1{2} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_EndTime1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EndTime1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% �ڶ�����ʼʱ��
function edit_StartTime2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StartTime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StartTime2 as text
%        str2double(get(hObject,'String')) returns contents of edit_StartTime2 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime2{1});
    errordlg('��������ȷ����ʼʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime2{1} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_StartTime2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StartTime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% �ڶ�����ֹʱ��
function edit_EndTime2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EndTime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EndTime2 as text
%        str2double(get(hObject,'String')) returns contents of edit_EndTime2 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime2{2});
    errordlg('��������ȷ����ֹʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime2{2} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_EndTime2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EndTime2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ��������ʼʱ��
function edit_StartTime3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_StartTime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_StartTime3 as text
%        str2double(get(hObject,'String')) returns contents of edit_StartTime3 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime3{1});
    errordlg('��������ȷ����ʼʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime3{1} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_StartTime3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_StartTime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ��������ֹʱ��
function edit_EndTime3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EndTime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EndTime3 as text
%        str2double(get(hObject,'String')) returns contents of edit_EndTime3 as a double
time = str2double(get(hObject, 'String'));
if isnan(time) || time < 0
    set(hObject, 'String', handles.metricdata.cutTime3{2});
    errordlg('��������ȷ����ֹʱ�䣡', 'Error');
    return;
end
handles.metricdata.cutTime3{2} = time;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_EndTime3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EndTime3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%% ���켣ͼ
% --- Executes on button press in checkbox_DrawTrack.
function checkbox_DrawTrack_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DrawTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DrawTrack
handles.metricdata.drawTrack = get(hObject, 'Value');
guidata(hObject, handles);


%%% ��ʱ��-�ٶ�ͼ
% --- Executes on button press in checkbox_DrawTimeSpeed.
function checkbox_DrawTimeSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DrawTimeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DrawTimeSpeed
handles.metricdata.drawTimeSpeed = get(hObject, 'Value');
guidata(hObject, handles);


%%% ��ʱ��-���ٶ�ͼ
% --- Executes on button press in checkbox_DrawTimeAcc.
function checkbox_DrawTimeAcc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DrawTimeAcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DrawTimeAcc
handles.metricdata.drawTimeAcc = get(hObject, 'Value');
guidata(hObject, handles);


%%% ��ʱ��-�Ӽ��ٶ�ͼ
% --- Executes on button press in checkbox_DrawTimeJerk.
function checkbox_DrawTimeJerk_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DrawTimeJerk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DrawTimeJerk
handles.metricdata.drawTimeJerk = get(hObject, 'Value');
guidata(hObject, handles);


%%% ������-�ٶ�ͼ
% --- Executes on button press in checkbox_DrawDistSpeed.
function checkbox_DrawDistSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DrawDistSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DrawDistSpeed
handles.metricdata.drawDistSpeed = get(hObject, 'Value');
guidata(hObject, handles);


%%% ����ģʽ
% --- Executes on button press in checkbox_SingleAxisMode.
function checkbox_SingleAxisMode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SingleAxisMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SingleAxisMode
handles.metricdata.singleAxisMode = get(hObject, 'Value');
guidata(hObject, handles);