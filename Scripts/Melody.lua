CONSTMELODY = {}
local melody = CONSTMELODY

-- Variables / Global Functions

    MELODY_THEME = true

    local _themename = string.sub(THEME:GetPath(2,'','_blank.png'),9)
    melody.ThemeName = string.sub(_themename,1,string.find(_themename,'/')-1)
    melody.GetWindowTitle = function()
        if FUCK_EXE then
            local ver_str,ver_num = melody.GetBuildVersion()
            return "Constant Melody X - NotITG " .. ver_str ..' ('.. GAMESTATE:GetVersionDate() ..')'
        else
            return "Constant Melody X - OpenITG"
        end
    end

    melody.RandomBG = 1

    local Modulo = function(a,b) return (a - math.floor(a/b)*b) end
    local Moduloop = function(a,min,max)
        local v = a
        local diff = math.abs(max-min)
        while v > max do v=v-diff end
        while v < min do v=v+diff end
        return v
    end
    local SplitByNumber = function(str,num)
        local nt = {}; local s = "";
        --
        for i=1,string.len(str) do
            if (Modulo(i,num)) == 0 then
                table.insert(nt,s)
                s = ""
            end
            local l = string.sub(str,i,i);
            s = s .. l
        end
        if s ~= "" then table.insert(nt,s); s = "" end
        --
        return nt
    end
    local Join = function(a,b)
        if not b then b = '' end
        local c = ""
        for i,v in pairs(a) do
            if i == table.getn(a) then c = c .. v
            else c = c .. v .. b
            end
        end
        return c
    end
    local TrimEnd = function(str,let)
        local s = ""; local c = string.len(str)
        for i=string.len(str),1,-1 do
            local l = string.sub(str,i,i)
            if l == let then c = c - 1; else s = string.sub(str,1,c); break end 
        end
        return s
    end
    local TrimStart = function(str,let)
        local s = ""; local c = 1;
        for i=1,string.len(str) do
            local l = string.sub(str,i,i)
            if l == let then c = c + 1; else s = string.sub(str,c,string.len(str)); break end
        end
        return s;
    end
    local ContainsLetter = function(str,let)
        for i=1,string.len(str) do
            if string.sub(str,i,i) == let then return true end
        end
        return false
    end
    melody.Split = function(str,sep)
        local t = {}; local c = 1; local s = "";
        -- woa
        if not ContainsLetter(str,sep) then return {str} end
        -- tell me how to split strings easily :(
        for i=1,string.len(str) do
            local l = string.sub(str,i,i);
            if l ~= sep then s = s..l -- If not encountered split, add to local string
            elseif i == string.len(str) and s ~= "" then t[c] = s; -- If end and s is not empty, insert to local table
            else t[c] = s; c = c + 1; s = ""; -- If encountered split, add to table
            end
        end
        if s ~= "" then table.insert(t,s) end
        --
        return t
    end
    melody.Moo = function()
        SCREENMAN:SystemMessage('Moo!')
    end
    melody.DiffuseActor = function(actor,alpha)
        local r,g,b,a = ColorRGB()
        if r + g + b == 3 then -- empty
            r,g,b,a = ColorRGB(math.random(1,12),true)
        end
        if alpha then a = alpha; end
        actor:diffuse(r,g,b,a)
    end
    local Round = function(a)
        return math.floor(a+0.5)
    end
    local FunctionFilter = function(a,b)
        local t = {}
        for i,v in pairs(a) do
            if b(v) then table.insert(t,v) end
        end
        return t
    end
    melody.SecToHHMMSS = function(t)
        local seconds = t
        if seconds <= 0 then
            return "00:00:00";
        else
            local hours = string.format("%02.f", math.floor(seconds/3600));
            local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
            local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
            return hours..":"..mins..":"..secs
        end
    end

-- Versions

    melody.BuildVersions = {
        ['V1']     = 20161226,
        ['V2']     = 20170405,
        ['V3']     = 20180617,
        ['V3.1']   = 20180827,
        ['V4']     = 20200112,
        ['V4.0.1'] = 20200126,
        ['V4.1']   = 20200402, -- All versions are welcome, except do_not
		['4.2']    = 20210420, -- nice
    }
    melody.GetBuildVersion = function()
        if not FUCK_EXE then return nil end

        local version_string = 'V1'
        local version_date = melody.BuildVersions[ version_string ]

		for k,v in pairs(melody.BuildVersions) do
            if tonumber(GAMESTATE:GetVersionDate()) >= v  then
                
                version_string = k
                version_date = v

            end
        end

        return version_string, version_date
    end
    melody.MinimumVersion = function(build) -- OpenITG|V1|V2|V3|V3.1|V4
        if build ~= 'OpenITG' and not FUCK_EXE then return false end
        if build == 'OpenITG' then return true end -- Only one check for OpenITG

        local v_str,v_num = melody.GetBuildVersion()

        return v_num >= melody.BuildVersions[build]
    end

-- Profile

    melody.Profile = {}
    melody.Profile.Profile = function(pn)
        if not PROFILEMAN then return {} end
        if pn == 0 then return PROFILEMAN:GetMachineProfile():GetSaved()
        else return PROFILEMAN:GetProfile(pn-1):GetSaved() end
    end
    melody.Profile.Get = function()
        if not melody.Profile.Profile(0) then return {} end
        if not melody.Profile.Profile(0).Melody then
            melody.Profile.Profile(0).Melody = {
                -- Defaults
                Options_ScreenStageOptions=false,
                Options_EvaluationMusic=true,
                Options_SelectMusicPony=true,
                Options_ProgressBar=false,

                -- Private
                BorderlessWindowed=false,
            }
        end
        return melody.Profile.Profile(0).Melody
    end
    melody.Profile.Set = function(t)
        if t then melody.Profile.Profile(0).Melody = t; end
        PROFILEMAN:SaveMachineProfile()
    end
    melody.Profile.__call = function(s,...)
        return melody.Profile.Profile(arg[1])
    end
    setmetatable(melody.Profile,melody.Profile)

-- Pony

    -- Hi Trotmania <3

    melody.Pony = {}
    melody.Pony.Selected = 1 -- For some reason, this is offsetted
    melody.Pony.Pony = function(p)
        if not melody.Profile.Get() then return 1 end
        if not melody.Profile.Get().Pony then melody.Profile.Get().Pony = 1 end
        if p then
            melody.Profile.Get().Pony = p
            Color(p)
        end
        return melody.Profile.Get().Pony or 1
    end
    melody.Pony.Default = function()
        local p = melody.Pony()
        return (p>9) and (p) or ('0'..tostring(p))
    end
    melody.Pony.NameUsingNumber = function(p)
        if not p then p = melody.Pony() end
        local pony = {
            [1] = "Twilight Sparkle",
            [2] = "Applejack",
            [3] = "Fluttershy",
            [4] = "Rarity",
            [5] = "Pinkie Pie",
            [6] = "Rainbow Dash",
            [7] = "Apple Bloom",
            [8] = "Scootaloo",
            [9] = "Sweetie Belle",
            [10] = "Princess Celestia",
            [11] = "Princess Luna",
            [12] = "Princess Cadance"
        }
        return pony[p] or "Derpy Hooves" -- owo what's this???
    end
    melody.Pony.GetSpriteDir = function(color)
        if melody.Chegg then return ('Themes/'.. melody.ThemeName ..'/Graphics/ScreenSelectColor scroll chegg.png') end
        if not color then color = melody.Pony(); end
        --
        local c = tostring(color)
        if color < 10 then c = '0'..c end
        --
        return ('Themes/'.. melody.ThemeName ..'/Graphics/ScreenSelectColor scroll choice'..c..'.png')
    end
    melody.Pony.TextTransformDiffuse = function(offset,numItems)
        local act_offset = math.abs(offset)
        local color_index = 1   

        while act_offset > 1 do
            act_offset=act_offset-1
            color_index=color_index+1
        end

        local left_color = color_index
        local right_color = math.mod(color_index,numItems) + 1

        local _or,_og,_ob = ColorRGB(left_color,true)
        local _nr,_ng,_nb = ColorRGB(right_color,true)

        local r = inOutCubic(act_offset,_or,(_nr-_or),1)
        local g = inOutCubic(act_offset,_og,(_ng-_og),1)
        local b = inOutCubic(act_offset,_ob,(_nb-_ob),1)

        melody.Pony.TextFrame:diffusecolor(r,g,b,1)
    end
    melody.Pony.ScrollerTransform = function(self,offset,itemIndex,numItems)
        local n = 80;
        local x = n*offset;
        if x > 6*n then
            x = x-12*n
        elseif x < -6*n then
            x = x+12*n
        end

        -- this was bothering me for quite awhile
        local screen_mult = ( ( ( SCREEN_WIDTH/640 ) - 1 ) * 1.2 ) + 1

        local s = scale(math.abs(x*(2/screen_mult)),0,4*n,3,-1)
        local z = clamp(s,1,3)
        z = scale(z,1,3,1,1.5)
        s = clamp(s,0,maxClamp) 
        if Off == 0 then
            self:diffuse(1,1,1,s)
        end
        self:x(x*1.5)
        self:zoom(0.5)
        self:z(-1*math.abs(x/n))

        if math.abs(offset) <= 1 then
            local t = 1 - math.abs(offset) -- [0-1]
            self:zoom(0.5 + (1-0.5) * t)
        end
        if melody.Pony.TextFrame and math.abs(offset)<0.5 then
            local newIndex = Moduloop(itemIndex+1,1,12)
            melody.Pony.TextFrame:settext( CONSTMELODY.Pony.NameUsingNumber(newIndex) );
            CONSTMELODY.Pony.Selected = newIndex;
        end

        if itemIndex==0 then melody.Pony.TextTransformDiffuse(offset,numItems) end
    end -- Function was too long and really hard to work with :/
    melody.Pony.__call = function(t,...)
        return melody.Pony.Pony(arg[1])
    end
    setmetatable(melody.Pony,melody.Pony)

-- Gameplay

    melody.Gameplay = {}
    melody.Gameplay.ComboTween = function(self)
        if melody.Profile.Get().Options_DefaultComboTween then
            local combo=self:GetZoom(); 
            local newZoom=scale(combo,50,3000,0.8,1.8);
            self:zoom(0.7*newZoom);
            self:linear(0.05); 
            self:zoom(0.7*newZoom);
        else
            self:zoom(0.5);
            self:zoomx(1.3);
            self:decelerate(0.25/GAMESTATE:GetCurBPS());
            self:zoomx(0.5);
        end
    end
    melody.Gameplay.Failed = {0,0}
    melody.Gameplay.BongoCat = false
    melody.Gameplay.BongoCatInput = {{0,0,0,0},{0,0,0,0}}

-- Evaluation

    melody.Evaluation = {}
    melody.Evaluation.SetColorFromText = function(actor,offset)
        actor:y(27 * offset)
        actor:zoom(0.35)
        actor:horizalign('right')
        actor:shadowlength(0)
        if melody.Profile.Get().Options_ColorfulEvaluation then
            local c = {
                ['FANTASTIC'] = function(actor) actor:diffuse(0,1,1,1) end,
                ['EXCELLENT'] = function(actor) actor:diffuse(1,1,90/255,1) end,
                ['GREAT']     = function(actor) actor:diffuse(0.43529411764705883,1,0.15294117647058825,1) end,
                ['DECENT']    = function(actor) actor:diffuse(0.6392156862745098,0.40784313725490196,0.6431372549019608,1) end,
                ['WAY OFF']   = function(actor) actor:diffuse(1,0.6039215686274509,0.011764705882352941,1) end,
                ['MISS']      = function(actor) actor:diffuse(0.8941176470588236,0,0,1) end,
            }
            c[ actor:GetText() ]( actor )
        end
    end -- For ScreenEvaluation grade frame
    melody.Evaluation.SetColorFromIndex = function(actor,index)
        local c = {
            function(actor) actor:diffuse(0,1,1,1) end,
            function(actor) actor:diffuse(1,1,90/255,1) end,
            function(actor) actor:diffuse(0.43529411764705883,1,0.15294117647058825,1) end,
            function(actor) actor:diffuse(0.6392156862745098,0.40784313725490196,0.6431372549019608,1) end,
            function(actor) actor:diffuse(1,0.6039215686274509,0.011764705882352941,1) end,
            function(actor) actor:diffuse(0.8941176470588236,0,0,1) end,
        }
        c[ index ]( actor )
    end -- For ScoreRow.xml / ScreenEvaluation overlay.xml

-- Get Functions

    melody.Get = {}
    melody.Get.Judgments = function()

        if not FUCK_EXE then
            -- Manually insert stuffs here
            local t = {
                'Default',
                'itg2hd',
                'splatoon2',
                'njsrt',
                'tmday',
                'tmnight',
                'wp',
                'groovenights',
                'thatquestionsucks',
                'japanese'
            }
            return t
        end

        local t = { GAMESTATE:GetFileStructure('Themes/'.. melody.ThemeName ..'/Graphics/_Judgments/') }
        local j = { 'Default' }

        -- [[ NAMES WITH SPACE SUPPORT ]] --
            -- Fun little thing,
            -- regardless of the type, the 2x6 or 1x6 always comes first before (doubleres) or (res %dx%d)
            -- so we can just get ALL the words before that!

        for i,v in pairs(t) do
            local temp = {}
            for k2,v2 in pairs(melody.Split(v,' ')) do
                if string.find(v2,'%dx%d') then
                    break
                end
                table.insert(temp,v2)
            end
            local a = string.gsub(Join(temp,' '),"%.png","")
            table.insert(j, a )
        end
        
        return j
    end
    melody.Get.NoteSkins = function()
        -- These are usually the old itg-control skins
        local blacklisted = {
            '_scalableBACK',
            'arrowkun',
            'arrowkun-notweens',
            'cel-cmd',
            'cel-cmd-notweens',
            'cel-glow2',
            'cel-yuno',
            'coin',
            'combination',
            'controlcel',
            'controlmetal',
            'controlmetal2',
            'couplesbw',
            'couples-cmd',
            'couplescontrol',
            'de-default',
            'dunno',
            'flat',
            'justholds',
            'latem',
            'metal2_dpad',
            'metal-cmd',
            'metal-cmdholds',
            'metal-cmd-notweens',
            'mindCode',
            'mindError',
            'mindGalaxyKiss',
            'mindKickMetal',
            'mindNoShow',
            'mindPressure',
            'mindRockSTARmetal',
            'mindStarsMetal',
            'mindTechMetal',
            'proxynotes',
            'randomhex',
            'spikes2',
            'splitter',
            'spt',
            'Touhou',
        }
        local n = {}
        --for i,v in pairs({GAMESTATE:GetFileStructure('NoteSkins/dance/')}) do
        for i,v in pairs(NOTESKIN:GetNoteSkinNames()) do
            local cont = false
            for k1,v1 in pairs(blacklisted) do
                if v == v1 then
                    cont = true
                    break
                end
            end
            if not cont then table.insert(n,v) end
        end
        return n
    end
    melody.Get.BuildIcon = function()
        if not FUCK_EXE then
            self:Load(THEME:GetPath(2,'GameLogo','itg'))
        else
            local n = tonumber(GAMESTATE:GetVersionDate())
            local v = 0
            if n>=20161226 then v=v+1 end -- V1
            if n>=20170405 then v=v+1 end -- V2
            if n>=20170609 then v=v+1 end -- V3
            if n>=20170826 then v=v+1 end -- V3.1
            if n>=20200112 then v=v+1 end -- V4
            if v==1 or v==2 then self:Load(THEME:GetPath(2,'GameLogo','nitg'))
            elseif v==3 or v==4 then self:Load(THEME:GetPath(2,'GameLogo','nitg3'))
            elseif v==5 then self:Load(THEME:GetPath(2,'GameLogo','nitg4')) end
        end
    end

-- Message Frame

    melody.ScreenSystemLayer = nil

    melody.MessageFrame = {}
    melody.MessageFrame.Frame = nil
    melody.MessageFrame.MessageOnCommand = function(self)
        --if not CONSTMELODY.MessageFrame.Frame then
        --    CONSTMELODY.MessageFrame.Frame=self;
        --end
        if melody.MinimumVersion('V3') then
            --self:cmd('finishtweening;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y-10;zoom,0.7;diffusealpha,0;bob;effectmagnitude,0,4,0;effectperiod,2;sleep,0.5;decelerate,0.5;diffusealpha,1')
            --self:cmd('sleep,1;decelerate,0.5;diffusealpha,0')
            self:finishtweening()
            self:x(SCREEN_CENTER_X)
            self:y(SCREEN_CENTER_Y - 10)
            self:zoom(0.7)
            self:diffusealpha(0)
            self:bob()
            self:effectmagnitude(0,4,0)
            self:effectperiod(2)
            self:sleep(0.5)
            self:decelerate(0.5)
            self:diffusealpha(1)
            --
            self:sleep(1)
            self:linear(0.5)
            self:diffusealpha(0)
        else
            --self:cmd('finishtweening;horizalign,left;x,SCREEN_LEFT+20;y,SCREEN_TOP+80;zoom,0.5;shadowlength,0;diffusealpha,1;addx,-SCREEN_WIDTH;linear,0.5;addx,SCREEN_WIDTH')
            --self:cmd('sleep,5;linear,0.5;diffusealpha,0')
            self:finishtweening()
            self:horizalign('left')
            self:x(SCREEN_LEFT + 20)
            self:y(SCREEN_TOP + 80)
            self:zoom(0.5)
            self:shadowlength(0)
            self:diffusealpha(1)
            self:addx(-SCREEN_WIDTH)
            self:linear(0.5)
            self:addx(SCREEN_WIDTH)
            --
            self:sleep(5)
            self:linear(0.5)
            self:diffusealpha(0)
        end
        self:wrapwidthpixels(SCREEN_WIDTH*1.2)
    end
    melody.MessageFrame.OffCommand = function(self)
        --
    end

-- Extra Options
    melody.ExtraOptions = {
        EnableScreenStageOptions = function()
            local t = OptionRowBase('ScreenStageOptions')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_ScreenStageOptions then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_ScreenStageOptions = list[1];
            end
            return t
        end,
        EnableDefaultFail = function()
            local t = OptionRowBase('DefaultFail')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_DefaultFail then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                if not CONSTMELODY.MinimumVersion('V3.1') then
                    SCREENMAN:SystemMessage('V3 below detected! Disabling DefaultFail')
                    list[1] = false
                    list[2] = true
                end
                melody.Profile.Get().Options_DefaultFail = list[1];
            end
            return t
        end,
        FailOption_Choices = {'Off','Random'},
        FailOption = function()
            local t = OptionRowBase('FailOption')
            t.OneChoiceForAllPlayers = true
            t.Choices = melody.ExtraOptions.FailOption_Choices
            t.LoadSelections = function(self, list)
                if not CONSTMELODY.MinimumVersion('V3.1') or not FUCK_EXE then
                    list[1] = true
                else
                    if not melody.Profile.Get().Options_FailOption then list[1]=true; return end
                    for i=1, table.getn(self.Choices) do
                        if melody.Profile.Get().Options_FailOption == i then
                            list[i] = true
                            return
                        end
                    end
                end
            end
            t.SaveSelections = function(self, list)
                for i=1, table.getn(self.Choices) do
                    if list[i] then melody.Profile.Get().Options_FailOption = i; break end
                end
                stitch('lua.death').Switch( melody.Profile.Get().Options_FailOption )
            end
            return t
        end,
        ColorfulEvaluation = function()
            local t = OptionRowBase('ColorfulEvaluation')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_ColorfulEvaluation then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_ColorfulEvaluation = list[1];
            end
            return t
        end,
        EvaluationMusic = function()
            local t = OptionRowBase('EvaluationMusic')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_EvaluationMusic then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_EvaluationMusic = list[1];
            end
            return t
        end,
        DefaultComboTween = function()
            local t = OptionRowBase('DefaultComboTween')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_DefaultComboTween then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_DefaultComboTween = list[1];
            end
            return t
        end,
        SelectMusicPony = function()
            local t = OptionRowBase('SelectMusicPony')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_SelectMusicPony then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_SelectMusicPony = list[1];
            end
            return t
        end,
        ProgressBar = function()
            local t = OptionRowBase('ProgressBar')
            t.OneChoiceForAllPlayers = true
            t.Choices = { "Enable", "Disable" }
            t.LoadSelections = function(self, list) if melody.Profile.Get().Options_ProgressBar then list[1] = true else list[2] = true end end
            t.SaveSelections = function(self, list)
                melody.Profile.Get().Options_ProgressBar = list[1];
            end
            return t
        end
    }
-- Break Time
    melody.BreakTime = {}
    melody.BreakTime.Songs = {}
    melody.BreakTime.Choice_Index = 1
    melody.BreakTime.Playing_Index = 1

    melody.BreakTime.Paused = false
-- Overlay
    melody.Overlay = {}
    melody.Overlay.Last_Seen_Screen = ''
-- Discord RPC
    melody.RPC = {}
    melody.RPC.Connected = false
    melody.RPC.UpdateScreen = function(ns)
        if ns == 'ScreenTitleMenu' then
            External:add_buffer(1,{1,1})
        elseif ns == 'ScreenSelectMusic' then
            External:add_buffer(1,{1,2})
        elseif ns == 'ScreenGameplay' then
            External:add_buffer(1,{1,3})
            local song_name = External.encode( GAMESTATE:GetCurrentSong():GetDisplayMainTitle() )
            table.insert(song_name,1,1)
            table.insert(song_name,1,2)
            local song_folder = External.encode( GAMESTATE:GetCurrentSong():GetGroupName() )
            table.insert(song_folder,1,2)
            table.insert(song_folder,1,2)
            local song_length = {2,3,GAMESTATE:GetCurrentSong():MusicLengthSeconds()}
            External:add_buffer(1,song_name)
            External:add_buffer(1,song_folder)
            External:add_buffer(1,song_length)
            External:add_buffer(1,{2,4}) -- push
        elseif string.find(ns,'ScreenEvaluation') then
            External:add_buffer(1,{1,4})
        elseif ns == 'ScreenMelodyBreakTime' then
            External:add_buffer(1,{1,5})
        elseif ns == 'ScreenEdit' then
            External:add_buffer(1,{1,6})
        end
    end
-- Card Display
    melody.Card = {}
    melody.Card[1] = {}
    melody.Card[1].Icon = nil
    melody.Card[1].Text = nil
    melody.Card[1].Position = { SCREEN_CENTER_X-(SCREEN_WIDTH*160/640) , SCREEN_BOTTOM - 13 }
    melody.Card[2] = {}
    melody.Card[2].Icon = nil
    melody.Card[2].Text = nil
    melody.Card[2].Position = { SCREEN_CENTER_X+(SCREEN_WIDTH*160/640) , SCREEN_BOTTOM - 13 }
    -- it was too long
    melody.Card.Initialize_Text = function(self,pn)
        -- shadowlength,0;horizalign,left;vertalign,bottom;zoom,0.4;ztest,1
        self:shadowlength(0)
        self:horizalign(pn==1 and 'left' or 'right')
        self:vertalign('bottom')
        self:zoom(0.4)
        self:ztest(1)

        -- Might consider removing card display at all??????

        -- useless, any screensystemlayer actors can't be grabbed.
        -- melody.Card[pn].Text = self
    end
    melody.Card.Initialize_Icon = function(self,pn)
        -- DrawOrder,311;zoom,0.8
        self:draworder(311)
        self:zoom(0.8)

        melody.Card[pn].Icon = self
    end
-- MISC
    melody.ScreenSelectPlayModeNITG = {}
    melody.ScreenSelectPlayModeNITG.Choice = 1
    melody.ScreenTitleMenu = {}
    melody.ScreenTitleMenu.Choice = 1
    melody.Chegg = false
    melody.IsEditPlaying = false
    melody.Garbage = {} -- Incase I got too lazy
-- 