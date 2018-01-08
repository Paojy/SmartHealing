local addon_name, ns = ...
local F, G = unpack(ns)

local anchor = "TOPLEFT"
local size = 30

local my_class = select(2, UnitClass("player"))
local my_name = UnitName("player")
local my_spec = 0
local safe_perc = 95
local ae_perc = 60
local ismoving = false
----------------------------------------------------------
--------------------[[     API     ]]---------------------
----------------------------------------------------------
F.GetLowSurvivalInRange_Absolute = function(perc)
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur and (not perc or info.sur <= perc) then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetLowSurvivalInRange = function(perc)
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur and (not perc or info.sur <= perc) and info.heal_block and info.heal_block < 80 then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetLowSurvivalInRangeForMelee = function(perc)
	local t = {}
	
	if IsInRaid() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.role and (info.role == "tank" or info.role == "melee") and info.sur and info.sur <= perc and info.heal_block and info.heal_block < 80 then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.sur < b.sur) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetLowSurvivalInRangeForRanged = function(perc)
	local t = {}
	
	if IsInRaid() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.role and (info.role == "ranged" or info.role == "healer") and info.sur and info.sur <= perc and info.heal_block and info.heal_block < 80 then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.sur < b.sur) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetLowSurvivalTankOrMe = function()
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur then
				if info.role and info.role == "tank" or info.name == my_name then
					table.insert(t, info)
				end
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetLowSurvivalTanking = function()
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur then
				if info.role and info.role == "tank" and UnitThreatSituation(name) and UnitThreatSituation(name) >= 2 then
					table.insert(t, info)
				end
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end

end

F.GetBuffTargetInRange = function(num, ...)
	local t = {}
	local buffs = {...}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur then
				local missing_buff = 0
				for k, spellID in pairs(buffs) do
					local buff_name = GetSpellInfo(spellID)
					if not UnitBuff(name, buff_name) then
						missing_buff = missing_buff + 1
					end
				end
				if missing_buff > num then
					table.insert(t, info)
				end
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetHealBlockInRange = function()
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur and info.heal_block and info.heal_block >= 50 then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end) -- 按照生存系数排序
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetHotTargetsInRange = function()
	if not SH_CDB["General"]["hot"] then return end
	
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.hot and info.hot > 0 then
				table.insert(t, info)
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end) -- 按照生存系数排序
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetBuffedTargetInRange = function(num, ...)
	local t = {}
	local buffs = {...}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur then
				local has_buff = 0
				for k, spellID in pairs(buffs) do
					local buff_name = GetSpellInfo(spellID)
					if UnitBuff(name, buff_name) then
						has_buff = has_buff + 1
					end
				end
				if has_buff >= num then
					table.insert(t, info)
				end
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

F.GetBuffTankOrMeInRange = function(num, ...)
	local t = {}
	local buffs = {...}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and info.sur and (info.role and info.role == "tank" or info.name == my_name) then
				local missing_buff = 0
				for k, spellID in pairs(buffs) do
					local buff_name = GetSpellInfo(spellID)
					if not UnitBuff(name, buff_name) then
						missing_buff = missing_buff + 1
					end
				end
				if missing_buff > num then
					table.insert(t, info)
				end
			end
		end
	else
		return
	end
	
	table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
	
	if #t > 0 then
		return t[1]["name"], t[1]["sur"], #t
	end
end

local GroupNeedHeal = function()
	local t = {}
	
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.active then
				if info.hp_perc and info.hp_perc <= safe_perc then
					return true
				elseif SH_CDB["General"]["hot"] and info.hot and info.hot > 0 then
					return true
				end
			end
		end
	else
		return
	end
	
	return
end

local IsSpellUsable = function(spellID)
	if not IsSpellKnown(spellID) then return end
	if UnitCastingInfo("player") and select(10, UnitCastingInfo("player")) then return end
	
	local hascharges = GetSpellCharges(spellID)
	if hascharges then
		local charges = GetSpellCharges(spellID)
		if charges > 0 then
			
			return true
		end
	else
		local start, duration = GetSpellCooldown(spellID)
		if start and duration < 2 then
		
			return true
		end
	end
