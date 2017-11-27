%% 获取运动轨迹
function [motionTracks, motionFlags] = GetMotionTrack(allFiles)
    motionTracks = [];
    motionFlags = [];
    if isempty(allFiles)
        return;
    end
    % 解析文件
    if ~iscell(allFiles)
        [motionTrack, motionFlag] = GetTrack(allFiles);
        if ~isempty(motionTrack)
            motionTracks{1} = motionTrack;
            motionFlags{1} = motionFlag;
        end
    else
        motionTracks = cell(length(allFiles),1);
        motionFlags = cell(length(allFiles),1);
        index = 0;
        for i = 1:length(allFiles)
            [motionTrack, motionFlag] = GetTrack(allFiles{i});
            if ~isempty(motionTrack)
                index = index + 1;
                motionTracks{index} = motionTrack;
                motionFlags{index} = motionFlag;
            end
        end
        motionTracks = motionTracks(1:index);
        motionFlags = motionFlags(1:index);
    end
end

%% 获取运动轨迹
function [motionTrack, motionFlag] = GetTrack(filePath)
    motionTrack = [];
    motionFlag = [];
    % 检查文件是否存在
    fileExist = exist(filePath, 'file');
    if (0 == fileExist) || (7 == fileExist)
        fprintf('文件(%s)不存在！\n', filePath);
        return;
    end
    % 文件名称
    fileInfo = dir(filePath);
    motionFlag = fileInfo.name;
    % 轨迹
    global g_dataFormat;
    fidRead = fopen(filePath, 'r');
    fAll = textscan(fidRead, g_dataFormat);
    fclose(fidRead);
    % 筛选数值列
    validTrack = zeros(length(fAll{1}), length(fAll));
    index = 0;
    if size(validTrack,1) > 1
        for i = 1:length(fAll)
            if isnumeric(fAll{i}(1))
                index = index + 1;
                validTrack(:, index) = fAll{i};
            end
        end
    end
    validTrack = validTrack(:,1:index);
    % 筛选有效数值列
    motionTrack = GetValidTrack(validTrack);
    % 删除首尾冗余数据
    motionTrack = DeleteRepeatTrack(motionTrack);
end

%% 筛选有效数值列
function validTrack = GetValidTrack(origTrack)
    if size(origTrack,1) < 1
        validTrack = [];
        return;
    end
    global g_validColumn;
    validTrack = zeros(size(origTrack));
    index = 0;
    column = 1;
    for i = 1:size(origTrack,2)
        if column > length(g_validColumn)
            break;
        end
        if i == g_validColumn(column)
            index = index + 1;
            validTrack(:,index) = origTrack(:,i);
            column = column + 1;
        end
    end
    if index > 0
        validTrack = validTrack(:,1:index);
    else
        validTrack = [];
    end
end

%% 删除首尾冗余数据
function simplifyData = DeleteRepeatTrack(origData)
    global g_deleteRepeat;
    if ~g_deleteRepeat
        simplifyData = origData;
        return;
    end
    % 首部重复数据
    startIndex = 1;
    while startIndex < size(origData,1)
        if ~isequal(origData(startIndex,:), origData(startIndex+1,:))
            break;
        end
        startIndex = startIndex + 1;
    end
    % 尾部重复数据
    endIndex = size(origData,1);
    while endIndex > 1
        if ~isequal(origData(endIndex,:), origData(endIndex-1,:))
            break;
        end
        endIndex = endIndex - 1;
    end
    % 截取数据
    simplifyData = origData(startIndex:endIndex,:);
end