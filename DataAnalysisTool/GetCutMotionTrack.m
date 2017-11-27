%% ��ȡ�����˶��켣
function [cutMotionTracks, cutMotionFlags] = GetCutMotionTrack(filePath, cutIndexs)
    cutMotionTracks = [];
    cutMotionFlags = [];
    [motionTracks, motionFlags] = GetMotionTrack(filePath);
    % �����ж�
    if length(motionTracks) ~= 1 || length(motionTracks) ~= length(motionFlags)
        fprintf('�˶��켣����������������˶��켣��Ϊ%d\n', length(motionTracks));
        return;
    end
    motionTrack = motionTracks{1};
    motionFlag = motionFlags{1};
    % ��ȡ���й켣
    global g_period;
    cutMotionTracks = cell(length(cutIndexs),1);
    cutMotionFlags = cell(length(cutIndexs),1);
    index = 0;
    for i = 1:length(cutIndexs)
        startIndex = max(cutIndexs{i}.startIndex,1);
        endIndex = min(cutIndexs{i}.endIndex, size(motionTrack,1));
        if startIndex >= endIndex
            continue;
        end
        index = index + 1;
        cutMotionTracks{index} = motionTrack(startIndex:endIndex,:);
        cutMotionFlags{index} = [motionFlag, ': ', num2str(cutIndexs{i}.startIndex * g_period), ...
            '-', num2str(cutIndexs{i}.endIndex * g_period)];
    end
    if index > 0
        cutMotionTracks = cutMotionTracks(1:index);
        cutMotionFlags = cutMotionFlags(1:index);
    else
        cutMotionTracks = [];
        cutMotionFlags = [];
    end
end