end

local IsItemUsable = function(itemID)
	if IsEquippedItem(itemID) then
		local start, duration = GetItemCooldown(itemID)
		if start and duration < 2 then
			return true
		end
	end
end

local UseTrinkets = function(name, sur)
	if not SH_CDB["General"]["trinkets"] then return true end
	
	local heal_absorb = UnitGetTotalHealAbsorbs(name)
	local hp_max = UnitHealthMax(name)
	local sur_no_absorb
	if heal_absorb and hp_max and hp_max > 0 then			
		sur_no_absorb = sur - heal_absorb/hp_max*100 -- 排除吸收因素
	end
	
	if sur_no_absorb and sur_no_absorb < 25 then -- 可以用吸收类饰品
		if IsItemUsable(151957) then -- 邪能护盾
			return 253277, name
		elseif IsItemUsable(147007) then -- 蓝图
			return 242622, name
		end
	elseif IsItemUsable(147006) then -- 信仰档案
		return 242619, name
	end
end

local UseDefensiveCD = function(spellID, tpye, sur)
	if not SH_CDB["General"]["cd"] then return true end
	
	local heal_absorb = UnitGetTotalHealAbsorbs(name)
	local hp_max = UnitHealthMax(name)
	local sur_no_absorb
	if heal_absorb and hp_max and hp_max > 0 then			
		sur_no_absorb = sur - heal_absorb/hp_max*100 -- 排除吸收因素
	end
	
	if sur_no_absorb and sur_no_absorb < 25 then -- 可以用减伤技能
		
	elseif IsItemUsable(147006) then -- 守护之魂
		return 242619, name
	end
end

local HasBuff = function(spellID, unitID)
	local unit = unitID or "player"
	local spell_name = GetSpellInfo(spellID)
	local hasbuff = UnitBuff(unit, spell_name, nil, "PLAYER")
	
	return hasbuff
end

local GetBuffRemain = function(spellID, unitID)
	local unit = unitID or "player"
	local spell_name = GetSpellInfo(spellID)
	local expiration = select(7, UnitBuff(unit, spell_name, nil, "PLAYER"))
	if expiration then
		return expiration - GetTime()
	end
end

local HasDebuff = function(spellID, unitID)
	local unit = unitID or "player"
	local spell_name = GetSpellInfo(spellID)
	local hasdebuff = UnitDeuff(unit, spell_name)
	
	return hasdebuff
end

local IsTalentChosen = function(tier, column)
	local chosen = select(4, GetTalentInfo(tier, column, 1))
	if chosen then
		return true
	end
end

local GetCountofBuff = function(spellID)
	local num = 0
	local buff = GetSpellInfo(spellID)
	if UnitInParty("player") and not UnitInRaid("player") then
        for i=1,4 do
            local unit = string.format("party%d",i)
            if not UnitIsUnit(unit, "player") then
                if UnitBuff(unit, buff, nil, "PLAYER") then
                    num = num + 1
                end
            end
        end
    elseif UnitInRaid("player") then
        for i=1,40 do
            local unit = string.format("raid%d",i)
            if not UnitIsUnit(unit, "player") then
                if UnitBuff(unit, buff, nil, "PLAYER") then
                    num = num + 1
                end
            end
        end
    end
    if UnitBuff("player", buff, nil, "PLAYER") then
        num = num + 1
    end
	
	return num
end

local MyAvailableHealth = function()
	local health = UnitHealth("player")
	local absorb = UnitGetTotalAbsorbs("player")
	local max_health = UnitHealthMax("player")
	local perc = floor((health + absorb)/max_health*100)
	local perc2 = floor(health/max_health*100)
	return perc, perc2
end

----------------------------------------------------------
-------------[[     团队框架上加图标     ]]---------------
----------------------------------------------------------
local Icons = {}

