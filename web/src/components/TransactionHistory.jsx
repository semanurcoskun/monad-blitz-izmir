import { useState, useEffect } from 'react'
import axios from 'axios'

const API_BASE_URL = 'http://localhost:3000/api'

export default function TransactionHistory() {
  const [transactions, setTransactions] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchTransactions()
    // Refresh every 20 seconds
    const interval = setInterval(fetchTransactions, 20000)
    return () => clearInterval(interval)
  }, [])

  const fetchTransactions = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`${API_BASE_URL}/purchases/history`)
      if (response.data.purchases) {
        setTransactions(response.data.purchases)
      }
      setError(null)
    } catch (err) {
      setError('İşlemler yüklenemedi: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const formatDate = (timestamp) => {
    if (typeof timestamp === 'string') return timestamp
    return new Date(timestamp * 1000).toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    })
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-500 mx-auto"></div>
          <p className="text-gray-400 mt-4">İşlemler yükleniyor...</p>
        </div>
      </div>
    )
  }

  return (
    <div>
      {error && (
        <div className="bg-red-900 border border-red-700 text-red-100 px-4 py-3 rounded-lg mb-6">
          ⚠️ {error}
        </div>
      )}

      {transactions.length === 0 ? (
        <div className="bg-gray-800 rounded-lg p-12 text-center border border-gray-700">
          <p className="text-gray-400 text-lg">Henüz işlem bulunmuyor</p>
        </div>
      ) : (
        <>
          <div className="mb-6 p-4 bg-gradient-to-r from-green-900 to-emerald-900 rounded-lg border border-green-500">
            <p className="text-white font-semibold">📊 Toplam {transactions.length} İşlem</p>
            <p className="text-green-200 text-sm mt-1">Marketplace'de gerçekleştirilen tüm satın almalar</p>
          </div>

          <div className="space-y-3">
            {transactions.map((tx, idx) => (
              <div
                key={idx}
                className="bg-gray-800 border border-gray-700 rounded-lg p-4 hover:border-purple-500 transition-colors"
              >
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  {/* Token ID */}
                  <div>
                    <p className="text-gray-400 text-xs uppercase mb-1">Bilet (Token ID)</p>
                    <p className="text-white font-bold text-lg">#{tx.tokenId}</p>
                  </div>

                  {/* Fiyat */}
                  <div>
                    <p className="text-gray-400 text-xs uppercase mb-1">Fiyat</p>
                    <p className="text-green-400 font-bold text-lg">{tx.price} MON</p>
                  </div>

                  {/* Alıcı ve Satıcı */}
                  <div>
                    <p className="text-gray-400 text-xs uppercase mb-1">Alıcı → Satıcı</p>
                    <div className="space-y-1">
                      <p className="text-blue-400 font-mono text-xs">
                        ↓ {tx.buyer.substring(0, 6)}...{tx.buyer.substring(tx.buyer.length - 4)}
                      </p>
                      <p className="text-orange-400 font-mono text-xs">
                        ↑ {tx.seller.substring(0, 6)}...{tx.seller.substring(tx.seller.length - 4)}
                      </p>
                    </div>
                  </div>

                  {/* Tarih */}
                  <div>
                    <p className="text-gray-400 text-xs uppercase mb-1">İşlem Tarihi</p>
                    <p className="text-white text-sm">{formatDate(tx.timestamp)}</p>
                  </div>
                </div>

                {/* NFT Badge */}
                <div className="mt-3 flex items-center gap-2 text-purple-300 text-xs">
                  <span className="text-sm">✨</span>
                  <span>ERC-721 NFT Transaction</span>
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  )
}
