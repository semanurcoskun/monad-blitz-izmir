export default function NFTTicketCard({ ticket, onUse }) {
  const formatDate = (timestamp) => {
    if (typeof timestamp === 'string') return timestamp
    return new Date(timestamp * 1000).toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  return (
    <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-lg overflow-hidden border-2 border-purple-500 hover:shadow-lg hover:shadow-purple-500/30 transition-all duration-300">
      {/* NFT Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 p-4">
        <div className="flex items-center gap-3 mb-3">
          <span className="text-3xl">✨</span>
          <div>
            <h3 className="text-white font-bold">NFT Bilet</h3>
            <p className="text-purple-200 text-xs">ERC-721 Token</p>
          </div>
        </div>
        <div className="text-2xl font-bold text-white">#{ticket.tokenId}</div>
      </div>

      {/* Bilet Bilgileri */}
      <div className="p-4 space-y-3">
        {/* Event Info */}
        <div className="bg-gray-700 bg-opacity-40 rounded p-3">
          <p className="text-gray-400 text-xs uppercase mb-1">Etkinlik</p>
          <p className="text-white font-semibold">{ticket.eventName || 'Etkinlik Adı'}</p>
        </div>

        {/* Event Details Grid */}
        <div className="grid grid-cols-2 gap-2">
          <div className="bg-gray-700 bg-opacity-40 rounded p-3">
            <p className="text-gray-400 text-xs uppercase mb-1">Konum</p>
            <p className="text-white text-sm font-semibold">{ticket.eventLocation || 'TBD'}</p>
          </div>
          <div className="bg-gray-700 bg-opacity-40 rounded p-3">
            <p className="text-gray-400 text-xs uppercase mb-1">Koltuk</p>
            <p className="text-white text-sm font-semibold">{ticket.seatInfo || 'TBD'}</p>
          </div>
        </div>

        {/* Dates */}
        <div className="bg-gray-700 bg-opacity-40 rounded p-3">
          <p className="text-gray-400 text-xs uppercase mb-1">Etkinlik Tarihi</p>
          <p className="text-white text-sm">{ticket.eventDate || 'TBD'}</p>
        </div>

        {/* Purchase & Status Info */}
        <div className="grid grid-cols-2 gap-2">
          <div className="bg-gray-700 bg-opacity-40 rounded p-3">
            <p className="text-gray-400 text-xs uppercase mb-1">Fiyat</p>
            <p className="text-green-400 font-bold">{ticket.price} MON</p>
          </div>
          <div className={`rounded p-3 ${
            ticket.used
              ? 'bg-red-900 bg-opacity-40'
              : 'bg-green-900 bg-opacity-40'
          }`}>
            <p className="text-gray-400 text-xs uppercase mb-1">Durum</p>
            <p className={`font-bold text-sm ${
              ticket.used ? 'text-red-400' : 'text-green-400'
            }`}>
              {ticket.used ? '✅ Kullanıldı' : '🎫 Aktif'}
            </p>
          </div>
        </div>

        {/* Purchase Info */}
        <div className="bg-gray-700 bg-opacity-40 rounded p-3">
          <p className="text-gray-400 text-xs uppercase mb-1">Satın Alma Tarihi</p>
          <p className="text-white text-xs">{formatDate(ticket.purchaseTimestamp)}</p>
        </div>
      </div>

      {/* Action Button */}
      <div className="px-4 py-3 border-t border-gray-700">
        {ticket.used ? (
          <div className="w-full py-2 bg-gray-700 text-gray-400 rounded-lg text-center font-semibold">
            ✅ Bilet Kullanıldı
          </div>
        ) : (
          <button
            onClick={() => onUse(ticket.tokenId)}
            className="w-full py-2 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700 text-white rounded-lg font-semibold transition-all duration-200 hover:shadow-lg hover:shadow-blue-500/50"
          >
            🪪 Bilet Kullan (Giriş)
          </button>
        )}
      </div>
    </div>
  )
}
