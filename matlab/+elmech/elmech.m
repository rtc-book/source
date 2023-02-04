classdef elmech < handle
    % ELMECH a class for defining an electromechanical system
    properties
        ts              % general target system version, e.g. 'T1'
        tss             % specific target system version, e.g. 'T1a'
        source          % source type 'voltage' or 'current'
        variant         % target system variant, e.g. 'OJ+iL'
        v               % version string, e.g. 'T1_current_OJ+iL'
        n               % system order
        m               % number of outputs
        r               % number of inputs
        states          % state variables, cell array of strings
        inputs          % input variables, cell array of strings
        outputs         % output variables, cell array of strings
        A_              % state-space A-matrix, symbolic
        B_              % state-space B-matrix, symbolic
        C_              % state-space C-matrix, symbolic
        D_              % state-space D-matrix, symbolic
        ss              % matlab ss model, numeric
        tf_              % transfer function, symbolic
        tf              % matlab tf model, numeric
        p_              % parameters, symbolic
        p               % parameters, numeric
        dc_             % dc gain(s), symbolic
        dc              % dc gain(s), numeric
        tss_versions    % specific TS versions (for exporting .mat files)
    end
    
    methods
        function self = elmech(ts,tss,source,variant)
            if nargin < 1
                ts = 'T1';
                tss = 'T1a';
                source = 'current';
                variant = 0;
            elseif nargin < 2
                tss = 'T1a';
                source = 'current';
                variant = 0;
            elseif nargin < 3
                source = 'current';
                variant = 0;
            elseif nargin < 4
                variant = 0;
            end
            self.ts = ts;
            self.tss = tss;
            self.source = source;
            self.variant = variant;
            self.v = strcat(ts,'_',source,'_',string(variant));
            self.params__con();
            self.params_con(tss,variant);
            self.ss__con(ts,source,variant);
            self.ss_con();
            self.tf_con();
            self.first_second_order_con();
            % for exporting .mat files
            self.tss_versions = {'T1a','T1ab','T1ac','T1ad','T1b','T2a'};
        end
        function self = params__con(self)
            syms R L Km J B Ka positive
            self.p_.R = R;
            self.p_.L = L;
            self.p_.Km = Km;
            self.p_.J = J;
            self.p_.B = B;
            self.p_.Ka = Ka;
        end
        function self = params_con(self,tss,variant)
            if strcmp(tss,'T1a')
                % motor (Faulhaber 2642048 CR)
                self.p.R = 23.8;            % Ohm
                self.p.L = 2200e-6;         % H
                self.p.Jm = 11e-3/100^2;    % kg-m^2    
                self.p.Km = 69.8e-3;        % N-m/A
                self.p.tau_mech = 5.4e-3;   % s ... mechanical time constant
                self.p.Vsnom = 48;
                self.p.noload_speed = 6400*2*pi/60;
                self.p.bm = (self.p.Vsnom*self.p.Km/self.p.noload_speed - self.p.Km^2)/self.p.R;
                % mechanical
                fly_density = 2700;         % kg/m^3 ... aluminum
                fly_diameter = 0.030;       % m
                fly_thick = 0.005;          % m 
                fly_volume = pi/4*fly_diameter^2*fly_thick; % m^3
                fly_mass = fly_density*fly_volume; % kg
                self.p.Jf = 1/2*fly_mass*(fly_diameter/2)^2;     % kg-m^2
                self.p.bb = 0;              % no external bearing
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Maxon ESCON Module 24/2)
                self.p.Ka = 0.06;        % A/V
            elseif strcmp(tss,'T1ab')
                % motor (Faulhaber 2342024 CR)
                self.p.R = 7.1;         % Ohm
                self.p.L = 265e-6;      % H
                self.p.Jm = 5.8e-3/100^2;     % kg-m^2    
                self.p.Km = 26.1e-3;    % N-m/A
                self.p.tau_mech = 6e-3; % s ... mechanical time constant
                self.p.Vsnom = 24;
                self.p.noload_speed = 8500*2*pi/60;
                self.p.bm = (self.p.Vsnom*self.p.Km/self.p.noload_speed - self.p.Km^2)/self.p.R;
                % mechanical
                self.p.Jf = 5.6376e-7;  % kg-m^2
                self.p.bb = 0;          % no external bearing
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Maxon ESCON Module 24/2)
                self.p.Ka = 0.06;        % A/V
            elseif strcmp(tss,'T1ac')
                % motor (Faulhaber 2342036 CR)
                self.p.R = 15.9;         % Ohm
                self.p.L = 590e-6;      % H
                self.p.Jm = 6.5e-3/100^2;     % kg-m^2    
                self.p.Km = 41.4e-3;    % N-m/A
                self.p.tau_mech = 6e-3; % s ... mechanical time constant
                self.p.Vsnom = 36;
                self.p.noload_speed = 8100*2*pi/60;
                self.p.bm = (self.p.Vsnom*self.p.Km/self.p.noload_speed - self.p.Km^2)/self.p.R;
                % mechanical
                self.p.Jf = 8.9424e-7;  % kg-m^2
                self.p.bb = 0;          % no external bearing
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Maxon ESCON Module 24/2)
                self.p.Ka = 0.06;        % A/V
            elseif strcmp(tss,'T1ad')
                % motor (Faulhaber 2342048 CR)
                self.p.R = 31.2;         % Ohm
                self.p.L = 1050e-6;      % H
                self.p.Jm = 6e-3/100^2;     % kg-m^2    
                self.p.Km = 56.1e-3;    % N-m/A
                self.p.tau_mech = 6e-3; % s ... mechanical time constant
                self.p.Vsnom = 48;
                self.p.noload_speed = 8000*2*pi/60;
                self.p.bm = (self.p.Vsnom*self.p.Km/self.p.noload_speed - self.p.Km^2)/self.p.R;
                % mechanical
                self.p.Jf = 1.21176e-6;  % kg-m^2
                self.p.bb = 0;          % no external bearing
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Maxon ESCON Module 24/2)
                self.p.Ka = 0.06;        % A/V
            elseif strcmp(tss,'T1b')
                % motor
                self.p.R = 1.6;
                self.p.L = 4.1e-3;
                self.p.Jm = 56.5e-6;
                self.p.bm = 16.9e-6;
                self.p.Km = 0.097;
                % mechanical
                self.p.Jf = 0.324e-3;
                self.p.bb = self.p.bm;
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Copley 412)
                self.p.Ka = 0.41;       % A/V
            elseif strcmp(tss,'T2a')
                % motor
                self.p.R = 1.09;                    % phidgets_motor_estimation.m (deduced from spec sheet)
                self.p.L = 0.0038106;               % estimated in phidgets_motor_estimation.m from step response measurement
                self.p.Jm = 6.4272e-05;             % estimated in phidgets_motor_estimation.m from step response measurement
                self.p.bm = 3.992e-05;              % estimated in phidgets_motor_estimation.m from step response measurement
                self.p.Km = 0.063694;               % estimated in phidgets_motor_estimation.m from step response measurement
                % mechanical
                density_Al = 2.71e3;                % kg/m^3 ... density of Al
                diameter_Jf = 2.5*2.54e-2;          % m ... flywheel diameter
                length_Jf = 1.0*2.54e-2;            % m ... flywheel length
                mass_Jf = density_Al*pi*(diameter_Jf/2)^2*length_Jf; % kg
                self.p.Jf = 1/2*mass_Jf*(diameter_Jf/2)^2; % kg-m^2 ... flywheel inertia
                self.p.bb = 0;                      % no external bearing
                % combined parameters
                self.p.J = self.p.Jm + self.p.Jf;
                self.p.B = self.p.bm + self.p.bb;
                % amplifier (Pololu 18v17, PWM)
                self.p.Ka = 1;       % V/V
            else
                error(['Specific target system tss ',tss,' undefined']);
            end
        end
        function self = ss__con(self,ts,source,variant)
            if strcmp(ts,'T0') | strcmp(ts,'T1') | strcmp(ts,'T2')
                if strcmp(source,'voltage')
                    self.states = {'\Omega_J','i_L'};
                    self.inputs = {'V_S'};
                    self.A_ = [
                        -self.p_.B/self.p_.J,   self.p_.Km/self.p_.J;
                        -self.p_.Km/self.p_.L,  -self.p_.R/self.p_.L;
                    ];
                    self.B_ = [
                        0; 1/self.p_.L
                    ];
                    if variant == 0
                        self.outputs = {'\Omega_J'};
                        self.C_ = [1, 0];
                        self.D_ = [0];
                    elseif strcmp(variant,'OJ+iL')
                        self.outputs = {'\Omega_J','i_L'};
                        self.C_ = [1, 0;0, 1];
                        self.D_ = [0; 0];
                    elseif strcmp(variant,'OJ+iL+TJ')
                        self.outputs = {'\Omega_J','i_L','T_J'};
                        self.C_ = [1, 0;0, 1;-self.p_.B, self.p_.Km];
                        self.D_ = [0; 0; 0];
                    elseif strcmp(variant,'OJ+iL+vL')
                        self.outputs = {'\Omega_J','i_L','v_L'};
                        self.C_ = [1, 0;0, 1;-self.p_.Km,-self.p_.R];
                        self.D_ = [0; 0; 1];
                    end
                elseif strcmp(source,'current')
                    self.states = {'\Omega_J'};
                    self.inputs = {'I_S'};
                    self.A_ = [-self.p_.B/self.p_.J];
                    self.B_ = [self.p_.Km/self.p_.J];
                    if variant == 0
                        self.outputs = {'\Omega_J'};
                        self.C_ = [1];
                        self.D_ = [0];
                    elseif strcmp(variant,'OJ+iL')
                        self.outputs = {'\Omega_J','i_L'};
                        self.C_ = [1;0];
                        self.D_ = [0;1];
                    end
                end
            end
            [self.n,self.r] = size(self.B_);
            [self.m,~] = size(self.C_);
        end
        function self = ss_con(self)
            A = double(subs(self.A_,self.p));
            B = double(subs(self.B_,self.p));
            C = double(subs(self.C_,self.p));
            D = double(subs(self.D_,self.p));
            self.ss = ss(A,B,C,D);
        end
        function self = tf_con(self)
            syms s
            self.tf_ = self.C_*(s*eye(self.n) - self.A_)^-1*self.B_ + self.D_;
            self.tf = tf(self.ss);
            self.dc_ = subs(self.tf_,0);
            self.dc = self.psubs(self.dc_);
        end
        function self = first_second_order_con(self)
            if self.n == 1
                self.tau_con();
            elseif self.n == 2   
                self.zwn_con();
            end
        end
        function self = zwn_con(self)
            syms s
            [~,d] = numden(self.tf_(1));         % numerator n, denominator d
            co = coeffs(d,s);                   % coefficients of the denominator
            cofactored = co/co(3);              % factored out s^2 coefficient
            self.p_.wn = sqrt(cofactored(1));   % rad/s ... natural frequency
            self.p_.z = cofactored(2)/(2*self.p_.wn);       % damping ratio 
            self.p.wn = self.psubs(self.p_.wn);% numerical
            self.p.z = self.psubs(self.p_.z);  % numerical
        end
        function self = tau_con(self)
            syms s
            [~,d] = numden(self.tf_(1));            % numerator n, denominator d
            co = coeffs(d,s);                   % coefficients of the denominator
            cofactored = co/co(1);              % factored out const coefficient
            self.p_.tau = cofactored(2);  % rad/s ... tau   
            self.p.tau = self.psubs(self.p_.tau); % numerical 
        end
        function obj = psubs(self,objin)
            % PSUBS substitutes parameters into symbolic object objin
            %   obj = PSUBS(objin) substitutes self.p into symbolic objin 
            % 
            %   returns a double
            obj = double(subs(objin,self.p));
        end
        function self = export_parameters(self)
            for i = 1:length(self.tss_versions)
                tss = self.tss_versions{i};
                fname = join(['elmech_params_',tss,'.mat']);
                disp(['Saving properties for ',tss,' to file ',fname])
                self.params_con(tss,0); % change to tss
                disp(self.p)
                p = self.p; % for the weird save command
                save(fname,'p');
            end
        end
    end
end