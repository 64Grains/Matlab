%% 将NURBS曲线分割为没有重节点的NURBS曲线段
% NURBS曲线信息如下：
%   nurbs.nDegree ------ 次数
%   nurbs.vecKnots ----- 节点矢量
%   nurbs.vecPoles ----- 控制点
%   nurbs.vecWeights --- 控制点对应的权值点
%   nurbs.bRational ---- 是否为有理B样条曲线
function vecNurbs = DivideNurbs(nurbs)
    % 检查参数
    nurbs = CheckNurbs(nurbs);
    % 在内重节点处插入节点，使得重节点的重复度为nurbs.nDegree+1，然后将NURBS曲线分割为没有重节点的NURBS曲线段
    global g_nCompareError;
    nStartIndex = 1;
    while true
        if nurbs.vecKnots(nStartIndex) - nurbs.vecKnots(nurbs.nDegree+1) > g_nCompareError
            break;
        end
        nStartIndex = nStartIndex + 1;
    end
    nEndIndex = length(nurbs.vecKnots);
    while true
        if nurbs.vecKnots(nEndIndex) - nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree) < -g_nCompareError
            break;
        end
        nEndIndex = nEndIndex - 1;
    end
    % 统计需要插入的节点值
    vecInsertKnot = nurbs.vecKnots;
    nIndex = 0;
    nFlagKnot = nurbs.vecKnots(nStartIndex);
    nRepeatCount = 1;
    for i = nStartIndex+1:nEndIndex+1
        if abs(nurbs.vecKnots(i) - nFlagKnot) < g_nCompareError
            nRepeatCount = nRepeatCount + 1;
            continue;
        end
        if nRepeatCount > 1
            nInsertCount = nurbs.nDegree + 1 - nRepeatCount;
            for j = 1:nInsertCount
                nIndex = nIndex + 1;
                vecInsertKnot(nIndex) = nFlagKnot;
            end
        end
        nFlagKnot = nurbs.vecKnots(i);
        nRepeatCount = 1;
    end
    vecInsertKnot = vecInsertKnot(1:nIndex);
    % 节点细化
    nurbs = RefineNurbs(nurbs, vecInsertKnot);
    % 将NURBS曲线进行划分
    vecNurbs = SectionNurbs(nurbs);
end

%%% NURBS曲线：节点细化
function nurbsNew = RefineNurbs(nurbs, vecInsertKnot)
    if isempty(vecInsertKnot)
        nurbsNew = nurbs;
        return;
    end
    % 非有理B样条曲线
    if ~nurbs.bRational
        nurbsNew = RefineBSpline(nurbs, vecInsertKnot);
        return;
    end
    % 有理B样条曲线：将坐标转化为高维的齐次坐标
    vecTempPoles = nurbs.vecPoles;
    [nRow, nColumn] = size(vecTempPoles);
    nurbs.vecPoles = zeros(nRow, nColumn+1);
    for i = 1:nRow
        nurbs.vecPoles(i,1:nColumn) = vecTempPoles(i,:) * nurbs.vecWeights(i);
        nurbs.vecPoles(i,nColumn+1) = nurbs.vecWeights(i);
    end
    nurbsNew = RefineBSpline(nurbs, vecInsertKnot);
    % 转化齐次坐标
    vecTempPoles = nurbsNew.vecPoles;
    [nRow, nColumn] = size(vecTempPoles);
    nurbsNew.vecPoles = zeros(nRow, nColumn-1);
    for i = 1:nRow
        nurbsNew.vecPoles(i,:) = vecTempPoles(i,1:nColumn-1) / vecTempPoles(i,nColumn);
    end
    nurbsNew.vecWeights = vecTempPoles(:,nColumn);
end

