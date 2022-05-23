function val = pwm(t,amp,w,duty)
    % PWM signal
    % Arguments:
    % - t: time array
    % - amp: amplitude
    % - w: angular frequency
    % - duty: duty cycle
    % Returns:
    % - val: value of the PWM signal at t
    td = 2*pi*duty/w;
    val = zeros(size(t));   % set all to zero
    tm = mod(t,2*pi/w);
    iamp = tm < td;     % indices at which val should be amp
    val(iamp) = amp;
end