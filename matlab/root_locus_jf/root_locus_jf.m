function root_locus_jf(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define systems
%     ZD = -.3:-.5:-.5*4;
    ZD = linspace(-.5,-2,4);
    ZI = ZD;
    disp(ZI)
    for n = 1:length(ZD)
        for k = 1:length(ZI)
            sys(:,:,n,k) = tf([1,-(ZD(n)+ZI(k)),ZD(n)*ZI(k)],[1,1,0,0]);
        end
    end
    
    %% Compute and save root locus data (and plot)
    figure;
    for n = 1:length(ZD)
        for k = 1:length(ZI)
            filename = ['sys',num2str(n),num2str(k),'.txt'];
            i = k + length(ZI)*(n-1);
            disp([n,k,i]);
            subplot(4,4,i)
            [r,k] = root_locus_data(sys(:,:,n,k),filename);
            xlim([-5.5,.5])
            ylim(3*[-1,1])
        end
    end
end
