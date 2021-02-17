local addon_name, ns = ...
local F, G, L = unpack(ns)

if not G.Healers[G.myClass] then return end

Smarthealing = LibStub("AceAddon-3.0"):NewAddon("Smarthealing")

if not Smarthealing then return end

Smarthealing.RaidRoster = {}

if not Smarthealing.events then
	Smarthealing.events = LibStub("CallbackHandler-1.0"):New(Smarthealing)
end

G.encounter = "none"
G.difficulty = "none"

G.Encounters = {
	[2076] = {	--"Worldbreaker"
	},
	
	[2074] = {	--"Felhounds"
		["debuffs"] = {
		    [GetSpellInfo(244768)] = 40, -- 荒芜凝视
			[GetSpellInfo(244091)] = 60, --烧焦
			[GetSpellInfo(248815)] = 30, --燃烧腐蚀

		},
	},	
	
	[2070] = {	--"HighCommand"
		["debuffs"] = {
			[GetSpellInfo(244737)] = 40, -- 震荡手雷
			[GetSpellInfo(244172)] = 50, --灵能突袭
			[GetSpellInfo(253037)] = 50, --恶魔冲锋
		},
	},	
	
	[2064] = {	--"Hasabel"
		["debuffs"] = {
			[GetSpellInfo(244613)] = 20, -- 永燃烈焰
			[GetSpellInfo(244849)] = 20, -- 腐蚀烂泥
			[GetSpellInfo(245075)] = 20, -- 饥饿幽影
			[GetSpellInfo(245118)] = 20, -- 饱足幽影
		},	
	},
	
	[2075] = {	--"Eonar"
		["debuffs"] = {
			[GetSpellInfo(248332)] = 30, -- 邪能之雨
		},
	},	
	
	[2082] = {	--"Imonar"
		["debuffs"] = {
			[GetSpellInfo(250006)] = 25, -- 强化脉冲手雷
			[GetSpellInfo(247716)] = 25, -- 充能轰炸
			[GetSpellInfo(247932)] = 25, -- 霰弹爆破
			[GetSpellInfo(248070)] = 25, -- 强化霰弹爆破
			[GetSpellInfo(248321)] = 25, -- 洪荒烈火
			[GetSpellInfo(248255)] = 25, -- 地狱火火箭
		},
	},	
	
	[2088] = {	--"Kingaroth"
		["debuffs"] = {
		    [GetSpellInfo(245770)] = 40, -- 屠戮
			[GetSpellInfo(249686)] = 40, -- 轰鸣屠戮
		},
	},	
	
	[2069] = {	--"Varimathras"
		["debuffs"] = {
			[GetSpellInfo(244094)] = 50, -- 冥魂之拥		
		},
	},	
	
	[2073] = {	--"CovenofShivarra"
		["debuffs"] = {
		    [GetSpellInfo(253520)] = 70, -- 爆裂脉冲
			[GetSpellInfo(250757)] = 60, -- 宇宙之光
		},
	},	
	
	[2063] = {	--"Aggramar"
		["debuffs"] = {
			[GetSpellInfo(245994)] = 40, -- 灼热之焰
		    [GetSpellInfo(254452)] = 70, -- 饕餮烈焰
		},
	},	
	
	[2092] = {	--"Argus"
		["debuffs"] = {
		    [GetSpellInfo(248396)] = 40, -- 灵魂凋零
			[GetSpellInfo(250669)] = 40, -- 灵魂爆发
			[GetSpellInfo(251570)] = 40, -- 灵魂炸弹
			[GetSpellInfo(252729)] = 40, -- 宇宙射线
		},
	},	
	
	["none"] = {
		["debuffs"] = {
		    [GetSpellInfo(240559)] = 40, -- 重伤
			[GetSpellInfo(243237)] = 40, -- 死疽
		},
		["spells"] = {
			[17] = {event = "SPELL_CAST_SUCCESS", delay = 3, dur = 5, target = "healer"}
		}
	},
}

local function UpdateText(parentFrame, text)
	if not parentFrame.stext then
		parentFrame.stext = parentFrame:CreateFontString(nil, "OVERLAY")
		parentFrame.stext:SetFontObject(GameFontHighlight)
		parentFrame.stext:SetPoint("LEFT", parentFrame, "RIGHT", 10, 0)
	end
	parentFrame.stext:SetText(text)
