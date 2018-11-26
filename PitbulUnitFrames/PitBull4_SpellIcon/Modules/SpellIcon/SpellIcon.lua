-- Aura.lua : Core setup of the Aura module and event processing

local PitBull4 = _G.PitBull4
local L = PitBull4.L

local PitBull4_SpellIcon = PitBull4:NewModule("Aura", "AceEvent-3.0")

PitBull4_SpellIcon:SetModuleType("custom")
PitBull4_SpellIcon:SetName(L["SpellIcon"])
PitBull4_SpellIcon:SetDescription(L["Creates clickable frame."])

PitBull4_SpellIcon.OnProfileChanged_funcs = {}

local timerFrame = CreateFrame("Frame")
timerFrame:Hide()
local timer = 0
local elapsed_since_text_update = 0
timerFrame:SetScript("OnUpdate",function(self, elapsed)
	timer = timer + elapsed
	if timer >= 0.2 then
		PitBull4_SpellIcon:OnUpdate()
		timer = 0
	end

	local next_text_update = PitBull4_SpellIcon.next_text_update
	if next_text_update then
		next_text_update = next_text_update - elapsed
		elapsed_since_text_update = elapsed_since_text_update + elapsed
		if next_text_update <= 0 then
			next_text_update = PitBull4_SpellIcon:UpdateCooldownTexts(elapsed_since_text_update)
			elapsed_since_text_update = 0
		end
		PitBull4_SpellIcon.next_text_update = next_text_update
	end
end)

function PitBull4_SpellIcon:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAll")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAll")
	self:RegisterEvent("UNIT_AURA")
	timerFrame:Show()

	-- Need to track spec changes since it can change what they can dispel.
	local _,player_class = UnitClass("player")
	if player_class == "DRUID" or player_class == "HUNTER" or player_class == "MONK" or player_class == "PALADIN" or player_class == "PRIEST" or player_class == "SHAMAN" or player_class == "WARLOCK" then
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
		self:RegisterEvent("SPELLS_CHANGED", "PLAYER_TALENT_UPDATE")
		self:PLAYER_TALENT_UPDATE()
	end
end

function PitBull4_SpellIcon:OnDisable()
	timerFrame:Hide()
end

function PitBull4_SpellIcon:OnProfileChanged()
	local funcs = self.OnProfileChanged_funcs
	for i = 1, #funcs do
		funcs[i](self)
	end
	LibStub("AceConfigRegistry-3.0"):NotifyChange("PitBull4")
end

function PitBull4_SpellIcon:ClearFrame(frame)
	self:ClearAuras(frame)
	if frame.aura_highlight then
		frame.aura_highlight = frame.aura_highlight:Delete()
	end
end

PitBull4_SpellIcon.OnHide = PitBull4_SpellIcon.ClearFrame

function PitBull4_SpellIcon:UpdateFrame(frame)
	self:UpdateSkin(frame)
	self:UpdateAuras(frame)
	self:LayoutAuras(frame)
end

function PitBull4_SpellIcon:LibSharedMedia_Registered(event, mediatype, key)
	if mediatype == "font" then
		self:UpdateAll()
	end
end