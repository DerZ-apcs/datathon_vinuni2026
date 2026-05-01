#!/usr/bin/env python3
"""Quick checks to validate DATA_PATH and presence of key files."""
import os
import sys

DATA_PATH = os.environ.get('DATA_PATH', os.path.join(os.getcwd(), 'data'))

required = [
    'sample_submission.csv',
    'sales.csv',
    'train_features.parquet',
    'test_features.parquet',
    'feature_cols.json',
]

print(f'Checking DATA_PATH = {DATA_PATH}')
if not os.path.exists(DATA_PATH):
    print(f'  ERROR: DATA_PATH does not exist: {DATA_PATH}')
    sys.exit(2)

found = []
missing = []
for fn in required:
    p = os.path.join(DATA_PATH, fn)
    if os.path.exists(p):
        found.append(fn)
    else:
        missing.append(fn)

print(f'  Found:   {len(found)} files')
for f in found:
    print(f'    - {f}')
if missing:
    print(f'  Missing: {len(missing)} files')
    for f in missing:
        print(f'    - {f}')
    print('\nHints:')
    print('  - Place CSV files into the DATA_PATH (default ./data).')
    print('  - If you run notebooks in Colab, set the DATA_PATH env var to your Drive path:')
    print('      export DATA_PATH=/content/drive/MyDrive/…')
    sys.exit(1)

print('\nBasic sanity: show first 3 rows of sample_submission.csv')
try:
    import pandas as pd
    ss = pd.read_csv(os.path.join(DATA_PATH, 'sample_submission.csv'), parse_dates=['Date'])
    print(ss.head(3).to_string(index=False))
except Exception as e:
    print('  Failed to read sample_submission.csv:', e)
    sys.exit(3)

print('\nAll checks passed (files present and sample_submission.csv readable).')
