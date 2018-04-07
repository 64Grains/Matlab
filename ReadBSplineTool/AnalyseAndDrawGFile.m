%% ������·�е��˶�ָ�����ͼ
% ����filePath����·�ļ�·��
% ����nFigId��ͼƬ���
% ����nColorId����ɫ���
% ����ֵfigHandle��ͼ����
function figHandle = AnalyseAndDrawGFile(filePath, nFigId, nColorId)
    global g_nHandleCount;
    global g_figHandle;
    g_nHandleCount = 4;
    g_figHandle = zeros(g_nHandleCount,1);
    % ���ļ�
    fidRead = fopen(filePath, 'r');
    % ��̷�ʽ������ֵ���G90�����ֵ���G91
    strG90 = '';
    % ����ƽ�棺XYƽ��G17��ZXƽ��G18��YZƽ��G19
    strG17 = '';
    % �˶�Gָ���ʶ����G0��G1��G2��G3��G6.2
    strLastGId = '';
    strCurGId = '';
    % ����ֵ��x�����꣬y�����꣬z������
    bSetStartPos = false;
    nxLastPos = ones(1,3) * Inf;
    nxCurPos = ones(1,3) * Inf;
    % ������Բ��I��Բ��J��Բ��/NURBS���߽ڵ�K��Բ���뾶/NURBS����ȨֵR��NURBS�����ݴ�P
    nxCurParam = ones(1,5) * Inf;
    % ������ǰ����ʱ�Ĳ���
    bForceEnd = false;
    % B���������ݴΡ��ڵ�ʸ���Ϳ��Ƶ�
    nurbs.nLevel = 0;
    nurbs.vecKnots = [];
    nurbs.vecControlPoints = [];
    nurbs.vecWeights = [];
    % ��������ݵ�
    global g_nMaxCachePoints;
    g_nMaxCachePoints = 10000;
    InitCellPointCache(g_nMaxCachePoints, nColorId);
    % ������ɢ����
    global g_nScatterPrecision;
    % ������ȡ�ļ���ֱ�������ļ�ĩβ
    while ~feof(fidRead)
        % һ���Զ�ȡ�����ļ�
        fAll = textscan(fidRead, '%s', 1000, 'Delimiter', '\n');
        fCell = fAll{1};
        nMaxLines = size(fCell,1);
        for i = 1:nMaxLines
            % ��ȡ������ÿһ���ַ���
            strOrig = fCell{i};
            % �ж��Ƿ�Ϊ����
            if isempty(strOrig)
                continue;
            end
            % �ж��Ƿ����Gָ��
            if isempty(strLastGId) && isempty(strfind(strOrig, 'G'))
                % �����·�а������꣬��Gָ��Ĭ��ΪG0
                if ~isempty(strfind(strOrig, 'X')) || ~isempty(strfind(strOrig, 'Y')) || ~isempty(strfind(strOrig, 'Z'))
                    strCurGId = 'G0';
                else
                    continue;
                end
            end
            % �жϳ����Ƿ����
            bForceEnd = JudgeEndMachine(strOrig);
            if bForceEnd
                break;
            end
            % ��ȡGָ�����ֵ
            [strG90, strG17, strCurGId, nxCurPos, nxCurParam] = AnalyseGCode(strOrig, strG90, strG17, strCurGId, nxCurPos, nxCurParam);
            % �ж�Gָ������
            if isempty(strLastGId) && isempty(strCurGId)
                continue;
            elseif isempty(strCurGId)
                strCurGId = strLastGId;
            end
            % ����Ч����ת��Ϊ0
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
            % �����һָ���Ƿ���B��������
            if ~strcmp(strLastGId, strCurGId) && strcmp(strLastGId, 'G6.2')
                % ��ɢB���������ϵĵ�
                nurbs.vecControlPoints = nurbs.vecControlPoints(1:size(nurbs.vecControlPoints,1)-nurbs.nLevel-1,:);
                vecPoints = ScatterNurbs(nurbs, g_nScatterPrecision);
                StoreCellPointCache(vecPoints, 3, nFigId);
                StoreCellPointCache(nurbs.vecControlPoints, 4, nFigId);
                nurbs.nLevel = 0;
                nurbs.vecKnots = [];
                nurbs.vecControlPoints = [];
                nurbs.vecWeights = [];
            end
            % ��������ֵ
            if strcmp(strCurGId, 'G1')
                StoreCellPointCache([nxLastPos; nxCurPos], 1, nFigId);
            elseif strcmp(strCurGId, 'G2') || strcmp(strCurGId, 'G3')
                vecPoints = ScatterArc(strG17, strCurGId, nxLastPos, nxCurPos, nxCurParam, g_nScatterPrecision);
                StoreCellPointCache(vecPoints, 2, nFigId);
            elseif strcmp(strCurGId, 'G6.2')
                % B�������ߵ��ݴ�
                if ~isinf(nxCurParam(5))
                    % ����Ƿ�������������B��������ָ��
                    if strcmp(strLastGId, 'G6.2')
                        % ��ɢB���������ϵĵ�
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
                % B�������ߵĽڵ�ʸ��
                if ~isinf(nxCurParam(3))
                    nurbs.vecKnots = [nurbs.vecKnots; nxCurParam(3)];
                end
                % B�������ߵĿ��Ƶ�
                if 0 == size(nurbs.vecControlPoints,1)
                    nurbs.vecControlPoints = nxCurPos;
                    % ���Ƶ��Ȩֵ
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
                    error('�����Gָ�%s', strCurGId);
                end
            end
            % ��¼�ϴεĲ���ֵ
            strLastGId = strCurGId;
            nxLastPos = nxCurPos;
            % ������λ
            nxCurPos = ones(1,3) * Inf;
            nxCurParam = ones(1,5) * Inf;
        end
        if bForceEnd
            break;
        end
    end
    % ���һ��ΪB��������
    if strcmp(strLastGId, 'G6.2')
        % ��ɢB���������ϵĵ�
        nurbs.vecControlPoints = nurbs.vecControlPoints(1:size(nurbs.vecControlPoints,1)-nurbs.nLevel-1,:);
        vecPoints = ScatterNurbs(nurbs, g_nScatterPrecision);
        StoreCellPointCache(vecPoints, 3, nFigId);
        StoreCellPointCache(nurbs.vecControlPoints, 4, nFigId);
    end
    % ˢ�»���
    for i = 1:g_nHandleCount
        FlushCellPointCache(i, nFigId);
    end
    % �ر��ļ�
    fclose(fidRead);
    figHandle = g_figHandle;
