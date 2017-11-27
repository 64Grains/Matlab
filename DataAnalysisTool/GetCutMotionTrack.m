%% 获取剪切运动轨迹
function [cutMotionTracks, cutMotionFlags] = GetCutMotionTrack(filePath, cutIndexs)
    cutMotionTracks = [];
    cutMotionFlags = [];
    [motionTracks, motionFlags] = GetMotionTrack(filePath);
    % 参数判断
    if length(motionTracks) ~= 1 || length(motionTracks) ~= length(motionFlags)
        fprintf('运动轨迹不满足剪切条件：运动轨迹数为%d\n', length(motionTracks));
        return;
    end
    motionTrack = motionTracks{1};
    motionFlag = motionFlags{1};
    % 获取剪切轨迹
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