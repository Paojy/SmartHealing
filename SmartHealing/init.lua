local addon_name, ns = ...

ns[1] = {} -- F, functions
ns[2] = {} -- G, globals

local F, G = unpack(ns)

Smarthealing = LibStub("AceAddon-3.0"):NewAddon("Smarthealing")

if not Smarthealing then return end

Smarthealing.RaidRoster = {}

if not Smarthealing.events then
	Smarthealing.events = LibStub("CallbackHandler-1.0"):New(Smarthealing)
end

function Smarthealing:OnUpdate(event, info)
	if not info.name or not info.spec_role or not info.spec_role_detailed then return end
	Smarthealing['RaidRoster'][info.name] = Smarthealing['RaidRoster'][info.name] or {}
	Smarthealing['RaidRoster'][info.name]["name"] = info.name
	Smarthealing['RaidRoster'][info.name]["role"] = info.spec_role_detailed
	Smarthealing['RaidRoster'][info.name]["class"] = info.class
end

function Smarthealing:OnRemove(guid)
	if (guid) then
	    local name = select(6, GetPlayerInfoByGUID(guid))
		if Smarthealing['RaidRoster'][name] then
			Smarthealing['RaidRoster'][name] = nil
		end
	else
		Smarthealing['RaidRoster'] = {}
	end
end

local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

function Smarthealing:OnInitialize()
	LGIST.RegisterCallback (Smarthealing, "GroupInSpecT_Update", function(event, ...)
		Smarthealing.OnUpdate(...)
	end)
	LGIST.RegisterCallback (Smarthealing, "GroupInSpecT_Remove", function(...)
		Smarthealing.OnRemove(...)
	end)
end

G.encounter = "none"
G.difficulty = "none"

G.Encounters = {
	[1810] = {	--"Test"
		["mode"] = "S",
	},
	
	[2076] = {	--"Worldbreaker"
		["mode"] = "S",
	},
	
	[2074] = {	--"Felhounds"
		["mode"] = "S",
		["debuffs"] = {
		    [GetSpellInfo(244768)] = 40, -- 荒芜凝视
		},
	},	
	
	[2070] = {	--"HighCommand"
		["mode"] = "G",
		["debuffs"] = {
			[GetSpellInfo(244737)] = 40, -- 震荡手雷
		},
	},	
	
	[2064] = {	--"Hasabel"
		["mode"] = "G",
	},
	
	[2075] = {	--"Eonar"
		["mode"] = "G",
		["debuffs"] = {
			[GetSpellInfo(248332)] = 30, -- 邪能之雨
		},
	},	
	
	[2082] = {	--"Imonar"
		["mode"] = "G",
	},	
	
	[2088] = {	--"Kingaroth"
		["mode"] = "G",
		["debuffs"] = {
		    [GetSpellInfo(245770)] = 40, -- 屠戮
			[GetSpellInfo(249686)] = 40, -- 轰鸣屠戮
		},
	},	
	
	[2069] = {	--"Varimathras"
		["mode"] = "G",
		["debuffs"] = {
			[GetSpellInfo(244094)] = 50, -- 冥魂之拥		
		},
	},	
	
	[2073] = {	--"CovenofShivarra"
		["mode"] = "S",
		["debuffs"] = {
		    [GetSpellInfo(253520)] = 70, -- 爆裂脉冲
			[GetSpellInfo(250757)] = 60, -- 宇宙之光
		},
	},	
	
	[2063] = {	--"Aggramar"
		["mode"] = "S",
		["debuffs"] = {
		    [GetSpellInfo(254452)] = 70, -- 饕餮烈焰
		},
	},	
	
	[2092] = {	--"Argus"
		["mode"] = "G",
		["debuffs"] = {
		    [GetSpellInfo(248396)] = 40, -- 灵魂凋零
			[GetSpellInfo(250669)] = 40, -- 灵魂爆发
			[GetSpellInfo(252729)] = 40, -- 宇宙射线
		},
	},	
	
	["none"] = {
		["mode"] = "G",
	},
}

