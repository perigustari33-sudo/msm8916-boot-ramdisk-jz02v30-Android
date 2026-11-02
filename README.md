# boot jz02_v30 msm8916 chainfire su-patched 2.82 (su persistent), no magisk

# Watchdog `daemonsu` untuk Root yang Tahan `kill -9`

Catatan singkat tentang masalah `daemonsu` yang hanya berjalan sekali saat boot,
beserta solusinya memakai watchdog di `init.rc`.

## ⚠️ Peringatan

**Jangan coba-coba unpack/repack `boot.img` hasil patch Magisk untuk dikustomisasi lagi.**
Ini berlaku untuk semua versi Android.

Tetapi itu bukan inti masalah yang dibahas di sini.

## Permasalahan

Walaupun `su` berjalan sebagai daemon, jika di `init.rc` ditulis dengan `oneshot`,
proses tersebut **hanya dijalankan sekali saat boot**.

### Pembuktian

```sh
for k in $(busybox pgrep daemonsu); do
  kill -9 $k
done
```

Hasilnya: **akses root hilang** dan baru kembali setelah restart.

Jika disebut daemon, mengapa masih bisa di-`kill -9`? Karena tidak ada yang
mengawasi dan menghidupkannya kembali.

## Solusi

Buat **watchdog** yang mengawasi `daemonsu` yang sedang berjalan.

### 1. Skrip watchdog: `su_watch.sh`

```sh
while true; do
  if ! pgrep daemonsu >/dev/null 2>&1; then
    /system/xbin/daemonsu --auto-daemon
  fi
  sleep 5
done
```

Skrip mengecek setiap 5 detik. Jika `daemonsu` tidak ditemukan, skrip
menjalankannya kembali dengan `--auto-daemon`.

### 2. Daftarkan service di `init.rc`

```rc
service su_watch /system/bin/sh /sbin/su_watch.sh
    class main
    user root
```

> Pastikan `su_watch.sh` berada di `/sbin/` (ramdisk) dan dapat dibaca/dieksekusi
> oleh `/system/bin/sh`.

## Hasil

Setelah `daemonsu` di-`kill -9`, watchdog akan menjalankannya lagi dalam hitungan
detik, sehingga akses root kembali **tanpa perlu reboot**.

## Catatan

- Service `su_watch` sengaja **tidak** memakai `oneshot`, sehingga `init` akan
  me-restart watchdog itu sendiri bila ikut mati.
- Pastikan `pgrep` tersedia (bawaan sistem atau lewat `busybox`).
