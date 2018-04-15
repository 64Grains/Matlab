%% 计算NURBS曲线指定节点处的导矢
% NURBS曲线信息如下：
%   nurbs.nLevel -------------- 次数
%   nurbs.vecKnots ------------ 节点矢量
%   nurbs.vecControlPoints ---- 控制点
%   nurbs.vecWeights ---------- 控制点对应的权值点
%   nurbs.bRational ----------- 是否为有理B样条曲线
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetNurbsDeriv(nurbs, nKnot)
    % 检查参数
    nurbs = CheckNurbs(nurbs);
    % 分类处理
    if nurbs.bRational
        % 有理B样条曲线：利用莱布尼茨公式求取
        % 分母的零阶、一阶、二阶导矢
        [nDenominatorDeriv0, nDenominatorDeriv1, nDenominatorDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecWeights, nKnot);
        % 分子的零阶、一阶、二阶导矢
        vecWeightedControlPoints = nurbs.vecControlPoints;
        for i = 1:size(nurbs.vecControlPoints,1)
            vecWeightedControlPoints(i,:) = nurbs.vecControlPoints(i,:) * nurbs.vecWeights(i);
        end
        [nxNumeratorDeriv0, nxNumeratorDeriv1, nxNumeratorDeriv2] = GetBSplineDeriv(nurbs, vecWeightedControlPoints, nKnot);
        % 零阶导矢（点的坐标）
        nxDeriv0 = nxNumeratorDeriv0 / nDenominatorDeriv0;
        % 一阶导矢
        nxDeriv1 = (nxNumeratorDeriv1 * nDenominatorDeriv0 - nxNumeratorDeriv0 * nDenominatorDeriv1) / (nDenominatorDeriv0 * nDenominatorDeriv0);
        % 二阶导矢
        nxDeriv2 = (nxNumeratorDeriv2 * nDenominatorDeriv0 - 2 * nxDeriv1 * nDenominatorDeriv0 * nDenominatorDeriv1...
            - nxNumeratorDeriv0 * nDenominatorDeriv2) / (nDenominatorDeriv0 * nDenominatorDeriv0);
    else
        %  非有理B样条曲线：利用De-Boor递推公式求解
        [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecControlPoints, nKnot);
    end
end

%% 计算非有理B样条曲线指定节点处的导矢
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, vecWeightedControlPoints, nKnot)
    % 获取有效的控制点
    [vecControlPoints, nKnotIndex] = GetValidControlPoints(nurbs, vecWeightedControlPoints, nKnot);
    % 利用De-Boor递推算法求解
    vecTempControlPoints = vecControlPoints;
    
    deBoorInfo.nKnot = nKnot;
    deBoorInfo.nKnotIndex = nKnotIndex;
    deBoorInfo.nStartIndex = 1;
    deBoorInfo.nEndIndex = nurbs.nLevel - 2;
    [vecControlPoints, vecTempControlPoints] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % 二阶导矢
    nxDeriv2 = nurbs.nLevel * (nurbs.nLevel - 1) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * ((vecControlPoints(nurbs.nLevel+1, :)...
        - vecControlPoints(nurbs.nLevel, :)) / (nurbs.vecKnots(nKnotIndex+2) - nurbs.vecKnots(nKnotIndex)) - (vecControlPoints(nurbs.nLevel, :)...
        - vecControlPoints(nurbs.nLevel-1, :)) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex-1)));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecControlPoints, vecTempControlPoints] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % 一阶导矢
    nxDeriv1 = nurbs.nLevel / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * (vecControlPoints(nurbs.nLevel+1,:)...
        - vecControlPoints(nurbs.nLevel,:));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecControlPoints, ~] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % 零阶导矢（点的坐标）
    nxDeriv0 = vecControlPoints(nurbs.nLevel+1, :);
end

%% 获取有效的控制点
function [vecValidControlPoints, nKnotIndex] = GetValidControlPoints(nurbs, vecOrigControlPoints, nKnot)
    % 查询节点在节点区间的下标
    nKnotIndex = FindSpan(nurbs.nLevel, nurbs.vecKnots, nKnot);
    % 非零B样条基函数对应的控制点
    vecValidControlPoints = vecOrigControlPoints(nKnotIndex-nurbs.nLevel:nKnotIndex,:);
end

%% 获取迭代控制点
function [vecControlPointsNew, vecTempControlPointsNew] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints)
    vecControlPointsNew = vecControlPoints;
    vecTempControlPointsNew = vecTempControlPoints;
    % De-Boor递推算法计算迭代控制点
    for i = deBoorInfo.nStartIndex:deBoorInfo.nEndIndex
        for j = i:nurbs.nLevel
            nTempIndex = deBoorInfo.nKnotIndex - nurbs.nLevel + j;
            nAlpha = (deBoorInfo.nKnot - nurbs.vecKnots(nTempIndex)) / (nurbs.vecKnots(nurbs.nLevel+1+nTempIndex-i) - nurbs.vecKnots(nTempIndex));
            vecTempControlPointsNew(j+1,:) = (1 - nAlpha) * vecControlPointsNew(j,:) + nAlpha * vecControlPointsNew(j+1,:);
        end
        vecControlPointsNew = vecTempControlPointsNew;
    end
end

%% 查询节点所在节点区间的下标
function nIndex = FindSpan(nLevel, vecKnots, nKnot)
    % 参数检查
    nLength = length(vecKnots);
    if nKnot < vecKnots(nLevel + 1) || nKnot > vecKnots(nLength - nLevel)
        error('节点值u=%f超出节点矢量的范围：下界%f，上界%f', nKnot, vecKnots(nLevel + 1), vecKnots(nLength - nLevel));
    end
    % 特殊情况
    if nKnot == vecKnots(nLength - nLevel)
        nIndex = nLength - nLevel - 1;
        while vecKnots(nIndex) == vecKnots(nLength - nLevel)
            nIndex = nIndex - 1;
        end
    else
        % 二分搜索
        nLow = nLevel + 1;
        nHigh = nLength - nLevel;
        nMid = floor((nLow + nHigh) / 2);
        while nKnot < vecKnots(nMid) || nKnot >= vecKnots(nMid + 1)
            if nKnot < vecKnots(nMid)
                nHigh = nMid;
            else
                nLow = nMid;
            end
            nMid = floor((nLow + nHigh) / 2);
        end
        nIndex = nMid;
    end
end