% /////// isflood ///////
% produces a vector of logicals indicating whether V_dir (nautical
% convention for currents corresponds to a flooding tide.
% the flooding domain is phi_lim(1) clockwise through to phi_lim(2)
%
% inputs
% V_dir: vector of directions (nautical)
% phi_lim: [phi_1 phi_2]
% i = isflood(v_dir,phi_lim)

function i = isflood(v_dir,phi_lim)
% checks
if length(phi_lim) ~= 2
    error('expecting phi_lim vector of length 2')
end

phi_1 = phi_lim(1);
phi_2 = phi_lim(2);

if phi_1 == phi_2
    error('phi_lim must cover a range of angles')
end

if phi_1 > phi_2
    i1 = v_dir >= phi_1;
    i2 = v_dir <= phi_2;
    i = i1 | i2;
else
    i = v_dir >= phi_1 & v_dir <= phi_2;
end