% /////// mytimer ///////
% inc = mytimer(i,i_all,inc)
%
% provides updates on how much processing has been done and how long you will have to wait
%
% inputs
%   tic (inbuilt matlab command) must be called before start of loop
%   i = integer count
%   i_all = [start of loop, end of loop] or [start of loop, skip, end of loop]
%   inc: set 'inc = []' before the start of your loop 
%
% outputs
%   text update in the command window of progress
%
% JN December 2011

function inc = mytimer(i,i_all,inc)

% is this the first time mytimer is called
if isempty(inc)
    inc = 1;
    tic
end

if length(i_all) == 3
    skip = i_all(2);
    ni = (i_all(3) - i_all(1))/skip + 1;
else
    ni = i_all(2) - i_all(1) + 1;
    skip = 1;
end


i = (i - i_all(1))/skip + 1;
perc_comp = i/ni * 100;
if perc_comp > inc
    time_remain = round((toc*100/perc_comp-toc)/60);   % mins
    disp(['percentage complete = ',num2str(round(perc_comp)),' %',' |',' time to completion = ',num2str(time_remain),' min']);
    inc = inc + 10;
end