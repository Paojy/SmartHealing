local addon_name, ns = ...
local F, G, L = unpack(ns)

local anchor = "TOPLEFT"
local size = 30

local my_spec = 0
local safe_perc = 95
local ae_perc = 70
local ismoving = false
----------------------------------------------------------
--------------------[[     API     ]]---------------------
----------------------------------------------------------
local function RoleCheck(info, i)
	if SH_CDB["Logic"][i]["target_rolefilter"] then
		if SH_CDB["Logic"][i]["target_role"] == "me" then
			if info.name == G.myName then
				return true
			end
		elseif SH_CDB["Logic"][i]["target_role"] == "exceptme" then
			if G.myName ~= G.myName then
				return true
			end
		elseif  SH_CDB["Logic"][i]["target_role"] == "tank" then
			if info.role == "tank" then
				return true
			end
		elseif  SH_CDB["Logic"][i]["target_role"] == "excepttank" then
			if info.role ~= "tank" then
				return true
			end
		end
	else
		return true
	end
end

local function LackHotCheck(info, i)
	if SH_CDB["Logic"][i]["target_lackhot"] then
		if SH_CDB["Logic"][i]["target_lackhot_logic"] == "any" then -- 缺少任意Hot
			for spellID in pairs(SH_CDB["Logic"][i]["target_lackhots"]) do
				local hot = GetSpellInfo(spellID)
				if not AuraUtil.FindAuraByName(hot, info.name, "HELPFUL") then
					return true
				end
			end
		else -- 缺少全部Hot
			local hot_num = 0
			for spellID in pairs(SH_CDB["Logic"][i]["target_lackhots"]) do
				local hot = GetSpellInfo(spellID)
				if AuraUtil.FindAuraByName(hot, info.name, "HELPFUL") then
					hot_num = hot_num + 1
					break
				end
			end
			if hot_num == 0 then
				return true
			end
		end
	else
		return true
	end
end

local function HasHotCheck(info, i)
	if SH_CDB["Logic"][i]["target_hashot"] then
		if SH_CDB["Logic"][i]["target_hashot_logic"] == "any" then -- 拥有任意Hot
			for spellID in pairs(SH_CDB["Logic"][i]["target_hashots"]) do
				local hot = GetSpellInfo(spellID)
				if AuraUtil.FindAuraByName(hot, info.name, "HELPFUL") then
					return true
				end
			end
		else -- 拥有全部Hot
			local lack_hot_num = 0
			for spellID in pairs(SH_CDB["Logic"][i]["target_hashots"]) do
				local hot = GetSpellInfo(spellID)
				if not AuraUtil.FindAuraByName(hot, info.name, "HELPFUL") then
					lack_hot_num = lack_hot_num + 1
					break
				end
			end
			if lack_hot_num == 0 then
				return true
			end
		end
	else
		return true
	end
end

local function HotCountCheck(i)
	if SH_CDB["Logic"][i]["raid_hot"] then
		local group_type = IsInRaid() and "raid" or "party"
		local group_size = GetNumGroupMembers()
		local has_hot_num = 0
		for index = 1, group_size do
			local unit_id
			if group_type == "party" and index == group_size then
				unit_id = "player"
			else
				unit_id = group_type .. index
			end
			
			if SH_CDB["Logic"][i]["raid_hashot_logic"] == "any" then -- 拥有任意Hot
				for spellID in pairs(SH_CDB["Logic"][i]["raid_hot_spells"]) do
					local hot = GetSpellInfo(spellID)
					if AuraUtil.FindAuraByName(hot, unit_id, "HELPFUL") then
						has_hot_num = has_hot_num + 1
						break
					end
				end
			else
				local lack_hot_num = 0
				for spellID in pairs(SH_CDB["Logic"][i]["raid_hot_spells"]) do
					local hot = GetSpellInfo(spellID)
					if not AuraUtil.FindAuraByName(hot, unit_id, "HELPFUL") then
						lack_hot_num = lack_hot_num + 1
						break
					end
				end
				if lack_hot_num == 0 then
					has_hot_num = has_hot_num + 1
				end
			end
		end
		
		if SH_CDB["Logic"][i]["raid_hot_logic"] == "lessthan" and has_hot_num < SH_CDB["Logic"][i]["raid_hot_num"] then
			return true
		elseif SH_CDB["Logic"][i]["raid_hot_logic"] == "morethan" and has_hot_num >= SH_CDB["Logic"][i]["raid_hot_num"] then
			return true
		end
	end
end

local function CheckHotDuration(unit, spellid, dur)
	local aura = GetSpellInfo(spellid)
	local name, icon, count, debuffType, duration, expirationTime = AuraUtil.FindAuraByName(aura, unit, "HELPFUL|PLAYER")
	if not name then
		return true
	elseif expirationTime and expirationTime - GetTime() < dur then
		return true
	end
end

