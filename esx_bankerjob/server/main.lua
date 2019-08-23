RegisterServerEvent('esx_bankerjob:payhealth')
RegisterServerEvent('esx_bankerjob:payhealth1')
RegisterServerEvent('esx_bankerjob:paycar')

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'banker', _('bank_customer1'), false, false)
TriggerEvent('esx_society:registerSociety', 'banker', 'Banquier', 'society_banker', 'society_banker', 'society_banker', {type = 'public'})

RegisterServerEvent('esx_bankerjob:customerDeposit')
AddEventHandler('esx_bankerjob:customerDeposit', function (target, amount)
  local xPlayer3 = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
    if amount > 0 and account.money >= amount and amount < 99999999 then
      --account.removeMoney(amount)

		--MySQL.Async.fetchAll(
			--'SELECT * FROM addon_account_data WHERE account_name = @account_name',
			--{ ['@account_name'] = 'bank_savings' },
			--function (result)
				--local xPlayers      = ESX.GetPlayers()

				--for i=1, #result, 1 do
					--local xPlayer     = nil

					--for i=1, #xPlayers, 1 do
						--local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
						--if xPlayer2.identifier == result[i].owner then
							--xPlayer     = xPlayer2
						--end
					--end
					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', target, function (account)
						  if account.money <= 99999999999 then	
							account.addMoney(amount)
						   TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							account.removeMoney(amount)
						   end)
						  else
							TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount2'))
						  end
						end)
				--end	
			--end	
		--)	
    else
      TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount1'))
    end
  end)
end)

RegisterServerEvent('esx_bankerjob:getStockItem')
AddEventHandler('esx_bankerjob:getStockItem', function (itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function (inventory)
		local item = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, _U('have_withdrawn', count, item.label))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_in_society'))
		end
	end)
end)

RegisterServerEvent('esx_bankerjob:putStockItems')
AddEventHandler('esx_bankerjob:putStockItems', function (itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function (inventory)
		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, _U('have_deposited', count, item.label))
		else
			TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
		end
	end)
end)

RegisterServerEvent('esx_bankerjob:customerDepositCompteBank')
AddEventHandler('esx_bankerjob:customerDepositCompteBank', function (target, amount)
  local xPlayer3 = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
    if amount > 0 and account.money >= amount and amount < 50001 then
					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_cb', target, function (account)
						  if account.money <= 500000 then	
							account.addMoney(amount)
						   TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							account.removeMoney(amount)
						   end)
						  else
							TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount3'))
						  end
						end)
    else
      TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount4'))
    end
  end)
end)

RegisterServerEvent('esx_bankerjob:customerDepositPret')
AddEventHandler('esx_bankerjob:customerDepositPret', function (target, amount)
  local xPlayer3 = ESX.GetPlayerFromId(source)

  --TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
		if amount > 0 then
					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_pret', target, function (account)
						  --if account.money <= 29000 then	
							account.addMoney(amount)
						   --TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							--account.removeMoney(amount)
						   --end)
						  --else
							--TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount2'))
						  --end
						end)
		else
			TriggerClientEvent('esx:showNotification', xPlayer3.source, 'Le montant entré ne peut être négatif')
		end
  --end)
end)

function getIdentity(source, callback)
  
  local identifier = GetPlayerIdentifiers(source)[1]
  local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
      ['@identifier'] = identifier
    })
    if result[1]['firstname'] ~= nil then
      local data = {
        identifier    = result[1]['identifier'],
        firstname     = result[1]['firstname'],
        lastname      = result[1]['lastname'],
        dateofbirth   = result[1]['dateofbirth'],
        sex           = result[1]['sex'],
        height        = result[1]['height'],
		job           = result[1]['labeljob']
      }			
      callback(data)
    else
      local data = {
        identifier    = '',
        firstname     = '',
        lastname      = '',
        dateofbirth   = '',
        sex           = '',
        height        = ''
      }
      callback(data)
    end
end

RegisterServerEvent('esx_bankerjob:success')
AddEventHandler('esx_bankerjob:success', function()

  math.randomseed(os.time())

  local xPlayer        = ESX.GetPlayerFromId(source)
  local total          = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max);
  local societyAccount = nil
  local poche = 0
  poche = xPlayer.getMoney()

  if xPlayer.job.grade > 3 then
    total = total * 2
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
    societyAccount = account
  end)

  if societyAccount ~= nil then
	if poche > 34999 then
		local playerMoney  = math.floor(35000 - (total / 100 * 75))
		local societyMoney = math.floor((total / 100 * 225) + 35000)
		local playerMoney2  = math.floor(total / 100 * 75)
		local societyMoney2 = math.floor(total / 100 * 225)
		local message = 'L\'employé a bien déposé l\'argent à la banque réceptrice'

		xPlayer.removeMoney(playerMoney)
		societyAccount.addMoney(societyMoney)
	
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. playerMoney2)
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. societyMoney2)
		
		getIdentity(source, function(data)
			MySQL.Async.execute(
				'INSERT INTO bank_data (playname, playname1, coment) VALUES (@playname, @playname1, @coment)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@coment']     = message
				}
			)
			
			MySQL.Async.execute(
				'INSERT INTO bank_result (playname, playname1, montwin) VALUES (@playname, @playname1, @montwin)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@montwin']     = societyMoney2
				}
			)

		end)

	else

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned3') .. total)

	end
  end

