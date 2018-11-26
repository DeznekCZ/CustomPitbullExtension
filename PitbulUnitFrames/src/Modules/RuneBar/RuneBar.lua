
local PitBull4 = _G.PitBull4
local L = PitBull4.L

local EXAMPLE_VALUE = 0.6
local PowerBarColor = _G.PowerBarColor

-- CONSTANTS ----------------------------------------------------------------

local SPELL_POWER_RUNES = 5 -- Enum.PowerType.Runes

local STANDARD_SIZE = 15
local BORDER_SIZE = 3
local SPACING = 3

local HALF_STANDARD_SIZE = STANDARD_SIZE / 2

local CONTAINER_HEIGHT = STANDARD_SIZE + BORDER_SIZE * 2

-- END CONSTANTS ------------------------------------------------------------

local PitBull4_RuneBar = PitBull4:NewModule("RuneBar", "AceEvent-3.0")

PitBull4_RuneBar:SetModuleType("bar")
PitBull4_RuneBar:SetName(L["Rune bar"])
PitBull4_RuneBar:SetDescription(L["Show a bar for death kinght runes."])
PitBull4_RuneBar.allow_animations = true
PitBull4_RuneBar:SetDefaults({
	position = 3,
	size = 1,
	enabled = false,
},{
	colors = {
		bloodrune = {
			0.882352941176471, -- [1]
			0,
			0,
		},
		bloodrune1 = {
			0.505882352941176, -- [1]
			0,
			0,
		},
		bloodrune2 = {
			0.243137254901961, -- [1]
			0,
			0,
		},
		frostrune = {
			0.501960784313726, -- [1]
			0.501960784313726, -- [2]
			1,
		},
		frostrune1 = {
			0.250980392156863, -- [1]
			0.270588235294118, -- [2]
			0.67843137254902, -- [3]
		},
		frostrune2 = {
			0.00784313725490196, -- [1]
			0, -- [2]
			0.266666666666667, -- [3]
		},
		unholyrune = {
			0, -- [1]
			0.788235294117647, -- [2]
			0,
		},
		unholyrune1 = {
			0, -- [1]
			0.384313725490196, -- [2]
			0,
		},
		unholyrune2 = {
			0, -- [1]
			0.219607843137255, -- [2]
			0,
		},
		deathrune = {
			0.584313725490196, -- [1]
			0,
			0.584313725490196,
		},
		deathrune1 = {
			0.415686274509804, -- [1]
			0.415686274509804,
			0,
		},
		deathrune2 = {
			0.266666666666667, -- [1]
			0,
			0.266666666666667,
		},
	}
})

local timerFrame = CreateFrame("Frame")
timerFrame:Hide()

function PitBull4_RuneBar:OnEnable()
	timerFrame:Show()
end

function PitBull4_RuneBar:OnDisable()
	timerFrame:Hide()
end

local nextTime = 0

timerFrame:SetScript("OnUpdate", function()
	if GetTime() > nextTime then
		PitBull4_RuneBar:UpdateAll()
		nextTime = GetTime() + 0.2
--		nextTime = GetTime() + 1.0
	end
end)

function PitBull4_RuneBar:AboveZero(number)
	if number > 0 then return number else return 0 end
end

function PitBull4_RuneBar:UpdateFrame(frame)
	if DEBUG then
		expect(frame, 'typeof', 'frame')
	end

	local count, full, runes = self:GetValue(frame)
	if count < 1 then
		return self:ClearFrame(frame)
	end

	local db = self:GetLayoutDB(frame)
	local id = self.id
	local control = frame[id]
	local made_control = not control
	if made_control then
		control = PitBull4.Controls.MakeBetterStatusBar(frame)
		frame[id] = control
	end
		
	control:SetTexture(self:GetTexture(frame))
	
	if full == count then
		control:SetValue(1)
		control:SetExtraValue(0)
		control:SetExtra2Value(0)
	else
		local curTime = GetTime()
		local start = 0
		local duration = {[1] = 0, [2] = 0}
		local restTime = {[1] = 0, [2] = 0}
		local countStart = {[1] = 0, [2] = 0}
		local didx = 0
		local rune = count
		while rune > full do
			local r = runes[rune]
			if r.start == start then
				duration[didx] = duration[didx] + r.duration
				restTime[didx] = restTime[didx] + self:AboveZero(r.start + r.duration - curTime)
				countStart[didx] = countStart[didx] + 1
			elseif didx == 2 then
				break -- too much indices
			else
				didx = didx + 1
				start = r.start
				duration[didx] = r.duration
				restTime[didx] = self:AboveZero(r.start + r.duration - curTime)
				countStart[didx] = 1
			end
			rune = rune - 1
		end
	