end

local function UpdateTextOnRF(name, text)
	if not SH_CDB["Layout"]["test"] then return end
	
    local hasAltzUI = _G["Altz_HealerRaid"] and _G["Altz_HealerRaid"]:IsVisible()
    
    if hasAltzUI then
        for i = 1, 40 do
            local f = _G["Altz_HealerRaidUnitButton"..i]
            if f and f.unit and UnitName(f.unit) == name then
                UpdateText(f, text)
                return
            end
        end
    end
end

local GroupUpdater = CreateFrame("Frame")

GroupUpdater:RegisterEvent("GROUP_ROSTER_UPDATE")
GroupUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
GroupUpdater:RegisterEvent("UNIT_HEALTH")
GroupUpdater:RegisterEvent("UNIT_MAXHEALTH")
GroupUpdater:RegisterEvent("UNIT_AURA")
GroupUpdater:RegisterEvent("UNIT_HEAL_PREDICTION")
GroupUpdater:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
GroupUpdater:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
GroupUpdater:RegisterEvent("UNIT_CONNECTION")
GroupUpdater:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
GroupUpdater:RegisterEvent("ENCOUNTER_START")
GroupUpdater:RegisterEvent("ENCOUNTER_END")
GroupUpdater:RegisterEvent("PLAYER_REGEN_ENABLED")

GroupUpdater.UpdateInRange = function(name)
	Smarthealing['RaidRoster'][name]["inRange"] = UnitInRange(name)
end

GroupUpdater.UpdateRaidIndex = function()
	if IsInGroup() then
		local group_type = IsInRaid() and "raid" or "party"
		local group_size = GetNumGroupMembers()
		for i = 1, group_size do
			local unit_id
			if group_type == "party" and i == group_size then
				unit_id = "player"
			else
				unit_id = group_type .. i
			end
			local unit_name = UnitName(unit_id)
			if Smarthealing['RaidRoster'][unit_name] then
				Smarthealing['RaidRoster'][unit_name]["index"] = i
			end
		end
	elseif Smarthealing['RaidRoster'][G.myName] then
		Smarthealing['RaidRoster'][G.myName]["index"] = 1
	end
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
		
		if G.Encounters[G.encounter]["debuffs"] then
			for debuff, effect in pairs(G.Encounters[G.encounter]["debuffs"]) do
				if AuraUtil.FindAuraByName(buff, name, "HARMFUL") then
					debuff_effect = debuff_effect + effect
				end
			end
		end
		
		for buff, effect in pairs(G.Buffs["ALL"]) do
			if AuraUtil.FindAuraByName(buff, name, "HELPFUL") then
				buff_effect = buff_effect + effect
			end
		end
		
		if G.Buffs[class] then
			for buff, effect in pairs(G.Buffs[class]) do
				if AuraUtil.FindAuraByName(buff, name, "HELPFUL") then
					buff_effect = buff_effect + effect
				end
			end
		end
		
		Smarthealing['RaidRoster'][name]["sur"] = floor((hp + hp_incoming + hp_absorb - heal_absorb)/hp_max*100) - debuff_effect + buff_effect
		Smarthealing['RaidRoster'][name]["dmg"] = - debuff_effect + buff_effect
		
		UpdateTextOnRF(name, Smarthealing['RaidRoster'][name]["sur"])
	end
end

GroupUpdater.UpdateHealblock = function(name)
	local debuff = GetSpellInfo(209858)
	if AuraUtil.FindAuraByName(debuff, name, "HARMFUL") then -- 死疽
		local count = select(3, AuraUtil.FindAuraByName(debuff, name, "HARMFUL"))
		Smarthealing['RaidRoster'][name]["heal_block"] = 3*count
	else
		Smarthealing['RaidRoster'][name]["heal_block"] = 0
	end
end

