%% ȫ�ֱ���
function GlobalVariable(handles)
    global g_strPlane;              % ��ͼ����ͼ����ά��ͼ��X-Yƽ�棬Y-Zƽ�棬Z-Xƽ��
    global g_bDrawControlPoint;     % NURBS���ߵĿ��Ƶ㻭ͼ
    global g_IJLIncrementalMode;    % Բ�����IJK������ʽ
    global g_nScatterPrecision;     % ������ɢ����
    global g_vecColor;              % ͼ����ɫ��line point, arc point, nurbs point, control point
    
    % ��ʼ��
    g_strPlane = handles.metricdata.Plane;
    g_bDrawControlPoint = handles.metricdata.DisplayCP;
    g_IJLIncrementalMode = handles.metricdata.IJKIncrementalMode;
    g_nScatterPrecision = handles.metricdata.ScatterPrecision;
    g_vecColor{1} = handles.metricdata.firstFileColor;
    g_vecColor{2} = handles.metricdata.secondFileColor;
end