local addon_name, ns = ...
local F, G, L = unpack(ns)

if not G.Healers[G.myClass] then return end

G.buffs = {
	["DRUID"] = {
	   [207640] = false, 	-- Abundance
	   [29166] = false, 	-- Innervate
	   [200389] = false, 	-- Cultivation
	   [774] = false,   	-- Rejuvenation
	   [155777] = false,	-- Rejuvenation (Germination)
	   [197721] = false, 	-- Flourish
	   [117679] = false, 	-- Incarnation
	   [8936] = false,   	-- Regrowth
	   [197625] = false, 	-- Moonkin Form
	   [33763] = false, 	-- Lifebloom
	   [33891] = false, 	-- Incarnation: Tree of Life
	   [16870] = false, 	-- Clearcasting
	   [102351] = false,	-- Cenarion Ward
	   [102342] = false,	-- Ironbark
	   [114108] = false,	-- Soul of the Forest
	   [48438] = false, 	-- Wild Growth
	},
	["PALADIN"] = {
		[1022] = false, 	-- Blessing of Protection
		[53563] = false,	-- Beacon of Light 
		[6940] = false,  	-- Blessing of Sacrifice
		[31821] = false, 	-- Aura Mastery
		[31884] = false,	-- Avenging Wrath 
		[498] = false,  	-- Divine Protection
		[642] = false,  	-- Divine Shield
		[200025] = false,	-- Beacon of Virtue
		[156910] = false, 	-- Beacon of Faith
		[54149] = false,	-- Infusion of Light 
		[105809] = false,	-- Holy Avenger
		[214202] = false,	-- Rule of Law
		[223306] = false,	-- Bestow Faith	
		[152262] = false,	-- 炽天使
		[223819] = false,	-- 神圣意志		
	},
	["SHAMAN"] = {
		[79206] = false, 
		[114052] = false,
		[974] = false,
		[216251] = false,
		[108271] = false,
		[73685] = false, 
		[157504] = false,
		[61295] = false, 
		[98007] = false, 
		[207400] = false,
		[201633] = false,
		[73920] = false, 
		[280615] = false,
		[53390] = false,
		[288675] = false, --浪潮汹涌
		[327164] = false, -- 始源之潮
	},
	["MONK"] = {
		[119611] = false,
		[196725] = false,
		[122783] = false,
		[116680] = false,
		[243435] = false,
		[124682] = false,
		[116841] = false,
		[197908] = false,
		[191840] = false,
		[115175] = false,
		[202090] = false,
		[122278] = false,
		[197919] = false,
		[116849] = false,
		[197916] = false,
	},
	["PRIEST"] = {
		[198069] = false, -- 阴暗面之力
		[194384] = false,
		[17] = false,
		[265258] = false,
		[21562] = false, 
		[81782] = false, 
		[33206] = false, 
		[47536] = false, 
		[45243] = false, 
		[47788] = false,
		[139] = false,
		[200183] = false,
		[27827] = false, 
		[114255] = false,
		[41635] = false,
	}   
}

G.my_buffs = G.buffs[G.myClass]

G.spells = {
	["DRUID"] = {
		[774] = true,
		[8936] = false,
		[33763] = false,
		[48438] = false,
		[740] = false,		-- Tranquility
		[18562] = false,		-- Swiftmend
		[29166] = false, 	-- Innervate
		[33891] = false, 	-- Incarnation: Tree of Life
		[48438] = false,		-- Wild Growth
		[102342] = false,	-- Ironbark
		[102351] = false,	-- Cenarion Ward
		[197721] = false,	-- Flourish
		[203651] = false,	-- 过度生长
		[50464] = false,	-- 滋养
	},
	["PALADIN"] = {
		[19750] = true,
		[20473] = false,
		[53563] = false,
		[82326] = false,
		[1022] = false,
		[183998] = false,
		[633] = false,
		[6940] = false,
		[223306] = false,
		[200025] = false,
		[156910] = false,
		[114165] = false,
		[85673] = false,
		[304971] = false,
	},
	["SHAMAN"] = {
		[8004] = true,
		[1064] = false,
		[77472] = false,
		[61295] = false, 
		[73685] = false, 
		[207399] = false,
		[974] = false,
		[326059] = false, -- 始源之潮
		[207778] = false, -- 倾盆大雨
	},  
	["MONK"] = {
		[116670] = true,
		[115175] = false,
		[124682] = false,
		[115098] = false,
		[115151] = false,
		[116844] = false,
		[116849] = false,
	},
	["PRIEST"] = {
		[17] = true,
		[2061] = false,
		[139] = false,
		[2060] = false,
		[596] = false,
		[32546] = false,
		[21562] = false,
	    [33206] = false, 
	    [47540] = false, 
	    [194509] = false,
	    [204263] = false,
		[2050] = false,
		[33076] = false, 
		[47788] = false, 
		[200183] = false,
		[204883] = false,
	}
}

G.my_spells = G.spells[G.myClass]

G.items = {
	[184020] = false,
}

