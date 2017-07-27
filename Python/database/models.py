#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 17 16:25:06 2017
@author: manje

TODO:
- Find and implenent all relationships to optimize query speed.
- Update docstrings to explain all variables.
"""

from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base, DeferredReflection
from sqlalchemy import (Column, Integer, Boolean,
                        DateTime, Date, String, Numeric,
                        ForeignKey)

Base = declarative_base(cls=DeferredReflection)


class Participant(Base):
    """
    participant
    -----------
    Contains all unique lopnrs in cohort.

    Inputs:
    - lopnr
    """

    __tablename__ = "participant"

    lopnr = Column(Integer, primary_key=True)

    cases = relationship("Case", back_populates="participant")
    controls = relationship("Control", back_populates="participant")
    dors = relationship("Dors", back_populates="participant")
    cans = relationship("Can", back_populates="participant")
    ovs = relationship("Ov", back_populates="participant")
    svs = relationship("Sv", back_populates="participant")


class Control(Base):
    """
    Control
    -------
    All controls in Swedish db.

    Inputs:
    - lopnr: Study ID
    - case_lopnr: Study ID of matched case.
    - foddar_fall: Year of birth of matched case.
    - foddar_kontroll: Year of birth of control.
    - kon: Sex {"1": "male", "2": "female"}
    """

    __tablename__ = "control"

    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer, ForeignKey("participant.lopnr"))
    case_lopnr = Column(Integer, ForeignKey("case.participant_lopnr"))

    foddar_fall = Column(Integer)
    foddar_kontroll = Column(Integer)
    kon = Column(Integer)

    participants = relationship("Participant", back_populates="controls")
    case = relationship("Case", back_populates="controls")


class Case(Base):
    """
    Case
    ----
    All cases in Swedish db.

    Inputs:
    - lopnr: Study ID
    - diadat: Date of diagnose in 8 digit string.
    - dia: diagnose
    - source:
    - kon: Sex {"1": "male", "2": "female"}
    """

    __tablename__ = "case"

    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer, ForeignKey("participant.lopnr"))

    diadat = Column(String(8))
    dia = Column(String(16))
    source = Column(String(3))
    kon = Column(Integer)

    participant = relationship("Participant", back_populates="cases")
    controls = relationship("Control", back_populates="case")


class Can(Base):
    """
    Cancer registry
    ---------------
    All entries in cancer registry.

    Inputs:
    - aterpnr:
    - alder:
    - ar:
    - ben:
    - dbgrund1:
    - diadat: Date of diagnose, 8 digit string.
    - diadatn: Date of diagnose, datetime object.
    - digr:
    - ...
    - etc.
    """

    __tablename__ = "can"

    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer, ForeignKey("participant.lopnr"))

    aterpnr = Column(Integer)
    alder = Column(Integer)
    ar = Column(Integer)
    ben = Column(Integer)
    dbgrund1 = Column(Integer)
    diadat = Column(String(8))
    diadatn = Column(Date)
    digr = Column(Integer)
    hemfr = Column(String(8))
    icd7 = Column(Integer)
    icd9 = Column(String(8))
    icdo10 = Column(String(16))
    icdo3 = Column(String(16))
    klinik = Column(Integer)
    kon = Column(Integer)
    m = Column(String(16))
    n = Column(String(16))
    obd1 = Column(Integer)
    pad = Column(Integer)
    region = Column(Integer)
    sjukhus = Column(Integer)
    snomed3 = Column(String(16))
    snomedo10 = Column(String(16))
    t = Column(String(16))
    tnmgrund = Column(String(16))
    tnr = Column(Integer)
    tnrmal = Column(Integer)

    participant = relationship("Participant", back_populates="cans")



class Dors(Base):
    """
    Dors
    ----
    Description of what dors is.

    Inputs:
    - ...
    """

    __tablename__ = "dors"

    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer,  ForeignKey("participant.lopnr"))

    dodsdatn = Column(Date)
    aterpnr = Column(Integer)
    foddat = Column(String(8))
    foddatn = Column(Date)
    dodsdat = Column(String(8))
    ar = Column(Integer)
    icd = Column(String(8))
    kon = Column(Integer)
    lkf = Column(Integer)
    ulorsak = Column(String(8))
    kap19 = Column(String(8))
    alder = Column(String(8))
    fodland = Column(String(32))
    dodutl = Column(String(8))
    kap17 = Column(String(8))

    # That's a LOOOOOT of columns...
    morsak1 = Column(String(8))
    morsak2 = Column(String(8))
    morsak3 = Column(String(8))
    morsak4 = Column(String(8))
    morsak5 = Column(String(8))
    morsak6 = Column(String(8))
    morsak7 = Column(String(8))
    morsak8 = Column(String(8))
    morsak9 = Column(String(8))
    morsak10 = Column(String(8))
    morsak11= Column(String(8))
    morsak12 = Column(String(8))
    morsak13 = Column(String(8))
    morsak14 = Column(String(8))
    morsak15 = Column(String(8))
    morsak16 = Column(String(8))
    morsak17 = Column(String(8))
    morsak18 = Column(String(8))
    morsak19 = Column(String(8))
    morsak20 = Column(String(8))
    morsak21 = Column(String(8))
    morsak22 = Column(String(8))
    morsak23 = Column(String(8))
    morsak24 = Column(String(8))
    morsak25 = Column(String(8))
    morsak26 = Column(String(8))
    morsak27 = Column(String(8))
    morsak28 = Column(String(8))
    morsak29 = Column(String(8))
    morsak30 = Column(String(8))
    morsak31 = Column(String(8))
    morsak32 = Column(String(8))
    morsak33 = Column(String(8))
    morsak34 = Column(String(8))
    morsak35 = Column(String(8))
    morsak36 = Column(String(8))
    morsak37 = Column(String(8))
    morsak38 = Column(String(8))
    morsak39 = Column(String(8))
    morsak40 = Column(String(8))
    morsak41 = Column(String(8))
    morsak42 = Column(String(8))
    morsak43 = Column(String(8))
    morsak44 = Column(String(8))
    morsak45 = Column(String(8))
    morsak46 = Column(String(8))
    morsak47 = Column(String(8))
    morsak48 = Column(String(8))

    # And some more.
    dbgrund1 = Column(String(8))
    dbgrund5 = Column(String(8))
    dbgrund7 = Column(String(8))
    dbgrund8 = Column(String(8))

    participant = relationship("Participant", back_populates="dors")


class Sv(Base):
    """
    Sv
    --
    Description of what Sv is.

    Inputs:
    - ...
    """

    __tablename__ = "sv"


    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer,  ForeignKey("participant.lopnr"))

    aterpnr = Column(Integer)
    alder = Column(Integer)
    alder_s = Column(Integer)
    ar = Column(Integer)
    diagnos = Column(String(1024))
    hdia = Column(String(1024))
    indatum = Column(Date)
    indatuma = Column(String(8))
    kon = Column(Integer)
    mvo = Column(String(8))
    op = Column(String(1024))
    sjukhus = Column(Integer)
    utdatum = Column(Date)
    utdatuma = Column(String(8))
    lk = Column(Integer)

    participant = relationship("Participant", back_populates="svs")


class Ov(Base):
    """
    Ov
    --
    Description of what Ov is.

    Inputs:
    - ...
    """

    __tablename__ = "ov"

    id = Column(Integer, primary_key=True, autoincrement=True)

    participant_lopnr = Column(Integer,  ForeignKey("participant.lopnr"))

    aterpnr = Column(Integer)
    alder = Column(Integer)
    alder_s = Column(Integer)
    ar = Column(Integer)
    diagnos = Column(String(1024))
    hdia = Column(String(1024))
    indatum = Column(Date())
    indatuma = Column(String(8))
    kon = Column(Integer())
    mvo = Column(String(8))
    op = Column(String(1024))
    sjukhus = Column(Integer())
    lk = Column(Integer())

    participant = relationship("Participant", back_populates="ovs")
