KRC_Spells = {}

KRC_Spells.myBloodlustID = UnitFactionGroup("player") == "Alliance" and 32182 or 2825
KRC_Spells.myAuraMasteryID = 31821
KRC_Spells.myGuardianSpiritID = 47788

KRC_Spells.mySpells = {
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
		[KRC_Spells.myBloodlustID] = 300, -- Bloodlust/Heroism
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
			["ShortName"] = "NS"
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
			["ShortName"] = "SS"
		},
		[13809] = {
			["Cooldown"] = 30,
			["Name"] = "Frost Trap",
			["ShortName"] = "FT"
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
			["ShortName"] = "AM"
		},
		[20216] = {
			["Cooldown"] = 120,
			["Name"] = "Divine Favor",
			["ShortName"] = "DF"
		},
		[31842] = {
			["Cooldown"] = 180,
			["Name"] = "Divine Illumination",
			["ShortName"] = "DI"
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
			["ShortName"] = "DSac"
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
			["Cooldown"] = 1200,
			["Name"] = "Lay on Hands",
			["ShortName"] = "LoH"
		},
		[66233] = {
			["Cooldown"] = 120,
			["Name"] = "Ardent Defender",
			["ShortName"] = "AD"
		}
	},
	PRIEST = {
		[33206] = {
			["Cooldown"] = 144,
			["Name"] = "Pain Suppression",
			["ShortName"] = "PS"
		},
		[47788] = {
			["Cooldown"] = 180,
			["Name"] = "Guardian Spirit",
			["ShortName"] = "GS"
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
			["ShortName"] = "PI"
		},
		[47585] = {
			["Cooldown"] = 180,
			["Name"] = "Dispersion",
			["ShortName"] = "Disp"
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
			["ShortName"] = "AR"
		},
		[13877] = {
			["Cooldown"] = 120,
			["Name"] = "Blade Flurry",
			["ShortName"] = "BF"
		},
		[14177] = {
			["Cooldown"] = 180,
			["Name"] = "Cold Blood",
			["ShortName"] = "CB"
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
			["ShortName"] = "Prep"
		},
		[36554] = {
			["Cooldown"] = 30,
			["Name"] = "Shadowstep",
			["ShortName"] = "SS"
		},
		[51690] = {
			["Cooldown"] = 120,
			["Name"] = "Killing Spree",
			["ShortName"] = "KS"
		},
		[51713] = {
			["Cooldown"] = 60,
			["Name"] = "Shadow Dance",
			["ShortName"] = "SD"
		},
		[14183] = {
			["Cooldown"] = 20,
			["Name"] = "Premeditation",
			["ShortName"] = "Prem"
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
			["ShortName"] = "NS"
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
			["ShortName"] = "Meta"
		},
		[18708] = {
			["Cooldown"] = 900,
			["Name"] = "Fel Domination",
			["ShortName"] = "FD"
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
			["ShortName"] = "LS"
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
			["ShortName"] = "RWep"
		},
		[49206] = {
			["Cooldown"] = 180,
			["Name"] = "Summon Gargoyle",
			["ShortName"] = "Garg"
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
			["ShortName"] = "UA"
		},
		[55233] = {
			["Cooldown"] = 60,
			["Name"] = "Vampiric Blood",
			["ShortName"] = "VB"
		},
		[49222] = {
			["Cooldown"] = 120,
			["Name"] = "Bone Shield",
			["ShortName"] = "BS"
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