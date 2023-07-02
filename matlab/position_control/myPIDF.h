//---PIDF position control, wc = 50 r/s
//---01-Jul-2023 19:45:39
    char        headerTime[] = "01-Jul-2023 19:45:39";
    int         PIDF_ns = 1;              // number of sections
    uint32_t    timeoutValue = 5000;      // time interval - us; f_s = 200 Hz
    static	struct	biquad PIDF[]={   // define the array of floating point biquads
        {1.427516e+01, -2.819317e+01, 1.391873e+01, 1.000000e+00, -1.494424e+00, 4.944236e-01, 0, 0, 0, 0, 0}
        };
