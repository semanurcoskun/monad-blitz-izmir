export default function TicketCard({ ticket, onPurchase, disabled }) {
  const formatDate = (timestamp) => {
    if (typeof timestamp === 'string') return timestamp
    return new Date(timestamp * 1000).toLocaleDateString('tr-TR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  return (
    <div className="bg-gradient-to-br from-gray-800 to-gray-900 rounded-lg overflow-hidden hover:shadow-xl hover:shadow-purple-500/20 transition-all duration-300 border border-gray-700 hover:border-purple-500">
      {/* Card Header */}
      <div className="bg-gradient-to-r from-purple-600 to-indigo-600 p-4">
        <div className="flex items-start justify-between">
          <div>
            <h3 className="text-xl font-bold text-white mb-1">🎪 Etkinlik</h3>
            <p className="text-purple-100 text-sm">NFT ID: #{ticket.tokenId}</p>
          </div>
          <div className="bg-white bg-opacity-20 px-3 py-1 rounded-full">
            <p className="text-white font-bold text-sm">{ticket.price} MON</p>
          </div>
        </div>
      </div>

      {/* NFT Badge */}
      <div className="px-4 pt-4">
        <div className="bg-gradient-to-r from-purple-900 to-indigo-900 border border-purple-500 rounded-lg p-3 mb-4">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-2xl">✨</span>
            <span className="text-sm font-semibold text-purple-200">NFT Ticket</span>
          </div>
          <p className="text-xs text-purple-300">Bu bilet ERC-721 NFT olarak blockchain'de depolanmıştır</p>
        </div>
      </div>

      {/* Card Details */}
      <div className="px-4 py-3 space-y-3">
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-gray-700 bg-opacity-40 rounded p-3">
            <p className="text-gray-400 text-xs uppercase tracking-wide">Satıcı</p>
            <p className="text-white font-mono text-xs mt-1">
              {ticket.seller.substring(0, 6)}...{ticket.seller.substring(ticket.seller.length - 4)}
            </p>
          </div>
          <div className="bg-gray-700 bg-opacity-40 rounded p-3">
            <p className="text-gray-400 text-xs uppercase tracking-wide">Fiyat</p>
            <p className="text-purple-400 font-bold text-sm mt-1">{ticket.price} MON</p>
          </div>
        </div>

        <div className="bg-gray-700 bg-opacity-40 rounded p-3">
          <p className="text-gray-400 text-xs uppercase tracking-wide">Tarih</p>
          <p className="text-white text-sm mt-1">{formatDate(ticket.timestamp)}</p>
        </div>
      </div>

      {/* Purchase Button */}
      <div className="px-4 py-4 border-t border-gray-700">
        <button
          onClick={() => onPurchase(ticket)}
          disabled={disabled}
          className={`w-full py-3 rounded-lg font-bold transition-all duration-200 ${
            disabled
              ? 'bg-gray-700 text-gray-500 cursor-not-allowed'
              : 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white cursor-pointer hover:shadow-lg hover:shadow-purple-500/50'
          }`}
        >
          {disabled ? '❌ Kendi Biletiniz' : '🛒 Satın Al'}
        </button>
      </div>
    </div>
  )
}
