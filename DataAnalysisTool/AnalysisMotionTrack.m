%% 分析运动轨迹，并根据选项画图
function AnalysisMotionTrack(motionTracks, motionFlags)
    if isempty(motionTracks)
        fprintf('没有需要分析的运动轨迹！\n');
        return;
    end
    % 画图选项
    global FileEntity;
    figId = FileEntity{end}.FigHandle;
    figColor = {'.-b', '.-g', '.-r', '.-m', '.-c', '.-y', '.-w'};
    % 画图
    figLegend = '';
    for i = 1:min(length(motionTracks), length(figColor)-1)
        Id = DrawMotionTrack(motionTracks{i}, figId, figColor{i});
        figLegend = strcat(figLegend, '''', motionFlags{i}, '''', ',');
    end
    for i = figId+1:Id
        FileEntity{size(FileEntity,2)+1}.FigHandle = i;
        figure(i);
        eval(['legend(', figLegend(1:length(figLegend)-1), ')']);
    end
end

%% 运动轨迹画图
function Id = DrawMotionTrack(motionTrack, figId, figColor)
    Id = figId;
    % 轨迹
    global g_drawTrack;
    if g_drawTrack
        Id = DrawTrack(motionTrack, Id, figColor);
    end
    % 速度
    global g_drawTimeSpeed;
    global g_drawTimeAcc;
    global g_drawTimeJerk;
    global g_drawDistSpeed;
    if ~g_drawTimeSpeed && ~g_drawTimeAcc && ~g_drawTimeJerk && ~g_drawDistSpeed
        return;
    end
    motionSpeed = GetSpeed(motionTrack);
    if g_drawTimeSpeed
        Id = DrawMotionWithTitle(motionSpeed, Id, figColor, '时间-速度图');
    end
    if g_drawDistSpeed
        Id = DrawDistSpeed(motionSpeed, Id, figColor);
    end
    % 加速度
    if ~g_drawTimeAcc && ~g_drawTimeJerk
        return;
    end
    motionAcc = GetAcc(motionSpeed);
    if g_drawTimeAcc
        Id = DrawMotionWithTitle(motionAcc, Id, figColor, '时间-加速度图');
    end
    % 加加速度
    if ~g_drawTimeJerk
        return;
    end
    motionJerk = GetAcc(motionAcc);
    Id = DrawMotionWithTitle(motionJerk, Id, figColor, '时间-加加速度图');
end

%% 轨迹画图
function Id = DrawTrack(motionTrack, figId, figColor)
    Id = figId;
    global g_SingleAxisMode;
    if g_SingleAxisMode
        fprintf('单轴模式下不支持画轨迹图！\n');
        return;
    end
    if size(motionTrack,2) < 1
        fprintf('没有用于画轨迹图的数据！\n');
        return;
    end
    if size(motionTrack,2) > 3
        fprintf('不支持超过3维的轨迹作图：实际维数为%d\n', size(motionTrack,2));
        return;
    end
    % 画图
    Id = Id + 1;
    figure(Id);
    hold on;
    if size(motionTrack,2) == 1
        plot(motionTrack, zeros(size(motionTrack,1),1), figColor);
    elseif size(motionTrack,2) == 2
        plot(motionTrack(:,1), motionTrack(:,2), figColor);
    else
        plot3(motionTrack(:,1), motionTrack(:,2), motionTrack(:,3), figColor);
        view([1 1 1]);
    end
    axis equal;
    title('轨迹图');
    grid on;
end

%% 获取速度
function motionSpeed = GetSpeed(motionTrack)
    global g_period;
    [row, column] = size(motionTrack);
    motionSpeed = zeros(row-1,column+2);
    for i = 1:row-1
        motionSpeed(i,1) = i * g_period;
        for j = 1:column
            motionSpeed(i,j+1) = (motionTrack(i+1,j) - motionTrack(i,j)) / g_period;
        end
        motionSpeed(i,column+2) = norm(motionSpeed(i,2:column+1));
    end
end

%% 获取加速度
function motionAcc = GetAcc(motionSpeed)
    global g_period;
    [row, column] = size(motionSpeed);
    motionAcc = zeros(row-1,column);
    for i = 1:row-1
        motionAcc(i,1) = motionSpeed(i,1);
        for j = 2:column
            motionAcc(i,j) = (motionSpeed(i+1,j) - motionSpeed(i,j)) / g_period;
        end
    end
end

%% 根据标题画图（速度、加速度、加加速度）
function Id = DrawMotionWithTitle(motionParam, figId, figColor, figTitle)
    Id = figId;
    global g_SingleAxisMode;
    % 根据维数决定图像布局：第一列为时间，最后一列为所有维数的合
    column = size(motionParam,2);
    if column < 3
        fprintf('错误的参数：数据维数不足！\n');
        return;
    end
    preTitle = {'X轴', 'Y轴', 'Z轴', '合'};
    if column == 3
        % 一维数据：只画单轴数据
        Id = Id + 1;
        figure(Id);
        hold on;
        plot(motionParam(:,1), motionParam(:,2), figColor);
        title([preTitle{1}, figTitle]);
        axis auto; grid on;
    elseif column == 4 && ~g_SingleAxisMode
        % 二维数据：画单轴数据和合数据
        Id = Id + 1;
        figure(Id);
        handleSub = cell(3,1);
        for i = 1:3
            handleSub{i} = subplot(3,1,i);
            hold on;
            plot(motionParam(:,1), motionParam(:,i+1), figColor);
            if i ~= 3
                j = i;
            else
                j = i + 1;
            end
            title([preTitle{j}, figTitle]);
            axis auto; grid on;
        end
        linkaxes([handleSub{1}, handleSub{2}, handleSub{3}], 'x');
    elseif column == 5 && ~g_SingleAxisMode
        % 三维数据：画单轴数据和合数据
        for i = 1:2:3
            Id = Id + 1;
            figure(Id);
            handleSub = cell(2,1);
            for j = 1:2
                handleSub{j} = subplot(2,1,j);
                hold on;
                plot(motionParam(:,1), motionParam(:,i+j), figColor);
                title([preTitle{i+j-1}, figTitle]);
                axis auto; grid on;
            end
            linkaxes([handleSub{1}, handleSub{2}], 'x');
        end
    else
        % 只画单轴数据：超过三维的数据默认不画合数据
        for i = 1:2:column-3
            Id = Id + 1;
            figure(Id);
            handleSub = cell(2,1);
            for j = 1:2
                handleSub{j} = subplot(2,1,j);
                hold on;
                plot(motionParam(:,1), motionParam(:,i+j), figColor);
                title(['第', num2str(i+j-1), '维', figTitle]);
                axis auto; grid on;
            end
            linkaxes([handleSub{1}, handleSub{2}], 'x');
        end
        if mod(column,2)
            Id = Id + 1;
            figure(Id);
            hold on;
            plot(motionParam(:,1), motionParam(:,column-1), figColor);
            title(['第', num2str(column-1), '维', figTitle]);
            axis auto; grid on;
        end
    end
end

%% 画距离-速度图
function Id = DrawDistSpeed(motionSpeed, figId, figColor)
    Id = figId;
    global g_SingleAxisMode;
    if g_SingleAxisMode
        fprintf('单轴模式下不支持画距离-轨迹图！\n');
        return;
    end
    [row, column] = size(motionSpeed);
    if column < 3 || column > 5
        error('%d维数据不支持画距离-速度图！\n', column-2);
    end
    global g_period;
    distSpeed = zeros(row,2);
    distSpeed(1,1) = motionSpeed(1,column) * g_period;
    distSpeed(1,2) = motionSpeed(1,column);
    for i = 2:row
        distSpeed(i,1) = distSpeed(i-1,1) + motionSpeed(i,column) * g_period;
        distSpeed(i,2) = motionSpeed(i,column);
    end
    % 画图
    Id = figId + 1;
    figure(Id);
    hold on;
    plot(distSpeed(:,1), distSpeed(:,2), figColor);
    title('距离-速度图');
    grid on;
end
