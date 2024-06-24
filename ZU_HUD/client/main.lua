local hunger, thirst = 100, 100
local hudVisible = true
local wasMenuOpen = false
local isTalking = false
local microphoneRange = 2 -- 1: Chuchoter, 2: Normal, 3: Crier
local isMicrophoneOn = true

-- Fonction pour afficher une notification à l'écran
function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isMenuOpen = IsPauseMenuActive()

        local playerTalking = NetworkIsPlayerTalking(PlayerId())
        
        SendNUIMessage({
            type = 'microphone',
            isTalking = playerTalking,
            isMicrophoneOn = isMicrophoneOn,
            microphoneRange = microphoneRange
        })
 
 

               -- Vérifier si l'état du menu a changé
               if isMenuOpen ~= wasMenuOpen then
                wasMenuOpen = isMenuOpen
                if isMenuOpen then
                    local playerTalking = NetworkIsPlayerTalking(PlayerId())
                
                    SendNUIMessage({
                        type = 'microphone',
                        isTalking = playerTalking,
                        isMicrophoneOn = isMicrophoneOn,
                        microphoneRange = microphoneRange
                    })
    
                    SendNUIMessage({type = 'toggle', show = false})
                    isMicrophoneOn = false
                    isTalking = false
                    hudVisible = false
                    microphone = false
                else
                    SendNUIMessage({type = 'toggle', show = true})
       
                    isMicrophoneOn = true
                    isTalking = true
                    hudVisible = true
                    microphone = true
    
                    Citizen.Wait(0)
                end
            end
   
            
       -- Mettre à jour le HUD seulement s'il est visible
       if hudVisible then
        local health = GetEntityHealth(player) - 100
        local armor = GetPedArmour(player)
        local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
        local isDead = IsPlayerDead(PlayerId())

        SendNUIMessage({
            type = 'update',
            health = health,
            hunger = isDead and 0 or hunger,
            thirst = isDead and 0 or thirst,
            armor = armor,
            oxygen = oxygen,
            isDead = isDead
        })
    end

        Citizen.Wait(1000)
    end
end)

-- Gestion de la touche ² pour activer/désactiver le micro
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 243) then -- 243 est le code pour la touche ²
            isMicrophoneOn = not isMicrophoneOn
           ShowNotification(isMicrophoneOn and "Microphone activé" or "Microphone désactivé")
            SendNUIMessage({
                type = 'microphone',
                isTalking = false,
                isMicrophoneOn = isMicrophoneOn,
                microphoneRange = microphoneRange
            })
        end

        -- Gestion de la touche F11 pour changer la portée du micro
        if IsControlJustPressed(0, 344) then -- 57 est le code pour F11 / 344 pour la touche F11
            microphoneRange = (microphoneRange % 3) + 1
          local rangeText = {"Chuchoter", "Normal", "Crier"}
           ShowNotification("Portée du micro changée à : " .. rangeText[microphoneRange])
            SendNUIMessage({
                type = 'microphone',
                isTalking = false,
                isMicrophoneOn = isMicrophoneOn,
                microphoneRange = microphoneRange
            })
        end     

    end
end)





--- CORRECTION BUG FEMME PED ---
Citizen.CreateThread(function()
    Citizen.Wait(0)
    SendNUIMessage({
        action = 'showui'
    })

    while true do
        if GetEntityMaxHealth(GetPlayerPed(-1)) ~= 200 then
            SetEntityMaxHealth(GetPlayerPed(-1), 200)
            SetEntityHealth(GetPlayerPed(-1), 200)
        end
        local player = PlayerPedId()

        SendNUIMessage({
            action = 'tick',
            show = IsPauseMenuActive(),
            health = (GetEntityHealth(player) - 100),
            armor = GetPedArmour(player),
            stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
        })
        Citizen.Wait(1000)
    end
end)

---- PERTE FAIM/SOIF SI SPRINT ---
Citizen.CreateThread(function()
    while(true) do
        local ped = PlayerPedId()
        
        if IsPedRunning(ped) and not IsPedSprinting(ped) then 
            TriggerEvent('esx_status:remove', 'hunger', 200)
            TriggerEvent('esx_status:remove', 'thirst', 200)
        end    
        
        if not IsPedRunning(ped) and IsPedSprinting(ped) then 
            TriggerEvent('esx_status:remove', 'hunger', 200)
            TriggerEvent('esx_status:remove', 'thirst', 200)
        end

        Citizen.Wait(700)
    end
end)

---- NO HELMET ---
Citizen.CreateThread(function()
    while true do 
        local delay = 1000
        if IsPedInAnyVehicle(PlayerPedId(), false) then 
            delay = 1
            SetPedConfigFlag(PlayerPedId(), 35, false)
        end
        Citizen.Wait(delay)
    end
end)

---- DOMMAGE WALK ----
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if GetEntityHealth(GetPlayerPed(-1)) <= 159 then
            setHurt()
        elseif hurt and GetEntityHealth(GetPlayerPed(-1)) > 160 then
            setNotHurt()
        end
    end
end)

function setHurt()
    hurt = true
    RequestAnimSet("move_m@injured")
    SetPedMovementClipset(GetPlayerPed(-1), "move_m@injured", true)
end

function setNotHurt()
    hurt = false
    ResetPedMovementClipset(GetPlayerPed(-1))
    ResetPedWeaponMovementClipset(GetPlayerPed(-1))
    ResetPedStrafeClipset(GetPlayerPed(-1))
end
 

-- Événement pour mettre à jour la faim et la soif
RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(status)
    for _, v in ipairs(status) do
        if v.name == 'hunger' then
            hunger = v.percent
        elseif v.name == 'thirst' then
            thirst = v.percent
        end
    end
end)
 