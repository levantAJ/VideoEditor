[![Pod Version](https://cocoapod-badges.herokuapp.com/v/VideoEditor/badge.png)](http://cocoadocs.org/docsets/VideoEditor/)
[![Pod Platform](https://cocoapod-badges.herokuapp.com/p/VideoEditor/badge.png)](http://cocoadocs.org/docsets/VideoEditor/)
[![Pod License](https://cocoapod-badges.herokuapp.com/l/VideoEditor/badge.png)](https://www.apache.org/licenses/LICENSE-2.0.html)

# 📽 VideoEditor
*VideoEditor* facilitates video editing

## Requirements

- iOS 9.0 or later
- Xcode 11.0 or later

## Install

### Installation with CocoaPods

```ruby
pod 'VideoEditor', '1.0'
```

### Build Project

At this point your workspace should build without error. If you are having problem, post to the Issue and the
community can help you solve it.

## How to use:

```swift
import VideoEditor
```

### Merge multiple audios to a video.
1: Prepare the source video asset.
 
```swift
let videoAsset = VideoEditor.Asset(localURL: yourVideoLocalURL, volume: 1)
``` 
- With `volume`, you can able to adjust to volume of video in 0...1

2: Prepare the audios

```swift
let firstAudioAsset = VideoEditor.Asset(localURL: firstAudioLocalURL, volume: 0.5, startTime: .zero, duration: videoDuration)

let secondAudioAsset = VideoEditor.Asset(localURL: secondAudioLocalURL, volume: 0.7, startTime: CMTime(seconds: 2, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), duration: secondAudioDuration)
```

- `startTime` is the point of time that you wanna add your audio into the final video, e.g. add set `startTime` as `CMTime(seconds: 3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))` to tell engine to start add this audio from the third second of the final video.

- `duration` indicates how long the audio will be added into the final video from the `startTime`. Usually set it equal to the audio asset duration. Set `nil` to tell the `duration` is its duration.

3: Start to merge

```swift
let videoEditor = VideoEditor()
videoEditor.merge(video: videoAsset, audios: [firstAudioAsset, secondAudioAsset], progress: { progress in
    print(progress)
}, completion: { result in
    switch result {
    case .success(let videoURL):
    	print(videoURL)
    case .failure(let error):
    	print(error)
    }
})
```

## Author
- [Tai Le](https://github.com/levantAJ)

## Communication
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Licenses

All source code is licensed under the [MIT License](https://raw.githubusercontent.com/levantAJ/VideoEditor/master/LICENSE).

