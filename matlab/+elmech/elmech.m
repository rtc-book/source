classdef elmech < handle
    % ELMECH a class for defining an electromechanical system
    properties
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
        H_              % transfer function, symbolic
        tf              % matlab tf model, numeric
        p_              % parameters, symbolic
        p               % parameters, numeric
        dc_             % dc gain(s), symbolic
        dc              % dc gain(s), numeric
    end
    
    methods
        function self = elmech(ts,source,variant)
            if nargin < 1
                ts = 'T1';
                source = 'voltage';
                variant = 0;
            elseif nargin < 2
                source = 'voltage';
                variant = 0;
            elseif nargin < 3
                variant = 0;
            end
            self.params__con(ts,variant);
            self.params_con(ts,variant);
            self.ss__con(ts,source,variant);
            self.ss_con();
            self.tf_con();
            self.first_second_order_con();
        end
        function self = params__con(self,ts,variant)
            syms R L Km J b positive
            self.p_.R = R;
            self.p_.L = L;
            self.p_.Km = Km;
            self.p_.J = J;
            self.p_.b = b;
        end
        function self = params_con(self,ts,variant)
            if ts == 'T1'
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
                self.p.b = self.p.bm + self.p.bb;
            end
        end
        function self = ss__con(self,ts,source,variant)
            if ts == 'T1'
                if source == 'voltage'
                    self.states = {'\Omega_J','i_L'};
                    self.inputs = {'V_S'};
                    self.A_ = [
                        -self.p_.b/self.p_.J,   self.p_.Km/self.p_.J;
                        -self.p_.Km/self.p_.L,  -self.p_.R/self.p_.L;
                    ];
                    self.B_ = [
                        0; 1/self.p_.L
                    ];
                    if variant == 0
                        self.outputs = {'\Omega_J'};
                        self.C_ = [1, 0];
                        self.D_ = [0];
                    elseif variant == 'OJ+iL'
                        self.outputs = {'\Omega_J','i_L'};
                        self.C_ = [1, 0;0, 1];
                        self.D_ = [0; 0];
                    end
                elseif source == 'current'
                    self.states = {'\Omega_J'};
                    self.inputs = {'I_S'};
                    self.outputs = {'\Omega_J'};
                    self.A_ = [-self.p_.b/self.p_.J];
                    self.B_ = [self.p_.Km/self.p_.J];
                    self.C_ = [1];
                    self.D_ = [0];
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
            self.H_ = self.C_*(s*eye(self.n) - self.A_)^-1*self.B_ + self.D_;
            self.tf = tf(self.ss);
            self.dc_ = subs(self.H_,0);
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
            [~,d] = numden(self.H_(1));         % numerator n, denominator d
            co = coeffs(d,s);                   % coefficients of the denominator
            cofactored = co/co(3);              % factored out s^2 coefficient
            self.p_.wn = sqrt(cofactored(1));   % rad/s ... natural frequency
            self.p_.z = cofactored(2)/(2*self.p_.wn);       % damping ratio 
            self.p.wn = self.psubs(self.p_.wn);% numerical
            self.p.z = self.psubs(self.p_.z);  % numerical
        end
        function self = tau_con(self)
            syms s
            [~,d] = numden(self.H_);            % numerator n, denominator d
            co = coeffs(d,s);                   % coefficients of the denominator
            cofactored = co/co(1);              % factored out const coefficient
            self.p_.tau = sqrt(cofactored(2));  % rad/s ... tau   
            self.p.tau = self.psubs(self.p_.tau); % numerical 
        end
        function obj = psubs(self,objin)
            % PSUBS substitutes parameters into symbolic object objin
            %   obj = PSUBS(objin) substitutes self.p into symbolic objin 
            % 
            %   returns a double
            obj = double(subs(objin,self.p));
        end
    end
end