end

%% ��ʼ���������ݵ�
function InitCellPointCache(nMaxSize, nColorId)
    % �������
    if nColorId ~= 1 && nColorId ~= 2
        error('����Ĳ�������ɫ���%f\n', nColorId);
    end
    global g_vecColor;
    global g_nHandleCount;
    global g_cellPointCache;
    g_cellPointCache = cell(g_nHandleCount,1);
    for i = 1:g_nHandleCount
        % ���ݵ�
        g_cellPointCache{i}.points = zeros(nMaxSize,3);
        % ��ʼ����
        g_cellPointCache{i}.index = 0;
        % ͼ����ɫ
        g_cellPointCache{i}.color = g_vecColor{nColorId}{i};
    end
end

%% �洢�������ݵ�
function StoreCellPointCache(vecPoints, nHandleIndex, nFigId)
    % �������
    if size(vecPoints,1) < 2
        error('����Ĳ��������ݵ���Ϊ%f\n', size(vecPoints,1));
    end
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('����Ĳ������������Ϊ%f\n', nHandleIndex);
    end
    % �����ɫһ�£����޸ľ������ֵ
    global g_cellPointCache;
    for i = 1:g_nHandleCount-1
        if strcmp(g_cellPointCache{i}.color, g_cellPointCache{nHandleIndex}.color)
            nHandleIndex = i;
            break;
        end
    end
    % �洢���ݵ�
    nPointIndex = g_cellPointCache{nHandleIndex}.index;
    if nPointIndex > 0 && ~isequal(g_cellPointCache{nHandleIndex}.points(nPointIndex,:), vecPoints(1,:))
        % ��ǰ���ݵ��뻺������ݵ㲻����β������
        vecNewPoints = g_cellPointCache{nHandleIndex}.points(1:nPointIndex,:);
        PlotFigureByPlane(vecNewPoints, nHandleIndex, nFigId, g_cellPointCache{nHandleIndex}.color);
        g_cellPointCache{nHandleIndex}.index = 0;
    end
    % ��黺���Ƿ�װ����
    global g_nMaxCachePoints;
    nPointIndex = g_cellPointCache{nHandleIndex}.index;
    if nPointIndex + size(vecPoints,1) >= g_nMaxCachePoints
        vecNewPoints = [g_cellPointCache{nHandleIndex}.points(1:nPointIndex,:); vecPoints];
        PlotFigureByPlane(vecNewPoints, nHandleIndex, nFigId, g_cellPointCache{nHandleIndex}.color);
        g_cellPointCache{nHandleIndex}.index = 0;
        return;
    end
    % �������ݵ�
    if nPointIndex == 0
        g_cellPointCache{nHandleIndex}.points = vecPoints;
        g_cellPointCache{nHandleIndex}.index = size(vecPoints,1);
    else
        g_cellPointCache{nHandleIndex}.points(nPointIndex+1:nPointIndex+size(vecPoints,1)-1,:) = vecPoints(2:end,:);
        g_cellPointCache{nHandleIndex}.index = g_cellPointCache{nHandleIndex}.index + size(vecPoints,1) - 1;
    end
end

%% ˢ�»������ݵ�
function FlushCellPointCache(nHandleIndex, nFigId)
    % �������
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('����Ĳ������������Ϊ%f\n', nHandleIndex);
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