local function editIcon(frame, t)
	if t == "all" or t == "size" then
		local size = SH_CDB["Layout"]["size"]
		
		frame:SetSize(size, size)
		
		if frame.overlay and frame:IsShown() then
			frame:Hide()
			frame:Show()
		end
	end
	
	if t == "all" or t == "anchor" then	
		frame:ClearAllPoints()
		frame:SetPoint(SH_CDB["Layout"]["anchor"])
	end
	
	if t == "all" or t == "glow" then
		if SH_CDB["Layout"]["glow"] then
			ActionButton_ShowOverlayGlow(frame)
			frame:SetScript("OnShow", function() ActionButton_ShowOverlayGlow(frame) end)
			frame:SetScript("OnHide", function() ActionButton_HideOverlayGlow(frame) end)
		else
			ActionButton_HideOverlayGlow(frame)
			frame:SetScript("OnShow", nil)
			frame:SetScript("OnHide", nil)
		end
	end
end

F.EditIcons = function(t)
	for i, icon in pairs(Icons) do
		editIcon(icon, t)
	end
end

local function addIcon(parentFrame, action, spellID)
	if not parentFrame.SHF then
		local frame = CreateFrame("Frame", nil, parentFrame)
		frame:SetFrameStrata("HIGH")
		frame:Hide()
		
		local texture = frame:CreateTexture(nil,"HIGH")
		texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
		texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.texture = texture
		
		editIcon(frame, "all")
		parentFrame.SHF = frame
		
		table.insert(Icons, frame) 
	end
	
	if action == "show" and parentFrame.SHF.spellID ~= spellID then
		parentFrame.SHF.spellID = spellID
		parentFrame.SHF.texture:SetTexture(select(3, GetSpellInfo(spellID)))
		parentFrame.SHF:Show()
	elseif action == "hide" and (parentFrame.SHF.spellID == spellID or not spellID) then
		parentFrame.SHF.spellID = 0
		parentFrame.SHF.texture:SetTexture(G.blank)
		parentFrame.SHF:Hide()
	end
end

F.SH_ShowHideIcon_RF = function(target, action, spellID)

	local hasGrid = IsAddOnLoaded("Grid")
    local hasGrid2 = IsAddOnLoaded("Grid2")
	local hasCompactRaid = IsAddOnLoaded("CompactRaid")
    local hasVuhDo = IsAddOnLoaded("VuhDo")
    local hasElvUI = _G["ElvUF_Raid"] and _G["ElvUF_Raid"]:IsVisible()
    local hasAltzUI = _G["Altz_HealerRaid"] and _G["Altz_HealerRaid"]:IsVisible()
    
    if hasElvUI then
        for i=1, 8 do
            for j=1, 5 do
                local f = _G["ElvUF_RaidGroup"..i.."UnitButton"..j]
                if f and f.unit and UnitName(f.unit) == target then
                    addIcon(f, action, spellID)
                    return
                end
            end
        end
		
	elseif hasGrid then
        local layout = GridLayoutFrame
        if layout then
            local children = {layout:GetChildren()}
            for _, child in ipairs(children) do
                if child:IsVisible() then
                    local frames = {child:GetChildren()}
                    for _, f in ipairs(frames) do
                        if f.unit and UnitName(f.unit) == target then
                            addIcon(f, action, spellID)
                            return
                        end
                    end
                end
            end
        end
		
    elseif hasGrid2 then
        local layout = Grid2LayoutFrame
        if layout then
            local children = {layout:GetChildren()}
            for _, child in ipairs(children) do
                if child:IsVisible() then
                    local frames = {child:GetChildren()}
                    for _, f in ipairs(frames) do
                        if f.unit and UnitName(f.unit) == target then
                            addIcon(f, action, spellID)
                            return
                        end
                    end
                end
            end
        end
		
    elseif hasAltzUI then
        for i = 1, 40 do
            local f = _G["Altz_HealerRaidUnitButton"..i]
            if f and f.unit and UnitName(f.unit) == target then
                addIcon(f, action, spellID)
                return
            end
        end
		
	elseif hasVuhDo then
        for i = 1, 40 do
            local f = _G["Vd1H"..i]
            if f and f.raidid and UnitName(f.raidid) == target then
                addIcon(f, action, spellID)
                return
            end
        end
	
	elseif hasCompactRaid then
        for i =1, 8 do 
            for j = 1, 5 do
                local f = _G["CompactRaidGroupHeaderSubGroup"..i.."UnitButton"..j]
                if f and f.unit and UnitName(f.unit) == target then
                    addIcon(f, action, spellID)
                    return
                end
            end
        end
		
    else
        for i=1, 40 do
            local f = _G["CompactRaidFrame"..i]
            if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                addIcon(f, action, spellID)
                return
            end
        end
        for i=1, 4 do
            for j=1, 5 do
                local f = _G["CompactRaidGroup"..i.."Member"..j]
                if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                    addIcon(f, action, spellID)
                    return
                end
            end
        end
    end
