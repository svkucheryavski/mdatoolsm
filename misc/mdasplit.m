function objs = mdasplit(data, factors)
   groups = factors.getgroups();
   nGroups = groups.nCols;
   objs = {};
   for iGroup = 1:nGroups
      ind = groups.values(:, iGroup) == 1;
      if any(ind)
         obj = data(ind, :);
         obj.name = groups.colFullNames{iGroup};
         objs{end + 1} = obj;
      end   
   end
end
