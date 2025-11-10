# VereRun

Aplikasi **Running** bernama **VereRun** (Verenius Run) — dibuat untuk sang maha pelari kalcer. Tapi niatnya juga bakal dirilis ke **App Store** dan **Play Store** juga sih (#Ngarep 🫠🤌🏻). Intinya bikin aplikasi running sendiri sekalian ngetes ilmu **Flutter**.

Awalnya mau pakai **Laravel** buat backend, tapi kok overkill banget. Jadi untuk sekarang pakai **SQLite** aja dulu. Nanti kalau penggunanya udah miliaran alias lebih dari 1 😂, bakal migrasi ke **Firebase**.

---

Link download ada di paling bawah.

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

- **Maps & Rute Lari** : Biar makin keren nantinya kasih maps dan rute lari.
- **Music import** : Import Musik Kamu sendiri biar lari makin enjoy!
- **Berbagai Mode Lari** : Interval, tempo run, long run, recovery.
- **Save & Share Image** : Nantinya bisa Export image rute lari buat pamer di sosmed! 📸

---

## Preview 📱

| | |
| :---: | :---: |
| **Home Screen**<br><a href="https://www.imagebam.com/view/ME17IK83" target="_blank"><img src="https://images4.imagebam.com/51/fe/17/ME17IKMX_o.png" alt="Screenshot 1" width="300"/></a> | **Running Tracker**<br><a href="https://www.imagebam.com/view/ME17IK82" target="_blank"><img src="https://images4.imagebam.com/d4/13/31/ME17IK83_o.png" alt="Screenshot 2" width="300"/></a> |
| **Run Detail**<br><a href="https://www.imagebam.com/view/ME17IK81" target="_blank"><img src="https://images4.imagebam.com/97/38/f5/ME17IK82_o.png" alt="Screenshot 3" width="300"/></a> | **History**<br><a href="https://www.imagebam.com/view/ME17IK80" target="_blank"><img src="https://images4.imagebam.com/82/dc/b9/ME17IK80_o.png" alt="Screenshot 4" width="300"/></a> |

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


---

Link Download: 
