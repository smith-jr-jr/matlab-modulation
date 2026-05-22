function system_design_backup

    colors = getUiColors();
    fontName = 'Microsoft YaHei UI';
    modulations = getModulationDefinitions();

 
    mainFig = figure( ...
        'Name', '数字调制演示平台', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Resize', 'off', ...
        'Color', colors.figure, ...
        'Position', [120 80 1380 820]);

    controlPanel = uipanel( ...
        'Parent', mainFig, ...
        'Title', '控制区', ...
        'FontName', fontName, ...
        'FontSize', 12, ...
        'BackgroundColor', colors.panel, ...
        'Position', [0.02 0.04 0.25 0.92]);

    displayPanel = uipanel( ...
        'Parent', mainFig, ...
        'Title', '波形与分析区', ...
        'FontName', fontName, ...
        'FontSize', 12, ...
        'BackgroundColor', colors.panel, ...
        'Position', [0.29 0.04 0.69 0.92]);

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '数字调制演示平台', ...
        'FontName', fontName, ...
        'FontSize', 16, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.title, ...
        'Position', [20 706 290 34]);

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '点击按钮生成固定均匀符号序列与调制信号', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text, ...
        'Position', [20 676 290 22]);

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '', ...
        'FontName', fontName, ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.mutedText, ...
        'Position', [20 654 290 20]);

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '调制按钮区', ...
        'FontName', fontName, ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text, ...
        'Position', [20 622 120 22]);

    buttonWidth = 82;
    buttonHeight = 34;
    buttonGap = 12;
    xPositions = [20 20 + buttonWidth + buttonGap];
    startY = 586;
    rowGap = 44;
    usedColumns = 2;

    % 按钮区仅保留两列实体按钮
    for idx = 1:numel(modulations)
        modDef = modulations(idx);
        row = floor((idx - 1) / usedColumns);
        col = mod(idx - 1, usedColumns) + 1;
        uicontrol( ...
            'Parent', controlPanel, ...
            'Style', 'pushbutton', ...
            'String', modDef.name, ...
            'FontName', fontName, ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'Position', [xPositions(col) startY - row * rowGap buttonWidth buttonHeight], ...
            'Callback', @(~, ~)generateSignal(mainFig, modDef));
    end

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'pushbutton', ...
        'String', '识别调制方式', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Position', [20 366 176 34], ...
        'Callback', @(~, ~)identifyModulation(mainFig));

    identifyObjectText = uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '识别对象：未识别', ...
        'FontName', fontName, ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.mutedText, ...
        'Position', [20 344 270 18]);

    identifyResultText = uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '识别结果：点击识别按钮', ...
        'FontName', fontName, ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.mutedText, ...
        'Position', [20 320 270 18]);

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'pushbutton', ...
        'String', '加入高斯白噪声（12 dB）', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'Position', [20 278 176 38], ...
        'Callback', @(~, ~)applyNoise(mainFig));

    uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '状态信息', ...
        'FontName', fontName, ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.text, ...
        'Position', [20 240 120 22]);

    statusText = uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'text', ...
        'String', '状态：等待生成信号', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', colors.panel, ...
        'ForegroundColor', colors.title, ...
        'Position', [20 214 290 22]);

    infoBox = uicontrol( ...
        'Parent', controlPanel, ...
        'Style', 'edit', ...
        'Enable', 'inactive', ...
        'Max', 12, ...
        'Min', 0, ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 1], ...
        'Position', [20 24 290 176], ...
        'String', getWelcomeInfo());

    axesPosition = { ...
        [0.07 0.56 0.40 0.35], ...
        [0.55 0.56 0.40 0.35]};

    axesHandles.track = axes('Parent', displayPanel, 'Position', axesPosition{1});
    axesHandles.signal = axes('Parent', displayPanel, 'Position', axesPosition{2});

    reserveDisplayPanel = uipanel( ...
        'Parent', displayPanel, ...
        'Title', '累积量与特征区', ...
        'FontName', fontName, ...
        'FontSize', 11, ...
        'BackgroundColor', [1 1 1], ...
        'ForegroundColor', colors.mutedText, ...
        'HighlightColor', colors.edge, ...
        'ShadowColor', colors.edge, ...
        'Position', [0.55 0.10 0.40 0.35]);

    cumulantPanel = uipanel( ...
        'Parent', reserveDisplayPanel, ...
        'Title', '累积量结果', ...
        'Units', 'normalized', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'BackgroundColor', [1 1 1], ...
        'ForegroundColor', colors.title, ...
        'Position', [0.03 0.08 0.46 0.86]);

    cumulantText = uicontrol( ...
        'Parent', cumulantPanel, ...
        'Style', 'edit', ...
        'Enable', 'inactive', ...
        'Max', 20, ...
        'Min', 0, ...
        'FontName', fontName, ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 1], ...
        'ForegroundColor', colors.text, ...
        'Position', [8 8 165 146], ...
        'String', getCumulantPlaceholderText());

    featurePanel = uipanel( ...
        'Parent', reserveDisplayPanel, ...
        'Title', '特征参数', ...
        'Units', 'normalized', ...
        'FontName', fontName, ...
        'FontSize', 10, ...
        'BackgroundColor', [1 1 1], ...
        'ForegroundColor', colors.title, ...
        'Position', [0.51 0.08 0.46 0.86]);

    featureText = uicontrol( ...
        'Parent', featurePanel, ...
        'Style', 'edit', ...
        'Enable', 'inactive', ...
        'Max', 20, ...
        'Min', 0, ...
        'String', getFeaturePlaceholderText(), ...
        'FontName', fontName, ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1 1 1], ...
        'ForegroundColor', colors.text, ...
        'Position', [8 8 165 146]);

    % 用 guidata 维护界面句柄和当前信号状态，便于不同按钮共享数据。
    state = struct();
    state.handles = struct( ...
        'statusText', statusText, ...
        'infoBox', infoBox, ...
        'axes', axesHandles, ...
        'cumulantPanel', cumulantPanel, ...
        'cumulantText', cumulantText, ...
        'reserveDisplayPanel', reserveDisplayPanel, ...
        'featurePanel', featurePanel, ...
        'featureText', featureText, ...
        'identifyObjectText', identifyObjectText, ...
        'identifyResultText', identifyResultText);
    state.colors = colors;
    state.noiseSnrDb = 12;
    state.current = [];
    state.recognition = [];
    guidata(mainFig, state);

    showWelcomePlots(axesHandles, colors);
end

function generateSignal(mainFig, modDef)


    state = guidata(mainFig);
    data = buildModulatedSignal(modDef);
    data = updateCumulantAnalysis(data);
    state.current = data;
    state.recognition = [];
    guidata(mainFig, state);

    exportSignalToWorkspace(data);
    refreshDisplay(mainFig);
    updateStatus(mainFig, sprintf('状态：%s 信号已生成，并已写入工作区。', modDef.name));
