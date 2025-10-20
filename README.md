# Forecast-Friend

A flutter weather application

## Application breakdown

- 3 pages
  - About page
    - Simple text
  - Add location Page
    - Search bar
    - Single panel
    - Back button
    - Star button
  - Main page
    - Carousel
      - Current location
      - Saved locations

## Expected behaviour

On application open, you will be prompted to allow the application to access the device location. I reccomend that you grant the access but I won't tell you what to do.

## Home Tab

The home page will display:

- The town name.
- The day's max, current and min temperature.
- A summary of the weather conditions with a matching gif
- The UV index, wind speed, humidity, air pressure, visibility.
- The 3 hour interval forecast displayed with icons that represent the anticipated weather condition.
- The 5 day forecast shows the average temperature of the next 5 days and an icon to represent the expected weather conditions.

All acquired using api calls to open weather.

In my emulator the default location is San Francisco, USA but this can be changed in the emulator settings. Since the application is being loaded for the first time there are no other saved locations.
Oh, you'd like to add some locations? Amazing, head to the search tab

## Search Tab

Start typing up a city name. For this part I used google's autocomplete service for location search. Caveat, I was not able to restrict the available options to towns or cities so if you click on some locations an error will be thrown for the location being too specific to give the forecast. This only happens for locations that are NOT in the format (city, country).

But when an error is not thrown, a card will be created with that town's weather details. This card will have a grey star outline and you can tap it to add it to your saved towns. I recommend adding towns in differnt time zones and climates to see the different gif animations. I searched long and hard to find free ones that kinda looked the same and I'd really like for someone else to see them.

Go back to the home page to view the current and future weather conditions of the current and saved locations. To remove a location from the saved towns, just tap the star icon then go to another tab and go back to home tab as a force refresh. I tried to figure out how to get the app to refresh automatically but I failed so force refresh it is.

## About Tab

Displays a brief about the application.

## API calls

I used three api keys for this project located in the .env file. If you have your own you may can change the saved ones. I know the fast life of api calls can be thrilling but do restrain yourself to a reasonable amount of calls as there is a threshold I would prefer not to cross to avoid getting charged by google.
