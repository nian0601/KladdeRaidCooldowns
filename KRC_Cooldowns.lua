local timeWidth = 40
local detailsWidth = 50

local tformat1 = "%d:%02d"
local tformat2 = "%1.1f"
local tformat3 = "%.0f"

local function SecondsToTimeDetail( t )
	if t >= 3600 then -- > 1 hour
		local h = floor(t/3600)
		local m = t - (h*3600)
		return tformat1, h, m
	elseif t >= 60 then -- 1 minute to 1 hour
		local m = floor(t/60)
		local s = t - (m*60)
		return tformat1, m, s
	elseif t < 10 then -- 0 to 10 seconds
		return tformat2, t
	else -- 10 seconds to one minute
		return tformat3, floor(t + .5)
	end
end

KRC_Cooldowns = {}
KRC_Cooldowns.myActiveFrames = {}
KRC_Cooldowns.myFreeFrames = {}

local bloodlustId = UnitFactionGroup("player") == "Alliance" and 32182 or 2825
KRC_Cooldowns.mySpells = {
	DRUID = {
		[48477] = 600,  -- Rebirth
		[29166] = 180,  -- Innervate
		[17116] = 180,  -- Nature's Swiftness
		[5209] = 180,   -- Challenging Roar
		[61336] = 180,  -- Survival Instincts
		[22812] = 60,   -- Barkskin
	},
	HUNTER = {
		[34477] = 30,   -- Misdirect
		[5384] = 30,    -- Feign Death
		[62757] = 300,  -- Call Stabled Pet
		[781] = 25,     -- Disengage
		[34490] = 20,   -- Silencing Shot
		[13809] = 30,   -- Frost Trap
	},
	MAGE = {
		[45438] = 300,  -- Iceblock
		[2139] = 24,    -- Counterspell
		[31687] = 180,  -- Summon Water Elemental
		[12051] = 240,  -- Evocation
		[66] = 180,     -- Invisibility
	},
	PALADIN = {
		[31821] = 120,  -- Aura Mastery
		[20216] = 120,  -- Divine Favor
		[31842] = 180,  -- Divine Illumination
		[19752] = 600,  -- Divine Intervention
		[642] = 300,    -- Divine Shield
		[64205] = 120,  -- Divine Sacrifice
		[54428] = 60,   -- Divine Plea
		[498] = 180,    -- Divine Protection
		[1044] = 25,    -- Hand of Freedom
		[10278] = 300,  -- Hand of Protection
		[6940] = 120,   -- Hand of Sacrifice
		[1038] = 120,   -- Hand of Salvation
		[48788] = 1200, -- Lay on Hands
		[66233] = 120,  -- Ardent Defender
	},
	PRIEST = {
		[33206] = 144,  -- Pain Suppression
		[47788] = 180,  -- Guardian Spirit
		[6346] = 180,   -- Fear Ward
		[64843] = 480,  -- Divine Hymn
		[64901] = 360,  -- Hymn of Hope
		[34433] = 300,  -- Shadowfiend
		[10060] = 96,  -- Power Infusion
		[47585] = 180,  -- Dispersion
	},
	ROGUE = {
		[31224] = 90,   -- Cloak of Shadows
		[38768] = 10,   -- Kick
		[1725] = 30,    -- Distract
		[13750] = 180,  -- Adrenaline Rush
		[13877] = 120,  -- Blade Flurry
		[14177] = 180,  -- Cold Blood
		[11305] = 180,  -- Sprint
		[26889] = 180,  -- Vanish
		[57934] = 30,   -- Tricks of the Trade
		[2094] = 180,   -- Blind
		[26669] = 180,  -- Evasion
		[14185] = 480,  -- Preparation
		[36554] = 30,   -- Shadowstep
		[14177] = 180,  -- Cold Blood
		[51690] = 120,  -- Killing Spree
		[51713] = 60,   -- Shadow Dance
		[14183] = 20,   -- Premeditation
	},
	SHAMAN = {
		[bloodlustId] = 300, -- Bloodlust/Heroism
		[20608] = 1800, -- Reincarnation
		[16190] = 300,  -- Mana Tide Totem
		[2894] = 600,   -- Fire Elemental Totem
		[2062] = 600,   -- Earth Elemental Totem
		[16188] = 180,  -- Nature's Swiftness
		[57994] = 6,    -- Wind Shear
	},
	WARLOCK = {
		[6203] = 900,   -- Soulstone
		[29858] = 180,  -- Soulshatter
		[47241] = 180,  -- Metamorphosis
		[18708] = 900,  -- Fel Domination
		[698] = 120,    -- Ritual of Summoning
		[58887] = 300,  -- Ritual of Souls
	},
	WARRIOR = {
		[871] = 300,    -- Shield Wall
		[1719] = 300,   -- Recklessness
		[20230] = 300,  -- Retaliation
		[12975] = 180,  -- Last Stand
		[6554] = 10,    -- Pummel
		[1161] = 180,   -- Challenging Shout
		[5246] = 180,   -- Intimidating Shout
		[64380] = 300,  -- Shattering Throw (could be 64382)
		[55694] = 180,  -- Enraged Regeneration
		[72] = 12,      -- Shield Bash
	},
	DEATHKNIGHT = {
		[48792] = 120,  -- Icebound Fortitude
		[42650] = 600,  -- Army of the Dead
		[61999] = 600,  -- Raise Ally
		[49028] = 90,   -- Dancing Rune Weapon
		[49206] = 180,  -- Summon Gargoyle
		[47476] = 120,  -- Strangulate
		[49576] = 35,   -- Death Grip
		[51271] = 120,  -- Unbreakable Armor
		[55233] = 60,   -- Vampiric Blood
		[49222] = 120,  -- Bone Shield
		[47528] = 10,   -- Mind Freeze
		[48707] = 45,   -- Anti-Magic Shell
	},
}

