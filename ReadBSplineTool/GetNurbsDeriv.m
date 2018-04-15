%% ����NURBS����ָ���ڵ㴦�ĵ�ʸ
% NURBS������Ϣ���£�
%   nurbs.nLevel -------------- ����
%   nurbs.vecKnots ------------ �ڵ�ʸ��
%   nurbs.vecControlPoints ---- ���Ƶ�
%   nurbs.vecWeights ---------- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ----------- �Ƿ�Ϊ����B��������
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetNurbsDeriv(nurbs, nKnot)
    % ������
    nurbs = CheckNurbs(nurbs);
    % ���ദ��
    if nurbs.bRational
        % ����B�������ߣ�����������Ĺ�ʽ��ȡ
        % ��ĸ����ס�һ�ס����׵�ʸ
        [nDenominatorDeriv0, nDenominatorDeriv1, nDenominatorDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecWeights, nKnot);
        % ���ӵ���ס�һ�ס����׵�ʸ
        vecWeightedControlPoints = nurbs.vecControlPoints;
        for i = 1:size(nurbs.vecControlPoints,1)
            vecWeightedControlPoints(i,:) = nurbs.vecControlPoints(i,:) * nurbs.vecWeights(i);
        end
        [nxNumeratorDeriv0, nxNumeratorDeriv1, nxNumeratorDeriv2] = GetBSplineDeriv(nurbs, vecWeightedControlPoints, nKnot);
        % ��׵�ʸ��������꣩
        nxDeriv0 = nxNumeratorDeriv0 / nDenominatorDeriv0;
        % һ�׵�ʸ
        nxDeriv1 = (nxNumeratorDeriv1 * nDenominatorDeriv0 - nxNumeratorDeriv0 * nDenominatorDeriv1) / (nDenominatorDeriv0 * nDenominatorDeriv0);
        % ���׵�ʸ
        nxDeriv2 = (nxNumeratorDeriv2 * nDenominatorDeriv0 - 2 * nxDeriv1 * nDenominatorDeriv0 * nDenominatorDeriv1...
            - nxNumeratorDeriv0 * nDenominatorDeriv2) / (nDenominatorDeriv0 * nDenominatorDeriv0);
    else
        %  ������B�������ߣ�����De-Boor���ƹ�ʽ���
        [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, nurbs.vecControlPoints, nKnot);
    end
end

%% ���������B��������ָ���ڵ㴦�ĵ�ʸ
function [nxDeriv0, nxDeriv1, nxDeriv2] = GetBSplineDeriv(nurbs, vecWeightedControlPoints, nKnot)
    % ��ȡ��Ч�Ŀ��Ƶ�
    [vecControlPoints, nKnotIndex] = GetValidControlPoints(nurbs, vecWeightedControlPoints, nKnot);
    % ����De-Boor�����㷨���
    vecTempControlPoints = vecControlPoints;
    
    deBoorInfo.nKnot = nKnot;
    deBoorInfo.nKnotIndex = nKnotIndex;
    deBoorInfo.nStartIndex = 1;
    deBoorInfo.nEndIndex = nurbs.nLevel - 2;
    [vecControlPoints, vecTempControlPoints] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % ���׵�ʸ
    nxDeriv2 = nurbs.nLevel * (nurbs.nLevel - 1) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * ((vecControlPoints(nurbs.nLevel+1, :)...
        - vecControlPoints(nurbs.nLevel, :)) / (nurbs.vecKnots(nKnotIndex+2) - nurbs.vecKnots(nKnotIndex)) - (vecControlPoints(nurbs.nLevel, :)...
        - vecControlPoints(nurbs.nLevel-1, :)) / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex-1)));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecControlPoints, vecTempControlPoints] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % һ�׵�ʸ
    nxDeriv1 = nurbs.nLevel / (nurbs.vecKnots(nKnotIndex+1) - nurbs.vecKnots(nKnotIndex)) * (vecControlPoints(nurbs.nLevel+1,:)...
        - vecControlPoints(nurbs.nLevel,:));
    
    deBoorInfo.nStartIndex = deBoorInfo.nEndIndex + 1;
    deBoorInfo.nEndIndex = deBoorInfo.nStartIndex;
    [vecControlPoints, ~] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints);
    % ��׵�ʸ��������꣩
    nxDeriv0 = vecControlPoints(nurbs.nLevel+1, :);
end

%% ��ȡ��Ч�Ŀ��Ƶ�
function [vecValidControlPoints, nKnotIndex] = GetValidControlPoints(nurbs, vecOrigControlPoints, nKnot)
    % ��ѯ�ڵ��ڽڵ�������±�
    nKnotIndex = FindSpan(nurbs.nLevel, nurbs.vecKnots, nKnot);
    % ����B������������Ӧ�Ŀ��Ƶ�
    vecValidControlPoints = vecOrigControlPoints(nKnotIndex-nurbs.nLevel:nKnotIndex,:);
end

%% ��ȡ�������Ƶ�
function [vecControlPointsNew, vecTempControlPointsNew] = GetIterateControlPoint(nurbs, deBoorInfo, vecControlPoints, vecTempControlPoints)
    vecControlPointsNew = vecControlPoints;
    vecTempControlPointsNew = vecTempControlPoints;
    % De-Boor�����㷨����������Ƶ�
    for i = deBoorInfo.nStartIndex:deBoorInfo.nEndIndex
        for j = i:nurbs.nLevel
            nTempIndex = deBoorInfo.nKnotIndex - nurbs.nLevel + j;
            nAlpha = (deBoorInfo.nKnot - nurbs.vecKnots(nTempIndex)) / (nurbs.vecKnots(nurbs.nLevel+1+nTempIndex-i) - nurbs.vecKnots(nTempIndex));
            vecTempControlPointsNew(j+1,:) = (1 - nAlpha) * vecControlPointsNew(j,:) + nAlpha * vecControlPointsNew(j+1,:);
        end
        vecControlPointsNew = vecTempControlPointsNew;
    end
end

%% ��ѯ�ڵ����ڽڵ�������±�
function nIndex = FindSpan(nLevel, vecKnots, nKnot)
    % �������
    nLength = length(vecKnots);
    if nKnot < vecKnots(nLevel + 1) || nKnot > vecKnots(nLength - nLevel)
        error('�ڵ�ֵu=%f�����ڵ�ʸ���ķ�Χ���½�%f���Ͻ�%f', nKnot, vecKnots(nLevel + 1), vecKnots(nLength - nLevel));
    end
    % �������
    if nKnot == vecKnots(nLength - nLevel)
        nIndex = nLength - nLevel - 1;
        while vecKnots(nIndex) == vecKnots(nLength - nLevel)
            nIndex = nIndex - 1;
        end
    else
        % ��������
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