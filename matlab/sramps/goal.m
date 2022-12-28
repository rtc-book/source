function goal(zeta_goal,zeta_wn_goal)
% a=axis; a(1)=-3; a(2)=0,a(3)=-2; a(4)=2; axis(a);
axis equal
hold on
plot(zeta_wn_goal*[-1,-1],[-200,200],'r--')
plot(zeta_goal*[0,-200],[0, 200*sin(acos(zeta_goal))],'r--')
plot(zeta_goal*[0,-200],[0,-200*sin(acos(zeta_goal))],'r--')
return
