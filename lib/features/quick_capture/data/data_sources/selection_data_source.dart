abstract interface class SelectionDataSource {
  /// Returns the text selected in the frontmost app, or `null` when there is
  /// no readable selection.
  Future<String?> readSelectedText();
}
