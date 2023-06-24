
function[xa,x0,iseg,itime,done]=Sramps(segs, iseg, nseg, itime, T, xa,x0)
%     // Computes the next position, *xa, of a uniform sampled position profile.
%     // The profile is composed of an array of segments (type: seg)
%     // Each segment consists of:
%     //      xfa:    final position
%     //      v:      maximum velcity
%     //      a:      maximum acceleration
%     //      d:      dwell time at the final position
%     //  Called from a loop, the profile proceeds from the current position,
%     //  through each segment in turn, and then repeats.
%     // Inputs:
%     //  seg *segs:  - segments array
%     //  int *iseg:  - variable hold segment index
%     //  int nseg:   - number of segments in the profile
%     //  int *itime  - time index within a segment (= -1 at segment beginning)
%     //  double T:   - time increment
%     // Outputs:
%     //  double *xa: - next positon in profile
%     // Returns:     1 at end of profile, 0 otherwise
%     //
%     //  Call with *itime = -1, *iseg = -1, outside the loop to being.
    

%     double t, t1=0, t2=1, tf=1, tramp, x1=1, xramp, xfr=1, xr, d;
%     static double x0, dir;
%     double vmax=1, amax=1;
%     int n;
    
if (itime==-1) 
    iseg = iseg+1;
    if(iseg==nseg) 
        iseg=0;
    end
    itime=0;
    x0=xa;
end
vmax=segs(iseg+1,2);
amax=segs(iseg+1,3);
d=segs(iseg+1,4);
xfr=segs(iseg+1,1)-x0;
dir=1.0;
if(xfr<0)
    dir=-1.;
    xfr=-xfr;
end
t1 = vmax/amax;
x1 = 1./2.*amax*t1*t1;
if (x1<xfr/2) 
    xramp = xfr-2.*x1;
    tramp = xramp/vmax;
    t2 = t1+tramp;
    tf = t2+t1;
else 
    x1 = xfr/2;
    t1 = sqrt(2*x1/amax);
    t2 = t1;
    tf = 2.*t1;
end
n = floor((tf+d)/T)+1;

t = itime*T;
if(t<t1)
    xr = 1./2.*amax*t*t;
elseif (t>=t1 && t<t2) 
    xr = x1+vmax*(t-t1);
elseif (t>=t2 && t<tf) 
    xr = xfr-1./2.*amax*(tf-t)*(tf-t);
else
    xr = xfr;
end
xa=x0+dir*xr;
itime=itime+1;
if(itime==n+1)
    itime=-1;
    if(iseg==nseg-1) 
        done=1;
        return
    end
end
done=0;
return