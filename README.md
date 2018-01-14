# Birthday Reminder

> The tool that helps you manage your favorite anime characters' births

![The index page of this app has a list of people and their birthdays](./GitHubPics/index.png)

[![Built with Love](https://forthebadge.com/images/badges/built-with-love.svg)](http://forthebadge.com)
[![Made with Swift](https://forthebadge.com/images/badges/made-with-swift.svg)](https://swift.org/)
[![For You](https://forthebadge.com/images/badges/for-you.svg)](http://forthebadge.com)

[![Stars](https://img.shields.io/github/stars/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge&label=Stars)](https://github.com/CaptainYukinoshitaHachiman/BirthReminder)
[![Forks](https://img.shields.io/github/forks/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge&label=Forks)](https://github.com/CaptainYukinoshitaHachiman/BirthReminder)
[![Watchers](https://img.shields.io/github/watchers/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge&label=Watchers)](https://github.com/CaptainYukinoshitaHachiman/BirthReminder)
[![Commit Activity](https://img.shields.io/github/commit-activity/y/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge)](https://github.com/CaptainYukinoshitaHachiman/BirthReminder)

[![Platform](https://img.shields.io/badge/Platform-iOS%20watchOS-green.svg?style=for-the-badge)](https://itunes.apple.com/us/app/birth-reminder/id1286497475?ls=1&mt=8)
[![Travis](https://img.shields.io/travis/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge)](https://www.travis-ci.org/CaptainYukinoshitaHachiman/BirthReminder)
[![License](https://img.shields.io/github/license/CaptainYukinoshitaHachiman/BirthReminder.svg?style=for-the-badge)](https://github.com/CaptainYukinoshitaHachiman/BirthReminder/blob/master/LICENSE)
[![Slack](https://img.shields.io/badge/Slack-BirthReminder-orange.svg?style=for-the-badge)](https://join.slack.com/t/birthreminder/shared_invite/enQtMjgwOTExNDA1MzE2LTkyZDQ3MWVmMmM0OWFhNzIyYzFkMGMwY2ZjMjY0ZGU1M2E2MTNjODlhNWQ1OTEzZmVlMWY4OTc5Njk0Njc1MTc)
# Features

## Supports both iOS and watchOS

This app supports iOS, iOS Today Extension, watchOS, and watchOS Complications

Wanna check the birth info? Just raise your wrist or swipe down from the top of your phone!

![](GitHubPics/applewatch.png)
![](GitHubPics/today.png)

## Online Birth Info

Of course, you may add the birth info manually, but it's usually time-consuming

Here, you may import characters easily

The only thing you need is to tap the ADD button

![Add button can be found on the upper-right corner](./GitHubPics/online.png)

# Download

Coming soon on the App Store

[![Download on the App Store](./GitHubPics/appstore.svg)](https://itunes.apple.com/us/app/birth-reminder/id1286497475?ls=1&mt=8)

Also, you may [join in beta testing](https://birth-reminder-testflight.herokuapp.com) in order to try the latest features.

# Contribution

## Online Info

If you would like to add more birth info, please [email the info](mailto:CaptainYukinoshitaHachiman@tcwq.tech) in this format
```JSON
{
	"anime":{
    	"name":"",
        "picUrl":"", // a url to the anime's pic (JPEG format, 200px*200px)
        "picCopyright":"" // a description of the copyright info of the pic, e.g. "pixiv, pidXXX", "Offical LOGO, http://xxx.png"
	},
    "characters":[ // an array which includes all the characters in the anime
    	{
        	"name":"",
            "birth":"", // the birth of the character, "MM-dd" formatted. e.g. "09-06" for Sept.6
            "picUrl":"", // a url to the anime's pic (JPEG format, 200px*200px)
        	"picCopyright":"" // a description of the copyright info of the pic, e.g. "pixiv, pidXXX", "CHARACTERS | 「妹さえいればいい。」\nhttp://.../chara_itsuki.png"
        }
    ]
}
```

(Only ACGN characters are welcome)

## APP Bug Report/Feature Suggestion

If you have nice ideas or find a bug in the app, please open an issue or a PR

<meta name="apple-itunes-app" content="app-id=1286497475">