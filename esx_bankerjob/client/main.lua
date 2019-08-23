local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData              = {}
local GUI                     = {}
local hasAlreadyEnteredMarker = false
local lastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local OnJob                     = false
local OnJob1                     = false
local CurrentCustomer           = nil
local CurrentCustomerBlip       = nil
local DestinationBlip           = nil
local IsNearCustomer            = false
local CustomerIsEnteringVehicle = false
local CustomerEnteredVehicle    = false
local TargetCoords              = nil
local CurrentCustomer1           = nil
local CurrentCustomerBlip1       = nil
local DestinationBlip1           = nil
local IsNearCustomer1            = false
local CustomerIsEnteringVehicle1 = false
local CustomerEnteredVehicle1    = false
local TargetCoords1              = nil
local delcar              = nil


ESX                           = nil
GUI.Time                      = 0

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function (job)
  PlayerData.job = job
end)

function OpenVehicleSpawnerMenu()

  local vehicles = Config.Zones.Vehicles

  ESX.UI.Menu.CloseAll()

    local elements = {}

    for i=1, #Config.AuthorizedVehicles, 1 do
      local vehicle = Config.AuthorizedVehicles[i]
      table.insert(elements, {label = vehicle.label, value = vehicle.name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_spawner',
      {
	    css =  'banker',
        title    = _U('vehicle_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        local model = data.current.value

        local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x,  vehicles.SpawnPoint.y,  vehicles.SpawnPoint.z,  3.0,  0,  71)

        if not DoesEntityExist(vehicle) then

          local playerPed = GetPlayerPed(-1)

          if Config.MaxInService == -1 then

            ESX.Game.SpawnVehicle(model, {
              x = vehicles.SpawnPoint.x,
              y = vehicles.SpawnPoint.y,
              z = vehicles.SpawnPoint.z
            }, vehicles.Heading, function(vehicle)
              TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1) -- teleport into vehicle
              SetVehicleMaxMods(vehicle)
              SetVehicleDirtLevel(vehicle, 0)
            end)
			
			if model == 'Stockade' then
				local prix20 = 8000
				location1(prix20)
				ESX.ShowNotification('~b~Attention à son état, cela sera vérifié au retour.')
			end	

          else

            ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

              if canTakeService then

                ESX.Game.SpawnVehicle(model, {
                  x = vehicles[partNum].SpawnPoint.x,
                  y = vehicles[partNum].SpawnPoint.y,
                  z = vehicles[partNum].SpawnPoint.z
                }, vehicles[partNum].Heading, function(vehicle)
                  TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)  -- teleport into vehicle
                  SetVehicleMaxMods(vehicle)
                  SetVehicleDirtLevel(vehicle, 0)
                end)

              else
                ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
              end

            end, 'etat')

          end

        else
          ESX.ShowNotification(_U('vehicle_out'))
        end

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {}

      end
    )

end

function location1(prix20)

	TriggerServerEvent('esx_bankerjob:paycar', prix20)
	
end

function OpenBankActionsMenu ()
  local elements = {
    { label = _U('customers'), value = 'customers' },
	{ label = _U('customerspret'), value = 'customerspret' },
	{ label = _U('customersbank'), value = 'customersbank' },
    { label = _U('billing'),   value = 'billing' },
	{label = _U('deposit_stock'),   value = 'put_stock'},
	{label = _U('take_stock'),   value = 'get_stock'}
  }

  if PlayerData.job.grade_name == 'boss' then
    table.insert(elements, { label = _U('boss_actions'), value = 'boss_actions' })
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'bank_actions',
    {
	  css =  'banker',
      title    = _U('bank'),
      elements = elements,
    },
    function (data, menu)
      if data.current.value == 'customers' then
        OpenCustomersMenu()
      end

      if data.current.value == 'put_stock' then
      	OpenPutStocksMenu()
      end

      if data.current.value == 'get_stock' then
      	OpenGetStocksMenu()
      end

	  if data.current.value == 'customerspret' then
        OpenCustomersPretMenu()
      end
	  
	  if data.current.value == 'customersbank' then
        OpenCustomersCompteBankMenu()
      end
	  
      if data.current.value == 'billing' then
        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'billing',
          {
            title = _U('bill_amount'),
          },
          function (data, menu)
            local amount = tonumber(data.value)

            if amount == nil then
              ESX.ShowNotification(_U('invalid_amount'))
            else
              menu.close()

              local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

              if closestPlayer == -1 or closestDistance > 5.0 then
                ESX.ShowNotification(_U('no_player_nearby'))
              else
                TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_banker', 'Banque', amount)
              end
            end
          end,
          function (data, menu)
            menu.close()
          end
        )

      end

      if data.current.value == 'boss_actions' then
        TriggerEvent('esx_society:openBossMenu', 'banker', function (data, menu)
          menu.close()
        end, {wash = false})
      end

    end,
    function (data, menu)
      menu.close()

      CurrentAction     = 'bank_actions_menu'
      CurrentActionMsg  = _U('press_input_context_to_open_menu')
      CurrentActionData = {}
    end
  )

end


function OpenCustomersMenu ()
  ESX.TriggerServerCallback('esx_bankerjob:getCustomers', function (customers)
    local elements = {
      head = { _U('deposit_stock') },
      rows = {}
    }

    for i=1, #customers, 1 do
      table.insert(elements.rows, {
        data = customers[i],
        cols = {
		  --customers[i].name,
		  customers[i].ident1,
          customers[i].ident,
          customers[i].bankSavings,
          '{{' .. _U('deposit') .. '|deposit}} {{' .. _U('withdraw') .. '|withdraw}}',
        }
      })
    end

    ESX.UI.Menu.Open(
      'list', GetCurrentResourceName(), 'customers',
      elements,
      function (data, menu)
        local customer = data.data

        if data.value == 'deposit' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_deposit_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerDeposit', customer.name, amount)

                OpenCustomersMenu()
              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersMenu()
            end
          )
        end

        if data.value == 'withdraw' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_withdraw_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerWithdraw', customer.name, amount)

                OpenCustomersMenu()

              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersMenu()
            end
          )

        end

      end,
      function (data, menu)
        menu.close()
      end
    )

  end)

end

function OpenCustomersPretMenu ()
  ESX.TriggerServerCallback('esx_bankerjob:getCustomersPret', function (customers)
    local elements = {
      head = { _U('customer1'), _U('customer'), _U('balancepret'), _U('actionspret') },
      rows = {}
    }

    for i=1, #customers, 1 do
      table.insert(elements.rows, {
        data = customers[i],
        cols = {
		  --customers[i].name,
		  customers[i].ident1,
          customers[i].ident,
          customers[i].bankSavings,
          '{{' .. _U('depositpret') .. '|deposit}} {{' .. _U('withdrawpret') .. '|withdraw}}',
        }
      })
    end

    ESX.UI.Menu.Open(
      'list', GetCurrentResourceName(), 'customers',
      elements,
      function (data, menu)
        local customer = data.data

        if data.value == 'deposit' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_deposit_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerDepositPret', customer.name, amount)

                OpenCustomersPretMenu()
              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersPretMenu()
            end
          )
        end

        if data.value == 'withdraw' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_withdraw_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerWithdrawPret', customer.name, amount)

                OpenCustomersPretMenu()

              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersPretMenu()
            end
          )

        end

      end,
      function (data, menu)
        menu.close()
      end
    )

  end)

end

function OpenCustomersCompteBankMenu ()
  ESX.TriggerServerCallback('esx_bankerjob:getCustomersCompteBank', function (customers)
    local elements = {
      head = { _U('customer1'), _U('customer'), _U('balancebank'), _U('actions') },
      rows = {}
    }

    for i=1, #customers, 1 do
      table.insert(elements.rows, {
        data = customers[i],
        cols = {
		  --customers[i].name,
		  customers[i].ident1,
          customers[i].ident,
          customers[i].bankSavings,
          '{{' .. _U('depositbank') .. '|deposit}} {{' .. _U('withdrawbank') .. '|withdraw}}',
        }
      })
    end

    ESX.UI.Menu.Open(
      'list', GetCurrentResourceName(), 'customers',
      elements,
      function (data, menu)
        local customer = data.data

        if data.value == 'deposit' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_deposit_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerDepositCompteBank', customer.name, amount)

                OpenCustomersCompteBankMenu()
              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersCompteBankMenu()
            end
          )
        end

        if data.value == 'withdraw' then
          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'customer_withdraw_amount',
            {
              title = _U('amount'),
            },
            function (data2, menu)
              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else
                menu.close()

                TriggerServerEvent('esx_bankerjob:customerWithdrawCompteBank', customer.name, amount)

                OpenCustomersCompteBankMenu()

              end
            end,
            function (data2, menu)
              menu.close()
              OpenCustomersCompteBankMenu()
            end
          )

        end

      end,
      function (data, menu)
        menu.close()
      end
    )

  end)

end

function OpenGetStocksMenu()
  ESX.TriggerServerCallback('esx_bankerjob:getStockItems', function (items)
    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {
        label = 'x' .. items[i].count .. ' ' .. items[i].label,
        value = items[i].name
      })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
      title    = _U('banker_stock'),
      align    = 'top-left',
      elements = elements
    }, function (data, menu)
      local itemName = data.current.value

      ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
        title = _U('amount')
      }, function (data2, menu2)
        local count = tonumber(data2.value)

        if count == nil then
          ESX.ShowNotification(_U('quantity_invalid'))
        else
          TriggerServerEvent('esx_bankerjob:getStockItem', itemName, count)
          menu2.close()
          menu.close()
          OpenGetStocksMenu()
        end
      end, function (data2, menu2)
        menu2.close()
      end)

    end, function (data, menu)
      menu.close()
    end)
  end)
end

function OpenPutStocksMenu()
  ESX.TriggerServerCallback('esx_bankerjob:getPlayerInventory', function (inventory)
    local elements = {}

    for i=1, #inventory.items, 1 do
      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {
          label = item.label .. ' x' .. item.count,
          type = 'item_standard',
          value = item.name
        })
      end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
      title    = _U('inventory'),
      align    = 'top-left',
      elements = elements
    }, function (data, menu)
      local itemName = data.current.value

      ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
        title = _U('amount')
      }, function (data2, menu2)
        local count = tonumber(data2.value)

        if count == nil then
          ESX.ShowNotification(_U('quantity_invalid'))
        else
          TriggerServerEvent('esx_bankerjob:putStockItems', itemName, count)
          menu2.close()
          menu.close()
          OpenPutStocksMenu()
        end
      end, function (data2, menu2)
        menu2.close()
      end)
    end, function (data, menu)
      menu.close()
    end)
  end)
