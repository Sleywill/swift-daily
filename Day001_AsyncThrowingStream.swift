import Foundation

// MARK: - Day 001: AsyncThrowingStream
//
// AsyncThrowingStream is one of the most powerful tools in Swift Concurrency.
// Use it to bridge callback-based or delegate APIs into async/await.
//
// Example: wrapping a URLSession download with progress reporting

/// A download task that reports progress and delivers the final data.
struct AsyncDownloader {
    
    enum DownloadError: Error {
        case invalidURL
        case networkFailure(Error)
        case unexpectedStatusCode(Int)
    }
    
    /// Downloads a resource and emits progress updates (0.0 – 1.0) as it goes.
    ///
    /// - Parameter url: The remote URL to download from.
    /// - Returns: An `AsyncThrowingStream` of `Double` progress values,
    ///   ending with `1.0` when the download completes.
    func download(from url: URL) -> AsyncThrowingStream<Double, Error> {
        AsyncThrowingStream { continuation in
            let task = URLSession.shared.downloadTask(with: url) { _, response, error in
                if let error {
                    continuation.finish(throwing: DownloadError.networkFailure(error))
                    return
                }
                guard let http = response as? HTTPURLResponse,
                      (200..<300).contains(http.statusCode) else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    continuation.finish(throwing: DownloadError.unexpectedStatusCode(code))
                    return
                }
                continuation.yield(1.0)
                continuation.finish()
            }
            
            // Observe progress via KVO
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                continuation.yield(progress.fractionCompleted)
            }
            
            // Clean up when the caller cancels
            continuation.onTermination = { _ in
                observation.invalidate()
                task.cancel()
            }
            
            task.resume()
        }
    }
}

// MARK: - Usage

/*
 Task {
     let downloader = AsyncDownloader()
     guard let url = URL(string: "https://example.com/large-file.zip") else { return }
     
     do {
         for try await progress in downloader.download(from: url) {
             print(String(format: "Progress: %.0f%%", progress * 100))
         }
         print("Download complete!")
     } catch {
         print("Failed:", error)
     }
 }
 */
