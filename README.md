#WebVisions Portland 2016

*May 18 - 20, 2016*

Workshop: [On the Verge of Genius](http://www.webvisionsevent.com/workshop/how-to-build-a-crowdsourced-pollution-monitoring-device/)

Cross a WebVisions workshop with Bill Nye the Science Guy (or Mr. Wizard depending on your generation), and you will get IBM's Kevin Hoyt, leading you through an interactive, hands-on, exploration of the increasingly connected world of cities, farms, and you.  

On this three-hour tour, the weather may just get rough, but smart cities with vast arrays of connected sensors will keep us on course and on time. Leaving the city behind, we will discover that data is the new fertilizer for the green acres of smart agriculture. The next stop on this fantastic voyage is inner space as we seek to leverage smart healthcare to unlock the secrets of heart disease and asthma.

This workshop is packed with live demonstrations of a large number of scientific sensors in action. The PH of your drinking water. The air quality of the conference center. The galvanic skin response (sweating) of the presenter. And many more. Having established the possibilities, you will have the option to spend an hour with your very own Internet-connected hardware. Solving the world's problems is hard work, but together we can achieve genius.

**What You'll Learn**

- How crowdsourcing social change and overcoming human bias in decision making, is leading to the rise of the machines;
- How cities like Amsterdam and London are using the Internet of Things to protect personal property and save lives;
- How companies like Harman and John Deere discovered the best user experience to keep up with population growth;
- How the science of you may just be able to eradicate the world biggest health problems - if you let it;
- Basic electronics, and how to connect a device of your own to an Internet of Things platform using Arduino.

**Who Should Attend**

If you think products like the Google Nest are cool, but are not sure what value they play in society, this workshop is for you. If you look at the emergence of self-driving cars, and wonder about the economic impact, this workshop is for you. If you enjoy gardening or farm-to-table food, and want to find out how to make that scale to a societal level, this workshop is for you. If you fear Skynet, this workshop is for you. If you picked up on any of the 60s, 70s, and 80s references in the overview, this workshop is for you. Or, if you just want to geek out with Internet-connected hardware, this workshop is for you.

Session: [The Business of Beacons](http://www.webvisionsevent.com/session/the-business-of-beacons/)

Built on BLE (Bluetooth Low Energy) beacons get a lot of press, and have seen increasing deployment around the globe, adding value to business and consumers. In this session, join IBM Developer Advocate, Kevin Hoyt, on a journey through beacon opportunities you may not have considered. Practical, real-world, references will be highlighted as we examine innovative use-cases for beacons in your business.

**Examples Covered**

*Table Service*

Leveraging inexpensive beacons at every table, restaurants might allow customers to order food and pay their bills using the smartphone they bring with them. This in turn increases customer satisfaction, as well as the number of customers that can be served in any given amount of time.

*Pathfinding*

Ever have problems finding an item in a grocery store?  What if beacons automatically transformed your shopping list into the most efficient route through the aisles? What if you only had to take one trip to the hardware store for your next home improvement project? Beacons can provide real-time location support for indoor settings.

*Localization*

While English is easily the most common language encountered in the United States, did you know that there are also nearly three-million people that speak Chinese? Tagalog, French, German, Korean, and Vietnamese account for another six-million. Supporting those languages on signage is a nearly impossible UX task.  Beacons can provide location-aware translation of subway maps, zoos, museums, historical landmarks and more.

*Venue Analytics*

A growing number of brick-and-mortar retail stores are leveraging A/B testing to optimize the layout of their products. Beacons can add a wealth of information as they track customer movement through the store itself. They could also then highlight relevant items for consumers, and even integrate access to off-site product.

*Logistics*

You just finished a long day of travel, and arrive at your hotel only to wait in yet another line. Beacons can enable you to bypass that line altogether, and go straight to your room.  They could be further integrated with hotel services such as valet parking and concierge services, optimizing the time usage of not only the staff, but improve the overall customer experience.

##Basics

A basic iOS (Swift) application showing the core parts of interacting with beacons, obtaining their details, and updating the screen based on those values.

##Bean

An iOS (Swift) application using the Light Blue Bean by Punch Through.  The Bean has an Arduino compatible programming workflow.  An Arduino sketch that increments a value by one every second is loaded onto the Bean.  That sketch also updates the Bluetooth "scratch" characteristic with the value.  When that value is changed on the Bean, the iOS application is notified and the latest value is displayed.

**TODO:** Additional example using I2C sensor.  Requires battery considerations.

##Restaurant

Rough, first-pass, demonstration at using a smartphone, plus beacons, to replace the Ziosk tablet ordering system (commonly found in chains such as Chili's).  Beacon specifies the store and table for the customer location.  Ordering is routed through Watson IoT to point of sale (POS) systems.  Uses publish/subscribe to make easier to wire into other systems.  Includes a basic dashboard to show management/business side of viewing the data.

##Rhythm

Using the Scosche Rhythm+ arm band heart rate monitor with an iOS (Swift) application.  This shows pairing iOS with a generic device using specified GAT UUIDs.  As the wearers heart rate changes, the sensor device notifies the iOS application.  The iOS application updates the screen with heart rate value from the sensor device.

At the same time, the iOS application also connects to Watson IoT (MQTT).  As new heart rate measurements arrive, the values are serialized into a JSON string, and published to a Watson IoT topic.

**TODO:** Store values in Cloudant (CouchDB).  Add charting to web page.

##Signs

The concept presented is to allow a smartphone to provide localization based on beacon information.  This application listens for beacons.  When one or more beacons are found, the closest one is singled out.  Based on the beacon information, a database query is made against Cloudant (NoSQL, CouchDB) to get textual information relative to the beacon (as beacons do not store this information themselves).  The resulting text is display on the screen.

By tapping the screen, the user can have Watson translate the text into Spanish.  Once that result has been retrieved, Watson is then tasked to speak the copy using the device audio features.

##Stage

A replacement for the "Basics" application, that shows physical location on the stage, rather than the technical details from the beacon(s).  Application running on iOS (Swift) looks for beacons, then determines the closest one.  Sends data about the closest one to Watson IoT.  A page in a browser is connected to Watson IoT, and subscribed for the location messages.  Highlights a side of the screen when the message arrives.

This demonstration replaced the "basics" application when I saw that Revolution Hall had a photo on their website from the perspective of the stage.  The additional context, and real-time pub/sub to the browser make for a better demonstration.

##Tag

Working with a Texas Instruments SensorTag product using Bluetooth LE from iOS (Swift).  The SensorTag can actually be changed to three different radio types, one of which (the default) is Bluetooth Smart.  The SensorTag is also packed with a number of sensors, as well as output controls such as a buzzer and different color LEDs.  This makes it ideal for getting started when learning BLE.

This example shows interrogating multiple SensorTag services as the same time.

**TODO:** Add controlling an LED or buzzer from iOS.
