%% 解析刀路中的运动指令，并画图
% 参数filePath：刀路文件路径
% 参数nFigId：图片序号
% 参数nColorId：颜色序号
% 返回值figHandle：图像句柄
function figHandle = AnalyseAndDrawGFile(filePath, nFigId, nColorId)
    global g_nHandleCount;
    global g_figHandle;
    g_nHandleCount = 4;
    g_figHandle = zeros(g_nHandleCount,1);
    % 打开文件
    fidRead = fopen(filePath, 'r');
    % 编程方式：绝对值编程G90，相对值编程G91
    strG90 = '';
    % 坐标平面：XY平面G17，ZX平面G18，YZ平面G19
    strG17 = '';
    % 运动G指令标识符：G0，G1，G2，G3，G6.2
    strLastGId = '';
    strCurGId = '';
    % 坐标值：x轴坐标，y轴坐标，z轴坐标
    bSetStartPos = false;
    nxLastPos = ones(1,3) * Inf;
    nxCurPos = ones(1,3) * Inf;
    % 参数：圆心I，圆心J，圆心/NURBS曲线节点K，圆弧半径/NURBS曲线权值R，NURBS曲线幂次P
    nxCurParam = ones(1,5) * Inf;
    % 程序提前结束时的参数
    bForceEnd = false;
    % B样条曲线幂次、节点矢量和控制点
    nurbs.nLevel = 0;
    nurbs.vecKnots = [];
    nurbs.vecControlPoints = [];
    nurbs.vecWeights = [];
    % 缓存的数据点
    global g_nMaxCachePoints;
    g_nMaxCachePoints = 10000;
    InitCellPointCache(g_nMaxCachePoints, nColorId);
    % 曲线离散精度
    global g_nScatterPrecision;
    % 批量读取文件，直到到达文件末尾
    while ~feof(fidRead)
        % 一次性读取多行文件
        fAll = textscan(fidRead, '%s', 1000, 'Delimiter', '\n');
        fCell = fAll{1};
        nMaxLines = size(fCell,1);
        for i = 1:nMaxLines
            % 获取并处理每一行字符串
            strOrig = fCell{i};
            % 判断是否为空行
            if isempty(strOrig)
                continue;
            end
            % 判断是否包含G指令
            if isempty(strLastGId) && isempty(strfind(strOrig, 'G'))
                % 如果刀路中包含坐标，则G指令默认为G0
                if ~isempty(strfind(strOrig, 'X')) || ~isempty(strfind(strOrig, 'Y')) || ~isempty(strfind(strOrig, 'Z'))
                    strCurGId = 'G0';
                else
                    continue;
                end
            end
            % 判断程序是否结束
            bForceEnd = JudgeEndMachine(strOrig);
            if bForceEnd
                break;
            end
            % 读取G指令及坐标值
            [strG90, strG17, strCurGId, nxCurPos, nxCurParam] = AnalyseGCode(strOrig, strG90, strG17, strCurGId, nxCurPos, nxCurParam);
            % 判断G指令类型
            if isempty(strLastGId) && isempty(strCurGId)
                continue;
            elseif isempty(strCurGId)
                strCurGId = strLastGId;
            end
            % 将无效坐标转化为0
            if isinf(nxCurPos(1)) && isinf(nxCurPos(2)) && isinf(nxCurPos(3)) && isinf(nxCurParam(3))
                if ~isempty(strCurGId)
                    strLastGId = strCurGId;
                end
                continue;
            else
                if bSetStartPos
                    nxCurPos = GetAbsoluteAxis(strG90, nxLastPos, nxCurPos);
                else
                    nxLastPos = GetAbsoluteAxis(strG90, zeros(1,3), nxCurPos);
                    nxCurPos = nxLastPos;
                    bSetStartPos = true;
                end
            end
            % 检查上一指令是否是B样条曲线
            if ~strcmp(strLastGId, strCurGId) && strcmp(strLastGId, 'G6.2')
                % 离散B样条曲线上的点
                nurbs.vecControlPoints = nurbs.vecControlPoints(1:size(nurbs.vecControlPoints,1)-nurbs.nLevel-1,:);
                vecPoints = ScatterNurbs(nurbs, g_nScatterPrecision);
                StoreCellPointCache(vecPoints, 3, nFigId);
                StoreCellPointCache(nurbs.vecControlPoints, 4, nFigId);
                nurbs.nLevel = 0;
                nurbs.vecKnots = [];
                nurbs.vecControlPoints = [];
                nurbs.vecWeights = [];
            end
            % 分析坐标值
            if strcmp(strCurGId, 'G1')
                StoreCellPointCache([nxLastPos; nxCurPos], 1, nFigId);
            elseif strcmp(strCurGId, 'G2') || strcmp(strCurGId, 'G3')
                vecPoints = ScatterArc(strG17, strCurGId, nxLastPos, nxCurPos, nxCurParam, g_nScatterPrecision);
                StoreCellPointCache(vecPoints, 2, nFigId);
            elseif strcmp(strCurGId, 'G6.2')
                % B样条曲线的幂次
                if ~isinf(nxCurParam(5))
                    % 检查是否有两个相连的B样条曲线指令
                    if strcmp(strLastGId, 'G6.2')
                        % 离散B样条曲线上的点
                        nurbs.vecControlPoints = nurbs.vecControlPoints(1:size(nurbs.vecControlPoints,1)-nurbs.nLevel-1,:);
                        vecPoints = ScatterNurbs(nurbs, g_nScatterPrecision);
                        StoreCellPointCache(vecPoints, 3, nFigId);
                        StoreCellPointCache(nurbs.vecControlPoints, 4, nFigId);
                        nurbs.vecKnots = [];
                        nurbs.vecControlPoints = [];
                        nurbs.vecWeights = [];
                    end
                    nurbs.nLevel = nxCurParam(5);
                end
                % B样条曲线的节点矢量
                if ~isinf(nxCurParam(3))
                    nurbs.vecKnots = [nurbs.vecKnots; nxCurParam(3)];
                end
                % B样条曲线的控制点
                if 0 == size(nurbs.vecControlPoints,1)
                    nurbs.vecControlPoints = nxCurPos;
                    % 控制点的权值
                    if ~isinf(nxCurParam(4))
                        nurbs.vecWeights = nxCurParam(4);
                    end
                else
                    nurbs.vecControlPoints = [nurbs.vecControlPoints; nxCurPos];
                    if ~isinf(nxCurParam(4))
                        nurbs.vecWeights = [nurbs.vecWeights; nxCurParam(4)];
                    end
                end
            else
                if ~strcmp(strCurGId, 'G0')
                    error('错误的G指令：%s', strCurGId);
                end
            end
            % 记录上次的参数值
            strLastGId = strCurGId;
            nxLastPos = nxCurPos;
            % 参数复位
            nxCurPos = ones(1,3) * Inf;
            nxCurParam = ones(1,5) * Inf;
        end
        if bForceEnd
            break;
        end
    end
    % 最后一段为B样条曲线
    if strcmp(strLastGId, 'G6.2')
        % 离散B样条曲线上的点
        nurbs.vecControlPoints = nurbs.vecControlPoints(1:size(nurbs.vecControlPoints,1)-nurbs.nLevel-1,:);
        vecPoints = ScatterNurbs(nurbs, g_nScatterPrecision);
        StoreCellPointCache(vecPoints, 3, nFigId);
        StoreCellPointCache(nurbs.vecControlPoints, 4, nFigId);
    end
    % 刷新缓存
    for i = 1:g_nHandleCount
        FlushCellPointCache(i, nFigId);
    end
    % 关闭文件
    fclose(fidRead);
    figHandle = g_figHandle;
