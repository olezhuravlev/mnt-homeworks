import time

import sentry_sdk
from sentry_sdk import capture_message, set_user, set_tag, add_breadcrumb, \
  set_context

sentry_sdk.init(
    dsn="https://b83f1a55fb2e487db0926c10a833a85c@o1370314.ingest.sentry.io/6674167",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
)


def devision_by_zero():
  division_by_zero = 1 / 0


def test_events():
  set_context("My_Context", {
    "project": "Netology",
    "info": "test",
  })

  set_user({"email": "jane.doe@example.com"})
  set_tag("Netology-Tag", "Centry Python Project")

  for event_level in ["off", "error", "info", "debug", "trace"]:
    print(event_level)

    add_breadcrumb(
        category='My Breadcrumb Category',
        message='My Breadcrumb Message',
        level=event_level,
        type='My Breadcrumb Type',
    )

    with sentry_sdk.push_scope() as scope:
      scope.set_extra('debug', False)
      capture_message('Event: Captured Message of level [' + event_level + ']',
                      event_level)

    time.sleep(1)


if __name__ == '__main__':
  # devision_by_zero()
  test_events()
