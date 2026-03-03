-- =============================================
-- SAMBUNG KATA - SERVER SCRIPT
-- Letakkan di: ServerScriptService > GameScript
-- =============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

-- Remote Events (buat folder "Remotes" di ReplicatedStorage)
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local RemoteSubmitWord = Instance.new("RemoteEvent")
RemoteSubmitWord.Name = "SubmitWord"
RemoteSubmitWord.Parent = Remotes

local RemoteUpdateUI = Instance.new("RemoteEvent")
RemoteUpdateUI.Name = "UpdateUI"
RemoteUpdateUI.Parent = Remotes

local RemoteGameState = Instance.new("RemoteEvent")
RemoteGameState.Name = "GameState"
RemoteGameState.Parent = Remotes

local RemoteNotify = Instance.new("RemoteEvent")
RemoteNotify.Name = "Notify"
RemoteNotify.Parent = Remotes

-- =============================================
-- KAMUS KATA BAHASA INDONESIA (Sample)
-- Tambahkan lebih banyak kata sesuai kebutuhan!
-- =============================================
local Dictionary = {
	-- A
	"apel", "awan", "air", "api", "anak", "angin", "ayam", "angsa", "akar", "alam",
	"anjing", "asing", "asap", "atas", "awak", "arung", "abang", "agung", "adik", "aksi",
	-- B
	"buku", "bunga", "burung", "batu", "baru", "besar", "biasa", "bulan", "bumi", "baik",
	"bangku", "bawang", "bayam", "bebek", "benar", "bintang", "bodoh", "bola", "boneka", "borong",
	-- C
	"cinta", "cerita", "cahaya", "cepat", "cucak", "cabai", "cacing", "cakar", "cantik", "capek",
	"celana", "cemara", "cendol", "cermat", "cicak", "ciri", "cobek", "coklat", "cuaca", "cuci",
	-- D
	"daun", "dalam", "dekat", "dunia", "darat", "daging", "damai", "danau", "dawai", "dayung",
	"debat", "dedak", "dekat", "delman", "demam", "derek", "desa", "dewa", "dinding", "domba",
	-- E
	"elang", "emas", "enak", "embun", "ember", "empat", "enak", "energi", "era", "esok",
	-- F
	"foto", "film", "fisik", "fajar", "fakta", "famili", "fantasi", "fesyen", "filosofi", "flora",
	-- G
	"gunung", "gajah", "garam", "gelap", "gempa", "gitar", "goreng", "gulai", "guru", "gula",
	"gabah", "gadis", "gagak", "galak", "galon", "gandum", "garpu", "gatot", "gaung", "gerak",
	-- H
	"hujan", "hutan", "hijau", "hitam", "harum", "harap", "hasil", "hati", "hayam", "hebat",
	"helai", "hemat", "hendak", "hewan", "hidup", "hilang", "hobi", "hormat", "hotel", "hubung",
	-- I
	"ikan", "indah", "inti", "ingin", "ilmu", "ibu", "impian", "iring", "isap", "istri",
	-- J
	"jalan", "jauh", "jaga", "jambu", "jaring", "jeruk", "jiwa", "joget", "jujur", "jumlah",
	"jabat", "jagung", "jajan", "jambul", "jangkrik", "janji", "jasa", "jawab", "jelita", "jernih",
	-- K
	"kucing", "kuda", "kamu", "kayu", "keras", "kecil", "kelas", "kenan", "kepala", "kerja",
	"kabut", "kacang", "kaget", "kaki", "kalah", "kambing", "kanan", "kapal", "karang", "kasih",
	-- L
	"langit", "laut", "lemah", "lembu", "lepas", "lezat", "lihat", "lincah", "lopak", "lotus",
	"labu", "ladang", "lahir", "lapar", "lari", "laut", "layar", "lebah", "lelah", "lengan",
	-- M
	"matahari", "makan", "malam", "manis", "mati", "meja", "merah", "mimpi", "mobil", "muda",
	"maaf", "macam", "magis", "mahir", "malas", "marah", "masak", "masuk", "mati", "mayur",
	-- N
	"nasi", "nama", "nilai", "nyala", "nyaman", "naik", "nangka", "narasi", "nasib", "natur",
	-- O
	"obat", "orang", "ombak", "omong", "opor", "otak", "otot",
	-- P
	"pohon", "pagi", "panas", "pantas", "papan", "pelajar", "penuh", "perlu", "pikir", "pintar",
	"padat", "pagar", "pahit", "pakai", "pakan", "paling", "pandai", "panjang", "pasir", "peduli",
	-- R
	"rumah", "rasa", "rajin", "ramai", "ramah", "rangka", "rapi", "rasa", "raung", "rawa",
	"rebus", "rendah", "resap", "ribut", "ringan", "roti", "ruang", "rubuh", "rusak", "rutuk",
	-- S
	"sapi", "satu", "sabar", "sabun", "sakit", "salam", "salju", "sampah", "sanak", "saring",
	"sekolah", "semua", "senang", "sinar", "siswa", "soleh", "subur", "suguh", "sulit", "sunyi",
	-- T
	"tangan", "tanah", "tawa", "tebal", "telur", "tepat", "terima", "tikus", "tinggi", "tiruan",
	"tanam", "tanya", "tarik", "taubat", "tegak", "tegas", "tekad", "tekun", "telung", "tembok",
	-- U
	"udara", "uang", "ubur", "ulang", "umum", "unggas", "unta", "usaha", "usik", "utama",
	-- W
	"warna", "waktu", "watak", "wajah", "warung", "wisata", "wujud",
	-- Y
	"yakin", "yangs", "yoga",
	-- Z
	"zona", "zaman", "zebra",
}

