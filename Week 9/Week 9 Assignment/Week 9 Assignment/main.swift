// main.swift
// Build with: swiftc -O -parse-as-library main.swift -o ObjCapture
// Run: ./ObjCapture --input "/path/to/images" --output "/path/to/model.usdz" --detail medium


import Foundation
import RealityKit

#if canImport(RealityFoundation)
import RealityFoundation
#endif

@available(macOS 12.0, *)
enum CLIError: Error, CustomStringConvertible {
    case missingArgument(String)
    case invalidPath(String)
    case notDirectory(String)

    var description: String {
        switch self {
        case .missingArgument(let k): return "Missing required argument: \(k)"
        case .invalidPath(let p):    return "Invalid path: \(p)"
        case .notDirectory(let p):   return "Path is not a directory: \(p)"
        }
    }
}

@available(macOS 12.0, *)
struct Args {
    let inputFolder: URL
    let outputFile: URL
    let detail: PhotogrammetrySession.Request.Detail

    static func parse() throws -> Args {
        // Simple flag parser: --input, --output, --detail
        let argv = CommandLine.arguments.dropFirst()
        func value(for flag: String) -> String? {
            guard let i = argv.firstIndex(of: flag), argv.indices.contains(i+1) else { return nil }
            return String(argv[argv.index(after: i)])
        }

        guard let input = value(for: "--input") else { throw CLIError.missingArgument("--input <folder>") }
        guard let output = value(for: "--output") else { throw CLIError.missingArgument("--output <file.usdz>") }
        _ = value(for: "--detail") // accepted but ignored for maximum SDK compatibility

        let inputURL = URL(fileURLWithPath: input, isDirectory: true)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: inputURL.path, isDirectory: &isDir) else {
            throw CLIError.invalidPath(inputURL.path)
        }
        guard isDir.boolValue else { throw CLIError.notDirectory(inputURL.path) }

        let outputURL = URL(fileURLWithPath: output)
        let detail: PhotogrammetrySession.Request.Detail = .medium

        return Args(inputFolder: inputURL, outputFile: outputURL, detail: detail)
    }
}

@available(macOS 12.0, *)
func run() async throws {
    let args = try Args.parse()


    print("🔧 Starting photogrammetry…")
    print("   • Input folder: \(args.inputFolder.path)")
    print("   • Output file : \(args.outputFile.path)")
    print("   • Detail      : \(args.detail)")

    let session = try PhotogrammetrySession(input: args.inputFolder)

    // Listen for progress / results
    let outputsTask = Task {
        do {
            for try await output in session.outputs {
                // Print all events generically for maximum SDK compatibility
                print("ℹ️  Session event: \(output)")
            }
        } catch {
            print("Output stream error: \(error)")
        }
    }

    // Kick off reconstruction
    try session.process(
        requests: [.modelFile(url: args.outputFile, detail: args.detail)]
    )

    // Keep the process alive until the outputs finish
    _ = await outputsTask.value
}

if #available(macOS 12.0, *) {
    Task {
        do {
            try await run()
            exit(EXIT_SUCCESS)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(EXIT_FAILURE)
        }
    }
    dispatchMain()
} else {
    fputs("This tool requires macOS 12.0 or later.\n", stderr)
    exit(EXIT_FAILURE)
}
