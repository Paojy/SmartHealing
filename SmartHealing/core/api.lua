local addon_name, ns = ...
local F, G, L = unpack(ns)

----------------------------------------------------------
-----------------[[        API        ]]------------------
----------------------------------------------------------
F.IsEmpty = function(t)
	for k, v in pairs(t) do
		if k then
			return false
		end
	end
	return true
end
 
F.GetSpellIconLink = function(spellID)
	if not GetSpellInfo(spellID) then
		print("法术"..spellID.."出错 请检查")
		return ""
	end
	local icon = select(3, GetSpellInfo(spellID))
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t"..GetSpellLink(spellID)
end

F.GetItemIconLink = function(itemID)
	if not GetItemInfo(itemID) then
		print("物品"..itemID.."出错 请检查")
		return ""
	end
	local icon = select(10, GetItemInfo(itemID))
	return "|T"..icon..":12:12:0:0:64:64:4:60:4:60|t"..select(2, GetItemInfo(itemID))
end

F.createbdframe = function(f)
	local bg
	
	if f:GetObjectType() == "Texture" then
		bg = CreateFrame("Frame", nil, f:GetParent(), "BackdropTemplate")
	else
		bg = CreateFrame("Frame", nil, f, "BackdropTemplate")
		local lvl = f:GetFrameLevel()
		bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	end
	
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	
	bg:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\SMT\\media\\glow",
		edgeSize = 1,
			insets = { left = 1, right = 1, top = 1, bottom = 1,}
		})

	bg:SetBackdropColor(.05, .05, .05, 0)
	bg:SetBackdropBorderColor(0, 0, 0)
	
	return bg
end

F.createborder = function(f, r, g, b)
	if f.style then return end
	
	f.sd = CreateFrame("Frame", nil, f, "BackdropTemplate")
	local lvl = f:GetFrameLevel()
	f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	f.sd:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\AddOns\\SMT\\media\\glow",
		edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3,}
		})
	f.sd:SetPoint("TOPLEFT", f, -3, 3)
	f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
	if not (r and g and b) then
		f.sd:SetBackdropColor(.05, .05, .05, .5)
		f.sd:SetBackdropBorderColor(0, 0, 0)
	else
		f.sd:SetBackdropColor(r, g, b, .5)
		f.sd:SetBackdropBorderColor(r, g, b)
	end
	f.style = true
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

-- dependency relationship
F.createDR = function(parent, ...)
    for i=1, select("#", ...) do
		local object = select(i, ...)
		if object:GetObjectType() == "Slider" then
			parent:HookScript("OnShow", function(self)
				if self:GetChecked() and self:IsEnabled() then
					BlizzardOptionsPanel_Slider_Enable(object)
				else
					BlizzardOptionsPanel_Slider_Disable(object)
				end
			end)
			parent:HookScript("OnClick", function(self)
				if self:GetChecked() and self:IsEnabled() then
					BlizzardOptionsPanel_Slider_Enable(object)
				else
					BlizzardOptionsPanel_Slider_Disable(object)
				end
			end)
		elseif object:GetObjectType() == "Frame" and object:GetName() then	
			if object:GetName():match("RadioButtonGroup") then
				local children = {object:GetChildren()}
				parent:HookScript("OnShow", function(self)
					if self:GetChecked() and self:IsEnabled() then
						for i = 1, #children do
							children[i]:Enable()
							_G[children[i]:GetName() .. "Text"]:SetTextColor(1, .8, 0)
							children[i]:GetCheckedTexture():SetVertexColor(0, 1, 0, .6)
						end
					else
						for i = 1, #children do
							children[i]:Disable()
							_G[children[i]:GetName() .. "Text"]:SetTextColor(.5, .5, .5)
							children[i]:GetCheckedTexture():SetVertexColor(.5, .5, .5)
						end
					end
				end)
				parent:HookScript("OnClick", function(self)
					if self:GetChecked() and self:IsEnabled() then
						for i = 1, #children do
							children[i]:Enable()
							_G[children[i]:GetName() .. "Text"]:SetTextColor(1, .8, 0)
							children[i]:GetCheckedTexture():SetVertexColor(0, 1, 0, .6)
						end
					else
						for i = 1, #children do
							children[i]:Disable()
							_G[children[i]:GetName() .. "Text"]:SetTextColor(.5, .5, .5)
							children[i]:GetCheckedTexture():SetVertexColor(.5, .5, .5)
						end
					end
				end)
			end
		else
			parent:HookScript("OnShow", function(self)
				if self:GetChecked() and self:IsEnabled() then
					object:Enable()
				else
					object:Disable()
				end
			end)
			parent:HookScript("OnClick", function(self)
				if self:GetChecked() and self:IsEnabled() then
					object:Enable()
				else
					object:Disable()
				end
			end)
		end
    end
end

F.createCR = function(...)
	local group = {...}
	for i= 1, #group do
		group[i]:HookScript("OnClick", function(self)
			if group[i]:GetChecked() then
				for j = 1, #group do
					if j ~= i then
						group[j]:SetChecked(false)
						SH_CDB[group[j].t][group[j].value] = false	
						group[j]:Hide()
						group[j]:Show()
					end
				end
			end
		end)
	end
end