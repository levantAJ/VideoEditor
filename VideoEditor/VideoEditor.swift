//
//  VideoEditor.swift
//  VideoEditor
//
//  Created by Tai Le on 10/17/20.
//

import AVFoundation

open class VideoEditor {
    public init() {}
}

public extension VideoEditor {
    func merge(video: VideoEditor.Asset, audios: [VideoEditor.Asset],
               progress: ((Float) -> Void)?,
               completion: @escaping (Result<URL, Error>) -> Void) {

        // Create Asset from record and music
        let videoAsset = AVURLAsset(url: video.localURL)
        let audioAssets = audios.map { AVURLAsset(url: $0.localURL) }

        // Create compositions
        let composition = AVMutableComposition()

        guard let videoComposition = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID()) else {
            return
        }

        guard let audioInVideoComposition = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID()) else {
            return
        }

        let audioCompositions = audios.compactMap { _ in composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID()) }

        // Create tracks

        guard let videoAssetTrack = videoAsset.tracks(withMediaType: .audio)[safe: 0] else {
            completion(.failure(VideoEditorError.notFoundAudioInVideo))
            return
        }

        let audioAssetTracks = audioAssets.compactMap { $0.tracks(withMediaType: .audio)[safe: 0] }

        guard audioCompositions.count == audioAssetTracks.count,
              audioCompositions.count == audios.count else {
            return
        }

        let videoTimeRange = video.timeRange

        // Add video to the final record
        do {
            let track = videoAsset.tracks(withMediaType: .video)[0]
            try videoComposition.insertTimeRange(videoTimeRange, of: track, at: .zero)
        } catch {
            print(error)
            completion(.failure(error))
            return
        }

        let audioMix = AVMutableAudioMix()
        var audioMixParams: [AVMutableAudioMixInputParameters] = []

        // Add audio on final record
        // First: the audio of the record and Second: the music
        do {
            // Add original audio to final record
            try audioInVideoComposition.insertTimeRange(videoTimeRange, of: videoAssetTrack, at: .zero)
            // Adjust volume
            let videoAudioParams = AVMutableAudioMixInputParameters(track: videoAssetTrack)
            videoAudioParams.trackID = audioInVideoComposition.trackID
            videoAudioParams.setVolumeRamp(fromStartVolume: video.volume, toEndVolume: video.volume, timeRange: videoTimeRange)
            audioMixParams.append(videoAudioParams)
        } catch {
            completion(.failure(error))
            return
        }

        // Add audios to final record
        for i in 0..<audios.count {
            do {
                let timeRange = CMTimeRange(start: .zero, duration: audios[i].duration)
                try audioCompositions[i].insertTimeRange(timeRange, of: audioAssetTracks[i], at: audios[i].startTime)

                // Adjust volume
                let audioParams = AVMutableAudioMixInputParameters(track: audioAssetTracks[i])
                audioParams.trackID = audioCompositions[i].trackID
                audioParams.setVolumeRamp(fromStartVolume: audios[i].volume, toEndVolume: audios[0].volume, timeRange: timeRange)
                audioMixParams.append(audioParams)
            } catch {
                completion(.failure(error))
                return
            }
        }

        audioMix.inputParameters = audioMixParams

        let outputVideoLocalURL = makeOutputURL()

        //Export the final record
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        session.shouldOptimizeForNetworkUse = true
        session.outputURL = outputVideoLocalURL
        session.outputFileType = .mp4
        session.audioMix = audioMix
        export(with: session,
               progress: progress, completion: completion)
    }
}

// MARK: - Privates

extension VideoEditor {
    private func makeOutputURL() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "merged-video.mp4")
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
        return url
    }

    private func export(with session: AVAssetExportSession,
                        progress: ((Float) -> Void)?,
                        completion: @escaping (Result<URL, Error>) -> Void) {
        print("started")
        let outputURL = makeOutputURL()
        session.outputURL = outputURL
        session.exportAsynchronously {
            switch session.status {
            case .completed:
                print("success")
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            case .failed:
                print("failed")
                guard let error = session.error else { return }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .cancelled:
                print("cancelled")
                guard let error = session.error else { return }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .unknown:
                print("unknown")
            case .waiting:
                print("waiting...")
            case .exporting:
                progress?(session.progress)
            @unknown default:
                print("unknown")
            }
        }
    }
}

public extension VideoEditor {
    class Asset {
        public var localURL: URL
        public var volume: Float
        public var startTime: CMTime
        public var duration: CMTime

        /// Initialize asset add to composition
        /// - Parameters:
        ///   - localURL: The asset local URL
        ///   - volume: Volume of the asset will be adjusted to the final video
        ///   - startTime: The start time of the asset in the final video
        ///   - duration: The duration of the asset will be added into the final video
        public init(localURL: URL, volume: Float = 1,
                    startTime: CMTime = .zero, duration: CMTime? = nil) {
            self.localURL = localURL
            self.volume = volume
            self.startTime = startTime
            self.duration = duration ?? localURL.localAssetDuration
        }

        public var timeRange: CMTimeRange {
            return CMTimeRange(start: startTime, duration: duration)
        }
    }
}

public enum VideoEditorError: Int, Error {
    case notFoundAudioInVideo = 10000

    var localizedDescription: String {
        switch self {
        case .notFoundAudioInVideo:
            return NSLocalizedString("Cannot found audio in video!", comment: "")
        }
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension URL {
    /// This work only with local asset
    var localAssetDuration: CMTime {
        let asset = AVAsset(url: self)
        return asset.duration
    }
}
