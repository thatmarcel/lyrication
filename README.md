# Lyrication
**Live Lyrics for jailbroken iOS devices**

## Building
You need to have [Theos](https://theos.dev/docs/installation) installed.

### Rootless
To build this tweak for iOS devices on rootless jailbreaks, run the following command:
```
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
```

### Rootful
To build this tweak for iOS devices on rootful jailbreaks, run the following command:
```
make package FINALPACKAGE=1
```


(This tweak started as a [tweak bounty](https://www.reddit.com/r/TweakBounty/comments/gl5m7w/30ios133_spotify_lyrics/) for Spotify and lot of the code for this tweak was written when I was still learning the basics of tweak development and Objective-C so don't judge the code quality too hard :p)