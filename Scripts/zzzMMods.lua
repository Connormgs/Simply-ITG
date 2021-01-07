
function SpeedType()
	local t = OptionRowBase((optionIndex == 'Edit' and 'Speed') or 'Speed Mod Type',{'x','C','M'})
	t.LoadSelections = function(self, list, pn) for i,v in ipairs(self.Choices) do if modType[pn+1] == v then list[i] = true end end end
	t.SaveSelections = function(self, list, pn)
		for i,v in ipairs(list) do
			if v then
				if modType[pn+1] then
					-- Preserve the BPM value when cycling between speed mod types
					-- Note: here, modType[pn+1] is the previous selection, and self.Choices[i] is the current selection.
					if self.Choices[i]~='x' and modType[pn+1]=='x' then -- going to a BPM mod from an X-mod
						local maxbpm = tonumber(bpm[2]) or tonumber(bpm[1]) or 0
						if maxbpm > 0 then local xmod = modSpeed[pn+1]/100 modSpeed[pn+1]=maxbpm*xmod end
					elseif self.Choices[i]=='x' and modType[pn+1]~='x' then -- going to an X-mod from a BPM mod
						local maxbpm = tonumber(bpm[2]) or tonumber(bpm[1]) or 0
						if maxbpm > 0 then local xmod = modSpeed[pn+1]/maxbpm modSpeed[pn+1]=xmod*100 end
					end
				end
				modType[pn+1] = self.Choices[i]
			end
		end
		SetSpeedMod(pn+1)
		SetOptionRow('Adjust Speed',true)
	end
	t.LayoutType = 'ShowOneInRow'
	return t
end

function SpeedNumber()
	local function display( text , pn ) text:settext( DisplaySpeedMod(pn) ) end
	local function move(pn,dir,cnt) modSpeed[pn+1] = clamp( AddSnap(modSpeed[pn+1] , dir , cnt , { 5 , 10 , 25 } ) , speedMin , speedMax ); SetSpeedMod(pn+1) end
	return SliderOption('Adjust Speed',move,display)
end
function CalculateSpeedMod()
	if not modType and not modSpeed then modType = {'C','C'} modSpeed = {700,700} end -- fallback defaults
	for pn=1,2 do if Player(pn) then
		for i=speedMin,speedMax do --search for speed mod
			if CheckMod(pn-1,'C'..i) then modType[pn] = 'C'; modSpeed[pn] = i
			elseif CheckMod(pn-1,(i/100)..'x') then modType[pn] = 'x'; modSpeed[pn] = i
			--elseif (OPENITG and CheckMod(pn-1,string.format('M%u',i))) then modType[pn] = 'M'; modSpeed[pn] = i --commented out because oITG doesn't save m-mods properly
			end
		end
		-- Save m-mods as c-mod with a separate flag, for backwards compatibility.
		-- Profile(pn) syntax is used here since ModCustom won't have been populated yet.
		if modType[pn]=='C' and Profile(pn) and Profile(pn).Mods and Profile(pn).Mods.SpeedModType and Profile(pn).Mods.SpeedModType=='M' then modType[pn]='M' end
	end end
end

function SpeedString(pn,speed) local s = speed or modSpeed[pn] or 1; if modType[pn]=='x' then return string.format('%01.2fx',s/100) else return string.format('%s%i', modType[pn], s+0.5) end end

function SetSpeedMod(pn,r)
	--if GAMESTATE:IsDemonstration() then return false end
	--use *10000 to set mods quickly, to allow for cases like Disconnected Hyper Expert (and other files that start early)
	local function IsScreenGameplay() return (Screen():GetChild('LifeP1') or Screen():GetChild('LifeP2')) and true end
	local function IsScreenEvaluation() return (Screen():GetChild('GraphFrameP1') or Screen():GetChild('GraphFrameP2')) and true end
	local function IsScreenPlayerOptions() return (Screen():GetChild('Frame') and Screen():GetChild('Frame'):GetChild('More')) and true end
	local rate=r or 1
	if modType[pn]=='M' then -- M-mods in 3.95, wahey
		local maxbpm = tonumber(bpm[2]) or tonumber(bpm[1]) or 0
		if maxbpm~=0 then
			local xmod=tonumber(modSpeed[pn])/maxbpm
			if IsScreenGameplay() then -- or IsScreenPlayerOptions() then
				ApplyMod(string.format('*10000 %gx',xmod/rate),pn)
			else
				ApplyMod(string.format('1x,C%u',modSpeed[pn]),pn) --for usb saving
			end
		else
			--The following is commented out because we're not using oITG's somewhat broken Mmod functionality.
			--[[
			if OPENITG then
				if IsScreenGameplay() then --or IsScreenPlayerOptions() then
					local mmod = string.format('*10000 M%u',modSpeed[pn]/rate)
					ApplyMod(mmod,pn)
					if not CheckMod(pn-1,mmod) then --mod wasn't applied; fall back to cmod
						ApplyMod(string.format('*10000 1x,*10000 C%u',modSpeed[pn]/rate),pn)
					end
				else
					ApplyMod(string.format('1x,C%u',modSpeed[pn]),pn) --for usb saving
				end
			else
			]] --No bpm? use a c-mod instead
				ApplyMod(string.format('*10000 1x,*10000 C%u',modSpeed[pn]/rate),pn)
			-- end
		end
	else
		--only apply 1x to m-mod on 3.95; applying 1x on oITG will cancel m-mod (because oitg sets its own xmod)
		--if modType[pn]=='C' or modType[pn]=='M' and not OPENITG then ApplyMod('1x',pn) end
		if modType[pn]=='C' then ApplyMod((IsScreenGameplay() and '*10000 1x') or '1x',pn) end

		if IsScreenGameplay() then
			ApplyMod('*10000 '..SpeedString(pn,modSpeed[pn]/rate),pn)
		else
			ApplyMod(SpeedString(pn,modSpeed[pn]/rate),pn)
		end
	end
	BM('SpeedModChanged')
end

function ApplyRateAdjust() for pn=1,2 do if Player(pn) then SetSpeedMod(pn,modRate) end end end
function RevertRateAdjust() for pn=1,2 do if modSpeed then SetSpeedMod(pn) end end end

