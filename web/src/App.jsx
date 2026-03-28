import { useState, useEffect } from 'react'
import WalletConnect from './components/WalletConnect'
import MarketplaceList from './components/MarketplaceList'
import MyTickets from './components/MyTickets'
import TransactionHistory from './components/TransactionHistory'

function App() {
  const [account, setAccount] = useState(null)
  const [activeTab, setActiveTab] = useState('marketplace')

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      {/* Header */}
      <header className="border-b border-purple-500 bg-opacity-50 backdrop-blur">
        <div className="max-w-7xl mx-auto px-4 py-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-white">🎫 Monad Ticket</h1>
              <p className="text-purple-300 text-sm mt-1">Decentralized Ticketing on Monad</p>
            </div>
            <WalletConnect account={account} setAccount={setAccount} />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">
        {!account ? (
          <div className="bg-gradient-to-r from-purple-600 to-indigo-600 rounded-lg p-12 text-center">
            <h2 className="text-3xl font-bold text-white mb-4">Hoşgeldiniz! 👋</h2>
            <p className="text-purple-100 mb-6 text-lg">
              Monad blockchain üzerinde biletleri satın almak için lütfen cüzdanınızı bağlayın
            </p>
            <p className="text-purple-200 text-sm">Sağ üstte cüzdan bağla butonunu kullanın</p>
          </div>
        ) : (
          <>
            {/* Tabs */}
            <div className="flex gap-4 mb-8 border-b border-purple-500">
              <button
                onClick={() => setActiveTab('marketplace')}
                className={`px-6 py-3 font-semibold transition-all ${
                  activeTab === 'marketplace'
                    ? 'text-purple-400 border-b-2 border-purple-400'
                    : 'text-gray-400 hover:text-gray-300'
                }`}
              >
                🏪 Marketplace
              </button>
              <button
                onClick={() => setActiveTab('tickets')}
                className={`px-6 py-3 font-semibold transition-all ${
                  activeTab === 'tickets'
                    ? 'text-purple-400 border-b-2 border-purple-400'
                    : 'text-gray-400 hover:text-gray-300'
                }`}
              >
                🎟️ Kendi Biletlerim
              </button>
              <button
                onClick={() => setActiveTab('history')}
                className={`px-6 py-3 font-semibold transition-all ${
                  activeTab === 'history'
                    ? 'text-purple-400 border-b-2 border-purple-400'
                    : 'text-gray-400 hover:text-gray-300'
                }`}
              >
                📝 İşlem Geçmişi
              </button>
            </div>

            {/* Tab Content */}
            {activeTab === 'marketplace' && <MarketplaceList account={account} />}
            {activeTab === 'tickets' && <MyTickets account={account} />}
            {activeTab === 'history' && <TransactionHistory />}
          </>
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-purple-500 mt-12 py-6 text-center text-gray-400">
        <p>🚀 Monad Decentralized Ticket Marketplace | Build on Monad</p>
      </footer>
    </div>
  )
}

export default App
