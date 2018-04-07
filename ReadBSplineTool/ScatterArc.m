%% ��Բ�����չ涨�ľ�����ɢΪС�߶�
% ����strG17������ƽ��
% ����strCurGId��Gָ��(G2��G3)
% ����nxLastPos��Բ�����������
% ����nxCurPos��Բ�����յ�����
% ����nxCurParam��Բ���Ĳ���
% ����ֵvecPoints��Բ����ɢ������ݵ�
function vecPoints = ScatterArc(strG17, strCurGId, nxLastPos, nxCurPos, nxCurParam, nDeflection)
    %%% Բ��ָ��G02��G03��G02/G03 X_Y_Z_R_(I_J_K_)��
    % G02ָ����˳ʱ�뷽ʽ�岹��G03Ϊ��ʱ��
    % R��ֵΪ��ʱ����Բ���δ��ڰ�Բ����Ϊ��ʱ�����Բ����С�ڻ���ڰ�Բ
    % G17�趨X-Y����ƽ�棬G18�趨Z-X����ƽ�棬G19�趨Y-Z����ƽ��
    % �������
    if ~strcmp(strCurGId, 'G2') && ~strcmp(strCurGId, 'G3')
        error('����Ĳ���ֵ��%s����ָ���Բ��ָ�', strCurGId);
    end
    % ����Ĭ��ֵ
    if isempty(strG17)
        strG17 = 'G17';
    end
    % ������ת��Ϊƽ������
    [nxLastTwoAxis, nLastThreeAxis] = GetTwoAxisByPlane(strG17, nxLastPos);
    [nxCurTwoAxis, nCurThreeAxis] = GetTwoAxisByPlane(strG17, nxCurPos);
    if nLastThreeAxis ~= nCurThreeAxis
        error('Բ���������յ㲻��ͬһ����ƽ���ڣ�');
    end
    % Բ��
    [nxArcCenter, ~] = GetTwoAxisByPlane(strG17, nxCurParam(1:3));
    global g_IJLIncrementalMode;
    if g_IJLIncrementalMode
        nxArcCenter = nxArcCenter + nxLastTwoAxis;
    end
    % ���뾶���ͳһΪԲ�ı��
    if ~isinf(nxCurParam(4))
        nxArcCenter = TransRadiusToArcCenter(strCurGId, nxLastTwoAxis, nxCurTwoAxis, nxCurParam(4));
    end
    % ����н�
    nxStartVec = (nxLastTwoAxis - nxArcCenter) / norm(nxLastTwoAxis - nxArcCenter);
    nxEndVec = (nxCurTwoAxis - nxArcCenter) / norm(nxCurTwoAxis - nxArcCenter);
    nCosValue = nxStartVec(1) * nxEndVec(1) + nxStartVec(2) * nxEndVec(2);
    nSinValue = nxStartVec(1) * nxEndVec(2) - nxStartVec(2) * nxEndVec(1);
    if strcmp(strCurGId, 'G2')
        nSinValue = -nSinValue;
    end
    nAngle = acos(nCosValue);
    if nSinValue < 0
        nAngle = 2 * pi - nAngle;
    end
    % �Ƿ�Ϊ��Բ
    if 0 == nAngle && isinf(nxCurParam(4))
        nAngle = 2 * pi;
    end
    % ���ݾ�����ɢԲ��
    nRadius = norm(nxLastTwoAxis - nxArcCenter);
    nStepAngle = 2 * acos(1 - min(nDeflection, nRadius) / nRadius);
    nCount = ceil(nAngle / nStepAngle) + 1;
    nStepAngle = nAngle / nCount;
    if strcmp(strCurGId, 'G2')
        nStepAngle = -nStepAngle;
    end
    % ������ɢ�ĵ�
    vecPoints = zeros(nCount+1,3);
    nxTempAxis = zeros(1,2);
    for i = 0:nCount
        nStartAngle = i * nStepAngle;
        nxTempAxis(1) = nxArcCenter(1) + nRadius * (nxStartVec(1) * cos(nStartAngle) - nxStartVec(2) * sin(nStartAngle));
        nxTempAxis(2) = nxArcCenter(2) + nRadius * (nxStartVec(1) * sin(nStartAngle) + nxStartVec(2) * cos(nStartAngle));
        vecPoints(i+1,:) = GetThreeAxisByPlane(strG17, nxTempAxis, nLastThreeAxis);
    end