KRC_Cooldowns.myTargetedSpells = {
	[48477] = 600,  -- Rebirth
	[29166] = 180,  -- Innervate
	[34477] = 30,   -- Misdirect
	[19752] = 600,  -- Divine Intervention
	[1044] = 25,    -- Hand of Freedom
	[10278] = 300,  -- Hand of Protection
	[6940] = 120,   -- Hand of Sacrifice
	[1038] = 120,   -- Hand of Salvation
	[48788] = 1200, -- Lay on Hands
	[33206] = 144,  -- Pain Suppression
	[47788] = 180,  -- Guardian Spirit
	[6346] = 180,   -- Fear Ward
	[10060] = 96,  -- Power Infusion
	[57934] = 30,   -- Tricks of the Trade
	[6203] = 900,   -- Soulstone
}

KRC_Cooldowns.myAuraMasteryID = 31821
KRC_Cooldowns.myGuardianSpiritID = 47788

-- Special handling of some spells that are only triggered by SPELL_AURA_APPLIED.
KRC_Cooldowns.myAuraAppliedSpells = {
	[66233] = true,  -- Ardent Defender
}

function KRC_Cooldowns:CreateText(aName, aParent)
	local frame = CreateFrame("Frame", aName, aParent)
	frame:SetFrameStrata("LOW")
	frame:SetFrameLevel(1)

	frame.Text = frame:CreateFontString(frame:GetName(), "LODW", "GameFontHighlightSmallOutline")
	frame.Text:SetFontObject("GameFontHighlightSmallOutline")
	frame.Text:SetTextColor(1, 1, 1)
	frame.Text:SetText("")
	return frame
end

