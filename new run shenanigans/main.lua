local mod = RegisterMod('New Run Shenanigans', 1)
local game = Game()

if REPENTOGON then
  mod.rngShiftIdx = 35
  mod.controllerOverride = -1
  mod.notification = nil
  mod.seed = nil
  mod.playerTypes = {}
  mod.difficulties = {}
  mod.challenges = {}
  mod.controllers = {}
  mod.controllersMap = {}
  
  mod.challengeUnlocks = {
    [Challenge.CHALLENGE_DARKNESS_FALLS]      = Achievement.CHALLENGE_4_DARKNESS_FALLS,
    [Challenge.CHALLENGE_THE_TANK]            = Achievement.CHALLENGE_5_THE_TANK,
    [Challenge.CHALLENGE_SOLAR_SYSTEM]        = Achievement.CHALLENGE_6_SOLAR_SYSTEM,
    [Challenge.CHALLENGE_SUICIDE_KING]        = Achievement.CHALLENGE_7_SUICIDE_KING,
    [Challenge.CHALLENGE_CAT_GOT_YOUR_TONGUE] = Achievement.CHALLENGE_8_CAT_GOT_YOUR_TONGUE,
    [Challenge.CHALLENGE_DEMO_MAN]            = Achievement.CHALLENGE_9_DEMO_MAN,
    [Challenge.CHALLENGE_CURSED]              = Achievement.CHALLENGE_10_CURSED,
    [Challenge.CHALLENGE_GLASS_CANNON]        = Achievement.CHALLENGE_11_GLASS_CANNON,
    [Challenge.CHALLENGE_THE_FAMILY_MAN]      = Achievement.CHALLENGE_19_THE_FAMILY_MAN,
    [Challenge.CHALLENGE_PURIST]              = Achievement.CHALLENGE_20_PURIST,
    [Challenge.CHALLENGE_XXXXXXXXL]           = Achievement.CHALLENGE_21_XXXXXXXXL,
    [Challenge.CHALLENGE_SPEED]               = Achievement.CHALLENGE_22_SPEED,
    [Challenge.CHALLENGE_BLUE_BOMBER]         = Achievement.CHALLENGE_23_BLUE_BOMBER,
    [Challenge.CHALLENGE_PAY_TO_PLAY]         = Achievement.CHALLENGE_24_PAY_TO_PLAY,
    [Challenge.CHALLENGE_HAVE_A_HEART]        = Achievement.CHALLENGE_25_HAVE_A_HEART,
    [Challenge.CHALLENGE_I_RULE]              = Achievement.CHALLENGE_26_I_RULE,
    [Challenge.CHALLENGE_BRAINS]              = Achievement.CHALLENGE_27_BRAINS,
    [Challenge.CHALLENGE_PRIDE_DAY]           = Achievement.CHALLENGE_28_PRIDE_DAY,
    [Challenge.CHALLENGE_ONANS_STREAK]        = Achievement.CHALLENGE_29_ONANS_STREAK,
    [Challenge.CHALLENGE_GUARDIAN]            = Achievement.CHALLENGE_30_THE_GUARDIAN,
    [Challenge.CHALLENGE_BACKASSWARDS]        = Achievement.CHALLENGE_31_BACKASSWARDS,
    [Challenge.CHALLENGE_APRILS_FOOL]         = Achievement.CHALLENGE_32_APRILS_FOOL,
    [Challenge.CHALLENGE_POKEY_MANS]          = Achievement.CHALLENGE_33_POKEY_MANS,
    [Challenge.CHALLENGE_ULTRA_HARD]          = Achievement.CHALLENGE_34_ULTRA_HARD,
    [Challenge.CHALLENGE_PONG]                = Achievement.CHALLENGE_35_PONG,
    [Challenge.CHALLENGE_BLOODY_MARY]         = Achievement.CHALLENGE_37_BLOODY_MARY,
    [Challenge.CHALLENGE_BAPTISM_BY_FIRE]     = Achievement.CHALLENGE_38_BAPTISM_BY_FIRE,
    [Challenge.CHALLENGE_ISAACS_AWAKENING]    = Achievement.CHALLENGE_39_ISAACS_AWAKENING,
    [Challenge.CHALLENGE_SEEING_DOUBLE]       = Achievement.CHALLENGE_40_SEEING_DOUBLE,
    [Challenge.CHALLENGE_PICA_RUN]            = Achievement.CHALLENGE_41_PICA_RUN,
    [Challenge.CHALLENGE_HOT_POTATO]          = Achievement.CHALLENGE_42_HOT_POTATO,
    [Challenge.CHALLENGE_CANTRIPPED]          = Achievement.CHALLENGE_43_CANTRIPPED,
    [Challenge.CHALLENGE_RED_REDEMPTION]      = Achievement.CHALLENGE_44_RED_REDEMPTION,
    [Challenge.CHALLENGE_DELETE_THIS]         = Achievement.CHALLENGE_45_DELETE_THIS,
  }
  
  function mod:onRender()
    mod:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
    mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
    mod:fillPlayerTypes()
    mod:fillDifficulties()
    mod:fillChallenges()
    mod:setupImGui()
  end
  
  -- reset variables here rather than in MC_PRE_GAME_EXIT
  -- so we don't wipe out the controller override when holding R to restart
  function mod:onMainMenuRender()
    mod.controllerOverride = -1
    mod.notification = nil
    mod.seed = nil
  end
  
  function mod:onPlayerInit(player)
    if game:GetFrameCount() <= 0 and mod.controllerOverride > -1 then
      player:SetControllerIndex(mod.controllerOverride)
    end
    
    if mod.seed then
      -- lock in the seed, and disable achievements
      -- EDEN_TOKENS/STREAK_COUNTER/EDENS_BLESSINGS_NEXT_RUN don't seem to be affected
      Isaac.ExecuteCommand('seed ' .. Seeds.Seed2String(mod.seed))
      mod.seed = nil
    end
    
    if mod.notification then
      ImGui.PushNotification(mod.notification, ImGuiNotificationType.INFO, 5000)
      mod.notification = nil
    end
  end
  
  function mod:localize(category, key)
    local s = Isaac.GetString(category, key)
    return (s == nil or s == 'StringTable::InvalidCategory' or s == 'StringTable::InvalidKey') and key or s
  end
  
  function mod:getXmlPlayerAchievement(id)
    id = tonumber(id)
    
    if math.type(id) == 'integer' then
      local entry = XMLData.GetEntryById(XMLNode.PLAYER, id)
      if entry and type(entry) == 'table' then
        if entry.achievement and entry.achievement ~= '' then
          return entry.achievement
        end
      end
    end
    
    return nil
  end
  
  function mod:getXmlPlayerSourceId(id)
    id = tonumber(id)
    
    if math.type(id) == 'integer' then
      local entry = XMLData.GetEntryById(XMLNode.PLAYER, id)
      if entry and type(entry) == 'table' then
        if entry.sourceid and entry.sourceid ~= '' then
          return entry.sourceid
        end
      end
    end
    
    return nil
  end
  
  function mod:getXmlAchievementId(name)
    local entry = XMLData.GetEntryByName(XMLNode.ACHIEVEMENT, name)
    if entry and type(entry) == 'table' then
      if entry.id and entry.id ~= '' then
        return entry.id
      end
    end
    
    return nil
  end
  
  function mod:getXmlChallengeData(id)
    id = tonumber(id)
    
    if math.type(id) == 'integer' then
      local entry = XMLData.GetEntryById(XMLNode.CHALLENGE, id)
      if entry and type(entry) == 'table' then
        return entry
      end
    end
    
    return nil
  end
  
  function mod:getXmlModName(sourceid)
    local entry = XMLData.GetModById(sourceid)
    if entry and type(entry) == 'table' and entry.name and entry.name ~= '' then
      return entry.name
    end
    
    return nil
  end
  
  function mod:getModdedCharacters()
    local characters = {}
    
    local i = PlayerType.NUM_PLAYER_TYPES -- 41, EntityConfig.GetMaxPlayerType()
    local playerConfig = EntityConfig.GetPlayer(i)
    while playerConfig do
      table.insert(characters, playerConfig)
      
      i = i + 1
      playerConfig = EntityConfig.GetPlayer(i)
    end
    
    return characters
  end
  
  function mod:getPlayerAchievementID(playerConfig)
    -- there's a few hidden player types that don't have achievements set in the default data
    if playerConfig:GetPlayerType() == PlayerType.PLAYER_THESOUL then
      playerConfig = EntityConfig.GetPlayer(PlayerType.PLAYER_THEFORGOTTEN)
    elseif playerConfig:GetPlayerType() == PlayerType.PLAYER_ESAU then
      playerConfig = EntityConfig.GetPlayer(PlayerType.PLAYER_JACOB)
    elseif playerConfig:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
      playerConfig = EntityConfig.GetPlayer(PlayerType.PLAYER_LAZARUS_B)
    elseif playerConfig:GetPlayerType() == PlayerType.PLAYER_JACOB2_B then
      playerConfig = EntityConfig.GetPlayer(PlayerType.PLAYER_JACOB_B)
    elseif playerConfig:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
      playerConfig = EntityConfig.GetPlayer(PlayerType.PLAYER_THEFORGOTTEN_B)
    end
    
    local achievementId = playerConfig:GetAchievementID() -- broken for modded characters right now
    
    if achievementId == 0 then
      local achievement = mod:getXmlPlayerAchievement(playerConfig:GetPlayerType())
      if achievement then
        local tempAchievementId = tonumber(mod:getXmlAchievementId(achievement))
        if math.type(tempAchievementId) == 'integer' then
          achievementId = tempAchievementId
        end
      end
    end
    
    return achievementId
  end
  
  function mod:getNumCompletionMarksToGo(playerType, difficulty)
    local num = 0
    local value = 0
    local completionTypes = {}
    
    if difficulty == Difficulty.DIFFICULTY_NORMAL then
      value = 1
      table.insert(completionTypes, CompletionType.MOMS_HEART)
      table.insert(completionTypes, CompletionType.ISAAC)
      table.insert(completionTypes, CompletionType.SATAN)
      table.insert(completionTypes, CompletionType.BOSS_RUSH)
      table.insert(completionTypes, CompletionType.BLUE_BABY)
      table.insert(completionTypes, CompletionType.LAMB)
      table.insert(completionTypes, CompletionType.MEGA_SATAN)
      table.insert(completionTypes, CompletionType.HUSH)
      table.insert(completionTypes, CompletionType.DELIRIUM)
      table.insert(completionTypes, CompletionType.MOTHER)
      table.insert(completionTypes, CompletionType.BEAST)
    elseif difficulty == Difficulty.DIFFICULTY_HARD then
      value = 2
      table.insert(completionTypes, CompletionType.MOMS_HEART)
      table.insert(completionTypes, CompletionType.ISAAC)
      table.insert(completionTypes, CompletionType.SATAN)
      table.insert(completionTypes, CompletionType.BOSS_RUSH)
      table.insert(completionTypes, CompletionType.BLUE_BABY)
      table.insert(completionTypes, CompletionType.LAMB)
      table.insert(completionTypes, CompletionType.MEGA_SATAN)
      table.insert(completionTypes, CompletionType.HUSH)
      table.insert(completionTypes, CompletionType.DELIRIUM)
      table.insert(completionTypes, CompletionType.MOTHER)
      table.insert(completionTypes, CompletionType.BEAST)
    elseif difficulty == Difficulty.DIFFICULTY_GREED then
      value = 1
      table.insert(completionTypes, CompletionType.ULTRA_GREED)
    else -- DIFFICULTY_GREEDIER
      value = 2
      table.insert(completionTypes, CompletionType.ULTRA_GREED)
    end
    
    for _, v in ipairs(completionTypes) do
      local completionMark = Isaac.GetCompletionMark(playerType, v)
      if completionMark < value then
        num = num + 1
      end
    end
    
    return num
  end
  
  function mod:getModdedChallenges()
    local challenges = {}
    
    local id = Challenge.NUM_CHALLENGES
    local entry = XMLData.GetEntryById(XMLNode.CHALLENGE, id)
    while entry and type(entry) == 'table' do
      table.insert(challenges, entry)
      
      id = id + 1
      entry = XMLData.GetEntryById(XMLNode.CHALLENGE, id)
    end
    
    return challenges
  end
  
  function mod:xmlAchievementsToTbl(s)
    local achievements = {}
    
    if s then
      for a in string.gmatch(s, '([^,]+)') do
        local achievement = tonumber(a)
        if achievement and math.type(achievement) == 'integer' then
          table.insert(achievements, achievement)
        end
      end
    end
    
    return achievements
  end
  
  function mod:fillPlayerTypes()
    for i = 0, PlayerType.NUM_PLAYER_TYPES - 1 do
      local playerConfig = EntityConfig.GetPlayer(i)
      local enabled = true
      if i == PlayerType.PLAYER_LAZARUS2 or
         i == PlayerType.PLAYER_BLACKJUDAS or
         i == PlayerType.PLAYER_THESOUL or
         i == PlayerType.PLAYER_ESAU or
         i == PlayerType.PLAYER_LAZARUS2_B or
         i == PlayerType.PLAYER_JACOB2_B or
         i == PlayerType.PLAYER_THESOUL_B
      then
        enabled = false
      end
      local name = mod:localize('Players', playerConfig:GetName())
      if i == PlayerType.PLAYER_LAZARUS2 or
         i == PlayerType.PLAYER_LAZARUS2_B or
         i == PlayerType.PLAYER_JACOB2_B
      then
        name = name .. ' (2)'
      elseif i == PlayerType.PLAYER_JACOB then
        name = name .. '+' .. mod:localize('Players', '#ESAU_NAME')
      end
      table.insert(mod.playerTypes, { id = i, name = name, tainted = i >= PlayerType.PLAYER_ISAAC_B, achievement = mod:getPlayerAchievementID(playerConfig), enabled = enabled, defaultEnabled = enabled })
    end
    
    for _, v in ipairs(mod:getModdedCharacters()) do
      local modName = nil
      local sourceid = mod:getXmlPlayerSourceId(v:GetPlayerType())
      if sourceid then
        modName = mod:getXmlModName(sourceid) or sourceid
      end
      table.insert(mod.playerTypes, { id = v:GetPlayerType(), name = v:GetName(), tainted = v:IsTainted(), achievement = mod:getPlayerAchievementID(v), mod = modName, enabled = not v:IsHidden(), defaultEnabled = not v:IsHidden() })
    end
  end
  
  -- community remix mod has a DifficultyManager
  function mod:fillDifficulties()
    table.insert(mod.difficulties, { id = Difficulty.DIFFICULTY_NORMAL  , name = 'Normal'  , enabled = true, defaultEnabled = true })
    table.insert(mod.difficulties, { id = Difficulty.DIFFICULTY_HARD    , name = 'Hard'    , enabled = true, defaultEnabled = true })
    table.insert(mod.difficulties, { id = Difficulty.DIFFICULTY_GREED   , name = 'Greed'   , enabled = true, defaultEnabled = true })
    table.insert(mod.difficulties, { id = Difficulty.DIFFICULTY_GREEDIER, name = 'Greedier', enabled = true, defaultEnabled = true })
  end
  
  function mod:fillChallenges()
    for i = 1, Challenge.NUM_CHALLENGES - 1 do
      local data = mod:getXmlChallengeData(i)
      if i == Challenge.CHALLENGE_DELETE_THIS and (data.name == nil or data.name == '') then
        data.name = 'DELETE THIS'
      end
      local playerType = tonumber(data.playertype)
      if math.type(playerType) ~= 'integer' then
        playerType = PlayerType.PLAYER_ISAAC
      end
      local difficulty = tonumber(data.difficulty)
      if math.type(difficulty) ~= 'integer' then
        difficulty = Difficulty.DIFFICULTY_NORMAL
      end
      local achievement = mod.challengeUnlocks[i]
      local achievements = achievement and { achievement } or {}
      table.insert(mod.challenges, { id = i, name = data.name or '', playerType = playerType, difficulty = difficulty, achievements = achievements, enabled = true, defaultEnabled = true })
    end
    
    for _, v in ipairs(mod:getModdedChallenges()) do
      local playerType = tonumber(v.playertype)
      if math.type(playerType) ~= 'integer' then
        playerType = PlayerType.PLAYER_ISAAC
      end
      local difficulty = tonumber(v.difficulty)
      if math.type(difficulty) ~= 'integer' then
        difficulty = Difficulty.DIFFICULTY_NORMAL
      end
      local modName = mod:getXmlModName(v.sourceid) or v.sourceid
      local enabled = false
      if v.hidden == nil or v.hidden == 'false' then
        enabled = true
      end
      table.insert(mod.challenges, { id = v.id, name = v.name or '', playerType = playerType, difficulty = difficulty, achievements = mod:xmlAchievementsToTbl(v.achievements), mod = modName, enabled = enabled, defaultEnabled = enabled })
    end
  end
  
  function mod:fillControllers()
    mod.controllers = { 'Default' }
    mod.controllersMap = { -1 }
    
    for i = 0, 10000 do
      local name = Input.GetDeviceNameByIdx(i)
      if name == nil and i == 0 then
        name = 'Keyboard'
      end
      if name then
        table.insert(mod.controllers, i .. ' - ' .. name)
        table.insert(mod.controllersMap, i)
      end
    end
  end
  
  function mod:isPlayerTypeUnlocked(achievement)
    if achievement > 0 then
      local gameData = Isaac.GetPersistentGameData()
      if not gameData:Unlocked(achievement) then
        return false
      end
    end
    
    return true
  end
  
  function mod:isChallengeUnlocked(achievements)
    local gameData = Isaac.GetPersistentGameData()
    
    if #achievements > 0 then
      for _, achievement in ipairs(achievements) do
        if not gameData:Unlocked(achievement) then
          return false
        end
      end
    end
    
    return true
  end
  
  function mod:setupImGui()
    if not ImGui.ElementExists('shenanigansMenu') then
      ImGui.CreateMenu('shenanigansMenu', '\u{f6d1} Shenanigans')
    end
    ImGui.AddElement('shenanigansMenu', 'shenanigansMenuItemNewRun', ImGuiElement.MenuItem, '\u{f70c} New Run Shenanigans')
    ImGui.CreateWindow('shenanigansWindowNewRun', 'New Run Shenanigans')
    ImGui.LinkWindowToElement('shenanigansWindowNewRun', 'shenanigansMenuItemNewRun')
    
    ImGui.AddTabBar('shenanigansWindowNewRun', 'shenanigansTabBarNewRun')
    ImGui.AddTab('shenanigansTabBarNewRun', 'shenanigansTabNewRun', 'New Run')
    ImGui.AddTab('shenanigansTabBarNewRun', 'shenanigansTabNewRunPlayerTypes', 'Player Types')
    ImGui.AddTab('shenanigansTabBarNewRun', 'shenanigansTabNewRunDifficulties', 'Difficulties')
    ImGui.AddTab('shenanigansTabBarNewRun', 'shenanigansTabNewRunChallenges', 'Challenges')
    
    local difficulty = Difficulty.DIFFICULTY_NORMAL
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Difficulty')
    ImGui.AddRadioButtons('shenanigansTabNewRun', 'shenanigansRadNewRunDifficulty', function(i)
      difficulty = i
    end, { 'Normal', 'Hard', 'Greed', 'Greedier', 'Random', 'Challenge' }, difficulty, true)
    
    local playerTypes = {
      regular = true,
      tainted = true,
    }
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Player Type')
    for i, v in ipairs({
                        { text = 'Regular', field = 'regular' },
                        { text = 'Tainted', field = 'tainted' },
                      })
    do
      ImGui.AddCheckbox('shenanigansTabNewRun', 'shenanigansChkNewRunPlayerType' .. i, v.text, function(b)
        playerTypes[v.field] = b
      end, playerTypes[v.field])
      if i < 2 then
        ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SameLine, '')
      end
    end
    
    local incomplete = false
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Optional')
    ImGui.AddCheckbox('shenanigansTabNewRun', 'shenanigansChkNewRunIncomplete', 'Limit to completion marks or challenges that are incomplete?', function(b)
      incomplete = b
    end, incomplete)
    
    local seed = ''
    local txtSeedId = 'shenanigansTxtNewRunSeed'
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Seed')
    ImGui.AddInputText('shenanigansTabNewRun', txtSeedId, '', nil, '', 'Random...')
    ImGui.AddCallback(txtSeedId, ImGuiCallback.DeactivatedAfterEdit, function(s)
      s = string.gsub(s, '%W', '') -- remove any non-alphanumeric characters
      s = string.upper(s)          -- upper case
      
      if string.len(s) > 8 then
        s = string.sub(s, 1, 8)
      end
      
      local map = { ['I'] = '1', ['O'] = '0', ['U'] = 'V' }
      local temp = ''
      for i = 1, string.len(s) do
        local c = string.sub(s, i, i)
        local c2 = map[c]
        if c2 then
          c = c2
        end
        temp = temp .. c
      end
      s = temp
      
      if string.len(s) > 4 then
        s = string.sub(s, 1, 4) .. ' ' .. string.sub(s, 5, string.len(s)) -- insert space
      end
      
      if s == '' then
        ImGui.UpdateData(txtSeedId, ImGuiData.Label, '')
      elseif Seeds.IsStringValidSeed(s) then
        ImGui.UpdateData(txtSeedId, ImGuiData.Label, 'Valid')
      else
        ImGui.UpdateData(txtSeedId, ImGuiData.Label, 'Not valid')
      end
      
      seed = s
      ImGui.UpdateData(txtSeedId, ImGuiData.Value, s)
    end)
    
    mod:fillControllers()
    local controller = 0
    local cmbControllerId = 'shenanigansCmbNewRunController'
    local btnControllerId = 'shenanigansBtnNewRunController'
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Controller')
    ImGui.AddCombobox('shenanigansTabNewRun', cmbControllerId, '', function(i)
      controller = i
    end, mod.controllers, controller, false)
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SameLine, '')
    ImGui.AddButton('shenanigansTabNewRun', btnControllerId, '\u{f021}', function()
      mod:fillControllers()
      controller = 0
      ImGui.UpdateData(cmbControllerId, ImGuiData.ListValues, mod.controllers)
      ImGui.UpdateData(cmbControllerId, ImGuiData.Value, controller)
    end, false)
    ImGui.SetTooltip(btnControllerId, 'Refresh (if you swap controllers)')
    
    ImGui.AddElement('shenanigansTabNewRun', '', ImGuiElement.SeparatorText, 'Go')
    ImGui.AddButton('shenanigansTabNewRun', 'shenanigansBtnNewRun', 'Start New Run', function()
      local gotActiveMenu, activeMenu = pcall(MenuManager.GetActiveMenu)
      if not gotActiveMenu then
        ImGui.PushNotification('Starting a new run is disabled while in a run.', ImGuiNotificationType.ERROR, 5000)
        return
      end
      if activeMenu <= MainMenuType.SAVES then -- 2
        ImGui.PushNotification('Select a save slot before starting a new run.', ImGuiNotificationType.ERROR, 5000)
        return
      end
      
      local gameData = Isaac.GetPersistentGameData()
      local rng = RNG(os.time(), mod.rngShiftIdx)
      
      local p = {}
      local c = { id = Challenge.CHALLENGE_NULL }
      local d = difficulty
      local notification = ''
      
      if d == 5 then -- challenge
        local tempChallenges = {}
        for _, v in ipairs(mod.challenges) do
          if v.enabled and mod:isChallengeUnlocked(v.achievements) then
            if not incomplete or (incomplete and not Isaac.IsChallengeDone(v.id)) then
              table.insert(tempChallenges, v)
            end
          end
        end
        
        c = tempChallenges[rng:RandomInt(#tempChallenges) + 1]
        if not c then
          ImGui.PushNotification('No unlocked challenges matched the criteria.', ImGuiNotificationType.ERROR, 5000)
          return
        end
        
        p.id = c.playerType
        d = c.difficulty
        
        notification = 'Challenge: ' .. c.name
      else
        local greedierModeUnlocked = gameData:Unlocked(Achievement.GREEDIER)
        local edenTokens = gameData:GetEventCounter(EventCounter.EDEN_TOKENS)
        
        if d == Difficulty.DIFFICULTY_GREEDIER and not greedierModeUnlocked then
          ImGui.PushNotification('Greedier mode has not been unlocked.', ImGuiNotificationType.ERROR, 5000)
          return
        end
        
        if d == 4 then -- random
          local tempDifficulties = {}
          for _, v in ipairs(mod.difficulties) do
            if v.enabled and (v.id ~= Difficulty.DIFFICULTY_GREEDIER or (v.id == Difficulty.DIFFICULTY_GREEDIER and greedierModeUnlocked)) then
              if not incomplete then
                table.insert(tempDifficulties, v)
              else
                for _, w in ipairs(mod.playerTypes) do
                  if w.enabled and ((playerTypes.regular and not w.tainted) or (playerTypes.tainted and w.tainted)) and mod:isPlayerTypeUnlocked(w.achievement) then
                    local isEden = w.id == PlayerType.PLAYER_EDEN or w.id == PlayerType.PLAYER_EDEN_B
                    if not isEden or (isEden and edenTokens > 0) then
                      if mod:getNumCompletionMarksToGo(w.id, v.id) > 0 then
                        table.insert(tempDifficulties, v)
                        break
                      end
                    end
                  end
                end
              end
            end
          end
          
          local tempD = tempDifficulties[rng:RandomInt(#tempDifficulties) + 1]
          if not tempD then
            ImGui.PushNotification('No unlocked difficulties matched the criteria.', ImGuiNotificationType.ERROR, 5000)
            return
          end
          
          d = tempD.id
          notification = 'Difficulty: ' .. tempD.name .. '\n'
        end
        
        local tempPlayerTypes = {}
        for _, v in ipairs(mod.playerTypes) do
          if v.enabled and ((playerTypes.regular and not v.tainted) or (playerTypes.tainted and v.tainted)) and mod:isPlayerTypeUnlocked(v.achievement) then
            local isEden = v.id == PlayerType.PLAYER_EDEN or v.id == PlayerType.PLAYER_EDEN_B
            if not isEden or (isEden and edenTokens > 0) then
              if not incomplete then
                table.insert(tempPlayerTypes, v)
              else
                for i = 1, mod:getNumCompletionMarksToGo(v.id, d) do
                  table.insert(tempPlayerTypes, v) -- weighted
                end
              end
            end
          end
        end
        
        p = tempPlayerTypes[rng:RandomInt(#tempPlayerTypes) + 1]
        if not p then
          ImGui.PushNotification(notification .. 'No unlocked player types matched the criteria.', ImGuiNotificationType.ERROR, 5000)
          return
        end
        
        notification = notification .. 'Player Type: ' .. p.name
        if p.tainted then
          notification = notification .. ' (Tainted)'
        end
      end
      
      local s = nil
      if seed ~= '' and c.id == Challenge.CHALLENGE_NULL then
        if Seeds.IsStringValidSeed(seed) then
          s = Seeds.String2Seed(seed)
        else
          ImGui.PushNotification('The seed is not valid.', ImGuiNotificationType.ERROR, 5000)
          return
        end
      end
      
      if (p.id == PlayerType.PLAYER_EDEN or p.id == PlayerType.PLAYER_EDEN_B) and c.id == Challenge.CHALLENGE_NULL then
        gameData:IncreaseEventCounter(EventCounter.EDEN_TOKENS, -1)
      end
      
      Isaac.StartNewGame(p.id, c.id, d, s)
      mod.controllerOverride = mod.controllersMap[controller + 1] or -1
      mod.notification = notification
      mod.seed = s
      ImGui.Hide()
    end, false)
    
    for i, v in ipairs({
                        { tab = 'shenanigansTabNewRunPlayerTypes' , tbl = mod.playerTypes , enabledPrefix = 'shenanigansChkNewRunPlayerTypeEnabled' },
                        { tab = 'shenanigansTabNewRunDifficulties', tbl = mod.difficulties, enabledPrefix = 'shenanigansChkNewRunDifficultyEnabled' },
                        { tab = 'shenanigansTabNewRunChallenges'  , tbl = mod.challenges  , enabledPrefix = 'shenanigansChkNewRunChallengeEnabled' },
                      })
    do
      ImGui.AddButton(v.tab, 'shenanigansBtnNewRunSelectAll' .. i, 'Select all', function()
        for _, w in ipairs(v.tbl) do
          w.enabled = true
          ImGui.UpdateData(v.enabledPrefix .. w.id, ImGuiData.Value, true)
        end
      end, false)
      ImGui.AddElement(v.tab, '', ImGuiElement.SameLine, '')
      ImGui.AddButton(v.tab, 'shenanigansBtnNewRunDeselectAll' .. i, 'Deselect all', function()
        for _, w in ipairs(v.tbl) do
          w.enabled = false
          ImGui.UpdateData(v.enabledPrefix .. w.id, ImGuiData.Value, false)
        end
      end, false)
      ImGui.AddElement(v.tab, '', ImGuiElement.SameLine, '')
      ImGui.AddButton(v.tab, 'shenanigansBtnNewRunReset' .. i, 'Reset', function()
        for _, w in ipairs(v.tbl) do
          w.enabled = w.defaultEnabled
          ImGui.UpdateData(v.enabledPrefix .. w.id, ImGuiData.Value, w.defaultEnabled)
        end
      end, false)
    end
    
    ImGui.AddElement('shenanigansTabNewRunPlayerTypes', '', ImGuiElement.SeparatorText, 'Regular')
    for _, v in ipairs(mod.playerTypes) do
      if not v.tainted then
        local chkPlayerTypeId = 'shenanigansChkNewRunPlayerTypeEnabled' .. v.id
        ImGui.AddCheckbox('shenanigansTabNewRunPlayerTypes', chkPlayerTypeId, v.id .. '.' .. v.name, function(b)
          v.enabled = b
        end, v.enabled)
        if v.mod then
          ImGui.SetHelpmarker(chkPlayerTypeId, v.mod)
        end
      end
    end
    
    ImGui.AddElement('shenanigansTabNewRunPlayerTypes', '', ImGuiElement.SeparatorText, 'Tainted')
    for _, v in ipairs(mod.playerTypes) do
      if v.tainted then
        local chkPlayerTypeId = 'shenanigansChkNewRunPlayerTypeEnabled' .. v.id
        ImGui.AddCheckbox('shenanigansTabNewRunPlayerTypes', chkPlayerTypeId, v.id .. '.' .. v.name, function(b)
          v.enabled = b
        end, v.enabled)
        if v.mod then
          ImGui.SetHelpmarker(chkPlayerTypeId, v.mod)
        end
      end
    end
    
    ImGui.AddElement('shenanigansTabNewRunDifficulties', '', ImGuiElement.SeparatorText, 'Random')
    for _, v in ipairs(mod.difficulties) do
      ImGui.AddCheckbox('shenanigansTabNewRunDifficulties', 'shenanigansChkNewRunDifficultyEnabled' .. v.id, v.name, function(b)
        v.enabled = b
      end, v.enabled)
    end
    
    ImGui.AddElement('shenanigansTabNewRunChallenges', '', ImGuiElement.SeparatorText, 'Challenge')
    for _, v in ipairs(mod.challenges) do
      local chkChallengeId = 'shenanigansChkNewRunChallengeEnabled' .. v.id
      ImGui.AddCheckbox('shenanigansTabNewRunChallenges', chkChallengeId, v.id .. '.' .. v.name, function(b)
        v.enabled = b
      end, v.enabled)
      if v.mod then
        ImGui.SetHelpmarker(chkChallengeId, v.mod)
      end
    end
  end
  
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)
  mod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, mod.onMainMenuRender)
  mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, mod.onPlayerInit, PlayerVariant.PLAYER)
end