end

----------------------------------------------------------
-------------------[[     刷新     ]]---------------------
----------------------------------------------------------

--[[ Spell ID

	激流 61295
	治疗波 77472
	治疗之涌 8004
	治疗链 1064(115175替换)
	
	潮汐奔涌 53390
	女王崛起 207228
	先祖指引 108281
	暴雨 157503
	升腾 114052
	
]]--

local SmartSpells = {
	SHAMAN = {},
	PALADIN = {},
	DRUID = {},
	PRIEST = {},
}

SmartSpells["SHAMAN"] = function(mode)
	if my_spec ~= 3 then return end
	
	if not GroupNeedHeal() then --所有血量都大于安全血线
		G.current_spell, G.current_target = nil, nil
	else
		local target, perc = F.GetLowSurvivalInRange()
		local low_target, low_perc, num_lowhp = F.GetLowSurvivalInRange(ae_perc) -- 低血量
		local melee_target, melee_perc, melee_lowhp = F.GetLowSurvivalInRangeForMelee(ae_perc) -- 近战低血量
		local range_target, range_perc, range_lowhp = F.GetLowSurvivalInRangeForRanged(ae_perc) -- 远程低血量
		
		if mode == "S" then -- 分散站位 Dispersed
		
			if IsSpellUsable(61295) then -- 能用激流用激流
				G.current_spell, G.current_target = 61295, target
			elseif perc < 25 then -- 紧急救人
				if UseTrinkets(target, perc) then
					G.current_spell, G.current_target = UseTrinkets(target, perc)
				else
					G.current_spell, G.current_target = 8004, target
				end
			elseif HasBuff(157503) and (HasBuff(114052) or HasBuff(108281)) then -- 暴雨 + 升腾/先祖
				local melee_chain_target, _, melee_num = F.GetLowSurvivalInRangeForMelee(ae_perc*1.3)
				local range_chain_target, _, range_num = F.GetLowSurvivalInRangeForRanged(ae_perc*1.3)
				if perc < 60 and SH_CDB["General"]["trinkets"] and IsItemUsable(147006) then
					G.current_spell, G.current_target = 242619, target
				elseif melee_num and melee_num >= 3 then
					G.current_spell, G.current_target = 1064, melee_chain_target
				elseif range_num and range_num >= 3 then
					G.current_spell, G.current_target = 1064, range_chain_target
				end
			elseif melee_lowhp and melee_lowhp >= 3 then
				G.current_spell, G.current_target = 1064, melee_target
			elseif range_lowhp and range_lowhp >= 3 then
				G.current_spell, G.current_target = 1064, range_target
			elseif HasBuff(53390) then -- 有潮汐奔涌
				if perc < 40 then -- 血量小于50%用治疗之涌
					G.current_spell, G.current_target = 8004, target
				else -- 血量大于50%用治疗波
					G.current_spell, G.current_target = 77472, target
				end
			else
				G.current_spell, G.current_target = 77472, target
			end
	
		else -- 集合站位 Gathered
	
			if IsSpellUsable(61295) then -- 能用激流用激流
				G.current_spell, G.current_target = 61295, target
			elseif perc < 25 then -- 紧急救人
				if UseTrinkets(target, perc) then
					G.current_spell, G.current_target = UseTrinkets(target, perc)
				else
					G.current_spell, G.current_target = 8004, target
				end
			elseif HasBuff(157503) and (HasBuff(114052) or HasBuff(108281)) then -- 暴雨 + 升腾/先祖
				local chain_target, _, chain_num = F.GetLowSurvivalInRange(ae_perc*1.3)
				if perc < 60 and SH_CDB["General"]["trinkets"] and IsItemUsable(147006) then
					G.current_spell, G.current_target = 242619, target
				elseif chain_num and chain_num >= 4 then
					G.current_spell, G.current_target = 1064, chain_target
				end
			elseif num_lowhp and num_lowhp >= 4 then -- 视野内至少4人低于团刷血量
				G.current_spell, G.current_target = 1064, low_target
			elseif HasBuff(53390) then -- 有潮汐奔涌
				if perc < 40 then -- 血量小于50%用治疗之涌
					G.current_spell, G.current_target = 8004, target
				else -- 血量大于50%用治疗波
					G.current_spell, G.current_target = 77472, target
				end
			else
				G.current_spell, G.current_target = 77472, target
			end		
		end
	end	
