import json
import csv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input')
parser.add_argument('output')
args = parser.parse_args()
input_json_file = args.input
output_csv_file = args.output

with open(input_json_file, "r", encoding="utf-8") as f:
    json_data = json.load(f)

chip_dict = {}
for item in json_data["items"]:
    name = item["name"]
    if "芯片" not in name:
        continue

    have = item["have"]
    if name.endswith("芯片组"):
        prof = name[:-3]
        chip_type = "大"
    elif name.endswith("双芯片"):
        prof = name[:-3]
        chip_type = "双"
    elif name.endswith("芯片"):
        prof = name[:-2]
        chip_type = "小"
    else:
        continue

    chip_dict[(prof,chip_type)] = have

csv_lines = []
prof_order = ["先锋", "辅助", "狙击", "术师", "近卫", "特种", "重装", "医疗"]
type_order = ["小", "大", "双"]
for prof in prof_order:
    for type in type_order:
        count = chip_dict.get((prof, type), 0)
        csv_lines.append([prof, type, count])

with open(output_csv_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f, quoting=csv.QUOTE_STRINGS)
    writer.writerow(["职业","芯片类型","数量"])
    writer.writerows(csv_lines)

print(f"Convert {input_json_file} to {output_csv_file}")
