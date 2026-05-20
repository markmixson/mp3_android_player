class AudioFile {
  final String path;
  final String name;
  final Duration duration;

  const AudioFile({
    required this.path,
    required this.name,
    required this.duration,
  });

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;
    return other is AudioFile &&
        other.path == path &&
        other.name == name &&
        other.duration == duration;
  }

  @override
  int get hashCode => path.hashCode ^ name.hashCode ^ duration.hashCode;

  @override
  String toString() =>
      'AudioFile(path: $path, name: $name, duration: $duration)';
}
