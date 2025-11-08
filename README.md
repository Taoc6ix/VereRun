# VereRun

Aplikasi **Running** bernama **VereRun** (Verenius Run) — dibuat khusus untuk sang maha pelari kalcer ini 😎. Tapi niatnya juga bakal dirilis ke **App Store** dan **Play Store** juga sih (#Ngarep 🫠🤌🏻). Intinya bikin aplikasi running sendiri sekalian ngetes ilmu **Flutter**.

Awalnya mau pakai **Laravel** buat backend, tapi kok overkill banget. Jadi untuk sekarang pakai **SQLite** aja dulu. Nanti kalau penggunanya udah miliaran alias lebih dari 1 😂, bakal migrasi ke **Firebase**.

---

## Fitur Saat Ini

- **Real-time Run Tracking**  
  Pantau jarak, Kalori, durasi dan pace secara langsung saat lari.

- **Riwayat Lari**  
  Semua sesi lari tersimpan rapi dengan detail.

- **UI Modern & Nyaman**  
  Desain clean, responsif, dan enak dilihat — bikin semangat lari tiap buka aplikasi! 😍

- **Aplikasi Ringan**
  Aplikasinya dibuat simple sehingga ringan untuk ram 2gb pun (untuk saat ini ya😂). Dengan optimize code nya agar lebih cantek dan singkat.

---

## Fitur yang Akan Datang

| Fitur |
|------|-----------|
| **Maps & Rute Lari** | Biar makin keren nantinya kasih maps dan rute lari. |
| **Audio Coaching** | Import Musik Kamu biar lari makin enjoy! |
| **Berbagai Mode Lari** | Interval, tempo run, long run, recovery — pilih sesuai target latihan. |
| **Save & Share Image** | Nantinya bisa Export image rute lari buat pamer di sosmed! 📸 |

---

## Preview

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; max-width: 600px;">
  <a href="https://www.imagebam.com/view/ME17IK83" target="_blank">
    <img src="https://thumbs4.imagebam.com/2f/47/c6/ME17IK83_t.png" alt="Screenshot 1" style="width: 100%; border-radius: 8px;"/>
  </a>
  <a href="https://www.imagebam.com/view/ME17IK82" target="_blank">
    <img src="https://thumbs4.imagebam.com/36/17/91/ME17IK82_t.png" alt="Screenshot 2" style="width: 100%; border-radius: 8px;"/>
  </a>
  <a href="https://www.imagebam.com/view/ME17IK81" target="_blank">
    <img src="https://thumbs4.imagebam.com/50/01/56/ME17IK81_t.png" alt="Screenshot 3" style="width: 100%; border-radius: 8px;"/>
  </a>
  <a href="https://www.imagebam.com/view/ME17IK80" target="_blank">
    <img src="https://thumbs4.imagebam.com/0a/6a/d5/ME17IK80_t.png" alt="Screenshot 4" style="width: 100%; border-radius: 8px;"/>
  </a>
</div>

---

## Cara Install & Jalankan

Setelah `git clone`, ikuti langkah berikut:

```bash
# 1. Masuk ke folder project
cd runningapp

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run
```

Nah udah bisa di run tuh app nya, tapi pastikan dulu:
- Versi NDK kamu 27+ karena ini memakai Geolocation dan sqflite yang butuh NDK 27.
- Abis itu cek apakah emulator kamu versi API 33+ (Seharusnya API dibawahnya bisa, namun saya nyoba pake emulator API 33 ga bisa jalan akhirnya pakai API 35).
