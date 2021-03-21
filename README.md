# NasaSearch

Search for images from NASA and view details about each image.


***App Demo***

<img src="Demo/NasaSearchDemo.gif" width="300">


***Demo Highlights***

- Detail view properly handles situations where the location, or photographer are not provided by the API
- Detail view enables scrolling for long descriptions
- Pagination triggered when the bottom of the scrollView is approaching
- Configurable appearance (dark mode)
- Alert triggered if no results are found for a given search


***Code Highlights***

- Caches images
- Uses Swift's Result type with custom NasaImageError
- Autolayout for correct formatting on any device size


***Here are the things I would work on with more time for future versions:***

- Activity indicator when loading data
- Make a more versatile URL constructor
- Have cache clear after certain duration of time, currently it just clears when the app is killed
- UI to show the total number of results for a given search
- Handle playing videos for the results that come back with a video link instead of a photo link
- Custom error alerts for things like no internet connection, internal errors, etc.
