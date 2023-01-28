//---PIDF position control, wc = 50 r/s
//---27-Jan-2023 01:12:23
    char        headerTime[] = "27-Jan-2023 01:12:23";
    int         PIDF_ns = 1;              // number of sections
    uint32_t    timeoutValue = 5000;      // time interval - us; f_s = 200 Hz
    static	struct	biquad PIDF[]={   // define the array of floating point biquads
        {2.575912e-01, -5.119104e-01, 2.543251e-01, 1.000000e+00, -1.580573e+00, 5.805727e-01, 0, 0, 0, 0, 0}
        };
