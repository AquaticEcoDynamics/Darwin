% /////// convtime ///////
% function t2 = convtime(t1,varargin)
% converts FV time to MATLAB time and visa versa
% if the date is upper than the 01/01/1969 you will have to use the varargin
% varargin = 'mat' converts fv time to matlab time
% varargin = 'fv'  converts matlab time to fv time
% varargin = 'string' gives the date



function t2 = convtime(t1,varargin)

t_ref = '01/01/1990 00:00:00';
t_tmp = t1/24 + datenum(t_ref);%,'dd/mm/yyyy HH:MM:SS');
t_tmp2 = (t1-datenum(t_ref,'dd/mm/yyyy HH:MM:SS'))*24;

i = ~isnan(t1);

if (t1(i)<700000)
    t2=t_tmp;
else
    t2=t_tmp2;
end

for i =1 : nargin-1
    varargtyp{i} = varargin{i};
    switch varargtyp{i}
        case 'mat'
            t2=t_tmp;
        case 'fv'
            t2=t_tmp2;
         
         case 'string'
             if (t1<700000)
                 t2 = datestr(t_tmp,'dd/mm/yyyy HH:MM:SS');
             else
                 t2 = datestr(t1,'dd/mm/yyyy HH:MM:SS');
             end
           
        otherwise
            error('unexpected variable argument type')
    end
end
