end

function reparation1(prix,vehicle,vehicleProps)
	
	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = "Besoin Repa. : l\'entreprise récupère ("..prix.." $)", value = 'yes'},
		{label = "Besoin Repa. : Passer voir le mécano", value = 'no'},
	}
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'delete_menu1',
		{
		    css =  'banker',
			title    = 'Etat de la voiture',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'yes') then
				TriggerServerEvent('esx_bankerjob:payhealth', prix)
				ranger1(vehicle,vehicleProps)
				delcar = true
			end
			if(data.current.value == 'no') then
				ESX.ShowNotification('~b~Appeler un mécano, ça sera peut-être moins cher')
			end

		end,
		function(data, menu)
			menu.close()
			
		end
	)	
end

function reparation2(prix,vehicle,vehicleProps)
	
	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = "Voiture Etat Ok : Rentrer le vehicule, l\'entreprise récupère ("..prix.." $)", value = 'yes'},
	}
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'delete_menu2',
		{
		    css =  'banker',
			title    = 'Etat de la voiture',
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'yes') then
				TriggerServerEvent('esx_bankerjob:payhealth1', prix)
				ranger1(vehicle,vehicleProps)
				delcar = true
			end
	

		end,
		function(data, menu)
			menu.close()
			
		end
	)	
end

function ranger1(vehicle,vehicleProps)
	ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
	TriggerEvent('esx:showNotification', '~g~L\'entreprise confirme le retour du véhicule de service.')
end

function StockVehicleMenu1()
	
	local ped = GetPlayerPed( -1 )
	
if IsPedInAnyVehicle(ped,  false) then
    if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
        if ( IsPedSittingInAnyVehicle( ped ) ) then 
            local vehicle = GetVehiclePedIsIn( ped, false )

            if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
                local damage = GetVehicleEngineHealth( vehicle )
				local vehicle = GetVehiclePedIsIn(ped,false)     
				local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
				
				if (IsPedInModel(GetPlayerPed(-1), GetHashKey("Stockade"))) then
					if damage < 1000 then
						local fraisRep= math.floor(8000-((1000 - damage)*150))			      
						reparation1(fraisRep,vehicle,vehicleProps)
					else
						local fraisRep= math.floor(8000-((1000 - damage)*150))			      
						reparation2(fraisRep,vehicle,vehicleProps)
					end
				end	
            end  
        end 
    end
else
		TriggerEvent('esx:showNotification', '~r~Il n\'y a pas de vehicule à mettre au garage.')
end

end

function OpenMissionBanker()
	  if OnJob then
        StopBankerJob()
      elseif OnJob1 then
		StopBankerJob()
	  else

        if PlayerData.job ~= nil and PlayerData.job.name == 'banker' then

          local playerPed = GetPlayerPed(-1)

          if IsPedInAnyVehicle(playerPed,  false) then

            local vehicle = GetVehiclePedIsIn(playerPed,  false)

            --if PlayerData.job.grade >= 3 then
              --StartTaxiJob()
            --else
              if GetEntityModel(vehicle) == GetHashKey('Stockade') then
                StartBankerJob()				
              else
                ESX.ShowNotification(_U('must_in_taxi'))
              end
            --end

          else

            --if PlayerData.job.grade >= 3 then
              --ESX.ShowNotification(_U('must_in_vehicle'))
            --else
              ESX.ShowNotification(_U('must_in_taxi'))
            --end

          end

        end

      end
end

function StopBankerJob()

  local playerPed = GetPlayerPed(-1)

  if IsPedInAnyVehicle(playerPed, false) and CurrentCustomer ~= nil then
    local vehicle = GetVehiclePedIsIn(playerPed,  false)
    TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)

    if CustomerEnteredVehicle then
      TaskGoStraightToCoord(CurrentCustomer,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z,  1.0,  -1,  0.0,  0.0)
    end

  end

  ClearCurrentMission()

  OnJob = false
  OnJob1 = false

  DrawSub(_U('mission_complete'), 5000)

end

function StartBankerJob()

  ShowLoadingPromt(_U('taking_service') .. 'Transport de Fond', 5000, 3)
  ClearCurrentMission()

  --if OnJob1 then
	--OnJob1 = false
  --else
	OnJob1 = true
  --end

end

function DrawSub(msg, time)
  ClearPrints()
  SetTextEntry_2("STRING")
  AddTextComponentString(msg)
  DrawSubtitleTimed(time, 1)
end

function ShowLoadingPromt(msg, time, type)
  Citizen.CreateThread(function()
    Citizen.Wait(0)
    N_0xaba17d7ce615adbf("STRING")
    AddTextComponentString(msg)
    N_0xbd12f8228410d9b4(type)
    Citizen.Wait(time)
    N_0x10d373323e5b9c0d()
  end)
end

