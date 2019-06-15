function seatemp = calc_Narrows_Temp(swan,SP)

Narrow_Temp = swan.NAR.TEMP.Data;
Narrow_Date = swan.NAR.TEMP.Date;
Narrow_Depth = swan.NAR.TEMP.Depth;

u_days = unique(floor(Narrow_Date));

inc = 1;

for i = 1:length(u_days)
    ss = find(floor(Narrow_Date) == u_days(i));
    
    [~,ind] = min(Narrow_Depth(ss));
    
    sTemp(inc) = Narrow_Temp(ss(ind(1)));
    inc = inc + 1;
    
    
    
end



seatemp = interp1(u_days,sTemp,SP.mDate);


ss = find(~isnan(seatemp) == 1);

mtemp = mean(seatemp(ss));

ss = find(isnan(seatemp) == 1);

seatemp(ss) = mtemp;

