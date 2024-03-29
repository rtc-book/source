clear;close all

% This script contains test data and calculations for the linearity
% tests of the Pololu 18v17 PWM amplifier.

%% Resistor measurements

r.R1.R = 3.21;     % measured resistance
r.R1.P = 100;   % W ... power rating
r.R2.R = 3.21;     % measured resistance
r.R2.P = 100;   % W ... power rating
r.R3.R = 8.27;     % measured resistance
r.R3.P = 100;   % W ... power rating
r.R4.R = 8.18;     % measured resistance
r.R4.P = 100;   % W ... power rating
r.R5.R = 25.20;    % measured resistance
r.R5.P = 50;    % W ... power rating
r.R6.R = 24.78;    % measured resistance
r.R6.P = 50;    % W ... power rating
r.R7.R = 8.29;    % measured resistance
r.R7.P = 25;     % W ... power rating
r.R8.R = 8.25;    % measured resistance
r.R8.P = 25;     % W ... power rating
r.R9.R = 6.26;    % measured resistance
r.R9.P = 25;     % W ... power rating
r.R10.R = 6.28;   % measured resistance
r.R10.P = 25;    % W ... power rating
r.R11.R = 991.7;    % Ohms
r.R11.P = 0;        % low power
r.R12.R = 38.747e3;    % Ohms
r.R12.P = 0;        % low power
r.R13.R = 14.890e3;    % Ohms
r.R13.P = 0;        % low power

%% Run definitions

run.r1.datafile = 'pololu-linearity-test-r1.mat';
run.r1.RS = r.R3;
run.r1.RL = r.R1;
run.r1.vdivided = true;
run.r1.R_upper = r.R12.R;
run.r1.R_lower = r.R13.R;

run.r2.datafile = 'pololu-linearity-test-r2.mat';
run.r2.RS = r.R3;
run.r2.RL = r.R1;
run.r2.vdivided = true;
run.r2.R_upper = r.R12.R;
run.r2.R_lower = r.R13.R;

%% Run computations and load data

fn = fieldnames(run);
for k=1:numel(fn)
    run.(fn{k}) = undivide(run.(fn{k}));            % compute gain for data
    run.(fn{k}).data = load(run.(fn{k}).datafile);  % load data into struct
    run.(fn{k}) = unbias(run.(fn{k}));              % compute unbiased data
    run.(fn{k}) = level_means(run.(fn{k}));         % compute level means
    run.(fn{k}) = levels(run.(fn{k}));              % extract level voltages
    run.(fn{k}) = total_resistance(run.(fn{k}));    % compute total resistance
    run.(fn{k}) = signify(run.(fn{k}));             % extract sign
end


%% Plot

% - raw voltage
figure;
for k=1:numel(fn)
    run_k = run.(fn{k});
    label = sprintf("R = %f",run_k.total_resistance);
    plot(run_k.data.t,run_k.gain*run_k.data.voltage_meas,...
        'displayname',label);hold on
end
hold off
grid on;
xlabel('time (s)')
ylabel('measured voltage (V)')
legend('location','southeast');
saveas(gcf,'raw-data.svg');

% - voltage means for each level
figure;
used_resistances = [];
ax = gca;
for k=1:numel(fn)
    run_k = run.(fn{k});
    label = sprintf("R = %f",run_k.total_resistance);
    plot(run_k.levels,run_k.levels,...
        'k','HandleVisibility','off');hold on
    if any(ismember(run_k.total_resistance,used_resistances))
        label = '';
        vis = 'off';
    else
        label = sprintf("R = %f",run_k.total_resistance);
        vis = 'on';
        used_resistances(end+1) = run_k.total_resistance;
    end
    ax.ColorOrderIndex = ax.ColorOrderIndex - 1;
    plot(run_k.levels,run_k.sign*run_k.gain*run_k.level_means,...
        'o','displayname',label,'handlevisibility',vis);hold on
end
hold off
grid on;
xlabel('nominal voltage (V)')
ylabel('measured voltage (V)')
legend('location','southeast');
saveas(gcf,'voltage-means.svg');

