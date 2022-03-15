local isDead = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('zrp_framework:onPlayerJoined')
			break
		end
	end
end)