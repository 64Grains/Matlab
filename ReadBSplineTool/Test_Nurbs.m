%% test
% NURBS������Ϣ���£�
%   nurbs.nDegree ------ ����
%   nurbs.vecKnots ----- �ڵ�ʸ��
%   nurbs.vecPoles ----- ���Ƶ�
%   nurbs.vecWeights --- ���Ƶ��Ӧ��Ȩֵ��
function Test_Nurbs()
    clear all;clc;close all;
    % ��ȡNURBS����
    nurbs = ReadNurbsFromFile('test\circle.nc');
    if isempty(nurbs)
        return;
    end
    % ������ɢ��ʽ
    Test_NurbsScatter(nurbs);
    % ���Ե�ʸ
    Test_NurbsDeriv(nurbs);
end

%%% ��ȡNURBS����
function nurbs = ReadNurbsFromFile(strFilePath)
    nurbs = [];
    % ����ļ��Ƿ����
    bFileExist = exist(strFilePath, 'file');
    if 0 == bFileExist || 7 == bFileExist
        fprintf('�ļ�(%s)������!\n', strFilePath);
        return;
    end
    % NURBS������Ϣ
    nurbs.nDegree = 0;
    nurbs.vecKnots = [];
    nurbs.vecPoles = [];
    nurbs.vecWeights = [];
    % ��ȡ�ļ�
    fidRead = fopen(strFilePath, 'r');
    while ~feof(fidRead)
        % һ���Զ�ȡ����
        fAll = textscan(fidRead, '%s', 1000, 'Delimiter', '\n');
        fCell = fAll{1};
        nMaxLines = size(fCell,1);
        for i = 1:nMaxLines
            % ��ȡ������ÿһ���ַ���
            strOrig = fCell{i};
            if isempty(strOrig)
                continue;
            end
            nurbs = GetNurbsFlags(nurbs, strOrig);
        end
    end
    fclose(fidRead);
    % ���NURBS�����Ƿ�Ϸ�
    CheckNurbs(nurbs);
end

%%% ��ȡNURBS���߱�ʶ����ֵ
function nurbsNew = GetNurbsFlags(nurbs, strOrig)
    nurbsNew = nurbs;
    % ����ֵ
    nxPole = [0, 0, 0];
    bHasPole = false;
    % ������ʶ������Ӧֵ
    vecResult = textscan(strOrig, '%c%f');
    vecFlags = vecResult{1};
    vecValues = vecResult{2};
    for i = 1:length(vecFlags)
        switch vecFlags(i)
            case 'G'
                if vecValues(i) ~= 6.2
                    error('����Ĳ�����G�����ʶΪ%f\n', vecValues(i));
                end
            case 'P'
                if nurbsNew.nDegree ~= 0
                    error('ֻ֧�ֵ���NURBS���ߵĽ���!\n');
                end
                nurbsNew.nDegree = vecValues(i);
            case 'K'
                nurbsNew.vecKnots = [nurbsNew.vecKnots; vecValues(i)];
            case 'X'
                nxPole(1) = vecValues(i);
                bHasPole = true;
            case 'Y'
                nxPole(2) = vecValues(i);
                bHasPole = true;
            case 'Z'
                nxPole(3) = vecValues(i);
                bHasPole = true;
            case 'R'
                nurbsNew.vecWeights = [nurbsNew.vecWeights; vecValues(i)];
            otherwise
                error('����ı�ʶ��:%c\n', vecFlags(i));
        end
    end
    if bHasPole
        nurbsNew.vecPoles = [nurbsNew.vecPoles; nxPole];
    end
end

%%% ������ɢ��ʽ
function Test_NurbsScatter(nurbs)
    % ���������ϵĵ�
    nCount = 200;
    vecPointsByFormula = zeros(nCount+1,3);
    nStartKnot = nurbs.vecKnots(nurbs.nDegree+1);
    nEndKnot = nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree);
    for i = 0:nCount
        nKnot = nStartKnot + (nEndKnot - nStartKnot) * i / nCount;
        if size(nurbs.vecPoles,2) == 2
            [vecPointsByFormula(i+1,1:2), ~, ~] = GetNurbsDeriv(nurbs, nKnot);
        elseif size(nurbs.vecPoles,2) == 3
            [vecPointsByFormula(i+1,:), ~, ~] = GetNurbsDeriv(nurbs, nKnot);
        end
    end
    nDeflection = 1e-2;
    vecPointsByDeflection = ScatterNurbs(nurbs, nDeflection);
    % ��ͼ�Ƚ�
    figure();
    hold on;
    if isequal(vecPointsByFormula(:,3), zeros(size(vecPointsByFormula,1),1))
        plot(vecPointsByFormula(:,1), vecPointsByFormula(:,2), '.-b');
        plot(vecPointsByDeflection(:,1), vecPointsByDeflection(:,2), '.-g');
        plot(nurbs.vecPoles(:,1), nurbs.vecPoles(:,2), '*-r');
    else
        plot3(vecPointsByFormula(:,1), vecPointsByFormula(:,2), vecPointsByFormula(:,3), '.-b');
        plot3(vecPointsByDeflection(:,1), vecPointsByDeflection(:,2), vecPointsByDeflection(:,3), '.-g');
        plot3(nurbs.vecPoles(:,1), nurbs.vecPoles(:,2), nurbs.vecPoles(:,3), '*-r');
        view([1 1 1]);
    end
    legend('���ڵ�ʸ����ɢ��ͼ', '�����������ɢ��ͼ', 'NURBS���߿��Ƶ�');
    title('�켣ͼ');
    axis equal;