end

%% ���뾶���ͳһΪԲ�ı��
% ����strCurGId��Gָ��(G2��G3)
% ����nxLastPos��Բ�����������
% ����nxCurPos��Բ�����յ�����
% ����nRadius��Բ���İ뾶
% ����ֵnxArcCenter��Բ����Բ��
function nxArcCenter = TransRadiusToArcCenter(strCurGId, nxLastPos, nxCurPos, nRadius)
    % �����ҳ�
    nChordLength = norm(nxCurPos - nxLastPos);
    % ������ת�Ƕ�
    nCosAngle = nChordLength * 0.5 / abs(nRadius);
    nSinAngle = sqrt(1 - nCosAngle * nCosAngle);
    % ������ת����
    if strcmp('G2', strCurGId) && nRadius > 0
        nSinAngle = -nSinAngle;
    end
    if strcmp('G3', strCurGId) && nRadius < 0
        nSinAngle = -nSinAngle;
    end
    % ����Բ��
    nAlpha = abs(nRadius) / nChordLength;
    nxArcCenter = zeros(1,2);
    nxArcCenter(1) = nxLastPos(1) + nAlpha * ((nxCurPos(1) - nxLastPos(1)) * nCosAngle...
        - (nxCurPos(2) - nxLastPos(2)) * nSinAngle);
    nxArcCenter(2) = nxLastPos(2) + nAlpha * ((nxCurPos(1) - nxLastPos(1)) * nSinAngle...
        + (nxCurPos(2) - nxLastPos(2)) * nCosAngle);
end

%% ��������ƽ�潫��ά����ת��Ϊ��ά����
% ����strG17������ƽ��
% ����nxThreeAxis����ά�ռ��е�����
% ����ֵnxTwoAxis����ά�ռ��е�����
% ����ֵnThreeAxis������ά�ռ������ֵ
function [nxTwoAxis, nThreeAxis] = GetTwoAxisByPlane(strG17, nxThreeAxis)
    % ��ʼ��
    nxTwoAxis = zeros(1,2);
    switch strG17
        case 'G17'
            nxTwoAxis(1) = nxThreeAxis(1);
            nxTwoAxis(2) = nxThreeAxis(2);
            nThreeAxis = nxThreeAxis(3);
        case 'G18'
            nxTwoAxis(1) = nxThreeAxis(3);
            nxTwoAxis(2) = nxThreeAxis(1);
            nThreeAxis = nxThreeAxis(2);
        case 'G19'
            nxTwoAxis(1) = nxThreeAxis(2);
            nxTwoAxis(2) = nxThreeAxis(3);
            nThreeAxis = nxThreeAxis(1);
        otherwise
            error('�����Gָ�%s', strG17);
    end
end

%% ��������ƽ�潫��ά����ת��Ϊ��ά����
% ����strG17������ƽ��
% ����nxTwoAxis����ά�ռ��е�����
% ����nThreeAxis������ά�ռ������
% ����ֵnxThreeAxis����ά�ռ��е�����
function nxThreeAxis = GetThreeAxisByPlane(strG17, nxTwoAxis, nThreeAxis)
    % ��ʼ��
    nxThreeAxis = zeros(1,3);
    switch strG17
        case 'G17'
            nxThreeAxis(1) = nxTwoAxis(1);
            nxThreeAxis(2) = nxTwoAxis(2);
            nxThreeAxis(3) = nThreeAxis;
        case 'G18'
            nxThreeAxis(3) = nxTwoAxis(1);
            nxThreeAxis(1) = nxTwoAxis(2);
            nxThreeAxis(2) = nThreeAxis;
        case 'G19'
            nxThreeAxis(2) = nxTwoAxis(1);
            nxThreeAxis(3) = nxTwoAxis(2);
            nxThreeAxis(1) = nThreeAxis;
        otherwise
            error('�����Gָ�%s', strG17);
    end
end