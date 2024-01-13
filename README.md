# AccelFlasher
## This is a work in progress, but it's working as expected so far. 
## Make a backup of your .cfg files just in case. Its smart to have a backup anyway, so just do it. 

### What is this?
A simple script to flash and set up Bigtreetech LIS2DW v1 and ADXL345 v2 accelerometers.
It includes an option to make the required .cfg file changes makeing the process near fully automated.

### Download and use AccelFlasher
** Disclaimer: Usage of this script happens at your own risk!**

* **Step 1:** \
Use the following command to download AccelFlasher into your home-directory:

```shell
cd ~ && git clone https://github.com/Pneumanifest/AccelFlasher.git
```

* **Step 2:** \
Start AccelFlasher by running the next command:

```shell
./AccelFlasher/accelflasher.sh
```
* **When the Klipper Firmware Config opens configure it like this image.
![image](https://github.com/Pneumanifest/AccelFlasher/assets/117918822/56ab4f42-618f-433d-a9ad-8b374dfeab7f)

* **Remember to run SHAPER_CALIBRATE for CoreXY or SHAPER_CALIBRATE AXIS=X SHAPER_CALIBRATE AXIS=Y for bed slingers wht the sensor in the right place.
* **It is also importaint to set up the axes_map: x,z,y to match your sensor's orientation.

 
