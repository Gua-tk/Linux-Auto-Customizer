import os


# First we get a list of all feature names
# All feature names is stores at the file .data/core/feature_keynames.txt
# Read the .txt and append each one to feature_names list.
feature_names = []
with open("../core/feature_keynames.txt") as doc:
    for key_name in doc.readlines():
        feature_names.append(key_name.strip('\n'))

for name in feature_names:
    feature_tags = []
    feature_path = "../features/" + name + "/" + name + ".dat.sh"

    feature_keyname_file = open(feature_path)
    for key_name_file_line in feature_keyname_file.readlines():
        if key_name_file_line.startswith(name + '_tags='):
            feature_tags = key_name_file_line.split('=')[1].replace("(", "").replace(")", "").replace('"', "").strip('\n').split(" ")

    for feature_name in feature_names:
        for feature_tag in feature_tags:
            print("Feature name " + feature_name + "\nFeature tag: " + feature_tag)
            if feature_name.__eq__(feature_tag):
                print("ERROR: The feature " + feature_name + " has the conflicting tag " + feature_tag + ".")
