from crontab import CronTab

if __name__ == '__main__':
    crontab = CronTab(user=True)
    crontab.remove_all()
    crontab.write()
