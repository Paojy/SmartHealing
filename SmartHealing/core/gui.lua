local addon_name, ns = ...
local F, G, L = unpack(ns)

if not G.Healers[G.myClass] then return end

local NewLogicOption = {}
local current
----------------------------------------------------------
-----------------[[        API        ]]------------------
----------------------------------------------------------
F.createUIPanelButton = function(parent, name, width, height, text)
	local button = CreateFrame("Button", name, parent)
	button:SetSize(width, height)
	F.createborder(button)	
	
	button.text = F.createtext(button, "OVERLAY", 12, "OUTLINE", "CENTER")
	button.text:SetText(text)
	button.text:SetPoint("CENTER")

	button:SetScript("OnEnter", function()
		button.text:SetTextColor(1, 1, 0)
		button.sd:SetBackdropColor(1, 1, 0, 0.2)
		button.sd:SetBackdropBorderColor(1, 1, 0)
	end)
 	button:SetScript("OnLeave", function()
		button.text:SetTextColor(1, 1, 1)
		button.sd:SetBackdropColor(0, 0, 0, .3)
		button.sd:SetBackdropBorderColor(0, 0, 0)
	end)
	button:SetScript("OnDisable", function()
		button.text:SetTextColor(.3, .3, .3)
	end)
	button:SetScript("OnEnable", function()
		button.text:SetTextColor(1, 1, 1)
	end)
	
	return button
end

local ReskinSlider = function(f)
	f:SetBackdrop(nil)
	f.SetBackdrop = function() end

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 14, -2)
	bd:SetPoint("BOTTOMRIGHT", -15, 3)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.createborder(bd, 0, .5, .5)
	
	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			region:SetBlendMode("ADD")
			break
		end
	end
end

local function TestSlider_OnValueChanged(self, value)
   if not self._onsetting then   -- is single threaded 
     self._onsetting = true
     self:SetValue(self:GetValue())
     value = self:GetValue()     -- cant use original 'value' parameter
     self._onsetting = false
   else return end               -- ignore recursion for actual event handler
 end

local createslider = function(parent, name, t, value, min, max, step, ...)
	local slider = CreateFrame("Slider", addon_name..t..value.."Slider", parent, "OptionsSliderTemplate")
	slider:SetPoint(...)
	slider:SetWidth(180)
	
	ReskinSlider(slider)
	BlizzardOptionsPanel_Slider_Enable(slider)
	
	slider:SetMinMaxValues(min, max)
	_G[slider:GetName()..'Low']:SetText(min)
	_G[slider:GetName()..'Low']:ClearAllPoints()
	_G[slider:GetName()..'Low']:SetPoint("RIGHT", slider, "LEFT", 10, 0)
	_G[slider:GetName()..'Low']:SetJustifyH("RIGHT")
	_G[slider:GetName()..'High']:SetText(max)
	_G[slider:GetName()..'High']:ClearAllPoints()
	_G[slider:GetName()..'High']:SetPoint("LEFT", slider, "RIGHT", -10, 0)
	_G[slider:GetName()..'High']:SetJustifyH("LEFT")
	_G[slider:GetName()..'Text']:ClearAllPoints()
	_G[slider:GetName()..'Text']:SetPoint("BOTTOM", slider, "TOP", 0, 3)
	_G[slider:GetName()..'Text']:SetTextColor(1, 1, 1)
	_G[slider:GetName()..'Text']:SetFontObject(GameFontHighlight)	
	
	slider:SetValueStep(step)
	
	slider:SetScript("OnShow", function(self)
		self:SetValue(SH_CDB[t][value])
		_G[slider:GetName()..'Text']:SetText(name.." "..SH_CDB[t][value])
	end)
	
	slider:SetScript("OnValueChanged", function(self, getvalue)
		SH_CDB[t][value] = getvalue
		TestSlider_OnValueChanged(self, getvalue)
		_G[slider:GetName()..'Text']:SetText(name.." "..SH_CDB[t][value])
		if slider.apply then
			slider:apply()
		end
	end)
	
	return slider	
end

local ReskinCheck = function(f)
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture(G.media.blank)
	
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 4, -4)
	hl:SetPoint("BOTTOMRIGHT", -4, 4)
	hl:SetVertexColor(1, 1, 1, .2)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	if f:GetFrameLevel() > 0 then
		bd:SetFrameLevel(f:GetFrameLevel()-1)
	end
	F.createborder(bd, 0, .5, .5)
	
	local tex = f:CreateTexture(nil, "BORDER")
	tex:SetTexture(G.media.blank)
	tex:SetVertexColor(.5, .5, .5, .3)
	tex:SetPoint("TOPLEFT", 4, -4)
	tex:SetPoint("BOTTOMRIGHT", -4, 4)

	local ch = f:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(0, 1, 0)
end

local createcheckbutton = function(parent, name, t, value, ...)
	local bu = CreateFrame("CheckButton", addon_name..t..value.."Button", parent, "InterfaceOptionsCheckButtonTemplate")	
	bu:SetPoint(...)
	bu:SetHitRectInsets(0, -50, 0, 0)
	ReskinCheck(bu)
	_G[bu:GetName() .. "Text"]:SetText(name)
	
	bu.t = t
	bu.value = value
	
	bu:SetScript("OnShow", function(self) self:SetChecked(SH_CDB[t][value]) end)
	bu:SetScript("OnClick", function(self)
		if self:GetChecked() then
			SH_CDB[t][value] = true
		else
			SH_CDB[t][value] = false
		end
		if bu.apply then
			bu:apply()
		end
	end)	
	
	return bu
end

local ReskinRadio = function(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetCheckedTexture(G.media.blank)
	
	local ch = f:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", 4, -4)
	ch:SetPoint("BOTTOMRIGHT", -4, 4)

	local bd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	bd:SetPoint("TOPLEFT", 3, -3)
	bd:SetPoint("BOTTOMRIGHT", -3, 3)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	F.createborder(bd)
	f.bd = bd
	
	local tex = f:CreateTexture(nil, "BORDER")
	tex:SetTexture(G.media.blank)
	tex:SetVertexColor(.5,.5,.5,.5)
	tex:SetPoint("TOPLEFT", 3, -3)
	tex:SetPoint("BOTTOMRIGHT", -3, 3)
	
	f:HookScript("OnEnter", function() f.bd:SetBackdropBorderColor(0, 1, 0) end)
	f:HookScript("OnLeave", function() f.bd:SetBackdropBorderColor(0, 0, 0) end)
end

local createradiobuttongroup = function(parent, t, value, group, ...)
	local frame = CreateFrame("Frame", addon_name..t..value.."RadioButtonGroup", parent)
	frame:SetPoint(...)
	frame:SetSize(150, 30)
	
	for i = 1, #group do
		local k = group[i][1]
		local v = group[i][2]
		
		frame[k] = CreateFrame("CheckButton", addon_name..t..value..k.."RadioButtonGroup", frame, "UIRadioButtonTemplate")
		ReskinRadio(frame[k])
		_G[frame[k]:GetName() .. "Text"]:SetText(v)
		
		frame[k]:SetScript("OnShow", function(self)
			self:SetChecked(SH_CDB[t][value] == k)
		end)
		
		frame[k]:SetScript("OnClick", function(self)
			if self:GetChecked() then
				SH_CDB[t][value] = k
				if frame.apply then
					frame:apply()
				end
			else
				self:SetChecked(true)
			end
		end)
	end
	
	for i = 1, #group do
	
		local k = group[i][1]
		
		frame[k]:HookScript("OnClick", function(self)
			if SH_CDB[t][value] == k then
				for index = 1, #group do
					local j = group[index][1]
					if j ~= k then
						frame[j]:SetChecked(false)
					end
				end
			end
		end)
	end
	
	local buttons = {frame:GetChildren()}
	for i = 1, #buttons do
		if i == 1 then
			buttons[i]:SetPoint("LEFT", frame, "LEFT", 0, 0)
		else
			buttons[i]:SetPoint("LEFT", _G[buttons[i-1]:GetName() .. "Text"], "RIGHT", 5, 0)
		end
	end
	
	return frame
end

local ReskinScroll = function(f)
	local frame = f:GetName()
    
	local bu = (f.ThumbTexture or f.thumbTexture) or _G[frame.."ThumbTexture"]
	bu:SetAlpha(0)
	bu:SetWidth(17)

	F.createbdframe(bu)
	
	local up, down = f:GetChildren()
	
	up:SetWidth(17)
	F.createbdframe(up)
	up:SetNormalTexture("")
	up:SetHighlightTexture("")
	up:SetPushedTexture("")
	up:SetDisabledTexture(G.media.blank)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .4)
	dis1:SetDrawLayer("OVERLAY")
	
	local uptex = up:CreateTexture(nil, "ARTWORK")
	uptex:SetTexture(G.media.arrowUp)
	uptex:SetSize(8, 8)
	uptex:SetPoint("CENTER")
	uptex:SetVertexColor(1, 1, 1)
	up.bgTex = uptex
	
	up:HookScript("OnEnter", function(f) 
		if f:IsEnabled() then
			f.bgTex:SetVertexColor(1, 1, 0)
		end
	end)
	up:HookScript("OnLeave", function(f) 
		f.bgTex:SetVertexColor(1, 1, 1)
	end)
	
	down:SetWidth(17)
	F.createbdframe(down)
	down:SetNormalTexture("")
	down:SetHighlightTexture("")
	down:SetPushedTexture("")
	down:SetDisabledTexture(G.media.blank)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .4)
	dis2:SetDrawLayer("OVERLAY")
	
	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture(G.media.arrowDown)
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)
	down.bgTex = downtex

	down:HookScript("OnEnter", function(f) 
		if f:IsEnabled() then
			f.bgTex:SetVertexColor(1, 1, 0)
		end
	end)
	down:HookScript("OnLeave", function(f) 
		f.bgTex:SetVertexColor(1, 1, 1)
	end)
	
