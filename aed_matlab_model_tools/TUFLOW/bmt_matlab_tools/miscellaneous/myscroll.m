% /////// myscroll ///////
%
% function [k skip] = myscroll(f,k,skip)
%
% used inside a while loop
% user able to scroll forwards or backwards
% scrolling can skip timesteps, to speed up scrolling, by pressing a numeric key
%
% inputs:
%   f = handle to figure for which you are working with
%   k = counter in your while loop
%
% outputs:
%   k = updated counter
%
% press the "f" key to proceed forward
% press the "b" key to go backwards
% press the "e" key to exit loop
% press "1","2","3",.... "9" to determine how to step through timesteps
%
% example:
% t = 200:300;
% nt  = length(t);
% f = figure;
% k = 1;
% skip = 1;
% while k < Inf % DO NOT use another condition
%     if k >= nt
%         display('you have reached the end, hit the "b" key to backup')
%         k = nt;
%         pause
%     end
%     title(gca,num2str(t(k)))
%     [k,skip] = myscroll(f,k,skip);
% end
%
% JN May 2012

function [k,skip] = myscroll(f,k,skip)

set(f,'windowkeypressfcn','set(gcbf,''Userdata'',get(gcbf,''CurrentCharacter''))')
set(f,'windowkeyreleasefcn','set(gcbf,''Userdata'','''')')


pause
key = get(f,'userdata');

while isempty(key)
    display('click over your figure or unselect pan, zoom or rotate')
    key = get(f,'userdata');
    pause
end

if ~isnan(str2double(key))
    skip = str2double(key);
    pause
    key = get(f,'userdata');
end

switch key
    case 'f'
        k = k + skip;
    case 'b'
        k = k - skip;
    case 'e'
        %         evalin('base','break') % Doesn't work unfortunately
        k = Inf;
    otherwise
        display('press "f" key to proceed, "b" key to backup or "e" to exit')
end

if k < 1
    k = 1;
end