end

%% 初始化缓存数据点
function InitCellPointCache(nMaxSize, nColorId)
    % 参数检查
    if nColorId ~= 1 && nColorId ~= 2
        error('错误的参数：颜色序号%f\n', nColorId);
    end
    global g_vecColor;
    global g_nHandleCount;
    global g_cellPointCache;
    g_cellPointCache = cell(g_nHandleCount,1);
    for i = 1:g_nHandleCount
        % 数据点
        g_cellPointCache{i}.points = zeros(nMaxSize,3);
        % 起始索引
        g_cellPointCache{i}.index = 0;
        % 图像颜色
        g_cellPointCache{i}.color = g_vecColor{nColorId}{i};
    end
end

%% 存储缓存数据点
function StoreCellPointCache(vecPoints, nHandleIndex, nFigId)
    % 参数检查
    if size(vecPoints,1) < 2
        error('错误的参数：数据点数为%f\n', size(vecPoints,1));
    end
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('错误的参数：句柄索引为%f\n', nHandleIndex);
    end
    % 如果颜色一致，则修改句柄索引值
    global g_cellPointCache;
    for i = 1:g_nHandleCount-1
        if strcmp(g_cellPointCache{i}.color, g_cellPointCache{nHandleIndex}.color)
            nHandleIndex = i;
            break;
        end
    end
    % 存储数据点
    nPointIndex = g_cellPointCache{nHandleIndex}.index;
    if nPointIndex > 0 && ~isequal(g_cellPointCache{nHandleIndex}.points(nPointIndex,:), vecPoints(1,:))
        % 当前数据点与缓存的数据点不是首尾相连的
        vecNewPoints = g_cellPointCache{nHandleIndex}.points(1:nPointIndex,:);
        PlotFigureByPlane(vecNewPoints, nHandleIndex, nFigId, g_cellPointCache{nHandleIndex}.color);
        g_cellPointCache{nHandleIndex}.index = 0;
    end
    % 检查缓存是否装得下
    global g_nMaxCachePoints;
    nPointIndex = g_cellPointCache{nHandleIndex}.index;
    if nPointIndex + size(vecPoints,1) >= g_nMaxCachePoints
        vecNewPoints = [g_cellPointCache{nHandleIndex}.points(1:nPointIndex,:); vecPoints];
        PlotFigureByPlane(vecNewPoints, nHandleIndex, nFigId, g_cellPointCache{nHandleIndex}.color);
        g_cellPointCache{nHandleIndex}.index = 0;
        return;
    end
    % 缓存数据点
    if nPointIndex == 0
        g_cellPointCache{nHandleIndex}.points = vecPoints;
        g_cellPointCache{nHandleIndex}.index = size(vecPoints,1);
    else
        g_cellPointCache{nHandleIndex}.points(nPointIndex+1:nPointIndex+size(vecPoints,1)-1,:) = vecPoints(2:end,:);
        g_cellPointCache{nHandleIndex}.index = g_cellPointCache{nHandleIndex}.index + size(vecPoints,1) - 1;
    end