function KRC_Cooldowns:CreateBar(aBarIndex)
	local frame = CreateFrame("Frame", "KRC_Cooldown" .. aBarIndex, self.DragableFrame)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(2)
	frame:SetWidth(KRC_Core.db.profile.cooldowns.barWidth + KRC_Core.db.profile.cooldowns.barHeight)
	frame:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetTexture(KRC_Core.MediaPath .. "Texture\\statusbar")
	frame.bg:SetAllPoints(true)
	frame.bg:SetVertexColor(0.2, 0.2, 0.2)

	frame.icon = frame:CreateTexture(nil, "LOW")
	frame.icon:SetWidth(KRC_Core.db.profile.cooldowns.barHeight)
	frame.icon:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.icon:SetTexture(KRC_Core.MediaPath .. "Texture\\statusbar")
	frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	frame.bar = CreateFrame("StatusBar", frame:GetName() .. "_Bar", frame)
	frame.bar:SetStatusBarTexture(KRC_Core.MediaPath .. "Texture\\statusbar")
	frame.bar:GetStatusBarTexture():SetHorizTile(false)
	frame.bar:SetStatusBarColor(0.7,0,0)
	frame.bar:SetMinMaxValues(0, 100)
	frame.bar:SetValue(100)
	frame.bar:SetWidth(KRC_Core.db.profile.cooldowns.barWidth)
	frame.bar:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", KRC_Core.db.profile.cooldowns.barHeight, 0)

	frame.bar.lable = self:CreateText(frame.bar:GetName() .. "_Label", frame.bar)
	frame.bar.lable.Text:ClearAllPoints()
	frame.bar.lable.Text:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", 2, 0)
	frame.bar.lable.Text:SetWidth(KRC_Core.db.profile.cooldowns.barWidth - timeWidth)
	frame.bar.lable.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.bar.lable.Text:SetJustifyH("LEFT")

	frame.bar.time = self:CreateText(frame.bar:GetName() .. "_Time", frame.bar)
	frame.bar.time.Text:ClearAllPoints()
	frame.bar.time.Text:SetPoint("TOPRIGHT", frame.bar, "TOPRIGHT", -2, 0)
	frame.bar.time.Text:SetWidth(timeWidth)
	frame.bar.time.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.bar.time.Text:SetJustifyH("RIGHT")


	frame.detailIcon = frame:CreateTexture(nil, "LOW")
	frame.detailIcon:SetWidth(KRC_Core.db.profile.cooldowns.barHeight)
	frame.detailIcon:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.detailIcon:SetPoint("TOPLEFT", frame.bar, "TOPRIGHT", 3, 0)

	frame.detailText = self:CreateText(frame:GetName() .. "_DetailText", frame)
	frame.detailText.Text:ClearAllPoints()
	frame.detailText.Text:SetPoint("TOPLEFT", frame.bar, "TOPRIGHT", 3, 0)
	frame.detailText.Text:SetWidth(detailsWidth)
	frame.detailText.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
	frame.detailText.Text:SetJustifyH("LEFT")
	frame.detailText.Text:SetText("THIS IS A NAME")

	frame:Hide()

	return frame
end

function KRC_Cooldowns:UpdateBarSizes()

	local i = 1
	while i <= table.getn(self.myActiveFrames) do
		local frame = self.myActiveFrames[i]
		frame:SetWidth(KRC_Core.db.profile.cooldowns.barWidth + KRC_Core.db.profile.cooldowns.barHeight)
		frame:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.icon:SetWidth(KRC_Core.db.profile.cooldowns.barHeight)
		frame.icon:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.bar:SetWidth(KRC_Core.db.profile.cooldowns.barWidth)
		frame.bar:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)
		frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", KRC_Core.db.profile.cooldowns.barHeight, 0)

		frame.bar.lable.Text:SetWidth(KRC_Core.db.profile.cooldowns.barWidth - timeWidth)
		frame.bar.lable.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.bar.time.Text:SetWidth(timeWidth)
		frame.bar.time.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		i = i + 1
	end

	i = 1
	while i <= table.getn(self.myFreeFrames) do
		local frame = self.myFreeFrames[i]
		frame:SetWidth(KRC_Core.db.profile.cooldowns.barWidth + KRC_Core.db.profile.cooldowns.barHeight)
		frame:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.icon:SetWidth(KRC_Core.db.profile.cooldowns.barHeight)
		frame.icon:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.bar:SetWidth(KRC_Core.db.profile.cooldowns.barWidth)
		frame.bar:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.bar.lable.Text:SetWidth(KRC_Core.db.profile.cooldowns.barWidth - timeWidth)
		frame.bar.lable.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		frame.bar.time.Text:SetWidth(timeWidth)
		frame.bar.time.Text:SetHeight(KRC_Core.db.profile.cooldowns.barHeight)

		i = i + 1
	end

	self.DragableFrame:SetWidth(KRC_Core.db.profile.cooldowns.barWidth + KRC_Core.db.profile.cooldowns.barHeight)
	self.DragableFrame:SetHeight(KRC_Core.db.profile.cooldowns.barHeight * KRC_Core.db.profile.cooldowns.maxNumBars)
