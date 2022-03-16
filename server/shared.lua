ZRP = {}
ZRP.Players = {}
ZRP.Items = {}
ZRP.ServerCallbacks = {}
ZRP.UsableItemsCallbacks = {}
ZRP.Pickups = {}
ZRP.PickupId = 0
ZRP.RegisteredCommands = {}

AddEventHandler('zrp_framework:getSharedObject', function(cb)
  cb(ZRP)
end)

function getSharedObject()
  return ZRP
end