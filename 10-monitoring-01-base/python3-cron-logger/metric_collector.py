import json
import os
import pathlib
from datetime import datetime, timezone
from pathlib import Path

METRICS_DIR = "/proc"
FILE_NAME = "-awesome-monitoring.log"
DATE_FORMAT = "%y-%m-%d"


def save_data(dir, metrics):
    Path(dir).mkdir(parents=True, exist_ok=True)

    timestamp = metrics[0]
    datetime_timezone = datetime.fromtimestamp(timestamp)
    current_date = datetime_timezone.strftime(DATE_FORMAT)
    current_file_name = current_date + FILE_NAME
    current_path = dir + os.path.sep + current_file_name

    metrics_json_string = json.dumps(metrics)
    with open(current_path, "a") as log_file:
        log_file.write(f"{metrics_json_string}\n")


def get_load_average():
    with open(METRICS_DIR + '/loadavg', 'r') as file:
        rows = file.read().split(' ')

    return rows


def get_memory_usage():
    data = {}
    with open(METRICS_DIR + '/meminfo', 'r') as file:
        for row in file:
            (key, value) = row.split(': ')
            data[key.strip()] = value.strip()

    return data


def collect_metrics():
    datetime_timezone = datetime.now(tz=timezone.utc)
    timestamp = datetime_timezone.timestamp()

    load_average = get_load_average()
    metric_1 = load_average[0]
    metric_2 = load_average[1]
    metric_3 = load_average[2]

    memory_usage = get_memory_usage()
    metric_4 = memory_usage['MemTotal']
    metric_5 = memory_usage['MemFree']
    metric_6 = memory_usage['MemAvailable']

    metrics = [timestamp, metric_1, metric_2, metric_3, metric_4, metric_5, metric_6]

    return metrics


if __name__ == '__main__':
    metrics = collect_metrics()
    current_dir = pathlib.Path(__file__).parent
    save_data(str(current_dir) + os.path.sep + "log", metrics)
