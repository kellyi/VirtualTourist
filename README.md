VirtualTourist
==============

VirtualTourist is the fourth app project for Udacity's [iOS Developer Nanodegree](https://www.udacity.com/course/ios-developer-nanodegree--nd003). It's the capstone app for the course on [iOS Persistence and Core Data](https://www.udacity.com/course/ios-persistence-and-core-data--ud325).

Using the app, you drop a pin on the map and retrieve a set of Public Domain and Creative Commons licensed photos from Flickr located near the pin's coordinates. You can see the photos from that spot presented in a UICollectionView, then choose to keep the pin's entire photo album, remove selected photos from the album, or load an entirely new collection from Flickr for those coordinates. 

The app uses the Flickr API to find and retrieve photos for latitude and longitude coordinates (selected when the user drops a pin on a map) and Core Data & NSFetchedResultsController to persist and show Pin and Photo objects. The image for each Photo object is saved as a .png file in the app's Documents directory, and the files are automatically deleted when the associated Photo object is deleted.

To run VirtualTourist on a simulator or on a device, you'll need to register for a Flickr API key and use that key for the `flickrAPIkey` variable in the `FlickrClient.swift` file.
