function [xdata,ydata] = get_field_at_depth(mDate,mData,mDepth,level)

xdata = [];
ydata = [];
if strcmpi(level,'surface')
    
    sss = find(mDepth > -1);
    xdata = mDate(sss);
    ydata = mData(sss);
else
    
    inc = 1;
    
    sss = find(mDepth < -1);
    
    if ~isempty(sss)
    
    mDate_b = mDate(sss);
    mData_b = mData(sss);
    mDepth_b = mDepth(sss);
    
    
    fdate = floor(mDate_b);
    
    udate = unique(fdate);
    
    for j = 1:length(udate)
        if ~isnan(udate(j))
        sss2 = find(fdate == udate(j));
        
        [~,tt] = min(mDepth_b(sss2));
        
        xdata(inc,1) = mDate_b(sss2(tt(1)));
        ydata(inc,1) = mData_b(sss2(tt(1)));
        inc = inc + 1;
        end
    end
    end
end