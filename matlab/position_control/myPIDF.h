//---PIDF position control, wc = 50 r/s
//---03-Feb-2023 00:26:47
    char        headerTime[] = "03-Feb-2023 00:26:47";
    int         PIDF_ns = 1;              // number of sections
    uint32_t    timeoutValue = 5000;      // time interval - us; f_s = 200 Hz
    static	struct	biquad PIDF[]={   // define the array of floating point biquads
        {2.422811e+00, -4.813088e+00, 2.390336e+00, 1.000000e+00, -1.580573e+00, 5.805727e-01, 0, 0, 0, 0, 0}
        };
