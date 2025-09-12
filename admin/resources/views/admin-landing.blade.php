<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Finote Admin Panel</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-br from-green-50 to-blue-50 min-h-screen">
    <div class="container mx-auto px-4 py-16">
        <!-- Header -->
        <div class="text-center mb-12">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-green-500 rounded-full mb-6">
                <i class="fas fa-chart-line text-white text-3xl"></i>
            </div>
            <h1 class="text-4xl font-bold text-gray-800 mb-4">Finote Admin Panel</h1>
            <p class="text-xl text-gray-600 max-w-2xl mx-auto">
                Kelola data transaksi, hutang, dan pengguna dengan mudah melalui panel administrasi yang powerful.
            </p>
        </div>

        <!-- Features Grid -->
        <div class="grid md:grid-cols-3 gap-8 mb-12">
            <div class="bg-white rounded-lg shadow-lg p-6 text-center hover:shadow-xl transition-shadow">
                <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-users text-blue-500 text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-800 mb-2">User Management</h3>
                <p class="text-gray-600">Kelola data pengguna, edit profil, dan pantau aktivitas pengguna.</p>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-6 text-center hover:shadow-xl transition-shadow">
                <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-exchange-alt text-green-500 text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-800 mb-2">Transaction Management</h3>
                <p class="text-gray-600">Pantau semua transaksi keuangan, pendapatan, dan pengeluaran.</p>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-6 text-center hover:shadow-xl transition-shadow">
                <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <i class="fas fa-credit-card text-red-500 text-2xl"></i>
                </div>
                <h3 class="text-xl font-semibold text-gray-800 mb-2">Debt Management</h3>
                <p class="text-gray-600">Kelola data hutang, status pembayaran, dan laporan hutang.</p>
            </div>
        </div>

        <!-- API Status -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-8">
            <h3 class="text-xl font-semibold text-gray-800 mb-4 flex items-center">
                <i class="fas fa-server text-green-500 mr-2"></i>
                API Status
            </h3>
            <div class="grid md:grid-cols-2 gap-4">
                <div class="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                    <span class="text-gray-700">Backend API</span>
                    <span class="text-green-600 font-semibold flex items-center">
                        <i class="fas fa-check-circle mr-1"></i>
                        Online
                    </span>
                </div>
                <div class="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                    <span class="text-gray-700">Database</span>
                    <span class="text-green-600 font-semibold flex items-center">
                        <i class="fas fa-check-circle mr-1"></i>
                        Connected
                    </span>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="text-center">
            <a href="/administrator" 
               class="inline-flex items-center px-8 py-4 bg-green-500 hover:bg-green-600 text-white font-semibold rounded-lg shadow-lg hover:shadow-xl transition-all duration-200 transform hover:scale-105">
                <i class="fas fa-sign-in-alt mr-2"></i>
                Masuk ke Admin Panel
            </a>
            
            <div class="mt-6 space-x-4">
                <a href="/api/login" 
                   class="inline-flex items-center px-6 py-2 bg-blue-500 hover:bg-blue-600 text-white font-medium rounded-lg transition-colors">
                    <i class="fas fa-code mr-2"></i>
                    API Endpoints
                </a>
                <a href="https://laravel.com/docs" 
                   target="_blank"
                   class="inline-flex items-center px-6 py-2 bg-gray-500 hover:bg-gray-600 text-white font-medium rounded-lg transition-colors">
                    <i class="fas fa-book mr-2"></i>
                    Documentation
                </a>
            </div>
        </div>

        <!-- Footer -->
        <div class="text-center mt-16 text-gray-500">
            <p>&copy; 2025 Finote Admin Panel. Powered by Laravel & Filament.</p>
        </div>
    </div>

    <script>
        // Auto refresh API status every 30 seconds
        setInterval(function() {
            fetch('/api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: '123456'
                })
            })
            .then(response => {
                const statusElement = document.querySelector('.bg-green-50 .text-green-600');
                if (response.ok) {
                    statusElement.innerHTML = '<i class="fas fa-check-circle mr-1"></i>Online';
                    statusElement.className = 'text-green-600 font-semibold flex items-center';
                } else {
                    statusElement.innerHTML = '<i class="fas fa-exclamation-circle mr-1"></i>Offline';
                    statusElement.className = 'text-red-600 font-semibold flex items-center';
                }
            })
            .catch(() => {
                const statusElement = document.querySelector('.bg-green-50 .text-green-600');
                statusElement.innerHTML = '<i class="fas fa-exclamation-circle mr-1"></i>Offline';
                statusElement.className = 'text-red-600 font-semibold flex items-center';
            });
        }, 30000);
    </script>
</body>
</html>















