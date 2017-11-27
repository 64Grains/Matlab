%% 全局变量
function GlobalVariable(handles)
    % 参数
    global g_period;            % 控制周期
    global g_dataFormat;        % 数据格式
    global g_validColumn;       % 有效数据列
    global g_deleteRepeat;      % 删除首尾重复数据
    global g_SingleAxisMode;    % 单轴模式：该模式下只能分析单轴速度、加速度和加加速度，不能画轨迹和距离-速度图
    global g_drawTrack;         % 画轨迹图
    global g_drawTimeSpeed;     % 画时间-速度图
    global g_drawTimeAcc;       % 画时间-加速度图
    global g_drawTimeJerk;      % 画时间-加加速度图
    global g_drawDistSpeed;     % 画距离-速度图
    % 初始化
    g_period = handles.metricdata.period;
    g_dataFormat = handles.metricdata.dataFormat;
    g_validColumn = textscan(handles.metricdata.validColumn, '%f');
    g_validColumn = g_validColumn{1};
    g_validColumn = sort(g_validColumn);
    g_deleteRepeat = handles.metricdata.deleteRepeat;
    g_SingleAxisMode = handles.metricdata.singleAxisMode;
    g_drawTrack = handles.metricdata.drawTrack;
    g_drawTimeSpeed = handles.metricdata.drawTimeSpeed;
    g_drawTimeAcc = handles.metricdata.drawTimeAcc;
    g_drawTimeJerk = handles.metricdata.drawTimeJerk;
    g_drawDistSpeed = handles.metricdata.drawDistSpeed;
end