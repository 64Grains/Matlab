%% ȫ�ֱ���
function GlobalVariable(handles)
    % ����
    global g_period;            % ��������
    global g_dataFormat;        % ���ݸ�ʽ
    global g_validColumn;       % ��Ч������
    global g_deleteRepeat;      % ɾ����β�ظ�����
    global g_SingleAxisMode;    % ����ģʽ����ģʽ��ֻ�ܷ��������ٶȡ����ٶȺͼӼ��ٶȣ����ܻ��켣�;���-�ٶ�ͼ
    global g_drawTrack;         % ���켣ͼ
    global g_drawTimeSpeed;     % ��ʱ��-�ٶ�ͼ
    global g_drawTimeAcc;       % ��ʱ��-���ٶ�ͼ
    global g_drawTimeJerk;      % ��ʱ��-�Ӽ��ٶ�ͼ
    global g_drawDistSpeed;     % ������-�ٶ�ͼ
    % ��ʼ��
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