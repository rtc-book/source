% Generates Sramps data for plot in lab exercise

clear; close all

%% Load packages

addpath('..')               % to load sibling packages
import elmech.*             % electromechanical system definition
import utils.*              % utilities like pwm function
import plotting.colors.*    % RTCBook colors
colors = plotting.colors(); % ... load them, set as default

%% Compute segments

load 'Lab.mat'
[nseg,nc]=size(mySegs);
ntot=length(position);

range=1:length(t);

T=0.005;
[xa,x0,iseg,itime,done]=Sramps(mySegs, -1, nseg, -1, T, 0,0);

for i=1:ntot
    [xa,x0,iseg,itime,done]=Sramps(mySegs, iseg, nseg, itime, T, xa,x0);
    r(i)=xa;
    ta(i)=(i-1)*T;
end

%% Save data

t_an = ta.';
r_an = r.';
dat_r = [t_an,r_an];
save(strcat('lab8_command_sramps','_make.dat'),'dat_r','-ascii');

%% Plot

figure
plot(ta,r)