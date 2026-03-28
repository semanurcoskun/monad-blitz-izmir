from fastapi import FastAPI
import argparse
import numpy as np
import pandas as pd
import uvicorn

app = FastAPI(title="Monad Blitz İzmir - Uçuş API")


def randomize_date_of_journey(
    file_path: str = "Cleaned_dataset.csv",
    months_ahead: int = 3,
    encoding: str = "windows-1254",
):
    df = pd.read_csv(file_path, sep=";", encoding=encoding)
    df.columns = df.columns.str.strip()

    if "Date_of_journey" not in df.columns:
        raise ValueError("Date_of_journey sütunu bulunamadı.")

    # Bugünden başlayarak sonraki 3 ay içindeki tarihleri rastgele üret.
    start_date = pd.Timestamp.today().normalize()
    end_date = start_date + pd.DateOffset(months=months_ahead)
    day_span = (end_date - start_date).days

    random_days = np.random.randint(0, day_span + 1, size=len(df))
    randomized_dates = pd.Series(
        start_date + pd.to_timedelta(random_days, unit="D"), index=df.index
    )

    df["Date_of_journey"] = randomized_dates.dt.strftime("%d.%m.%Y")

    # Tutarlılık için ilişkili alanları da güncelle.
    if "Journey_day" in df.columns:
        df["Journey_day"] = randomized_dates.dt.day_name()
    if "Days_left" in df.columns:
        df["Days_left"] = (randomized_dates - start_date).dt.days.astype(int)

    df.to_csv(file_path, sep=";", index=False, encoding=encoding)
    print(
        f"✅ {len(df)} satır için Date_of_journey sonraki {months_ahead} aya rastgele güncellendi."
    )


# 1. Veriyi Yükleme ve Temizleme Fonksiyonu
def load_and_clean_data():
    try:
        # Önce hata aldığın encoding ile açıyoruz
        df = pd.read_csv("Cleaned_dataset.csv", sep=";", encoding="windows-1254")

        # Sütun isimlerindeki boşlukları temizleyelim (Architect dokunuşu)
        df.columns = df.columns.str.strip()

        # Sayısal verilerdeki (Duration_in_hours gibi) bozuk karakterleri temizleme
        if "Duration_in_hours" in df.columns:
            df["Duration_in_hours"] = pd.to_numeric(
                df["Duration_in_hours"], errors="coerce"
            )

        print("✅ Veri başarıyla yüklendi ve temizlendi.")
        return df
    except Exception as e:
        print(f"❌ Veri yükleme hatası: {e}")
        return None


# Global değişken olarak dataframe'i tanımla
flight_df = load_and_clean_data()


@app.get("/")
def home():
    return {"message": "Uçuş API Çalışıyor. Dokümantasyon için /docs adresine gidin."}


# 2. Uçuşları Listeleme, Gelişmiş Filtreleme ve Sıralama
@app.get("/flights")
def get_flights(
    source: str = None,
    destination: str = None,
    airline: str = None,
    date: str = None,
    min_price: float = None,
    max_price: float = None,
    sort_by: str = None,
):
    global flight_df

    if flight_df is None:
        return {"error": "Dataset yüklenemedi."}

    filtered = flight_df.copy()

    # --- 1. METİN TABANLI FİLTRELER ---
    if source:
        filtered = filtered[
            filtered["Source"].str.contains(source, case=False, na=False)
        ]
    if destination:
        filtered = filtered[
            filtered["Destination"].str.contains(destination, case=False, na=False)
        ]
    if airline:
        filtered = filtered[
            filtered["Airline"].str.contains(airline, case=False, na=False)
        ]

    # --- 2. TARİH FİLTRESİ (Date_of_journey) ---
    if date and "Date_of_journey" in filtered.columns:
        filtered = filtered[
            filtered["Date_of_journey"].str.contains(date, case=False, na=False)
        ]

    # --- 3. FİYAT FİLTRELERİ (Fare) ---
    if min_price is not None and "Fare" in filtered.columns:
        filtered = filtered[filtered["Fare"] >= min_price]

    if max_price is not None and "Fare" in filtered.columns:
        filtered = filtered[filtered["Fare"] <= max_price]

    # --- 4. SIRALAMA (SORTING) ---
    if sort_by:
        if sort_by == "price_asc" and "Fare" in filtered.columns:
            filtered = filtered.sort_values(
                by="Fare", ascending=True
            )  # Ucuzdan pahalıya
        elif sort_by == "price_desc" and "Fare" in filtered.columns:
            filtered = filtered.sort_values(
                by="Fare", ascending=False
            )  # Pahalıdan ucuza
        elif sort_by == "duration_asc" and "Duration_in_hours" in filtered.columns:
            filtered = filtered.sort_values(
                by="Duration_in_hours", ascending=True
            )  # En kısa uçuşlar

    # Filtreleme sonucu elimizde hiç veri kalmadıysa
    if filtered.empty:
        return {"error": "Belirtilen kriterlere uygun uçuş bulunamadı."}

    # Mobil tarafı kasmaması için ilk 50 kaydı al ve JSON'ı çökerten NaN değerleri None yap
    clean_result = filtered.head(50).replace({np.nan: None})

    # Temizlenmiş veriyi sözlük formatında (JSON) döndür
    return clean_result.to_dict(orient="records")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--randomize-dates",
        action="store_true",
        help="Date_of_journey sütununu bugünden sonraki 3 ay içinde rastgele tarihlerle günceller.",
    )
    args = parser.parse_args()

    if args.randomize_dates:
        randomize_date_of_journey()
    else:
        # Uygulamayı başlat
        uvicorn.run(app, host="127.0.0.1", port=8000)