end

function KRC_Cooldowns:RepositionBars()

	local numActiveFrames = table.getn(self.myActiveFrames)
	if numActiveFrames < 1 then
		return
	end

	local numClasses = 10
	local classes = {
		[1] = "DEATHKNIGHT",
		[2] = "DRUID",
		[3] = "HUNTER",
		[4] = "MAGE",
		[5] = "PALADIN",
		[6] = "PRIEST",
		[7] = "ROGUE",
		[8] = "SHAMAN",
		[9] = "WARLOCK",
		[10] = "WARRIOR"
	}

	local rows = {}
	local classesPerRow = numClasses / KRC_Core.db.profile.cooldowns.numberOfRows

	local counter = 0
	local currRow = 0
	for i=1, numClasses do
		if(counter >= classesPerRow) then
			counter = 0
			currRow = currRow + 1
		end
		counter = counter + 1
		rows[classes[i]] = currRow
	end

	local currX = 0
	local currY = 0
	local thisRowY = 0
	local minY = 100000
	local prevClass = self.myActiveFrames[1].bar.ClassName

	local useRows = KRC_Core.db.profile.cooldowns.useRows

	for i = 1, numActiveFrames do
		local frame = self.myActiveFrames[i]

		local isNewClass = (frame.bar.ClassName == prevClass) == false
		if isNewClass then

			currY = currY - KRC_Core.db.profile.cooldowns.classSpacing
			-- First update MinY if needed, we'll use this to make sure
			-- that we dont intersect existing bars when we start a new row
			if(currY < minY) then
				minY = currY
			end

			local prevRow = rows[prevClass]
			local currRow = rows[frame.bar.ClassName]

			-- If the bars are on the same row we just advance the X and reset the Y
			if(prevRow == currRow) then
				currX = currX + frame:GetWidth() + detailsWidth
				currY = thisRowY
			else
				-- If the bars are *NOT* on the same row, then we need to reset X and advance Y
				currX = 0
				currY = minY - frame:GetHeight() - KRC_Core.db.profile.cooldowns.barSpacing
				thisRowY = currY
			end
			prevClass = frame.bar.ClassName
		elseif i > 1 then
			currY = currY - frame:GetHeight() - KRC_Core.db.profile.cooldowns.barSpacing
		end

		frame:SetPoint("TOPLEFT", self.DragableFrame, "TOPLEFT", currX, currY)
	end
end

local function CompareBars(aFrame, bFrame)
	local a = aFrame.bar
	local b = bFrame.bar
	if(a.ClassName ~= b.ClassName) then
		return a.ClassName < b.ClassName
	end

	if(a.SpellID ~= b.SpellID) then
		return a.SpellID < b.SpellID
	end

	return a.TimeRemaining < b.TimeRemaining
end

function KRC_Cooldowns:GetActiveBarIndex(aCasterName, aSpellID)
	
	local numActiveFrames = table.getn(self.myActiveFrames)
	for i = 1, numActiveFrames do
		local bar = self.myActiveFrames[i].bar

		if(bar.SpellID == aSpellID and bar.Caster == aCasterName) then
			return i
		end
	end

	return -1
end

function KRC_Cooldowns:SortBars()
	table.sort(self.myActiveFrames, CompareBars)
	self:RepositionBars()
end

function KRC_Cooldowns:UpdateBarProgress(aBar)
	local percent = aBar.TimeRemaining / aBar.CooldownTime
	aBar:SetValue(percent * 100)
	aBar.time.Text:SetFormattedText(SecondsToTimeDetail(aBar.TimeRemaining))
end