G.hots = {
	["DRUID"] = {
		[774] = true,		-- 回春
        [155777] = false,	-- 萌芽
        [8936] = false,		-- 愈合
        [33763] = false,	-- 生命绽放
        [48438] = false,	-- 野性成长
		[102351] = false,	-- 塞纳里奥结界
        [200389] = false,	-- 栽培
		[102342] = false,	-- 铁木树皮
	},
	["PALADIN"] = {
		[53563] = true,	-- 圣光道标
        [156910] = false,	-- 信仰道标
		[223306] = false,	-- 赋予信仰
		[1022] = false,		-- 保护之手
		[287280] = false,	-- 圣光闪烁
		[200025] = false,	-- Beacon of Virtue
	},
	["SHAMAN"] = {
		[61295] = true,	-- 激流
		[974] = false,
	},
	["MONK"] = {
		[119611] = true,	-- 复苏之雾
        [124682] = false,	-- 氤氲之雾
        [124081] = false,	-- 禅意波
		[191840] = false,	-- 精华之泉
		[115175] = false,	-- 抚慰之雾
		[116849] = false,	-- 作茧缚命
	},
	["PRIEST"] = {
		[41635] = true,	-- 愈合祷言
		[194384] = false, 	-- 救赎
		[139] = false, 		-- 恢复
		[17] = false, 		-- 盾
		[33206] = false, 	-- 痛苦压制
        [47788] = false, 	-- 守护之魂
	},
}

G.my_hots = G.hots[G.myClass]

G.Buffs = {
	["ALL"] = {
		[33206]  = 40, -- 痛苦压制
        [47788]  = 80, -- 守护之魂
		[102342] = 30, -- 铁木树皮
	},
	["DRUID"] = {--小德                       
		[22812]  = 20, -- 树皮术
		[61336]  = 50, -- 生存本能
	},
	["PALADIN"] = {--骑士                       
		[1022]   = 95, -- 保护之手
		[31850]  = 80, -- 炽热防御者
        [498]    = 20, -- 圣佑术
		[642]    = 95, -- 圣盾术
		[86659]  = 50, -- 远古列王守卫
	},
	["DEATHKNIGHT"] = {--DK
		[48792]  = 20, -- 冰封之韧
		[49028]  = 50, -- 吸血鬼之血
		[55233]  = 40, -- 符文刃舞
	},
	["WARRIOR"] = {--战士
		[871]    = 40, -- 盾墙
		[184364] = 30, -- 狂怒回复
	},
	["DEMONHUNTER"] = {--DH                             
		[196555] = 95, -- 虚空行走 浩劫
	},
	["HUNTER"] = {--猎人                           
		[186265] = 80, -- 灵龟守护
	},
	["ROGUE"] = {--盗贼                           
		[31224]  = 95, -- 暗影斗篷
		[1966]   = 40, -- 佯攻
	},
	["WARLOCK"] = {--术士                           
		[104773] = 40, -- 不灭决心
	},
	["MAGE"] = {--法师                           
		[45438]  = 95, -- 寒冰屏障
	},
	["MONK"] = {--武僧                       
		[115203] = 40, -- 壮胆酒    
		[122470] = 30, -- 业报之触
		[122783] = 50, -- 散魔功
	},
	["SHAMAN"] = {--萨满                           
		[108271] = 40, -- 星界转移
	},
}