end

function applyNoise(mainFig)


    state = guidata(mainFig);
    if isempty(state.current)
        updateStatus(mainFig, '状态：请先生成一种调制信号，再添加高斯白噪声。');
        return;
    end

    data = state.current;
    data.noisySignal = addGaussianNoise(data.signal, state.noiseSnrDb);
    data.noisyFeatureSignal = addGaussianNoise(data.featureSignal, state.noiseSnrDb);
    data.hasNoise = true;
    data.noiseSnrDb = state.noiseSnrDb;
    data = updateCumulantAnalysis(data);
    state.current = data;
    state.recognition = [];
    guidata(mainFig, state);

    exportSignalToWorkspace(data);
    refreshDisplay(mainFig);
    updateStatus(mainFig, sprintf('状态：已为 %s 信号加入 %.0f dB 高斯白噪声。', ...
        data.name, state.noiseSnrDb));
end

function refreshDisplay(mainFig)


    state = guidata(mainFig);
    handles = state.handles;
    colors = state.colors;
    data = state.current;

    if isempty(data)
        showWelcomePlots(handles.axes, colors);
        set(handles.infoBox, 'String', getWelcomeInfo());
        set(handles.cumulantText, 'String', getCumulantPlaceholderText());
        set(handles.featureText, 'String', getFeaturePlaceholderText());
        set(handles.identifyObjectText, 'String', '识别对象：未识别', ...
            'ForegroundColor', colors.mutedText);
        set(handles.identifyResultText, 'String', '识别结果：点击识别按钮', ...
            'ForegroundColor', colors.mutedText);
        return;
    end

    noiseLabel = getNoiseLabel(data);
    set(handles.identifyObjectText, 'String', ...
        sprintf('识别对象：%s（%s）', data.name, noiseLabel), ...
        'ForegroundColor', colors.text);

    if isempty(state.recognition)
        set(handles.identifyResultText, 'String', '识别结果：点击识别按钮', ...
            'ForegroundColor', colors.mutedText);
    end

    tMs = data.time * 1e3;
    displayEndMs = min(100, tMs(end));
    displayMask = (tMs >= 0) & (tMs <= displayEndMs);
    displayTimeMs = tMs(displayMask);
    % 欢迎占位图会隐藏坐标轴，正式绘图前恢复显示。
    set(handles.axes.track, 'Visible', 'on');
    set(handles.axes.signal, 'Visible', 'on');

    cla(handles.axes.track);
    if strcmp(data.trackMode, 'double')
        plot(handles.axes.track, displayTimeMs, data.track1(displayMask), 'LineWidth', 1.3, ...
            'Color', colors.primary);
        hold(handles.axes.track, 'on');
        plot(handles.axes.track, displayTimeMs, data.track2(displayMask), 'LineWidth', 1.3, ...
            'Color', colors.secondary);
        hold(handles.axes.track, 'off');
        legend(handles.axes.track, {'I 路', 'Q 路'}, 'Location', 'northeast');
    else
        plot(handles.axes.track, displayTimeMs, data.track1(displayMask), 'LineWidth', 1.5, ...
            'Color', colors.primary);
    end
    grid(handles.axes.track, 'on');
    xlim(handles.axes.track, [0 displayEndMs]);
    title(handles.axes.track, data.trackTitle, 'FontWeight', 'bold');
    xlabel(handles.axes.track, '时间 / ms');
    ylabel(handles.axes.track, data.trackLabel);

    cla(handles.axes.signal);
    legend(handles.axes.signal, 'off');
    if strcmp(data.family, 'QAM')
        plotSignalConstellation(handles.axes.signal, data, colors);
    else
        if data.hasNoise
            plot(handles.axes.signal, displayTimeMs, data.signal(displayMask), '--', 'LineWidth', 1.0, ...
                'Color', [0.60 0.60 0.60]);
            hold(handles.axes.signal, 'on');
            plot(handles.axes.signal, displayTimeMs, data.noisySignal(displayMask), 'LineWidth', 1.2, ...
                'Color', colors.signal);
            hold(handles.axes.signal, 'off');
            legend(handles.axes.signal, {'原始信号', '加噪信号'}, 'Location', 'best');
            signalTitle = sprintf('%s 时域波形（含 %.0f dB 噪声）', ...
                data.name, data.noiseSnrDb);
        else
            plot(handles.axes.signal, displayTimeMs, data.signal(displayMask), 'LineWidth', 1.2, ...
                'Color', colors.signal);
            signalTitle = sprintf('%s 时域波形', data.name);
        end
        grid(handles.axes.signal, 'on');
        xlim(handles.axes.signal, [0 displayEndMs]);
        % 统一所有调制信号的时域幅度显示范围，便于不同按钮之间横向比较。
        ylim(handles.axes.signal, [-1.5 1.5]);
        title(handles.axes.signal, signalTitle, 'FontWeight', 'bold');
        xlabel(handles.axes.signal, '时间 / ms');
        ylabel(handles.axes.signal, '幅度');
    end

    set(handles.cumulantText, 'String', buildCumulantLines(data));
    set(handles.featureText, 'String', buildFeatureLines(data));

    set(handles.infoBox, 'String', buildInfoLines(data));
end

function plotSignalConstellation(axHandle, data, colors)
% PLOTSIGNALCONSTELLATION 在时域显示区绘制 QAM 信号星座图。
% 输入参数：
%   axHandle - 用于显示星座图的坐标轴句柄。
%   data     - 当前 QAM 信号数据，包含理想星座点、当前符号点和加噪状态。
%   colors   - 界面统一配色结构体。
% 输出参数：
%   无。函数会直接更新指定坐标轴中的星座图。

    referencePoints = data.referencePoints;
    currentPoints = data.usedPoints;
    legendText = {'理想星座点', '当前符号点'};

    if data.hasNoise && ~isempty(data.noisyFeatureSignal)
        currentPoints = extractReceivedConstellationPoints(data);
        legendText = {'理想星座点', '加噪接收点'};
    end

    plot(axHandle, referencePoints(:, 1), referencePoints(:, 2), 'o', ...
        'LineWidth', 1.4, ...
        'MarkerSize', 8, ...
        'Color', colors.primary, ...
        'MarkerFaceColor', [1 1 1]);
    hold(axHandle, 'on');
    plot(axHandle, currentPoints(:, 1), currentPoints(:, 2), '.', ...
        'MarkerSize', 18, ...
        'Color', colors.signal);
    hold(axHandle, 'off');

    grid(axHandle, 'on');
    axis(axHandle, 'equal');
    xlim(axHandle, [-1.5 1.5]);
    ylim(axHandle, [-1.5 1.5]);
    title(axHandle, data.mappingTitle, 'FontWeight', 'bold');
    xlabel(axHandle, data.mappingXLabel);
    ylabel(axHandle, data.mappingYLabel);
    legend(axHandle, legendText, 'Location', 'best');
