KRC_Helpers = {}

function KRC_Helpers:UnitIsInOurRaidOrParty(aUnitName)
	for i = 1, MAX_RAID_MEMBERS  do
		local memberName = UnitName("raid" .. i)
		if(memberName == aUnitName) then
			return true
		end
	end

	local numPartyMembers = GetNumPartyMembers()
	for i = 1, numPartyMembers do
		local memberName = UnitName("party" .. i)
		if(memberName == aUnitName) then
			return true
		end
	end

	if (UnitName("player") == aUnitName) then
		return true;
	end
	
	return false
end

function KRC_Helpers:GetUnitID(aUnitName)
	for i = 1, MAX_RAID_MEMBERS  do
		local id = "raid " .. i
		local memberName = UnitName(id)

		if(memberName == aUnitName) then
			return id
		end
	end
	

	local numPartyMembers = GetNumPartyMembers()
	for i = 1, numPartyMembers do
		local id = "party" .. i
		local memberName = UnitName(id)
		
		if(memberName == aUnitName) then
			return id
		end
	end

	if (UnitName("player") == aUnitName) then
		return "player"
	end
	
	return nil
end