--		local count1 = countStart[1]
	
--		if count1 > 0 then
--			local rest1 = restTime[1]
--			local dur1 = duration[1]
--			control:SetValue((full / count) + (dur1 - rest1) * count1 / (dur1 * count))
--			control:SetExtraValue((rest1 * count1) / (dur1 * count))
--			
--			local count2 = countStart[2]
--			if count2 > 0 then
--				local dur2 = duration[2]
--				local rest2 = restTime[2]
--				control:SetExtra2Value((rest2 * count2) / (dur2 * count))
--			else
--				control:SetExtra2Value(0)
--			end
--		else
--			control:SetValue(full / count)
--			control:SetExtraValue(0)
--			control:SetExtra2Value(0)
--		end

		control:SetValue(full / count)
		local count1 = countStart[1]
		if count1 > 0 then
			local rest1 = restTime[1]
			local dur1 = duration[1]
			control:SetExtraValue((dur1 - rest1) * count1 / (dur1 * count))
			control:SetExtra2Value((rest1 * count1) / (dur1 * count))
		else
			control:SetExtraValue(0)
			control:SetExtra2Value(0)
		end
	end

	if self.allow_animations then
		control:SetAnimated(db.animated)
		control:SetFade(db.fade)
		control:SetAnimDuration(db.anim_duration)
	end
	
	local bar_db = self:GetLayoutDB(frame)
	local r,g,b,a
	r, g, b = self:GetColor(frame, control:GetValue())
	control:SetColor(r, g, b)
	control:SetNormalAlpha(bar_db.alpha)
	
	r, g, b = self:GetExtraColor(frame, control:GetValue())
	control:SetExtraColor(r, g, b)
	control:SetExtraAlpha(bar_db.alpha)
	
	r, g, b = self:GetExtra2Color(frame, control:GetValue())
	control:SetExtra2Color(r, g, b)
	control:SetExtra2Alpha(bar_db.alpha)

	control:SetBackgroundColor(0, 0, 0)
	control:SetBackgroundAlpha(bar_db.background_alpha)

	control:Show()

	return true
end

function PitBull4_RuneBar:GetValue(frame)
	local numRunes = UnitPowerMax("player", SPELL_POWER_RUNES)
	if numRunes < 1 then return 0 end

	local full = 0
	
	local runes = {}
	
	for rune = 1, numRunes do
		local start, duration, ready = GetRuneCooldown(rune)
		if ready == true then
			runes[rune] = {ready = true}
			full = full + 1
			if rune > 1 then
				local added = rune
				local sorted = rune - 1
				while sorted > 0 do
					local s = runes[sorted]
					if s.ready == false then
						runes[added].ready     = s.ready
						runes[added].duration  = s.duration
						runes[added].start     = s.start
						runes[sorted].ready    = true
						runes[sorted].duration = nil
						runes[sorted].start    = nil
						added = added - 1
						sorted = sorted - 1
					else
						break
					end
				end
			end
		else
			runes[rune] = {ready = false, start = start, duration = duration}
			-- sort
			if rune > 1 then
				local added = rune
				local sorted = rune - 1
				while sorted > 0 do
					local s = runes[sorted]
					if s.ready == false and s.start < start then
						runes[added].ready     = s.ready
						runes[added].duration  = s.duration
						runes[added].start     = s.start
						runes[sorted].ready    = false
						runes[sorted].duration = duration
						runes[sorted].start    = start
						added = added - 1
						sorted = sorted - 1
					else
						break
					end
				end
			end
		end
	end
	return numRunes, full, runes
end

function PitBull4_RuneBar:GetExampleValue(frame)
	return 3/6, 1/6
end

function PitBull4_RuneBar:GetColor(frame, value)
	local unit = frame.unit
	local spec = GetSpecialization()
	
	if not spec then
		return unpack(PitBull4.RuneColors.RUNETYPE_DEATH)
	else
		return unpack( (spec == 1 and self.db.profile.global.colors.bloodrune)
		            or (spec == 2 and self.db.profile.global.colors.frostrune)
		            or (spec == 3 and self.db.profile.global.colors.unholyrune)
		            or                self.db.profile.global.colors.deathrune
		       ) -- select color
	end
end

