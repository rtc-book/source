function root_locus_16up(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
%     ts_default = 'T1';              % default elmech system
%     source_default = 'voltage';     % default elmech system
%     variant_default = 'OJ+iL';      % default elmech system
%     p = inputParser;
%     valid_ts = @(x) true;
%     valid_source = @(x) strcmp(x,'voltage'); % has to be voltage source model
%     valid_variant = @(x) true;
%     addParameter(p,'ts',ts_default,valid_ts);
%     addParameter(p,'source',source_default,valid_source);
%     addParameter(p,'variant',variant_default,valid_variant);
%     parse(p,varargin{:});

    %% Define systems
    sys(:,:,1) = zpk([],[-1,-2],1);
    sys(:,:,2) = zpk([-3],[-1,-2],1);
    sys(:,:,3) = zpk([-4],[-1,-2,-3],1);
    sys(:,:,4) = zpk([],[-1,-2,-3,-4],1);
    sys(:,:,5) = zpk([],[-2+1j*2,-2-1j*2],1);
    sys(:,:,6) = zpk([],[-1,-2+1j*2,-2-1j*2],1);
    sys(:,:,7) = zpk([-3],[-1,-2+1j*2,-2-1j*2],1);
    sys(:,:,8) = zpk([-3,-4],[-1,-2+1j*2,-2-1j*2],1);
    sys(:,:,9) = zpk([],[-1,1],1);
    sys(:,:,10) = zpk([-3],[-2,-1,1],1);
    sys(:,:,11) = zpk([-2],[-3,-1,1],1);
    sys(:,:,12) = zpk([-.666,-.333],[0,-1,1],1);
    sys(:,:,13) = zpk([-2],[-1],1);
    sys(:,:,14) = zpk([-2+1j*2,-2-1j*2],[-1+1j*1,-1-1j*1],1);
    sys(:,:,15) = zpk([-2+1j*2,-2-1j*2],[-1+1j*1,-1-1j*1,-3+1j,-3-1j],1);
    sys(:,:,16) = zpk([-1,-2+1j*2,-2-1j*2],[-1+1j*1,-1-1j*1,-3+1j,-3-1j],1);
    
    %% Compute and save root locus data (and plot)
    figure;
    for i = 1:length(sys)
        filename = ['sys',num2str(i),'.txt'];
        subplot(4,4,i)
        [r,k] = root_locus_data(sys(:,:,i),filename);
    end
end
