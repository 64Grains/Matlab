%% 全局变量
function GlobalVariable(handles)
    global g_strPlane;              % 画图的视图：三维视图，X-Y平面，Y-Z平面，Z-X平面
    global g_bDrawControlPoint;     % NURBS曲线的控制点画图
    global g_IJLIncrementalMode;    % 圆弧编程IJK增量方式
    global g_nScatterPrecision;     % 曲线离散精度
    global g_vecColor;              % 图像颜色：line point, arc point, nurbs point, control point
    
    % 初始化
    g_strPlane = handles.metricdata.Plane;
    g_bDrawControlPoint = handles.metricdata.DisplayCP;
    g_IJLIncrementalMode = handles.metricdata.IJKIncrementalMode;
    g_nScatterPrecision = handles.metricdata.ScatterPrecision;
    g_vecColor{1} = handles.metricdata.firstFileColor;
    g_vecColor{2} = handles.metricdata.secondFileColor;
end