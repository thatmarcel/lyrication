# Lyrication
**Live Lyrics for jailbroken iOS devices**

## Building
You need to have [Theos](https://theos.dev/docs/installation) installed.

### Rootless
To build this tweak for iOS devices on rootless jailbreaks, run the following command:
```
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
```

You need to have the [iOS 15.6 SDK](https://github.com/theos/sdks/tree/master/iPhoneOS15.6.sdk) in the Theos SDKs folder or edit the Makefiles.

### Rootful
To build this tweak for iOS devices on rootful jailbreaks, run the following command:
```
make package FINALPACKAGE=1
```

The Makefiles currently assume you have Xcode 11.7 installed at `/Applications/Xcode_11.7.app` when packaging for rootful to ensure compatibility with A12+ devices on iOS 12.0-13.7 ([more here](https://theos.dev/docs/arm64e-deployment)). You can either download this version from Apple or edit the Makefiles if you want to build with a different version.

You also need to have the [iOS 13.7 SDK](https://github.com/theos/sdks/tree/master/iPhoneOS13.7.sdk) in the Theos SDKs folder or edit the Makefiles.


(This tweak started as a [tweak bounty](https://www.reddit.com/r/TweakBounty/comments/gl5m7w/30ios133_spotify_lyrics/) for Spotify and lot of the code for this tweak was written when I was still learning the basics of tweak development and Objective-C so don't judge the code quality too hard :p)