end)

RegisterServerEvent('esx_bankerjob:starting')
AddEventHandler('esx_bankerjob:starting', function()

  math.randomseed(os.time())

  local xPlayer        = ESX.GetPlayerFromId(source)
  local societyAccount = nil
  poche = xPlayer.getMoney()

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
    societyAccount = account
  end)

  if societyAccount ~= nil then

    local playerMoney1  = 35000
    local societyMoney1 = 35000
	local message = 'L\'employé est partie de la banque centrale avec l\'argent'

    xPlayer.addMoney(playerMoney1)
    societyAccount.removeMoney(societyMoney1)

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned1') .. playerMoney1)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned1') .. societyMoney1)
	
			getIdentity(source, function(data)
			MySQL.Async.execute(
				'INSERT INTO bank_data (playname, playname1, coment) VALUES (@playname, @playname1, @coment)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@coment']     = message
				}
			)

			end)

  end

end)

RegisterServerEvent('esx_bankerjob:customerWithdraw')
AddEventHandler('esx_bankerjob:customerWithdraw', function (target, amount)
  --local xPlayer = ESX.GetPlayerFromId(target)

  --TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function (account)
    --if amount > 0 and account.money >= amount then
      --account.removeMoney(amount)

      --TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
        --account.addMoney(amount)
      --end)
    --else
      --TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
    --end
  --end)
  
  local xPlayer3 = ESX.GetPlayerFromId(source)

  --TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
    --if amount > 0 and account.money >= amount and amount < 5001 then
      --account.removeMoney(amount)

		--MySQL.Async.fetchAll(
			--'SELECT * FROM addon_account_data WHERE account_name = @account_name',
			--{ ['@account_name'] = 'bank_savings' },
			--function (result)
				--local xPlayers      = ESX.GetPlayers()
				
				
				--for i=1, #result, 1 do
					--local xPlayer     = result[i].owner

					--for i=1, #xPlayers, 1 do
						--local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
						--if xPlayer2.identifier == result[i].owner then
							--xPlayer     = xPlayer2
						--end
					--end
					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', target, function (account)
						  if amount > 0 and account.money >= amount then	
							account.removeMoney(amount)
						   TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							account.addMoney(amount)
						   end)
						  else
							TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount5'))
						  end
						end)
				--end	
			--end	
		--)	
    --else
      --TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount'))
    --end
  --end)
end)

RegisterServerEvent('esx_bankerjob:customerWithdrawCompteBank')
AddEventHandler('esx_bankerjob:customerWithdrawCompteBank', function (target, amount)
  
  local xPlayer3 = ESX.GetPlayerFromId(source)
					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_cb', target, function (account)
						  if amount > 0 and account.money >= amount then	
							account.removeMoney(amount)
						   TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							account.addMoney(amount)
						   end)
						  else
							TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount6'))
						  end
						end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getStockItems', function (source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getPlayerInventory', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items = xPlayer.inventory

	cb({items = items})
end)

RegisterServerEvent('esx_bankerjob:customerWithdrawPret')
AddEventHandler('esx_bankerjob:customerWithdrawPret', function (target, amount)
  
  local xPlayer3 = ESX.GetPlayerFromId(source)

					
						TriggerEvent('esx_addonaccount:getAccount', 'bank_pret', target, function (account)
						  if amount > 0 and account.money >= amount then	
							account.removeMoney(amount)
						   --TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
							--account.addMoney(amount)
						   --end)
						  else
							TriggerClientEvent('esx:showNotification', xPlayer3.source, _U('invalid_amount7'))
						  end
						end)

end)

