# AlaskaWatch

Built with Flutter version 1.14.3

## Notes

Build Notes

* Local notifications were not working with the release apk, so if you want to test that then use the debug apk
* I tested it on Android (no iOS yet)

App Notes

* I chose to use navy blue and yellow since they are found on the Alaska state flag
* When sharing the forecast, it links to weather.com
* Sample weather alert page is copy and pasted from a sample one I found online
* For "severe weather", I created 3 criteria: 1) if wind is greater than 15 mph 2) UV Index is greater than 6 ("high" or up) and 3) if there is snow
* The weather cards on the home tab pages will show a red alert if you select a zip code with a current weather alert. You may have to try different zip codes to get one to show
* In the weather detail/forecast page, the 'set alerts' dialog is experimental
