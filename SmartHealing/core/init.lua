local addon_name, ns = ...

ns[1] = {} -- F, functions
ns[2] = {} -- G, globals
ns[3] = {} -- L, globals

local F, G, L = unpack(ns)

G.addon_name = "SmartHealing"
G.addon_cname = "|cffEE3A8CSmart Healing|r"
G.Client = GetLocale()
G.Version = GetAddOnMetadata("SmartHealing", "Version")
G.Font = GameFontHighlight:GetFont()

G.media = {
	blank = "Interface\\Buttons\\WHITE8x8",
	logo = "Interface\\AddOns\\SmartHealing\\media\\KEAHOARL",
}

G.Healers = {
	["DRUID"] = true,
	["PALADIN"] = true,
	["SHAMAN"] = true,
	["MONK"] = true,
	["PRIEST"] = true,
}

G.myClass = select(2, UnitClass("player"))
G.myName = UnitName("player")