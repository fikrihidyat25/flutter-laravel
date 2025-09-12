# Spesifikasi API

Dokumen ini merangkum autentikasi, endpoint umum, dan skema respons yang digunakan bersama oleh modul Admin dan Aplikasi User.

## Autentikasi
- Skema umum: Bearer Token (JWT) atau Session (sesuaikan implementasi)
- Header: `Authorization: Bearer <token>`
- Mendapatkan token: melalui endpoint login

## Konvensi
- Base URL: `https://api.example.com` (sesuaikan di lingkungan)
- Format respons umum:
```json
{
  "success": true,
  "message": "",
  "data": {}
}
```
- Error standar:
```json
{
  "success": false,
  "message": "invalid_credentials",
  "errors": {}
}
```

## Endpoint

### POST /v1/auth/login
- Deskripsi: Autentikasi pengguna untuk mendapatkan token
- Body:
```json
{ "email": "string", "password": "string" }
```
- 200:
```json
{ "token": "<jwt>" }
```
- 401:
```json
{ "success": false, "message": "invalid_credentials" }
```

### GET /v1/items
- Query: `page` (number), `limit` (number)
- 200:
```json
{ "data": [], "page": 1, "total": 0 }
```

### GET /v1/profile
- Header: `Authorization: Bearer <token>`
- 200:
```json
{ "id": 1, "name": "User", "email": "user@example.com" }
```

> Lengkapi daftar endpoint sesuai modul aktual (CRUD, upload, dsb.).

## Versi & Deprekasi
- Versi API: `v1`
- Perubahan breaking: komunikasikan di `CHANGELOG.md` dan beri masa deprekasi



