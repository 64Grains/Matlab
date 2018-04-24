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