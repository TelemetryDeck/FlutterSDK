import TelemetryDeck

/// Adds the Flutter SDK metadata to every event's context, replacing the native SDK identification.
struct SDKMetadataProcessor: EventProcessor {
    static let parameterPrefix = "TelemetryDeck.SDK."

    let parameters: [String: String]

    func process(
        _ input: EventInput,
        context: EventContext,
        next: nonisolated(nonsending) @Sendable (EventInput, EventContext) async throws -> Event
    ) async throws -> Event {
        var context = context
        context.addParameters(parameters)
        return try await next(input, context)
    }
}