local function RaidHotLackCheck(i)
	if SH_CDB["Logic"][i]["raid_hot_lack"] then
		local group_type = IsInRaid() and "raid" or "party"
		local group_size = GetNumGroupMembers()
		
		local passed, needheal, str = 0, 0, 0
			
		for i = 1, group_size do  
			local unit_id
			if group_type == "party" and i == group_size then
				unit_id = "player"
			else
				unit_id = group_type .. i
			end
			
			local perc
			if UnitHealthMax(unit_id) > 0 then
				perc = UnitHealth(unit_id)/UnitHealthMax(unit_id)
			else
				perc = 1
			end
			
			if CheckHotDuration(unit_id, SH_CDB["Logic"][i]["raid_hot_lack_spellid"], SH_CDB["Logic"][i]["raid_hot_lack_dur"]) then
				if perc*100 <= SH_CDB["Logic"][i]["raid_hot_lack_value"] then
					passed = passed + 1
				end
			end
		end
		
		if passed >= SH_CDB["Logic"][i]["raid_hot_lack_num"] then
			return true
		end
	end
end

F.GetTarget = function(i)
	local t = {}
	if IsInGroup() then
		for name, info in pairs(Smarthealing['RaidRoster']) do
			if info.inRange and info.active and RoleCheck(info, i) and LackHotCheck(info, i) and HasHotCheck(info, i) then
				if SH_CDB["Logic"][i]["raid_sur"] then
					if info.sur and info.sur <= SH_CDB["Logic"][i]["raid_sur_value"] and info.heal_block and info.heal_block < 80 then
						table.insert(t, info)
					end
				elseif SH_CDB["Logic"][i]["raid_sur_melee"] then
					if info.role and (info.role == "tank" or info.role == "melee") and info.sur and info.sur <= SH_CDB["Logic"][i]["raid_sur_melee_value"] and info.heal_block and info.heal_block < 80 then
						table.insert(t, info)
					end
				elseif SH_CDB["Logic"][i]["raid_sur_ranged"] then
					if info.role and (info.role == "ranged" or info.role == "healer") and info.sur and info.sur <= SH_CDB["Logic"][i]["raid_sur_ranged_value"] and info.heal_block and info.heal_block < 80 then
						table.insert(t, info)
					end
				elseif SH_CDB["Logic"][i]["raid_sur_tank"] then
					if info.role and info.role == "tank" and info.sur and info.sur <= SH_CDB["Logic"][i]["raid_sur_tank_value"] and info.heal_block and info.heal_block < 80 then
						table.insert(t, info)
					end
				elseif SH_CDB["Logic"][i]["raid_icd"] then
					if info.icd and info.icd > 0 then
						table.insert(t, info)
					end
				else
					table.insert(t, info)
				end
			end
		end
	else
		return nil
	end
	
	local number_check
	if (SH_CDB["Logic"][i]["raid_sur"] and #t >= SH_CDB["Logic"][i]["raid_sur_num"]) then	
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_sur_melee"] and #t >= SH_CDB["Logic"][i]["raid_sur_melee_num"]) then
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_sur_ranged"] and #t >= SH_CDB["Logic"][i]["raid_sur_ranged_num"]) then
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_sur_tank"] and #t >= SH_CDB["Logic"][i]["raid_sur_tank_num"]) then
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_icd"] and #t >= SH_CDB["Logic"][i]["raid_icd_num"]) then
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_hot"] and HotCountCheck(i)) then
		number_check = true
	elseif (SH_CDB["Logic"][i]["raid_hot_lack"] and RaidHotLackCheck(i)) then
		number_check = true      
	elseif not (SH_CDB["Logic"][i]["raid_sur"] or SH_CDB["Logic"][i]["raid_sur_melee"] or SH_CDB["Logic"][i]["raid_sur_ranged"] or SH_CDB["Logic"][i]["raid_sur_tank"] or SH_CDB["Logic"][i]["raid_icd"] or SH_CDB["Logic"][i]["raid_hot"] or SH_CDB["Logic"][i]["raid_hot_lack"]) and #t > 0 then
		number_check = true
	end
	
	if number_check then
		if SH_CDB["Logic"][i]["order_logic"] == "sur_order" then
			table.sort(t, function(a,b) return a.sur < b.sur or (a.sur == b.sur and a.hp < b.hp) end)
		else
			table.sort(t, function(a,b) return a.index < b.index end)
		end
		if t[1] and t[1]["name"] then
			return t[1]["name"]
		end
	end
end

local function MyBuffCheck(i)
	if SH_CDB["Logic"][i]["self_buff"] then
		if SH_CDB["Logic"][i]["self_buff_logic"] == "any" then -- 拥有任意Hot
			for spellID in pairs(SH_CDB["Logic"][i]["enable_buffs"]) do
				local hot = GetSpellInfo(spellID)
				if AuraUtil.FindAuraByName(hot, "player", "HELPFUL") then
					return true
				end
			end
		else -- 拥有全部Hot
			local lack_hot_num = 0
			for spellID in pairs(SH_CDB["Logic"][i]["enable_buffs"]) do
				local hot = GetSpellInfo(spellID)
				if not AuraUtil.FindAuraByName(hot, "player", "HELPFUL") then
					lack_hot_num = lack_hot_num + 1
					break
				end
			end
			if lack_hot_num == 0 then
				return true
			end
		end
	else
		return true
	end
end

local function MySpellCheck(i)
	if SH_CDB["Logic"][i]["self_spell"] then
		local spellID = SH_CDB["Logic"][i]["enable_spell"]
		if not IsSpellKnown(spellID) and not IsSpellKnown(FindBaseSpellByID(spellID)) then			
			return 
		end
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
	else
		return true
	end
end

local function MyItemCheck(i)
	if SH_CDB["Logic"][i]["self_item"] then
		local itemID = SH_CDB["Logic"][i]["enable_item"]
		if IsEquippedItem(itemID) then
			local start, duration = GetItemCooldown(itemID)
			if start and duration < 2 then
				return true
			end
		end
	else
		return true
	end
end

local function MyTalentsCheck(i)
	if SH_CDB["Logic"][i]["self_talent"] then
		if SH_CDB["Logic"][i]["self_talent_logic"] == "any" then -- 拥有任意天赋
			for talent_info in pairs(SH_CDB["Logic"][i]["enable_talents"]) do
				local group, talent_id = string.split("_", talent_info)
				local selected = select(4, GetTalentInfoByID(talent_id, group))
				if selected then
					return true
				end
			end
		else -- 拥有全部天赋
			local lack_talent_num = 0
			for talent_info in pairs(SH_CDB["Logic"][i]["enable_talents"]) do
				local group, talent_id = string.split("_", talent_info)
				local selected = select(4, GetTalentInfoByID(talent_id, group))
				if not selected then
					lack_talent_num = lack_talent_num + 1
					break
				end
			end
			if lack_talent_num == 0 then
				return true
			end
		end
	else
		return true
	end
end

local function MyHealthCheck(i)
	if SH_CDB["Logic"][i]["self_myhealth"] then
		local health = UnitHealth("player")
		local absorb = UnitGetTotalAbsorbs("player")
		local max_health = UnitHealthMax("player")
		local perc = floor((health + absorb)/max_health*100)
		if perc >= SH_CDB["Logic"][i]["self_myhealth_value"] then
			return true
		end
	else
		return true
	end
end

local function HolyPowerCheck(i)
	if SH_CDB["Logic"][i]["self_holypower"] then
		local power = UnitPower("player", 9)		
		if power >= SH_CDB["Logic"][i]["self_holypower_value"] then
			return true
		end
	else
		return true
	end
end

F.CheckMyState = function(i) 
	if MyBuffCheck(i) and MySpellCheck(i) and MyItemCheck(i) and MyTalentsCheck(i) and MyHealthCheck(i) and HolyPowerCheck(i) then
		return true
	end
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
    local hasCell = IsAddOnLoaded("Cell")
	

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
		
	elseif hasCell then
        for i =1, 5 do 
            local f = _G["CellPartyFrameHeaderUnitButton"..i]
            if f and f:IsVisible() and f.state and f.state.unit and UnitName(f.state.unit) == target then
                addIcon(f, action, spellID)
                return
            end
        end
		for i=1, 4 do
            for j=1, 5 do
                local f = _G["CellGroupHeaderSubGroup"..i.."UnitButton"..j]
                if f and f:IsVisible() and f.state and f.state.unit and UnitName(f.state.unit) == target then
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

F.GetIconLink = function(spellID)
	if not spellID then return end
	if not GetSpellInfo(spellID) then
		print(spellID.."出错 请检查")
		return spellID.."出错"
	end
	local icon = select(3, GetSpellInfo(spellID))
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t"..GetSpellLink(spellID)
end

F.GetSmartSpell = function()
	if UnitGroupRolesAssigned("player") ~= "HEALER" then return end
	
	G.current_spell, G.current_target = nil, nil
	
	for i in pairs(SH_CDB["Logic"]) do
		if F.CheckMyState(i) then
			local target = F.GetTarget(i)
			if target then
				G.current_target = target
				if SH_CDB["Logic"][i]["use_custom_icon"] then
					G.current_spell = SH_CDB["Logic"][i]["custom_icon"]
				else
					G.current_spell = SH_CDB["Logic"][i]["select_icon"]
				end
				break
			end
		end
	end
	
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
		if G.current_spell and SH_CDB["Layout"]["test"] then
			print(F.GetIconLink(G.current_spell), G.current_target)
		end
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
				C_Timer.After(.2, function() F.GetSmartSpell() end)
				C_Timer.After(dur, function() G.InGCD = false end)
			end
		else
			F.GetSmartSpell()
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