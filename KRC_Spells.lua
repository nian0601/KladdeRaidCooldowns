KRC_Spells = {}

KRC_Spells.myBloodlustID = UnitFactionGroup("player") == "Alliance" and 32182 or 2825
KRC_Spells.myAuraMasteryID = 31821
KRC_Spells.myGuardianSpiritID = 47788
KRC_Spells.myReadinessID = 23989
KRC_Spells.myMisdirectionID = 34477
KRC_Spells.myTricksOfTheTradeID = 57934

KRC_Spells.mySpeccs = {
	DRUID = {["Tank"] = 1, ["Heal"] = 1, ["DPS"] = 1},
	HUNTER = {["DPS"] = 1},
	MAGE = {["DPS"] = 1},
	PALADIN = {["Tank"] = 1, ["Heal"] = 1, ["DPS"] = 1},
	PRIEST = {["Heal"] = 1, ["DPS"] = 1},
	ROGUE = {["DPS"] = 1},
	SHAMAN = {["Heal"] = 1, ["DPS"] = 1},
	WARLOCK = {["DPS"] = 1},
	WARRIOR = {["Tank"] = 1, ["DPS"] = 1},
	DEATHKNIGHT = {["Tank"] = 1, ["DPS"] = 1},
}

KRC_Spells.mySpells = {
	DRUID = {
		[48477] = {
			["Cooldown"] = 600,
			["Name"] = "Rebirth",
			["ShortName"] = "BR"
		},
		[29166] = {
			["Cooldown"] = 180,
			["Name"] = "Innervate",
			["ShortName"] = "Innerv"
		},
		[17116] = {
			["Cooldown"] = 180,
			["Name"] = "Nature's Swiftness",
			["ShortName"] = "NS",
			["TalentRequirement"] = "Resto"
		},
		[5209] = {
			["Cooldown"] = 180,
			["Name"] = "Challenging Roar",
			["ShortName"] = "CR"
		},
		[61336] = {
			["Cooldown"] = 180,
			["Name"] = "Survival Instincts",
			["ShortName"] = "SI"
		},
		[22812] = {
			["Cooldown"] = 60,
			["Name"] = "Barkskin",
			["ShortName"] = "BS"
		}
	},
	HUNTER = {
		[34477] = {
			["Cooldown"] = 30,
			["Name"] = "Misdirect",
			["ShortName"] = "MD"
		},
		[5384] = {
			["Cooldown"] = 30,
			["Name"] = "Feign Death",
			["ShortName"] = "FD"
		},
		[62757] = {
			["Cooldown"] = 300,
			["Name"] = "Call Stabled Pet",
			["ShortName"] = "Pet"
		},
		[781] = {
			["Cooldown"] = 25,
			["Name"] = "Disengage",
			["ShortName"] = "Dis"
		},
		[34490] = {
			["Cooldown"] = 20,
			["Name"] = "Silencing Shot",
			["ShortName"] = "SS",
			["TalentRequirement"] = "Marksmanship"
		},
		[13809] = {
			["Cooldown"] = 30,
			["Name"] = "Frost Trap",
			["ShortName"] = "FT"
		},
		[19263] = {
			["Cooldown"] = 90,
			["Name"] = "Deterrence",
			["ShortName"] = "Det"
		},
		[23989] = {
			["Cooldown"] = 180,
			["Name"] = "Readiness",
			["ShortName"] = "Read"
		}
	},
	MAGE = {
		[45438] = {
			["Cooldown"] = 300,
			["Name"] = "Iceblock",
			["ShortName"] = "IB"
		},
		[2139] = {
			["Cooldown"] = 24,
			["Name"] = "Counterspell",
			["ShortName"] = "CS"
		},
		[31687] = {
			["Cooldown"] = 180,
			["Name"] = "Summon Water Elemental",
			["ShortName"] = "Pet"
		},
		[12051] = {
			["Cooldown"] = 240,
			["Name"] = "Evocation",
			["ShortName"] = "Evo"
		},
		[66] = {
			["Cooldown"] = 180,
			["Name"] = "Invisibility",
			["ShortName"] = "Invis"
		}
	},
	PALADIN = {
		[31821] = {
			["Cooldown"] = 120,
			["Name"] = "Aura Mastery",
			["ShortName"] = "AM",
			["TalentRequirement"] = "Holy, Retribution"
		},
		[20216] = {
			["Cooldown"] = 120,
			["Name"] = "Divine Favor",
			["ShortName"] = "DF",
			["TalentRequirement"] = "Holy"
		},
		[31842] = {
			["Cooldown"] = 180,
			["Name"] = "Divine Illumination",
			["ShortName"] = "DI",
			["TalentRequirement"] = "Holy"
		},
		[19752] = {
			["Cooldown"] = 600,
			["Name"] = "Divine Intervention",
			["ShortName"] = "DI"
		},
		[642] = {
			["Cooldown"] = 300,
			["Name"] = "Divine Shield",
			["ShortName"] = "Bubble"
		},
		[64205] = {
			["Cooldown"] = 120,
			["Name"] = "Divine Sacrifice",
			["ShortName"] = "DSac",
			["TalentRequirement"] = "Holy, Protection"
		},
		[54428] = {
			["Cooldown"] = 60,
			["Name"] = "Divine Plea",
			["ShortName"] = "DP"
		},
		[498] = {
			["Cooldown"] = 180,
			["Name"] = "Divine Protection",
			["ShortName"] = "DP"
		},
		[1044] = {
			["Cooldown"] = 25,
			["Name"] = "Hand of Freedom",
			["ShortName"] = "HoF"
		},
		[10278] = {
			["Cooldown"] = 300,
			["Name"] = "Hand of Protection",
			["ShortName"] = "HoP"
		},
		[6940] = {
			["Cooldown"] = 120,
			["Name"] = "Hand of Sacrifice",
			["ShortName"] = "PSac"
		},
		[1038] = {
			["Cooldown"] = 120,
			["Name"] = "Hand of Salvation",
			["ShortName"] = "Salv"
		},
		[48788] = {
			["Cooldown"] = 660,
			["Name"] = "Lay on Hands",
			["ShortName"] = "LoH"
		},
		[66233] = {
			["Cooldown"] = 120,
			["Name"] = "Ardent Defender",
			["ShortName"] = "AD",
			["TalentRequirement"] = "Protection"
		}
	},
	PRIEST = {
		[33206] = {
			["Cooldown"] = 144,
			["Name"] = "Pain Suppression",
			["ShortName"] = "PS",
			["TalentRequirement"] = "Discipline"
		},
		[47788] = {
			["Cooldown"] = 180,
			["Name"] = "Guardian Spirit",
			["ShortName"] = "GS",
			["TalentRequirement"] = "Holy"
		},
		[6346] = {
			["Cooldown"] = 180,
			["Name"] = "Fear Ward",
			["ShortName"] = "FW"
		},
		[64843] = {
			["Cooldown"] = 480,
			["Name"] = "Divine Hymn",
			["ShortName"] = "DH"
		},
		[64901] = {
			["Cooldown"] = 360,
			["Name"] = "Hymn of Hope",
			["ShortName"] = "HoH"
		},
		[34433] = {
			["Cooldown"] = 300,
			["Name"] = "Shadowfiend",
			["ShortName"] = "Pet"
		},
		[10060] = {
			["Cooldown"] = 96,
			["Name"] = "Power Infusion",
			["ShortName"] = "PI",
			["TalentRequirement"] = "Discipline"
		},
		[47585] = {
			["Cooldown"] = 180,
			["Name"] = "Dispersion",
			["ShortName"] = "Disp",
			["TalentRequirement"] = "Shadow"
		}
	},
	ROGUE = {
		[31224] = {
			["Cooldown"] = 90,
			["Name"] = "Cloak of Shadows",
			["ShortName"] = "Cloak"
		},
		[38768] = {
			["Cooldown"] = 10,
			["Name"] = "Kick",
			["ShortName"] = "Kick"
		},
		[1725] = {
			["Cooldown"] = 30,
			["Name"] = "Distract",
			["ShortName"] = "Dist"
		},
		[13750] = {
			["Cooldown"] = 180,
			["Name"] = "Adrenaline Rush",
			["ShortName"] = "AR",
			["TalentRequirement"] = "Combat"
		},
		[13877] = {
			["Cooldown"] = 120,
			["Name"] = "Blade Flurry",
			["ShortName"] = "BF",
			["TalentRequirement"] = "Combat"
		},
		[14177] = {
			["Cooldown"] = 180,
			["Name"] = "Cold Blood",
			["ShortName"] = "CB",
			["TalentRequirement"] = "Assasination"
		},
		[11305] = {
			["Cooldown"] = 180,
			["Name"] = "Sprint",
			["ShortName"] = "Sprint"
		},
		[26889] = {
			["Cooldown"] = 180,
			["Name"] = "Vanish",
			["ShortName"] = "Vanish"
		},
		[57934] = {
			["Cooldown"] = 30,
			["Name"] = "Tricks of the Trade",
			["ShortName"] = "ToT"
		},
		[2094] = {
			["Cooldown"] = 180,
			["Name"] = "Blind",
			["ShortName"] = "Blind"
		},
		[26669] = {
			["Cooldown"] = 180,
			["Name"] = "Evasion",
			["ShortName"] = "Eva"
		},
		[14185] = {
			["Cooldown"] = 480,
			["Name"] = "Preparation",
			["ShortName"] = "Prep",
			["TalentRequirement"] = "Subtely"
		},
		[36554] = {
			["Cooldown"] = 30,
			["Name"] = "Shadowstep",
			["ShortName"] = "SS",
			["TalentRequirement"] = "Subtely"
		},
		[51690] = {
			["Cooldown"] = 120,
			["Name"] = "Killing Spree",
			["ShortName"] = "KS",
			["TalentRequirement"] = "Combat"
		},
		[51713] = {
			["Cooldown"] = 60,
			["Name"] = "Shadow Dance",
			["ShortName"] = "SD",
			["TalentRequirement"] = "Subtely"
		},
		[14183] = {
			["Cooldown"] = 20,
			["Name"] = "Premeditation",
			["ShortName"] = "Prem",
			["TalentRequirement"] = "Subtely"
		}
	},
	SHAMAN = {
		[KRC_Spells.myBloodlustID] = {
			["Cooldown"] = 300,
			["Name"] = "Bloodlust",
			["ShortName"] = "BL"
		},
		[20608] = {
			["Cooldown"] = 1800,
			["Name"] = "Reincarnation",
			["ShortName"] = "Ankh"
		},
		[16190] = {
			["Cooldown"] = 300,
			["Name"] = "Mana Tide Totem",
			["ShortName"] = "Tide"
		},
		[2894] = {
			["Cooldown"] = 600,
			["Name"] = "Fire Elemental Totem",
			["ShortName"] = "FET"
		},
		[2062] = {
			["Cooldown"] = 600,
			["Name"] = "Earth Elemental Totem",
			["ShortName"] = "EET"
		},
		[16188] = {
			["Cooldown"] = 180,
			["Name"] = "Nature's Swiftness",
			["ShortName"] = "NS",
			["TalentRequirement"] = "Resto"
		},
		[57994] = {
			["Cooldown"] = 6,
			["Name"] = "Wind Shear",
			["ShortName"] = "WS"
		}
	},
	WARLOCK = {
		[6203] = {
			["Cooldown"] = 900,
			["Name"] = "Soulstone",
			["ShortName"] = "SS"
		},
		[29858] = {
			["Cooldown"] = 180,
			["Name"] = "Soulshatter",
			["ShortName"] = "Shatter"
		},
		[47241] = {
			["Cooldown"] = 180,
			["Name"] = "Metamorphosis",
			["ShortName"] = "Meta",
			["TalentRequirement"] = "Demonology"
		},
		[18708] = {
			["Cooldown"] = 900,
			["Name"] = "Fel Domination",
			["ShortName"] = "FD",
			["TalentRequirement"] = "Demonology"
		},
		[698] = {
			["Cooldown"] = 120,
			["Name"] = "Ritual of Summoning",
			["ShortName"] = "Sum"
		},
		[58887] = {
			["Cooldown"] = 300,
			["Name"] = "Ritual of Souls",
			["ShortName"] = "HS"
		}
	},
	WARRIOR = {
		[871] = {
			["Cooldown"] = 300,
			["Name"] = "Shield Wall",
			["ShortName"] = "Wall"
		},
		[1719] = {
			["Cooldown"] = 300,
			["Name"] = "Recklessness",
			["ShortName"] = "Reck"
		},
		[20230] = {
			["Cooldown"] = 300,
			["Name"] = "Retaliation",
			["ShortName"] = "Ret"
		},
		[12975] = {
			["Cooldown"] = 180,
			["Name"] = "Last Stand",
			["ShortName"] = "LS",
			["TalentRequirement"] = "Protection"
		},
		[6554] = {
			["Cooldown"] = 10,
			["Name"] = "Pummel",
			["ShortName"] = "Pummel"
		},
		[1161] = {
			["Cooldown"] = 180,
			["Name"] = "Challenging Shout",
			["ShortName"] = "CS"
		},
		[5246] = {
			["Cooldown"] = 180,
			["Name"] = "Intimidating Shout",
			["ShortName"] = "Fear"
		},
		[64380] = { -- could be 64382???
			["Cooldown"] = 300,
			["Name"] = "Shattering Throw",
			["ShortName"] = "Shatter"
		},
		[55694] = {
			["Cooldown"] = 180,
			["Name"] = "Enraged Regeneration",
			["ShortName"] = "Reg"
		},
		[72] = {
			["Cooldown"] = 12,
			["Name"] = "Shield Bash",
			["ShortName"] = "Bash"
		}
	},
	DEATHKNIGHT = {
		[48792] = {
			["Cooldown"] = 120,
			["Name"] = "Icebound Fortitude",
			["ShortName"] = "IF"
		},
		[42650] = {
			["Cooldown"] = 600,
			["Name"] = "Army of the Dead",
			["ShortName"] = "Army"
		},
		[61999] = {
			["Cooldown"] = 600,
			["Name"] = "Raise Ally",
			["ShortName"] = "Ally"
		},
		[49028] = {
			["Cooldown"] = 90,
			["Name"] = "Dancing Rune Weapon",
			["ShortName"] = "RWep",
			["TalentRequirement"] = "Blood"
		},
		[49206] = {
			["Cooldown"] = 180,
			["Name"] = "Summon Gargoyle",
			["ShortName"] = "Garg",
			["TalentRequirement"] = "Unholy"
		},
		[47476] = {
			["Cooldown"] = 120,
			["Name"] = "Strangulate",
			["ShortName"] = "Stran"
		},
		[49576] = {
			["Cooldown"] = 35,
			["Name"] = "Death Grip",
			["ShortName"] = "Grip"
		},
		[51271] = {
			["Cooldown"] = 120,
			["Name"] = "Unbreakable Armor",
			["ShortName"] = "UA",
			["TalentRequirement"] = "Frost"
		},
		[55233] = {
			["Cooldown"] = 60,
			["Name"] = "Vampiric Blood",
			["ShortName"] = "VB",
			["TalentRequirement"] = "Blood"
		},
		[49222] = {
			["Cooldown"] = 120,
			["Name"] = "Bone Shield",
			["ShortName"] = "BS",
			["TalentRequirement"] = "Unholy"
		},
		[47528] = {
			["Cooldown"] = 10,
			["Name"] = "Mind Freeze",
			["ShortName"] = "MF"
		},
		[48707] = {
			["Cooldown"] = 45,
			["Name"] = "Anti-Magic Shell",
			["ShortName"] = "AMS"
		}
	},
}

