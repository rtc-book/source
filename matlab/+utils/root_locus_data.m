function [r,k] = root_locus_data(sys,filename)
    % ROOT_LOCUS_DATA saves root locus data as ascii file
    % Arguments:
    % - sys: linear system model
    % - filename: file name to save data to
    % Returns:
    % - [r,k] 
    % - r: complex roots
    % - k: corresponding gains
    [r,k] = rlocus(sys);
    p = pole(sys);
    z = zero(sys);
    N=max([length(z),length(p)]);

    mydata = []; % to populate with data
    for i=1:N
        mydata(:,2*i -1) = (real(r(i,:))).'; % CL eig Real Part
        mydata(:,2*i)    = (imag(r(i,:))).'; % CL eig Imag Part
    end
    mydata(:,2*N+1) = k'; % the gain array
    save(filename,'mydata','-ascii');
    
    % get Matlab's autoscaling limits
    [folder, base, extension] = fileparts(filename);
    filename_xyminmax = [base,'-xyminmax.txt'];
    rlocus(sys);
    x = xlim;
    y = ylim;
    mydat_xyminmax = [x(1) x(2) y(1) y(2)];
    save(filename_xyminmax,'mydat_xyminmax','-ascii');
end