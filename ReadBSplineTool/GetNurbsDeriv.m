%% ����NURBS����ָ���ڵ㴦�ĵ�ʸ
% NURBS������Ϣ���£�
%   nurbs.nDegree ------ ����
%   nurbs.vecKnots ----- �ڵ�ʸ��
%   nurbs.vecPoles ----- ���Ƶ�
%   nurbs.vecWeights --- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ---- �Ƿ�Ϊ����B��������
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetNurbsDeriv(nurbs, nKnot)
    % ������
    nurbs = CheckNurbs(nurbs);
    % ���ദ��
    if nurbs.bRational
        % ����B�������ߣ�����������Ĺ�ʽ��ȡ
        % ��ĸ����ס�һ�ס����׵�ʸ
        [nDenominatorDeriv0, nDenominatorDeriv1, nDenominatorDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecWeights, nKnot);
        % ���ӵ���ס�һ�ס����׵�ʸ
        vecWeightedPoles = nurbs.vecPoles;
        for i = 1:size(nurbs.vecPoles,1)
            vecWeightedPoles(i,:) = nurbs.vecPoles(i,:) * nurbs.vecWeights(i);
        end
        [nxNumeratorDeriv0, nxNumeratorDeriv1, nxNumeratorDeriv2] = GetBSplineDeriv(nurbs, vecWeightedPoles, nKnot);
        % ��׵�ʸ��������꣩
        nxDeriv0 = nxNumeratorDeriv0 / nDenominatorDeriv0;
        % һ�׵�ʸ
        nxDeriv1 = (nxNumeratorDeriv1 * nDenominatorDeriv0 - nxNumeratorDeriv0 * nDenominatorDeriv1) / (nDenominatorDeriv0 * nDenominatorDeriv0);
        % ���׵�ʸ
        nxDeriv2 = (nxNumeratorDeriv2 * nDenominatorDeriv0 - 2 * nxDeriv1 * nDenominatorDeriv0 * nDenominatorDeriv1...
            - nxNumeratorDeriv0 * nDenominatorDeriv2) / (nDenominatorDeriv0 * nDenominatorDeriv0);
    else
        %  ������B�������ߣ�����De-Boor���ƹ�ʽ���
        [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecPoles, nKnot);
    end
end

%% ���������B��������ָ���ڵ㴦�ĵ�ʸ
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, vecWeightedPoles, nKnot)
    % ��ȡ��Ч�Ŀ��Ƶ�
    [vecPoles, nKnotIndex] = GetValidPoles(nurbs, vecWeightedPoles, nKnot);
    % ����De-Boor�����㷨���
    vecTempPoles = vecPoles;
    
    deBoorInfo.nKnot = nKnot;
    deBoorInfo.nKnotIndex = nKnotIndex;
    deBoorInfo.nStartIndex = 1;
    deBoorInfo.nEndIndex = nurbs.nDegree - 2;
    [vecPoles, vecTempPoles] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % ���׵�ʸ
    nxDeriv2 = nurbs.nDegree * (nurbs.nDegree - 1) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * ((vecPoles(nurbs.nDegree+1, :)...
        - vecPoles(nurbs.nDegree, :)) / (nurbs.vecKnots(nKnotIndex+2) - nurbs.vecKnots(nKnotIndex)) - (vecPoles(nurbs.nDegree, :)...
        - vecPoles(nurbs.nDegree-1, :)) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex-1)));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecPoles, vecTempPoles] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % һ�׵�ʸ
    nxDeriv1 = nurbs.nDegree / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * (vecPoles(nurbs.nDegree+1,:)...
        - vecPoles(nurbs.nDegree,:));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecPoles, ~] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles);
    % ��׵�ʸ��������꣩
    nxDeriv0 = vecPoles(nurbs.nDegree+1, :);
end

%% ��ȡ��Ч�Ŀ��Ƶ�
function [vecValidPoles, nKnotIndex] = GetValidPoles(nurbs, vecOrigPoles, nKnot)
    % ��ѯ�ڵ��ڽڵ�������±�
    nKnotIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, nKnot);
    % ����B������������Ӧ�Ŀ��Ƶ�
    vecValidPoles = vecOrigPoles(nKnotIndex-nurbs.nDegree:nKnotIndex,:);
end

%% ��ȡ�������Ƶ�
function [vecPolesNew, vecTempPolesNew] = GetIteratePole(nurbs, deBoorInfo, vecPoles, vecTempPoles)
    vecPolesNew = vecPoles;
    vecTempPolesNew = vecTempPoles;
    % De-Boor�����㷨����������Ƶ�
    for i = deBoorInfo.nStartIndex:deBoorInfo.nEndIndex
        for j = i:nurbs.nDegree
            nTempIndex = deBoorInfo.nKnotIndex - nurbs.nDegree + j;
            nAlpha = (deBoorInfo.nKnot - nurbs.vecKnots(nTempIndex)) / (nurbs.vecKnots(nurbs.nDegree+1+nTempIndex-i) - nurbs.vecKnots(nTempIndex));
            vecTempPolesNew(j+1,:) = (1 - nAlpha) * vecPolesNew(j,:) + nAlpha * vecPolesNew(j+1,:);
        end
        vecPolesNew = vecTempPolesNew;
    end
end

%% ��ѯ�ڵ����ڽڵ�������±�
function nIndex = FindSpan(nDegree, vecKnots, nKnot)
    % �������
    global g_nCompareError;
    nLength = length(vecKnots);
    if nKnot < vecKnots(nDegree + 1) || nKnot > vecKnots(nLength - nDegree)
        if abs(nKnot - vecKnots(nDegree + 1)) < g_nCompareError
            nKnot = vecKnots(nDegree + 1);
        elseif abs(nKnot - vecKnots(nLength - nDegree)) < g_nCompareError
            nKnot = vecKnots(nLength - nDegree);
        else
            error('�ڵ�ֵu=%f�����ڵ�ʸ���ķ�Χ���½�%f���Ͻ�%f', nKnot, vecKnots(nDegree + 1), vecKnots(nLength - nDegree));
        end
    end
    % �������
    if nKnot == vecKnots(nLength - nDegree)
        nIndex = nLength - nDegree - 1;
        while vecKnots(nIndex) == vecKnots(nLength - nDegree)
            nIndex = nIndex - 1;
        end
    else
        % ��������
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