function GetRandomWalkingNPC()

  local search = {}
  local peds   = ESX.Game.GetPeds()

  --for i=1, #peds, 1 do
    --if IsPedHuman(peds[i]) and IsPedWalking(peds[i]) and not IsPedAPlayer(peds[i]) then
      --table.insert(search, peds[i])
    --end
  --end

  --if #search > 0 then
    --return search[GetRandomIntInRange(1, #search)]
  --end

  print('Using fallback code to find walking ped')

  --for i=1, 250, 1 do

    --local ped = GetRandomPedAtCoord(0.0,  0.0,  0.0,  math.huge + 0.0,  math.huge + 0.0,  math.huge + 0.0,  26)

    --if DoesEntityExist(ped) and IsPedHuman(ped) and IsPedWalking(ped) and not IsPedAPlayer(ped) then
      --table.insert(search, ped)
    --end

  --end

  --if #search > 0 then
    --return search[GetRandomIntInRange(1, #search)]
  --end

end

function ClearCurrentMission()

  if DoesBlipExist(CurrentCustomerBlip) then
    RemoveBlip(CurrentCustomerBlip)
  end
  
  if DoesBlipExist(CurrentCustomerBlip1) then
    RemoveBlip(CurrentCustomerBlip1)
  end

  if DoesBlipExist(DestinationBlip) then
    RemoveBlip(DestinationBlip)
  end

  if DoesBlipExist(DestinationBlip1) then
    RemoveBlip(DestinationBlip1)
  end
  
  CurrentCustomer           = nil
  CurrentCustomerBlip       = nil
  DestinationBlip           = nil
  IsNearCustomer            = false
  CustomerIsEnteringVehicle = false
  CustomerEnteredVehicle    = false
  TargetCoords              = nil
  CurrentCustomer1           = nil
  CurrentCustomerBlip1       = nil
  DestinationBlip1           = nil
  IsNearCustomer1            = false
  CustomerIsEnteringVehicle1 = false
  CustomerEnteredVehicle1    = false
  TargetCoords1              = nil

end

-- Banker Job
Citizen.CreateThread(function()

  while true do

    Citizen.Wait(0)

    local playerPed = GetPlayerPed(-1)
	local playerPed1 = GetPlayerPed(-1)

	if OnJob1 then
	  if CurrentCustomer1 == nil then

        DrawSub(_U('drive_search_pass1'), 5000)
			
            CurrentCustomer1 = 10

            if CurrentCustomer1 ~= nil then

              local standTime1 = GetRandomIntInRange(60000,  180000)
				--Citizen.Wait(15000)
              --TaskStandStill(CurrentCustomer1, standTime1)

              ESX.ShowNotification(_U('customer_found'))

            end

      else

        if IsPedInAnyVehicle(playerPed1,  false) then

          local vehicle1          = GetVehiclePedIsIn(playerPed1,  false)
          local playerCoords1     = GetEntityCoords(playerPed1)
          local customerCoords1   = GetEntityCoords(CurrentCustomer1)
          local customerDistance1 = GetDistanceBetweenCoords(playerCoords1.x,  playerCoords1.y,  playerCoords1.z,  customerCoords1.x,  customerCoords1.y,  customerCoords1.z)
  
            if CustomerEnteredVehicle1 then

              local targetDistance1 = GetDistanceBetweenCoords(playerCoords1.x,  playerCoords1.y,  playerCoords1.z,  TargetCoords1.x,  TargetCoords1.y,  TargetCoords1.z)

              if targetDistance1 <= 10.0 then

                --TaskLeaveVehicle(CurrentCustomer,  vehicle,  0)
				
                if GetEntityModel(vehicle1) == GetHashKey('Stockade') then
                
				ESX.ShowNotification(_U('arrive_dest1'))

                TaskGoStraightToCoord(CurrentCustomer1,  TargetCoords1.x,  TargetCoords1.y,  TargetCoords1.z,  1.0,  -1,  0.0,  0.0)
                SetEntityAsMissionEntity(CurrentCustomer1,  false, true)

				Citizen.Wait(15000)

                RemoveBlip(DestinationBlip1)

                --local scope1 = function(customer1)
                 -- ESX.SetTimeout(60000, function()
                    --DeletePed(customer1)
                 -- end)
               -- end

               -- scope(CurrentCustomer1)
				
				OnJob1     				  = false
				OnJob     				  = true
                CurrentCustomer1           = nil
                CurrentCustomerBlip1       = nil
                DestinationBlip1           = nil
                IsNearCustomer1            = false
                CustomerIsEnteringVehicle1 = false
                CustomerEnteredVehicle1    = false
                TargetCoords1              = nil
				
					--if OnJob then
	
						--TriggerServerEvent('esx_bankerjob:starting')
	  
						--if CurrentCustomer == nil then

							--DrawSub(_U('drive_search_pass'), 5000)
			
							--CurrentCustomer = 10

							--if CurrentCustomer ~= nil then

								--local standTime = GetRandomIntInRange(60000,  180000)
									--Citizen.Wait(15000)
									--TaskStandStill(CurrentCustomer, standTime)

								--ESX.ShowNotification(_U('customer_found'))

							--end

						--else

							--if IsPedInAnyVehicle(playerPed,  false) then

								--local vehicle          = GetVehiclePedIsIn(playerPed,  false)
								--local playerCoords     = GetEntityCoords(playerPed)
								--local customerCoords   = GetEntityCoords(CurrentCustomer)
								--local customerDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  customerCoords.x,  customerCoords.y,  customerCoords.z)

									--if CustomerEnteredVehicle then

										--local targetDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z)

										--if targetDistance <= 10.0 then
				
											--if GetEntityModel(vehicle) == GetHashKey('Stockade') then
                
												--ESX.ShowNotification(_U('arrive_dest'))

												--TaskGoStraightToCoord(CurrentCustomer,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z,  1.0,  -1,  0.0,  0.0)
												--SetEntityAsMissionEntity(CurrentCustomer,  false, true)
	
												--Citizen.Wait(15000)
												--TriggerServerEvent('esx_bankerjob:success')

												--RemoveBlip(DestinationBlip)

												--local scope = function(customer)
													--ESX.SetTimeout(60000, function()
													--DeletePed(customer)
												--end)
												--end

												--scope(CurrentCustomer)

												--CurrentCustomer           = nil
												--CurrentCustomerBlip       = nil
												--DestinationBlip           = nil
												--IsNearCustomer            = false
												--CustomerIsEnteringVehicle = false
												--CustomerEnteredVehicle    = false
												--TargetCoords              = nil
												--CurrentCustomer1           = nil
												--CurrentCustomerBlip1       = nil
												--DestinationBlip1           = nil
												--IsNearCustomer1            = false
												--CustomerIsEnteringVehicle1 = false
												--CustomerEnteredVehicle1    = false
												--TargetCoords1              = nil
												--OnJob     				  = false
				
											--end

										--end

										--if TargetCoords ~= nil then
											--DrawMarker(1, TargetCoords.x, TargetCoords.y, TargetCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
										--end

									--else

										--if GetEntityModel(vehicle) == GetHashKey('Stockade') then
			
											--RemoveBlip(CurrentCustomerBlip)

											--CurrentCustomerBlip = nil

											--TargetCoords = Config.JobLocations[GetRandomIntInRange(1,  #Config.JobLocations)]

											--local street = table.pack(GetStreetNameAtCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z))
											--local msg    = nil

											--if street[2] ~= 0 and street[2] ~= nil then
												--msg = string.format(_U('take_me_to_near', GetStreetNameFromHashKey(street[1]),GetStreetNameFromHashKey(street[2])))
											--else
												--msg = string.format(_U('take_me_to', GetStreetNameFromHashKey(street[1])))
											--end

											--ESX.ShowNotification(msg)

											--DestinationBlip = AddBlipForCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z)

											--BeginTextCommandSetBlipName("STRING")
											--ddTextComponentString("Destination")
											--EndTextCommandSetBlipName(blip)

											--SetBlipRoute(DestinationBlip,  true)

											--CustomerEnteredVehicle = true
			  
										--end  
									--end

							--else

							--DrawSub(_U('return_to_veh'), 5000)

							--end

						--end

					--else
					
					--DrawSub(_U('return_to_veh1'), 5000)
					--end
				end

              end

              if TargetCoords1 ~= nil then
                DrawMarker(1, TargetCoords1.x, TargetCoords1.y, TargetCoords1.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
              end

            else

			if GetEntityModel(vehicle1) == GetHashKey('Stockade') then
			
              RemoveBlip(CurrentCustomerBlip1)

              CurrentCustomerBlip1 = nil

              TargetCoords1 = Config.JobLocations1[GetRandomIntInRange(1,  #Config.JobLocations1)]

              local street1 = table.pack(GetStreetNameAtCoord(TargetCoords1.x, TargetCoords1.y, TargetCoords1.z))
              local msg1    = nil

              if street1[2] ~= 0 and street1[2] ~= nil then
                msg1 = string.format(_U('take_me_to_near1', GetStreetNameFromHashKey(street1[1]),GetStreetNameFromHashKey(street1[2])))
              else
                msg1 = string.format(_U('take_me_to1', GetStreetNameFromHashKey(street1[1])))
              end

              ESX.ShowNotification(msg1)

              DestinationBlip1 = AddBlipForCoord(TargetCoords1.x, TargetCoords1.y, TargetCoords1.z)

              BeginTextCommandSetBlipName("STRING")
              AddTextComponentString("Destination")
              EndTextCommandSetBlipName(blip)

              SetBlipRoute(DestinationBlip1,  true)

              CustomerEnteredVehicle1 = true
			  
			  CurrentCustomer           = nil
			  CurrentCustomerBlip       = nil
												
			  IsNearCustomer            = false
			  CustomerIsEnteringVehicle = false
			  CustomerEnteredVehicle    = false
			  
			end  
            end
		else

          DrawSub(_U('return_to_veh'), 5000)

        end

      end	
			
	
    elseif OnJob then
	  
      if CurrentCustomer == nil then

        DrawSub(_U('drive_search_pass'), 5000)
		TriggerServerEvent('esx_bankerjob:starting')
			
            CurrentCustomer = 10

            if CurrentCustomer ~= nil then

              local standTime = GetRandomIntInRange(60000,  180000)
				--Citizen.Wait(15000)
              ---TaskStandStill(CurrentCustomer, standTime)

              ESX.ShowNotification(_U('customer_found'))

            end

      else

        if IsPedInAnyVehicle(playerPed,  false) then

          local vehicle          = GetVehiclePedIsIn(playerPed,  false)
          local playerCoords     = GetEntityCoords(playerPed)
          local customerCoords   = GetEntityCoords(CurrentCustomer)
          local customerDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  customerCoords.x,  customerCoords.y,  customerCoords.z)

            if CustomerEnteredVehicle then

              local targetDistance = GetDistanceBetweenCoords(playerCoords.x,  playerCoords.y,  playerCoords.z,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z)

              if targetDistance <= 10.0 then
				
                if GetEntityModel(vehicle) == GetHashKey('Stockade') then
                
				ESX.ShowNotification(_U('arrive_dest'))

                TaskGoStraightToCoord(CurrentCustomer,  TargetCoords.x,  TargetCoords.y,  TargetCoords.z,  1.0,  -1,  0.0,  0.0)
                SetEntityAsMissionEntity(CurrentCustomer,  false, true)

				Citizen.Wait(15000)
                TriggerServerEvent('esx_bankerjob:success')

                RemoveBlip(DestinationBlip)

                --local scope = function(customer)
                  --ESX.SetTimeout(60000, function()
                    --DeletePed(customer)
                  --end)
                --end

                --scope(CurrentCustomer)

				OnJob     				  = false
				OnJob1					  = true
                CurrentCustomer           = nil
                CurrentCustomerBlip       = nil
                DestinationBlip           = nil
                IsNearCustomer            = false
                CustomerIsEnteringVehicle = false
                CustomerEnteredVehicle    = false
                TargetCoords              = nil
				
				end

              end

              if TargetCoords ~= nil then
                DrawMarker(1, TargetCoords.x, TargetCoords.y, TargetCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 178, 236, 93, 155, 0, 0, 2, 0, 0, 0, 0)
              end

            else

			if GetEntityModel(vehicle) == GetHashKey('Stockade') then
			
              RemoveBlip(CurrentCustomerBlip)

              CurrentCustomerBlip = nil

              TargetCoords = Config.JobLocations[GetRandomIntInRange(1,  #Config.JobLocations)]

              local street = table.pack(GetStreetNameAtCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z))
              local msg    = nil

              if street[2] ~= 0 and street[2] ~= nil then
                msg = string.format(_U('take_me_to_near', GetStreetNameFromHashKey(street[1]),GetStreetNameFromHashKey(street[2])))
              else
                msg = string.format(_U('take_me_to', GetStreetNameFromHashKey(street[1])))
              end

              ESX.ShowNotification(msg)

              DestinationBlip = AddBlipForCoord(TargetCoords.x, TargetCoords.y, TargetCoords.z)

              BeginTextCommandSetBlipName("STRING")
              AddTextComponentString("Destination")
              EndTextCommandSetBlipName(blip)

              SetBlipRoute(DestinationBlip,  true)

              CustomerEnteredVehicle = true
			  
			end  
            end

        else

          DrawSub(_U('return_to_veh'), 5000)

        end

      end

    end

  end
end)

AddEventHandler('esx_bankerjob:hasEnteredMarker', function (zone)
  if zone == 'BankActions' and PlayerData.job ~= nil and PlayerData.job.name == 'banker' then
    CurrentAction     = 'bank_actions_menu'
    CurrentActionMsg  = _U('press_input_context_to_open_menu')
    CurrentActionData = {}
  end
  
  if zone == 'Vehicles' and PlayerData.job ~= nil and PlayerData.job.name == 'banker' then
        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {}
  end
  
  if zone == 'VehicleDeleters' and PlayerData.job ~= nil and PlayerData.job.name == 'banker' then

      local playerPed = GetPlayerPed(-1)

      if IsPedInAnyVehicle(playerPed,  false) then

        local vehicle = GetVehiclePedIsIn(playerPed,  false)

        CurrentAction     = 'delete_vehicle'
        CurrentActionMsg  = _U('store_vehicle')
        CurrentActionData = {vehicle = vehicle}
      end

    end
end)

AddEventHandler('esx_bankerjob:hasExitedMarker', function (zone)
  CurrentAction = nil
  ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function (phoneNumber, contacts)
  local specialContact = {
    name       = 'Banque',
    number     = 'banker',
    base64Icon = 'data:image/x-icon;base64,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RCU6uEMlDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4w41Qub+NULqfjVC7b41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/4FMt/8RIJ/+2QyX/tkMl/7ZDJf+2QyX/tkMl4LhEJay2QyVyuEQlNQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyXfuUQlZLhEJQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4841Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/gUy3/xkko/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml07dDJUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4U41Quo+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/j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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5341Qu++NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/2lAs/7tFJv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX8uEQlfQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4M41Qup+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/9FNKv+4QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41Qu5+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/cUSz/vUUm/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl6rZDJSsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuGONULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/1E4r/7hDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl4rdDJRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgzjVC7L41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/4lMt/8pKKf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0MlzrdDJQ4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Qup+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/95SLf/BRyf/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uEQlrAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULnfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/ZUCv/ukQm/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uEQlfQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5E41Qu++NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/0E0q/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX8uUQlSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuFONULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/4FMt/8ZJKP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyXmt0MlFgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6v41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/91RLP++Rib/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+4RCWzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuYONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/WTyv/uEQl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+5RCVlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhTjVC7v41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/zEsp/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJfG3QyUWAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Quo+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/lZEH/9se6//78/P///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////vz7/+jEu/++Vz3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7lEJagAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULjzjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5WE+//rk3v////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////fq5/+8VDn/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7dDJUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4E41Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/0v7H//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+S4rf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml07hEJQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULmDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//75+P///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Pn4/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uUQlZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4I41Qu3+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyXfuEMlCQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULm/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/++fj///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////z5+P+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+5RCV0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4E41Qu3+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+6Xf//+/Pz////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/Pv/0499/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJeO4RCUEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULlzjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+ZmRf/umYP/8amW//vn4v//////////////////////////////////////////////////////+vPx/9uklf/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/aoZL/8NnS///////////////////////////////////////////////////////8+fj/3qmc/9qhkv/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/rzcX///////////////////////////////////////////////////////78+//hsqb/1pWE/79aQP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJWAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/riW//////////////////////////////////////////////////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTv/////////////////////////////////////////////////////////////////jua3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/u1E2//78+////////////////////////////////////////////////////////////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml0wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULjjjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+uJb//////////////////////////////////////////////////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/w2ZO/////////////////////////////////////////////////////////////////+O5rf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+7UTb//vz7////////////////////////////////////////////////////////////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uEQlPQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Qun+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+2Ref/xqZb/8amW//jUyv//////////////////////2qGS/9qhkv/aoZL/1pWE/7dGKP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/y3tl/9qhkv/aoZL/2qGS///////////////////////aoZL/2qGS/9qhkv/Ym4v/uUsv/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/Hb1j/2qGS/9qhkv/aoZL//////////////////////+zQyP/aoZL/2qGS/9mejv+8VDn/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+5RCWjAAAAAAAAAAAAAAAAAAAAAAAAAAAA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VC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hEJawAAAAAAAAAAAAAAAAAAAAA41Qu7+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl8QAAAAAAAAAAAAAAAONULjDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uEQlNQAAAAAAAAAA41Qub+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyVyAAAAAAAAAADjVC6n41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hEJawAAAAAAAAAAONULtvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl4AAAAADjVC4M41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/vUUmDuNULjTjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/79GJv/QTCo141QuXONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/FSCf/4VMt/9ZPK1zjVC6D41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/zEsp/+NULv/jVC7/3lItg+NULp/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9JOKv/jVC7/41Qu/+NULv/jVC6f41Quv+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7pEJf/YUCv/41Qu/+NULv/jVC7/41Qu/+NULr/jVC7X41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+9RSb/3FEs/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu1+NULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/wUcn/+BTLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7j41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8hJKP/iUy3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/OTCr/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+4QyX/1U8r/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/ukQm/9pQLP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/75GJv/eUi3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/DSCf/4FMt/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/y0op/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9FNKv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hEJf/XTyv/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7j41Qu1+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/xqZb//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl///////////////////////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+9RSb/3FEs/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULtfjVC6/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Gplv//////////////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/wEcn/99SLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quv+NULp/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8amW//////////////////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX//////////////////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf//////////////////////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8ZJKP/iUy3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC6f41Qug+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+h3WP/87+v//////////////////////////////////////////////////////+3QyP+4SSv/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uk4y//Hc1v//////////////////////////////////////////////////////8t/Z/7tRNv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+3Rij/7M3F///////////////////////////////////////////////////////68/H/yHJb/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/NSyn/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULoPjVC5c41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/9Lyt/////////////////////////////////////////////////////////////////86BbP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/UkoH/////////////////////////////////////////////////////////////////15iI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8t7Zv/////////////////////////////////////////////////////////////////juK3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+4QyX/004q/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuXONULjTjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5mZE/+ZpSP/voY3/////////////////////////////////////////////////////////////////y3tm/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9KMev/////////////////////////////////////////////////////////////////WlYT/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/yXVf////////////////////////////////////////////////////////////+/b1/9GJdv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/ukQl/9lQLP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC4041QuDONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+qBZf////////////////////////////////////////////////////////////////////////////v29f/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/aoZL/3KeY//35+P///////////////////////////////////////////////////////vz7/9ynmP/aoZL/2qGS/9qhkv/aoZL/2qGS/9qhkv/Ym4v/0Yp3/9GKd//Rinf/+O3r///////////////////////////////////////////////////////////////////////58O7/vFQ5/7ZDJf+2QyX/tkMl/71GJv/eUi3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULgwAAAAA41Qu2+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NfO///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Ym4v/tkMl/7ZDJf/DSCf/4FMt/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7bAAAAAAAAAADjVC6n41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/76uX//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+O4rf+2QyX/yUop/+JTLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULqcAAAAAAAAAAONULm/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//nc1P//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2ZuL/9BNKv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QubwAAAAAAAAAA41QuMONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/7I92//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////nt6v/cYD//41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC4wAAAAAAAAAAAAAAAA41Qu7+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/6Xxf//rf2P/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////1xrr/5WlI/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu7wAAAAAAAAAAAAAAAAAAAADjVC6n41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Yx/+6Zg//88e7////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////64dv/6oFl/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC6nAAAAAAAAAAAAAAAAAAAAAONULlzjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+ReO//zt6f//vz8///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////99PL/75yG/+NWMf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULlwAAAAAAAAAAAAAAAAAAAAA41QuFONULvvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/ocVL/99HH///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/Pz/87mq/+VhPv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7741QuFAAAAAAAAAAAAAAAAAAAAAAAAAAA41Quu+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/7Ixz//vp5f//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+NfO/+h0Vf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULrsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5k41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5Fk0//Cnk//++fj/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////++nl/+yPdv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgzjVC7341Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+ZmRf/1xLf//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////vn4//Gplv/kWTT/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvfjVC4MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULp/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/pfF//+t/Y//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////XEt//maUj/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QunwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuOONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVjH/7peA//zx7v////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////rh2//qf2L/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC44AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5F47//K0o//+/Pz///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////308v/umYP/41Yx/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuzwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5c41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+dvTv/30cf///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////78/P/zt6f/5F47/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC5cAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgTjVC7j41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/siW//++fi///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////30cf/6HFS/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu3+NULgQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULm/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/kWTT/8KeT//339f/////////////////////////////////////////////////////////////////////////////////////////////////76eX/7Ixz/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC5vAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuCONULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5mZF//XCtP/////////////////////////////////////////////////////////////////////////////////++fj/8KeT/+RZNP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu3+NULggAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuYONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+l8X//53NX/////////////////////////////////////////////////////////////////9cS3/+ZmRf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC5gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4E41Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NWMf/ul4D//PHu////////////////////////////////////////////+dzV/+l8X//jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quz+NULgQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4841Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/kXjv/8rGg//78/P///////////////////////PHu/+6XgP/jVjH/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC48AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6j41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/6HdY//fPxP/++fj//PLv//S8rf/mZkX/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuowAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhTjVC7v41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULu/jVC4UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULmDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULq/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULq8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuFONULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7j41QuFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuRONULvvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu++NULkQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Qud+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC53AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Qup+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QupwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4M41Quy+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULsvjVC4MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4Y41Qu3+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7f41QuGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41Qu5+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu5+NULigAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41Qu8+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvPjVC4oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4841Qu8+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7z41QuPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41Qu5+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu5+NULigAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41Qu3+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULt/jVC4oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4Y41Quy+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7L41QuGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4M41Quq+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qup+NULgwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Qud+NULvvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu++NULncAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuRONULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULuPjVC5EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuFONULq/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC6v41QuFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULmDjVC7v41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7v41QuYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhTjVC6j41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quo+NULhQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4841Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quz+NULjwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4E41QuYONULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu3+NULmDjVC4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuCONULm/jVC7f41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu3+NULm/jVC4IAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgTjVC5c41Quz+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quz+NULlzjVC4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuOONULp/jVC7341Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7341Qun+NULjgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgzjVC5k41Quu+NULvvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvvjVC6741QuZONULgwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuFONULlzjVC6n41Qu7+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu7+NULqfjVC5c41QuFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuMONULm/jVC6n41Qu2+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULtvjVC6n41Qub+NULjAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuDONULjTjVC5c41Qug+NULp/jVC6/41Qu1+NULuPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULuPjVC7X41Quv+NULp/jVC6D41QuXONULjTjVC4MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////////AAAA////////////////8AAAAA///////////////wAAAAAA//////////////gAAAAAAB/////////////gAAAAAAAH////////////AAAAAAAAAP///////////AAAAAAAAAA///////////AAAAAAAAAAD//////////gAAAAAAAAAAf/////////gAAAAAAAAAAB/////////wAAAAAAAAAAAP////////wAAAAAAAAAAAA////////4AAAAAAAAAAAAH///////8AAAAAAAAAAAAA///////8AAAAAAAAAAAAAD//////+AAAAAAAAAAAAAAf//////AAAAAAAAAAAAAAD//////gAAAAAAAAAAAAAAf/////wAAAAAAAAAAAAAAD/////4AAAAAAAAAAAAAAAf////8AAAAAAAAAAAAAAAD////+AAAAAAAAAAAAAAAAf////AAAAAAAAAAAAAAAAD////wAAAAAAAAAAAAAAAA////4AAAAAAAAAAAAAAAAH///8AAAAAAAAAAAAAAAAA///+AAAAAAAAAAAAAAAAAH///gAAAAAAAAAAAAAAAAB///wAAAAAAAAAAAAAAAAAP//4AAAAAAAAAAAAAAAAAB//+AAAAAAAAAAAAAAAAAAf//AAAAAAAAAAAAAAAAAAD//gAAAAAAAAAAAAAAAAAAf/4AAAAAAAAAAAAAAAAAAH/8AAAAAAAAAAAAAAAAAAA//AAAAAAAAAAAAAAAAAAAP/gAAAAAAAAAAAAAAAAAAB/4AAAAAAAAAAAAAAAAAAAf+AAAAAAAAAAAAAAAAAAAH/AAAAAAAAAAAAAAAAAAAA/wAAAAAAAAAAAAAAAAAAAP4AAAAAAAAAAAAAAAAAAAB+AAAAAAAAAAAAAAAAAAAAfgAAAAAAAAAAAAAAAAAAAHwAAAAAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAPAAAAAAAAAAAAAAAAAAAADwAAAAAAAAAAAAAAAAAAAA4AAAAAAAAAAAAAAAAAAAAGAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAGAAAAAAAAAAAAAAAAAAAABwAAAAAAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAPAAAAAAAAAAAAAAAAAAAADwAAAAAAAAAAAAAAAAAAAA+AAAAAAAAAAAAAAAAAAAAfgAAAAAAAAAAAAAAAAAAAH4AAAAAAAAAAAAAAAAAAAB/AAAAAAAAAAAAAAAAAAAA/wAAAAAAAAAAAAAAAAAAAP+AAAAAAAAAAAAAAAAAAAH/gAAAAAAAAAAAAAAAAAAB/4AAAAAAAAAAAAAAAAAAAf/AAAAAAAAAAAAAAAAAAAP/wAAAAAAAAAAAAAAAAAAD/+AAAAAAAAAAAAAAAAAAB//gAAAAAAAAAAAAAAAAAAf/8AAAAAAAAAAAAAAAAAAP//gAAAAAAAAAAAAAAAAAH//4AAAAAAAAAAAAAAAAAB///AAAAAAAAAAAAAAAAAA///4AAAAAAAAAAAAAAAAAf//+AAAAAAAAAAAAAAAAAH///wAAAAAAAAAAAAAAAAD///+AAAAAAAAAAAAAAAAB////wAAAAAAAAAAAAAAAA////8AAAAAAAAAAAAAAAAP////gAAAAAAAAAAAAAAAH////8AAAAAAAAAAAAAAAD/////gAAAAAAAAAAAAAAB/////8AAAAAAAAAAAAAAA//////gAAAAAAAAAAAAAAf/////8AAAAAAAAAAAAAAP//////gAAAAAAAAAAAAAH//////8AAAAAAAAAAAAAD///////wAAAAAAAAAAAAD///////+AAAAAAAAAAAAB////////wAAAAAAAAAAAA/////////AAAAAAAAAAAA/////////4AAAAAAAAAAAf/////////gAAAAAAAAAAf/////////8AAAAAAAAAAP//////////wAAAAAAAAAP///////////AAAAAAAAAP///////////+AAAAAAAAf////////////4AAAAAAAf/////////////wAAAAAA///////////////wAAAAD////////////////wAAAP////////KAAAAGAAAADAAAAAAQAgAAAAAACAlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4I41QuKeJTLU7jVC5341Qum+JTLb3j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QiT+tUIk/rVCJP62QyX7tkMlXQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtDuNULuTjVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/8a6c/v///////////v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/tymmP+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tkMl5rdDJQ8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMteONULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/99PJ/v///////////v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/uzOx/+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rhEJXsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0Y4lMt6OJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+99HH/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/uvMxP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rZDJei3QyUaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC584lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/6Xlb/vrh2v/+/Pv//v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v/////+/f3/8+Db/sZuVv+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+4RCV/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhDjVC7f4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uRbNv/nbk3/+NjP/v///////////v7+/v////////////////7+/v7+/Pz/2qCR/79aQP6/WkD/v1pA/79aQP6/WkD/v1pA/79aQP7bpJb//vz8//7+/v7///////////7+/v7///////////7+/v7t0sv/wV9F/79aQP6/WkD/v1pA/r9aQP+/WkD/v1pA/sp4Yv/58O7//v7+/v///////////v7+/v///////////v7+/vry8P/Kd2H/uUsv/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyXgtkMlEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLV3iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7lYj/+/PDt/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+5bux/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7lvbP+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v747er+u1I2/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/sx9af7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7OgWz+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QyT+t0MlYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULsbjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/6HZY/u2UfP/voYz//v7+/v//////////3KaY/9GJdv7Qh3T/u1I2/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP68Uzf/0Id0/9GJdv7oxLr///////7+/v7oxLr/0Yl2/9GJdv7EZ0//tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rdGKP/Me2b/0Yl2/tymmP///////v7+/v/////XmIf/0Yl2/sx9aP+3Rij/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/t0MlyAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtKONULv3jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUMk/bdDJSsAAAAAAAAAAAAAAAAAAAAA4lMtgONULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rdDJYMAAAAAAAAAAAAAAADiUy0I4lMtzeJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rZDJc+2QyUJAAAAAAAAAADjVC4o4lMt+ONULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJfm2QyUqAAAAAAAAAADjVC5p4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyVrAAAAAAAAAADiUy2s4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP63QyWwAAAAAONULgjjVC7g4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyXhtkMlCeNULinjVC7z4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX1uUQlLOJTLU7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+vkYmT+NULnfjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf/FSSf/1U4rd+NULpvjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/stLKf/hUy3/3lIsm+JTLb3iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP64QyX+0U0q/uJTLf7iUy3+4lMtveNULtbjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rpEJf/WTyv/4lMt/uNULv/jVC7/4lMt1uNULunjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/vEUm/ttRLP/jVC7/4lMt/uNULv/jVC7/4lMt6eJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7CRyf+31It/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tkMl/shJKP/gUy3/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/zUsp/uJTLf/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rhEJf7UTiv+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/u0Um/tlQK//iUy3/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+/Rib/3FEs/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uJTLeniUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7maUj+/v7+/v7+/v7+/v7+yHFb/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v7+/v7+/v7aoJH+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/shyW/7+/v7+/v7+/v7+/v6/WkD+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/sRIJ/7gUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt6eNULtbjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/maUj//v7+/v//////////yHFb/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7aoZL///////7+/v7aoZH/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/shyW////////v7+/v////+/WkD/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/ykop/uFTLf/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt1uNULr3jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lQu/uNULv/maUj//v7+/v//////////yHJb/7ZDJf62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7ZDJf7aoZL///////7+/v7aoZL/tkMl/7ZDJf62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tkMl/shyW////////v7+/v////+/WkD/tkMl/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rZDJf+2QyX/tUIk/rdDJf/PTCn/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMtveJTLZviUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7lYkD++uLc/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v769PL+x29Y/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP7aoZL+/v39/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v79/f7cppj+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+tUIk/sZsVP768vD+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/vXm4v69Vjv+tUIk/rVCJP61QiT+tUIk/rVCJP61QiT+uUQl/tZPK/7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMtm+NULnfjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNYM//odFX//vz7/v///////////v7+/v////////////////7+/v7/////26KT/7VCJP62QyX/tkMl/7VCJP62QyX/tkMl/7VCJP7z4Nv///////7+/v7///////////7+/v7///////////7+/v7049//tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX/tUIk/tmfkP///////v7+/v///////////v7+/v///////////v7+/v35+P/DZEz/tUIk/rZDJf+2QyX/tUIk/rZDJf+9RSb/2lAs/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMtd+JTLU7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+521N/vnd1v764dr+/vr6/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/f3+3que/tGJdv7RiXb+0Yl2/tGJdv7RiXb+0Yl2/tGJdv7sz8f+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7u08z+0Yl2/tGJdv7RiXb+0Yl2/tGJdv7MfWj+ynhi/teaif79+/v+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/vr08v7t0sv+6ce+/rlMMP61QiT+tUIk/sBHJ/7eUiz+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMtTeNULinjVC7z4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/87mq/v///////////v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/tGKeP+2QyX/xkko/uFTLf/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7z4lMtKeNULgjjVC7g4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/9MG0/v///////////v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/taSgf/MSyn/4VMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7g4lMtBwAAAADiUy2s4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+7Ixy/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7++/Xz/ttmRv7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy2sAAAAAAAAAADjVC5p4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uqAZP/52tL//v7+/v///////////v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v79/P/2zMD/53BR/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC5pAAAAAAAAAADjVC4o4lMt+ONULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/kXDj/7pmD/vzv6////v7//v7+/v////////////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v/////+/v7/+uTe/uuJb//jWDP/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULvjjVC4oAAAAAAAAAADiUy0I4lMtzeJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uVmRP7zuKj+/vr6/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v318/7wppL+5F06/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLc3iUy0IAAAAAAAAAAAAAAAA4lMtf+NULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/6HNU/vfRx//+/f3///////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v/////++vn/9cG0/uZmRP/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULn8AAAAAAAAAAAAAAAAAAAAA4lMtKONULv3jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNYM//sj3b/+uTf//7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v39/vjXzv/pfWH/41Uw/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/eNULigAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLcbiUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+5F87/vGrmP799/X+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v787er+7piC/uNYMv7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMtxgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULl3jVC7+4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7makn/9cG0//77+/7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////fb1/vKwn//lYDz/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7+4lMtXQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhDjVC7f4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Yw/+qCZv752tL//v39//7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v77+v/2y8D/6HRV/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7f4lMtDwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy1+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7kWzb+7pqD/vzx7v7+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VC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+NULv7nb1D/76CL/+6Zgv7mZkT/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC644lMtBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0u4lMt8OJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLfDiUy0uAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtauNULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULmoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtA+NULrHjVC7+41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7+4lMtsONULgMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLRriUy3a4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3a4lMtGgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4041Qu7OJTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULuzjVC40AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuU+JTLfnjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt+eNULlMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLXHiUy364lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy364lMtcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC534lMt/ONULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULvzjVC53AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4E4lMtd+NULvrjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt+uNULnfjVC4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLXHiUy354lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy354lMtcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5T4lMt7eNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULuzjVC5TAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtNeNULtrjVC7+4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7+4lMt2uNULjQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLRriUy2x4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy2w4lMtGgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4D4lMtauNULvDjVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt8ONULmrjVC4DAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULi7jVC644lMt++NULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULvvjVC644lMtLgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0G4lMtWuJTLeTiUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt5OJTLVriUy0FAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULg7jVC544lMt6ONULv/jVC7/4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULujjVC544lMtDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtGONULnzjVC7f4lMt/uNULv/jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC7/4lMt/uNULv7jVC7f4lMte+NULhgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0P4lMtXeJTLcbiUy394lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLf7iUy394lMtxuJTLV3iUy0PAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4o41QugOJTLc3jVC7441Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/jVC7/4lMt/uNULv/jVC744lMtzeNULn/jVC4oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLQjjVC4o41QuaeJTLazjVC7g41Qu8+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULvPjVC7g4lMtrONULmnjVC4o4lMtCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0H4lMtKeJTLU3iUy134lMtm+JTLb3iUy3W4lMt6eJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/uJTLeniUy3W4lMtveJTLZviUy134lMtTeJTLSniUy0HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/////4AAAf//////////+AAAAB//////////4AAAAAf/////////AAAAAAD////////8AAAAAAA////////wAAAAAAAP///////AAAAAAAAD//////+AAAAAAAAB//////4AAAAAAAAAf/////wAAAAAAAAAP/////gAAAAAAAAAH/////AAAAAAAAAAD////+AAAAAAAAAAB////4AAAAAAAAAAAf///4AAAAAAAAAAAf///wAAAAAAAAAAAP///gAAAAAAAAAAAH///AAAAAAAAAAAAD//+AAAAAAAAAAAAB//8AAAAAAAAAAAAA//8AAAAAAAAAAAAA//4AAAAAAAAAAAAAf/wAAAAAAAAAAAAAP/wAAAAAAAAAAAAAP/gAAAAAAAAAAAAAH/gAAAAAAAAAAAAAH/AAAAAAAAAAAAAAD/AAAAAAAAAAAAAAD+AAAAAAAAAAAAAAB+AAAAAAAAAAAAAAB+AAAAAAAAAAAAAAB8AAAAAAAAAAAAAAA8AAAAAAAAAAAAAAA4AAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAcAAAAAAAAAAAAAAA8AAAAAAAAAAAAAAA+AAAAAAAAAAAAAAB+AAAAAAAAAAAAAAB+AAAAAAAAAAAAAAB/AAAAAAAAAAAAAAD/AAAAAAAAAAAAAAD/gAAAAAAAAAAAAAH/gAAAAAAAAAAAAAH/wAAAAAAAAAAAAAP/wAAAAAAAAAAAAAP/4AAAAAAAAAAAAAf/8AAAAAAAAAAAAA//8AAAAAAAAAAAAA//+AAAAAAAAAAAAB///AAAAAAAAAAAAD///gAAAAAAAAAAAH///wAAAAAAAAAAAP///4AAAAAAAAAAAf///4AAAAAAAAAAAf///+AAAAAAAAAAB/////AAAAAAAAAAD/////gAAAAAAAAAH/////wAAAAAAAAAP/////4AAAAAAAAAf/////+AAAAAAAAB///////AAAAAAAAD///////wAAAAAAAP///////8AAAAAAA/////////AA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QiT+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7dDJaa2QyUCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULlXjVC7941Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVjH/42dF/8heQv+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/v1pA/79aQP+/WkD/vlk+/7dGKP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf23QyVXAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuDuNULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NYM//2yLz//v39/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////v38/+nHv/+4SCv/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyXgtkMlDwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMthuNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/++eiP/+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+//////7+/v7///////////7+/v7//////v7+/v/////+/v7+//////7+/v7VlIP/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/t0MliQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4d41Qu8ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//K0o//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////frJ//tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl8LdDJR4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6N4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+p/Y//77On+/v7+//7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+//////7+/v7///////////7+/v7//////v7+/v/////+/v7+//////fs6f7JdF3/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rdDJZAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhXjVC7s41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/kWzf/76CL//7+/v///////////////////////////+W+s/+8VDn/vFQ5/7xUOf+8VDn/vFQ5/9aWhf/+/f3////////////////////////////mv7X/vFQ5/7xUOf+8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QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl8rZDJRjjVC5D41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hDJUXjVC5041Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7sjnX//v7+/v/////DZk3+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+v1pA///////+/v7+v1pA/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/8NmTf7//////v7+/s+Db/+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7tFJXXjVC6d41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/wEYm/9ZPK53jVC7B41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7sjnX//v7+/v/////DZk3+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+v1pA///////+/v7+v1pA/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/8NmTf7//////v7+/s+Db/+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf/FSCf+4FMt/+FTLcHjVC7e41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8tLKf/iUy3/41Qu/+NULt7jVC7y41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7sjnX//v7+/v/////DZk3+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+v1pA///////+/v7+v1pA/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/8NmTf7//////v7+/s+Db/+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP63QyX/0U0q/uJTLf/iUy3+41Qu/+JTLfLjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7pEJf/XTyv/4lMt/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/vUUm/9tRLP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7sjnX//v7+/v/////DZk3+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+v1pA///////+/v7+v1pA/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/8NmTf7//////v7+/s+Db/+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP7CRyf/31It/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8dJKP/hUy3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7y41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7sjnX//v7+/v/////DZk3+tkMl/7ZDJf+1QiT+tkMl/7VCJP62QyX/tUIk/rZDJf+1QiT+v1pA///////+/v7+v1pA/7VCJP62QyX/tUIk/rZDJf+1QiT+tkMl/7VCJP62QyX/tkMl/8NmTf7//////v7+/s+Db/+1QiT+tkMl/7VCJP62QyX/tkMl/7VCJP62QyX/tUIk/rZDJf+2QyX+zkwp/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLfLjVC7e41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/sjnX////////////DZk3/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/v1pA////////////v1pA/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8NmTf///////////8+Db/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hEJf/UTir/4lMt/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULt7jVC7B41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+6HJT//Cplv71xrr//v7+/v/////hsqb+2qCR/8FfRv+1QiT+tkMl/7VCJP62QyX/tUIk/sBeRf/aoJH+36yf///////+/v7+36yf/9qgkf7BYEb/tUIk/rZDJf+1QiT+tkMl/7VCJP7AXkX/2p+Q/+Gypv7//////v7+/ufBt//aoJH+xGhQ/7VCJP62QyX/tkMl/7VCJP62QyX/u0Qm/tlQK//iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLcHjVC6d41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVzL/9L2v/////////////////////////////////+K2qv+2QyX/tkMl/7ZDJf+2QyX/tkMl/+K0qP/////////////////////////////////juKz/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/hs6f/////////////////////////////////47es/7ZDJf+2QyX/tkMl/7ZDJf+/Rib/3VEs/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULp3jVC5041Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+hyU//65uD+/PHu//7+/v7//////v7+/v/////+/v7+/////+zPx//cppj+3KaY/9ymmP7cppj/3KaY/uzOxv/+/v7+///////////+/v7+//////7+/v7s0Mj/3KaY/tymmP/cppj+26OU/9eZif7oxLr///////7+/v7//////v7+/v/////+/v7+9ujl/+/X0P68Uzj/tkMl/8NIJ/7gUi3/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLXTjVC5D41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//Cnk//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////OgGz/ykop/+JTLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULkLjVC4X41Qu8eJTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+uHbP/+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+//////7+/v7///////////7+/v7//////v7+/v/////+/v7+//////35+P7aZ0n/4lMt/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu8eJTLRcAAAAA41QuxeNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/qgWb/+d7W///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/v7/99PJ/+h1Vv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuxQAAAAAAAAAA41QufeNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5Fk1/++diP/88e7//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////v7+//vq5f/skHf/41Yx/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QufQAAAAAAAAAA41QuK+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7lY0D/87mq/v76+f/+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+//////7+/v7///////////7+/v799vT/8auZ/uRcOP/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41QuKwAAAAAAAAAA41QuAuNULs7jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+h3Wf/41Mr//v79/////////////////////////////////////////////////////////////////////////////////////////////////////////////vz8//XGuv/nbEz/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7O41QuAgAAAAAAAAAAAAAAAOJTLWzjVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/jVTD+7ZB4//vo4//+/v7+//////7+/v7//////v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v/////+/v7+//////7+/v753tf/6oNn/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy1sAAAAAAAAAAAAAAAAAAAAAONULhTjVC7s41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+RcOP/xq5n//fXz/////////////////////////////////////////////////////////////////////////////O/s/++dh//jWDP/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULuzjVC4UAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6P4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+5mxL//XGuv7+/f3//v7+/v/////+/v7+///////////+/v7+//////7+/v7//////v7+/v77+v/zuKj+5WNA/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULo0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4d41Qu8ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NUL//qgWX/+d3W///+/v/////////////////////////////////+/f3/99LI/+h0Vv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu8ONULh0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMthuNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/41k1/u+ch//88u/+///////////+/v7+//////vo4/7sjnX/41Yx/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMthgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuDuNULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/lYT7/87us//349v/99PH/8aya/+RaNv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7f41QuDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULlXjVC7941Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+VjQf/lYT3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv3jVC5VAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgLiUy2k41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLaTjVC4CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4T41Qu3ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu3ONULhMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuN+NULvHiUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7x41QuNwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULljjVC7741Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvvjVC5YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy1z41Qu/OJTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/OJTLXMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41Quf+NULvzjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7841QufwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOJTLXPjVC774lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULvviUy1zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC5Y41Qu8uNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu8eNULlgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuN+NULtzjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7c41QuNwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhPiUy2k41Qu/eNULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/eJTLaTjVC4TAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4C41QuVeNULt/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7f41QuVeNULgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULg7iUy2G41Qu8OJTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu8OJTLYbjVC4OAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuHeNULo3jVC7s41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULuzjVC6N41QuHQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4U4lMtbONULs7iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+NULv/iUy3+41Qu/+JTLf7jVC7/4lMt/uNULv/iUy3+41Qu/+JTLf7jVC7/41Qu/+JTLf7jVC7O4lMtbONULhQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgLjVC4r41QufeNULsXjVC7x41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvHjVC7F41QufeNULivjVC4CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiUy0X41QuQuJTLXTjVC6d4lMtweNULt7iUy3y41Qu/+NULv/iUy3+41Qu/+JTLfLjVC7e4lMtweNULp3iUy1041QuQuJTLRcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////gAAf///8AAAD///4AAAB///8AAAD///gAAAAf//8AAAD//+AAAAAH//8AAAD//4AAAAAB//8AAAD//gAAAAAAf/8AAAD//AAAAAAAP/8AAAD/+AAAAAAAH/8AAAD/8AAAAAAAD/8AAAD/4AAAAAAAB/8AAAD/wAAAAAAAA/8AAAD/gAAAAAAAAf8AAAD/AAAAAAAAAP8AAAD+AAAAAAAAAH8AAAD8AAAAAAAAAD8AAAD4AAAAAAAAAB8AAAD4AAAAAAAAAB8AAADwAAAAAAAAAA8AAADwAAAAAAAAAA8AAADgAAAAAAAAAAcAAADgAAAAAAAAAAcAAADAAAAAAAAAAAMAAADAAAAAAAAAAAMAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAACAAAAAAAAAAAEAAADAAAAAAAAAAAMAAADAAAAAAAAAAAMAAADgAAAAAAAAAAcAAADgAAAAAAAAAAcAAADwAAAAAAAAAA8AAADwAAAAAAAAAA8AAAD4AAAAAAAAAB8AAAD4AAAAAAAAAB8AAAD8AAAAAAAAAD8AAAD+AAAAAAAAAH8AAAD/AAAAAAAAAP8AAAD/gAAAAAAAAf8AAAD/wAAAAAAAA/8AAAD/4AAAAAAAB/8AAAD/8AAAAAAAD/8AAAD/+AAAAAAAH/8AAAD/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QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJfi3QyUyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuBeNULtPjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/91RLP++Rib/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml1bZDJQUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULnfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41cy//XDtv/+/v7///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////7+/v/nwbf/t0cq/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+3QyV5AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhnjVC7z41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+6Ygf///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9OOe/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl9LdDJRoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6V41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/wqJT////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////Zn5D/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+3QyWWAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4Y41Qu9+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5WRC//S/sP/6493////////////////////////////15eH/7NDI/+zQyP/s0Mj/7NDI/+zQyP/79fP///////////////////////79/f/t0sv/7NDI/+zQyP/s0Mj/7NDI//Hb1f////////////////////////////fr6P/kuq//vVY7/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl+LZDJRkAAAAAAAAAAAAAAAAAAAAA41QugeNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/9cS3////////////////////////////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+8VDn/////////////////////////////////zH5p/7ZDJf+2QyX/tkMl/7ZDJf/cp5n////////////////////////////15+P/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyWEAAAAAAAAAAAAAAAA41QuA+NULuXjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+VjQP/qfmL/+d7X///////juK3/yHJb/75YPf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8RoUP/Iclv////////////Iclv/x3BZ/7ZFJ/+2QyX/tkMl/7ZDJf+2QyX/uk4x/8hyW//juK3///////Hb1v/Iclv/wF5E/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl5rZDJQMAAAAAAAAAAONULkfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//jUyv//////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/2qGS///////s0Mj/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyVKAAAAAAAAAADjVC6a41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/41Mr//////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf///////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9qhkv//////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMlnAAAAAAAAAAA41Qu5eNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NTK///////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX///////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/aoZL//////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJecAAAAA41QuJ+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//jUyv//////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/2qGS///////s0Mj/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMlKeNULmDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/41Mr//////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf///////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9qhkv//////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hDJWPjVC6P41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NTK///////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX///////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/aoZL//////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/ARyeQ41Qut+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//jUyv//////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/2qGS///////s0Mj/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/KSin/3lItt+NULtfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/41Mr//////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf///////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9qhkv//////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7dDJf/RTSr/41Qu/+NULtfjVC7u41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NTK///////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX///////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/aoZL//////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7hEJf/XTyv/41Qu/+NULv/jVC7u41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//jUyv//////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/2qGS///////s0Mj/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7xFJv/cUSz/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/41Mr//////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf///////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9qhkv//////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8BHJ//fUi3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NTK///////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX///////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/aoZL//////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/8ZJKP/hUy3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu//jUyv//////2qGS/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl////////////tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/2qGS///////s0Mj/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/81LKf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULu7jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/41Mr//////9qhkv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf///////////7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/9qhkv//////7NDI/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml/9NOKv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULu7jVC7X41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/+NTK///////aoZL/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX///////////+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/aoZL//////+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/ukQl/9lQLP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7X41Qut+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/2yLz////////////////////////////cppj/tkMl/7ZDJf+2QyX/tkMl/75ZP//79vT///////////////////////v39f+/XEL/tkMl/7ZDJf+2QyX/tkMl/9ujlP///////////////////////////+nHvv+2QyX/tkMl/7ZDJf+2QyX/vUYm/91RLP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qut+NULo/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+RfO//ys6L/++fi////////////////////////////6MS7/8hyW//Iclv/yHJb/8hyW//QhXL//v39///////////////////////+/v7/0Ih1/8hyW//Iclv/x3BZ/8NmTv/kurD////////////////////////////y39r/2Z2N/7dHKv+2QyX/wkcn/+BTLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULo/jVC5g41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/umoP////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////KdmD/yUoo/+JTLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC5g41QuJ+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/64Rp///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////9+vn/2mdI/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuJwAAAADjVC7l41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/qgWX/+uLb///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////42M//6HVX/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu5QAAAAAAAAAA41QumuNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NWMf/vnoj//fPx//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////zt6f/tkXn/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULpoAAAAAAAAAAONULkfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+ViP//zuqr//v39/////////////////////////////////////////////////////////////////////////////////////////////////////////////vn4//GunP/kXDf/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC5HAAAAAAAAAADjVC4D41Qu5eNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+h0Vv/41s3/////////////////////////////////////////////////////////////////////////////////////////////////9sm9/+ZqSf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7l41QuAwAAAAAAAAAAAAAAAONULoHjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+yOdf/76+f////////////////////////////////////////////////////////////////////////////649z/6oJn/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QugQAAAAAAAAAAAAAAAAAAAADjVC4Y41Qu+ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5Fo2//Grmf/++ff///////////////////////////////////////////////////////3z8f/vnoj/41Yx/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu9+NULhgAAAAAAAAAAAAAAAAAAAAAAAAAAONULpXjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5mpI//XHu////////////////////////////////////////v39//O6qv/lYj//41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULpUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4Z41Qu8+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/6oBk//rh2///////////////////////+NXM/+h0Vv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvPjVC4ZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULnfjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVjH/756I//zx7v/76+b/7JB4/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC53AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4F41Qu0+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7T41QuBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULjDjVC7441Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7441QuMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QubeNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QubQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC6f41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QunwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuBuNULrvjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quu+NULgYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4K41QuyONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuyONULgoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgrjVC6741Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Quu+NULgoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuBuNULqDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qun+NULgYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QubeNULvjjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7441QubQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4w41Qu0+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7T41QuMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgXjVC5341Qu8+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvPjVC5341QuBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhnjVC6V41Qu9+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu9+NULpXjVC4ZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULhjjVC6B41Qu5eNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7l41QugeNULhgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgPjVC5H41QumuNULuXjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu5eNULprjVC5H41QuAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA41QuJ+NULmDjVC6P41Qut+NULtfjVC7u41Qu/+NULv/jVC7/41Qu/+NULu7jVC7X41Qut+NULo/jVC5g41QuJwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///wAA///////wAAAP/////8AAAAP/////AAAAAP////wAAAAAP///+AAAAAAf///wAAAAAA///8AAAAAAA///gAAAAAAB//8AAAAAAAD//gAAAAAAAH/+AAAAAAAAf/wAAAAAAAA/+AAAAAAAAB/wAAAAAAAAD/AAAAAAAAAP4AAAAAAAAAfgAAAAAAAAB8AAAAAAAAADwAAAAAAAAAOAAAAAAAAAAYAAAAAAAAABgAAAAAAAAAGAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAGAAAAAAAAAAYAAAAAAAAABgAAAAAAAAAHAAAAAAAAAA8AAAAAAAAAD4AAAAAAAAAfgAAAAAAAAB/AAAAAAAAAP8AAAAAAAAA/4AAAAAAAAH/wAAAAAAAA//gAAAAAAAH/+AAAAAAAAf/8AAAAAAAD//4AAAAAAAf//wAAAAAAD///wAAAAAA////gAAAAAH////AAAAAA/////AAAAAP/////AAAAD//////AAAA///////wAA////KAAAADAAAABgAAAAAQAgAAAAAACAJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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QyX/tkMlZuNULpriUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+uEQlm+NULsTiUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP67RSb+1k8rxONULuTjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8rSj//////+/WkD/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/7NDI/+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+/WkD//////9+sn/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/79GJv/eUi3/41Qu5ONULvniUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+xUgn/+FTLf7iUy3+4lMt+eNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP61QiT+tkMl/7ZDJf7LSyn+4lMt/+JTLf7iUy3+4lMt/uNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/8rSj//////+/WkD/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/7NDI/+zQyP+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+/WkD//////9+sn/+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/t0Ml/9JNKv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvniUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/7VCJP65RCX+108r/+JTLf7iUy3+41Qu/+JTLf7iUy3+4lMt+eNULuTiUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+8rSj/v////+/WkD+tUIk/rZDJf+1QiT+tUIk/rZDJf+1QiT+7M/I/uzPyP+1QiT+tUIk/rZDJf+1QiT+tUIk/rZDJf+/WkD+/////9+sn/61QiT+tkMl/7VCJP61QiT+tkMl/71FJv7cUSz+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+4lMt5ONULsTjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+VhPf/99/X/////////////////58G3/7ZDJf+2QyX/tkMl/86Bbf/+/v7////////////+/v7/z4Rw/7ZDJf+2QyX/tkMl/+a/tf/////////////////89/b/u1A0/7ZDJf+2QyX/wUcn/99SLf/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41QuxONULpriUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+6HNU//zv6/7+/f3+/v7+/v/////+/v7+9unm/ujEuv/oxLr+6MS6/u/Vz//+/v7+/v7+/v/////+/v7+79bQ/ujEuv/oxLr+5byy/vTk4P/+/v7+//////7+/v79/Pv+9ebi/75XPP7HSSj+4VMt/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+4lMtmuNULmXiUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+6X1g//7+/v7+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+//////7+/v7+/v7+/vz8/9hmR/7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+4lMtZeNULiTjVC7941Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+qCZ//64dv///7+//////////////////////////////////////////////////////////////////////////////////////////////////7+/v/52tL/6Xpc/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7941QuJONULgLiUy3S4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7jWDP+756J/v3z8P/+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/O7q/+2Vff7jVjH+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3S4lMtAgAAAADjVC5741Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+VjQf/zu6z//v38//////////////////////////////////////////////////////////////////76+f/ysaD/5F47/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC57AAAAAAAAAADiUy0b4lMt9uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+6HVW/vjWzP/+/v7+/v7+/v/////+/v7+/v7+/v/////+/v7+/v7+/v/////+/v3+9s3C/uduTv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLfbiUy0bAAAAAAAAAAAAAAAA4lMtn+NULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNVMP/skHf+++rm/v/////+/v7+/v7+/v/////+/v7+/v7+/vrk3v/rhmz+41Qu/uNULv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLZ4AAAAAAAAAAAAAAAAAAAAA41QuIeNULvjjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5Fw4//Gtm//++fj////////////99fL/76OO/+NZNP/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu+ONULiEAAAAAAAAAAAAAAAAAAAAAAAAAAONULoXiUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/makn+9MGz/vO7q//lZEL+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41QuhQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgviUy3W4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3W41QuCwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADjVC4z41Qu9eNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULvXjVC4zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtXeNULv3iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/eJTLV0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULnjiUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41Qu/+JTLf7iUy3+41QueAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAONULgHjVC5441Qu/eNULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv3jVC5441QuAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA4lMtXeNULvXiUy3+41Qu/+JTLf7iUy3+4lMt/uNULv/iUy3+4lMt/uNULv/i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iXb/0Yl2/+jGvf///////////+3TzP/RiXb/0Yl2//Lg2////////////+G0qP+3Ryr/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyWlAAAAAONULhLjVC7441Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41cy/++hjP/v1c//vFQ4/7ZDJf+2QyX/uUwv/9+sn//frJ//uk4y/7ZDJf+2QyX/u1E1/+/Vz//XmIf/uEks/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJfi2QyUT41QuX+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/7ZR8/+zQyP+2QyX/tkMl/7ZDJf+2QyX/2qGS/9qhkv+2QyX/tkMl/7ZDJf+2QyX/7NDI/9GJdv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJWDjVC6h41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/tlHz/7NDI/7ZDJf+2QyX/tkMl/7ZDJf/aoZL/2qGS/7ZDJf+2QyX/tkMl/7ZDJf/s0Mj/0Yl2/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMlouNULtHjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+2UfP/s0Mj/tkMl/7ZDJf+2QyX/tkMl/9qhkv/aoZL/tkMl/7ZDJf+2QyX/tkMl/+zQyP/RiXb/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf/HSSjR41Qu8ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/7ZR8/+zQyP+2QyX/tkMl/7ZDJf+2QyX/2qGS/9qhkv+2QyX/tkMl/7ZDJf+2QyX/7NDI/9GJdv+2QyX/tkMl/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/0E0q/+NULvDjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/tlHz/7NDI/7ZDJf+2QyX/tkMl/7ZDJf/aoZL/2qGS/7ZDJf+2QyX/tkMl/7ZDJf/s0Mj/0Yl2/7ZDJf+2QyX/tkMl/7ZDJf+2QyX/uEQl/9ZPK//jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+2UfP/s0Mj/tkMl/7ZDJf+2QyX/tkMl/9qhkv/aoZL/tkMl/7ZDJf+2QyX/tkMl/+zQyP/RiXb/tkMl/7ZDJf+2QyX/tkMl/7tFJv/bUSz/41Qu/+NULv/jVC7/41Qu8ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/7ZR8/+zQyP+2QyX/tkMl/7ZDJf+2QyX/2qGS/9qhkv+2QyX/tkMl/7ZDJf+2QyX/7NDI/9GJdv+2QyX/tkMl/7ZDJf/ARif/31It/+NULv/jVC7/41Qu/+NULvDjVC7R41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Yx//Gtm/////////////Da1P+/WkD/v1pA/+K0qf///////////+K2qv+/WkD/vVc8/+/X0P///////////9qhkv+2RCb/xUko/+FTLf/jVC7/41Qu/+NULv/jVC7/41Qu0eNULqHjVC7/41Qu/+NULv/jVC7/41Qu/+NULv/ncVL//////////////////////////////////////////////////////////////////////////////////v39/9RfQP/iUy3/41Qu/+NULv/jVC7/41Qu/+NULv/jVC6h41QuX+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/qg2j/+uPd//////////////////////////////////////////////////////////////////nf2P/pfWH/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULl/jVC4S41Qu+ONULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVzL/76CL//308v////////////////////////////////////////////zx7v/umYP/41Yw/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7441QuEgAAAADjVC6k41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/5WJA//S8rf/+/f3///////////////////////78+//ztaX/5F88/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULqMAAAAAAAAAAONULivjVC7841Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+NULv/jVC7/41Qu/+h2WP/4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iXb+0Yl2/tGJdv7NgGz+tkMl/rVCJP61QiT+tkMl9bdDJSQAAAAAAAAAAONULq7iUy3+41Qu/+NULv/ma0v+/vz8///////+/v7+/////////////////v7+/v/////+/v7+///////////+/Pz+wF1D/7ZDJf+1QiT+tkMl/7ZDJa4AAAAA4FMtJeNULvziUy3+41Qu/+NULv/iUy3+6oRp//zv7P/dqZv+uEgr/71WO//sz8f/7M/H/sBeRP+4SCv+2qCR//ju6//OgW3+tkMl/7ZDJf+1QiT+tkMl/7ZDJf22QyUm4lMtfeJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/vjZ0f66TjL+tUIk/rVCJP7RiXb+0Yl2/rVCJP61QiT+uk4y/u/Vz/61QiT+tUIk/rVCJP61QiT+tUIk/rVCJP62QyV+41Quv+NULv/iUy3+41Qu/+NULv/iUy3+41Qu//jZ0f+6TjL+tkMl/7ZDJf/RiXb/0Yl2/rZDJf+1QiT+uk4y/+/Vz/+1QiT+tkMl/7ZDJf+1QiT+tkMl/7ZDJf+2QyXA41Qu6eNULv/iUy3+41Qu/+NULv/iUy3+41Qu//jZ0f+6TjL+tkMl/7ZDJf/RiXb/0Yl2/rZDJf+1QiT+uk4y/+/Vz/+1QiT+tkMl/7ZDJf+1QiT+tkMl/7hDJf/UTivp41Qu/eNULv/iUy3+41Qu/+NULv/iUy3+41Qu//jZ0f+6TjL+tkMl/7ZDJf/RiXb/0Yl2/rZDJf+1QiT+uk4y/+/Vz/+1QiT+tkMl/7ZDJf+1QiT+u0Um/9pQLP/iUy394lMt/eJTLf7iUy3+4lMt/uJTLf7iUy3+4lMt/vjZ0f66TjL+tUIk/rVCJP7RiXb+0Yl2/rVCJP61QiT+uk4y/u/Vz/61QiT+tUIk/rVCJP6/Rib+3lIt/uJTLf7iUy3941Qu6eNULv/iUy3+41Qu/+NULv/iUy3+6oBj//vs6P/Wl4b+tkMl/7xSN//oxLr/6MS6/rxTN/+1QiT+1paG//fq5//Ic13+tkMl/8VIKP/hUy3+41Qu/+NULv/iUy3p4lMtv+JTLf7iUy3+4lMt/uJTLf7lZkT+/vr5/v7+/v78+fj+8+Hc/vXm4v7+/v7+/v7+/vXm4v7y39r+/Pj3/v7+/v789/b+0FY2/uJTLf7iUy3+4lMt/uJTLf7i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',
  }

  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- Create Blips
Citizen.CreateThread(function ()
  local blip = AddBlipForCoord(Config.Zones.BankActions.Pos.x, Config.Zones.BankActions.Pos.y, Config.Zones.BankActions.Pos.z)

  SetBlipSprite (blip, 500)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.0)
  SetBlipColour (blip, 25)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName('STRING')
  AddTextComponentString(_U('bank'))
  EndTextCommandSetBlipName(blip)
end)

-- Display markers
Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
      if(PlayerData.job ~= nil and PlayerData.job.name == 'banker' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
      end
    end

  end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function ()
  while true do
    Wait(0)

    if(PlayerData.job ~= nil and PlayerData.job.name == 'banker') then
      local coords      = GetEntityCoords(GetPlayerPed(-1))
      local isInMarker  = false
      local currentZone = nil

      for k,v in pairs(Config.Zones) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
          isInMarker  = true
          currentZone = k
        end
      end

      if isInMarker and not hasAlreadyEnteredMarker then
        hasAlreadyEnteredMarker = true
        lastZone                = currentZone
        TriggerEvent('esx_bankerjob:hasEnteredMarker', currentZone)
      end

      if not isInMarker and hasAlreadyEnteredMarker then
        hasAlreadyEnteredMarker = false
        TriggerEvent('esx_bankerjob:hasExitedMarker', lastZone)
      end
    end

  end
end)

-- Key Controls
Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'banker' and (GetGameTimer() - GUI.Time) > 150 then
        if CurrentAction == 'bank_actions_menu' then
          OpenBankActionsMenu()
        end
		if CurrentAction == 'menu_vehicle_spawner' then
            OpenVehicleSpawnerMenu()
        end

        if CurrentAction == 'delete_vehicle' then

          if Config.EnableSocietyOwnedVehicles then

            local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
            TriggerServerEvent('esx_society:putVehicleInGarage', 'unicorn', vehicleProps)

          else

            if
              GetEntityModel(vehicle) == GetHashKey('rentalbus')
            then
              TriggerServerEvent('esx_service:disableService', 'unicorn')
            end

          end
			
			StockVehicleMenu1()
			
			if delcar ~= nil then
				ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
			end	
		  
        end
		
		delcar = nil
        CurrentAction = nil
        GUI.Time      = GetGameTimer()
      end
    end

  end
end)

-- Fin fonction qui permet de rentrer un vehicule 
---------------------------------------------------------------------------------------------------------
--NB : gestion des menu
------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('NB:openMissionBanker')
AddEventHandler('NB:openMissionBanker', function()
	OpenMissionBanker()
end)

