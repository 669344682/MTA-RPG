LootClothes_S = inherit(Attack_S)

function LootClothes_S:constructor(lootSettings)
	
	self.settings = lootSettings
	self.id = lootSettings.id
	self.x = lootSettings.x
	self.y = lootSettings.y
	self.z = lootSettings.z
	self.rz = math.random(0, 360)
	self.playerClass = lootSettings.playerClass
	
	self.itemContainer = lootSettings.itemContainer
	self.itemContainer.instance = nil
	
	self.owner = nil
	
	self.startCount = 0
	self.currentCount = 0
	
	self.isLocked = true
	self.isPickedUp = false
	self.pickup = nil
	self.aura = nil

	self:init()
	
	if (Settings.showClassDebugInfo == true) then
		sendMessage("LootClothes_S " .. self.id .. " was loaded.")
	end
end


function LootClothes_S:init()
	if (self.playerClass) then
		self.owner = self.playerClass.player
		
		if (not self.owner) then
			LootManager_S:getSingleton():deleteLoot(self.id)
		end
	else
		LootManager_S:getSingleton():deleteLoot(self.id)
	end
	
	self.m_PickupItem = bind(self.pickupItem, self)
	addEvent("PICKUPLOOT", true)
	addEventHandler("PICKUPLOOT", root, self.m_PickupItem)
	
	self:createLootObject()
	
	self.startCount = getTickCount()
end


function LootClothes_S:update()
	self.currentCount = getTickCount()
	
	if (self.currentCount > self.startCount + Settings.lootLockDelay) then
		if (self.isLocked == true) then
			if (self.owner) then
				self.owner = nil
			end
			
			if (self.playerClass) then
				self.playerClass = nil
			end
			
			self.isLocked = false
		end
	end
	
	if (self.currentCount > self.startCount + Settings.lootDelay) then
		LootManager_S:getSingleton():deleteLoot(self.id)
	end
end


function LootClothes_S:pickupItem(element)
	if (self.isPickedUp == false) then
		if (client) and (isElement(client)) and (element) and (self.pickUp) then
			if (element == self.pickUp) then
				if (self.owner) then
					if (self.owner == client) then
						if (self.playerClass) then
							if (self.itemContainer) then
								local color = RGBToHex(self.itemContainer.color.r, self.itemContainer.color.g, self.itemContainer.color.b)
								local inventory = self.playerClass:getInventory()
								
								if (color) and (inventory) then
									self.isPickedUp = true
									inventory:addItem(self.owner, self.itemContainer)
									
									NotificationManager_S:getSingleton():sendPlayerNotification(self.owner, "#EEEEEEYou got " .. color .. self.itemContainer.name)
									LootManager_S:getSingleton():deleteLoot(self.id)
								end
							end
						end
					else
						NotificationManager_S:getSingleton():sendPlayerNotification(client, "#EE4444Not allowed to loot this!")
					end
				else
					self.owner = client
					self.playerClass = PlayerManager_S:getSingleton():getPlayerClass(self.owner)
					
					if (self.playerClass) then
						if (self.itemContainer) then
							local color = RGBToHex(self.itemContainer.color.r, self.itemContainer.color.g, self.itemContainer.color.b)
							local inventory = self.playerClass:getInventory()
							
							if (color) and (inventory) then
								self.isPickedUp = true
								inventory:addItem(self.owner, self.itemContainer)
								
								NotificationManager_S:getSingleton():sendPlayerNotification(self.owner, "#EEEEEEYou got " .. color .. self.itemContainer.name)
								LootManager_S:getSingleton():deleteLoot(self.id)
							end
						end
					end
				end
			end
		end
	end
end


function LootClothes_S:createLootObject()
	if (not self.pickUp) and (self.owner)then
		self.pickUp = createObject(1575, self.x, self.y, self.z - 0.48, 0, 0, self.rz, false)
		
		if (self.pickUp) then
			self.pickUp:setData("ISLOOT", "true", true)
			self.pickUp:setDimension(self.owner:getDimension())
			
			if (self.itemContainer) then
				if (self.itemContainer.color) then
					if (not self.aura) then
						self.aura = createMarker(self.x, self.y, self.z - 0.48, "corona", 0.4, self.itemContainer.color.r, self.itemContainer.color.g, self.itemContainer.color.b, 45)
					
						if (self.aura) then
							self.aura:setDimension(self.owner:getDimension())
						end
					end
				end
			end
		end
	end
end


function LootClothes_S:deleteLootObject()
	if (self.pickUp) then
		self.pickUp:destroy()
		self.pickUp = nil
	end
	
	if (self.aura) then
		self.aura:destroy()
		self.aura = nil
	end
end


function LootClothes_S:getObject()
	return self.pickUp
end


function LootClothes_S:getPosition()
	return {x = self.x, y = self.y, z = self.z}
end


function LootClothes_S:clear()
	removeEventHandler("PICKUPLOOT", root, self.m_PickupItem)
	
	self:deleteLootObject()
end


function LootClothes_S:destructor()
	self:clear()

	if (Settings.showClassDebugInfo == true) then
		sendMessage("LootClothes_S " .. self.id .. " was deletes.")
	end
end