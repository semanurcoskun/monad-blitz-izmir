import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import numpy as np
import os
import json

# Setup
SERVICE_ACCOUNT_PATH = 'mobile-blockchain-system-firebase-adminsdk-fbsvc-c8611e42eb.json'
CSV_PATH = 'Cleaned_dataset.csv'

def to_title_case(text):
    if not isinstance(text, str): return text
    return ' '.join([word.capitalize() for word in text.split()])

def seed_data():
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f"Error: {SERVICE_ACCOUNT_PATH} not found.")
        return

    # Initialize Firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("Reading CSV (first 5000 rows)...")
    try:
        df = pd.read_csv(CSV_PATH, sep=';', encoding='windows-1254', nrows=5000)
    except Exception as e:
        print(f"Error reading CSV: {e}")
        return

    # Clean column names
    df.columns = df.columns.str.strip()

    print("Normalizing data and randomizing dates...")
    
    # 1. Title Case normalization for reliable search
    if 'Source' in df.columns:
        df['Source'] = df['Source'].apply(to_title_case)
    if 'Destination' in df.columns:
        df['Destination'] = df['Destination'].apply(to_title_case)
    
    # Keep original Date_of_journey from CSV. 
    # The CSV format is already dd.MM.yyyy (e.g., 16.01.2027)
    
    # Ensure numeric values
    df['Fare'] = pd.to_numeric(df['Fare'], errors='coerce')
    df['Duration_in_hours'] = pd.to_numeric(df['Duration_in_hours'], errors='coerce')
    
    # Days_left calculation based on today
    today = pd.Timestamp.today().normalize()
    # Try to parse original Date_of_journey and calculate actual days left
    try:
        journal_dates = pd.to_datetime(df['Date_of_journey'], format='%d.%m.%Y', errors='coerce')
        df['Days_left'] = (journal_dates - today).dt.days
    except:
        df['Days_left'] = pd.to_numeric(df['Days_left'], errors='coerce')

    # Replace NaN with None
    df = df.where(pd.notnull(df), None)

    collection_name = 'routes'
    batch = db.batch()
    count = 0
    total_uploaded = 0

    print(f"Uploading to '{collection_name}' collection...")
    
    for _, row in df.iterrows():
        doc_ref = db.collection(collection_name).document()
        data = row.to_dict()
        
        # Ensure correct types
        if data.get('Fare') is not None:
            data['Fare'] = float(data['Fare'])
        if data.get('Duration_in_hours') is not None:
            data['Duration_in_hours'] = float(data['Duration_in_hours'])
        if data.get('Days_left') is not None:
            data['Days_left'] = int(data['Days_left'])

        batch.set(doc_ref, data)
        count += 1
        total_uploaded += 1

        if count >= 400:
            batch.commit()
            print(f"Uploaded {total_uploaded} rows...")
            batch = db.batch()
            count = 0

    if count > 0:
        batch.commit()
    
    print(f"Successfully uploaded {total_uploaded} routes with normalized data to Firestore!")

if __name__ == '__main__':
    seed_data()
