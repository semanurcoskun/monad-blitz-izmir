from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
import datetime

# --- 1. FIREBASE BAĞLANTISI ---
# Firebase konsolundan indirdiğin Service Account JSON dosyasının yolunu buraya yazmalısın
# (Geliştirme aşamasında bu dosyayı github'a pushlamamaya çok dikkat et!)
cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI(title="Monad Blitz İzmir - İşlem API")


# --- 2. VERİ MODELLERİ (Mobil'den gelecek isteğin yapısı) ---
class ReserveRequest(BaseModel):
    flight_id: str
    seat_id: str
    user_id: str  # Cüzdan adresi veya Firebase Auth UID olabilir


# --- 3. TRANSACTION FONKSİYONU (İşin Kalbi) ---
# @firestore.transactional dekoratörü sayesinde bu fonksiyon aynı anda sadece bir kez çalıştırılabilir.
# Veri okunduğu an ile yazıldığı an arasında başka biri veriyi değiştirirse işlem iptal olur/başa sarar.
@firestore.transactional
def lock_seat_transaction(transaction, seat_ref, user_id):
    # Koltuğun güncel anlık durumunu oku
    snapshot = seat_ref.get(transaction=transaction)

    if not snapshot.exists:
        raise HTTPException(status_code=404, detail="Böyle bir koltuk bulunamadı.")

    seat_data = snapshot.to_dict()
    status = seat_data.get("status")
    locked_until = seat_data.get("locked_until")

    # Şu anki zamanı UTC olarak alıyoruz
    now = datetime.datetime.now(datetime.timezone.utc)

    # KONTROL 1: Koltuk zaten satılmış mı?
    if status == "sold":
        raise HTTPException(status_code=400, detail="Maalesef bu koltuk satılmış.")

    # KONTROL 2: Koltuk şu an başkası tarafından inceleniyor/alınıyor mu?
    # Eğer kilitliyse ve kilit süresi henüz dolmadıysa izin verme
    if status == "locked" and locked_until and locked_until > now:
        raise HTTPException(
            status_code=400,
            detail="Koltuk şu an başka bir kullanıcı tarafından rezerve ediliyor.",
        )

    # HER ŞEY YOLUNDA: Koltuğu bu kullanıcı için 10 dakikalığına kilitle
    lock_time = now + datetime.timedelta(minutes=10)

    transaction.update(
        seat_ref, {"status": "locked", "locked_by": user_id, "locked_until": lock_time}
    )

    return lock_time


# --- 4. API ENDPOINT (Flutter'ın istek atacağı yer) ---
@app.post("/reserve-seat")
def reserve_seat(req: ReserveRequest):
    # Firestore'daki döküman yolunu belirliyoruz (Flights -> uçuş -> Seats -> koltuk)
    seat_ref = (
        db.collection("Flights")
        .document(req.flight_id)
        .collection("Seats")
        .document(req.seat_id)
    )

    # Transaction için bir Firestore istemcisi oluştur ve fonksiyonu tetikle
    transaction = db.transaction()

    try:
        lock_expiry = lock_seat_transaction(transaction, seat_ref, req.user_id)
        return {
            "success": True,
            "message": "Koltuk başarıyla kilitlendi. Ödeme için 10 dakikanız var.",
            "locked_until": lock_expiry,
        }
    except Exception as e:
        # Transaction içinde fırlattığımız HTTPException'ları yakalayıp döndürüyoruz
        raise HTTPException(status_code=400, detail=str(e))
