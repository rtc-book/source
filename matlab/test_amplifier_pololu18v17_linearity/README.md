# Linearity tests for the Pololu 18v17 motor driver

The purpose of the experiment that this directory analyzes is to measure the linearity of the Pololu 18v17 motor driver. The main result is that the driver is quite linear, as shown in the following plot.

![The primary result of the experiment.](voltage-means.svg)

Some details of the experiment follow.

## Setup

Below is the test setup for test **r2**.

![](test-rt.jpg)

The resistors $R_1$ and $R_3$ are power resistors that together comprise the load, measured to be $11.48$ Ω. The 10 mF capacitor smooths the PWM. The reason the load is split is to allow the smoothing to occur (otherwise the cap is a dependent energy storage element) and to divide down the voltage somewhat for the measurement. To use the myRIO A Connector for the AI measurement, the signal must be divided again, as shown. 

We had intended to do several runs, but the difficulty in setup and time constraints were prohibitive. In the end, we only completed **r1** and **r2**, which both had the same load resistance. Run **r2** was for negative voltages, which had to be separated from the positive voltages due to the 0-5 V voltage range of the AI, the voltage divider, and the polar capacitor. Run **r1** was for positive voltages. The setup differed slightly from the figure above: it is important to have the capacitor voltage drop in the proper direction and for the voltage divider to have its low side at ground. Due to the high power, soldering and resoldering were required for the load on each setup. The voltage divider was on a breadboard.