G.Buffs = {
	["ALL"] = {
		[GetSpellInfo(33206)]  = 40, -- 痛苦压制
        [GetSpellInfo(47788)]  = 80, -- 守护之魂
		[GetSpellInfo(102342)] = 30, -- 铁木树皮
	},
	["DRUID"] = {--小德                       
		[GetSpellInfo(22812)]  = 20, -- 树皮术
		[GetSpellInfo(61336)]  = 50, -- 生存本能
	},
	["PALADIN"] = {--骑士                       
		[GetSpellInfo(1022)]   = 95, -- 保护之手
		[GetSpellInfo(31850)]  = 80, -- 炽热防御者
        [GetSpellInfo(498)]    = 20, -- 圣佑术
		[GetSpellInfo(642)]    = 95, -- 圣盾术
		[GetSpellInfo(86659)]  = 50, -- 远古列王守卫
	},
	["DEATHKNIGHT"] = {--DK
		[GetSpellInfo(48792)]  = 20, -- 冰封之韧
		[GetSpellInfo(49028)]  = 50, -- 吸血鬼之血
		[GetSpellInfo(55233)]  = 40, -- 符文刃舞
	},
	["WARRIOR"] = {--战士
		[GetSpellInfo(871)]    = 40, -- 盾墙
		[GetSpellInfo(184364)] = 30, -- 狂怒回复
	},
	["DEMONHUNTER"] = {--DH                             
		[GetSpellInfo(196555)] = 95, -- 虚空行走 浩劫
	},
	["HUNTER"] = {--猎人                           
		[GetSpellInfo(186265)] = 80, -- 灵龟守护
	},
	["ROGUE"] = {--盗贼                           
		[GetSpellInfo(31224)]  = 95, -- 暗影斗篷
		[GetSpellInfo(1966)]   = 40, -- 佯攻
	},
	["WARLOCK"] = {--术士                           
		[GetSpellInfo(104773)] = 40, -- 不灭决心
	},
	["MAGE"] = {--法师                           
		[GetSpellInfo(45438)]  = 95, -- 寒冰屏障
	},
	["MONK"] = {--武僧                       
		[GetSpellInfo(115203)] = 40, -- 壮胆酒    
		[GetSpellInfo(122470)] = 30, -- 业报之触
		[GetSpellInfo(122783)] = 50, -- 散魔功
	},
	["SHAMAN"] = {--萨满                           
		[GetSpellInfo(108271)] = 40, -- 星界转移
	},
}

local function UpdateSurvival(parentFrame, text)
	if not parentFrame.stext then
		parentFrame.stext = parentFrame:CreateFontString(nil, "OVERLAY")
		parentFrame.stext:SetFont("Interface\\AddOns\\Aurora\\media\\font.TTF", 12, "OUTLINE")
		parentFrame.stext:SetPoint("TOP", parentFrame, "TOP")
	end
	parentFrame.stext:SetText(text)
end

local function UpdateSurvivalOnRF(name)
    local hasAltzUI = _G["Altz_HealerRaid"] and _G["Altz_HealerRaid"]:IsVisible()
    
    if hasAltzUI then
        for i = 1, 40 do
            local f = _G["Altz_HealerRaidUnitButton"..i]
            if f and f.unit and UnitName(f.unit) == name then
                UpdateSurvival(f, Smarthealing['RaidRoster'][name]["sur"])
                return
            end
        end
    end
end

local GroupUpdater = CreateFrame("Frame")

GroupUpdater:RegisterEvent("GROUP_ROSTER_UPDATE")
GroupUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
GroupUpdater:RegisterEvent("UNIT_HEALTH")
GroupUpdater:RegisterEvent("UNIT_HEALTH_FREQUENT")
GroupUpdater:RegisterEvent("UNIT_MAXHEALTH")
GroupUpdater:RegisterEvent("UNIT_AURA")
GroupUpdater:RegisterEvent("UNIT_HEAL_PREDICTION")
GroupUpdater:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
GroupUpdater:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
GroupUpdater:RegisterEvent("UNIT_CONNECTION")
GroupUpdater:RegisterEvent("ENCOUNTER_START")
GroupUpdater:RegisterEvent("ENCOUNTER_END")