end

%% 刷新缓存数据点
function FlushCellPointCache(nHandleIndex, nFigId)
    % 参数检查
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('错误的参数：句柄索引为%f\n', nHandleIndex);
    end
    global g_cellPointCache;
    nPointIndex = g_cellPointCache{nHandleIndex}.index;
    if nPointIndex == 0
        return;
    end
    vecNewPoints = g_cellPointCache{nHandleIndex}.points(1:nPointIndex,:);
    PlotFigureByPlane(vecNewPoints, nHandleIndex, nFigId, g_cellPointCache{nHandleIndex}.color);
    g_cellPointCache{nHandleIndex}.index = 0;
end

%% 判断程序是否结束加工
% 参数strOrig：待解析的字符串
% 返回值bForceEnd：是否停止加工，true为停止，false为不停止
function bForceEnd = JudgeEndMachine(strOrig)
    bForceEnd = false;
    % 如果包含M2或M30，则程序结束
    nIndex = strfind(strOrig, 'M');
    if isempty(nIndex)
        nIndex = strfind(strOrig, 'm');
        if isempty(nIndex)
            return;
        end
    end
    % 默认第1个字符为标识符
    nResult = textscan(strOrig(nIndex:end), '%c%f', 1);
    if ~isempty(nResult{2})
        nValue = nResult{2};
        if (2 == nValue) || (30 == nValue)
            bForceEnd = true;
        end
    else
        error('索引值不存在：字符串为%s，索引为%d', strOrig, nIndex);
    end
end

%% 获取绝对坐标值
% 参数strG90：编程方式，G90为绝对坐标编程(默认值)，G91为相对坐标编程
% 参数nxLastPos：上一插补点的绝对坐标
% 参数nxCurPos：当前插补点的(绝对/相对)坐标
% 返回值nxCurPosOut：根据编程方式获取当前插补点的绝对坐标
function nxCurPosOut = GetAbsoluteAxis(strG90, nxLastPos, nxCurPos)
    % 参数检查
    if ~isempty(strG90) && strcmp(strG90, 'G90') && strcmp(strG90, 'G91')
        error('错误的编程方式：%s', strG90);
    end
    if isinf(nxLastPos(1)) && isinf(nxLastPos(2)) && isinf(nxLastPos(3))
        nxLastPos = zeros(1,3);
    end
    if isinf(nxLastPos(1)) || isinf(nxLastPos(2)) || isinf(nxLastPos(3))
        error('错误的坐标值：X=%f,Y=%f,Z=%f', nxLastPos(1), nxLastPos(2), nxLastPos(3));
    end
    % 绝对坐标
    nxCurPosOut = nxLastPos;
    for i = 1:3
        if ~isinf(nxCurPos(i)) && strcmp(strG90, 'G91')
            nxCurPosOut(i) = nxLastPos(i) + nxCurPos(i);
        elseif ~isinf(nxCurPos(i)) && ~strcmp(strG90, 'G91')
            nxCurPosOut(i) = nxCurPos(i);
        end
    end
