import { useState, useEffect } from 'react'
import axios from 'axios'
import TicketCard from './TicketCard'
import PurchaseModal from './PurchaseModal'

const API_BASE_URL = 'http://localhost:3000/api'

export default function MarketplaceList({ account }) {
  const [listings, setListings] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [selectedTicket, setSelectedTicket] = useState(null)
  const [showPurchaseModal, setShowPurchaseModal] = useState(false)

  useEffect(() => {
    fetchListings()
    // Refresh every 10 seconds
    const interval = setInterval(fetchListings, 10000)
    return () => clearInterval(interval)
  }, [])

  const fetchListings = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/marketplace/transactions`)
      if (response.data.transactions) {
        setListings(response.data.transactions)
      }
      setError(null)
    } catch (err) {
      setError('Biletler yüklenemedi: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handlePurchase = (ticket) => {
    setSelectedTicket(ticket)
    setShowPurchaseModal(true)
  }

  const handlePurchaseSuccess = () => {
    setShowPurchaseModal(false)
    fetchListings()
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-purple-500 mx-auto"></div>
          <p className="text-gray-400 mt-4">Biletler yükleniyor...</p>
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

      {listings.length === 0 ? (
        <div className="bg-gray-800 rounded-lg p-12 text-center">
          <p className="text-gray-400 text-lg">Henüz bilet bulunmuyor</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {listings.map((ticket) => (
            <TicketCard
              key={ticket.tokenId}
              ticket={ticket}
              onPurchase={handlePurchase}
              disabled={ticket.buyer === account}
            />
          ))}
        </div>
      )}

      {showPurchaseModal && selectedTicket && (
        <PurchaseModal
          ticket={selectedTicket}
          account={account}
          onClose={() => setShowPurchaseModal(false)}
          onSuccess={handlePurchaseSuccess}
        />
      )}
    </div>
  )
}