ESX.RegisterServerCallback('esx_bankerjob:getCustomers', function (source, cb)
  --local xPlayers  = ESX.GetPlayers()
  --local customers = {}

  --for i=1, #xPlayers, 1 do

    --local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

    --TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function (account)
      --table.insert(customers, {
        --source      = xPlayer.source,
        --name        = GetPlayerName(xPlayer.source)
        --bankSavings = account.money
      --})
    --end)

  --end

  --cb(customers)
  
	--MySQL.Async.fetchAll(
		--'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		--{ ['@account_name'] = 'bank_savings' },
		--function (results)
			--local customers = {}

			--for i=1, #results, 1 do
				--table.insert(customers, {
				--name = results[i].owner,
				--ident = results[i].playname,
				--bankSavings = results[i].money,
			--})
			--end

			--cb(customers)
		--end
    --)
	
	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{ 
			['@account_name'] = 'bank_savings',
		},
		function (results)
			local customers = {}

			for i=1, #results, 1 do
				namem = results[i].owner
				TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', namem, function (account)
					table.insert(customers, {
						name = account.owner,
						ident1 = account.playname1,
						ident = account.playname,
						bankSavings = account.money,
					})
				end)	
			end

			cb(customers)
		end
    )
end)

ESX.RegisterServerCallback('esx_bankerjob:getCustomersPret', function (source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{ 
			['@account_name'] = 'bank_pret',
		},
		function (results)
			local customers = {}

			for i=1, #results, 1 do
				namem = results[i].owner
				TriggerEvent('esx_addonaccount:getAccount', 'bank_pret', namem, function (account)
					table.insert(customers, {
						name = account.owner,
						ident1 = account.playname1,
						ident = account.playname,
						bankSavings = account.money,
					})
				end)	
			end

			cb(customers)
		end
    )
end)

ESX.RegisterServerCallback('esx_bankerjob:getCustomersCompteBank', function (source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{ 
			['@account_name'] = 'bank_cb',
		},
		function (results)
			local customers = {}

			for i=1, #results, 1 do
				namem = results[i].owner
				TriggerEvent('esx_addonaccount:getAccount', 'bank_cb', namem, function (account)
					table.insert(customers, {
						name = account.owner,
						ident1 = account.playname1,
						ident = account.playname,
						bankSavings = account.money,
					})
				end)	
			end

			cb(customers)
		end
    )
end)

function CalculateBankSavings (d, h, m)
  local asyncTasks = {}

  ----MySQL.Async.fetchAll(
    ----'SELECT * FROM addon_account_data WHERE account_name = @account_name',
    ----{ ['@account_name'] = 'bank_savings' },
    ----function (result)
      ----local bankInterests = 0
      ----local xPlayers      = ESX.GetPlayers()

      ----for i=1, #result, 1 do
        ----local foundPlayer = false
        ----local xPlayer     = nil

        ----for i=1, #xPlayers, 1 do
          ----local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
          ----if xPlayer2.identifier == result[i].owner then
            ----foundPlayer = true
            ----xPlayer     = xPlayer2
          ----end
        ----end

        --if foundPlayer then
          --TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', xPlayer.identifier, function (account)
            --local interests = math.floor(account.money / 100 * Config.BankSavingPercentage)
            --bankInterests   = bankInterests + interests

            --table.insert(asyncTasks, function(cb)
              --account.addMoney(interests)
            --end)
          --end)
		--else
		
          ----local interests = math.floor(result[i].money / 100 * Config.BankSavingPercentage)
          ----local newMoney  = result[i].money + interests;
          ----bankInterests   = bankInterests + interests

          ----local scope = function (newMoney, owner)
            ----table.insert(asyncTasks, function (cb)

              ----MySQL.Async.execute(
                ----'UPDATE addon_account_data SET money = @money WHERE owner = @owner AND account_name = @account_name',
                ----{
                  ----['@money']        = newMoney,
                  ----['@owner']        = owner,
                  ----['@account_name'] = 'bank_savings',
                ----},
                ----function (rowsChanged)
                  ----cb()
                ----end
              ----)
            ----end)
          ----end

          ----scope(newMoney, result[i].owner)
        --end
      ----end
	  
	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{ 
			['@account_name'] = 'bank_savings',
		},
		function (results)
			local bankInterests = 0
			---local customers = {}

			for i=1, #results, 1 do
				namem = results[i].owner
				TriggerEvent('esx_addonaccount:getAccount', 'bank_savings', namem, function (account)
				  if account.money < 30001 then
					local interests = math.floor(account.money / 100 * Config.BankSavingPercentage)
					bankInterests   = bankInterests + interests
					
					table.insert(asyncTasks, function(cb)
						account.addMoney(interests)
					end)
				  end	
				end)	
			end

			---cb(customers)
		
    

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
				account.removeMoney(bankInterests)
			end)

			Async.parallelLimit(asyncTasks, 5, function (results)
				print('[BANK] Calculated interests')
			end)

			print('[BANK1] Calculated interests')
		end
    ----end
	)
  -----)
end