end

%% 解析G指令及坐标值
% 参数strOrig：待解析的字符串
% 参数strG90：编程方式
% 参数strG17：坐标平面
% 参数strCurGId：G指令标识符
% 参数nxCurPos：坐标值
% 参数nxCurParam：圆弧/B样条参数
% 返回值：其余参数与输入参数类似
function [strG90Out, strG17Out, strCurGIdOut, nxCurPosOut, nxCurParamOut]...
    = AnalyseGCode(strOrig, strG90, strG17, strCurGId, nxCurPos, nxCurParam)
    % 默认值
    strG90Out = strG90;
    strG17Out = strG17;
    strCurGIdOut = strCurGId;
    nxCurPosOut = nxCurPos;
    nxCurParamOut = nxCurParam;
    % 解析字符串中的值
    vecResult = textscan(strOrig, '%c%f');
    vecFlags = vecResult{1};
    vecValues = vecResult{2};
    for i = 1:length(vecFlags)
        if strcmp(vecFlags(i), 'G') || strcmp(vecFlags(i), 'g')
            % 分类处理G指令标识符
            switch vecValues(i)
                case 1
                    strCurGIdOut = 'G1';
                case 2
                    strCurGIdOut = 'G2';
                case 3
                    strCurGIdOut = 'G3';
                case 6.2
                    strCurGIdOut = 'G6.2';
                case 0
                    strCurGIdOut = 'G0';
                case 17
                    strG17Out = 'G17';
                case 18
                    strG17Out = 'G18';
                case 19
                    strG17Out = 'G19';
                case 90
                    strG90Out = 'G90';
                case 91
                    strG90Out = 'G91';
            end
        elseif strcmp(vecFlags(i), 'X') || strcmp(vecFlags(i), 'x')
            nxCurPosOut(1) = vecValues(i);
        elseif strcmp(vecFlags(i), 'Y') || strcmp(vecFlags(i), 'y')
            nxCurPosOut(2) = vecValues(i);
        elseif strcmp(vecFlags(i), 'Z') || strcmp(vecFlags(i), 'z')
            nxCurPosOut(3) = vecValues(i);
        elseif strcmp(vecFlags(i), 'I') || strcmp(vecFlags(i), 'i')
            nxCurParamOut(1) = vecValues(i);
        elseif strcmp(vecFlags(i), 'J') || strcmp(vecFlags(i), 'j')
            nxCurParamOut(2) = vecValues(i);
        elseif strcmp(vecFlags(i), 'K') || strcmp(vecFlags(i), 'k')
            nxCurParamOut(3) = vecValues(i);
        elseif strcmp(vecFlags(i), 'R') || strcmp(vecFlags(i), 'r')
            nxCurParamOut(4) = vecValues(i);
        elseif strcmp(vecFlags(i), 'P') || strcmp(vecFlags(i), 'p')
            nxCurParamOut(5) = vecValues(i);
        end
    end
end

%% 根据坐标视图进行画图
function PlotFigureByPlane(vecFitPoint, nHandleIndex, nFigId, strColor)
    % 参数检查
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('错误的参数：句柄索引为%f\n', nHandleIndex);
    end
    global g_bDrawControlPoint;
    if nHandleIndex == g_nHandleCount
        if ~g_bDrawControlPoint
            return;
        end
    end
    % 画图
    global g_figHandle;
    global g_strPlane;
    figure(nFigId);
    hold on;
    switch g_strPlane
        case '三维视图'
            g_figHandle(nHandleIndex) = plot3(vecFitPoint(:,1), vecFitPoint(:,2), vecFitPoint(:,3), strColor);
            view([1 1 1]);
        case 'X-Y平面'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,1), vecFitPoint(:,2), strColor);
        case 'Y-Z平面'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,2), vecFitPoint(:,3), strColor);
        case 'Z-X平面'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,3), vecFitPoint(:,1), strColor);
        otherwise
            error('错误的视图：%s', g_strPlane);
    end
    axis equal;
end