%% �жϳ����Ƿ�����ӹ�
% ����strOrig�����������ַ���
% ����ֵbForceEnd���Ƿ�ֹͣ�ӹ���trueΪֹͣ��falseΪ��ֹͣ
function bForceEnd = JudgeEndMachine(strOrig)
    bForceEnd = false;
    % �������M2��M30����������
    nIndex = strfind(strOrig, 'M');
    if isempty(nIndex)
        nIndex = strfind(strOrig, 'm');
        if isempty(nIndex)
            return;
        end
    end
    % Ĭ�ϵ�1���ַ�Ϊ��ʶ��
    nResult = textscan(strOrig(nIndex:end), '%c%f', 1);
    if ~isempty(nResult{2})
        nValue = nResult{2};
        if (2 == nValue) || (30 == nValue)
            bForceEnd = true;
        end
    else
        error('����ֵ�����ڣ��ַ���Ϊ%s������Ϊ%d', strOrig, nIndex);
    end
end

%% ��ȡ��������ֵ
% ����strG90����̷�ʽ��G90Ϊ����������(Ĭ��ֵ)��G91Ϊ���������
% ����nxLastPos����һ�岹��ľ�������
% ����nxCurPos����ǰ�岹���(����/���)����
% ����ֵnxCurPosOut�����ݱ�̷�ʽ��ȡ��ǰ�岹��ľ�������
function nxCurPosOut = GetAbsoluteAxis(strG90, nxLastPos, nxCurPos)
    % �������
    if ~isempty(strG90) && strcmp(strG90, 'G90') && strcmp(strG90, 'G91')
        error('����ı�̷�ʽ��%s', strG90);
    end
    if isinf(nxLastPos(1)) && isinf(nxLastPos(2)) && isinf(nxLastPos(3))
        nxLastPos = zeros(1,3);
    end
    if isinf(nxLastPos(1)) || isinf(nxLastPos(2)) || isinf(nxLastPos(3))
        error('���������ֵ��X=%f,Y=%f,Z=%f', nxLastPos(1), nxLastPos(2), nxLastPos(3));
    end
    % ��������
    nxCurPosOut = nxLastPos;
    for i = 1:3
        if ~isinf(nxCurPos(i)) && strcmp(strG90, 'G91')
            nxCurPosOut(i) = nxLastPos(i) + nxCurPos(i);
        elseif ~isinf(nxCurPos(i)) && ~strcmp(strG90, 'G91')
            nxCurPosOut(i) = nxCurPos(i);
        end
    end
end

%% ����Gָ�����ֵ
% ����strOrig�����������ַ���
% ����strG90����̷�ʽ
% ����strG17������ƽ��
% ����strCurGId��Gָ���ʶ��
% ����nxCurPos������ֵ
% ����nxCurParam��Բ��/B��������
% ����ֵ����������������������
function [strG90Out, strG17Out, strCurGIdOut, nxCurPosOut, nxCurParamOut]...
    = AnalyseGCode(strOrig, strG90, strG17, strCurGId, nxCurPos, nxCurParam)
    % Ĭ��ֵ
    strG90Out = strG90;
    strG17Out = strG17;
    strCurGIdOut = strCurGId;
    nxCurPosOut = nxCurPos;
    nxCurParamOut = nxCurParam;
    % �����ַ����е�ֵ
    vecResult = textscan(strOrig, '%c%f');
    vecFlags = vecResult{1};
    vecValues = vecResult{2};
    for i = 1:length(vecFlags)
        if strcmp(vecFlags(i), 'G') || strcmp(vecFlags(i), 'g')
            % ���ദ��Gָ���ʶ��
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

%% ����������ͼ���л�ͼ
function PlotFigureByPlane(vecFitPoint, nHandleIndex, nFigId, strColor)
    % �������
    global g_nHandleCount;
    if nHandleIndex < 1 || nHandleIndex > g_nHandleCount
        error('����Ĳ������������Ϊ%f\n', nHandleIndex);
    end
    global g_bDrawControlPoint;
    if nHandleIndex == g_nHandleCount
        if ~g_bDrawControlPoint
            return;
        end
    end
    % ��ͼ
    global g_figHandle;
    global g_strPlane;
    figure(nFigId);
    hold on;
    switch g_strPlane
        case '��ά��ͼ'
            g_figHandle(nHandleIndex) = plot3(vecFitPoint(:,1), vecFitPoint(:,2), vecFitPoint(:,3), strColor);
            view([1 1 1]);
        case 'X-Yƽ��'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,1), vecFitPoint(:,2), strColor);
        case 'Y-Zƽ��'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,2), vecFitPoint(:,3), strColor);
        case 'Z-Xƽ��'
            g_figHandle(nHandleIndex) = plot(vecFitPoint(:,3), vecFitPoint(:,1), strColor);
        otherwise
            error('�������ͼ��%s', g_strPlane);
    end
    axis equal;
end