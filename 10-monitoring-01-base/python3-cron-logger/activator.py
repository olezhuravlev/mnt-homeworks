import os
import pathlib

from crontab import CronTab

if __name__ == '__main__':

    crontab = CronTab(user=True)
    crontab.remove_all()

    current_dir = pathlib.Path(__file__).parent
    job = crontab.new(command="python3 " + str(current_dir) + os.path.sep + "metric_collector.py")
    job.minute.every(1)

    for job in crontab:
        print(job)

    crontab.write()
