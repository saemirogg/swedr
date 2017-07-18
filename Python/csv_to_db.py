"""
This script, quite crudely, deletes all the tables in database and
overwrites them with data from csv files. This is intended for the
initial setup of the database. Also, it will take a while before
it finishes with several GBs of data.
"""

import os
import csv
from config import database, datadir
from sqlalchemy.orm import sessionmaker
from database.tools import init_engine
from database.models import (Base, Participant, Case,
                             Control, Can, Dors, Sv, Ov)
import pandas as pd
import numpy as np
from df_functions import extract_unique_values, int_or_null

# Create engine
engine = init_engine(database["username"],
                     database["password"],
                     database["dbname"])

# Delete all children tables
tables = [
    Control,
    Case,
    Dors,
    Can,
    Ov,
    Sv
]

for table in tables:
    if engine.has_table(table.__tablename__):
        table.__table__.drop(bind=engine)

# Finally, the parent table
if engine.has_table("participant"):
    Participant.__table__.drop(bind=engine)

# Open a session
Base.metadata.create_all(engine)
Base.prepare(engine)
Session = sessionmaker(engine)
session = Session()
session.close()

# We need a table with all unique lop numbers to use relationships in SQL.
# This will be the participant master table, collecting all individuals. We
# will call it "participant". The table will serve as a hub connecting
# all tables together. First, create empty participants df.
participants = pd.DataFrame({"lopnr": []})

# Add cases, controls, can, dors, ov and sv
cases = os.path.join(datadir, "cases.csv")
controls = os.path.join(datadir, "controls.csv")
can = os.path.join(datadir, "can.csv")
dors = os.path.join(datadir, "dors.csv")
ov = os.path.join(datadir, "ov.csv")
sv = os.path.join(datadir, "sv.csv")
# Add cases
participants = extract_unique_values(
    cases, "Lopnr_fall",
    participants, "lopnr")
# Add controls
participants = extract_unique_values(
    controls, "Lopnr_kontroll",
    participants, "lopnr")
# Add other tables
for fname in [can, dors, ov, sv]:
    participants = extract_unique_values(
        fname, "LopNr",
        participants, "lopnr",
        nrows=100000)

# Create the table in MySQL database
participants.to_sql("participant", engine, if_exists="append",
                    chunksize=2**8, index=False)

# Load all the data into dataframes
df_controls = pd.read_csv(controls)
df_cases = pd.read_csv(cases)
df_ov = pd.read_csv(ov, nrows=100000)
df_sv = pd.read_csv(sv, nrows=100000)
df_can = pd.read_csv(can, nrows=100000)
df_dors = pd.read_csv(dors, nrows=100000, encoding="latin-1")
dfs = {
    "case": df_cases,
    "control": df_controls,
    "ov": df_ov,
    "sv": df_sv,
    "can": df_can,
    "dors": df_dors
    }

# Change column names to fit with database models in sqlalchemy
cols = list(df_controls.columns)
cols[0] = "participant_lopnr"
cols[1] = "case_lopnr"
df_controls.columns = cols
for name, df in dfs.items():
    if name is not "control":
        cols = [val.lower() for val in df.columns[1:]]
        df.columns = ["participant_lopnr"] + cols

# Weird non-numeric entries need to be NULL.
df_sv.sjukhus = df_sv.sjukhus.apply(int_or_null).astype(float)
df_ov.sjukhus = df_ov.sjukhus.apply(int_or_null).astype(float)
df_can.klinik = df_can.klinik.apply(int_or_null)

# Upload everything to MySQL db. Case first,
# to respect ForeignKey constraints.
df_cases.to_sql("case", engine, if_exists="append",
                chunksize=2**8, index=False)
# Now the rest
for name, df in dfs.items():
    if name is not "case":
        df.to_sql(name, engine, if_exists="append",
                  chunksize=2**8, index=False)
