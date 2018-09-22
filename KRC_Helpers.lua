KRC_Helpers = {}

function KRC_Helpers:UnitIsInOurRaidOrParty(aUnitName)
	local numRaidMembers = GetNumRaidMembers()
	for i = 1, numRaidMembers do
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

	return false
end