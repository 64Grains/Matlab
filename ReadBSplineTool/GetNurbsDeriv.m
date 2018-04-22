%% 计算NURBS曲线指定节点处的导矢
% NURBS曲线信息如下：
%   nurbs.nDegree ------ 次数
%   nurbs.vecKnots ----- 节点矢量
%   nurbs.vecPoles ----- 控制点
%   nurbs.vecWeights --- 控制点对应的权值点
%   nurbs.bRational ---- 是否为有理B样条曲线
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetNurbsDeriv(nurbs, nKnot)
    % 检查参数
    nurbs = CheckNurbs(nurbs);
    % 分类处理
    if nurbs.bRational
        % 有理B样条曲线：利用莱布尼茨公式求取
        % 分母的零阶、一阶、二阶导矢
        [nDenominatorDeriv0, nDenominatorDeriv1, nDenominatorDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecWeights, nKnot);
        % 分子的零阶、一阶、二阶导矢
        vecWeightedPoles = nurbs.vecPoles;
        for i = 1:size(nurbs.vecPoles,1)
            vecWeightedPoles(i,:) = nurbs.vecPoles(i,:) * nurbs.vecWeights(i);
        end
        [nxNumeratorDeriv0, nxNumeratorDeriv1, nxNumeratorDeriv2] = GetBSplineDeriv(nurbs, vecWeightedPoles, nKnot);
        % 零阶导矢（点的坐标）
        nxDeriv0 = nxNumeratorDeriv0 / nDenominatorDeriv0;
        % 一阶导矢
        nxDeriv1 = (nxNumeratorDeriv1 * nDenominatorDeriv0 - nxNumeratorDeriv0 * nDenominatorDeriv1) / (nDenominatorDeriv0 * nDenominatorDeriv0);
        % 二阶导矢
        nxDeriv2 = (nxNumeratorDeriv2 * nDenominatorDeriv0 - 2 * nxDeriv1 * nDenominatorDeriv0 * nDenominatorDeriv1...
            - nxNumeratorDeriv0 * nDenominatorDeriv2) / (nDenominatorDeriv0 * nDenominatorDeriv0);
    else
        %  非有理B样条曲线：利用De-Boor递推公式求解
        [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecPoles, nKnot);
    end
end

%% 计算非有理B样条曲线指定节点处的导矢
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, vecWeightedPoles, nKnot)
    % 获取有效的控制点
    [vecPoles, nKnotIndex] = GetValidPoles(nurbs, vecWeightedPoles, nKnot);
    % 利用De-Boor递推算法求解
    vecTempPoles = vecPoles;
    
    deBoorInfo.nKnot = nKnot;
    deBoorInfo.nKnotIndex = nKnotIndex;
    deBoorInfo.nStartIndex = 1;
    deBoorInfo.nEndIndex = nurbs.nDegree - 2;
    [vecPoles, vecTempPoles] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % 二阶导矢
    nxDeriv2 = nurbs.nDegree * (nurbs.nDegree - 1) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * ((vecPoles(nurbs.nDegree+1, :)...
        - vecPoles(nurbs.nDegree, :)) / (nurbs.vecKnots(nKnotIndex+2) - nurbs.vecKnots(nKnotIndex)) - (vecPoles(nurbs.nDegree, :)...
        - vecPoles(nurbs.nDegree-1, :)) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex-1)));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecPoles, vecTempPoles] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % 一阶导矢
    nxDeriv1 = nurbs.nDegree / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * (vecPoles(nurbs.nDegree+1,:)...
        - vecPoles(nurbs.nDegree,:));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecPoles, ~] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % 零阶导矢（点的坐标）
    nxDeriv0 = vecPoles(nurbs.nDegree+1, :);
end

%% 获取有效的控制点
function [vecValidPoles, nKnotIndex] = GetValidPoles(nurbs, vecOrigPoles, nKnot)
    % 查询节点在节点区间的下标
    nKnotIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, nKnot);
    % 非零B样条基函数对应的控制点
    vecValidPoles = vecOrigPoles(nKnotIndex-nurbs.nDegree:nKnotIndex,:);
end

%% 获取迭代控制点
function [vecPolesNew, vecTempPolesNew] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles)
    vecPolesNew = vecPoles;
    vecTempPolesNew = vecTempPoles;
    % De-Boor递推算法计算迭代控制点
    for i = deBoorInfo.nStartIndex:deBoorInfo.nEndIndex
        for j = i:nurbs.nDegree
            nTempIndex = deBoorInfo.nKnotIndex - nurbs.nDegree + j;
            nAlpha = (deBoorInfo.nKnot - nurbs.vecKnots(nTempIndex)) / (nurbs.vecKnots(nurbs.nDegree+1+nTempIndex-i) - nurbs.vecKnots(nTempIndex));
            vecTempPolesNew(j+1,:) = (1 - nAlpha) * vecPolesNew(j,:) + nAlpha * vecPolesNew(j+1,:);
        end
        vecPolesNew = vecTempPolesNew;
    end
end

%% 查询节点所在节点区间的下标
function nIndex = FindSpan(nDegree, vecKnots, nKnot)
    % 参数检查
    global g_nCompareError;
    nLength = length(vecKnots);
    if nKnot < vecKnots(nDegree + 1) || nKnot > vecKnots(nLength - nDegree)
        if abs(nKnot - vecKnots(nDegree + 1)) < g_nCompareError
            nKnot = vecKnots(nDegree + 1);
        elseif abs(nKnot - vecKnots(nLength - nDegree)) < g_nCompareError
            nKnot = vecKnots(nLength - nDegree);
        else
            error('节点值u=%f超出节点矢量的范围：下界%f，上界%f', nKnot, vecKnots(nDegree + 1), vecKnots(nLength - nDegree));
        end
    end
    % 特殊情况
    if nKnot == vecKnots(nLength - nDegree)
        nIndex = nLength - nDegree - 1;
        while vecKnots(nIndex) == vecKnots(nLength - nDegree)
            nIndex = nIndex - 1;
        end
    else
        % 二分搜索
        nLow = nDegree + 1;
        nHigh = nLength - nDegree;
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