% - current
figure;
ax = gca;
used_resistances = [];
for k=1:numel(fn)
    run_k = run.(fn{k});
    plot(run_k.levels,run_k.levels/run_k.total_resistance,...
        'k','HandleVisibility','off');hold on
    if any(ismember(run_k.total_resistance,used_resistances))
        label = '';
        vis = 'off';
        disp('ismember')
    else
        label = sprintf("R = %f",run_k.total_resistance);
        vis = 'on';
        used_resistances(end+1) = run_k.total_resistance;
        disp('isnotmember')
    end
    ax.ColorOrderIndex = ax.ColorOrderIndex - 1;
    plot(run_k.levels,run_k.sign*run_k.gain*run_k.level_means/run_k.total_resistance,...
        'o','displayname',label,'HandleVisibility',vis);hold on
end
hold off
grid on;
xlabel('nominal voltage (V)')
ylabel('inferred current (A)')
legend('location','southeast');
saveas(gcf,'current-means.svg');

%% Define functions

function gain = V_undivide(R_upper,R_lower)
    % V_UNDIVIDE estimates the load voltage gain from a voltage divider
    % R_upper is the high-side resistor
    % R_lower is the low-side resistor across which v_meas was measured
    gain = (R_lower+R_upper)/R_lower; % from the voltage divider
end

function gain = P_undivide(RS,RL)
    % P_UNDIVIDE estimates the source voltage gain from a load voltage
    gain = (RL+RS)/RL; % from the voltage divider, DC component
end

function run_w_gain = undivide(run)
    % UNDIVIDE estimates the total undivide gain for the run
    % returns run now with key/value pair for gain
    if run.vdivided
        gain = P_undivide(run.RS.R,run.RL.R)*V_undivide(run.R_upper,run.R_lower);
    else
        gain = P_undivide(run.RS.R,run.RL.R);
    end
    run.gain = gain;
    run_w_gain = run;
end

function run_w_sign = signify(run)
    if isfield(run.data,'Vmax') % to account for old runs missing Vmax (all were positive)
        if run.data.Vmax < 0
            run.sign = 1;
        else
            run.sign = -1;
        end
    else
        run.sign = 1;
    end
    run_w_sign = run;
end

function run_unbiased = unbias(run)
    % UNBIAS Removes the bias voltage offset in the voltage_meas data
    % Based on a multimeter measurement, the Pololu outputs only 0.1 mV
    % when the PWM duty cycle is zero. Therefore, there's a bias in the
    % measurements, which we estimate to be the measured voltage at zero
    % duty cycle. This function removes that bias from all measured data
    % points.
    i_v0 = run.data.voltage_out == 0;
    bias = run.data.voltage_meas(i_v0); % all 0 volts
    bias = bias(1); % should all be equal, so take the first one.
    run.data.voltage_meas_unbiased = run.data.voltage_meas - bias;
    run.data.voltage_meas_unbiased = run.data.voltage_meas_unbiased + 0.1e-3/run.gain; % add measured actual offset
    run_unbiased = run;
end

function run_w_level_means = level_means(run)
    levels = run.data.levels;
    samples_per_level = run.data.samples_per_level;
    l_means = zeros(levels,1);
    for i = 1:levels
        j_lo = (i-1)*samples_per_level + 1;
        j_hi = j_lo+samples_per_level - 1;
        level_data = run.data.voltage_meas_unbiased(j_lo:j_hi);
        l_means(i) = mean(level_data);
    end
    run.level_means = l_means;
    run_w_level_means = run;
end

function run_w_levels = levels(run)
    nlevels = run.data.levels;
    samples_per_level = run.data.samples_per_level;
    level_voltage = zeros(nlevels,1);
    for i = 1:nlevels
        j_lo = (i-1)*samples_per_level + 1;
        level_voltage(i) = run.data.voltage_out(j_lo);
    end
    run.levels = level_voltage;
    run_w_levels = run;
end

function run_w_resistance = total_resistance(run)
    run.total_resistance = run.RS.R + run.RL.R;
    run_w_resistance = run;
end