import { useState } from 'react'
import { ethers } from 'ethers'

export default function WalletConnect({ account, setAccount }) {
  const [connecting, setConnecting] = useState(false)
  const [error, setError] = useState(null)

  const connectWallet = async () => {
    try {
      setConnecting(true)
      setError(null)

      if (!window.ethereum) {
        setError('MetaMask yüklü değil. Lütfen Meta Mask uzantısını yükleyin.')
        return
      }

      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })

      setAccount(accounts[0])

      // Switch to Monad testnet if not already on it
      try {
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x27af' }], // 10143 in hex
        })
      } catch (e) {
        if (e.code === 4902) {
          // Chain not added yet
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [
              {
                chainId: '0x27af',
                chainName: 'Monad Testnet',
                rpcUrls: ['https://testnet-rpc.monad.xyz/'],
                nativeCurrency: {
                  name: 'Monad',
                  symbol: 'MON',
                  decimals: 18,
                },
                blockExplorerUrls: ['https://testnet-explorer.monad.xyz/'],
              },
            ],
          })
        }
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setConnecting(false)
    }
  }

  const disconnectWallet = () => {
    setAccount(null)
    setError(null)
  }

  if (account) {
    return (
      <div className="flex items-center gap-3">
        <div className="text-right">
          <p className="text-sm text-gray-400">Bağlı Cüzdan</p>
          <p className="text-white font-mono">
            {account.substring(0, 6)}...{account.substring(account.length - 4)}
          </p>
        </div>
        <button
          onClick={disconnectWallet}
          className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg transition-colors"
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-2">
      <button
        onClick={connectWallet}
        disabled={connecting}
        className="px-6 py-2 bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 text-white rounded-lg font-semibold transition-all disabled:opacity-50"
      >
        {connecting ? 'Bağlanıyor...' : '💰 Cüzdan Bağla'}
      </button>
      {error && <p className="text-red-400 text-sm">{error}</p>}
    </div>
  )
}
