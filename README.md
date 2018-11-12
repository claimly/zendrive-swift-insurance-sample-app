## Introduction

It is important for Fairmatic’s on-demand customers to appropriately tag their trips with the correct insurance period so that Fairmatic can measure their safety/risk based on the period of driving via the Zendrive SDK. With this measurement in place, Fairmatic may be positioned to unlock potentially significant commercial auto insurance savings.  Insurance risk premiums are determined using the mileage from P1, P2, and P3 periods and each period carries a different amount of risk and insurance coverage. Without the appropriate tagging of trips, Zendrive will be limited in its value creation today and in the future from an insurance standpoint.

## Tracking Regulatory Periods
Marking the start and end of each period will allow Fairmatic to accurately assess the risk of the fleet when providing quotes for commercial auto insurance. The three periods are defined as follows:


  *Period 1: The driver or courier is logged into the mobile application, is available for ride requests, but is not yet matched with a passenger (or a good).
  *Period 2: The driver or courier has accepted a match with a prospective passenger (or good) but that passenger (or good) is not yet physically in the vehicle.
  *Period 3: The driver or courier has picked up the passenger (or good) and the driver’s vehicle is occupied. If the passenger count changes, start another manual trip with startDriveWithPeriod3.