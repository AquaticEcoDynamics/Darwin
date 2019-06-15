function idetitle(Title)
%IDETITLE Set Window title of the Matlab IDE
%
% Examples:
% idetitle('Matlab - Foo model')
% idetitle(sprintf('Matlab - some big model - #%d', feature('getpid')))

win = appwin();
if ~isempty(win)
    win.setTitle(Title);
end

function out = appwin()
%APPWIN Get main application window

wins = java.awt.Window.getOwnerlessWindows();
for i = 1:numel(wins)
    if isa(wins(i), 'com.mathworks.mde.desk.MLMainFrame')
        out = wins(i);
        return
    end
end

out = [];