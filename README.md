# NasaSearch

Search for images from NASA and view details about each image.


***App Demo***

*gif format sacrifices some visual app smoothness quality

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
