-- Main Script Auto Play & Auto Blacklist
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- Pastikan KamusData sudah ada di ReplicatedStorage
local Kamus = require(ReplicatedStorage:WaitForChild("KamusData"))

local IsAutoPlay = false
local KataTerpakai = {}

-- Fungsi Logika Utama
local function cariJawaban(hurufDepan)
	local daftar = Kamus[hurufDepan:upper()]
	if not daftar then return nil end
	
	-- Acak daftar kata agar tidak selalu menjawab kata yang sama
	local kataAcak = {}
	for _, v in pairs(daftar) do table.insert(kataAcak, v) end
	for i = #kataAcak, 2, -1 do
		local j = math.random(i)
		kataAcak[i], kataAcak[j] = kataAcak[j], kataAcak[i]
	end

	for _, kata in ipairs(kataAcak) do
		local kataUpper = kata:upper()
		if not KataTerpakai[kataUpper] then
			KataTerpakai[kataUpper] = true
			return kata
		end
	end
	return nil
end

-- Deteksi Chat Masuk
TextChatService.MessageReceived:Connect(function(textChatMessage)
	if not IsAutoPlay then return end
	
	local pesan = textChatMessage.Text:gsub("%s+", "") -- Bersihkan spasi
	if #pesan == 0 then return end
	
	local hurufTerakhir = string.sub(pesan, -1):upper()
	KataTerpakai[pesan:upper()] = true -- Blacklist kata lawan
	
	-- Jeda realistis (1-3 detik)
	task.wait(math.random(15, 30) / 10)
	
	local jawaban = cariJawaban(hurufTerakhir)
	if jawaban then
		TextChatService.TextChannels.RBXGeneral:SendAsync(jawaban)
	end
end)

-- Global Function untuk GUI Toggle
_G.ToggleAutoPlay = function()
	IsAutoPlay = not IsAutoPlay
	warn("Auto Play is now: " .. (IsAutoPlay and "ON" or "OFF"))
	return IsAutoPlay
end