-- Index kata berdasarkan huruf awal (untuk performa lebih cepat)
local WordIndex = {}
for _, word in ipairs(Dictionary) do
	local firstLetter = string.lower(string.sub(word, 1, 1))
	if not WordIndex[firstLetter] then
		WordIndex[firstLetter] = {}
	end
	table.insert(WordIndex[firstLetter], word)
end

-- =============================================
-- STATE GAME
-- =============================================
local GameState = {
	isRunning = false,
	currentPlayerIndex = 1,
	playerOrder = {},
	usedWords = {},
	currentWord = "",
	lastLetter = "",
	timeLimit = 15, -- detik per giliran
	scores = {},
	roundTimer = nil,
}

-- =============================================
-- FUNGSI HELPER
-- =============================================

local function getLastLetter(word)
	return string.lower(string.sub(word, -1))
end

local function getFirstLetter(word)
	return string.lower(string.sub(word, 1, 1))
end

local function isWordValid(word)
	word = string.lower(word)
	-- Cek apakah kata ada di kamus
	for _, dictWord in ipairs(Dictionary) do
		if dictWord == word then
			return true
		end
	end
	return false
end

local function isWordUsed(word)
	return GameState.usedWords[string.lower(word)] == true
end

local function broadcastToAll(remoteEvent, ...)
	for _, player in ipairs(Players:GetPlayers()) do
		remoteEvent:FireClient(player, ...)
	end
end

local function updateScoreboard()
	local scoreData = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(scoreData, {
			name = player.Name,
			score = GameState.scores[player.UserId] or 0
		})
	end
	-- Sort by score
	table.sort(scoreData, function(a, b) return a.score > b.score end)
	broadcastToAll(RemoteUpdateUI, "scoreboard", scoreData)
end

local function notifyCurrentPlayer()
	local playerOrder = GameState.playerOrder
	if #playerOrder == 0 then return end
	local currentIdx = GameState.currentPlayerIndex
	local currentPlayer = playerOrder[currentIdx]

	if currentPlayer and currentPlayer.Parent then
		broadcastToAll(RemoteUpdateUI, "turn", {
			playerName = currentPlayer.Name,
			lastLetter = string.upper(GameState.lastLetter),
			currentWord = GameState.currentWord,
			timeLimit = GameState.timeLimit,
		})
		-- Notify current player it's their turn
		RemoteNotify:FireClient(currentPlayer, "yourTurn", GameState.lastLetter)
	end
end

local function eliminatePlayer(player, reason)
	-- Hapus dari urutan
	for i, p in ipairs(GameState.playerOrder) do
		if p == player then
			table.remove(GameState.playerOrder, i)
			if GameState.currentPlayerIndex > #GameState.playerOrder then
				GameState.currentPlayerIndex = 1
			end
			break
		end
	end
	broadcastToAll(RemoteNotify, "eliminated", player.Name, reason)
	
	-- Cek apakah game selesai (tinggal 1 pemain)
	if #GameState.playerOrder <= 1 then
		local winner = GameState.playerOrder[1]
		if winner then
			GameState.scores[winner.UserId] = (GameState.scores[winner.UserId] or 0) + 5
			broadcastToAll(RemoteGameState, "gameOver", winner.Name)
		end
		GameState.isRunning = false
	end
end

