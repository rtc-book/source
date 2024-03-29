clear;close all

% This script contains test data and calculations for the Phidgets motor
% step responses for estimating the motor J and L.

%% Known motor parameters

stall_current = 22.06;                  % A ... motor curve/spec sheet
terminal_voltage = 24.08;               % V ... motor curve/spec sheet
p.R = terminal_voltage/stall_current;   % Ohms ... terminal resistance
% p.Km = 0.0661;            % motor curve/spec sheet ... estimating instead
% p.b = 243e-6;             % motor curve/spec sheet ... estimating instead

%% Run definitions

run.r1.datafile = 'phidgets-motor-estimation-r1.mat';
run.r1.p = p; % initial parameters ... will add more as they are estimated

%% Run computations and load data

fn = fieldnames(run);
for k=1:numel(fn)
    run.(fn{k}).data = load(run.(fn{k}).datafile);  % load data into struct
    run.(fn{k}) = rad_s(run.(fn{k}));               % convert speed from BDI/BTI to rad/s
    run.(fn{k}) = mean_step_resp(run.(fn{k}));         % compute step response mean
    run.(fn{k}) = fit_parameters(run.(fn{k}));      % curve fit parameters from step response mean
    run.(fn{k}) = estimate_params(run.(fn{k}));
    run.(fn{k}).curve
    fnp = fieldnames(run.(fn{k}).p);
    fprintf("Parameter estimates:\n")
    for kp=1:numel(fnp)
        pk = run.(fn{k}).p;
        if isfield(p,fnp{kp})
            post = '(spec sheet)';
        else
            post = '';
        end
        fprintf("%s = %.5g\t%s\n", ...
            fnp{kp}, ...
            pk.(fnp{kp}), ...
            post ...
        )
    end
end

%% Plot

% - raw BDI/BTI
figure;
for k=1:numel(fn)
    run_k = run.(fn{k});
    plot(run_k.data.t,run_k.data.velocity);hold on
end
hold off
grid on;
xlabel('time (s)')
ylabel('angular velocity (BDI/BTI)')
legend('location','southeast');
saveas(gcf,'raw-data.svg');

% - mean step
figure;
for k=1:numel(fn)
    run_k = run.(fn{k});
    t = run_k.data.t(1:run_k.n_step);
    h1(k) = plot(t,run_k.step_mean,...
        'o');hold on
    h2(k) = plot(run_k.curve); hold on
end
hold off
grid on;
ylabel('angular velocity (rad/s)')
xlabel('time (s)')
legend([h1,h2],{'mean step','fitted curve'},'location','southeast');
saveas(gcf,'step-response-means-fitted.svg');


%% Define functions

function run_w_mean_step_resp = mean_step_resp(run)
    reps = run.data.reps;
    samples_per_rep = run.data.samples_per_rep;
    data_sequential = run.rad_s;
    data_reps = reshape(data_sequential,samples_per_rep,reps).';
    n_step = floor(samples_per_rep/2);
    step_mean = mean(data_reps(:,1:n_step));
    run.n_step = n_step;
    run.step_mean = step_mean;
    run_w_mean_step_resp = run;
end

function run_w_rad_s = rad_s(run)
    % RAD_S converts speed from BDI/BTI to rad/s
    cpr = 300; % HKT22 encoder
    rad_s = run.data.velocity*2*pi/(4*cpr)/run.data.bti_s;
    run.rad_s = rad_s;
    run_w_rad_s = run;
end

function run_w_fit = fit_parameters(run)
    p = run.p;
    syms wn z b Km positive
    syms x real
    l1 = -z*wn + wn*sqrt(z^2 - 1);
    l2 = -z*wn - wn*sqrt(z^2 - 1);
    ystep = run.data.Vmax*Km/(Km^2+b*p.R)*(1 - 1/(l2 - l1)*(l2*exp(l1*x) - l1*exp(l2*x)));
    ystep_s = sprintf("%s",ystep);
    fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0.01,1e-6,0.1,0.5],...
               'Upper',[0.1,5e-5,1000,3],...
               'StartPoint',[0.05,30e-6,10,0.9]);
    ft = fittype(ystep_s,'options',fo);
    [curve,gof] = fit(run.data.t(1:run.n_step),run.step_mean.',ft);
    run.p.wn = curve.wn;
    run.p.z = curve.z;
    run.p.b = curve.b;
    run.p.Km = curve.Km;
    run.ft = ft;
    run.curve = curve;
    run.gof = gof;
    run_w_fit = run;
end

function run_w_params = estimate_params(run)
    syms wn z Km b R J L positive
    eq1 = wn == sqrt((Km^2+b*R)/(J*L));
    eq2 = z == (b*L+J*R)/(2*sqrt(J*L*(Km^2+b*R)));
    S = solve([eq1,eq2],[J,L],'Real',true,'ReturnConditions',true);
    J2 = double(subs(S.J,run.p)); % two solutions
    L2 = double(subs(S.L,run.p)); % two solutions
    run.p.J = J2(1); % the first solution seems more reasonable
    run.p.L = L2(1); % corresponding inductance
    run_w_params = run;
end