KRC_Spells.myTargetedSpells = {
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

KRC_Spells.myPaladinAuras =
{
	{ ["SpellID"] = 48942, ["Name"] = "Devotion Aura"},
	{ ["SpellID"] = 54043, ["Name"] = "Retribution Aura"},
	{ ["SpellID"] = 19746, ["Name"] = "Concentration Aura"},
	{ ["SpellID"] = 48943, ["Name"] = "Shadow Resistance Aura"},
	{ ["SpellID"] = 48947, ["Name"] = "Fire Resistance Aura"},
	{ ["SpellID"] = 48945, ["Name"] = "Frost Resistance Aura"},
	{ ["SpellID"] = 32223, ["Name"] = "Crusader Aura"}
}

function KRC_Spells:GetSpellCD(aCasterName, aCasterClass, aSpellID)
	-- We should check for CD-reducing talents here, thats why we pass in aCaster
	-- We'll need some way of getting the raid-ID for the caster,
	-- just iterating through all raidmembers and comparing names should do the trick
	-- But maybe we should just cache this data somewhere?

	local classInfo = self.mySpells[aCasterClass]
	local spellInfo = classInfo[aSpellID]

	-- Could just return cooldown right away, but I want to make it clear that we're returning nil if the
	-- spell doesnt exist
	if(spellInfo == nil) then
		return nil
	end
	
	return spellInfo["Cooldown"];
end

function KRC_Spells:GetShortName(aCasterClass, aSpellID)
	local classInfo = self.mySpells[aCasterClass]
	local spellInfo = classInfo[aSpellID]

	if(spellInfo == nil) then
		return nil
	end

	return spellInfo["ShortName"];
end

function KRC_Spells:SpellIsTargeted(aSpellID)
	if(self.myTargetedSpells[aSpellID] == nil) then
		return false
	end

	return true
end

function KRC_Spells:IsAuraMastery(aSpellID)
	return aSpellID == self.myAuraMasteryID
end

function KRC_Spells:IsGuardianSpirit(aSpellID)
	return aSpellID == self.myGuardianSpiritID
end

function KRC_Spells:IsReadiness(aSpellID)
	return aSpellID == self.myReadinessID
end

function KRC_Spells:IsMisdirection(aSpellID)
	return aSpellID == self.myMisdirectionID
end

function KRC_Spells:IsTricksOfTheTrade(aSpellID)
	return aSpellID == self.myTricksOfTheTradeID
end

function KRC_Spells:CanCastSpell(aSpellID, aClass, aUnitID)
	local classInfo = self.mySpells[aClass]
	local spellInfo = classInfo[aSpellID]

	if(spellInfo == nil) then
		return false
	end

	if(spellInfo["CheckTalent"] == nil) then
		return true
	end

	return spellInfo["CheckTalent"](aUnitID)
end