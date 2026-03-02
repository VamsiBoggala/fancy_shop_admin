List<String> generateSearchKeywords(String name, String brand) {
  final Set<String> keywords = {};

  // Combine brand and name into a single string
  final combinedString = '$brand $name'.toLowerCase();

  // Replace any special characters with space to separate words cleanly
  final cleanString = combinedString.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

  // Split the string into individual words by whitespace
  final words = cleanString.split(RegExp(r'\s+'));

  // Common stop words to exclude
  final stopWords = {'and', 'the', 'with', 'in', 'on', 'of', 'for', 'a', 'an'};

  for (final word in words) {
    if (word.isEmpty || stopWords.contains(word)) continue;

    // Add the full word just to be sure
    keywords.add(word);

    // Generate prefixes for the word (advanced feature)
    String prefix = '';
    for (int i = 0; i < word.length; i++) {
      prefix += word[i];
      keywords.add(prefix);
    }
  }

  // Set naturally removes duplicates, return as List
  return keywords.toList();
}
