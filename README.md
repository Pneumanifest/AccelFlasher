# AccelFlasher
## Make a backup of your .cfg files before continuing, just in case. Its smart to have a backup anyway, so just do it. 

### What is this?
A simple script to flash and set up Bigtreetech LIS2DW v1 and ADXL345 v2 accelerometers.
It includes an option to make the required .cfg file changes makeing the process near fully automated.

### See it in action https://youtu.be/B0Pi_b7ekBg

### Download and use AccelFlasher
** Disclaimer: Use this at your own risk! I am not responsible for any loss data.**

* **Step 1:** \
git is required to download this repo to your machine. Use the following command if you are unsure that you have it installed.

```shell
sudo apt-get update && sudo apt-get install git -y
```

* **Step 2:** \
Use the following command to download AccelFlasher into your home-directory:

```shell
cd ~ && git clone https://github.com/Pneumanifest/AccelFlasher.git
```

* **Step 3:** \
Start AccelFlasher by running the next command:

```shell
./AccelFlasher/accelflasher.sh
```
* **When the Klipper Firmware Config opens configure it like this image.** \
![image](https://github.com/Pneumanifest/AccelFlasher/assets/117918822/56ab4f42-618f-433d-a9ad-8b374dfeab7f)

* **Remember to run SHAPER_CALIBRATE for CoreXY or SHAPER_CALIBRATE AXIS=X and SHAPER_CALIBRATE AXIS=Y for bed slingers with the sensor in the right place.** 
* **It is also importaint to set up the axes_map: x,y,z to match your sensor's orientation. Update that every time you move the sensor position.** 

## Affiliate Links to the sensor modules.
*  [BTT - ADXL345 v2](https://shareasale.com/r.cfm?b=1890927&u=3691202&m=118144&urllink=biqu%2Eequipment%2Fproducts%2Fadxl%2D345%2Daccelerometer%2Dboard%2Dfor%2D36%2Dstepper%2Dmotors&afftrack=ADXL345%20V2)
*  [BTT - LIS2DW V1](https://shareasale.com/r.cfm?b=1890927&u=3691202&m=118144&urllink=biqu%2Eequipment%2Fproducts%2Fadxl%2D345%2Daccelerometer%2Dboard%2Dfor%2D36%2Dstepper%2Dmotors%3Fvariant%3D40446852759650&afftrack=LIS2DW%20V1)