end

SmartSpells["PALADIN"] = function(mode)
	if my_spec ~= 1 then return end
	
	if GetCountofBuff(53563) == 0 or (IsTalentChosen(7, 1) and GetCountofBuff(156910)==0) then -- 需要上道标
		local beacon_target = F.GetBuffTankOrMeInRange(1, 53563, 156910)
		G.current_spell, G.current_target = 53563, beacon_target
	elseif not GroupNeedHeal() then --所有血量都大于安全血线
		G.current_spell, G.current_target = nil, nil
	else
		local target, perc = F.GetLowSurvivalInRange()
		local tank_target, tank_perc = F.GetLowSurvivalTankOrMe()		
		if IsSpellUsable(20473) then -- 震击好了用震击
			G.current_spell, G.current_target = 20473, target
		elseif target and perc < 25 and UseTrinkets(target, perc) then -- 紧急救人
			G.current_spell, G.current_target = UseTrinkets(target, perc)
		elseif target and perc < 25 and SH_CDB["General"]["cd"] and IsSpellUsable(6940) then -- 牺牲
			G.current_spell, G.current_target = 6940, target
		elseif IsSpellUsable(223306) then -- 赋予信仰好了给坦克或者自己用
			G.current_spell, G.current_target = 223306, tank_target
		elseif HasBuff(234862) then -- 玛尔拉德的临终之息
			G.current_spell, G.current_target = 183998, target
		elseif HasBuff(200423) and HasBuff(54149) then -- 圣光救赎
			local beaconed_target, beaconed_target_perc = F.GetBuffedTargetInRange(1, 53563, 156910)
			if beaconed_target_perc <= 60 then
				G.current_spell, G.current_target = 19750, beaconed_target
			else
				G.current_spell, G.current_target = 82326, beaconed_target
			end
		elseif MyAvailableHealth() > 80 and target ~= my_name and ismoving then -- 移动中，血还多就用自杀光
			G.current_spell, G.current_target = 183998, target			
		elseif HasBuff(54149) then -- 有圣光灌注用闪现
			G.current_spell, G.current_target = 19750, target
		elseif perc < 60 then
			G.current_spell, G.current_target = 19750, target
		else
			G.current_spell, G.current_target = 82326, target
		end
	end
		
end

