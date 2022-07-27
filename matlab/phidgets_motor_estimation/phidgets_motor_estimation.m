clear;close all

% This script contains test data and calculations for the Phidgets motor
% step responses for estimating the motor J and L.

%% Run definitions

run.r1.datafile = 'phidgets-motor-estimation-r1.mat';
run.r1.outliers = [];

%% Run computations and load data

fn = fieldnames(run);
for k=1:numel(fn)
    run.(fn{k}).data = load(run.(fn{k}).datafile);  % load data into struct
    run.(fn{k}) = mean_step_resp(run.(fn{k}));         % compute step response means
%     run.(fn{k}) = levels(run.(fn{k}));              % extract level voltages
end


%% Plot

% - raw voltage
figure;
for k=1:numel(fn)
    run_k = run.(fn{k});
    plot(run_k.data.t,run_k.data.velocity);hold on
end
hold off
grid on;
xlabel('time (s)')
ylabel('angular velocity (rad/s)')
legend('location','southeast');
saveas(gcf,'raw-data.svg');

% - mean step
figure;
for k=1:numel(fn)
    run_k = run.(fn{k});
    plot(run_k.data.t(1:length(run_k.step_mean)),run_k.step_mean,...
        '-');hold on
end
hold off
grid on;
ylabel('angular velocity (rad/s)')
xlabel('time (s)')
legend('location','southeast');
saveas(gcf,'step-response-means.svg');


%% Define functions

function run_w_mean_step_resp = mean_step_resp(run)
    reps = run.data.reps;
    samples_per_rep = run.data.samples_per_rep;
    data_sequential = run.data.velocity;
    data_reps = reshape(data_sequential,samples_per_rep,reps).';
    n_step = floor(samples_per_rep/2);
    step_mean = mean(data_reps(:,1:n_step));
    run.n_step = n_step;
    run.step_mean = step_mean;
    run_w_mean_step_resp = run;
end