function CalculateBankPretSavings (d, h, m)
  local asyncTasks = {}

	MySQL.Async.fetchAll(
		'SELECT * FROM addon_account_data WHERE account_name = @account_name',
		{ 
			['@account_name'] = 'bank_pret',
		},
		function (results)
			local bankPretMensu = 0

			for i=1, #results, 1 do
				namem = results[i].owner
				TriggerEvent('esx_addonaccount:getAccount', 'bank_pret', namem, function (account)
					local Mensu = math.floor(account.money / 1)
					bankPretMensu   = bankPretMensu + Mensu
					
					TriggerEvent('esx_addonaccount:getAccount', 'bank_cb', namem, function (account1)
						table.insert(asyncTasks, function(cb)
							account1.removeMoney(Mensu)
						end)
					--table.insert(asyncTasks, function(cb)
						--xPlayer.removeAccountMoney('bank', Mensu)
						--account.addMoney(Mensu)
					--end)
					end)
				end)
					
			end
		
    

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function (account)
				account.addMoney(bankPretMensu)
			end)

			Async.parallelLimit(asyncTasks, 5, function (results)
				print('[BANK] Calculated Mensualite Pret')
			end)

			print('[BANK1] Calculated Mensualite Pret')
		end
	)
	
end

--debut de payement pour la santé vehicule
AddEventHandler('esx_bankerjob:payhealth', function(price)

	local xPlayer = ESX.GetPlayerFromId(source)
	local joby
	local message = 'L\'employé a ramené un véhicule en mauvais état au garage'
	joby = 'banker'
    TriggerEvent('esx_society:getSociety', joby, function (society)
    TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
	
	account.addMoney(price)
    TriggerClientEvent('esx:showNotification', xPlayer.source, ('~b~Voiture dégradée, l\'entreprise ne récupère pas la somme totale de location : ') .. '~r~$' .. price)
    end)
    end)
			getIdentity(source, function(data)
			MySQL.Async.execute(
				'INSERT INTO bank_data (playname, playname1, coment) VALUES (@playname, @playname1, @coment)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@coment']     = message
				}
			)

			end)
	
end)
--fin de payement pour la santé vehicule

--debut de payement pour la santé vehicule
AddEventHandler('esx_bankerjob:payhealth1', function(price)

	local xPlayer = ESX.GetPlayerFromId(source)
	local joby
	local message = 'L\'employé a ramené un véhicule en bon état au garage'
	joby = 'banker'
    TriggerEvent('esx_society:getSociety', joby, function (society)
    TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
	
	account.addMoney(price)
    TriggerClientEvent('esx:showNotification', xPlayer.source, ('~b~Bonne état, l\'entreprise récupère la somme totale de location : ') .. '~g~$' .. price)
    end)
    end)
			getIdentity(source, function(data)
			MySQL.Async.execute(
				'INSERT INTO bank_data (playname, playname1, coment) VALUES (@playname, @playname1, @coment)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@coment']     = message
				}
			)

			end)	
	
end)
--fin de payement pour la santé vehicule

--debut de payement pour la santé vehicule
AddEventHandler('esx_bankerjob:paycar', function(price)

	local xPlayer = ESX.GetPlayerFromId(source)
	local joby
	local message = 'L\'employé a sortie un véhicule du garage'
	joby = 'banker'
    TriggerEvent('esx_society:getSociety', joby, function (society)
    TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
	
	account.removeMoney(price)
    TriggerClientEvent('esx:showNotification', xPlayer.source, ('~b~Voiture de service sortie, l\'entreprise prend en charge les frais de location : ') .. '~r~$' .. price)
    end)
    end)
			getIdentity(source, function(data)
			MySQL.Async.execute(
				'INSERT INTO bank_data (playname, playname1, coment) VALUES (@playname, @playname1, @coment)',
				{
					['@playname']     = data.lastname,
					['@playname1']     = data.firstname,
					['@coment']     = message
				}
			)

			end)	
	
end)
--fin de payement pour la santé vehicule

function Tick1()

	local chrono = false

	if chrono then
		SetTimeout(Config.Interval, CalculateBankSavings)
		chrono = false
	else	
		SetTimeout(Config.Interval, CalculateBankSavings)
		chrono = true
	end

	SetTimeout(Config.Interval, Tick1)
end

function Tick2()

	local chrono1 = false

	if chrono1 then
		SetTimeout(Config.Intervalpret, CalculateBankPretSavings)
		chrono1 = false
	else	
		SetTimeout(Config.Intervalpret, CalculateBankPretSavings)
		chrono1 = true
	end

	SetTimeout(Config.Intervalpret, Tick2)
end

Tick1()
Tick2()

--TriggerEvent('cron:runAt', 22, 0, CalculateBankSavings)