SmartSpells["DRUID"] = function(mode)
	if my_spec ~= 4 then return end
	
	local target, perc = F.GetLowSurvivalInRange() -- 安全血线以下的人
	
	local target_rej, perc_rej = F.GetBuffTargetInRange(1, 774, 155777) -- 无回春
	local target_rej2, perc_rej2 = F.GetBuffTargetInRange(0, 774, 155777) -- 无双回春
	local target_rej3, perc_rej3 = F.GetBuffTargetInRange(2, 48438, 774, 155777) -- 无野性成长无回春的人
	local low_target, low_perc, num_lowhp = F.GetLowSurvivalInRange(ae_perc) -- 低血量
	
	local tanking_target = F.GetLowSurvivalTanking()
	
	if target and perc < 40 then
		if perc < 25 and UseTrinkets(target, perc) then -- 紧急救人
			G.current_spell, G.current_target = UseTrinkets(target, perc)
		elseif perc < 25 and SH_CDB["General"]["cd"] and IsSpellUsable(102342) then -- 铁木树皮
			G.current_spell, G.current_target = 102342, target
		elseif not (HasBuff(774, target) or HasBuff(155777, target)) then -- 没回春
			G.current_spell, G.current_target = 774, target
		elseif IsTalentChosen(6, 3) and not (HasBuff(774, target) and HasBuff(155777, target)) then -- 补满双回春
			G.current_spell, G.current_target = 774, target
		elseif IsSpellUsable(18562) then -- 迅捷
			G.current_spell, G.current_target = 18562, target
		else -- 愈合
			G.current_spell, G.current_target = 8936, target
		end
	elseif IsTalentChosen(5, 3) and perc_rej and perc_rej < 60 then -- 可触发栽培
		G.current_spell, G.current_target = 774, target_rej
	elseif IsSpellUsable(102351) and target and  perc < 50 then -- 结界
		G.current_spell, G.current_target = 102351, target
	elseif IsSpellUsable(102351) and tanking_target then -- 结界
		G.current_spell, G.current_target = 102351, tanking_target
	elseif HasBuff(16870) and target and perc < 80 and (not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 8936) then -- 有节能施法
		G.current_spell, G.current_target = 8936, target
	elseif HasBuff(16870) and tanking_target and (not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 8936) then -- 有节能施法
		G.current_spell, G.current_target = 8936, tanking_target
	elseif GetCountofBuff(33763) == 0 and tanking_target then -- 生命绽放
		G.current_spell, G.current_target = 33763, tanking_target		
	elseif num_lowhp and num_lowhp > 3 and IsSpellUsable(48438) and (not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 48438) then -- 野性成长
		G.current_spell, G.current_target = 48438, low_target
	elseif tanking_target and not (HasBuff(774, tanking_target) or HasBuff(155777, tanking_target)) then -- T没回春
		G.current_spell, G.current_target = 774, tanking_target
	elseif IsTalentChosen(6, 3) and tanking_target and not (HasBuff(774, tanking_target) and HasBuff(155777, tanking_target)) then -- 补满T双回春
		G.current_spell, G.current_target = 774, tanking_target
	elseif target_rej and perc_rej < safe_perc then
		G.current_spell, G.current_target = 774, target_rej
	elseif IsTalentChosen(6, 3) and target_rej2 and perc_rej2 < safe_perc then
		G.current_spell, G.current_target = 774, target_rej2
	elseif target and perc < safe_perc and (not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 8936) then
		if InCombatLockdown() then
			G.current_spell, G.current_target = 8936, target
		else
			G.current_spell, G.current_target = 5185, target
		end
	elseif target_rej then
		G.current_spell, G.current_target = 774, target_rej
	elseif UnitAffectingCombat("player") and IsTalentChosen(6, 3) and target_rej2 then
		G.current_spell, G.current_target = 774, target_rej2
	else
		G.current_spell, G.current_target = nil, nil
	end
	
end