function KRC_Cooldowns:AddDetailedInformation(aFrame, aTargetName)

	aFrame.detailText:Hide()
	aFrame.detailIcon:Hide()

	if(KRC_Core.db.profile.cooldowns.enableExtraDetails == false) then
		return
	end

	local spellID = aFrame.bar.SpellID
	if(spellID == self.myAuraMasteryID) then
		local activeAura = KRC_PallyAuras:GetAuraNameForPally(aFrame.bar.Caster)
		if(activeAura ~= nil) then
			local _, _, icon = GetSpellInfo(activeAura)
			aFrame.detailIcon:SetTexture(icon)
		else
			aFrame.detailIcon:SetTexture(1.0, 0.0, 1.0)
		end

		aFrame.detailIcon:Show()
		return
	end

	if (self.myTargetedSpells[spellID] ~= nil) then
		aFrame.detailText.Text:SetText("(" .. aTargetName .. ")")
		aFrame.detailText:Show()
		return;
	end
end

function KRC_Cooldowns:ActivateBar(aCasterName, aCasterClass, aSpellName, aSpellID, aTime, aTargetName)
	if table.getn(self.myFreeFrames) > 0 then
		local frame = table.remove(self.myFreeFrames)
		local bar = frame.bar

		bar.lable.Text:SetText(aCasterName .. ": " .. aSpellName)

		local _, _, icon = GetSpellInfo(aSpellID)
		frame.icon:SetTexture(icon)

		bar.Caster = aCasterName
		bar.CooldownTime = aTime
		bar.TimeRemaining = aTime
		bar.SpellID = aSpellID
		bar.ClassName = aCasterClass

		local color = RAID_CLASS_COLORS[aCasterClass]
		bar:SetStatusBarColor(color.r, color.g, color.b)
		self:AddDetailedInformation(frame, aTargetName)
		self:UpdateBarProgress(bar)
		frame:Show()

		table.insert(self.myActiveFrames, frame)

		self:SortBars()

		return frame
	end
end

function KRC_Cooldowns:DeActivateBar(aFrame, aFrameIndex)
	aFrame.bar.TimeRemaining = 0
	aFrame:Hide()
	table.insert(self.myFreeFrames, aFrame)
	table.remove(self.myActiveFrames, aFrameIndex)
end

function KRC_Cooldowns:HandleGuardianSpirit(aEventType, aCasterName, aCasterClass, aSpellID, aSpellName, aTargetName)

	local activeBarIndex = self:GetActiveBarIndex(aCasterName, aSpellID)
	if(activeBarIndex ~= -1) then
			local frame = self.myActiveFrames[activeBarIndex]
		if(aEventType == "SPELL_HEAL") then
			frame.wasConsumed = true
		elseif (aEventType == "SPELL_AURA_REMOVED") then
			frame.hasFaded = true
			frame.fadeTime = GetTime()
		end

		return
	end

	cooldownTime = self.mySpells[aCasterClass][aSpellID]
	local frame = self:ActivateBar(aCasterName, aCasterClass, aSpellName, aSpellID, cooldownTime, aTargetName)
	frame.wasConsumed = false
	frame.hasFaded = false
	frame.cooldownWasReduced = false
	
end

function KRC_Cooldowns:CheckForReducedGuardianSpiritCD(aFrame)
	if(aFrame.wasConsumed == true) then
		return
	end

	if(aFrame.hasFaded == true and aFrame.cooldownWasReduced == false) then
		local timeSinceFaded = GetTime() - aFrame.fadeTime
		if(timeSinceFaded < 5) then
			return
		end

		aFrame.bar.TimeRemaining = 55
		aFrame.cooldownWasReduced = true
	end
end

function KRC_Cooldowns:OnSpellEvent(aEventType, aCasterName, aCasterClass, aSpellID, aSpellName, aTargetName, aWasAppliedAuraEvent)

	if KRC_Core.db.profile.cooldowns.activeSpells[aSpellID] == nil then
		return
	end

	if KRC_Core.db.profile.cooldowns.activeSpells[aSpellID] == false then
		return
	end

	if(aSpellID == self.myGuardianSpiritID and KRC_Core.db.profile.cooldowns.enableGSGlyphCheck == true) then
		self:HandleGuardianSpirit(aEventType, aCasterName, aCasterClass, aSpellID, aSpellName, aTargetName)
		return
	end

	if(self:GetActiveBarIndex(aCasterName, aSpellID) > -1) then
		return
	end

	local cooldownTime = nil
	if(aWasAppliedAuraEvent == true) then
		cooldownTime = self.myAuraAppliedSpells[aSpellID]
	else
		cooldownTime = self.mySpells[aCasterClass][aSpellID]
	end
	
	

	if cooldownTime ~= nil then
		self:ActivateBar(aCasterName, aCasterClass, aSpellName, aSpellID, cooldownTime, aTargetName)
	end