GroupUpdater.UpdateInRange = function(name)
	Smarthealing['RaidRoster'][name]["inRange"] = UnitInRange(name)
end

GroupUpdater.UpdateActive = function(name)
	if not (UnitIsDead(name) or UnitIsGhost(name)) and UnitIsConnected(name) then
		Smarthealing['RaidRoster'][name]["active"] = true
	else
		Smarthealing['RaidRoster'][name]["active"] = false
	end
end

GroupUpdater.UpdateHealth = function(name)

	local hp = UnitHealth(name)
	local hp_max = UnitHealthMax(name)
	local hp_incoming = UnitGetIncomingHeals(name) or 0
	local heal_absorb = UnitGetTotalHealAbsorbs(name) or 0
		
	if hp and hp_max and hp_max > 0 then		
		Smarthealing['RaidRoster'][name]["hp"] = UnitHealth(name)
		Smarthealing['RaidRoster'][name]["hp_max"] = UnitHealthMax(name)	
		Smarthealing['RaidRoster'][name]["hp_perc"] = floor((hp + hp_incoming - heal_absorb)/hp_max*100)
	end
end

GroupUpdater.UpdateSurvival = function(name)

	local buff_effect, debuff_effect = 0, 0
	local class = Smarthealing['RaidRoster'][name]["class"]
	local hp = UnitHealth(name)
	local hp_max = UnitHealthMax(name)
	local hp_incoming = UnitGetIncomingHeals(name) or 0
	local hp_absorb = UnitGetTotalAbsorbs(name) or 0
	local heal_absorb = UnitGetTotalHealAbsorbs(name) or 0
	
	if hp and hp_max and hp_max > 0 then
	
		for debuff, effect in pairs(G.Encounters[G.encounter]) do
			if UnitDebuff(name, debuff) then
				debuff_effect = debuff_effect + effect
			end
		end
		
		for buff, effect in pairs(G.Buffs["ALL"]) do
			if UnitBuff(name, buff) then
				buff_effect = buff_effect + effect
			end
		end
		
		if G.Buffs[class] then
			for buff, effect in pairs(G.Buffs[class]) do
				if UnitBuff(name, buff) then
					buff_effect = buff_effect + effect
				end
			end
		end
		
		Smarthealing['RaidRoster'][name]["sur"] = floor((hp + hp_incoming*.7 + hp_absorb - heal_absorb)/hp_max*100) - debuff_effect + buff_effect
		UpdateSurvivalOnRF(name)
	end
end

GroupUpdater:SetScript("OnEvent", function(self, event, ...)
	if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			GroupUpdater.UpdateActive(name)
			GroupUpdater.UpdateHealth(name)
			GroupUpdater.UpdateSurvival(name)
			GroupUpdater.UpdateInRange(name)
		end
	elseif event == "UNIT_CONNECTION" then
		local unit = ...
		local name = UnitName(unit)
		if Smarthealing['RaidRoster'][name] then
			GroupUpdater.UpdateActive(name)
		end
	elseif event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_MAXHEALTH" then
		local unit = ...
		local name = UnitName(unit)
		if Smarthealing['RaidRoster'][name] then
			GroupUpdater.UpdateActive(name)
			GroupUpdater.UpdateHealth(name)
			GroupUpdater.UpdateSurvival(name)
		end
	elseif event == "UNIT_AURA" or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
		local unit = ...
		local name = UnitName(unit)
		if Smarthealing['RaidRoster'][name] then
			GroupUpdater.UpdateSurvival(name)
		end
	elseif event == "ENCOUNTER_START" then
		local encounterID, encounterName, difficultyID, groupSize = ...
		if G.Encounters[encounterID] then
			G.encounter = encounterID
			G.difficulty = difficultyID
		end
	elseif event == "ENCOUNTER_END" then
		encounter = "none"
		difficulty = "none"
	end
end)

GroupUpdater.t = 0
GroupUpdater:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > 0.2 then	
		for name, info in pairs(Smarthealing['RaidRoster']) do
			GroupUpdater.UpdateInRange(name)
		end		
		self.t = 0
	end
end)