end

%%% ���Ե�ʸ
function Test_NurbsDeriv(nurbs)
    % ���㵼ʸ��ֵ
    nCount = 200;
    vecNewDeriv = zeros(nCount+1,9);
    nStartKnot = nurbs.vecKnots(nurbs.nDegree+1);
    nEndKnot = nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree);
    for i = 0:nCount
        nKnot = nStartKnot + (nEndKnot - nStartKnot) * i / nCount;
        if size(nurbs.vecPoles,2) == 2
            [vecNewDeriv(i+1,1:2), vecNewDeriv(i+1,4:5), vecNewDeriv(i+1,7:8)] = GetNurbsDeriv(nurbs, nKnot);
        elseif size(nurbs.vecPoles,2) == 3
            [vecNewDeriv(i+1,1:3), vecNewDeriv(i+1,4:6), vecNewDeriv(i+1,7:9)] = GetNurbsDeriv(nurbs, nKnot);
        end
    end
    nStepKnot = (nEndKnot - nStartKnot) / nCount;
    vecOrigDeriv = vecNewDeriv;
    vecOrigDeriv(2:end,4:6) = diff(vecOrigDeriv(:,1:3)) / nStepKnot;
    vecOrigDeriv(3:end,7:9) = diff(vecOrigDeriv(2:end,4:6)) / nStepKnot;
    % ��ͼ�Ƚ�
    vecTitles = {'һ�׵�ʸͼ', '���׵�ʸͼ'};
    for i = 2:min(nurbs.nDegree+1,3)
        figure();
        hold on;
        if isequal(vecNewDeriv(:,i*3), zeros(size(vecNewDeriv,1),1))
            plot(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), '.-b');
            plot(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), '.-g');
        else
            plot3(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), vecOrigDeriv(i:end,i*3), '.-b');
            plot3(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), vecNewDeriv(:,i*3), '.-g');
            view([1 1 1]);
        end
        legend('΢�ַ���ͼ', '���㷨��ͼ');
        title(vecTitles{i-1});
        axis equal;
    end
    % ��������
    vecNewCurvature = zeros(size(vecNewDeriv,1),1);
    vecOldCurvature = zeros(size(vecOrigDeriv,1),1);
    for i = 1:length(vecNewCurvature)
        nxNumerator = zeros(1,3);
        nxNumerator(1) = vecNewDeriv(i,5) * vecNewDeriv(i,9) - vecNewDeriv(i,8) * vecNewDeriv(i,6);
        nxNumerator(2) = vecNewDeriv(i,6) * vecNewDeriv(i,7) - vecNewDeriv(i,9) * vecNewDeriv(i,4);
        nxNumerator(3) = vecNewDeriv(i,4) * vecNewDeriv(i,8) - vecNewDeriv(i,7) * vecNewDeriv(i,5);
        vecNewCurvature(i) = norm(nxNumerator) / (norm(vecNewDeriv(i,4:6)))^3;
    end
    for i = 1:length(vecOldCurvature)
        nxNumerator = zeros(1,3);
        nxNumerator(1) = vecOrigDeriv(i,5) * vecOrigDeriv(i,9) - vecOrigDeriv(i,8) * vecOrigDeriv(i,6);
        nxNumerator(2) = vecOrigDeriv(i,6) * vecOrigDeriv(i,7) - vecOrigDeriv(i,9) * vecOrigDeriv(i,4);
        nxNumerator(3) = vecOrigDeriv(i,4) * vecOrigDeriv(i,8) - vecOrigDeriv(i,7) * vecOrigDeriv(i,5);
        vecOldCurvature(i) = norm(nxNumerator) / (norm(vecOrigDeriv(i,4:6)))^3;
    end
    % ��ͼ
    figure();
    hold on;
    plot(1:length(vecOldCurvature), vecOldCurvature, '.-b');
    plot(1:length(vecNewCurvature), vecNewCurvature, '.-g');
    legend('΢�ַ���ͼ', '���㷨��ͼ');
    title('����ͼ');
end