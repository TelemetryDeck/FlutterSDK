enum ErrorCategory {
  thrownException,
  userInput,
  appState,
  @Deprecated(
    'Not supported by the native SDKs; the category is omitted from the signal.',
  )
  integration,
  @Deprecated(
    'Not supported by the native SDKs; the category is omitted from the signal.',
  )
  unknown,
}
