function newVar = strip_interped(oldvar,newVar)
% A function to strip out the inpterpolated data from secondary variables.

oldDate = oldvar.Date;

tempVar = newVar;
newVar.Date = [];
newVar.Data = [];
newVar.Depth = [];

newDate = tempVar.Date;

for i = 1:length(oldDate)
    [~,ind] = min(abs(newDate - oldDate(i)));
    newVar.Date(i,1) = tempVar.Date(ind);
    newVar.Data(i,1) = tempVar.Data(ind);
    newVar.Depth(i,1) = tempVar.Depth(ind);
end