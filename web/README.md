# Monad Ticket Marketplace - Web UI

Decentralized ticket marketplace web arayüzü - React + Vite ile yapılmıştır.

## Özellikler

✅ **Marketplace** - Satışta olan biletleri görüntüle
✅ **Bilet Satın Al** - Monad cüzdanıyla NFT bilet satın al
✅ **NFT Yönetimi** - Kendi biletlerini yönet
✅ **Bilet Kullanma** - Etkinliğe giriş yap
✅ **İşlem Geçmişi** - Tüm işlemleri takip et
✅ **Cüzdan Entegrasyonu** - MetaMask bağlantısı

## Kurulum

### Sistem Gereksinimi

- Node.js 16+
- npm veya yarn

### 1. Bağımlılıkları Yükle

```bash
cd web
npm install
```

### 2. Sunucuyu Başlat

```bash
npm run dev
```

Web uygulaması şu adreste açılacaktır:

```
http://localhost:5173
```

## Özellik Açıklaması

### 🏪 Marketplace

- Satışta olan tüm biletleri listele
- Bilet detaylarını görüntüle
- Fiyat, satıcı bilgilerini kontrol et
- NFT token ID'sini gör

### 🛒 Satın Alma

- Bilet seç ve satın al
- Fiyat doğrulaması yap
- İşlemi Monad blockchain'de gerçekleştir
- Platform ücreti otomatik hesaplanan
- Bilet NFT olarak cüzdanına eklenir

### 🎫 NFT Biletlerim

- Satın aldığın tüm biletleri gör
- Bilet detaylarını incele
- Bilet durumunu kontrol et (aktif/kullanılmış)
- Etkinliğe giriş yap (bilet kullan)

### ✨ NFT Özellikleri

Her bilet şunları içerir:

- Etkinlik adı ve tarihi
- Konum ve koltuk bilgisi
- Satın alma tarihi
- ERC-721 NFT ID
- Blockchain'de kalıcı depolama

### 📊 İşlem Geçmişi

- Marketplace'de yapılan tüm işlemleri gör
- Alıcı ve satıcı bilgilerini kontrol et
- İşlem tarihini ve fiyatını gör
- NFT işlem dizisini takip et

## Cüzdan Bağlantısı

1. Sağ üstte "💰 Cüzdan Bağla" butonuna tıkla
2. MetaMask popupı açılacak
3. Cüzdanını seç ve onayla
4. Otomatik olarak Monad testnet'e geçilecek
5. Hazırsın! Biletleri satın almaya başla

### Monad Testnet Yapılandırması

- **RPC URL**: https://testnet-rpc.monad.xyz/
- **Chain ID**: 10143 (0x27af)
- **Ağ Adı**: Monad Testnet

## API Entegrasyonu

Web uygulaması şu backend API adresine bağlanır:

```
http://localhost:3000/api
```

### Kullanılan Endpoints

- `GET /marketplace/transactions` - Satışta olan biletler
- `GET /marketplace/listing/:tokenId` - Bilet detayları
- `POST /purchases/from-marketplace` - Satın alma
- `GET /tickets/user/:address` - Kullanıcı biletleri
- `POST /tickets/:tokenId/use` - Bilet kullanma
- `GET /purchases/history` - İşlem geçmişi

## Kullanılan Teknolojiler

- **React 18** - UI kütüphanesi
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Axios** - HTTP client
- **Ethers.js** - Web3 entegrasyonu
- **MetaMask** - Cüzdan bağlantısı

## Geliştirme

### Development Mode (Hot Reload)

```bash
npm run dev
```

### Production Build

```bash
npm run build
```

Build çıktısı `dist/` klasöründe oluşturulur.

### Preview Production Build

```bash
npm run preview
```

## Proje Yapısı

```
web/
├── src/
│   ├── components/
│   │   ├── WalletConnect.jsx        # Cüzdan bağlantısı
│   │   ├── MarketplaceList.jsx      # Bilet listesi
│   │   ├── TicketCard.jsx           # Bilet kartı
│   │   ├── PurchaseModal.jsx        # Satın alma modal'ı
│   │   ├── MyTickets.jsx            # Kendi biletlerim
│   │   ├── NFTTicketCard.jsx        # NFT bilet kartı
│   │   └── TransactionHistory.jsx   # İşlem geçmişi
│   ├── App.jsx                      # Ana component
│   ├── main.jsx                     # Entry point
│   └── index.css                    # Tailwind CSS
├── index.html                       # HTML template
├── package.json                     # Bağımlılıklar
├── vite.config.js                   # Vite config
├── tailwind.config.js               # Tailwind config
└── postcss.config.js                # PostCSS config
```

## Önemli Notlar

- ✅ Backend sunucusunun çalışıyor olması gerekir (localhost:3000)
- ✅ MetaMask uzantısı kurulu olmalı
- ✅ Monad testnet'te test MON token'ı olmalı
- ✅ Biletler ERC-721 NFT olarak blockchain'de saklanır
- ✅ İşlemler kalıcı ve geri dönüştürülemez

## Tarayıcı Desteği

- Chrome/Chromium ✅
- Firefox ✅
- Safari ✅
- Edge ✅

## Sorun Giderme

### "Biletler yüklenemedi"

- Backend sunucusunun çalışıp çalışmadığını kontrol et
- `http://localhost:3000/health` test et

### "Cüzdan bağlanmadı"

- MetaMask kurulu olduğundan emin ol
- Cüzdan kilitli değilse kontrol et
- Tarayıcıyı yenile

### "İşlem başarısız"

- Monad testnet'te yeterli MON token'ı var mı kontrol et
- Bilet hala satışta mı kontrol et
- Fiyat güncellenmedi mi kontrol et

## İletişim

Sorularınız veya önerileriniz için GitHub issues açın.

---

🚀 **Build on Monad!** - Merkeziyetsiz ticket pazarını keşfet!
