import preset from '../../../../vendor/filament/filament/tailwind.config.preset'
const colors = require('tailwindcss/colors');

export default {
    presets: [preset],
    content: [
        './app/Filament/**/*.php',
        './resources/views/filament/**/*.blade.php',
        './vendor/filament/**/*.blade.php',
    ],
    theme: {
        extend: {
            colors: {
                // Kamu bisa ganti warna ini sesuai keinginanmu
                primary: colors.amber, // Contoh: mengubah warna primary
                danger: colors.red,
                success: colors.green,
                warning: colors.yellow,
                // Kamu juga bisa tambahkan warna baru
                finote: {
                    50: '#F0FDF4',
                    100: '#DCFCE7',
                    200: '#BBF7D0',
                    300: '#86EFAC',
                    400: '#4ADE80',
                    500: '#22C55E', // Warna hijau Finote
                    600: '#16A34A',
                    700: '#15803D',
                    800: '#14532D',
                    900: '#052e16',
                },
            },
        },
    },
}