end

function receivedPoints = extractReceivedConstellationPoints(data)
% EXTRACTRECEIVEDCONSTELLATIONPOINTS 从加噪复基带信号中抽取每个符号中心点。
% 输入参数：
%   data - 当前调制信号结构体，需包含 noisyFeatureSignal 和 numSymbols。
% 输出参数：
%   receivedPoints - N x 2 的 I/Q 坐标矩阵，用于绘制加噪后的接收星座点。

    samplesPerSymbol = max(1, round(numel(data.noisyFeatureSignal) / data.numSymbols));
    centerOffset = max(1, round(samplesPerSymbol / 2));
    centerIndices = centerOffset:samplesPerSymbol:numel(data.noisyFeatureSignal);
    centerIndices = centerIndices(1:min(numel(centerIndices), data.numSymbols));
    receivedSymbols = data.noisyFeatureSignal(centerIndices);
    receivedPoints = [real(receivedSymbols(:)) imag(receivedSymbols(:))];
end

function data = updateCumulantAnalysis(data)
% UPDATECUMULANTANALYSIS 更新当前接收信号对应的高阶累积量结果。
% 输入参数：
%   data - 当前调制结果结构体。
% 输出参数：
%   data - 补充了复基带接收信号描述、混合矩、累积量和特征参数结果的结构体。

    if data.hasNoise
        receivedSignal = data.noisyFeatureSignal;
        receivedLabel = '复基带接收信号（加噪）';
    else
        receivedSignal = data.featureSignal;
        receivedLabel = '复基带接收信号';
    end

    data.receivedSignalName = receivedLabel;
    data.cumulantAnalysis = computeHighOrderCumulants(receivedSignal);
    data.featureValues = computeFeatureValues( ...
        data.cumulantAnalysis.cumulants, receivedSignal, data.sampleRate);
end

