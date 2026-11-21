"""Builds hr.db (SQLite) from HRDataset_v14.csv with cleaned text and ISO dates."""
import pandas as pd, sqlite3
df = pd.read_csv('HRDataset_v14.csv')
for c in df.select_dtypes(include=['object', 'string']).columns:
    df[c] = df[c].str.strip()
for c in ['DateofHire', 'DateofTermination']:
    df[c] = pd.to_datetime(df[c]).dt.strftime('%Y-%m-%d')
df = df.rename(columns={'Termd': 'Left'})
con = sqlite3.connect('hr.db')
df.to_sql('employees', con, if_exists='replace', index=False)
print('employees table:', len(df), 'rows')