%%% BSpline曲线：节点细化
% NURBS曲线信息如下：
%   nurbs.nDegree ------ 次数
%   nurbs.vecKnots ----- 节点矢量
%   nurbs.vecPoles ----- 控制点
%   nurbs.vecWeights --- 控制点对应的权值点
%   nurbs.bRational ---- 是否为有理B样条曲线
function nurbsNew = RefineBSpline(nurbs, vecInsertKnot)
    nLength = length(vecInsertKnot);
    % B样条曲线的幂次
    nurbsNew.nDegree = nurbs.nDegree;
    % 节点的索引
    nMinIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, vecInsertKnot(1));
    nMaxIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, vecInsertKnot(nLength)) + 1;
    % 复制不变的节点矢量
    nurbsNew.vecKnots = zeros(length(nurbs.vecKnots)+nLength,1);
    nurbsNew.vecKnots(1:nMinIndex) = nurbs.vecKnots(1:nMinIndex);
    nurbsNew.vecKnots(nMaxIndex+nLength:end) = nurbs.vecKnots(nMaxIndex:end);
    % 复制不变的控制点
    [nRow, nColumn] = size(nurbs.vecPoles);
    nurbsNew.vecPoles = zeros(nRow+nLength,nColumn);
    nurbsNew.vecPoles(1:nMinIndex-nurbs.nDegree,:) = nurbs.vecPoles(1:nMinIndex-nurbs.nDegree,:);
    nurbsNew.vecPoles(nMaxIndex-1+nLength:end,:) = nurbs.vecPoles(nMaxIndex-1:end,:);
    
    nIndex = nMaxIndex + nurbs.nDegree;
    nFlag = nMaxIndex + nurbs.nDegree + nLength;
    % 新控制点和节点矢量
    for j = nLength:-1:1
        while vecInsertKnot(j) <= nurbs.vecKnots(nIndex) && nIndex > nMinIndex
            nurbsNew.vecPoles(nFlag-nurbs.nDegree-1,:) = nurbs.vecPoles(nIndex-nurbs.nDegree-1,:);
            nurbsNew.vecKnots(nFlag) = nurbs.vecKnots(nIndex);
            nFlag = nFlag - 1;
            nIndex = nIndex - 1;
        end
        nurbsNew.vecPoles(nFlag-nurbs.nDegree-1,:) = nurbsNew.vecPoles(nFlag-nurbs.nDegree,:);
        for k = 1:nurbs.nDegree
            nTemp = nFlag - nurbs.nDegree + k;
            nAlpha = nurbsNew.vecKnots(nFlag+k) - vecInsertKnot(j);
            if nAlpha ~= 0
                nAlpha = nAlpha / (nurbsNew.vecKnots(nFlag+k) - nurbs.vecKnots(nIndex-nurbs.nDegree+k));
                nurbsNew.vecPoles(nTemp-1,:) = nAlpha * nurbsNew.vecPoles(nTemp-1,:) + (1 - nAlpha) * nurbsNew.vecPoles(nTemp,:);
            else
                nurbsNew.vecPoles(nTemp-1,:) = nurbsNew.vecPoles(nTemp,:);
            end
        end
        nurbsNew.vecKnots(nFlag) = vecInsertKnot(j);
        nFlag = nFlag - 1;
    end
    % 控制点的权值
    nurbsNew.vecWeights = [];
end

%%% 将NURBS曲线进行划分
function vecNurbs = SectionNurbs(nurbs)
    vecNurbs = cell(size(nurbs.vecPoles,1),1);
    nIndex = 0;
    % 第一段NURBS曲线段
    nKnotIndex = nurbs.nDegree + 1;
    nPointIndex = 0;
    nurbsNew.nDegree = nurbs.nDegree;
    nurbsNew.vecKnots = nurbs.vecKnots(1:nKnotIndex);
    nurbsNew.vecWeights = [];
    nRepeatCount = 1;
    nFlagKnot = nurbs.vecKnots(nKnotIndex+1);
    global g_nCompareError;
    for i = nKnotIndex+2:length(nurbs.vecKnots)-nurbs.nDegree
        % 重节点
        if abs(nurbs.vecKnots(i) - nFlagKnot) < g_nCompareError
            nRepeatCount = nRepeatCount + 1;
            continue;
        end
        % 内节点不重复
        if nRepeatCount == 1
            nurbsNew.vecKnots = [nurbsNew.vecKnots; nFlagKnot];
            nFlagKnot = nurbs.vecKnots(i);
            continue;
        end
        % 内节点重复：重复度为nurbs.nDegree + 1
        if nRepeatCount < nurbs.nDegree + 1
            error('错误的参数：节点重复度为%d\n', nRepeatCount);
        end
        nurbsNew.vecKnots = [nurbsNew.vecKnots; ones(nRepeatCount,1) * nFlagKnot];
        nPointCount = length(nurbsNew.vecKnots) - nurbsNew.nDegree - 1;
        nurbsNew.vecPoles = nurbs.vecPoles(nPointIndex+1:nPointIndex+nPointCount,:);
        if ~isempty(nurbs.vecWeights)
            nurbsNew.vecWeights = nurbs.vecWeights(nPointIndex+1:nPointIndex+nPointCount,:);
        end
        nPointIndex = nPointIndex + nPointCount;
        nIndex = nIndex + 1; 
        vecNurbs{nIndex} = nurbsNew;
        % 重置标识值
        nurbsNew.vecKnots = ones(nRepeatCount,1) * nFlagKnot;
        nFlagKnot = nurbs.vecKnots(i);
        nRepeatCount = 1;
    end
    % 最后一段NURBS曲线段
    nurbsNew.vecKnots = [nurbsNew.vecKnots; ones(nRepeatCount,1) * nFlagKnot];
    nurbsNew.vecKnots = [nurbsNew.vecKnots; nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree+1:end)];
    if nPointIndex ~= size(nurbs.vecPoles,1)
        nPointCount = length(nurbsNew.vecKnots) - nurbsNew.nDegree - 1;
        nurbsNew.vecPoles = nurbs.vecPoles(nPointIndex+1:nPointIndex+nPointCount,:);
        if ~isempty(nurbs.vecWeights)
            nurbsNew.vecWeights = nurbs.vecWeights(nPointIndex+1:nPointIndex+nPointCount,:);
        end
        nPointIndex = nPointIndex + nPointCount;
        nIndex = nIndex + 1; 
        vecNurbs{nIndex} = nurbsNew;
    end
    vecNurbs = vecNurbs(1:nIndex);
    if nPointIndex ~= size(nurbs.vecPoles,1)
        error('错误的结果：控制点存在遗漏！\n');
    end
end