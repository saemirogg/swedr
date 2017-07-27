from sqlalchemy import create_engine


def init_engine(user, passwd, dbname,
                host="localhost",
                port=3306,
                backend="mysqlconnector"):
    """Initialize engine"""
    # Create database url
    url = ('mysql+{backend}://{user}:'
           '{password}@{host}:'
           '{port}/{dbname}')

    # Create sqlalchemy engine for istopmm db.
    engine = create_engine(
        url.format(user=user, password=passwd,
                   host=host, port=port,
                   backend="mysqlconnector",
                   dbname=dbname))

    return engine


def create_table(model, engine):
    """Create a table in database"""
    if not engine.has_table(model.__tablename__):
        model.__table__.create(bind=engine)