SmartSpells["PRIEST"] = function(mode)
	if my_spec == 1 then -- 戒律
		local target, perc = F.GetLowSurvivalInRange() -- 安全血线以下的人
		local target_pws, perc_pws = F.GetBuffTargetInRange(0, 17) -- 无盾的血量最低的人
		local target_ato, perc_ato = F.GetBuffTargetInRange(0, 194384) -- 无救赎的血量最低的人
		local tanking_target, tanking_perc = F.GetLowSurvivalTanking()
		
		if not InCombatLockdown() then -- 脱离战斗时
			if target and perc <= 50 then
				G.current_spell, G.current_target = 47540, target
			elseif target and perc <= 90 then
				G.current_spell, G.current_target = 186263, target
			else
				G.current_spell, G.current_target = nil, nil
			end
		elseif target and perc < 30 and IsSpellUsable(47540) then -- 苦修
			G.current_spell, G.current_target = 47540, target
		elseif target and perc < 25 and UseTrinkets(target, perc) then -- 紧急救人
			G.current_spell, G.current_target = UseTrinkets(target, perc)
		elseif perc < 25 and SH_CDB["General"]["cd"] and IsSpellUsable(33206) then -- 痛苦压制
			G.current_spell, G.current_target = 33206, target
		elseif target_ato and IsInRaid() and GetCountofBuff(194384) <= 5 and IsSpellUsable(194509) then
			G.current_spell, G.current_target = 194509, target_ato -- 真言术：耀
		elseif target_ato and IsInGroup() and not IsInRaid() and GetCountofBuff(194384) <= 3 then
			if perc_ato < 30 then -- 暗影愈合
				G.current_spell, G.current_target = 186263, target
			elseif IsSpellUsable(194509) then -- 真言术：耀
				G.current_spell, G.current_target = 194509, my_name
			elseif perc_ato < 60 then -- 暗影愈合
				G.current_spell, G.current_target = 186263, target
			else -- 恳求
				G.current_spell, G.current_target = 200829, target
			end
		elseif target_pws and IsSpellUsable(17) then
			if perc_pws < 70 then-- 真言术：盾 给血量最低的人 <70
				G.current_spell, G.current_target = 17, target_pws
			elseif tanking_target and not HasBuff(17, tanking_target) then -- 真言术：盾 给当前坦克
				G.current_spell, G.current_target = 17, tanking_target
			else -- 真言术：盾 给血量最低的人
				G.current_spell, G.current_target = 17, target_pws
			end
		else
			G.current_spell, G.current_target = nil, nil
		end
	elseif my_spec == 2 then -- 神圣

		if not GroupNeedHeal() and not IsSpellUsable(33076) and (not IsTalentChosen(2, 3) or Hasbuff(139)) then  -- 所有血量都大于安全血线 愈合祷言不可用 选祈告时自己已经有恢复了 /sleep
			G.current_spell, G.current_target = nil, nil
		else
			local target, perc = F.GetLowSurvivalInRange() -- 安全血线以下的人
			local low_target, low_perc, num_lowhp = F.GetLowSurvivalInRange(ae_perc) -- 低血量
			local target_mending, perc_mending = F.GetBuffTargetInRange(0, 33076) -- 无愈合祷言的人
			local tanking_target, tanking_perc = F.GetLowSurvivalTanking()
			
			if target and perc < 50 and IsSpellUsable(2050) then -- 静
				G.current_spell, G.current_target = 2050, target
			elseif target and perc < 25 and UseTrinkets(target, perc) then -- 紧急救人
				G.current_spell, G.current_target = UseTrinkets(target, perc)
			elseif perc < 25 and SH_CDB["General"]["cd"] and IsSpellUsable(47788) then -- 守护之魂
				G.current_spell, G.current_target = 47788, target
			elseif target and perc < 70 and IsSpellUsable(208065) and not HasBuff(208065, target) then -- 图雷
				G.current_spell, G.current_target = 208065, target
			elseif tanking_target and tanking_perc < 85 and IsSpellUsable(2050) then -- 静
				G.current_spell, G.current_target = 2050, tanking_target
			elseif target and perc < 65 and IsSpellUsable(2050) then -- 静
				G.current_spell, G.current_target = 2050, target
			elseif IsSpellUsable(33076) and target_mending and (not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 33076) then -- 愈合祷言
				if tanking_target and not HasBuff(33076, tanking_target) then
					G.current_spell, G.current_target = 33076, tanking_target
				elseif target_mending then
					G.current_spell, G.current_target = 33076, target_mending
				end
			elseif tanking_target and GetSpellCharges(208065) == 2  and not HasBuff(208065, tanking_target) then -- 双图雷
				G.current_spell, G.current_target = 208065, tanking_target
			elseif IsTalentChosen(5,2) and select(2, MyAvailableHealth()) < 85 and target and target ~= my_name then -- 联结治疗
				G.current_spell, G.current_target = 32546, tanking_target
			elseif num_lowhp and num_lowhp > 3 then
				if IsTalentChosen(7, 3) and IsSpellUsable(204883) then -- 治疗之环
					G.current_spell, G.current_target = 204883, low_target
				else
					local low_target2, low_perc2, num_lowhp2 = F.GetLowSurvivalInRange(ae_perc-20)
					if num_lowhp2 and num_lowhp2 > 3 or not UnitCastingInfo("player") or select(10, UnitCastingInfo("player")) ~= 596 then -- 治疗祷言
						G.current_spell, G.current_target = 596, low_target
					end
				end
			elseif target and perc < 85 then -- 快速治疗
				G.current_spell, G.current_target = 2061, target
			elseif HasBuff(200183) then -- 有神圣化身时刷出静和灵
				if not IsSpellUsable(2050) and (target or tanking_target) then
					if target then
						G.current_spell, G.current_target = 2061, target
					elseif tanking_target then
						G.current_spell, G.current_target = 2061, tanking_target
					end
				elseif not IsSpellUsable(34861) then
					if target then
						G.current_spell, G.current_target = 596, target
					elseif tanking_target then
						G.current_spell, G.current_target = 596, tanking_target
					else
						G.current_spell, G.current_target = 596, my_name
					end
				end
			elseif target and not HasBuff(139, target) then -- 恢复
				G.current_spell, G.current_target = 139, target
			elseif IsTalentChosen(2, 3) and not HasBuff(139) then -- 选祈告时给自己恢复
				G.current_spell, G.current_target = 139, my_name
			elseif target then -- 治疗术
				G.current_spell, G.current_target = 2060, target
			else
				G.current_spell, G.current_target = nil, nil
			end
		end
	end
