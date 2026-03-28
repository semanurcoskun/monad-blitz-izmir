import { useState } from 'react'
import axios from 'axios'
import { ethers } from 'ethers'

const API_BASE_URL = 'http://localhost:3000/api'

export default function PurchaseModal({ ticket, account, onClose, onSuccess }) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [txHash, setTxHash] = useState(null)
  const [success, setSuccess] = useState(false)

  const handlePurchase = async () => {
    try {
      setLoading(true)
      setError(null)

      // Bilet detaylarını doğrula
      const listingRes = await axios.get(
        `${API_BASE_URL}/marketplace/listing/${ticket.tokenId}`
      )
      const listing = listingRes.data.listing

      if (!listing.active) {
        setError('Bu bilet artık satışta değildir')
        return
      }

      if (listing.price !== ticket.price.toString()) {
        setError('Bilet fiyatı değişti. Lütfen sayfayı yenileyin.')
        return
      }

      // Satın alma işlemini gerçekleştir
      const purchaseRes = await axios.post(
        `${API_BASE_URL}/purchases/from-marketplace`,
        {
          buyerAddress: account,
          tokenId: ticket.tokenId,
          amount: ticket.price,
        }
      )

      if (purchaseRes.data.success) {
        setTxHash(purchaseRes.data.transactionHash)
        setSuccess(true)

        // 2 saniye sonra modal'ı kapat ve listeyi yenile
        setTimeout(() => {
          onSuccess()
        }, 2000)
      }
    } catch (err) {
      setError(err.response?.data?.details || err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
      <div className="bg-gray-900 rounded-lg shadow-2xl max-w-md w-full mx-4 overflow-hidden border border-purple-500">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-indigo-600 p-6">
          <h2 className="text-2xl font-bold text-white">🎫 Bilet Satın Al</h2>
          <p className="text-purple-100 text-sm mt-1">Monad Blockchain'de NFT olarak kaydedilecek</p>
        </div>

        {/* Content */}
        <div className="p-6 space-y-4">
          {success ? (
            <div className="text-center space-y-4">
              <div className="text-5xl">✅</div>
              <h3 className="text-xl font-bold text-white">Satın Alma Başarılı!</h3>
              <p className="text-gray-400">Bilet NFT olarak cüzdanınıza eklendi</p>

              {txHash && (
                <div className="bg-gray-800 rounded p-3 mt-4">
                  <p className="text-xs text-gray-400 mb-2">İşlem Hash:</p>
                  <p className="text-white font-mono text-xs break-all">{txHash}</p>
                </div>
              )}

              <button
                onClick={onClose}
                className="w-full py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-semibold transition-colors"
              >
                Kapat
              </button>
            </div>
          ) : (
            <>
              {/* Ticket Details */}
              <div className="bg-gray-800 rounded-lg p-4 space-y-3">
                <div className="flex justify-between">
                  <span className="text-gray-400">NFT Token ID:</span>
                  <span className="text-white font-bold">#{ticket.tokenId}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Fiyat:</span>
                  <span className="text-green-400 font-bold">{ticket.price} MON</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Satıcı:</span>
                  <span className="text-white font-mono text-xs">
                    {ticket.seller.substring(0, 6)}...{ticket.seller.substring(ticket.seller.length - 4)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Alıcı (Sen):</span>
                  <span className="text-white font-mono text-xs">
                    {account.substring(0, 6)}...{account.substring(account.length - 4)}
                  </span>
                </div>
              </div>

              {/* NFT Info */}
              <div className="bg-gradient-to-r from-purple-900 to-indigo-900 border border-purple-500 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <span className="text-2xl">✨</span>
                  <div>
                    <h4 className="font-bold text-purple-200 mb-1">NFT Olarak Saklanacak</h4>
                    <p className="text-purple-300 text-sm">
                      Bu bilet ERC-721 NFT olarak Monad blockchain'de kalıcı olarak kaydedilecektir. Transferini yapabilir veya pazarda satabilirsin.
                    </p>
                  </div>
                </div>
              </div>

              {/* Fee Info */}
              <div className="bg-gray-800 rounded p-3 text-center">
                <p className="text-gray-400 text-xs">Platform Ücreti: %5</p>
                <p className="text-gray-400 text-xs">Satıcı Alacağı: {(ticket.price * 0.95).toFixed(2)} MON</p>
              </div>

              {error && (
                <div className="bg-red-900 border border-red-700 text-red-100 px-4 py-3 rounded">
                  ⚠️ {error}
                </div>
              )}

              {/* Buttons */}
              <div className="flex gap-3">
                <button
                  onClick={onClose}
                  disabled={loading}
                  className="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg font-semibold transition-colors disabled:opacity-50"
                >
                  İptal
                </button>
                <button
                  onClick={handlePurchase}
                  disabled={loading}
                  className="flex-1 py-2 bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white rounded-lg font-semibold transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white"></div>
                      İşlem yapılıyor...
                    </>
                  ) : (
                    <>🛒 Satın Al ({ticket.price} MON)</>
                  )}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
