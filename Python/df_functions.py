import pandas as pd

def extract_unique_values(src_fname, src_colname, tgt_df, tgt_colname, **kwargs):
    """
    Extract unique values from columns
    and append to target column.

    Inputs
        - src_fname: source filename
        - src_colname: source column name
        - tgt_df: target dataframe
        - tgt_colname: target column name
    Output:
        - Pandas DataFrame
    TODO:
        - Use pandas series instead of dataframe. Now it's a bit confusing.
        - ...
    """
    # Load dataframe
    df = pd.read_csv(src_fname,
                     usecols=[src_colname],
                     **kwargs)
    # Group dataframe by unique values in column
    df = (df[src_colname]
          .groupby(df[src_colname])
          .first())
    # Create mask of values that match target dataframe.
    mask = (df.index.get_level_values(src_colname)
            .isin(tgt_df[tgt_colname]))
    # Select values that are NOT in target dataframe
    df = df[~mask]
    # Create output by appending values to target.
    tgt_df = tgt_df.append(pd.DataFrame({tgt_colname: df.values}))

    return tgt_df


def int_or_null(val):
    """
    Return integer if value in column can be
    converted to integer, else return None

    Example:
    >>> df = pd.DataFrame({"ints": ["1", 2.1, "NotAnInt"]})
    >>> df.ints.apply(int_or_null)
    0    1.0
    1    2.0
    2    NaN
    Name: ints, dtype: float64
    """
    try:
        out = int(val)
    except:
        out = None
    return out