function PitBull4_RuneBar:GetExtraColor(frame, value)
	local unit = frame.unit
	local spec = GetSpecialization()
	
	if not spec then
		return unpack(PitBull4.RuneColors.RUNETYPE_DEATH)
	else
		return unpack( (spec == 1 and self.db.profile.global.colors.bloodrune1)
		            or (spec == 2 and self.db.profile.global.colors.frostrune1)
		            or (spec == 3 and self.db.profile.global.colors.unholyrune1)
		            or                self.db.profile.global.colors.deathrune1
		       ) -- select color
	end
end

function PitBull4_RuneBar:GetExtra2Color(frame, value)
	local unit = frame.unit
	local spec = GetSpecialization()
	
	if not spec then
		return unpack(PitBull4.RuneColors.RUNETYPE_DEATH)
	else
		return unpack( (spec == 1 and self.db.profile.global.colors.bloodrune2)
		            or (spec == 2 and self.db.profile.global.colors.frostrune2)
		            or (spec == 3 and self.db.profile.global.colors.unholyrune2)
		            or                self.db.profile.global.colors.deathrune2
		       ) -- select color
	end
end

function PitBull4_RuneBar:GetExampleColor(frame)
	return unpack(self.db.profile.global.colors.deathrune)
end

PitBull4_RuneBar:SetColorOptionsFunction(function(self)
	local function get(info)
		return unpack(self.db.profile.global.colors[info[#info]])
	end
	local function set(info, r, g, b)
		local color = self.db.profile.global.colors[info[#info]]
		color[1], color[2], color[3] = r, g, b
	end
	
	return 'bloodrune', {
		type = 'color',
		name = L["Blood"],
		get = get,
		set = set,
	},'bloodrune1', {
		type = 'color',
		name = L["Blood - cooldown 1"],
		get = get,
		set = set,
	},'bloodrune2', {
		type = 'color',
		name = L["Blood - cooldown 2"],
		get = get,
		set = set,
	},
	'frostrune', {
		type = 'color',
		name = L["Frost"],
		get = get,
		set = set,
	},
	'frostrune1', {
		type = 'color',
		name = L["Frost - cooldown 1"],
		get = get,
		set = set,
	},
	'frostrune2', {
		type = 'color',
		name = L["Frost - cooldown 2"],
		get = get,
		set = set,
	},
	'unholyrune', {
		type = 'color',
		name = L["Unholy"],
		get = get,
		set = set,
	},
	'unholyrune1', {
		type = 'color',
		name = L["Unholy - cooldown 1"],
		get = get,
		set = set,
	},
	'unholyrune2', {
		type = 'color',
		name = L["Unholy - cooldown 2"],
		get = get,
		set = set,
	},
	'deathrune', {
		type = 'color',
		name = L["Death"],
		get = get,
		set = set,
	},
	'deathrune1', {
		type = 'color',
		name = L["Death - cooldown 1"],
		get = get,
		set = set,
	},
	'deathrune2', {
		type = 'color',
		name = L["Death - cooldown 2"],
		get = get,
		set = set,
	},
	function(info)
		local colors = self.db.profile.global.colors
		colors.bloodrune = {
			0.882352941176471, -- [1]
			0,
			0,
		}
		colors.bloodrune1 = {
			0.505882352941176, -- [1]
			0,
			0,
		}
		colors.bloodrune2 = {
			0.243137254901961, -- [1]
			0,
			0,
		}
		colors.frostrune = {
			0.501960784313726, -- [1]
			0.501960784313726, -- [2]
			1,
		}
		colors.frostrune1 = {
			0.250980392156863, -- [1]
			0.270588235294118, -- [2]
			0.67843137254902, -- [3]
		}
		colors.frostrune2 = {
			0.0117647058823529, -- [1]
			0,
			0.462745098039216,
		}
		colors.unholyrune = {
			0, -- [1]
			0.788235294117647, -- [2]
			0,
		}
		colors.unholyrune1 = {
			0, -- [1]
			0.384313725490196, -- [2]
			0,
		}
		colors.unholyrune2 = {
			0, -- [1]
			0.219607843137255, -- [2]
			0,
		}
		colors.deathrune = {
			0.584313725490196, -- [1]
			0,
			0.584313725490196,
		}
		colors.deathrune1 = {
			0.415686274509804, -- [1]
			0.415686274509804,
			0,
		}
		colors.deathrune2 = {
			0.266666666666667, -- [1]
			0,
			0.266666666666667,
		}
	end
end)