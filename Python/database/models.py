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
    fodland = Column(String(8))
    dodutl = Column(String(8))
    kap17 = Column(String(8))

    participant = relationship("Participant", back_populates="dors")



# Add some attributes to Dors, systematically.
for i in range(48):
    setattr(Dors, ("morsak%d" % i), String(8))

# Add some more attributes to Dors, systematically.
for i in [1, 5, 7, 8]:
    setattr(Dors, ("dbgrund%d" % i), String(8))


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
    mvo = Column(Integer)
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
    mvo = Column(Integer())
    op = Column(String(1024))
    sjukhus = Column(Integer())
    lk = Column(Integer())

    participant = relationship("Participant", back_populates="ovs")
