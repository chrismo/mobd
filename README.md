mobd
====

Screwing around with https://github.com/jeffpeterson/obd to 
figure out why my 'check engine' light is on.

See:
- http://en.wikipedia.org/wiki/OBD-II_PIDs#Standard_PIDs
- http://www.elmelectronics.com/DSheets/ELM327DSH.pdf

You'll need a cable, too: 
- http://www.amazon.com/ELM327-OBDII-CAN-BUS-Diagnostic-Scanner/dp/B005FEGP7I/

Fire up pry after installing, then:

```ruby
# presumes Mac OS X and the above cable
a = Auto.detect
a.debug # toggle on debug mode if you want
a.error_codes
```

You may need to try it more than once to get it to work.
