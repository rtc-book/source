clear;close all

% This script contains test data and calculations for the Pololu 18v17
% motor driver experiment to demonstrate its four-quadrant capabilities.

%% Current shunt resistor

probe_offset = 0.27;    % Ohms ... measured probe resistance
R = 1.73-probe_offset;  % Ohms ... measured shunt resistor resistance, which was two 3 Ohm power resistors in parallel

%% Load data

datafile = 'r1.mat';
load(datafile)

%% Plot

% time_range_plot = 1;
plot_samples = 1:500;

% - angular velocity vs time
figure;
plot(t(plot_samples),velocity(plot_samples)/(2*pi)*60);
grid on;
xlabel('time (s)')
ylabel('angular velocity (rpm)')
legend('location','southeast');
% xlim([0,time_range_plot])
saveas(gcf,'angular-velocity-vs-time.svg');

% - applied voltage and current vs time
figure;
yyaxis left
plot(t(plot_samples),voltage_source(plot_samples));hold on
ylabel('voltage (V)')
yyaxis right
plot(t(plot_samples),voltage(plot_samples)/R);hold off
ylabel('current (A)')
xlabel('time (s)')
% xlim([0,time_range_plot])
saveas(gcf,'voltage-current-vs-time.svg');

% - applied power vs time
power = voltage_source(plot_samples).*voltage(plot_samples)/R;
figure;
plot(t(plot_samples),power);hold on
ylabel('power (W)')
xlabel('time (s)')
% xlim([0,time_range_plot])
saveas(gcf,'power-vs-time.svg');

% - applied voltage vs current
neg_i = find(power < 0);
pos_i = find(power >= 0);
figure;
plot(voltage_source(plot_samples),voltage(plot_samples)/R,'-','Color',[0,0,1,.15]);hold on
scatter(voltage_source(pos_i),voltage(pos_i)/R,30,[0,0,1],'filled','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);
scatter(voltage_source(neg_i),voltage(neg_i)/R,30,[1,0,0],'filled','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);hold off
grid on;
axis equal;
xlabel('voltage (V)')
ylabel('current (A)')
saveas(gcf,'current-vs-voltage.svg');