end

function KRC_Cooldowns:ResetPosition()
	KRC_Core.db.profile.cooldowns.bottomLeftX = 10
	KRC_Core.db.profile.cooldowns.bottomLeftY = 300
	self:SortBars()
end

function KRC_Cooldowns:ToggleDragableFrame(aValue)
	self.DragableFrame:SetMovable(aValue)
	self.DragableFrame:EnableMouse(aValue)
end

function KRC_Cooldowns:CreateDragableFrame()
	self.DragableFrame = CreateFrame("Frame")
	self.DragableFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", KRC_Core.db.profile.cooldowns.bottomLeftX, KRC_Core.db.profile.cooldowns.bottomLeftY)
	self.DragableFrame:SetWidth(KRC_Core.db.profile.cooldowns.barWidth + KRC_Core.db.profile.cooldowns.barHeight)
	self.DragableFrame:SetHeight(KRC_Core.db.profile.cooldowns.barHeight * KRC_Core.db.profile.cooldowns.maxNumBars)

	self.DragableFrame:RegisterForDrag("LeftButton")
	self.DragableFrame:SetScript("OnDragStart", self.DragableFrame.StartMoving)
	self.DragableFrame:SetScript("OnDragStop", function(aWidget)
		aWidget:StopMovingOrSizing()
		KRC_Core.db.profile.cooldowns.bottomLeftX = aWidget:GetLeft()
		KRC_Core.db.profile.cooldowns.bottomLeftY = aWidget:GetBottom()
	end)

end

function KRC_Cooldowns:GetRandomInTable(aTable)
	local counterTarget = 0
	for key,value in pairs(aTable) do 
		counterTarget = counterTarget + 1
	end

	counterTarget = math.random(counterTarget)
	local counter = 1
	for key,value in pairs(aTable) do 
		if(counter == counterTarget) then
			return key, value
		end

		counter = counter + 1
	end
end

function KRC_Cooldowns:Initialize()

	self:CreateDragableFrame()
	for i = 0, KRC_Core.db.profile.cooldowns.maxNumBars do
		table.insert(self.myFreeFrames, self:CreateBar(i))
	end
end

function KRC_Cooldowns:FillWithTestBars()
	local numFreeFrames = table.getn(self.myFreeFrames)
	for i = 0, numFreeFrames do
		local randomClass, spellTable = self:GetRandomInTable(self.mySpells)
		local randomSpell, spellCooldown = self:GetRandomInTable(spellTable)
		local spellName = GetSpellInfo(randomSpell)
		local cooldown = 15

		self:ActivateBar("Test", randomClass, spellName, randomSpell, cooldown, "Test")
	end
end

function KRC_Cooldowns:UpdateBars(aElasped)

	local i = 1
	local somethingWasRemoved = false
	while i <= table.getn(self.myActiveFrames) do
		local frame = self.myActiveFrames[i]
		local bar = frame.bar

		if(bar.TimeRemaining <= 0) then
			bar.TimeRemaining = 0
			frame:Hide()
			table.insert(self.myFreeFrames, frame)
			table.remove(self.myActiveFrames, i)
			somethingWasRemoved = true
		else
			if(bar.SpellID == self.myGuardianSpiritID and KRC_Core.db.profile.cooldowns.enableGSGlyphCheck == true) then
				self:CheckForReducedGuardianSpiritCD(frame)
			end

			bar.TimeRemaining = bar.TimeRemaining - 1
			self:UpdateBarProgress(bar)
			i = i + 1
		end
	end

	if somethingWasRemoved == true then
		self:SortBars()
	end
end