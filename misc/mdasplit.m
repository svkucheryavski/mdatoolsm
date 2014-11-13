function objs = mdasplit(data, factors)
   groups = factors.getgroups();
   nGroups = groups.nCols;
   objs = cell(nGroups, 1);
   for iGroup = 1:nGroups
      ind = groups.values(:, iGroup) == 1;
      objs{iGroup} = data(ind, :);
      objs{iGroup}.name = groups.colFullNames{iGroup};
   end
end