end

F.GetSmartSpell = function()
	if UnitGroupRolesAssigned("player") ~= "HEALER" or not SmartSpells[my_class] then return end
	
	SmartSpells[my_class](G.Encounters[G.encounter]["mode"])
	
	if G.last_spell ~= G.current_spell or G.last_target ~= G.current_target then
	
		local group_type = IsInRaid() and "raid" or "party"
		local group_size = GetNumGroupMembers()
		
		for i = 1, group_size do  
			local unit_id
			if group_type == "party" and i == group_size then
				unit_id = "player"
			else
				unit_id = group_type .. i
			end
			
			local name = UnitName(unit_id)
			
			if name then
				F.SH_ShowHideIcon_RF(name, "hide")
			end
		end

		F.SH_ShowHideIcon_RF(G.current_target, "show", G.current_spell)
			
		G.last_spell = G.current_spell
		G.last_target = G.current_target
		--print(G.current_spell, G.current_target)
	
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
EventFrame:RegisterEvent("PLAYER_STARTED_MOVING") 
EventFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	
EventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "SPELL_UPDATE_COOLDOWN" then
		local start, dur = GetSpellCooldown(61304)
		if start and dur > 0 then
			if not G.InGCD then
				G.InGCD = true
				C_Timer.After(.1, function() F.GetSmartSpell() end)
				C_Timer.After(dur, function() G.InGCD = false end)
			end
		end
	elseif event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STOPPED_MOVING" then
		if event == "PLAYER_STARTED_MOVING" then
			ismoving = true
		else
			ismoving = false
		end
		F.GetSmartSpell()
	elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
		my_spec = GetSpecialization()
	end
end)