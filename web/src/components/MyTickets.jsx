import { useState, useEffect } from 'react'
import axios from 'axios'
import NFTTicketCard from './NFTTicketCard'

const API_BASE_URL = 'http://localhost:3000/api'

export default function MyTickets({ account }) {
  const [tickets, setTickets] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchMyTickets()
    // Refresh every 15 seconds
    const interval = setInterval(fetchMyTickets, 15000)
    return () => clearInterval(interval)
  }, [account])

  const fetchMyTickets = async () => {
    try {
      setLoading(true)
      const response = await axios.get(`${API_BASE_URL}/tickets/user/${account}`)
      if (response.data.tickets) {
        setTickets(response.data.tickets)
      }
      setError(null)
    } catch (err) {
      setError('Biletler yüklenemedi: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const handleUseTicket = async (tokenId) => {
    try {
      await axios.post(`${API_BASE_URL}/tickets/${tokenId}/use`)
      fetchMyTickets()
    } catch (err) {
      console.error('Bilet kullanılamadı:', err)
    }
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

      {tickets.length === 0 ? (
        <div className="bg-gray-800 rounded-lg p-12 text-center border border-gray-700">
          <p className="text-gray-400 text-lg mb-2">Henüz biletiniz yok</p>
          <p className="text-gray-500 text-sm">Marketplace'ten bilet satın almaya başla!</p>
        </div>
      ) : (
        <>
          <div className="mb-4 p-4 bg-gradient-to-r from-purple-900 to-indigo-900 rounded-lg border border-purple-500">
            <p className="text-white font-semibold">📊 {tickets.length} NFT Biletiniz Var</p>
            <p className="text-purple-200 text-sm mt-1">Tüm biletleriniz ERC-721 NFT olarak blockchain'de güvendedir</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {tickets.map((ticket) => (
              <NFTTicketCard
                key={ticket.tokenId}
                ticket={ticket}
                onUse={handleUseTicket}
              />
            ))}
          </div>
        </>
      )}
    </div>
  )
}