function data = buildModulatedSignal(modDef)
% BUILDMODULATEDSIGNAL 根据调制定义生成完整演示数据。
% 输入参数：
%   modDef - 调制方式结构体，包含调制家族和阶数信息。
% 输出参数：
%   data   - 结果结构体，含比特流、符号索引、时域信号、复基带信号、
%            轨迹数据及绘图所需元数据。

    params.symbolRate = 100;
    params.samplePerSymbol = 240;
    params.numSymbols = 256;
    params.carrierFreq = 1000;
    params.symbolDuration = 1 / params.symbolRate;
    params.dt = params.symbolDuration / params.samplePerSymbol;
    params.sampleRate = 1 / params.dt;

    bitsPerSymbol = round(log2(modDef.M));
    baseSymbolIndices = generateUniformSymbolSequence(modDef.M, params.numSymbols);
    bits = symbolIndicesToBits(baseSymbolIndices, bitsPerSymbol);
    symbolIndices = bitsToSymbolIndices(bits, bitsPerSymbol);
    time = (0:(params.numSymbols * params.samplePerSymbol - 1)) * params.dt;

    carrierCos = cos(2 * pi * params.carrierFreq * time);
    carrierSin = sin(2 * pi * params.carrierFreq * time);

    data = struct();
    data.name = modDef.name;
    data.family = modDef.family;
    data.M = modDef.M;
    data.bits = bits;
    data.bitsPerSymbol = bitsPerSymbol;
    data.symbolIndices = symbolIndices;
    data.numSymbols = params.numSymbols;
    data.carrierFreq = params.carrierFreq;
    data.sampleRate = params.sampleRate;
    data.time = time;
    data.signal = [];
    data.featureSignal = [];
    data.noisySignal = [];
    data.noisyFeatureSignal = [];
    data.hasNoise = false;
    data.noiseSnrDb = [];
    data.targetSymbolEnergy = 1;
    data.averageSymbolEnergy = NaN;
    data.symbolEnergyScale = 1;

    switch modDef.family
        case 'ASK'
            % ASK：用离散幅度电平映射不同符号。
            levels = linspace(0, 1, modDef.M);
            symbolValues = levels(symbolIndices + 1);
            amplitudeWave = repelem(symbolValues, params.samplePerSymbol);

            data.signal = amplitudeWave .* carrierCos;
            data.featureSignal = complex(amplitudeWave, zeros(size(amplitudeWave)));
            data.trackMode = 'single';
            data.track1 = amplitudeWave;
            data.track2 = [];
            data.trackTitle = '基带幅度轨迹';
            data.trackLabel = '幅度';
            data.referencePoints = [levels(:) zeros(modDef.M, 1)];
            data.usedPoints = [symbolValues(:) zeros(numel(symbolValues), 1)];
            data.mappingTitle = sprintf('%s 符号幅度分布', modDef.name);
            data.mappingXLabel = '幅度电平';
            data.mappingYLabel = '';
            data.isOneDimensionalMapping = true;

        case 'FSK'
            % FSK：为每个符号分配不同频偏，并通过累计相位生成连续波形。
            toneSpacing = params.symbolRate / 2;
            freqOffsets = ((0:(modDef.M - 1)) - (modDef.M - 1) / 2) * toneSpacing;
            symbolFrequencies = params.carrierFreq + freqOffsets(symbolIndices + 1);
            frequencyWave = repelem(symbolFrequencies, params.samplePerSymbol);
            phaseWave = 2 * pi * params.dt * cumsum(frequencyWave);
            basebandFreqWave = repelem(freqOffsets(symbolIndices + 1), params.samplePerSymbol);
            basebandPhaseWave = 2 * pi * params.dt * cumsum(basebandFreqWave);

            data.signal = sin(phaseWave);
            data.featureSignal = exp(1i * basebandPhaseWave);
            data.trackMode = 'single';
            data.track1 = frequencyWave;
            data.track2 = [];
            data.trackTitle = '频率轨迹';
            data.trackLabel = '频率 / Hz';
            data.referencePoints = [freqOffsets(:) zeros(modDef.M, 1)];
            data.usedPoints = [freqOffsets(symbolIndices + 1).' zeros(numel(symbolIndices), 1)];
            data.mappingTitle = sprintf('%s 音调分布', modDef.name);
            data.mappingXLabel = '相对频偏 / Hz';
            data.mappingYLabel = '';
            data.isOneDimensionalMapping = true;

        case 'PSK'
            % PSK：保持幅度不变，仅切换载波相位。
            phaseSet = 2 * pi * (0:(modDef.M - 1)) / modDef.M;
            symbolPhases = phaseSet(symbolIndices + 1);
            phaseWave = repelem(symbolPhases, params.samplePerSymbol);

            data.signal = cos(2 * pi * params.carrierFreq * time + phaseWave);
            data.featureSignal = exp(1i * phaseWave);
            data.trackMode = 'single';
            data.track1 = phaseWave / pi;
            data.track2 = [];
            data.trackTitle = '相位轨迹';
            data.trackLabel = '相位 / \pi';
            data.referencePoints = [cos(phaseSet(:)) sin(phaseSet(:))];
            data.usedPoints = [cos(symbolPhases(:)) sin(symbolPhases(:))];
            data.mappingTitle = sprintf('%s 星座图', modDef.name);
            data.mappingXLabel = '同相 I';
            data.mappingYLabel = '正交 Q';
            data.isOneDimensionalMapping = false;

        case 'QAM'
            % QAM：分别调制 I/Q 两路基带，再合成为带通信号。
            constellation = getQamConstellation(modDef.M);
            symbolPoints = constellation(symbolIndices + 1);
            iWave = repelem(real(symbolPoints), params.samplePerSymbol);
            qWave = repelem(imag(symbolPoints), params.samplePerSymbol);

            data.signal = iWave .* carrierCos - qWave .* carrierSin;
            data.featureSignal = iWave + 1i * qWave;
            data.trackMode = 'double';
            data.track1 = iWave;
            data.track2 = qWave;
            data.trackTitle = 'I/Q 基带轨迹';
            data.trackLabel = '幅度';
            data.referencePoints = [real(constellation(:)) imag(constellation(:))];
            data.usedPoints = [real(symbolPoints(:)) imag(symbolPoints(:))];
            data.mappingTitle = sprintf('%s 星座图', modDef.name);
            data.mappingXLabel = '同相 I';
            data.mappingYLabel = '正交 Q';
            data.isOneDimensionalMapping = false;

        otherwise
            error('Unsupported modulation family: %s', modDef.family);
    end

    % 对当前帧做统一归一化，使不同调制方式的平均符号能量都满足 Es = 1。
    data = normalizeAverageSymbolEnergy(data, data.targetSymbolEnergy);
end

function analysis = computeHighOrderCumulants(signal)
% COMPUTEHIGHORDERCUMULANTS 计算接收信号的混合矩和高阶累积量。
% 输入参数：
%   signal   - 当前接收信号序列，可为原始信号或加噪信号。
% 输出参数：
%   analysis - 包含中心化均值、混合矩及二/四/六阶累积量的结构体。

    signal = signal(:);
    signalMean = mean(signal);
    centeredSignal = signal - signalMean;

    moments = struct();
    moments.M20 = computeMixedMoment(centeredSignal, 2, 0);
    moments.M21 = computeMixedMoment(centeredSignal, 2, 1);
    moments.M40 = computeMixedMoment(centeredSignal, 4, 0);
    moments.M41 = computeMixedMoment(centeredSignal, 4, 1);
    moments.M42 = computeMixedMoment(centeredSignal, 4, 2);
    moments.M60 = computeMixedMoment(centeredSignal, 6, 0);
    moments.M61 = computeMixedMoment(centeredSignal, 6, 1);
    moments.M63 = computeMixedMoment(centeredSignal, 6, 3);

    cumulants = struct();
    cumulants.C20 = moments.M20;
    cumulants.C21 = moments.M21;
    cumulants.C40 = moments.M40 - 3 * moments.M20 ^ 2;
    cumulants.C41 = moments.M41 - 3 * moments.M20 * moments.M21;
    cumulants.C42 = moments.M42 - moments.M20 ^ 2 - 2 * moments.M21 ^ 2;
    cumulants.C60 = moments.M60 - 15 * moments.M40 * moments.M20 + 30 * moments.M20 ^ 3;
    cumulants.C61 = moments.M61 - 5 * moments.M40 * moments.M21 ...
        - 10 * moments.M20 * moments.M41 + 30 * moments.M21 * moments.M20 ^ 2;
    cumulants.C63 = moments.M63 - 6 * moments.M41 * moments.M20 ...
        - 9 * moments.M21 * moments.M42 + 18 * moments.M21 * moments.M20 ^ 2 ...
        + 12 * moments.M21 ^ 3;

    analysis = struct();
    analysis.sampleCount = numel(centeredSignal);
    analysis.originalMean = signalMean;
    analysis.mixedMoments = moments;
    analysis.cumulants = cumulants;
end

function data = normalizeAverageSymbolEnergy(data, targetSymbolEnergy)
% NORMALIZEAVERAGESYMBOLENERGY 将当前帧的平均符号能量归一化到目标值。
% 输入参数：
%   data               - 当前调制结果结构体，至少包含 signal 和 featureSignal。
%   targetSymbolEnergy - 目标平均符号能量，当前统一设为 1。
% 输出参数：
%   data               - 已完成能量归一化的调制结果结构体。

    currentSymbolEnergy = mean(abs(data.featureSignal(:)) .^ 2);
    if currentSymbolEnergy < 1e-12
        error('Current symbol energy is too small to normalize.');
    end

    scale = sqrt(targetSymbolEnergy / currentSymbolEnergy);

    data.signal = data.signal * scale;
    data.featureSignal = data.featureSignal * scale;
    data.track1 = data.track1 * scale;
    if ~isempty(data.track2)
        data.track2 = data.track2 * scale;
    end
    data.referencePoints = data.referencePoints * scale;
    data.usedPoints = data.usedPoints * scale;
    data.averageSymbolEnergy = mean(abs(data.featureSignal(:)) .^ 2);
    data.symbolEnergyScale = scale;
end

function features = computeFeatureValues(cumulants, featureSignal, sampleRate)
% COMPUTEFEATUREVALUES 根据累积量、包络和瞬时频率计算特征参数。
% 输入参数：
%   cumulants     - 累积量结构体，至少包含 C21、C40、C41、C42、C60、C63。
%   featureSignal - 用于包络和瞬时频率特征提取的复基带接收信号。
%   sampleRate    - 复基带信号采样率。
% 输出参数：
%   features      - 特征参数结构体，包含 Fe1 到 Fe5、Fa 和 Ff。

    features = struct();
    features.Fe1 = safeFeatureDivide(abs(cumulants.C41), abs(cumulants.C42));
    features.Fe2 = safeFeatureDivide(abs(cumulants.C60) ^ 2, abs(cumulants.C40) ^ 3);
    features.Fe3 = safeFeatureDivide(abs(cumulants.C40), abs(cumulants.C42));
    features.Fe4 = safeFeatureDivide(abs(cumulants.C63) ^ 2, abs(cumulants.C42) ^ 3);
    features.Fe5 = safeFeatureDivide(abs(cumulants.C42), abs(cumulants.C21) ^ 2);

    envelopeStats = computeEnvelopeStatistics(featureSignal);
    features.Fa = envelopeStats.normalizedVariance;
    features.envelopeMean = envelopeStats.mean;
    features.envelopeVariance = envelopeStats.variance;

    frequencyStats = computeInstantaneousFrequencyStatistics(featureSignal, sampleRate);
    features.Ff = frequencyStats.normalizedVariance;
    features.instantFrequencyMean = frequencyStats.mean;
    features.instantFrequencyVariance = frequencyStats.variance;
end

function envelopeStats = computeEnvelopeStatistics(featureSignal)
% COMPUTEENVELOPESTATISTICS 计算复基带信号的包络统计量。
% 输入参数：
%   featureSignal - 复基带接收信号。
% 输出参数：
%   envelopeStats - 包含包络均值、包络方差和归一化包络方差的结构体。

    envelope = abs(featureSignal(:));
    envelopeMean = mean(envelope);
    envelopeVariance = mean((envelope - envelopeMean) .^ 2);

    envelopeStats = struct();
    envelopeStats.mean = envelopeMean;
    envelopeStats.variance = envelopeVariance;
    envelopeStats.normalizedVariance = safeFeatureDivide( ...
        envelopeVariance, envelopeMean ^ 2);
end

function frequencyStats = computeInstantaneousFrequencyStatistics(featureSignal, sampleRate)
% COMPUTEINSTANTANEOUSFREQUENCYSTATISTICS 计算复基带信号的瞬时频率统计量。
% 输入参数：
%   featureSignal - 复基带接收信号。
%   sampleRate    - 信号采样率，单位 Hz。
% 输出参数：
%   frequencyStats - 包含瞬时频率均值、方差和归一化方差的结构体。

    phase = unwrap(angle(featureSignal(:)));
    instantFrequency = sampleRate * diff(phase) / (2 * pi);
    if isempty(instantFrequency)
        instantFrequency = 0;
    end
    frequencyMean = mean(instantFrequency);
    frequencyVariance = mean((instantFrequency - frequencyMean) .^ 2);

    frequencyStats = struct();
    frequencyStats.mean = frequencyMean;
    frequencyStats.variance = frequencyVariance;
    frequencyStats.normalizedVariance = safeFeatureDivide( ...
        frequencyVariance, sampleRate ^ 2);
end

function value = safeFeatureDivide(numerator, denominator)
% SAFEFEATUREDIVIDE 对特征参数计算中的除法做零分母保护。
% 输入参数：
%   numerator   - 分子。
%   denominator - 分母。
% 输出参数：
%   value       - 当分母过小时返回 NaN，否则返回正常比值。

    if denominator < 1e-12
        value = NaN;
        return;
    end

    value = numerator / denominator;
end

function result = classifyModulation(fv)
% CLASSIFYMODULATION 基于特征参数决策树识别调制方式。
% 输入：fv - featureValues 结构体 (Fe1, Fe3, Fe4, Fe5)
% 输出：result - 含 name (识别名称) 和 path (决策路径) 的结构体

    featNames = {'Fe1', 'Fe3', 'Fe4', 'Fe5'};
    for k = 1:numel(featNames)
        if isnan(fv.(featNames{k}))
            result.name = '无法识别';
            result.path = '特征值异常（NaN）';
            return;
        end
    end

    if fv.Fe1 > 0.6
        if fv.Fe4 > 30
            if fv.Fe5 < 1.7
                result.name = '2ASK';
                result.path = 'Fe1>0.6→Fe4>30→Fe5<1.7';
            else
                result.name = '2PSK';
                result.path = 'Fe1>0.6→Fe4>30→Fe5>1.7';
            end
        else
            if fv.Fe5 < 0.9
                result.name = '8ASK';
                result.path = 'Fe1>0.6→Fe4<30→Fe5<0.9';
            else
                result.name = '4ASK';
                result.path = 'Fe1>0.6→Fe4<30→Fe5>0.9';
            end
        end
    else
        if fv.Fe3 > 0.6
            if fv.Fe4 > 15
                result.name = '4PSK';
                result.path = 'Fe1<0.6→Fe3>0.6→Fe4>15';
            else
                if fv.Fe5 < 0.57
                    result.name = '64QAM';
                    result.path = 'Fe1<0.6→Fe3>0.6→Fe4<15→Fe5<0.57';
                else
                    result.name = '16QAM';
                    result.path = 'Fe1<0.6→Fe3>0.6→Fe4<15→Fe5>0.57';
                end
            end
        else
            if fv.Fe5 > 0.75
                result.name = '2FSK';
                result.path = 'Fe1<0.6→Fe3<0.6→Fe5>0.75';
            else
                if fv.Fe5 < 0.88
                    result.name = '4FSK';
                    result.path = 'Fe1<0.6→Fe3<0.6→Fe5<0.75→Fe5<0.88';
                else
                    result.name = '8PSK';
                    result.path = 'Fe1<0.6→Fe3<0.6→Fe5<0.75→Fe5>0.88';
                end
            end
        end
    end
end

function identifyModulation(mainFig)
% IDENTIFYMODULATION 识别按钮回调，执行调制识别并更新界面。

    state = guidata(mainFig);
    if isempty(state.current)
        updateStatus(mainFig, '状态：请先生成一种调制信号，再点击识别。');
        return;
    end

    data = state.current;
    fv = data.featureValues;
    result = classifyModulation(fv);

    actualName = data.name;
    identifiedName = result.name;
    isMatch = strcmp(identifiedName, actualName);

    noiseLabel = getNoiseLabel(data);

    set(state.handles.identifyObjectText, ...
        'String', sprintf('识别对象：%s（%s）', actualName, noiseLabel));

    if isMatch
        set(state.handles.identifyResultText, ...
            'String', sprintf('识别结果：正确 - 识别为 %s', identifiedName), ...
            'ForegroundColor', state.colors.signal);
    else
        set(state.handles.identifyResultText, ...
            'String', sprintf('识别结果：错误 - 实际 %s，误识别为 %s', actualName, identifiedName), ...
            'ForegroundColor', state.colors.secondary);
    end

    state.recognition = struct( ...
        'identifiedName', identifiedName, ...
        'actualName', actualName, ...
        'isMatch', isMatch, ...
        'path', result.path, ...
        'hasNoise', data.hasNoise);
    guidata(mainFig, state);

    if isMatch
        updateStatus(mainFig, sprintf('状态：调制识别完成 - 正确识别为 %s（决策路径：%s）', ...
            identifiedName, result.path));
    else
        updateStatus(mainFig, sprintf('状态：调制识别完成 - 识别错误！实际 %s，误识别为 %s', ...
            actualName, identifiedName));
    end
end

function label = getNoiseLabel(data)
% GETNOISELABEL 返回当前信号的加噪状态标签。

    if data.hasNoise
        label = sprintf('已加噪 %.0fdB', data.noiseSnrDb);
    else
        label = '未加噪';
    end
end

function momentValue = computeMixedMoment(signal, p, q)
% COMPUTEMIXEDMOMENT 计算 p 阶 q 共轭形式下的混合矩。
% 输入参数：
%   signal - 中心化后的接收信号。
%   p      - 总阶数。
%   q      - 共轭项个数。
% 输出参数：
%   momentValue - 对应的混合矩数值。

    momentValue = mean((signal .^ (p - q)) .* (conj(signal) .^ q));
end

function symbolIndices = generateUniformSymbolSequence(M, numSymbols)
% GENERATEUNIFORMSYMBOLSEQUENCE 生成固定且均匀分布的符号索引序列。
% 输入参数：
%   M          - 调制阶数。
%   numSymbols - 需要生成的符号总数，要求能被 M 整除。
% 输出参数：
%   symbolIndices - 每个符号出现次数完全相同的固定符号序列。

    if mod(numSymbols, M) ~= 0
        error('Uniform symbol generation requires numSymbols to be divisible by M.');
    end

    repeatsPerSymbol = numSymbols / M;
    groupedSymbols = repelem(0:(M - 1), repeatsPerSymbol);

    % 使用与 256 互素的固定步长做确定性重排，避免符号长块连续出现。
    permutationStep = 29;
    permutationIndices = mod((0:(numSymbols - 1)) * permutationStep, numSymbols) + 1;
    symbolIndices = groupedSymbols(permutationIndices);
end

function bits = symbolIndicesToBits(symbolIndices, bitsPerSymbol)
% SYMBOLINDICESTOBITS 将十进制符号索引转换为按高位在前排列的比特流。
% 输入参数：
%   symbolIndices  - 十进制符号索引序列。
%   bitsPerSymbol  - 每个符号对应的比特数。
% 输出参数：
%   bits           - 与符号索引一一对应的比特流。

    symbolIndices = symbolIndices(:);
    weights = 2 .^ (bitsPerSymbol - 1:-1:0);
    bitMatrix = zeros(numel(symbolIndices), bitsPerSymbol);
    for idx = 1:bitsPerSymbol
        bitMatrix(:, idx) = bitand(symbolIndices, weights(idx)) > 0;
    end
    bits = reshape(bitMatrix.', 1, []);
end

function symbolIndices = bitsToSymbolIndices(bits, bitsPerSymbol)
% BITSTOSYMBOLINDICES 将二进制比特流转换为十进制符号索引。
% 输入参数：
%   bits          - 原始比特序列。
%   bitsPerSymbol - 每个符号对应的比特数。
% 输出参数：
%   symbolIndices - 按高位在前规则得到的符号编号序列。

    % 按“高位在前”的分组方式把比特流转成十进制符号索引。
    bitMatrix = reshape(bits, bitsPerSymbol, []).';
    weights = 2 .^ (bitsPerSymbol - 1:-1:0);
    symbolIndices = (bitMatrix * weights.').';
end

function noisySignal = addGaussianNoise(signal, snrDb)
% ADDGAUSSIANNOISE 按给定信噪比向信号中加入高斯白噪声。
% 输入参数：
%   signal - 原始时域信号。
%   snrDb  - 目标信噪比，单位为 dB。
% 输出参数：
%   noisySignal - 叠加高斯白噪声后的输出信号。

    % 根据信号功率和目标 SNR 反推噪声功率，再叠加高斯白噪声。
    signalPower = mean(abs(signal) .^ 2);
    noisePower = signalPower / (10 ^ (snrDb / 10));

    if ~isreal(signal)
        noise = sqrt(noisePower / 2) * ...
            (randn(size(signal)) + 1i * randn(size(signal)));
    else
        noise = sqrt(noisePower) * randn(size(signal));
    end

    noisySignal = signal + noise;
end

function exportSignalToWorkspace(data)
% EXPORTSIGNALTOWORKSPACE 将当前演示结果写入 MATLAB 工作区。
% 输入参数：
%   data - 当前调制结果结构体。
% 输出参数：
%   无。函数导出通用变量以及带调制名称前缀的变量。

    % 同时导出通用变量和按调制方式命名的变量，方便课程演示和后续分析。
    result = struct();
    result.modulation = data.name;
    result.family = data.family;
    result.bits = data.bits;
    result.symbolIndices = data.symbolIndices;
    result.time = data.time;
    result.signal = data.signal;
    result.featureSignal = data.featureSignal;
    result.sampleRate = data.sampleRate;
    result.targetSymbolEnergy = data.targetSymbolEnergy;
    result.averageSymbolEnergy = data.averageSymbolEnergy;
    result.symbolEnergyScale = data.symbolEnergyScale;
    result.hasNoise = data.hasNoise;
    result.noisySignal = data.noisySignal;
    result.noisyFeatureSignal = data.noisyFeatureSignal;
    result.noiseSnrDb = data.noiseSnrDb;
    result.receivedSignalName = data.receivedSignalName;
    result.cumulantAnalysis = data.cumulantAnalysis;
    result.featureValues = data.featureValues;

    assignin('base', 'demo_result', result);
    assignin('base', 'demo_modulation', data.name);
    assignin('base', 'demo_bits', data.bits);
    assignin('base', 'demo_symbol_indices', data.symbolIndices);
    assignin('base', 'demo_time', data.time);
    assignin('base', 'demo_signal', data.signal);
    assignin('base', 'demo_feature_signal', data.featureSignal);
    assignin('base', 'demo_sample_rate', data.sampleRate);
    assignin('base', 'demo_target_symbol_energy', data.targetSymbolEnergy);
    assignin('base', 'demo_average_symbol_energy', data.averageSymbolEnergy);
    assignin('base', 'demo_symbol_energy_scale', data.symbolEnergyScale);
    assignin('base', 'demo_has_noise', data.hasNoise);
    assignin('base', 'demo_noisy_signal', data.noisySignal);
    assignin('base', 'demo_noisy_feature_signal', data.noisyFeatureSignal);
    assignin('base', 'demo_noise_snr_db', data.noiseSnrDb);
    assignin('base', 'demo_received_signal_name', data.receivedSignalName);
    assignin('base', 'demo_cumulant_analysis', data.cumulantAnalysis);
    assignin('base', 'demo_mixed_moments', data.cumulantAnalysis.mixedMoments);
    assignin('base', 'demo_cumulants', data.cumulantAnalysis.cumulants);
    assignin('base', 'demo_feature_values', data.featureValues);

    prefix = ['demo_' lower(data.name)];
    assignin('base', [prefix '_result'], result);
    assignin('base', [prefix '_bits'], data.bits);
    assignin('base', [prefix '_time'], data.time);
    assignin('base', [prefix '_signal'], data.signal);
    assignin('base', [prefix '_feature_signal'], data.featureSignal);
    assignin('base', [prefix '_target_symbol_energy'], data.targetSymbolEnergy);
    assignin('base', [prefix '_average_symbol_energy'], data.averageSymbolEnergy);
    assignin('base', [prefix '_symbol_energy_scale'], data.symbolEnergyScale);
    assignin('base', [prefix '_noisy_signal'], data.noisySignal);
    assignin('base', [prefix '_noisy_feature_signal'], data.noisyFeatureSignal);
    assignin('base', [prefix '_cumulants'], data.cumulantAnalysis.cumulants);
    assignin('base', [prefix '_features'], data.featureValues);
end

function showWelcomePlots(axesHandles, colors)
% SHOWWELCOMEPLOTS 在两个坐标轴中显示界面启动时的提示信息。
% 输入参数：
%   axesHandles - 两个显示坐标轴的句柄集合。
%   colors      - 界面颜色配置结构体。
% 输出参数：
%   无。函数用于界面初始化和空状态提示。

    showPlaceholder(axesHandles.track, '请选择左侧任一调制按钮', colors);
    showPlaceholder(axesHandles.signal, '生成后将在这里显示时域波形', colors);
end

function showPlaceholder(axHandle, message, colors)
% SHOWPLACEHOLDER 在指定坐标轴中绘制提示文字占位图。
% 输入参数：
%   axHandle - 目标坐标轴句柄。
%   message  - 居中显示的提示文字。
%   colors   - 界面颜色配置结构体。
% 输出参数：
%   无。函数主要用于未生成信号时的界面提示。

    cla(axHandle);
    axis(axHandle, [0 1 0 1]);
    axis(axHandle, 'off');
    set(axHandle, 'Visible', 'off');
    text(axHandle, 0.5, 0.5, message, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'Color', colors.title);
end

function updateStatus(mainFig, message)
% UPDATESTATUS 更新左侧状态栏中的文字说明。
% 输入参数：
%   mainFig  - 主界面句柄。
%   message  - 需要显示的状态文本。
% 输出参数：
%   无。函数只负责更新状态标签内容。

    state = guidata(mainFig);
    set(state.handles.statusText, 'String', message);
end

function lines = buildInfoLines(data)
% BUILDINFOLINES 构造左侧信息框中显示的文本内容。
% 输入参数：
%   data - 当前调制结果结构体。
% 输出参数：
%   lines - 单元格字符串数组，用于展示当前参数与结果摘要。

    if data.hasNoise
        noiseText = sprintf('已添加高斯白噪声：是（SNR = %.0f dB）', data.noiseSnrDb);
    else
        noiseText = '已添加高斯白噪声：否';
    end

    lines = { ...
        sprintf('当前调制方式：%s', data.name), ...
        sprintf('每符号比特数：%d', data.bitsPerSymbol), ...
        sprintf('符号数：%d，总比特数：%d', data.numSymbols, numel(data.bits)), ...
        sprintf('载波频率：%.0f Hz', data.carrierFreq), ...
        sprintf('采样率：%.0f Hz', data.sampleRate), ...
        sprintf('目标平均符号能量 Es：%s', formatFeatureValue(data.targetSymbolEnergy)), ...
        sprintf('当前平均符号能量 Es：%s', formatFeatureValue(data.averageSymbolEnergy)), ...
        sprintf('能量归一化系数：%s', formatFeatureValue(data.symbolEnergyScale)), ...
        '特征提取对象：复基带接收信号', ...
        noiseText, ...
        sprintf('特征参数：Fe1=%s，Fe2=%s', ...
            formatFeatureValue(data.featureValues.Fe1), formatFeatureValue(data.featureValues.Fe2)), ...
        sprintf('Fe3=%s，Fe4=%s，Fe5=%s', ...
            formatFeatureValue(data.featureValues.Fe3), formatFeatureValue(data.featureValues.Fe4), ...
            formatFeatureValue(data.featureValues.Fe5)), ...
        sprintf('Fa=%s，Ff=%s', ...
            formatFeatureValue(data.featureValues.Fa), formatFeatureValue(data.featureValues.Ff)), ...
        sprintf('固定比特序列：%s', formatSequence(data.bits, 40)), ...
        sprintf('固定均匀符号索引序列：%s', formatSequence(data.symbolIndices, 22)), ...
        '工作区变量：demo_result、demo_feature_signal、demo_cumulants、demo_feature_values 等'};
end

function textOut = formatSequence(values, maxCount)
% FORMATSEQUENCE 将较长序列整理为适合界面显示的短文本。
% 输入参数：
%   values   - 待显示的数值序列。
%   maxCount - 允许显示的最大元素个数。
% 输出参数：
%   textOut  - 截断并格式化后的字符串。

    values = values(:).';
    shownValues = values(1:min(numel(values), maxCount));
    textOut = num2str(shownValues);
    textOut = strtrim(textOut);
    if numel(values) > maxCount
        textOut = [textOut ' ...'];
    end
end

function lines = getWelcomeInfo()
% GETWELCOMEINFO 返回程序启动时的信息框说明文字。
% 输入参数：
%   无。
% 输出参数：
%   lines - 启动说明文本单元格数组。

    lines = { ...
        '使用说明：', ...
        '1. 点击左侧任一调制按钮生成固定均匀符号序列信号。', ...
        '2. 右侧将显示基带轨迹和时域波形。', ...
        '3. 累积量与特征参数改为基于复基带接收信号计算。', ...
        '4. 右下左半区显示二阶、四阶和六阶累积量结果。', ...
        '5. 右下右半区显示 Fe1、Fe2、Fe3、Fe4、Fe5、Fa 和 Ff。', ...
        '6. 点击“加入高斯白噪声（12 dB）”可对当前信号加噪。', ...
        '7. 生成结果会自动写入 MATLAB 工作区。', ...
        '支持的调制方式：', ...
        '2FSK、4FSK、2ASK、4ASK、8ASK、2PSK、4PSK、8PSK、64QAM、16QAM'}; 
end

function lines = getCumulantPlaceholderText()
% GETCUMULANTPLACEHOLDERTEXT 返回累积量结果区的默认提示文字。
% 输入参数：
%   无。
% 输出参数：
%   lines - 多行提示文本单元格数组。

    lines = { ...
        '高阶累积量结果', ...
        '等待接收信号输入', ...
        '处理流程：', ...
        '1. 信号中心化', ...
        '2. 计算混合矩', ...
        '3. 计算 C20、C21', ...
        '4. 计算 C40、C41、C42', ...
        '5. 计算 C60、C61、C63'};
end

function lines = getFeaturePlaceholderText()
% GETFEATUREPLACEHOLDERTEXT 返回特征参数区的默认提示文字。
% 输入参数：
%   无。
% 输出参数：
%   lines - 多行提示文本单元格数组。

    lines = { ...
        '特征参数结果', ...
        '等待累积量输入', ...
        '计算公式：', ...
        'Fe1 = |C41| / |C42|', ...
        'Fe2 = |C60|^2 / |C40|^3', ...
        'Fe3 = |C40| / |C42|', ...
        'Fe4 = |C63|^2 / |C42|^3', ...
        'Fe5 = |C42| / |C21|^2', ...
        'Fa = sigma_A^2 / mean(A)^2', ...
        'Ff = sigma_f^2 / Fs^2'};
end

function lines = buildCumulantLines(data)
% BUILDCUMULANTLINES 构造右下左半区的累积量结果文本。
% 输入参数：
%   data - 当前调制结果结构体。
% 输出参数：
%   lines - 用于界面显示的多行文本单元格数组。

    analysis = data.cumulantAnalysis;
    cumulants = analysis.cumulants;

    lines = { ...
        '高阶累积量结果', ...
        ['对象：' data.receivedSignalName], ...
        ['中心化均值：' formatComplexValue(analysis.originalMean)], ...
        ['样本数：' num2str(analysis.sampleCount)], ...
        '二阶：', ...
        ['C20 = ' formatComplexValue(cumulants.C20)], ...
        ['C21 = ' formatComplexValue(cumulants.C21)], ...
        '四阶：', ...
        ['C40 = ' formatComplexValue(cumulants.C40)], ...
        ['C41 = ' formatComplexValue(cumulants.C41)], ...
        ['C42 = ' formatComplexValue(cumulants.C42)], ...
        '六阶：', ...
        ['C60 = ' formatComplexValue(cumulants.C60)], ...
        ['C61 = ' formatComplexValue(cumulants.C61)], ...
        ['C63 = ' formatComplexValue(cumulants.C63)]};
end

function lines = buildFeatureLines(data)
% BUILDFEATURELINES 构造右下右半区的特征参数结果文本。
% 输入参数：
%   data - 当前调制结果结构体。
% 输出参数：
%   lines - 用于界面显示的多行文本单元格数组。

    features = data.featureValues;

    lines = { ...
        '特征参数结果', ...
        ['对象：' data.receivedSignalName], ...
        ['Fe1 = ' formatFeatureValue(features.Fe1)], ...
        ['Fe2 = ' formatFeatureValue(features.Fe2)], ...
        ['Fe3 = ' formatFeatureValue(features.Fe3)], ...
        ['Fe4 = ' formatFeatureValue(features.Fe4)], ...
        ['Fe5 = ' formatFeatureValue(features.Fe5)], ...
        ['Fa = ' formatFeatureValue(features.Fa)], ...
        ['Ff = ' formatFeatureValue(features.Ff)], ...
        '说明：', ...
        'Fe1 = |C41| / |C42|', ...
        'Fe2 = |C60|^2 / |C40|^3', ...
        'Fe3 = |C40| / |C42|', ...
        'Fe4 = |C63|^2 / |C42|^3', ...
        'Fe5 = |C42| / |C21|^2', ...
        'Fa = sigma_A^2 / mean(A)^2', ...
        'Ff = sigma_f^2 / Fs^2'};
end

function colors = getUiColors()
% GETUICOLORS 定义界面所用的统一配色方案。
% 输入参数：
%   无。
% 输出参数：
%   colors - 包含窗口、按钮、曲线等颜色设置的结构体。

    colors = struct();
    colors.figure = [0.95 0.97 0.99];
    colors.panel = [0.98 0.99 1.00];
    colors.title = [0.07 0.24 0.45];
    colors.text = [0.18 0.22 0.28];
    colors.mutedText = [0.45 0.52 0.60];
    colors.primary = [0.00 0.45 0.74];
    colors.secondary = [0.85 0.33 0.10];
    colors.signal = [0.10 0.55 0.28];
    colors.edge = [0.82 0.86 0.90];
end

function textOut = formatComplexValue(value)
% FORMATCOMPLEXVALUE 将实数或复数格式化为便于显示的短字符串。
% 输入参数：
%   value - 待格式化的标量数值。
% 输出参数：
%   textOut - 适合界面显示的字符串。

    if abs(imag(value)) < 1e-10
        textOut = sprintf('%.4e', real(value));
        return;
    end

    textOut = sprintf('%.4e%+.4ei', real(value), imag(value));
end

function textOut = formatFeatureValue(value)
% FORMATFEATUREVALUE 将特征参数格式化为便于显示的短字符串。
% 输入参数：
%   value - 待显示的特征参数数值。
% 输出参数：
%   textOut - 适合界面展示的字符串。

    if isnan(value)
        textOut = 'NaN（分母过小）';
        return;
    end

    textOut = sprintf('%.4e', value);
end

function modulations = getModulationDefinitions()
% GETMODULATIONDEFINITIONS 返回界面支持的全部调制配置。
% 输入参数：
%   无。
% 输出参数：
%   modulations - 调制定义结构体数组，含名称、家族和阶数。

    modulations = [ ...
        struct('name', '2FSK', 'family', 'FSK', 'M', 2), ...
        struct('name', '4FSK', 'family', 'FSK', 'M', 4), ...
        struct('name', '2ASK', 'family', 'ASK', 'M', 2), ...
        struct('name', '4ASK', 'family', 'ASK', 'M', 4), ...
        struct('name', '8ASK', 'family', 'ASK', 'M', 8), ...
        struct('name', '2PSK', 'family', 'PSK', 'M', 2), ...
        struct('name', '4PSK', 'family', 'PSK', 'M', 4), ...
        struct('name', '8PSK', 'family', 'PSK', 'M', 8), ...
        struct('name', '64QAM', 'family', 'QAM', 'M', 64), ...
        struct('name', '16QAM', 'family', 'QAM', 'M', 16)];
end

function constellation = getQamConstellation(M)
% GETQAMCONSTELLATION 生成指定阶数 QAM 的归一化星座点。
% 输入参数：
%   M - QAM 调制阶数，目前支持 16 和 64。
% 输出参数：
%   constellation - 归一化后的复数星座点序列。

    switch M
        case 16
            % 16QAM 采用标准 4x4 星座点阵。
            levels = [-3 -1 1 3];
            [iGrid, qGrid] = meshgrid(levels, levels);
            constellation = iGrid(:).' + 1i * qGrid(:).';
        case 64
            % 64QAM 采用标准 8x8 星座点阵。
            levels = [-7 -5 -3 -1 1 3 5 7];
            [iGrid, qGrid] = meshgrid(levels, levels);
            constellation = iGrid(:).' + 1i * qGrid(:).';
        otherwise
            error('Unsupported QAM order: %d', M);
    end

    constellation = constellation ./ sqrt(mean(abs(constellation) .^ 2));
end
