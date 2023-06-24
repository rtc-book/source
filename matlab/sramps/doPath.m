function [iseg,xc,yc,xr,yr,dwell,dtime]=doPath(path,nseg,iseg,xc,yc,xr,yr,dwell,dtime,Ts)
if iseg==-1
    iseg=1;
    dwell=0;
end

if (dwell==1)
    dtime = dtime - Ts;
    if (dtime <= 0)
        dwell=0;
        iseg=iseg+1;
        if iseg==nseg+1
            iseg=1;
        end
    end
    return
end

xf=path(iseg,1);
yf=path(iseg,2);
v =path(iseg,3);
tdwell=path(iseg,4);
 
dwell=0;
xs=v*Ts;
ys=v*Ts;
d=sqrt((xf-xc)^2+(yf-yc)^2);
vx=v*(xf-xc)/d;
vy=v*(yf-yc)/d;
xr=xc+vx*Ts;
yr=yc+vy*Ts;
if( (abs(xf-xc)<xs) && (abs(yf-yc)<ys) )
    if(tdwell>0)
        dwell=1;
        dtime=tdwell;
    else
        iseg=iseg+1;
        if iseg==nseg+1
            iseg=1;
        end
    end
    xr=xf;
    yr=yf;
end
xc=xr;
yc=yr;

end