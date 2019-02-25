KRC_Spells = {}

KRC_Spells.myBloodlustID = UnitFactionGroup("player") == "Alliance" and 32182 or 2825
KRC_Spells.myAuraMasteryID = 31821

KRC_Spells.mySpeccs = {
	DRUID = { ["Tank"] = 1, ["Heal"] = 1, ["DPS"] = 1 },
	HUNTER = { ["DPS"] = 1 },
	MAGE = { ["DPS"] = 1 },
	PALADIN = { ["Tank"] = 1, ["Heal"] = 1,  ["DPS"] = 1 },
	PRIEST = { ["Heal"] = 1, ["DPS"] = 1 },
	ROGUE = { ["DPS"] = 1 },
	SHAMAN = { ["Heal"] = 1,  ["DPS"] = 1 },
	WARLOCK = { ["DPS"] = 1 },
	WARRIOR = { ["Tank"] = 1,  ["DPS"] = 1 },
	DEATHKNIGHT = { ["Tank"] = 1,["DPS"] = 1 },
}

KRC_Spells.mySpells = {
	DRUID = {
		[48477] = { ["Name"] = "Rebirth", ["ShortName"] = "BR" },
		[29166] = { ["Name"] = "Innervate", ["ShortName"] = "Innerv" },
		[17116] = { ["Name"] = "Nature's Swiftness", ["ShortName"] = "NS" },
		[5209] = { ["Name"] = "Challenging Roar", ["ShortName"] = "CR" },
		[61336] = { ["Name"] = "Survival Instincts", ["ShortName"] = "SI" },
		[22812] = { ["Name"] = "Barkskin", ["ShortName"] = "BS" },
		[5229] = { ["Name"] = "Enrage", ["ShortName"] = "Enr" },
		[22842] = { ["Name"] = "Frenzied Regeneration", ["ShortName"] = "FR" }
	},
	HUNTER = {
		[34477] = { ["Name"] = "Misdirect", ["ShortName"] = "MD" },
		[5384] = { ["Name"] = "Feign Death", ["ShortName"] = "FD" },
		[62757] = {["Name"] = "Call Stabled Pet", ["ShortName"] = "Pet" },
		[781] = { ["Name"] = "Disengage", ["ShortName"] = "Dis" },
		[34490] = { ["Name"] = "Silencing Shot", ["ShortName"] = "SS" },
		[13809] = { ["Name"] = "Frost Trap", ["ShortName"] = "FT" },
		[19263] = { ["Name"] = "Deterrence", ["ShortName"] = "Det" },
		[23989] = { ["Name"] = "Readiness", ["ShortName"] = "Read" }
	},
	MAGE = {
		[45438] = { ["Name"] = "Iceblock", ["ShortName"] = "IB" },
		[2139] = { ["Name"] = "Counterspell", ["ShortName"] = "CS" },
		[31687] = { ["Name"] = "Summon Water Elemental", ["ShortName"] = "Pet" },
		[12051] = { ["Name"] = "Evocation", ["ShortName"] = "Evo" },
		[66] = { ["Name"] = "Invisibility", ["ShortName"] = "Invis" }
	},
	PALADIN = {
		[31821] = { ["Name"] = "Aura Mastery", ["ShortName"] = "AM" },
		[20216] = { ["Name"] = "Divine Favor", ["ShortName"] = "DF" },
		[31842] = { ["Name"] = "Divine Illumination", ["ShortName"] = "DI" },
		[19752] = { ["Name"] = "Divine Intervention", ["ShortName"] = "DI" },
		[642] = { ["Name"] = "Divine Shield", ["ShortName"] = "Bubble" },
		[64205] = { ["Name"] = "Divine Sacrifice", ["ShortName"] = "DSac" },
		[54428] = { ["Name"] = "Divine Plea", ["ShortName"] = "DP" },
		[498] = { ["Name"] = "Divine Protection", ["ShortName"] = "DP" },
		[1044] = { ["Name"] = "Hand of Freedom", ["ShortName"] = "HoF" },
		[10278] = { ["Name"] = "Hand of Protection", ["ShortName"] = "HoP" },
		[6940] = { ["Name"] = "Hand of Sacrifice", ["ShortName"] = "PSac" },
		[1038] = { ["Name"] = "Hand of Salvation", ["ShortName"] = "Salv" },
		[48788] = { ["Name"] = "Lay on Hands", ["ShortName"] = "LoH" },
		[66233] = { ["Name"] = "Ardent Defender", ["ShortName"] = "AD" }
	},
	PRIEST = {
		[33206] = { ["Name"] = "Pain Suppression",["ShortName"] = "PS" },
		[47788] = { ["Name"] = "Guardian Spirit", ["ShortName"] = "GS" },
		[6346] = { ["Name"] = "Fear Ward", ["ShortName"] = "FW" },
		[64843] = { ["Name"] = "Divine Hymn", ["ShortName"] = "DH" },
		[64901] = { ["Name"] = "Hymn of Hope", ["ShortName"] = "HoH" },
		[34433] = { ["Name"] = "Shadowfiend", ["ShortName"] = "Pet" },
		[10060] = { ["Name"] = "Power Infusion", ["ShortName"] = "PI" },
		[47585] = { ["Name"] = "Dispersion", ["ShortName"] = "Disp" }
	},
	ROGUE = {
		[31224] = { ["Name"] = "Cloak of Shadows", ["ShortName"] = "Cloak" },
		[38768] = { ["Name"] = "Kick", ["ShortName"] = "Kick" },
		[1725] = { ["Name"] = "Distract", ["ShortName"] = "Dist" },
		[13750] = { ["Name"] = "Adrenaline Rush", ["ShortName"] = "AR" },
		[13877] = { ["Name"] = "Blade Flurry", ["ShortName"] = "BF" },
		[14177] = { ["Name"] = "Cold Blood", ["ShortName"] = "CB" },
		[11305] = { ["Name"] = "Sprint", ["ShortName"] = "Sprint" },
		[26889] = { ["Name"] = "Vanish", ["ShortName"] = "Vanish" },
		[57934] = { ["Name"] = "Tricks of the Trade", ["ShortName"] = "ToT" },
		[2094] = { ["Name"] = "Blind", ["ShortName"] = "Blind" },
		[26669] = { ["Name"] = "Evasion", ["ShortName"] = "Eva" },
		[14185] = { ["Name"] = "Preparation", ["ShortName"] = "Prep" },
		[36554] = { ["Name"] = "Shadowstep", ["ShortName"] = "SS" },
		[51690] = { ["Name"] = "Killing Spree",["ShortName"] = "KS" },
		[51713] = { ["Name"] = "Shadow Dance", ["ShortName"] = "SD" },
		[14183] = { ["Name"] = "Premeditation", ["ShortName"] = "Prem" }
	},
	SHAMAN = {
		[KRC_Spells.myBloodlustID] = { ["Name"] = "Bloodlust", ["ShortName"] = "BL" },
		[20608] = { ["Name"] = "Reincarnation", ["ShortName"] = "Ankh" },
		[16190] = { ["Name"] = "Mana Tide Totem", ["ShortName"] = "Tide" },
		[2894] = { ["Name"] = "Fire Elemental Totem", ["ShortName"] = "FET" },
		[2062] = { ["Name"] = "Earth Elemental Totem", ["ShortName"] = "EET" },
		[16188] = { ["Name"] = "Nature's Swiftness", ["ShortName"] = "NS" },
		[57994] = { ["Name"] = "Wind Shear", ["ShortName"] = "WS" }
	},
	WARLOCK = {
		[6203] = { ["Name"] = "Soulstone", ["ShortName"] = "SS" },
		[29858] = { ["Name"] = "Soulshatter", ["ShortName"] = "Shatter" },
		[47241] = { ["Name"] = "Metamorphosis", ["ShortName"] = "Meta" },
		[18708] = { ["Name"] = "Fel Domination", ["ShortName"] = "FD" },
		[698] = { ["Name"] = "Ritual of Summoning", ["ShortName"] = "Sum" },
		[58887] = { ["Name"] = "Ritual of Souls", ["ShortName"] = "HS" }
	},
	WARRIOR = {
		[871] = { ["Name"] = "Shield Wall", ["ShortName"] = "Wall" },
		[1719] = { ["Name"] = "Recklessness", ["ShortName"] = "Reck" },
		[20230] = { ["Name"] = "Retaliation", ["ShortName"] = "Ret" },
		[12975] = { ["Name"] = "Last Stand", ["ShortName"] = "LS" },
		[6554] = { ["Name"] = "Pummel", ["ShortName"] = "Pummel" },
		[1161] = { ["Name"] = "Challenging Shout", ["ShortName"] = "CS" },
		[5246] = { ["Name"] = "Intimidating Shout", ["ShortName"] = "Fear" },
		[64380] = { ["Name"] = "Shattering Throw", ["ShortName"] = "Shatter" },
		[55694] = { ["Name"] = "Enraged Regeneration", ["ShortName"] = "Reg" },
		[72] = { ["Name"] = "Shield Bash", ["ShortName"] = "Bash" }
	},
	DEATHKNIGHT = {
		[48792] = { ["Name"] = "Icebound Fortitude", ["ShortName"] = "IF" },
		[42650] = { ["Name"] = "Army of the Dead", ["ShortName"] = "Army" },
		[61999] = { ["Name"] = "Raise Ally", ["ShortName"] = "Ally" },
		[49028] = { ["Name"] = "Dancing Rune Weapon", ["ShortName"] = "RWep", },
		[49206] = { ["Name"] = "Summon Gargoyle", ["ShortName"] = "Garg", },
		[47476] = { ["Name"] = "Strangulate", ["ShortName"] = "Stran" },
		[49576] = { ["Name"] = "Death Grip", ["ShortName"] = "Grip" },
		[51271] = { ["Name"] = "Unbreakable Armor", ["ShortName"] = "UA", },
		[55233] = { ["Name"] = "Vampiric Blood", ["ShortName"] = "VB", },
		[49222] = { ["Name"] = "Bone Shield", ["ShortName"] = "BS", },
		[47528] = { ["Name"] = "Mind Freeze", ["ShortName"] = "MF" },
		[48707] = { ["Name"] = "Anti-Magic Shell", ["ShortName"] = "AMS" }
	},
}