G.Instance = {
	{ -- 伤逝剧场
		id = 1187,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},	
	{ -- 凋魂之殇
		id = 1183,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 塞兹仙林的迷雾
		id = 1184,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 彼界
		id = 1189,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 晋升高塔
		id = 1186,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 赎罪大厅
		id = 1185,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 赤红深渊
		id = 1189,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 通灵战潮
		id = 1182,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
	{ -- 纳斯利亚堡
		id = 1190,
		encounters = { 			
			debuffs = {
				
			},
			spells = {
			
			},			
		},
	},
}

G.Character_default_Settings = {
	Layout = {
		anchor = "TOPLEFT",
		size = 36,
		glow = true,
		test = false,
	},
	Add = {
		-- 团队
		raid_sur = true,
		raid_sur_num = 1,
		raid_sur_value = 50,
		
		raid_sur_melee = false,
		raid_sur_melee_num = 1,
		raid_sur_melee_value = 50,
		
		raid_sur_ranged = false,
		raid_sur_ranged_num = 1,
		raid_sur_ranged_value = 50,
		
		raid_sur_tank = false,
		raid_sur_tank_num = 1,
		raid_sur_tank_value = 50,
		
		raid_icd = false,
		raid_icd_num = 5,
		
		raid_hot = false,
		raid_hashot_logic = "any",
		raid_hot_logic = "lessthan",
		raid_hot_num = 1,
		raid_hot_spells = {},
		
		raid_hot_lack = false,
		raid_hot_lack_num = 1,
		raid_hot_lack_value = 90,
		raid_hot_lack_dur = 3,
		
		-- 自身
		self_buff = false,
		self_buff_logic = "any",
		enable_buffs = {},
		
		self_spell = false,
		enable_spell = 0,
		
		self_item = false,
		enable_item = 0,
		
		self_talent = false,
		self_talent_logic = "any",
		enable_talents = {},
		
		self_myhealth = false,
		self_myhealth_value = 80,
		
		self_holypower = false,
		self_holypower_value = 3,
		
		-- 目标
		target_rolefilter = false,
		target_role = "me",
		
		target_lackhot = false,
		target_lackhot_logic = "any",
		target_lackhots = {},
		
		target_hashot = false,
		target_hashot_logic = "any",
		target_hashots = {},
		
		-- 图标
		use_custom_icon = false,
		custom_icon = 74008,
		
		-- 顺序
		order_logic = "sur_order",
	},
	Logic = {},
	Buffs = {},
	Debuffs = {},
}

for spellid, enable in pairs(G.my_spells) do
	if enable then
		G.Character_default_Settings.Add.select_icon = spellid
		break
	end
end

for spellid, enable in pairs(G.my_hots) do
	if enable then
		G.Character_default_Settings.Add.raid_hot_lack_spellid = spellid
		break
	end
end

for class, t in pairs(G.Buffs) do
	for spellID, value in pairs(t) do
		G.Character_default_Settings.Buffs[spellID] = value
	end
end

for index, t in pairs(G.Instance) do
	for k, v in pairs(t) do
		if k == "encounters" then
			for type, spells in pairs(v) do
				if type == "debuffs" then
					for spellID, value in pairs(spells) do
						G.Character_default_Settings.Debuffs[spellID] = value
					end
				end
			end
		end
	end
end

local Account_default_Settings = {

}

function F.LoadVariables()
	if SH_CDB == nil then
		SH_CDB = {}
	end
	for a, b in pairs(G.Character_default_Settings) do
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

StaticPopupDialogs[addon_name.."Cannot Import"] = {
	text = L["无法导入"],
	button1 = ACCEPT,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

StaticPopupDialogs[addon_name.."Import Confirm"] = {
	text = L["导入确认"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hideOnEscape = 1, 
	whileDead = true,
	preferredIndex = 3,
}

F.ImportSettings = function(str)
	local optionlines = {string.split("^", str)}
	local uiname, version, class = string.split("~", optionlines[1])
	local sameversion, sameclient, sameclass
	
	if uiname ~= "SmartHealing Export" then
		StaticPopupDialogs[addon_name.."Cannot Import"].text = L["无法导入"]
		StaticPopup_Show(addon_name.."Cannot Import")
	elseif class ~= G.myClass then
		StaticPopupDialogs[addon_name.."Cannot Import"].text = format(L["职业不符合"], class, G.myClass)
		StaticPopup_Show(addon_name.."Cannot Import")
	else
		if version ~= G.Version then
			StaticPopupDialogs[addon_name.."Import Confirm"].text = format(L["版本不符合"], version, G.Version)
		else
			StaticPopupDialogs[addon_name.."Import Confirm"].text = L["导入确认"]
		end
		StaticPopupDialogs[addon_name.."Import Confirm"].OnAccept = function()
			SH_CDB["Logic"] = {}
			for index, v in pairs(optionlines) do
				if index ~= 1 then
					local i, k, a = string.split("~", v)
					i = tonumber(i)					
					if tonumber(a) then
						a = tonumber(a)
					elseif a == "true" then
						a = true
					elseif a == "false" then
						a = false
					end
					if not SH_CDB["Logic"][i] then
						SH_CDB["Logic"][i] = {}
						for key, value in pairs(G.Character_default_Settings.Add) do
							if type(value) ~= "table" then
								SH_CDB["Logic"][i][key] = value
							else
								SH_CDB["Logic"][i][key] = {}
							end
						end
					end	
					if G.Character_default_Settings.Add[k] ~= nil then						
						if type(G.Character_default_Settings.Add[k]) ~= "table" then
							SH_CDB["Logic"][i][k] = a
						else
							if not SH_CDB["Logic"][i][k] then
								SH_CDB["Logic"][i][k] = {}
							end
							SH_CDB["Logic"][i][k][a] = true
						end
					end
				end
			end
			G.gui:Hide()
			G.gui:Show()
		end
		StaticPopup_Show(addon_name.."Import Confirm")
	end
end

F.GetExportString = function()
	local str = "SmartHealing Export".."~"..G.Version.."~"..G.myClass
	for i, t in pairs(SH_CDB["Logic"]) do
		for key, value in pairs(G.Character_default_Settings.Add) do
			if type(value) ~= "table" then
				if t[key]~= nil and t[key] ~= value then
					local valuetext
					if t[key] == false then
						valuetext = "false"
					elseif t[key] == true then
						valuetext = "true"
					else
						valuetext = t[key]
					end
					str = str.."^"..i.."~"..key.."~"..valuetext
				end
			else
				for id, v in pairs(t[key]) do
					str = str.."^"..i.."~"..key.."~"..id
				end
			end
		end
	end
	return str
end