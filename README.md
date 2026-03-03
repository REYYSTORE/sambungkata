# Roblox Sambung Kata Auto-Play Script

Script otomatis untuk memenangkan game "Sambung Kata" di Roblox. Dilengkapi dengan database kamus bahasa Indonesia dan fitur Auto-Blacklist.

## Fitur
- **Auto Answer**: Menjawab otomatis berdasarkan huruf terakhir chat lawan.
- **Auto Blacklist**: Menghindari pengulangan kata yang sudah digunakan.
- **Human-like Delay**: Jeda waktu acak agar tidak langsung terdeteksi sebagai bot.
- **Simple GUI Support**: Mudah dinyalakan/dimatikan.

## Cara Pemasangan
1. Masukkan `KamusData.lua` ke dalam **ReplicatedStorage**.
2. Masukkan `MainScript.lua` ke dalam **StarterPlayerScripts**.
3. Buat sebuah tombol (TextButton) di ScreenGui, lalu tambahkan script berikut:
   ```lua
   script.Parent.MouseButton1Click:Connect(function()
       _G.ToggleAutoPlay()
   end)
   
