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