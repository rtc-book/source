classdef colors < handle
    properties
        c1
        c2
        c3
        c4
        c5
        c6
        list    % list of all the colors
    end
    
    methods
        function self = colors()
            self.c1 = [13, 212, 255]/255;
            self.c2 = [255, 87, 13]/255;
            self.c3 = [105, 15, 255]/255;
            self.c4 = [255, 184, 15]/255;
            self.c5 = [10, 204, 136]/255;
            self.c6 = [204, 10, 142]/255;
            self.list = [self.c1;self.c2;self.c3;self.c4;self.c5;self.c6];
            set(0,'DefaultAxesColorOrder',self.list);
        end
    end
end