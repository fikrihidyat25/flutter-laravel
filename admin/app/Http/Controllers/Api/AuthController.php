<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'phone' => ['required', 'string', 'max:20', 'unique:users'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'message' => 'Registrasi berhasil!'
        ], 201)->header('Content-Type', 'application/json');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'message' => 'Login berhasil!'
        ])->header('Content-Type', 'application/json');
    }

    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email,' . $request->user()->id],
            'phone' => ['required', 'string', 'max:20', 'unique:users,phone,' . $request->user()->id],
        ]);

        $user = $request->user();
        $user->update([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
        ]);

        return response()->json([
            'user' => $user,
            'message' => 'Profile berhasil diperbarui!'
        ])->header('Content-Type', 'application/json');
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $user = $request->user();

        // Verify current password
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Password saat ini salah!'
            ], 422)->header('Content-Type', 'application/json');
        }

        // Update password
        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return response()->json([
            'message' => 'Password berhasil diubah!'
        ])->header('Content-Type', 'application/json');
    }


    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        
        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate([
            'phone' => ['required', 'string', 'exists:users,phone'],
        ]);

        $phone = $request->phone;
        
        // Generate OTP 6 digit
        $otp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        // Simpan OTP ke cache dengan expiry 10 menit
        Cache::put("otp_reset_{$phone}", $otp, now()->addMinutes(10));
        
        // TODO: Kirim OTP via SMS/WA Gateway
        // $this->sendSMS($phone, "Kode OTP Anda: {$otp}. Berlaku 10 menit. Jangan bagikan kode ini.");
        
        // Untuk development, log OTP ke console
        \Log::info("OTP for {$phone}: {$otp}");
        
        return response()->json([
            'message' => 'OTP berhasil dikirim ke nomor ' . $phone
        ])->header('Content-Type', 'application/json');
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'phone' => ['required', 'string', 'exists:users,phone'],
            'otp' => ['required', 'string', 'size:6'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);

        $phone = $request->phone;
        $otp = $request->otp;
        
        // Verifikasi OTP
        $storedOtp = Cache::get("otp_reset_{$phone}");
        
        if (!$storedOtp || $storedOtp !== $otp) {
            return response()->json([
                'message' => 'OTP tidak valid atau sudah expired'
            ], 422)->header('Content-Type', 'application/json');
        }
        
        // Update password user
        $user = User::where('phone', $phone)->first();
        $user->update([
            'password' => Hash::make($request->password),
        ]);
        
        // Hapus OTP dari cache
        Cache::forget("otp_reset_{$phone}");
        
        // Revoke semua token user (logout dari semua device)
        $user->tokens()->delete();
        
        return response()->json([
            'message' => 'Password berhasil direset! Silakan login dengan password baru.'
        ])->header('Content-Type', 'application/json');
    }
}