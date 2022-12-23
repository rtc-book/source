function pi_controller_discrete_example_wz(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define system
    GP = tf([2,20],[1,20])*tf([64],[1,12,32]);
    H = tf([1],[1]);
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(GP*H,'root-locus-P.txt');
    grid on
    
    %% Define the closed-loop transfer function
    K = 3.66;               % from root locus
    GCLP = K*GP/(1+K*GP*H);   % closed-loop tf
    
    %% Simulate the step response
    t = linspace(0,1,200);  % time array
    yP = step(GCLP,t);      % step response simulation
    
    %% Plot step response
    figure
    plot(t,yP);
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP];
    save('step-response-P.txt','d','-ascii');
    
    %% Integral compensation
    CI1 = tf([1,1],[1,0]);
    GC1 = K*CI1;
    GCLPI1 = GC1*GP/(1+GC1*GP*H);
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(CI1*GP*H,'root-locus-PI1.txt');
    grid on
    
    %% Simulate the step response
    yPI1 = step(GCLPI1,t);        % step response simulation
    
    %% Faster integral compensation
    CI2 = tf([1,2],[1,0]);
    K2 = 4;
    GC2 = K2*CI2;
    GCLPI2 = GC2*GP/(1+GC2*GP*H);
    
    %% Simulate the step response
    yPI2 = step(GCLPI2,t);        % step response simulation
    
    %% Plot step responses together
    figure
    plot(t,yP);hold on
    plot(t,yPI1);
    plot(t,yPI2);hold off
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP,yPI1,yPI2];
    save('step-response-all.txt','d','-ascii');
    
    %% Compute transient response characteristics
    S = stepinfo(yPI2,t);
    sprintf('Tp = %0.3f sec',S.PeakTime)
    sprintf('Tr = %0.3f sec',S.RiseTime)
    
    %% Sample rate
    T = 10e-3;   % s ... sample period
    fs = 1/T;   % Hz ... sample rate
    
    %% Discretize controller, GP, and H
    Nd = c2d(GC2,T,'Tustin');
    GPd = c2d(GP,T,'Tustin');
    Hd = c2d(H,T,'Tustin');
    GCLd = Nd*GPd/(1+Nd*GPd*Hd);
    
    %% Simulate the step response
    td = 0:T:1;
    yPId = step(GCLd,td);        % step response simulation
    
    %% Simulate the control effort
    UoRd = Nd/(1+Nd*GPd*Hd);
    uPId = step(UoRd,td);
    
    %% Plot step responses together
    figure
    yyaxis left
    plot(t,yPI2);hold on
    plot(td,yPId);hold off
    ylabel('output response')
    yyaxis right
    plot(td,uPId);
    xlabel('time (s)')
    ylabel('control effort')
    
    %% Save more step plot data
    d = [td.',yPId,uPId];
    save('step-response-digital.txt','d','-ascii');
end
