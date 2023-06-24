% Doing voltage reversal sans inductor to see the differences
clear; close all;

%% Load T1a parameters

load("../elmech_params/elmech_params_T1a.mat");

J = p.J;
B = p.B;
R = p.R;
Km = p.Km;

%% State space model

% numerical
a = (-B.*R - Km.^2)./(J.*R);
b = Km./(J.*R);
c = [1; -Km./R; -Km];
d = [0; 1./R; 1];

% symbolic
syms a_ b_ c_ d_ J_ B_ R_ Km_
a_ = (-B_.*R_ - Km_.^2)./(J_.*R_);
b_ = Km_./(J_.*R_);
c_ = [1; -Km_./R_; -Km_];
d_ = [0; 1./R_; 1];

%% Symbolic transfer functions

% The outputs are angular velocity ΩJ and resistor voltage vR.
% The transfer functions are ΩJ/VS and vR/VS.

syms s
H = simplify( ...
    c_*(s*eye(size(a_))-a_)^-1*b_ + d_ ...
)

%% State-space simulation

N = 3000; % number of points
ta = linspace(0,0.12,N);
VSa = zeros(size(ta)); % initialize
for i = 1:N % construct input VS
    if i < N/2
        VSa(i) = 1;
    else
        VSa(i) = -1;
    end
end

sys = ss(a,b,c,d);
y = lsim(sys,VSa,ta);

%% Plot

figure
subplot(3,1,1)
plot(ta,y(:,1))
ylabel('\Omega_J')
subplot(3,1,2)
plot(ta,y(:,2))
ylabel('i_S')
xlabel('time (s)')
subplot(3,1,3)
plot(ta,y(:,3))
ylabel('v_R')
xlabel('time (s)')