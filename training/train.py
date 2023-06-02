import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn import preprocessing
import pickle
import glob, os, sys


def main(input_dir, output_dir):
    data = glob.glob(f"{input_dir}/*csv")[0]

    print("Loading Dataset")
    df = pd.read_csv(data, date_parser="Timestamp")
    df["Timestamp"] = pd.to_datetime(df["Timestamp"])

    print("Preprocessing Dataset")
    new_df = preprocessing(df)
    X = new_df.drop("Feeling anxious", axis=1)
    print(X.shape)
    print(X.columns)

    y = new_df.loc[:, "Feeling anxious"]

    print("Training Model")
    rf = RandomForestClassifier()
    rf.fit(X, y)

    print("Saving Model")
    pickle.dump(rf, open(f"{output_dir}/rf.pkl", "wb"))


def preprocessing(df):

    df = df.drop("id", axis=1)

    cols = [
        "Age",
        "Feeling anxious",
        "Feeling of guilt",
        "Feeling sad or Tearful",
        "Irritable towards baby & partner",
        "Overeating or loss of appetite",
        "Problems concentrating or making decision",
        "Problems of bonding with baby",
        "Suicide attempt",
        "Timestamp",
        "Trouble sleeping at night",
    ]

    df.columns = cols

    categorical_columns = [
        "Feeling sad or Tearful",
        "Irritable towards baby & partner",
        "Trouble sleeping at night",
        "Problems concentrating or making decision",
        "Overeating or loss of appetite",
        "Feeling anxious",
        "Feeling of guilt",
        "Problems of bonding with baby",
        "Suicide attempt",
    ]

    mapper = {"No": 0, "Yes": 1, "Maybe": 3, "Sometimes": 4}
    df["Feeling of guilt"] = df["Feeling of guilt"].astype("object")

    df_copy = df.copy()
    # Numericalize all categorical columns
    for x in df_copy[categorical_columns]:
        df_copy[x] = df_copy[x].str.capitalize().str.strip(" ")
        df_copy[x] = df_copy[x].map(mapper)

    # Age column feature engineering
    df_copy["Max Age"] = df_copy["Age"].str[:2].astype("int")
    df_copy["Min Age"] = df_copy["Age"].str[3:].astype("int")
    df_copy["Age"] = (df_copy["Max Age"] + df_copy["Min Age"]) / 2

    df_copy.fillna(0, inplace=True)

    # Remove Unnecessary features
    df_copy = df_copy.drop(["Timestamp", "Max Age", "Min Age"], axis=1)

    return df_copy


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Must pass arguments. Format: [command] input_dir output_dir")
        sys.exit()
    main(sys.argv[1], sys.argv[2])