KRC_Spells.myPaladinAuras =
{
	{ ["SpellID"] = 48942, ["Name"] = "Devotion Aura", ["ShortName"] = "De"},
	{ ["SpellID"] = 54043, ["Name"] = "Retribution Aura", ["ShortName"] = "Re"},
	{ ["SpellID"] = 19746, ["Name"] = "Concentration Aura", ["ShortName"] = "Co"},
	{ ["SpellID"] = 48943, ["Name"] = "Shadow Resistance Aura", ["ShortName"] = "Sh"},
	{ ["SpellID"] = 48947, ["Name"] = "Fire Resistance Aura", ["ShortName"] = "Fi"},
	{ ["SpellID"] = 48945, ["Name"] = "Frost Resistance Aura", ["ShortName"] = "Fr"},
	{ ["SpellID"] = 32223, ["Name"] = "Crusader Aura", ["ShortName"] = "Cr"}
}

function KRC_Spells:GetShortName(aCasterClass, aSpellID)
	local classInfo = self.mySpells[aCasterClass]
	local spellInfo = classInfo[aSpellID]

	if(spellInfo == nil) then
		return nil
	end

	return spellInfo["ShortName"];
end

function KRC_Spells:IsAuraMastery(aSpellID)
	return aSpellID == self.myAuraMasteryID
end