local function nextTurn()
	if not GameState.isRunning then return end
	local order = GameState.playerOrder
	if #order == 0 then return end

	GameState.currentPlayerIndex = (GameState.currentPlayerIndex % #order) + 1
	notifyCurrentPlayer()

	-- Timer per giliran
	if GameState.roundTimer then
		task.cancel(GameState.roundTimer)
	end
	GameState.roundTimer = task.delay(GameState.timeLimit, function()
		if GameState.isRunning then
			local currentPlayer = order[GameState.currentPlayerIndex]
			if currentPlayer then
				eliminatePlayer(currentPlayer, "Kehabisan waktu!")
				if GameState.isRunning then
					nextTurn()
				end
			end
		end
	end)
end

-- =============================================
-- MULAI GAME
-- =============================================
local function startGame()
	local players = Players:GetPlayers()
	if #players < 2 then
		broadcastToAll(RemoteNotify, "info", "Butuh minimal 2 pemain untuk mulai!")
		return
	end

	-- Reset state
	GameState.isRunning = true
	GameState.usedWords = {}
	GameState.currentWord = ""
	GameState.lastLetter = ""
	GameState.currentPlayerIndex = 1
	GameState.playerOrder = {}

	-- Acak urutan pemain
	local shuffled = {}
	for _, p in ipairs(players) do
		table.insert(shuffled, p)
		GameState.scores[p.UserId] = GameState.scores[p.UserId] or 0
	end
	for i = #shuffled, 2, -1 do
		local j = math.random(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	GameState.playerOrder = shuffled

	-- Kata pertama ditentukan oleh sistem
	local starterWords = {"api", "buku", "cinta", "daun", "elang"}
	local starter = starterWords[math.random(1, #starterWords)]
	GameState.currentWord = starter
	GameState.lastLetter = getLastLetter(starter)
	GameState.usedWords[starter] = true

	broadcastToAll(RemoteGameState, "gameStart", {
		word = starter,
		lastLetter = string.upper(GameState.lastLetter),
		playerOrder = (function()
			local names = {}
			for _, p in ipairs(GameState.playerOrder) do
				table.insert(names, p.Name)
			end
			return names
		end)(),
	})

	task.wait(2)
	notifyCurrentPlayer()

	-- Set timer giliran pertama
	GameState.roundTimer = task.delay(GameState.timeLimit, function()
		if GameState.isRunning then
			local currentPlayer = GameState.playerOrder[GameState.currentPlayerIndex]
			if currentPlayer then
				eliminatePlayer(currentPlayer, "Kehabisan waktu!")
				if GameState.isRunning then nextTurn() end
			end
		end
	end)
end

-- =============================================
-- TERIMA KATA DARI PEMAIN
-- =============================================
RemoteSubmitWord.OnServerEvent:Connect(function(player, word)
	if not GameState.isRunning then
		RemoteNotify:FireClient(player, "error", "Game belum dimulai!")
		return
	end

	-- Cek giliran
	local currentPlayer = GameState.playerOrder[GameState.currentPlayerIndex]
	if currentPlayer ~= player then
		RemoteNotify:FireClient(player, "error", "Bukan giliran kamu!")
		return
	end

	word = string.lower(string.gsub(word, "%s+", ""))

	-- Validasi 1: Kata sudah dipakai?
	if isWordUsed(word) then
		RemoteNotify:FireClient(player, "error", "Kata '" .. word .. "' sudah pernah dipakai!")
		return
	end

	-- Validasi 2: Huruf awal harus sesuai
	if GameState.lastLetter ~= "" and getFirstLetter(word) ~= GameState.lastLetter then
		RemoteNotify:FireClient(player, "error", 
			"Kata harus dimulai dengan huruf '" .. string.upper(GameState.lastLetter) .. "'!")
		return
	end

	-- Validasi 3: Kata harus ada di kamus
	if not isWordValid(word) then
		RemoteNotify:FireClient(player, "error", "Kata '" .. word .. "' tidak ada di kamus!")
		return
	end

	-- SUKSES!
	if GameState.roundTimer then
		task.cancel(GameState.roundTimer)
	end

	GameState.currentWord = word
	GameState.lastLetter = getLastLetter(word)
	GameState.usedWords[word] = true
	GameState.scores[player.UserId] = (GameState.scores[player.UserId] or 0) + 1

	broadcastToAll(RemoteNotify, "wordAccepted", {
		playerName = player.Name,
		word = word,
		lastLetter = string.upper(GameState.lastLetter),
	})

	updateScoreboard()
	task.wait(1)
	nextTurn()
end)

-- =============================================
-- PEMAIN JOIN / LEAVE
-- =============================================
Players.PlayerAdded:Connect(function(player)
	GameState.scores[player.UserId] = 0
	task.wait(2) -- tunggu GUI load
	RemoteGameState:FireClient(player, "welcome", {
		isRunning = GameState.isRunning,
		currentWord = GameState.currentWord,
		lastLetter = string.upper(GameState.lastLetter),
	})
end)

Players.PlayerRemoving:Connect(function(player)
	if GameState.isRunning then
		for i, p in ipairs(GameState.playerOrder) do
			if p == player then
				table.remove(GameState.playerOrder, i)
				broadcastToAll(RemoteNotify, "info", player.Name .. " telah keluar dari game.")
				if #GameState.playerOrder <= 1 and GameState.isRunning then
					local winner = GameState.playerOrder[1]
					if winner then
						broadcastToAll(RemoteGameState, "gameOver", winner.Name)
					end
					GameState.isRunning = false
				elseif GameState.currentPlayerIndex > #GameState.playerOrder then
					GameState.currentPlayerIndex = 1
				end
				break
			end
		end
	end
	GameState.scores[player.UserId] = nil
end)

-- =============================================
-- AUTO START (opsional - aktifkan jika mau)
-- =============================================
-- task.wait(10)
-- startGame()

-- Expose startGame untuk admin via RemoteFunction
local StartGameRemote = Instance.new("RemoteEvent")
StartGameRemote.Name = "StartGame"
StartGameRemote.Parent = Remotes

StartGameRemote.OnServerEvent:Connect(function(player)
	-- Hanya admin yang bisa mulai (ganti dengan UserId kamu)
	-- if player.UserId == 12345678 then
		startGame()
	-- end
end)

print("[SambungKata] Server Script loaded!")
