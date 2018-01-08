local addon_name, ns = ...
local F, G = unpack(ns)

local Character_default_Settings = {
	Layout = {
		anchor = "TOPLEFT",
		size = 36,
		glow = true,
	},
	General = {
		hot = true,
		cd = true,
		trinkets = true,
	},
}

local Account_default_Settings = {

}

function F.LoadVariables()
	if SH_CDB == nil then
		SH_CDB = {}
	end
	for a, b in pairs(Character_default_Settings) do
		if type(b) ~= "table" then
			if SH_CDB[a] == nil then
				SH_CDB[a] = b
			end
		else
			if SH_CDB[a] == nil then
				SH_CDB[a] = {}
			end
			for k, v in pairs(b) do
				if SH_CDB[a][k] == nil then
					SH_CDB[a][k] = v
				end
			end
		end
	end
end

function F.LoadAccountVariables()
	if SH_DB == nil then
		SH_DB = {}
	end
	for a, b in pairs(Account_default_Settings) do
		if type(b) ~= "table" then
			if SH_DB[a] == nil then
				SH_DB[a] = b
			end
		else
			if SH_DB[a] == nil then
				SH_DB[a] = {}
			end
			for k, v in pairs(b) do
				if SH_DB[a][k] == nil then
					if v then
						SH_DB[a][k] = v
					else
						print(a,k)
					end
				end
			end
		end
	end
end

local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:SetScript("OnEvent", function(self, event, ...)
	local addon = ...
	if addon ~= G.addon_name then return end
	
	F.LoadVariables()
	F.LoadAccountVariables()
end)
----------------------------------------------------------
-----------------[[        API        ]]------------------
----------------------------------------------------------
F.createborder = function(frame, r, g, b)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1,}
		})
	if not (r and g and b) then
		frame:SetBackdropColor(.05, .05, .05, .5)
		frame:SetBackdropBorderColor(0, 0, 0)
	else
		frame:SetBackdropColor(r, g, b, .5)
		frame:SetBackdropBorderColor(r, g, b)
	end
end

F.createtext = function(frame, layer, fontsize, flag, justifyh, shadow)
	local text = frame:CreateFontString(nil, layer)
	text:SetFont(G.Font, fontsize, flag)
	text:SetJustifyH(justifyh)
	
	if shadow then
		text:SetShadowColor(0, 0, 0)
		text:SetShadowOffset(1, -1)
	end
	
	return text
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
	slider:SetWidth(140)
	
	BlizzardOptionsPanel_Slider_Enable(slider)
	
	slider:SetMinMaxValues(min, max)
	_G[slider:GetName()..'Low']:SetText(min)
	_G[slider:GetName()..'Low']:ClearAllPoints()
	_G[slider:GetName()..'Low']:SetPoint("RIGHT", slider, "LEFT", -5, 0)
	_G[slider:GetName()..'High']:SetText(max)
	_G[slider:GetName()..'High']:ClearAllPoints()
	_G[slider:GetName()..'High']:SetPoint("LEFT", slider, "RIGHT", 5, 0)
	
	_G[slider:GetName()..'Text']:ClearAllPoints()
	_G[slider:GetName()..'Text']:SetPoint("BOTTOM", slider, "TOP", 0, 3)
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

local createcheckbutton = function(parent, name, t, value, ...)
	local bu = CreateFrame("CheckButton", addon_name..t..value.."Button", parent, "InterfaceOptionsCheckButtonTemplate")	
	bu:SetPoint(...)
	bu:SetHitRectInsets(0, -50, 0, 0)
	
	_G[bu:GetName() .. "Text"]:SetText(name)
	
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

----------------------------------------------------------
-----------------[[        GUI        ]]------------------
----------------------------------------------------------

local gui = CreateFrame("Frame", G.addon_name.."_GUI", UIParent)
gui:SetSize(200, 350)
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

G.gui = gui

local Raidframe = CreateFrame("Frame", nil, gui)
Raidframe:SetSize(120, 80)
Raidframe:SetPoint("TOP", 0, -20)
F.createborder(Raidframe, .2, .5, .4)

local anchors = {"CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

for index, key in pairs(anchors) do
	local ind = CreateFrame("Button", nil, Raidframe)
	ind:SetSize(15, 15)
	ind:SetPoint(key, Raidframe, key)
	F.createborder(ind, 1, 1, 1)
	Raidframe[key] = ind
	
	ind.update = function()
		if SH_CDB["Layout"]["anchor"] == key then
			ind:SetBackdropColor(1, 1, 0, .8)
			ind:SetBackdropBorderColor(1, 1, 0, 1)
		else
			ind:SetBackdropColor(1, 1, 1, .5)
			ind:SetBackdropBorderColor(1, 1, 1, 1)
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

local size_slider = createslider(gui, "Icon size", "Layout", "size", 20, 40, 2, "TOP", Raidframe, "BOTTOM", 0, -30)
size_slider.apply = function() F.EditIcons("size") end

local glow_bu = createcheckbutton(gui, "Icon glow", "Layout", "glow", "TOPLEFT", size_slider, "BOTTOMLEFT", 0, -10)
glow_bu.apply = function() F.EditIcons("glow") end

local hot_bu = createcheckbutton(gui, "Hot in advance", "General", "hot", "TOPLEFT", glow_bu, "BOTTOMLEFT", 0, -10)

local cd_bu = createcheckbutton(gui, "Defensive spell", "General", "cd", "TOPLEFT", hot_bu, "BOTTOMLEFT", 0, -10)

local trinkets_bu = createcheckbutton(gui, "Trinket spell", "General", "trinkets", "TOPLEFT", cd_bu, "BOTTOMLEFT", 0, -10)
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