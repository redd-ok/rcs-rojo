local RCS = game:GetService("ReplicatedStorage").RCS

local Types = require(RCS.Types)

local Utilities = require(RCS.Modules.Utilities)

local AttachmentsFolder = RCS.Attachments

export type Attachment = {
	Id: string,
	Model: Model,
	Tags: { string },
	AttachmentPoints: { [string]: AttachmentPoint },
}
export type AttachmentPoint = {
	Name: string,
	Part: BasePart,
	TagWhitelist: { string },
	TagBlacklist: { string },
}

local Attachments = {}
Attachments._attachments = nil

function Attachments:GetAllAttachments(): {
	[string]: Attachment,
}
	if not Attachments._attachments then
		local atts: { [string]: Attachment } = {}
		local nest
		nest = function(folder: Folder, tags: { string })
			for i, v in folder:GetChildren() do
				if v:IsA("Model") then
					if not atts[v.Name] then
						local attachmentPoints: { [string]: AttachmentPoint } =
							{}
						if v:FindFirstChild("AttachmentPoints") then
							for i, v in
								v:FindFirstChild("AttachmentPoints")
									:GetChildren()
							do
								if v:IsA("BasePart") then
									attachmentPoints[v.Name] = {
										Name = v.Name,
										Part = v,
										TagWhitelist = string.split(
											v:GetAttribute("Whitelist") or "",
											","
										),
										TagBlacklist = string.split(
											v:GetAttribute("Blacklist") or "",
											","
										),
									}
								end
							end
						end

						atts[v.Name] = {
							Id = v.Name,
							Model = v,
							AttachmentPoints = attachmentPoints,
							Tags = tags,
						}
					else
						warn(`Duplicate attachment found: {v.Name}`)
					end
				elseif v:IsA("Folder") then
					nest(
						v,
						table.move(
							tags,
							1,
							#tags,
							#v.Name:split(",") + 1,
							v.Name:split(",")
						)
					)
				end
			end
		end
		nest(AttachmentsFolder, {})

		Attachments._attachments = atts
	end

	return Attachments._attachments
end

function Attachments:GetAttachmentsWithFilter(
	whitelist: { string },
	blacklist: { string }
): { Attachment }
	local attachments = {}

	for _, attachment in Attachments:GetAllAttachments() do
		local cont = false
		for _, tag in whitelist do
			if not table.find(attachment.Tags, tag) then
				cont = true
				break
			end
		end
		if cont then
			continue
		end

		for _, tag in blacklist do
			if table.find(attachment.Tags, tag) then
				cont = true
				break
			end
		end
		if cont then
			continue
		end

		table.insert(attachments, attachment)
	end

	return attachments
end

function Attachments:BuildAttachmentModel(
	attachment: Types.GunAttachment
): Model?
	local allAttachments = Attachments:GetAllAttachments()

	if allAttachments[attachment.Id] then
		local model = allAttachments[attachment.Id].Model:Clone()

		for i, v in model:GetChildren() do
			if v ~= model.PrimaryPart and v:IsA("BasePart") then
				Utilities:Weld(model.PrimaryPart, v)
			end
		end

		local attachmentPointsFolder = model:FindFirstChild("AttachmentPoints")
		if attachmentPointsFolder then
			for i, v in attachmentPointsFolder:GetChildren() do
				if not v:IsA("BasePart") then
					continue
				end

				Utilities:Weld(model.PrimaryPart, v)
			end
		end

		if attachment.Attachments then
			if not attachmentPointsFolder then
				warn(
					`Supplied with attachments on a model that has no attachment points`
				)
				return
			end

			for attPoint, att in attachment.Attachments do
				if
					not allAttachments[attachment.Id].AttachmentPoints[attPoint]
				then
					warn(
						`Tried to put attachment on non existing attachment point: {attPoint} on {attachment.Id}`
					)
					continue
				end
				local attachmentPoint =
					attachmentPointsFolder:FindFirstChild(attPoint)

				local attModel = Attachments:BuildAttachmentModel(att)
				attModel.Parent = attachmentPoint

				Utilities:Weld(
					attachmentPoint,
					attModel.PrimaryPart,
					CFrame.new()
				)
			end
		end

		return model
	else
		warn(`Tried to build an attachment that doesnt exist: {attachment.Id}`)
	end

	return
end

return Attachments
