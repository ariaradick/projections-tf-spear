import pandas as pd

def update_qc(df, var_id, platform, qc_status):
    df.loc[(df["variable_id"] == var_id) & (df["platform"] == platform), "pass_qc"] = qc_status