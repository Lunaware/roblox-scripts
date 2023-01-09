---@diagnostic disable: undefined-global

getgenv().esp_objects = {}

getgenv().isEspEnabled = function(esp_object)
	if Toggles.ESP_Enabled.Value == false then return false end

	return (esp_object.Type == "Player" and Toggles.ESP_Players.Value) or (esp_object.Type == "Printer" and Toggles.ESP_Printers.Value) or (esp_object.Type == "Entity" and Toggles.ESP_Entities.Value) or (esp_object.Type == "Shipment" and Toggles.ESP_Shipments.Value) or false
end

getgenv().isHostile = function(Object)
	if true then return false end

	if Players:GetPlayerFromCharacter(Object) then
		if Object:FindFirstChild("NameTag") and Object.NameTag:FindFirstChild("TextLabel") and Object.NameTag.TextLabel.TextColor3 == Color3.fromRGB(255, 33, 33) then
			return true
		end
	end

	return false
end

getgenv().RemoveObjectEsp = function(Object)
	assert(Object, "failed to get parameter #1, is it null?")

	for index, esp_object in pairs(esp_objects) do
		if index == Object then
			pcall(function()
				esp_object.Highlight:Destroy()
				esp_object.Name:Remove()
				esp_object.Info:Remove()
				esp_object.Tracer:Remove()
	
				esp_objects[index] = nil
			end)
		end
	end
end

getgenv().AddObjectEsp = function(Object)
	assert(Object, "failed to get parameter #1, is it null?")

	if Object == LocalPlayer then
		return
	end

	if Object.Parent ~= nil then
		local esp = {
			Highlight = Instance.new("Highlight"),
			Name = Drawing.new("Text"),
			Info = Drawing.new("Text"),
			Tracer = Drawing.new("Line"),
			Type = (Object:IsA("Player") and "Player") or (Object:IsDescendantOf(workspace.MoneyPrinters) and "Printer") or ((Object:IsDescendantOf(workspace.Entities) and Object.Name == "Gun") and "Entity") or ((Object:IsDescendantOf(workspace.Entities) and string.find(Object.Name, "Shipment")) and "Shipment") or nil
		}

		if esp.Type == nil then
			return
		end

		esp_objects[Object] = esp
	end
end