local function CreateUpdater(DestName, target, t1, t2)
	local f = CreateFrame("Frame")
	f.t1 = t1
	f.t2 = t1+t2
	
	f:SetScript("OnUpdate", function(self, e)
		f.t1 = f.t1 - e
		f.t2 = f.t2 - e
		if f.t1 < 0 and not f.start then		
			f.start = true
			for name, info in pairs(Smarthealing['RaidRoster']) do
				if target == "all" then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] + 1
				elseif target == info.role or (target == "ranged_healer" and (info.role == "ranged" or info.role == "healer")) then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] + 1
				elseif target == "target" and name == DestName then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] + 1
				end
				UpdateTextOnRF(name, Smarthealing['RaidRoster'][name]["sur"])
			end
		end
		if f.t2 < 0 then
			self:SetScript("OnUpdate", nil)
			for name, info in pairs(Smarthealing['RaidRoster']) do
				if target == "all" then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] - 1
				elseif target == info.role or (target == "ranged_healer" and (info.role == "ranged" or info.role == "healer")) then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] - 1
				elseif target == "target" and name == DestName then
					Smarthealing['RaidRoster'][name]["icd"] = Smarthealing['RaidRoster'][name]["icd"] - 1
				end
				UpdateTextOnRF(name, Smarthealing['RaidRoster'][name]["sur"])
			end
		end
	end)
	
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:SetScript("OnEvent", function(self, event)
		self:SetScript("OnUpdate", nil)
	end)
end

GroupUpdater.ResetInComingDmg = function()
	for name, info in pairs(Smarthealing['RaidRoster']) do
		Smarthealing['RaidRoster'][name]["icd"] = 0
		UpdateTextOnRF(name, Smarthealing['RaidRoster'][name]["sur"])
	end
end

GroupUpdater.UpdateInComingDmg = function(Event_type, SpellID, DestName)
	if G.Encounters[G.encounter]["spells"] then
		if G.Encounters[G.encounter]["spells"][SpellID] and G.Encounters[G.encounter]["spells"][SpellID]["event"] == Event_type then
			CreateUpdater(DestName, G.Encounters[G.encounter]["spells"][SpellID]["target"], G.Encounters[G.encounter]["spells"][SpellID]["delay"], G.Encounters[G.encounter]["spells"][SpellID]["dur"])
		end
	end
end

GroupUpdater:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_CONNECTION" then
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
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local Time_stamp, Event_type, _, _, SourceName, _, _, _, DestName, _, _, SpellID = CombatLogGetCurrentEventInfo()	
		-- 检查致死效果
		if string.find(Event_type, "AURA") and Smarthealing['RaidRoster'][DestName] then
			GroupUpdater.UpdateHealblock(DestName)
		end
		-- 检查伤害预判
		GroupUpdater.UpdateInComingDmg(Event_type, SpellID, DestName)
	elseif event == "ENCOUNTER_START" then
		local encounterID, encounterName, difficultyID, groupSize = ...
		if G.Encounters[encounterID] then
			G.encounter = encounterID
			G.difficulty = difficultyID
		end
	elseif event == "ENCOUNTER_END" then
		encounter = "none"
		difficulty = "none"
	elseif event == "PLAYER_REGEN_ENABLED" then
		GroupUpdater.ResetInComingDmg()
	elseif event == "GROUP_ROSTER_UPDATE" then
		GroupUpdater.UpdateRaidIndex()
	end
end)

GroupUpdater.t = 0
GroupUpdater:SetScript("OnUpdate", function(self, e)
	self.t = self.t + e
	if self.t > 0.2 then	
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if name then
			GroupUpdater.UpdateInRange(name)
			end
		end		
		self.t = 0
	end
end)

function Smarthealing:OnUpdate(event, info)
	if not info.name or not info.spec_role or not info.spec_role_detailed then return end
	Smarthealing['RaidRoster'][info.name] = Smarthealing['RaidRoster'][info.name] or {}
	Smarthealing['RaidRoster'][info.name]["name"] = info.name
	Smarthealing['RaidRoster'][info.name]["role"] = info.spec_role_detailed
	Smarthealing['RaidRoster'][info.name]["class"] = info.class
	Smarthealing['RaidRoster'][info.name]["icd"] = 0
	GroupUpdater.UpdateActive(info.name)
	GroupUpdater.UpdateHealth(info.name)
	GroupUpdater.UpdateSurvival(info.name)
	GroupUpdater.UpdateHealblock(info.name)
	GroupUpdater.UpdateInRange(info.name)
	UpdateTextOnRF(info.name, Smarthealing['RaidRoster'][info.name]["sur"])
	GroupUpdater.UpdateRaidIndex()
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