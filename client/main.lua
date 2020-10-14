ESX 						= nil
local PlayerData            = {}

local sellDrugVar = false
local Do3DTextToSell = true
local canSellVar = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()
	while canSellVar do
		TriggerServerEvent("vin_drugsystem:canSellDrugsv2")
		Citizen.Wait(5500)
	end
end)

function SellToPed(ped)
	if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped,false) and not IsEntityDead(ped) and IsPedHuman(ped) and GetEntityModel(ped) ~= GetHashKey("s_m_y_cop_01") and GetEntityModel(ped) ~= GetHashKey("s_m_y_dealer_01") and GetEntityModel(ped) ~= GetHashKey("mp_m_shopkeep_01") and ped ~= oldped and sellDrugVar then 
		return true
	end
	return false
end

RegisterNetEvent("vin_drugsystem:Effects") -- thanks 3DSMarx for sending the template, just cleaned it up and such, no need for config usage now..
AddEventHandler("vin_drugsystem:Effects", function(k,v)
    local playerPed = PlayerId()
	local ped = GetPlayerPed(-1)
	local BodyArmor = true
	local HealthAdder = true
	local FasterSprint = true
	local TimeCycleModifier = true
	local MotionBlur = true
	local UnlimitedStamina = true
	if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
		TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SMOKING_POT", 0, true)
		exports['progressBars']:startUI(3500, "Using drug")
		Citizen.Wait(3500)
		ClearPedTasks(PlayerPedId())
	else
		exports['progressBars']:startUI(3500, "Using drug")
		Citizen.Wait(3500)
	end
	if BodyArmor then
		if GetPedArmour(ped) <= (100-15) then
			AddArmourToPed(ped, 25)
		elseif GetPedArmour(ped) <= 99 then
			SetPedArmour(ped,100)
		end
	end
	if HealthAdder then
		if GetEntityHealth(ped) <= (200-100) then
			SetEntityHealth(ped,GetEntityHealth(ped)+10)
		elseif GetEntityHealth(ped) <= 199 then
			SetEntityHealth(ped,200)
		end
	end
	local timer = 0
	while timer < 30 do
		if FasterSprint then
			SetRunSprintMultiplierForPlayer(playerPed,1.2)
		end
		if TimeCycleModifier then
			SetTimecycleModifier('spectator5')
		end
		if MotionBlur then
			SetPedMotionBlur(playerPed, true)
		end
		if UnlimitedStamina then
			ResetPlayerStamina(playerPed)
		end
		Citizen.Wait(1000)
		timer = timer + 1
	end
    SetTimecycleModifier("default")
	SetPedMotionBlur(playerPed, false)
    SetRunSprintMultiplierForPlayer(playerPed,1.0)
end)

RequestAnimDict("mp_common")
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        local player = PlayerPedId()
        local playerPos = GetEntityCoords(player, 0)
		local handle, ped = FindFirstPed()
		local goodtogo
		repeat -- this will repeat the statement until its body condition is true. 
			goodtogo, ped = FindNextPed(handle)
			local pos = GetEntityCoords(ped)
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playerPos.x, playerPos.y, playerPos.z, true)
			
			if distance < 2 and SellToPed(ped) and sellDrugVar and not IsPedInAnyVehicle(player, true) then
				if Do3DTextToSell then
					DrawText3Ds(pos.x, pos.y, pos.z, "Press ~g~[H]~s~ to offer ~y~drugs~s~")
				else
					exports['mythic_notify']:SendAlert('success', 'Press H to offer Drugs')
				end
				if IsControlJustPressed(1,74) then
					oldped = ped
					TaskStandStill(ped,5000.0)
					SetEntityAsMissionEntity(ped)
					FreezeEntityPosition(ped,true)
					FreezeEntityPosition(player,true)
					SetEntityHeading(ped,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y)+180)
					SetEntityHeading(player,GetHeadingFromVector_2d(pos.x-playerPos.x,pos.y-playerPos.y))
					local randomAmount = math.random(2,9)
					exports['progressBars']:startUI((5000), "Drugs being sold")
					Citizen.Wait(5500)
					if randomAmount == 1 or randomAmount == 2 then
						TaskPlayAnim(player, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
						TaskPlayAnim(ped, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
						TriggerServerEvent("vin_drugsystem:") -- to be done
					end
					SetPedAsNoLongerNeeded(oldped)
					FreezeEntityPosition(ped,false)
					FreezeEntityPosition(player,false)
					Citizen.Wait(5500)
					break
				end
			end
			
		until not goodtogo -- until it isn't true, then it executes the native function below.
		EndFindPed(handle)
	end
end)

-- Function for 3D text: very common anyways lol.
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end
