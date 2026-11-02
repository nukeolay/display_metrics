## 1.7.0
* Added iPhone Duo device mapping (foldable: 7.6" inner and 5.4" outer display) (thanks @Tilmanfs95, [#39](https://github.com/nukeolay/display_metrics/pull/39))
* Screen metrics are now computed on every call instead of once, so they follow the active display of foldable devices
* On the iPhone Duo, screen metrics use the screen of the foreground app scene, because `UIScreen.main` keeps reporting the outer display
* Devices missing from the device table (e.g. a new foldable) also use the screen of the foreground app scene, so *onUnknownDisplay* receives the resolution of the active display (all other devices still use `UIScreen.main`)

## 1.6.0
* Added **IosUnknownDisplayInfo** class (extends **UnknownDisplayInfo** with model identifier)
* Unknown devices are reported via *getDisplaysReport* as **IosUnknownDisplayInfo** instead of being dropped
* Added *getModelIdentifier* method channel call

## 1.5.0
* Added Fall 2026 device mappings:
  * iPhone 18 Pro
  * iPhone 18 Pro Max

## 1.4.0
* Added Swift Package Manager compatibility

## 1.3.0
* Added Spring 2026 device mappings:
  * iPhone 17e
  * iPad Air M4 11"
  * iPad Air M4 13"
* Added missing device mappings:
  * iPad mini 7 (2024)
  * iPad Pro M5 11" (2025)
  * iPad Pro M5 13" (2025)
* Corrected iPad mini (6th gen) sizing from 7.9" to 8.3"

## 1.2.0
* Added Fall 2025 iOS devices support (thanks @rotsen24154):
  * iPhone 17
  * iPhone 17 Pro
  * iPhone 17 Pro Max
  * iPhone 17 Air

## 1.1.0
* Updated `display_metrics_platform_interface` dependency (1.1.0)

## 1.0.3
* Added Spring 2025 iOS devices support:
  * iPhone 16e
  * iPad Air M3 (7th gen) 11", 13"
  * iPad A16 (11th gen) 11"

## 1.0.2
* Updated documentation

## 1.0.1
* Updated documentation

## 1.0.0
* Initial release