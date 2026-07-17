# APB RTC UVM Environment

The UVM 1.2 environment contains an APB agent, monitor, scoreboard, reusable
register sequences, and tests for register access, calendar rollover, alarm,
and second-tick interrupts.

Run the complete regression with:

```sh
make run
```

Run one test with:

```sh
make run UVM_TEST=apb_rtc_calendar_test
```