getgenv().UpdateEsp = function()
	for index, esp_object in pairs( esp_objects ) do
			cont = true

			if index == nil or index.Parent == nil then
				pcall(function()
					esp_object.Highlight:Destroy()
					esp_object.Name:Remove()
					esp_object.Info:Remove()
					esp_object.Tracer:Remove()
		
					esp_objects[index] = nil
				end)

				cont = false
			end

			if cont and not isEspEnabled(esp_object) then
				esp_object.Name.Visible = false
				esp_object.Info.Visible = false
				esp_object.Tracer.Visible = false
				esp_object.Highlight.Enabled = false
				cont = false
			elseif cont and esp_object.Type == "Player" and not index.Character then
				esp_object.Name.Visible = false
				esp_object.Info.Visible = false
				esp_object.Tracer.Visible = false
				esp_object.Highlight.Enabled = false
				cont = false
			elseif cont and (esp_object.Type == "Printer" or esp_object.Type == "Entity" or esp_object.Type == "Shipment") then
				if not index:FindFirstChild("Int") then
					esp_object.Name.Visible = false
					esp_object.Info.Visible = false
					esp_object.Tracer.Visible = false
					esp_object.Highlight.Enabled = false
					cont = false
				end
			end

			if cont then
				local esp_pivot = esp_object.Type == "Player" and index.Character:GetPivot() or index:GetPivot()
				local Position, Visible = Camera:WorldToViewportPoint(esp_pivot.Position)
				if esp_object.Type == "Player" and index.Character:FindFirstChild("Humanoid") and index.Character.Humanoid.Health <= 0 then Visible = false end

				if Visible then
					local esp_name = (esp_object.Type == "Player" and (index:FindFirstChild("Job") and ("[".. index.Job.Value .."] ") or "").. index.Name.. " [".. math.floor(LocalPlayer:DistanceFromCharacter(esp_pivot.Position)).. "]") or (esp_object.Type == "Entity" and index.Int.Value) or index.Name
					local esp_color = (esp_object.Type == "Printer" and (string.find(index.Name, "Advanced") and Options.ESP_AdvancedPrinters.Value or Options.ESP_BasicPrinters.Value)) or (esp_object.Type == "Shipment" and Options.ESP_ShipmentColor.Value) or (esp_object.Type == "Entity" and Options.ESP_EntityColor.Value) or (esp_object.Type == "Player" and (isHostile(index.Character) and Options.ESP_Hostile.Value) or ((index:FindFirstChild("Flagged") and index.Flagged.Value == true) and Options.ESP_Flagged.Value) or ((index:FindFirstChild("Job") and (index.Job.Value == "Soldier" or index.Job.Value == "Detective" or index.Job.Value == "Mayor")) and Options.ESP_Government.Value) or Options.ESP_Neutral.Value) or Color3.new(0, 0, 0)
					local esp_info = (esp_object.Type == "Player" and string.format("Health: %s/%s | Karma: %s | Tool: %s", (index.Character:FindFirstChild("Humanoid") and math.ceil(index.Character.Humanoid.Health) or "0"), (index.Character:FindFirstChild("Humanoid") and math.floor(index.Character.Humanoid.MaxHealth) or "0"), (index:FindFirstChild("PlayerData") and index.PlayerData:FindFirstChild("Karma")) and tostring(index.PlayerData.Karma.Value) or "nil", (index.Character and index.Character:FindFirstChildOfClass("Tool")) and index.Character:FindFirstChildOfClass("Tool").Name or "nil")) or (esp_object.Type == "Printer" and string.format("Money: %s | Uses: %s | Owner: %s", index.Int.Money.Value, index.Int.Uses.Value, index.TrueOwner.Value ~= nil and tostring(index.TrueOwner.Value) or "nil")) or (esp_object.Type == "Shipment" and string.format("Uses: %s | Owner: %s", index.Int.Uses.Value, index.TrueOwner.Value ~= nil and tostring(index.TrueOwner.Value) or "nil")) or ""	

					esp_object.Info.Text = esp_info
					esp_object.Info.Position = Vector2.new(Position.X, Position.Y)
					esp_object.Info.Color = Color3.new(.8, .8, .8)
					esp_object.Info.Outline = true
					esp_object.Info.Size = 16
					esp_object.Info.Center = true

					esp_object.Name.Text = esp_name
					esp_object.Name.Color = esp_color
					esp_object.Name.Outline = true
					esp_object.Name.Size = 16
					esp_object.Name.Center = true
					esp_object.Name.Position = Vector2.new(Position.X, Position.Y - esp_object.Info.TextBounds.Y)

					esp_object.Tracer.To = Vector2.new(Position.X, Position.Y)
					esp_object.Tracer.Color = esp_color or Color3.new(0, 0, 0)
					esp_object.Tracer.From = (Toggles.ESP_MouseTracers.Value and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 100))

					esp_object.Highlight.OutlineTransparency = 1
					esp_object.Highlight.FillTransparency = .5
					esp_object.Highlight.Parent = CoreGui
					esp_object.Highlight.Adornee = (esp_object.Type == "Player" and (index.Character or index.CharacterAdded:Wait())) or index
					esp_object.Highlight.FillColor = esp_color or Color3.new(0, 0, 0)
				end
		
				esp_object.Name.Visible = Visible
				esp_object.Info.Visible = Visible
				esp_object.Tracer.Visible = Visible and Toggles.ESP_Tracers.Value
				esp_object.Highlight.Enabled = Visible
			end
	end
end