end

F.CreateOptions = function(text, name, parent, scroll, x, r, g, b)
	local options = CreateFrame("Frame", name, parent)
	options:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -45)
	options:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
	options:Hide()
	F.createborder(options, r, g, b)

	local tab = parent["tab"..parent.tabindex]
	tab.n = parent.tabindex
	tab:SetFrameLevel(parent:GetFrameLevel()+2)

	F.createborder(tab, .2, .5, .4)

	tab.name = F.createtext(tab, "OVERLAY", 12, "OUTLINE", "CENTER")
	tab.name:SetText(text)
	tab.name:SetPoint("CENTER")
	
	tab:SetSize(130, 25)
	tab:SetPoint("TOPLEFT", parent, "TOPLEFT", x+140*(tab.n-1), -10)
	
	if tab.n == 1 then
		tab.sd:SetBackdropBorderColor(1, 1, 0)
		options:Show()
	end
	
	tab:HookScript("OnMouseDown", function(self)
		options:Show()
		tab.sd:SetBackdropBorderColor(1, 1, 0)
	end)
	
	for i = 1, parent.tabnum do
		if i ~= tab.n then
			parent["tab"..i]:HookScript("OnMouseDown", function(self)
				options:Hide()
				tab.sd:SetBackdropBorderColor(.2, .5, .4)
			end)
		end
	end
	
	parent.tabindex = parent.tabindex +1
	
	if scroll then
		options.sf = CreateFrame("ScrollFrame", name.."ScrollFrame", options, "UIPanelScrollFrameTemplate")
		options.sf:SetPoint("TOPLEFT", options, "TOPLEFT", 10, -10)
		options.sf:SetPoint("BOTTOMRIGHT", options, "BOTTOMRIGHT", -35, 57)
		options.sf:SetFrameLevel(options:GetFrameLevel()+1)

		options.sfa = CreateFrame("Frame", name.."ScrollAnchor", options.sf)
		options.sfa:SetPoint("TOPLEFT", options.sf, "TOPLEFT", 0, -3)
		options.sfa:SetWidth(options.sf:GetWidth()-20)
		options.sfa:SetHeight(options.sf:GetHeight())
		options.sfa:SetFrameLevel(options.sf:GetFrameLevel()+1)
		
		options.sf:SetScrollChild(options.sfa)
		options.sf.mobs = {}
		
		ReskinScroll(_G[name.."ScrollFrameScrollBar"])
	end
	
	return options
end

local CreateLine = function(frame, anchor, x, y)
	local line = frame:CreateTexture(nil, "ARTWORK")
	line:SetSize(frame:GetWidth()-20, 1)
	line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
	line:SetColorTexture(1, 1, 1, .2)
end

local CreateTextInfo = function(frame, anchor, x, y, t, height)
	local text = F.createtext(frame, "OVERLAY", 12, "OUTLINE", "LEFT")
	text:SetWidth(frame:GetWidth()-20)
	if height then
		text:SetHeight(12*height)
	end
	text:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
	text:SetText(t)
	return text
end
----------------------------------------------------------
-----------------[[        GUI        ]]------------------
----------------------------------------------------------

local gui = CreateFrame("Frame", G.addon_name.."_GUI", UIParent)
gui:SetSize(1000, 600)
gui:SetScale(1)
gui:SetPoint("CENTER", UIParent, "CENTER")
gui:SetFrameStrata("HIGH")
gui:SetFrameLevel(2)
gui:Hide()

gui:RegisterForDrag("LeftButton")
gui:SetScript("OnDragStart", function(self) self:StartMoving() end)
gui:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
gui:SetClampedToScreen(true)
gui:SetMovable(true)
gui:SetUserPlaced(true)
gui:EnableMouse(true)
F.createborder(gui)

gui.title = F.createtext(gui, "OVERLAY", 15, "OUTLINE", "CENTER")
gui.title:SetPoint("BOTTOM", gui, "TOP", 0, -5)
gui.title:SetText(G.addon_name.." "..G.Version)

gui.close = CreateFrame("Button", nil, gui)
gui.close:SetPoint("BOTTOMRIGHT", -3, 3)
gui.close:SetSize(20, 20)
gui.close:SetNormalTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
gui.close:SetHighlightTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Highlight")
gui.close:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Down")
gui.close:SetScript("OnClick", function() gui:Hide() end)

gui.refresh = CreateFrame("Button", nil, gui)
gui.refresh:SetPoint("RIGHT", gui.close, "LEFT", -5, 0)
gui.refresh:SetSize(20, 20)
gui.refresh:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
gui.refresh:SetScript("OnMouseDown", function(self) self:GetNormalTexture():SetVertexColor(0,1,0)  end)
gui.refresh:SetScript("OnMouseUp", function(self) self:GetNormalTexture():SetVertexColor(1,1,1) end)
gui.refresh:SetScript("OnClick", function() F.GetSmartSpell() end)

gui.logo = gui:CreateTexture(nil, "OVERLAY")
gui.logo:SetSize(280, 300)
gui.logo:SetTexCoord( 0, .5, .2, .8)
gui.logo:SetAlpha(.4)
gui.logo:SetPoint("BOTTOMRIGHT", gui, "BOTTOMRIGHT", 0, 0)
gui.logo:SetTexture(G.media.logo)

G.gui = gui

----------------------------------------------------------
-----------------[[     通用设置     ]]-------------------
----------------------------------------------------------
local options = CreateFrame("Frame", addon_name.."General Settings", gui)
options:SetPoint("TOPLEFT", gui, "TOPLEFT", 10, -10)
options:SetPoint("BOTTOMRIGHT", gui, "BOTTOMLEFT", 260, 10)
F.createborder(options)

options.title = F.createtext(options, "OVERLAY", 15, "OUTLINE", "CENTER")
options.title:SetText(L["通用"])
options.title:SetPoint("TOPLEFT", options, "TOPLEFT", 20, -20)

CreateLine(options, options.title, -10, -5)

local Raidframe = CreateFrame("Frame", nil, options)
Raidframe:SetSize(120, 80)
Raidframe:SetPoint("TOPLEFT", 50, -80)
F.createborder(Raidframe, .2, .5, .4)

Raidframe.text = F.createtext(Raidframe, "OVERLAY", 14, "OUTLINE", "CENTER")
Raidframe.text:SetText(L["锚点"])
Raidframe.text:SetPoint("BOTTOM", Raidframe, "TOP", 0, 10)

local anchors = {"CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

for index, key in pairs(anchors) do
	local ind = CreateFrame("Button", nil, Raidframe)
	ind:SetSize(15, 15)
	ind:SetPoint(key, Raidframe, key)
	F.createborder(ind, 1, 1, 1)
	Raidframe[key] = ind
	
	ind.update = function()
		if SH_CDB["Layout"]["anchor"] == key then
			ind.sd:SetBackdropColor(1, 1, 0, .8)
			ind.sd:SetBackdropBorderColor(1, 1, 0, 1)
		else
			ind.sd:SetBackdropColor(1, 1, 1, .5)
			ind.sd:SetBackdropBorderColor(1, 1, 1, 1)
		end
	end
	
	ind:SetScript("OnShow", ind.update)
	
	ind:SetScript("OnClick", function()
		SH_CDB["Layout"]["anchor"] = key
		for i, k in pairs(anchors) do
			Raidframe[k].update()
		end
		F.EditIcons("anchor")
	end)
end

local size_slider = createslider(options, L["图标大小"], "Layout", "size", 20, 40, 2, "TOPLEFT", Raidframe, "BOTTOMLEFT", -20, -30)
size_slider.apply = function() F.EditIcons("size") end

local glow_bu = createcheckbutton(options, L["发光"], "Layout", "glow", "TOPLEFT", size_slider, "BOTTOMLEFT", 10, -20)
glow_bu.apply = function() F.EditIcons("glow") end

local test_bu = createcheckbutton(options, L["测试"], "Layout", "test", "TOPLEFT", glow_bu, "BOTTOMLEFT", 0, -20)

local reset_bu = F.createUIPanelButton(options, "reset", 240, 30, L["重置所有设置"])
reset_bu:SetPoint("BOTTOM", options, "BOTTOM", 0, 10)

StaticPopupDialogs[addon_name.."Reset Confirm"] = {
	text = L["重置确认"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	OnAccept = function()
		SH_CDB = {}
		ReloadUI()
	end
}

reset_bu:SetScript("OnClick", function()
	StaticPopup_Show(addon_name.."Reset Confirm")
end)

local import_bu = F.createUIPanelButton(options, "import", 240, 30, L["导入设置"])
import_bu:SetPoint("BOTTOM", reset_bu, "TOP", 0, 5)

StaticPopupDialogs[addon_name.."Import"] = {
	text = L["导入"],
	hasEditBox = true,
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		F.ImportSettings(text)
	end,
}

import_bu:SetScript("OnClick", function()
	StaticPopup_Show(addon_name.."Import")
end)

local export_bu = F.createUIPanelButton(options, "export", 240, 30, L["导出设置"])
export_bu:SetPoint("BOTTOM", import_bu, "TOP", 0, 5)

StaticPopupDialogs[addon_name.."Export"] = {
	text = L["导出"],
	hasEditBox = true,
	hideOnEscape = 1, 
	whileDead = true,
	button2 = CANCEL,
	OnShow = function(self)
		local str = F.GetExportString()
		self.editBox:SetText(str)
		self.editBox:HighlightText()
	end
}

export_bu:SetScript("OnClick", function()
	StaticPopup_Show(addon_name.."Export")
end)
----------------------------------------------------------
--------------------[[     逻辑     ]]--------------------
----------------------------------------------------------

gui.tabindex = 1
gui.tabnum = 4
for i = 1, 4 do
	gui["tab"..i] = CreateFrame("Frame", addon_name.."GUI Tab"..i, gui)
	gui["tab"..i]:SetScript("OnMouseDown", function() end)
end

local heal_logic = F.CreateOptions(L["逻辑"], addon_name.."heal_logic", gui, true, 270, .05, .05, .05)
local createnew = F.createUIPanelButton(heal_logic.sfa, "createnew", 200, 30, L["新增"])
createnew:SetScript("OnClick", function()
	for i = 1, 5 do
		NewLogicOption[i].create_bu:Show()
		NewLogicOption[i].edit_bu:Hide()
	end
	for k, v in pairs(SH_CDB["Add"]) do
		if type(G.Character_default_Settings["Add"][k]) == "table" then
			SH_CDB["Add"][k] = {}
		else
			SH_CDB["Add"][k] = G.Character_default_Settings["Add"][k]
		end
	end
	for i = 1, 5 do
		if i == 1 then
			_G[addon_name.."new_logic"]["tab"..i].sd:SetBackdropBorderColor(1, 1, 0)
			NewLogicOption[i]:Show()
		else
			_G[addon_name.."new_logic"]["tab"..i].sd:SetBackdropBorderColor( .2, .5, .4)
			NewLogicOption[i]:Hide()
		end
	end
	heal_logic.sf:Hide()
	_G[addon_name.."new_logic"]:Show()	
end)

local function UpdateHealLogic()
	for i, t in pairs(SH_CDB["Logic"]) do
		local raid, self, target, order, icon = "", "", "", "", ""
		
		-- 团队条件
		if SH_CDB["Logic"][i]["raid_sur"] then
			raid = string.format(L["生存系数描述"], SH_CDB["Logic"][i]["raid_sur_num"], "", SH_CDB["Logic"][i]["raid_sur_value"])
		elseif SH_CDB["Logic"][i]["raid_sur_melee"] then
			raid = string.format(L["生存系数描述"], SH_CDB["Logic"][i]["raid_sur_melee_num"], MELEE, SH_CDB["Logic"][i]["raid_sur_melee_value"])
		elseif SH_CDB["Logic"][i]["raid_sur_ranged"] then
			raid = string.format(L["生存系数描述"], SH_CDB["Logic"][i]["raid_sur_ranged_num"], RANGED, SH_CDB["Logic"][i]["raid_sur_ranged_value"])
		elseif SH_CDB["Logic"][i]["raid_sur_tank"] then
			raid = string.format(L["生存系数描述"], SH_CDB["Logic"][i]["raid_sur_tank_num"], TANK, SH_CDB["Logic"][i]["raid_sur_tank_value"])
		elseif SH_CDB["Logic"][i]["raid_icd"] then
			raid = string.format(L["预估伤害描述"], SH_CDB["Logic"][i]["raid_icd_num"])
		elseif SH_CDB["Logic"][i]["raid_hot"] and not F.IsEmpty(SH_CDB["Logic"][i]["raid_hot_spells"]) then
			for spellid in pairs(SH_CDB["Logic"][i]["raid_hot_spells"]) do
				raid = raid..F.GetSpellIconLink(spellid)
			end
			raid = string.format(L["团队增益描述"], SH_CDB["Logic"][i]["target_lackhot_logic"] == "any" and L["任意"] or L["所有"], raid, SH_CDB["Logic"][i]["raid_hot_logic"] == "morethan" and L["大于"] or L["小于"], SH_CDB["Logic"][i]["raid_hot_num"])
		elseif SH_CDB["Logic"][i]["raid_hot_lack"] and SH_CDB["Logic"][i]["raid_hot_lack_spellid"] then
			raid = raid..string.format(L["团队缺少增益描述"], SH_CDB["Logic"][i]["raid_hot_lack_value"], F.GetSpellIconLink(SH_CDB["Logic"][i]["raid_hot_lack_spellid"]), SH_CDB["Logic"][i]["raid_hot_lack_num"])
		else
			raid = L["忽略"]..L["团队条件"].."，"
		end
		-- 自身条件
		if SH_CDB["Logic"][i]["self_buff"] and not F.IsEmpty(SH_CDB["Logic"][i]["enable_buffs"]) then
			local mybuffs = ""
			for spellid in pairs(SH_CDB["Logic"][i]["enable_buffs"]) do
				mybuffs = mybuffs..F.GetSpellIconLink(spellid)
			end
			self = self..string.format(L["我的增益描述"], SH_CDB["Logic"][i]["self_buff_logic"] == "any" and L["任意"] or L["所有"], mybuffs)
		end
		if SH_CDB["Logic"][i]["self_spell"] and SH_CDB["Logic"][i]["enable_spell"] ~= 0 then
			self = self..string.format(L["我的技能描述"], F.GetSpellIconLink(SH_CDB["Logic"][i]["enable_spell"]))
		end
		if SH_CDB["Logic"][i]["self_item"] and SH_CDB["Logic"][i]["enable_item"] ~= 0 then
			self = self..string.format(L["我的物品描述"], F.GetItemIconLink(SH_CDB["Logic"][i]["enable_item"]))
		end
		if SH_CDB["Logic"][i]["self_talent"] and not F.IsEmpty(SH_CDB["Logic"][i]["enable_talents"]) then
			local mytalents = ""
			for talent_info in pairs(SH_CDB["Logic"][i]["enable_talents"]) do
				local group, talent_id = string.split("_", talent_info)
				local talent = F.GetSpellIconLink(select(6, GetTalentInfoByID(talent_id, group)))
				mytalents = mytalents..talent
			end
			self = self..string.format(L["我的天赋描述"], SH_CDB["Logic"][i]["self_talent_logic"] == "any" and L["任意"] or L["所有"], mytalents)
		end
		if SH_CDB["Logic"][i]["self_myhealth"] then
			self = self..string.format(L["我的有效血量描述"], SH_CDB["Logic"][i]["self_myhealth_value"])
		end
		if SH_CDB["Logic"][i]["self_holypower"] then
			self = self..string.format(L["我的圣能描述"], SH_CDB["Logic"][i]["self_holypower_value"])
		end		
		-- 目标条件
		if (SH_CDB["Logic"][i]["target_lackhot"] and not F.IsEmpty(SH_CDB["Logic"][i]["target_lackhots"])) or (SH_CDB["Logic"][i]["target_hashot"] and not F.IsEmpty(SH_CDB["Logic"][i]["target_hashots"])) then
			if SH_CDB["Logic"][i]["target_lackhot"] and not F.IsEmpty(SH_CDB["Logic"][i]["target_lackhots"]) then
				target = target..string.format(L["缺少增益描述"], SH_CDB["Logic"][i]["target_lackhot_logic"] == "any" and L["任意"] or L["所有"])
				for spellid in pairs(SH_CDB["Logic"][i]["target_lackhots"]) do
					local spell = F.GetSpellIconLink(spellid)
					target = target..spell
				end
			end
			if SH_CDB["Logic"][i]["target_hashot"] and not F.IsEmpty(SH_CDB["Logic"][i]["target_hashots"]) then
				target = target..string.format(L["拥有增益描述"], SH_CDB["Logic"][i]["target_hashot_logic"] == "any" and L["任意"] or L["所有"])
				for spellid in pairs(SH_CDB["Logic"][i]["target_hashots"]) do
					local spell = F.GetSpellIconLink(spellid)
					target = target..spell
				end
			end
			target = string.format(L["目标角色描述"], target)
		end
		
		order = string.format(L["顺序描述"], SH_CDB["Logic"][i]["target_rolefilter"] == false and L["所有队友"] or SH_CDB["Logic"][i]["target_role"] == "me" and L["我"] or SH_CDB["Logic"][i]["target_role"] == "exceptme" and L["除我之外"] or SH_CDB["Logic"][i]["target_role"] == "tank" and L["坦克"] or SH_CDB["Logic"][i]["target_role"] == "excepttank" and L["除坦克之外"], (SH_CDB["Logic"][i]["order_logic"] == "sur_order" and L["生存系数"]) or L["队列位置"], target)

		-- 图标
		local icontex
		if SH_CDB["Logic"][i]["use_custom_icon"] then
			icontex = select(3, GetSpellInfo(SH_CDB["Logic"][i]["custom_icon"]))
		else
			icontex = select(3, GetSpellInfo(SH_CDB["Logic"][i]["select_icon"]))
		end
		icon = string.format(L["图标描述"], icontex)

		local str = raid..self..order..icon
		
		if not heal_logic.sfa["l"..i] then
			local f = CreateFrame("Frame", addon_name.."heal_logic"..i, heal_logic.sfa)
			f:SetSize(640, 100)
			F.createborder(f, .2, .5, .4)
			
			f.index = F.createtext(f, "OVERLAY", 12, "OUTLINE", "LEFT")
			f.index:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -10)
			f.index:SetTextColor(0,1,1)
			f.index:SetText(i)
			
			f.text = F.createtext(f, "OVERLAY", 12, "OUTLINE", "LEFT")
			f.text:SetJustifyV("TOP")
			f.text:SetSize(600, 80)
			f.text:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -25)
			
			f.previous_bu = F.createUIPanelButton(f, "previous", 10, 40, "↑")
			f.previous_bu:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
			f.previous_bu:SetScript("OnClick", function()
				table.insert(SH_CDB["Logic"], i-1, SH_CDB["Logic"][i])
				table.remove(SH_CDB["Logic"], i+1)
				heal_logic:Hide()
				heal_logic:Show()
			end)
			
			f.next_bu = F.createUIPanelButton(f, "next", 10, 40, "↓")
			f.next_bu:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)
			f.next_bu:SetScript("OnClick", function()
				table.insert(SH_CDB["Logic"], i+2, SH_CDB["Logic"][i])
				table.remove(SH_CDB["Logic"], i)
				heal_logic:Hide()
				heal_logic:Show()
			end)
			
			f.delete_bu = F.createUIPanelButton(f, "delete", 40, 15, L["删除"])
			f.delete_bu:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 5)
			f.delete_bu:SetScript("OnClick", function()
				table.remove(SH_CDB["Logic"], i)
				heal_logic.sfa["l"..#SH_CDB["Logic"]+1]:Hide()
				heal_logic:Hide()
				heal_logic:Show()
			end)
			
			f.copy_bu = F.createUIPanelButton(f, "copy", 40, 15, L["复制"])
			f.copy_bu:SetPoint("LEFT", f.delete_bu, "RIGHT", 5, 0)
			f.copy_bu:SetScript("OnClick", function()
				for k, v in pairs(SH_CDB["Logic"][i]) do
					SH_CDB["Add"][k] = v
				end
				heal_logic.sf:Hide()
				_G[addon_name.."new_logic"]:Show()
				for index = 1, 5 do
					if index == 1 then
						_G[addon_name.."new_logic"]["tab"..index].sd:SetBackdropBorderColor(1, 1, 0)
						NewLogicOption[index]:Show()
					else
						_G[addon_name.."new_logic"]["tab"..index].sd:SetBackdropBorderColor( .2, .5, .4)
						NewLogicOption[index]:Hide()
					end
					NewLogicOption[index].edit_bu:Hide()
					NewLogicOption[index].create_bu:Show()
				end
			end)
			
			f.edit_bu = F.createUIPanelButton(f, "edit", 40, 15, L["编辑"])
			f.edit_bu:SetPoint("LEFT", f.copy_bu, "RIGHT", 5, 0)
			f.edit_bu:SetScript("OnClick", function()
				current = i
				for k, v in pairs(SH_CDB["Logic"][i]) do
					SH_CDB["Add"][k] = v
				end
				heal_logic.sf:Hide()
				_G[addon_name.."new_logic"]:Show()
				for index = 1, 5 do
					if index == 1 then
						_G[addon_name.."new_logic"]["tab"..index].sd:SetBackdropBorderColor(1, 1, 0)
						NewLogicOption[index]:Show()
					else
						_G[addon_name.."new_logic"]["tab"..index].sd:SetBackdropBorderColor(.2, .5, .4)
						NewLogicOption[index]:Hide()
					end
					NewLogicOption[index].edit_bu:Show()
					NewLogicOption[index].create_bu:Hide()
				end
			end)
			
			f:SetPoint("TOPLEFT", heal_logic.sfa, "TOPLEFT", 10, -20-(i-1)*110)
			
			heal_logic.sfa["l"..i] = f
		end
		
		if i == 1 then
			heal_logic.sfa["l"..i].previous_bu:Disable()
		else
			heal_logic.sfa["l"..i].previous_bu:Enable()
		end
		if i == #SH_CDB["Logic"] then
			heal_logic.sfa["l"..i].next_bu:Disable()
		else
			heal_logic.sfa["l"..i].next_bu:Enable()
		end
		
		heal_logic.sfa["l"..i]:Show()
		heal_logic.sfa["l"..i].text:SetText(str)
	end
	if #SH_CDB["Logic"] >= 1 then
		createnew:SetPoint("TOP", heal_logic.sfa["l"..#SH_CDB["Logic"]], "BOTTOM", 0, -20)
	else
		createnew:SetPoint("TOP", heal_logic.sfa, "TOP", 0, -20)
	end
end

heal_logic.sfa:SetScript("OnShow", UpdateHealLogic)
----------------------------------------------------------
--------------------[[     新增     ]]--------------------
----------------------------------------------------------

local new_logic = CreateFrame("Frame", addon_name.."new_logic", heal_logic)
new_logic:SetAllPoints()
new_logic:Hide()
F.createborder(new_logic, .05, .05, .05)

new_logic.tabindex = 1
new_logic.tabnum = 5
for i = 1, 5 do
	new_logic["tab"..i] = CreateFrame("Frame", addon_name.."NewLogic Tab"..i, new_logic)
	new_logic["tab"..i]:SetScript("OnMouseDown", function() end)
end

local CreateNewLogicOptions = function(index, text)

	local options = F.CreateOptions(text, addon_name.."new_logic"..index, new_logic, true, 10, .2, .5, .4)
	
	options.previous_bu = F.createUIPanelButton(options, "previous", 160, 30, L["上一项"])
	options.previous_bu:SetPoint("BOTTOMLEFT", options, "BOTTOMLEFT", 10, 10)
	
	options.next_bu = F.createUIPanelButton(options, "next", 160, 30, L["下一项"])
	options.next_bu:SetPoint("LEFT", options.previous_bu, "RIGHT", 10, 0)
	
	options.create_bu = F.createUIPanelButton(options, "create", 160, 30, L["创建"])
	options.create_bu:SetPoint("LEFT", options.next_bu, "RIGHT", 10, 0)

	options.create_bu:SetScript("OnClick", function()
		local t = {}
		for k, v in pairs(SH_CDB["Add"]) do
			t[k] = v
		end
		table.insert(SH_CDB["Logic"], t)
		new_logic:Hide()
		heal_logic.sf:Show()
	end)
	
	options.edit_bu = F.createUIPanelButton(options, "edit", 160, 30, L["编辑"])
	options.edit_bu:SetPoint("LEFT", options.next_bu, "RIGHT", 10, 0)
	options.edit_bu:Hide()
	
	options.edit_bu:SetScript("OnClick", function()
		for k, v in pairs(SH_CDB["Add"]) do
			SH_CDB["Logic"][current][k] = v
		end		
		new_logic:Hide()
		heal_logic.sf:Show()
	end)
	
	options.cancel_bu = F.createUIPanelButton(options, "cancel", 160, 30, CANCEL)
	options.cancel_bu:SetPoint("LEFT", options.create_bu, "RIGHT", 10, 0)

	options.cancel_bu:SetScript("OnClick", function()
		for k, v in pairs(SH_CDB["Add"]) do
			if type(G.Character_default_Settings["Add"][k]) == "table" then
				SH_CDB["Add"][k] = {}
			else
				SH_CDB["Add"][k] = G.Character_default_Settings["Add"][k]
			end
		end
		current = false
		new_logic:Hide()
		heal_logic.sf:Show()
		gui["tab2"].sd:SetBackdropBorderColor(.2, .5, .4)
		gui["tab1"].sd:SetBackdropBorderColor(1, 1, 0)
	end)
	
	NewLogicOption[index] = options
	
	if index == 1 then
		options.previous_bu:Disable()
	else
		options.previous_bu:SetScript("OnClick", function()	
			NewLogicOption[index]:Hide()
			NewLogicOption[index-1]:Show()			
			new_logic["tab"..index].sd:SetBackdropBorderColor(.2, .5, .4)
			new_logic["tab"..index-1].sd:SetBackdropBorderColor(1, 1, 0)
		end)
	end
	
	if index == 5 then 
		options.next_bu:Disable()
	else
		options.next_bu:SetScript("OnClick", function()
			NewLogicOption[index]:Hide()
			NewLogicOption[index+1]:Show()			
			new_logic["tab"..index].sd:SetBackdropBorderColor(.2, .5, .4)
			new_logic["tab"..index+1].sd:SetBackdropBorderColor(1, 1, 0)
		end)
	end
	
end
---------------- 团队条件 ----------------
CreateNewLogicOptions(1, L["团队条件"])
local add_raid = NewLogicOption[1].sfa
add_raid.sur = createcheckbutton(add_raid, RAID.." "..L["生存系数"], "Add", "raid_sur", "TOPLEFT", add_raid, "TOPLEFT", 10, -10)
add_raid.sur_text = CreateTextInfo(add_raid, add_raid.sur, 0, -10, L["生存系数说明"], 2)
add_raid.sur_num = createslider(add_raid, L["人数"], "Add", "raid_sur_num", 1, 6, 1, "TOPLEFT", add_raid.sur_text, "BOTTOMLEFT", 0, -30)
add_raid.sur_value = createslider(add_raid, L["阈值"], "Add", "raid_sur_value", 0, 100, 1, "LEFT", add_raid.sur_num, "RIGHT", 50, 0)
CreateLine(add_raid, add_raid.sur_num, 0, -10)
F.createDR(add_raid.sur, add_raid.sur_num, add_raid.sur_value)

add_raid.sur_melee = createcheckbutton(add_raid, MELEE.." "..L["生存系数"], "Add", "raid_sur_melee", "TOPLEFT", add_raid.sur_num, "BOTTOMLEFT", 0, -20)
add_raid.sur_melee_text = CreateTextInfo(add_raid, add_raid.sur_melee, 0, -10, L["近战生存系数说明"], 2)
add_raid.sur_melee_num = createslider(add_raid, L["人数"], "Add", "raid_sur_melee_num", 1, 6, 1, "TOPLEFT", add_raid.sur_melee_text, "BOTTOMLEFT", 0, -30)
add_raid.sur_melee_value = createslider(add_raid, L["阈值"], "Add", "raid_sur_melee_value", 0, 100, 1, "LEFT", add_raid.sur_melee_num, "RIGHT", 50, 0)
CreateLine(add_raid, add_raid.sur_melee_num, 0, -10)
F.createDR(add_raid.sur_melee, add_raid.sur_melee_num, add_raid.sur_melee_value)

add_raid.sur_ranged = createcheckbutton(add_raid, RANGED.." "..L["生存系数"], "Add", "raid_sur_ranged", "TOPLEFT", add_raid.sur_melee_num, "BOTTOMLEFT", 0, -20)
add_raid.sur_ranged_text = CreateTextInfo(add_raid, add_raid.sur_ranged, 0, -10, L["远程生存系数说明"], 2)
add_raid.sur_ranged_num = createslider(add_raid, L["人数"], "Add", "raid_sur_ranged_num", 1, 6, 1, "TOPLEFT", add_raid.sur_ranged_text, "BOTTOMLEFT", 0, -30)
add_raid.sur_ranged_value = createslider(add_raid, L["阈值"], "Add", "raid_sur_ranged_value", 0, 100, 1, "LEFT", add_raid.sur_ranged_num, "RIGHT", 50, 0)
CreateLine(add_raid, add_raid.sur_ranged_num, 0, -10)
F.createDR(add_raid.sur_ranged, add_raid.sur_ranged_num, add_raid.sur_ranged_value)

add_raid.sur_tank = createcheckbutton(add_raid, TANK.." "..L["生存系数"], "Add", "raid_sur_tank", "TOPLEFT", add_raid.sur_ranged_num, "BOTTOMLEFT", 0, -20)
add_raid.sur_tank_text = CreateTextInfo(add_raid, add_raid.sur_tank, 0, -10, L["坦克生存系数说明"], 2)
add_raid.sur_tank_num = createslider(add_raid, L["人数"], "Add", "raid_sur_tank_num", 1, 6, 1, "TOPLEFT", add_raid.sur_tank_text, "BOTTOMLEFT", 0, -30)
add_raid.sur_tank_value = createslider(add_raid, L["阈值"], "Add", "raid_sur_tank_value", 0, 100, 1, "LEFT", add_raid.sur_tank_num, "RIGHT", 50, 0)
CreateLine(add_raid, add_raid.sur_tank_num, 0, -10)
F.createDR(add_raid.sur_tank, add_raid.sur_tank_num, add_raid.sur_tank_value)

add_raid.icd = createcheckbutton(add_raid, L["预估伤害人数"], "Add", "raid_icd", "TOPLEFT", add_raid.sur_tank_num, "BOTTOMLEFT", 0, -20)
add_raid.icd_text = CreateTextInfo(add_raid, add_raid.icd, 0, -10, L["预估伤害人数说明"], 2)
add_raid.icd_num = createslider(add_raid, L["人数"], "Add", "raid_icd_num", 1, 6, 1, "TOPLEFT", add_raid.icd_text, "BOTTOMLEFT", 0, -30)
CreateLine(add_raid, add_raid.icd_num, 0, -10)
F.createDR(add_raid.icd, add_raid.icd_num)

add_raid.hot = createcheckbutton(add_raid, L["团队增益数量"], "Add", "raid_hot", "TOPLEFT", add_raid.icd_num, "BOTTOMLEFT", 0, -20)
add_raid.hot_text = CreateTextInfo(add_raid, add_raid.hot, 0, -10, L["团队增益数量说明"], 2)

local raid_hashot_logic = {{"any", L["拥有选中任意增益"]}, {"all", L["拥有选中所有增益"]}}
add_raid.raid_hashot_logic_group = createradiobuttongroup(add_raid, "Add", "raid_hashot_logic", raid_hashot_logic, "TOPLEFT", add_raid.hot_text, "BOTTOMLEFT", 0, 0)

add_raid.hframe = CreateFrame("Frame", addon_name.."Raid hot", add_raid)
add_raid.hframe:SetSize(30,30)
add_raid.hframe:SetPoint("TOPLEFT", add_raid.raid_hashot_logic_group, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_hots) do
	local bu = CreateFrame("Button", addon_name.."Raid hot"..spellid, add_raid.hframe)
	bu:SetSize(30,30)
	bu.ID = spellid
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnClick", function()
		if not SH_CDB["Add"]["raid_hot_spells"][spellid] then
			SH_CDB["Add"]["raid_hot_spells"][spellid] = true
		else
			SH_CDB["Add"]["raid_hot_spells"][spellid] = nil
		end
		
		if SH_CDB["Add"]["raid_hot_spells"][spellid] then
			bu.sd:SetBackdropBorderColor(1, 1, 0)
		else
			bu.sd:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	add_raid.hot:HookScript("OnShow", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["raid_hot_spells"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	add_raid.hot:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["raid_hot_spells"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_raid.hframe.last then
		bu:SetPoint("TOPLEFT", add_raid.hframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_raid.hframe.last, "RIGHT", 5, 0)
	end
	
	add_raid.hframe.last = bu
end

local raid_hot_logic = {{"morethan", L["人数"]..L["大于"]}, {"lessthan", L["人数"]..L["小于"]}}
add_raid.raidhot_logic_group = createradiobuttongroup(add_raid, "Add", "raid_hot_logic", raid_hot_logic, "TOPLEFT", add_raid.hframe, "BOTTOMLEFT", 0, -10)
add_raid.hot_num = createslider(add_raid, L["人数"], "Add", "raid_hot_num", 1, 10, 1, "TOPLEFT", add_raid.raidhot_logic_group, "BOTTOMLEFT", 0, -20)
F.createDR(add_raid.hot, add_raid.raid_hashot_logic_group, add_raid.raidhot_logic_group, add_raid.hot_num)

CreateLine(add_raid, add_raid.hot_num, 0, -10)
-- 缺少增益且血量小于某值人数 --

add_raid.hot_lack = createcheckbutton(add_raid, L["缺少增益且血量小于某值人数"], "Add", "raid_hot_lack", "TOPLEFT", add_raid.hot_num, "BOTTOMLEFT", 0, -20)
add_raid.hot_lack_text = CreateTextInfo(add_raid, add_raid.hot_lack, 0, -10, L["缺少增益且血量小于某值人数说明"], 2)

add_raid.lhframe = CreateFrame("Frame", addon_name.."Raid hot", add_raid)
add_raid.lhframe:SetSize(30,30)
add_raid.lhframe:SetPoint("TOPLEFT", add_raid.hot_lack_text, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_hots) do
	local bu = CreateFrame("Button", addon_name.."Raid hot lack"..spellid, add_raid.lhframe)
	bu:SetSize(30,30)
	bu.ID = spellid
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnClick", function()		
		SH_CDB["Add"]["raid_hot_lack_spellid"] = bu.ID
		for i, child in ipairs({add_raid.lhframe:GetChildren()}) do
			if SH_CDB["Add"]["raid_hot_lack_spellid"] == child.ID then
				child.sd:SetBackdropBorderColor(1, 1, 0)
			else
				child.sd:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)

	add_raid.hot_lack:HookScript("OnShow", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["raid_hot_lack_spellid"] == bu.ID then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	add_raid.hot_lack:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["raid_hot_lack_spellid"] == bu.ID then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_raid.lhframe.last then
		bu:SetPoint("TOPLEFT", add_raid.lhframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_raid.lhframe.last, "RIGHT", 5, 0)
	end
	
	add_raid.lhframe.last = bu
end

add_raid.hot_lack_num = createslider(add_raid, L["人数"], "Add", "raid_hot_lack_num", 1, 10, 1, "TOPLEFT", add_raid.lhframe, "BOTTOMLEFT", 0, -30)
add_raid.hot_lack_value = createslider(add_raid, L["阈值"], "Add", "raid_hot_lack_value", 0, 100, 1, "LEFT", add_raid.hot_lack_num, "RIGHT", 30, 0)
add_raid.hot_lack_dur = createslider(add_raid, L["剩余时间"], "Add", "raid_hot_lack_dur", 0, 10, 1, "LEFT", add_raid.hot_lack_value, "RIGHT", 40, 0)
F.createDR(add_raid.hot_lack, add_raid.hot_lack_num, add_raid.hot_lack_value, add_raid.hot_lack_dur)

F.createCR(add_raid.sur, add_raid.sur_melee, add_raid.sur_ranged, add_raid.sur_tank, add_raid.icd, add_raid.hot, add_raid.hot_lack)

---------------- 自身条件 ----------------
local self = CreateNewLogicOptions(2, L["自身条件"])
local add_self = NewLogicOption[2].sfa

add_self.buff = createcheckbutton(add_self, L["我的增益"], "Add", "self_buff", "TOPLEFT", add_self, "TOPLEFT", 10, -10)
add_self.buff_text = CreateTextInfo(add_self, add_self.buff, 0, -10, L["我的增益说明"], 2)

local self_buff_logic = {{"any", L["拥有选中任意增益"]}, {"all", L["拥有选中所有增益"]}}
add_self.self_buff_logic_group = createradiobuttongroup(add_self, "Add", "self_buff_logic", self_buff_logic, "TOPLEFT", add_self.buff_text, "BOTTOMLEFT", 0, 0)

F.createDR(add_self.buff, add_self.self_buff_logic_group)

add_self.bframe = CreateFrame("Frame", addon_name.."Mybuffs", add_self)
add_self.bframe:SetSize(30,30)
add_self.bframe:SetPoint("TOPLEFT", add_self.self_buff_logic_group, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_buffs) do
	local bu = CreateFrame("Button", addon_name.."Mybuff"..spellid, add_self.bframe)
	bu:SetSize(30,30)
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["self_buff"] then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["enable_buffs"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		if not SH_CDB["Add"]["enable_buffs"][spellid] then
			SH_CDB["Add"]["enable_buffs"][spellid] = true
		else
			SH_CDB["Add"]["enable_buffs"][spellid] = nil
		end
		
		if SH_CDB["Add"]["enable_buffs"][spellid] then
			bu.sd:SetBackdropBorderColor(1, 1, 0)
		else
			bu.sd:SetBackdropBorderColor(0, 0, 0)
		end
	end)
	
	add_self.buff:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["enable_buffs"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_self.bframe.last then
		bu:SetPoint("TOPLEFT", add_self.bframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_self.bframe.last, "RIGHT", 5, 0)
	end
	
	add_self.bframe.last = bu
end

CreateLine(add_self, add_self.bframe, 0, -10)

add_self.spell = createcheckbutton(add_self, L["我的技能"], "Add", "self_spell", "TOPLEFT", add_self.bframe, "BOTTOMLEFT", 0, -20)
add_self.spell_text = CreateTextInfo(add_self, add_self.spell, 0, -10, L["我的技能说明"], 2)

add_self.sframe = CreateFrame("Frame", addon_name.."Myspells", add_self)
add_self.sframe:SetSize(30,30)
add_self.sframe:SetPoint("TOPLEFT", add_self.spell_text, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_spells) do
	local bu = CreateFrame("Button", addon_name.."Myspells"..spellid, add_self.sframe)
	bu:SetSize(30,30)
	bu.ID = spellid
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["self_spell"] then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["enable_spell"] == spellid then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		SH_CDB["Add"]["enable_spell"] = spellid
		for i, child in ipairs({add_self.sframe:GetChildren()}) do
			if SH_CDB["Add"]["enable_spell"] == child.ID then
				child.sd:SetBackdropBorderColor(1, 1, 0)
			else
				child.sd:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)

	add_self.spell:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["enable_spell"] == spellid then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_self.sframe.last then
		bu:SetPoint("TOPLEFT", add_self.sframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_self.sframe.last, "RIGHT", 5, 0)
	end
	
	add_self.sframe.last = bu
end

CreateLine(add_self, add_self.sframe, 0, -10)

add_self.item = createcheckbutton(add_self, L["我的物品"], "Add", "self_item", "TOPLEFT", add_self.sframe, "BOTTOMLEFT", 0, -20)
add_self.item_text = CreateTextInfo(add_self, add_self.item, 0, -10, L["我的物品说明"], 2)

add_self.iframe = CreateFrame("Frame", addon_name.."Myitems", add_self)
add_self.iframe:SetSize(30,30)
add_self.iframe:SetPoint("TOPLEFT", add_self.item_text, "BOTTOMLEFT", 0, -10)

for itemid in pairs(G.items) do
	local bu = CreateFrame("Button", addon_name.."Myitems"..itemid, add_self.iframe)
	bu:SetSize(30,30)
	bu.ID = itemid
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(10, GetItemInfo(itemid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(itemid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["self_item"] then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["enable_item"] == itemid then
			bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		SH_CDB["Add"]["enable_item"] = itemid
		for i, child in ipairs({add_self.iframe:GetChildren()}) do
			if SH_CDB["Add"]["enable_item"] == child.ID then
				child.sd:SetBackdropBorderColor(1, 1, 0)
			else
				child.sd:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)
	
	add_self.item:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			bu:Enable()
			if SH_CDB["Add"]["enable_item"] == itemid then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_self.iframe.last then
		bu:SetPoint("TOPLEFT", add_self.iframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_self.iframe.last, "RIGHT", 5, 0)
	end
	
	add_self.iframe.last = bu
end

CreateLine(add_self, add_self.iframe, 0, -10)

add_self.talent = createcheckbutton(add_self, L["我的天赋"], "Add", "self_talent", "TOPLEFT", add_self.iframe, "BOTTOMLEFT", 0, -20)
add_self.talent_text = CreateTextInfo(add_self, add_self.talent, 0, -10, L["我的天赋说明"], 2)

local self_talent_logic = {{"any", L["启用选中任意天赋"]}, {"all", L["启用选中所有天赋"]}}
add_self.self_talent_logic_group = createradiobuttongroup(add_self, "Add", "self_talent_logic", self_talent_logic, "TOPLEFT", add_self.talent_text, "BOTTOMLEFT", 0, 0)

F.createDR(add_self.talent, add_self.self_talent_logic_group)

add_self.tframe = CreateFrame("Frame", addon_name.."Mytalents", add_self)
add_self.tframe:SetSize(30,30)
add_self.tframe:SetPoint("TOPLEFT", add_self.self_talent_logic_group, "BOTTOMLEFT", 0, -10)

add_self.tframe:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
add_self.tframe:RegisterEvent("PLAYER_LOGIN")
add_self.tframe:SetScript("OnEvent", function(self)
	for i = 1, 7 do
		for j = 1, 3 do
			local talent_id, _, tex, _, _, spell_id = GetTalentInfo(i, j, 1)
			local spec = GetSpecialization()
			local bu
			
			if not _G[addon_name.."Mytalents"..i..j] then
				bu = CreateFrame("Button", addon_name.."Mytalents"..i..j, add_self.iframe)
				bu:SetSize(30,30)
				bu.ID = spec.."_"..talent_id
				bu.SpellID = spell_id
				F.createborder(bu)
			
				bu.texture = bu:CreateTexture(nil, "ARTWORK")
				bu.texture:SetAllPoints()
				bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			
				bu:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetSpellByID(bu.SpellID)
					GameTooltip:Show()
				end)
				bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
				bu:SetScript("OnShow", function()
					if SH_CDB["Add"]["self_talent"] then
						bu.texture:SetDesaturated(false)
						if SH_CDB["Add"]["enable_talents"][bu.ID] then
							bu.sd:SetBackdropBorderColor(1, 1, 0)
						else
							bu.sd:SetBackdropBorderColor(0, 0, 0)
						end
						bu:Enable()
					else
						bu.texture:SetDesaturated(true)
						bu.sd:SetBackdropBorderColor(0, 0, 0)
						bu:Disable()
					end
				end)
			
				bu:SetScript("OnClick", function()
					if SH_CDB["Add"]["enable_talents"][bu.ID] then
						SH_CDB["Add"]["enable_talents"][bu.ID] = nil
						bu.sd:SetBackdropBorderColor(0, 0, 0)
					else
						SH_CDB["Add"]["enable_talents"][bu.ID] = true
						bu.sd:SetBackdropBorderColor(1, 1, 0)
					end
				end)
			
				add_self.talent:HookScript("OnClick", function(self)
					if self:GetChecked() and self:IsEnabled() then
						bu.texture:SetDesaturated(false)
						bu:Enable()
						if SH_CDB["Add"]["enable_talents"][bu.ID] then
							bu.sd:SetBackdropBorderColor(1, 1, 0)
						else
							bu.sd:SetBackdropBorderColor(0, 0, 0)
						end
					else
						bu.texture:SetDesaturated(true)
						bu.sd:SetBackdropBorderColor(0, 0, 0)
						bu:Disable()
					end
				end)
			
				bu:SetPoint("TOPLEFT", add_self.tframe, "TOPLEFT", (i-1)*40, -(j-1)*35)
			end
			
			local t_bu = _G[addon_name.."Mytalents"..i..j]
			t_bu.ID = spec.."_"..talent_id
			t_bu.SpellID = spell_id
			t_bu.texture:SetTexture(tex)
			if SH_CDB["Add"]["self_talent"] and SH_CDB["Add"]["enable_talents"][t_bu.ID] then
				t_bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				t_bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
end)

CreateLine(add_self, add_self.tframe, 0, -80)

add_self.myhealth = createcheckbutton(add_self, L["我的有效血量"], "Add", "self_myhealth", "TOPLEFT", add_self.tframe, "BOTTOMLEFT", 0, -90)
add_self.myhealth_text = CreateTextInfo(add_self, add_self.myhealth, 0, -10, L["我的有效血量说明"], 2)

add_self.myhealth_value = createslider(add_self, L["阈值"], "Add", "self_myhealth_value", 0, 100, 1, "TOPLEFT", add_self.myhealth_text, "BOTTOMLEFT", 0, -30)
CreateLine(add_self, add_self.myhealth_value, 0, -10)
F.createDR(add_self.myhealth, add_self.myhealth_value)

add_self.holypower = createcheckbutton(add_self, L["我的圣能"], "Add", "self_holypower", "TOPLEFT", add_self.tframe, "BOTTOMLEFT", 0, -220)
add_self.holypower_text = CreateTextInfo(add_self, add_self.holypower, 0, -10, L["我的圣能说明"], 2)

add_self.holypower_value = createslider(add_self, L["阈值"], "Add", "self_holypower_value", 0, 5, 1, "TOPLEFT", add_self.holypower_text, "BOTTOMLEFT", 0, -30)
CreateLine(add_self, add_self.holypower_value, 0, -10)
F.createDR(add_self.holypower, add_self.holypower_value)
---------------- 目标条件 ----------------
local target = CreateNewLogicOptions(3, L["目标条件"])
local add_target = NewLogicOption[3].sfa

add_target.role = createcheckbutton(add_target, L["目标角色"], "Add", "target_rolefilter", "TOPLEFT", add_target, "TOPLEFT", 10, -10)
add_target.role_text = CreateTextInfo(add_target, add_target.role, 0, -10, L["目标角色说明"], 2)
local target_role = {{"me", L["我"]}, {"exceptme", L["除我之外"]}, {"tank", L["坦克"]}, {"excepttank", L["除坦克之外"]}}
add_target.role_group = createradiobuttongroup(add_target, "Add", "target_role", target_role, "TOPLEFT", add_target.role_text, "BOTTOMLEFT", 0, 0)
F.createDR(add_target.role, add_target.role_group)

CreateLine(add_target, add_target.role_group, 0, -10)

add_target.lackhot = createcheckbutton(add_target, L["缺少增益"], "Add", "target_lackhot", "TOPLEFT", add_target.role_group, "BOTTOMLEFT", 0, -20)
add_target.lackhot_text = CreateTextInfo(add_target, add_target.lackhot, 0, -10, L["缺少增益说明"], 2)
local target_lackhot_logic = {{"any", L["缺少选中任意增益"]}, {"all", L["缺少选中所有增益"]}}
add_target.lackhot_logic_group = createradiobuttongroup(add_target, "Add", "target_lackhot_logic", target_lackhot_logic, "TOPLEFT", add_target.lackhot_text, "BOTTOMLEFT", 0, 0)
F.createDR(add_target.lackhot, add_target.lackhot_logic_group)

add_target.lhframe = CreateFrame("Frame", addon_name.."Target lack hot", add_target)
add_target.lhframe:SetSize(30,30)
add_target.lhframe:SetPoint("TOPLEFT", add_target.lackhot_logic_group, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_hots) do
	local bu = CreateFrame("Button", addon_name.."Target lack hot "..spellid, add_target.lhframe)
	bu:SetSize(30,30)
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["target_lackhot"] then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["target_lackhots"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)			
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		if not SH_CDB["Add"]["target_lackhots"][spellid] then
			SH_CDB["Add"]["target_lackhots"][spellid] = true
		else
			SH_CDB["Add"]["target_lackhots"][spellid] = nil
		end
		
		if SH_CDB["Add"]["target_lackhots"][spellid] then
			bu.sd:SetBackdropBorderColor(1, 1, 0)
		else
			bu.sd:SetBackdropBorderColor(0, 0, 0)
		end
	end)
	
	add_target.lackhot:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)	
			if SH_CDB["Add"]["target_lackhots"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_target.lhframe.last then
		bu:SetPoint("TOPLEFT", add_target.lhframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_target.lhframe.last, "RIGHT", 5, 0)
	end
	
	add_target.lhframe.last = bu
end

CreateLine(add_target, add_target.lhframe, 0, -10)

add_target.hashot = createcheckbutton(add_target, L["拥有增益"], "Add", "target_hashot", "TOPLEFT", add_target.lhframe, "BOTTOMLEFT", 0, -20)
add_target.hashot_text = CreateTextInfo(add_target, add_target.hashot, 0, -10, L["拥有增益说明"], 2)
local target_hashot_logic = {{"any", L["拥有选中任意增益"]}, {"all", L["拥有选中所有增益"]}}
add_target.hashot_logic_group = createradiobuttongroup(add_target, "Add", "target_hashot_logic", target_hashot_logic, "TOPLEFT", add_target.hashot_text, "BOTTOMLEFT", 0, 0)
F.createDR(add_target.hashot, add_target.hashot_logic_group)

add_target.hhframe = CreateFrame("Frame", addon_name.."Target has hot", add_target)
add_target.hhframe:SetSize(30,30)
add_target.hhframe:SetPoint("TOPLEFT", add_target.hashot_logic_group, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_hots) do
	local bu = CreateFrame("Button", addon_name.."Target has hot "..spellid, add_target.hhframe)
	bu:SetSize(30,30)
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(spellid)))
	
	bu:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetSpellByID(spellid)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["target_hashot"] then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["target_hashots"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		if not SH_CDB["Add"]["target_hashots"][spellid] then
			SH_CDB["Add"]["target_hashots"][spellid] = true
		else
			SH_CDB["Add"]["target_hashots"][spellid] = nil
		end
		
		if SH_CDB["Add"]["target_hashots"][spellid] then
			bu.sd:SetBackdropBorderColor(1, 1, 0)
		else
			bu.sd:SetBackdropBorderColor(0, 0, 0)
		end
	end)
	
	add_target.hashot:HookScript("OnClick", function(self)
		if self:GetChecked() and self:IsEnabled() then
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["target_hashots"][spellid] then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		else
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		end
	end)
	
	if not add_target.hhframe.last then
		bu:SetPoint("TOPLEFT", add_target.hhframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_target.hhframe.last, "RIGHT", 5, 0)
	end
	
	add_target.hhframe.last = bu
end

------------------ 动作 ------------------
local action = CreateNewLogicOptions(4, L["动作"])
local add_action = NewLogicOption[4].sfa

add_action.selecticon = F.createtext(add_action, "OVERLAY", 14, "OUTLINE", "LEFT")
add_action.selecticon:SetText(L["选择图标"])
add_action.selecticon:SetPoint("TOPLEFT", add_action, "TOPLEFT", 10, -10)
add_action.selecticon_text = CreateTextInfo(add_action, add_action.selecticon, 0, -10, L["选择图标说明"], 2)

add_action.iframe = CreateFrame("Frame", addon_name.."Select icon", add_action)
add_action.iframe:SetSize(30,30)
add_action.iframe:SetPoint("TOPLEFT", add_action.selecticon_text, "BOTTOMLEFT", 0, -10)

for spellid in pairs(G.my_spells) do
	local bu = CreateFrame("Button", addon_name.."Select icon "..spellid, add_action.iframe)
	bu:SetSize(30,30)
	bu.ID = spellid
	F.createborder(bu)
	
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bu.texture:SetTexture(select(3, GetSpellInfo(bu.ID)))
	
	bu:SetScript("OnShow", function()
		if SH_CDB["Add"]["use_custom_icon"] then
			bu.texture:SetDesaturated(true)
			bu.sd:SetBackdropBorderColor(0, 0, 0)
			bu:Disable()
		else
			bu.texture:SetDesaturated(false)
			if SH_CDB["Add"]["select_icon"] == bu.ID then
				bu.sd:SetBackdropBorderColor(1, 1, 0)
			else
				bu.sd:SetBackdropBorderColor(0, 0, 0)
			end
			bu:Enable()
		end
	end)
	
	bu:SetScript("OnClick", function()
		SH_CDB["Add"]["select_icon"] = bu.ID
		for i, child in ipairs({add_action.iframe:GetChildren()}) do
			if SH_CDB["Add"]["select_icon"] == child.ID then
				child.sd:SetBackdropBorderColor(1, 1, 0)
			else
				child.sd:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)
	
	if not add_action.iframe.last then
		bu:SetPoint("TOPLEFT", add_action.iframe, "TOPLEFT")
	else
		bu:SetPoint("LEFT", add_action.iframe.last, "RIGHT", 5, 0)
	end
	
	add_action.iframe.last = bu
end

add_action.use_custom_icon = createcheckbutton(add_action, L["自定义图标"], "Add", "use_custom_icon", "TOPLEFT", add_action.iframe, "BOTTOMLEFT", 0, -20)
add_action.custom_bu = CreateFrame("Button", addon_name.."Custom icon", add_action)
add_action.custom_bu:SetSize(30,30)
add_action.custom_bu:SetPoint("TOPLEFT", add_action.use_custom_icon, "BOTTOMLEFT", 0, -10)
F.createborder(add_action.custom_bu)

add_action.custom_bu.texture = add_action.custom_bu:CreateTexture(nil, "ARTWORK")
add_action.custom_bu.texture:SetAllPoints()
add_action.custom_bu.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

add_action.custom_bu:SetScript("OnShow", function()
	add_action.custom_bu.texture:SetTexture(select(3, GetSpellInfo(SH_CDB["Add"]["custom_icon"])))
	if SH_CDB["Add"]["use_custom_icon"] then
		add_action.custom_bu.sd:SetBackdropBorderColor(1, 1, 0)
		add_action.custom_bu.texture:SetDesaturated(false)
		add_action.custom_bu:Enable()
	else
		add_action.custom_bu.sd:SetBackdropBorderColor(0, 0, 0)
		add_action.custom_bu.texture:SetDesaturated(true)
		add_action.custom_bu:Disable()
	end
end)

StaticPopupDialogs[addon_name.."incorrect spellid"] = {
	button1 = ACCEPT, 
	hideOnEscape = 1, 
	whileDead = true,
}

StaticPopupDialogs[addon_name.."input spellid"] = {
	text = L["输入法术ID"],
	hasEditBox = true,
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	OnShow = function(self)
		self.editBox:SetNumeric(true)
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		local name, _, tex = GetSpellInfo(text)
		if not name then
			StaticPopupDialogs[addon_name.."incorrect spellid"].text = "|cff7FFF00"..text.." |r"..L["不是一个有效的法术ID"]
			StaticPopup_Show(addon_name.."incorrect spellid")
		else
			SH_CDB["Add"]["custom_icon"] = text
			add_action.custom_bu.texture:SetTexture(tex)
		end
	end,
}

add_action.custom_bu:SetScript("OnClick", function()
	StaticPopup_Show(addon_name.."input spellid")
end)

add_action.use_custom_icon:HookScript("OnClick", function(self)
	if SH_CDB["Add"]["use_custom_icon"] then
		for i, child in ipairs({add_action.iframe:GetChildren()}) do
			child.texture:SetDesaturated(true)
			child.sd:SetBackdropBorderColor(0, 0, 0)
			child:Disable()
		end
		add_action.custom_bu.sd:SetBackdropBorderColor(1, 1, 0)
		add_action.custom_bu.texture:SetDesaturated(false)
		add_action.custom_bu:Enable()
	else
		for i, child in ipairs({add_action.iframe:GetChildren()}) do
			child.texture:SetDesaturated(false)
			if SH_CDB["Add"]["select_icon"] == child.ID then
				child.sd:SetBackdropBorderColor(1, 1, 0)
			else
				child.sd:SetBackdropBorderColor(0, 0, 0)
			end
			child:Enable()
		end
		add_action.custom_bu.sd:SetBackdropBorderColor(0, 0, 0)
		add_action.custom_bu.texture:SetDesaturated(true)
		add_action.custom_bu:Disable()
	end
end)
------------------ 顺序 ------------------
local order = CreateNewLogicOptions(5, L["选择顺序"])
local add_order = NewLogicOption[5].sfa

add_order.order = F.createtext(add_order, "OVERLAY", 14, "OUTLINE", "LEFT")
add_order.order:SetText(L["选择顺序"])
add_order.order:SetPoint("TOPLEFT", add_order, "TOPLEFT", 10, -10)
add_order.order_text = CreateTextInfo(add_order, add_order.order, 0, -10, L["选择顺序说明"], 2)
local order_logic = {{"sur_order", L["生存系数"]}, {"raid_order", L["队列位置"]}}
add_order.order_logic_group = createradiobuttongroup(add_order, "Add", "order_logic", order_logic, "TOPLEFT", add_order.order_text, "BOTTOMLEFT", 0, 0)

----------------------------------------------------------
------------------[[     生存系数     ]]------------------
----------------------------------------------------------

local sur_options = F.CreateOptions(L["生存系数"], addon_name.."sur_options", gui, nil, 270, .05, .05, .05)
sur_options.tabindex = 1
sur_options.tabnum = 2
for i = 1, 2 do
	sur_options["tab"..i] = CreateFrame("Frame", addon_name.."Sur Tab"..i, sur_options)
	sur_options["tab"..i]:SetScript("OnMouseDown", function() end)
end

local sur_buff_options = F.CreateOptions(SHOW_BUFFS, addon_name.."sur_buff_options", sur_options, true, 10, .05, .05, .05)

local function CreateAuraOpitons(parent, spellID, aura_type)
	if not parent.ind then
		parent.ind = 0
	end
	
	local option = CreateFrame("Frame", nil, parent)
	option:SetSize(600, 40)
	option:SetPoint("TOP", parent, "TOP", 0, -10-parent.ind*50)
	F.createborder(option)
	
	local spell_name, _, spell_icon = GetSpellInfo(spellID)
	
	options.icon = option:CreateTexture(nil, "ARTWORK")
	options.icon:SetSize(30, 30)
	options.icon:SetPoint("LEFT", option, "LEFT", 20, 0)
	options.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	options.icon:SetTexture(spell_icon)
	F.createbdframe(options.icon)
	
	option.name = F.createtext(option, "OVERLAY", 15, "OUTLINE", "LEFT")
	option.name:SetPoint("LEFT", options.icon, "RIGHT", 10, 0)
	option.name:SetText(spell_name)
	
	option.value = createslider(option, L["生存系数"], aura_type, spellID, 0, 100, 5, "LEFT", options.icon, "RIGHT", 200, 0)
	
	parent.ind = parent.ind + 1
end

for cat, t in pairs(G.Buffs) do
	for spellID, v in pairs(t) do
		CreateAuraOpitons(sur_buff_options.sfa, spellID, "Buffs")
	end
end

local sur_debuff_options = F.CreateOptions(SHOW_DEBUFFS, addon_name.."sur_debuff_options", sur_options, true, 10, .05, .05, .05)

local function CreateInstancePanel(parent, instanceID, encounters)
	if not parent.ind then
		parent.ind = 0
	end
	
	local option = CreateFrame("Frame", "Instance"..instanceID.."button", parent)
	option:SetSize(174, 96)
	option:SetPoint("TOPLEFT", parent, "TOPLEFT", 20 + math.fmod(parent.ind,3)*194, - 10 - math.floor(parent.ind/3)*115)
	F.createborder(option)
	
	local name, description, bgImage, buttonImage, loreImage = EJ_GetInstanceInfo(instanceID)
	
	option.tex = option:CreateTexture(nil, "ARTWORK")
	option.tex:SetAllPoints()
	option.tex:SetTexCoord(.05, .65, .05, .7)
	option.tex:SetTexture(buttonImage)

	option.name = F.createtext(option, "OVERLAY", 15, "OUTLINE", "CENTER")
	option.name:SetPoint("TOP", option, "TOP", 0, -10)
	option.name:SetText(name)
	
	option:SetScript("OnEnter", function(self)
		self.name:SetTextColor(1, 1, 0)
		self.sd:SetBackdropColor(1, 1, 0, 0.2)
		self.sd:SetBackdropBorderColor(1, 1, 0)
	end)
 	option:SetScript("OnLeave", function(self)
		self.name:SetTextColor(1, 1, 1)
		self.sd:SetBackdropColor(0, 0, 0, .3)
		self.sd:SetBackdropBorderColor(0, 0, 0)
	end)
	
	option.sf = CreateFrame("ScrollFrame", "Instance"..instanceID.."ScrollFrame", sur_debuff_options, "UIPanelScrollFrameTemplate")
	option.sf:SetPoint("TOPLEFT", sur_debuff_options, "TOPLEFT", 10, -10)
	option.sf:SetPoint("BOTTOMRIGHT", sur_debuff_options, "BOTTOMRIGHT", -35, 57)
	option.sf:SetFrameLevel(sur_debuff_options:GetFrameLevel()+1)

	option.sfa = CreateFrame("Frame", "Instance"..instanceID.."ScrollAnchor", option.sf)
	option.sfa:SetPoint("TOPLEFT", option.sf, "TOPLEFT", 0, -3)
	option.sfa:SetWidth(option.sf:GetWidth()-20)
	option.sfa:SetHeight(option.sf:GetHeight())
	option.sfa:SetFrameLevel(option.sf:GetFrameLevel()+1)
	
	option.sf:SetScrollChild(option.sfa)
	
	for k, v in pairs(encounters) do
		for type, spells in pairs(v) do
			if type == "debuffs" then
				for spellID, value in pairs(spells) do
					CreateAuraOpitons(option.sfa, spellID, "Debuffs")
				end
			end
		end
	end
	
	ReskinScroll(_G["Instance"..instanceID.."ScrollFrameScrollBar"])
	option.sf:Hide()
	
	option.back = F.createUIPanelButton(option.sf, "BACK", 100, 25, BACK)
	option.back:SetPoint("BOTTOMRIGHT", sur_debuff_options, "TOPRIGHT", 0, 5)
	option.back:Hide()
	
	option.back:SetScript("OnClick", function()
		option.sf:Hide()
		option.back:Hide()
		sur_debuff_options.sf:Show()
		sur_debuff_options.sfa:Show()
	end)
	
	option:SetScript("OnMouseDown", function()
		option.sf:Show()
		option.back:Show()
		sur_debuff_options.sf:Hide()
		sur_debuff_options.sfa:Hide()
	end)
	
	parent.ind = parent.ind + 1
end

for i, instance in pairs(G.Instance) do
	CreateInstancePanel(sur_debuff_options.sfa, instance.id, instance.encounters)
end
----------------------------------------------------------
------------------[[     预估伤害     ]]------------------
----------------------------------------------------------

local icd_options = F.CreateOptions(L["预估伤害"], addon_name.."icd_options", gui, nil, 270, .05, .05, .05)


----------------------------------------------------------
------------------[[       制作       ]]------------------
----------------------------------------------------------

local credit = F.CreateOptions(L["制作"], addon_name.."credit", gui, nil, 270, .05, .05, .05)

local info = F.createtext(credit, "OVERLAY", 25, "OUTLINE", "CENTER")
info:SetPoint("CENTER", credit, "CENTER", 0, 20)
info:SetText(L["制作文本"])

model = CreateFrame("PlayerModel", nil, credit)
model:SetSize(200,200)
model:SetPoint("BOTTOM", credit, "BOTTOM", 0, 30)

model:SetPosition(0, 0, 0)
model:SetFacing(1)
model:SetCreature(112144)

model.text = F.createtext(model, "HIGHLIGHT", 20, "NONE", "CENTER")
model.text:SetPoint("BOTTOM", model, "BOTTOM", 0, 25)
model.text:SetTextColor(1, 1, 1)
model.text:SetText(L["汪汪"])

model.glow = model:CreateTexture(nil, "HIGHLIGHT")
model.glow:SetSize(30, 30)
model.glow:SetPoint("CENTER", model.text, "TOPRIGHT", -3, -5)
model.glow:SetTexture("Interface\\Cooldown\\star4")
model.glow:SetVertexColor(1, 1, 1, .7)
model.glow:SetBlendMode("ADD")

model:SetScript("OnEnter", function(self) self:SetFacing(0) end)
model:SetScript("OnLeave", function(self) self:SetFacing(1) end)
	
model:EnableMouse(true)

----------------------------------------------------------
--------------------[[     CMD     ]]---------------------
----------------------------------------------------------

SLASH_SH1 = "/sh"
SlashCmdList["SH"] = function(arg)
	if gui:IsShown() then
		gui:Hide()
	else
		gui:Show()
	end
end

local MinimapButton = CreateFrame("Button", "SmartHealing MinimapButton", Minimap)
MinimapButton:SetSize(16, 16)
MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
MinimapButton:SetScript("OnEnter", function(self) 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT",  -20, 10)
	GameTooltip:AddLine(G.addon_cname)
	GameTooltip:Show() 
end)
MinimapButton:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
end)
MinimapButton:SetScript("OnClick", function()
	if gui:IsShown() then
		gui:Hide()
	else
		gui:Show()
	end
end)

MinimapButton.tex = MinimapButton:CreateTexture(nil, "OVERLAY")
MinimapButton.tex:SetAllPoints(MinimapButton)
MinimapButton.tex:SetTexture(133941)
MinimapButton.tex:SetTexCoord( .2, .8, .2, .8)